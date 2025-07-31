import pandas as pd
from rdflib import Graph, Namespace, URIRef, Literal
from rdflib.namespace import RDF
import uuid
import re
import io
import networkx as nx
from pyvis.network import Network
import tempfile
import json

CONFIG_FILE = 'config.json'

def load_config():
    try:
        with open(CONFIG_FILE, 'r', encoding='utf-8') as f:
            return json.load(f)
    except FileNotFoundError:
        print(f"Error: El archivo de configuración '{CONFIG_FILE}' no se encontró.")
        return None

config = load_config()

# --- Namespaces y utilidades ---
NAMESPACES = {}
if config and 'namespaces' in config:
    for prefix, uri in config['namespaces'].items():
        NAMESPACES[prefix.upper()] = Namespace(uri)

ID_CANDIDATES = ["EID", "DOI", "Title"]

def get_available_properties():
    if config and 'available_properties' in config:
        return [""] + config['available_properties']
    return [""]

def convert_csv_to_ttl(df, user_selected_mappings):
    g = Graph()
    for prefix, ns_uri in NAMESPACES.items(): g.bind(prefix.lower(), ns_uri)
    id_col = next((c for c in ID_CANDIDATES if c in df.columns), df.columns[0])

    for _, row in df.iterrows():
        # --- Artículo ---
        if pd.isnull(row[id_col]): continue
        article_uri = NAMESPACES["UTI"][str(row[id_col]).replace("/", "_")]
        g.add((article_uri, RDF.type, NAMESPACES["SCHEMA"].ScholarlyArticle))

        # --- Autores ---
        names_col = user_selected_mappings.get('author_full_names_col')
        ids_col = user_selected_mappings.get('author_ids_col')

        if names_col and pd.notna(row.get(names_col)):
            names = str(row[names_col]).split(';')
            ids = str(row.get(ids_col, '')).split(';') if ids_col and pd.notna(row.get(ids_col)) else [str(uuid.uuid4()) for _ in names]
            for name, author_id in zip(names, ids):
                clean_name = re.sub(r'\s*\(.*?\)', '', name).strip()
                if not clean_name: continue
                author_uri = NAMESPACES["UTI"][author_id.strip()]
                g.add((author_uri, RDF.type, NAMESPACES["SCHEMA"].Person))
                g.add((author_uri, NAMESPACES["SCHEMA"].name, Literal(clean_name)))
                g.add((article_uri, NAMESPACES["SCHEMA"].author, author_uri))

        # --- Fuente de Publicación --- 
        source_title_col = user_selected_mappings.get('source_title_col')
        vol_col = user_selected_mappings.get('volume_col')
        iss_col = user_selected_mappings.get('issue_col')

        if source_title_col and pd.notna(row.get(source_title_col)):
            # Entidad para la edición de la revista
            issue_id = f"{row[source_title_col]}_{row.get(vol_col, '')}_{row.get(iss_col, '')}".replace(" ", "_")
            issue_uri = NAMESPACES["UTI"]["issue_" + issue_id]
            g.add((issue_uri, RDF.type, NAMESPACES["SCHEMA"].PublicationIssue))
            g.add((issue_uri, NAMESPACES["SCHEMA"].name, Literal(row[source_title_col])))
            if vol_col and pd.notna(row.get(vol_col)): g.add((issue_uri, NAMESPACES["BIBO"].volume, Literal(row[vol_col])))
            if iss_col and pd.notna(row.get(iss_col)): g.add((issue_uri, NAMESPACES["BIBO"].issue, Literal(row[iss_col])))
            g.add((article_uri, NAMESPACES["SCHEMA"].isPartOf, issue_uri)) # Conecta el artículo con la edición

        # --- Propiedades Generales ---
        for col, prop_str in user_selected_mappings['direct_mappings'].items():
            if prop_str and pd.notna(row.get(col)):
                prefix, name = prop_str.split(':', 1) 
                predicate = NAMESPACES[prefix.upper()][name]
                
                # Ver si la columna es una lista
                col_config = next((item for item in config['column_mappings'] if item['csv_column'] == col), None)
                
                if col_config and col_config.get('is_list', False):
                    delimiter = col_config.get('delimiter', ';')
                    items = str(row[col]).split(delimiter)
                    for item in items:
                        if item.strip(): g.add((article_uri, predicate, Literal(item.strip())))
                else:
                    g.add((article_uri, predicate, Literal(row[col])))

    ttl_output = io.BytesIO()
    g.serialize(destination=ttl_output, format="turtle")
    ttl_output.seek(0)
    return ttl_output, g
    
def render_rdf_graph(grafo_rdflib):
    G = nx.MultiDiGraph()

    for s, p, o in grafo_rdflib:
        s_str = str(s)
        p_str = str(p).split('/')[-1].split('#')[-1]
        o_str = str(o)
        
        G.add_node(s_str, title=s_str)
        G.add_node(o_str, title=o_str)
        G.add_edge(s_str, o_str, label=p_str, title=p_str)

    # Configurar la visualización
    net = Network(height="600px", width="100%", bgcolor="#ffffff", font_color="black", directed=True)
    net.from_nx(G)
    
    # Aplicar físicas para una mejor visualización
    net.repulsion(node_distance=250, central_gravity=0.1, spring_length=200)

    # Guardar el grafo en un archivo HTML temporal
    with tempfile.NamedTemporaryFile(delete=False, suffix=".html", mode='w', encoding='utf-8') as tmp_file:
        net.write_html(tmp_file.name)
        return tmp_file.name


