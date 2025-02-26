# 📥 Scraper de Datos de Corrientes HYCOM

Este script en Python permite la descarga automatizada de datos de corrientes oceánicas (u, v) desde el servidor de **HYCOM** (http://ncss.hycom.org/). Implementa concurrencia para acelerar las descargas y maneja reintentos en caso de fallos.

## 🏷️ Versiones

### 🔹 **HYCOM Scraper v1**
- Descarga datos de corrientes oceánicas (u, v) en formato `.nc`.
- Permite definir una región geográfica de interés mediante coordenadas.
- Descarga datos cada 3 horas dentro de un rango de fechas especificado en el código.
- Maneja errores y reintentos automáticos en caso de fallos.
- Utiliza **descargas en paralelo** para mayor eficiencia.
  
### 🔹 **HYCOM Scraper v2 (Mejorado)**
- **Solicita la información al usuario antes de ejecutar la descarga**, incluyendo:
  - Coordenadas geográficas (norte, sur, este, oeste).
  - Fechas de inicio y fin en formato `dd-MMM-yyyy HH:mm:ss`.
  - Intervalo de tiempo entre descargas (en horas).
- Mantiene todas las características de la **versión 1**, pero con mayor flexibilidad.
- Carpeta de salida automática (`Data/`).
- Implementa reintentos automáticos y descargas concurrentes con **multithreading**.

---

## 🛠️ Requisitos

### 🔹 Versión de Python
El script requiere **Python 3.8 o superior**. Puedes verificar tu versión ejecutando:

```bash
python --version
```

### 🔹 Instalación de dependencias
Antes de ejecutar el script, asegúrate de instalar las siguientes librerías:

```bash
pip install requests python-dateutil
```

---

## 📌 Uso

Ejecuta el script y sigue las instrucciones en pantalla para ingresar los parámetros de descarga:

```bash
python scraper_hycom.py
```

Dependiendo de la versión que utilices:

### 🔹 **Para v1:**
- Debes modificar los parámetros dentro del código antes de ejecutarlo.

### 🔹 **Para v2:**
- El script te pedirá ingresar **coordenadas**, **fechas**, y **intervalo de descarga** de manera interactiva.

---

## 📂 Salida

Los archivos descargados se guardarán en la carpeta **`Data/`**, con nombres en el formato:

```
YYYYMMDD_HH.nc  (Ejemplo: 19940101_12.nc)
```

---

## ⚠️ Notas
- La velocidad de descarga depende de la conexión a internet y la capacidad del servidor HYCOM.
- Si muchas descargas fallan, intenta reducir el número de hilos (`MAX_WORKERS`) en el código.
- Asegúrate de ingresar fechas válidas para evitar errores en la ejecución.

---
