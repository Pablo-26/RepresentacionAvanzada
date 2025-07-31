import streamlit as st
import pandas as pd
import json
import re
from converter import (
    convert_csv_to_ttl,
    render_rdf_graph,
    get_available_properties,
    load_config
)
from rdflib import Graph
import google.generativeai as genai

# --- Cargar configuración de config.json---
config = load_config()
if not config:
    st.error("❌ Error: No se pudo cargar el archivo de configuración (config.json). Asegúrate de que exista y sea válido.")
    st.stop()

# --- Función para extraer JSON de respuesta de Gemini ---
def extract_json_from_text(text):
    try:
        match = re.search(r'\{.*\}', text, re.DOTALL)
        if match:
            return json.loads(match.group(0))
        return {}
    except json.JSONDecodeError:
        return {}

# --- Configuración de Gemini API ---
GENAI_API_KEY = 'AIzaSyDUwbGcmcaa-5ObXcxUsoSqQxGGp4HJWjg'

if GENAI_API_KEY:
    genai.configure(api_key=GENAI_API_KEY)
else:
    st.error("❌ Error: La clave de API de Gemini no está configurada. Por favor, asegúrate de que \'GENAI_API_KEY\' esté definida.")

# --- Configuración de la página de Streamlit ---
st.set_page_config(page_title="Conversor de Scopus Data a RDF", layout="wide")
st.title("📄🧠📘 Conversor de Scopus CSV a RDF")
st.markdown("Carga el archivo en Formato CSV para la conversión a RDF.")

# --- Carga de archivos CSV ---
csv_file = st.file_uploader("📎 Carga tu archivo CSV de Scopus", type=["csv"])

