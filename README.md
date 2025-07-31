# Conversor de Scopus CSV a RDF

## 🎯 Propósito del Proyecto

Este proyecto tiene como objetivo principal facilitar la transformación de datos bibliográficos estructurados en formato CSV (específicamente exportaciones de Scopus) a un grafo de conocimiento en formato RDF (Resource Description Framework). La meta es permitir una representación semántica de la información académica, mejorando la interoperabilidad y la capacidad de análisis de los datos mediante estándares de la Web Semántica. El diseño prioriza la flexibilidad y la adaptabilidad a posibles variaciones en la estructura de los archivos CSV de origen.

## 🧩 Componentes Principales

La solución está modularizada en los siguientes componentes clave:

*   **`app.py` (Interfaz de Usuario y Orquestación):** Desarrollado con Streamlit, proporciona una interfaz gráfica intuitiva para la carga de archivos CSV, la visualización de columnas, la configuración interactiva de mapeos semánticos y la visualización del grafo RDF resultante. Incluye integración con la API de Google Gemini para la sugerencia inteligente de propiedades RDF.

*   **`converter.py` (Lógica de Conversión):** Contiene el motor principal para la transformación de datos. Se encarga de leer la configuración de mapeo, iterar sobre el DataFrame de entrada, construir el grafo RDF utilizando la librería `RDFlib`, y serializar el grafo a formato Turtle (`.ttl`). Su diseño es agnóstico a la estructura del CSV, basándose completamente en la configuración externa.

*   **`config.json` (Archivo de Configuración):** Un archivo JSON que centraliza la definición de los mapeos entre las columnas del CSV y las propiedades RDF. Permite especificar `namespaces`, mapeos por defecto, y reglas para el manejo de tipos de datos y listas. Este archivo es fundamental para la flexibilidad del sistema, permitiendo adaptar el conversor a nuevas estructuras de CSV sin modificar el código fuente.

---

# 🧠 EduMind RDF Visualizer

Una aplicación Flutter para la exploración visual e interactiva de recursos históricos relacionados con el Ecuador, obtenidos desde bases de conocimiento abiertas como **DBpedia** y **Wikidata** mediante consultas SPARQL.

Este proyecto busca facilitar la consulta, exploración y visualización semántica de datos enlazados (Linked Data) orientados a la educación y el patrimonio cultural. Está diseñado como una herramienta educativa para que estudiantes, docentes e investigadores puedan acceder a información estructurada a través de interfaces amigables.

## 🧩 Componentes principales

### 1. 🧠 RDF Providers

*   **DBPediaProvider**: Ejecuta consultas SPARQL sobre eventos históricos y lugares del Ecuador desde DBpedia.
*   **WikidataProvider**: Ejecuta consultas SPARQL sobre personajes e instituciones históricas de Ecuador desde Wikidata.
*   Ambos exponen funciones asincrónicas que devuelven modelos de recursos para ser renderizados por la aplicación.

### 2. 📦 Conversor CSV → RDF (TTL)

*   Utilidad incluida para transformar archivos CSV en grafos RDF utilizando vocabularios personalizados.
*   Convierte datos estructurados en tripletas compatibles con estándares semánticos (TTL).

### 3. 📱 Interfaz Flutter

*   **Vista de categorías**: Muestra listas de recursos clasificados (Eventos, Lugares, Personajes, Instituciones).
*   **Vista de recurso**:
    *   Detalle textual (lista de propiedades).
    *   Visualización como grafo (interactivo con GraphView).
    *   Conmutación de vistas mediante `Switch`.

### 4. 🧭 Navegación

*   Gestión de rutas con GetX (`AppRoutes`) para mantener una navegación clara entre pantallas.
*   Cada recurso seleccionado lleva a una vista enriquecida del mismo con sus relaciones y atributos.

## 📂 Estructura básica del proyecto

```text
lib/
│
├── data/
│   ├── models/             
│   ├── providers/          
│
├── presentation/
│   ├── modules/
│   │   ├── category/        
│   │   ├── resource/        
│   │   └── graph/           
│
├── routes/                  
├── utils/                   
```

## 🛠️ Tecnologías usadas

*   **Flutter + GetX**: Framework principal para frontend multiplataforma.
*   **SPARQL**: Lenguaje de consultas sobre grafos RDF.
*   **DBpedia / Wikidata**: Endpoints SPARQL públicos para obtener datos abiertos.
*   **GraphView**: Visualización de relaciones semánticas como grafos.
*   **Dart HTTP**: Para consultas asincrónicas a endpoints SPARQL.

## 📌 Consideraciones

*   Los resultados pueden variar según la disponibilidad y estabilidad de los endpoints SPARQL públicos.
*   Se puede extender fácilmente para nuevas categorías u otras fuentes RDF.