if csv_file:
    df = pd.read_csv(csv_file)
    st.success("✅ Archivo CSV cargado. Estas son las columnas existentes:")
    st.write(df.columns.tolist())

    st.markdown("---")
    st.header("⚙️ Validación del Mapeo Semántico")

    user_mapping = {}

    # --- Mapeo de Autores ---
    with st.expander("👤 Autores", expanded=True):
        c1, c2 = st.columns(2)
        
        # Obtener valores por defecto del config.json
        default_author_full_names = config['default_mappings'].get('author_full_names_col', '')
        default_author_ids = config['default_mappings'].get('author_ids_col', '')

        # Selectbox para nombres completos de autor
        user_mapping['author_full_names_col'] = c1.selectbox(
            "Columna con nombres completos de autor",
            df.columns,
            index=df.columns.get_loc(default_author_full_names) if default_author_full_names in df.columns else 0
        )
        # Selectbox para IDs de autor
        user_mapping['author_ids_col'] = c2.selectbox(
            "Columna con IDs de autor",
            df.columns,
            index=df.columns.get_loc(default_author_ids) if default_author_ids in df.columns else 0
        )

    # --- Mapeo de Fuente de Publicación (Journal/Conferencia) ---
    with st.expander("📚 Fuente de Publicación (Journal/Conferencia)", expanded=True):
        c1, c2, c3 = st.columns(3)

        default_source_title = config['default_mappings'].get('source_title_col', '')
        default_volume = config['default_mappings'].get('volume_col', '')
        default_issue = config['default_mappings'].get('issue_col', '')

        user_mapping['source_title_col'] = c1.selectbox(
            "Columna con el título de la fuente",
            df.columns,
            index=df.columns.get_loc(default_source_title) if default_source_title in df.columns else 0
        )
        user_mapping['volume_col'] = c2.selectbox(
            "Columna de Volumen",
            df.columns,
            index=df.columns.get_loc(default_volume) if default_volume in df.columns else 0
        )
        user_mapping['issue_col'] = c3.selectbox(
            "Columna de Edición (Issue)",
            df.columns,
            index=df.columns.get_loc(default_issue) if default_issue in df.columns else 0
        )

    # --- Mapeo de Propiedades del Artículo ---
    with st.expander("📄 Propiedades del Artículo"):
        direct_mappings = {} 
        property_options = get_available_properties() 
        
        # Obtener las columnas mapeables y sus propiedades por defecto desde config.json
        mappable_cols_from_config = {item['csv_column']: item['rdf_property'] for item in config.get('column_mappings', [])}
        
        # Filtrar las columnas del CSV que existen en el config.json y no han sido usadas en mapeos anteriores
        mappable_cols = [col for col in df.columns if col in mappable_cols_from_config and col not in user_mapping.values()]

        grid = st.columns(3)
        col_idx = 0
        for col in mappable_cols:
            default_prop = mappable_cols_from_config.get(col, "")
            
            initial_index = 0
            if default_prop and default_prop in property_options:
                initial_index = property_options.index(default_prop)
            
            if col not in st.session_state:
                st.session_state[col] = default_prop
            
            with grid[col_idx % 3]:
                selected_value = st.selectbox(
                    f"Columna: **{col}**",
                    options=property_options,
                    index=initial_index,
                    key=col
                )
                direct_mappings[col] = selected_value 
            col_idx += 1
        user_mapping['direct_mappings'] = direct_mappings

    st.markdown("---")

    # --- Sugerencia con Gemini ---
    if GENAI_API_KEY:
        empty_cols = [col for col, value in direct_mappings.items() if not value]
        if empty_cols:
            if st.button("✨ Sugerir mapeo semántico con Gemini"):
                prompt = f"""
I have the following column names from a Scopus CSV export that currently have no semantic mapping:
{json.dumps(empty_cols, indent=2)}

Please suggest the most appropriate RDF properties for each column, using only the following vocabularies:
- schema.org (prefix: schema)
- BIBO ontology (prefix: bibo)

Return your answer strictly as a flat JSON object with the format:
{{
  "Column Name 1": "schema:propertyName",
  "Column Name 2": "bibo:propertyName"
}}

Constraints and guidelines:
- Only use properties from schema.org or bibo.
- Avoid inventing custom or undefined properties.
- The values must match real vocabulary terms (case-sensitive).
- Do not include explanations, markdown formatting, code fences, or natural language—only return a valid JSON object.
- The JSON must be parsable directly using Python\'s `json.loads()` function.
- If no suitable property exists, omit that column (do NOT return null, empty string, or unknown).

Your response should help enrich an RDF graph representation of academic articles.
"""

                with st.spinner("Consultando a Gemini..."):
                    model = genai.GenerativeModel(model_name="models/gemini-1.5-flash")
                    response = model.generate_content(prompt)

                    print("\\n--- Respuesta de Gemini ---")
                    print(response.text)
                    print("----------------------------------\\n")
        else:
            st.info("Todas las columnas ya tienen un mapeo o no hay columnas mapeables restantes.")

    # --- Botón para Convertir a RDF y Mostrar Grafo ---
    if st.button("🚀 Convertir a RDF y Mostrar Grafo", type="primary"):
        # --- IMPRIMIR EL user_mapping FINAL EN CONSOLA ---
        print("\\n--- user_mapping final enviado a convert_csv_to_ttl ---")
        print(json.dumps(user_mapping, indent=2))
        print("------------------------------------------------------\\n")
        
        with st.spinner("Generando RDF y grafo..."):
            # Llama a la función de conversión con el DataFrame y el mapeo de usuario
            ttl_data, g = convert_csv_to_ttl(df, user_mapping)
            st.success("🎉 ¡Conversión completada!")
            
            # Permite descargar el archivo TTL
            st.download_button("⬇️ Descargar archivo RDF (.ttl)", ttl_data, "scopus_data.ttl", "text/turtle")
            
            # Renderiza y muestra el grafo RDF interactivo
            html_path = render_rdf_graph(g)
            with open(html_path, 'r', encoding='utf-8') as f:
                st.components.v1.html(f.read(), height=600, scrolling=True)


