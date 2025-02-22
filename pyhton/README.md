# 📥 Scraper de Datos de Corrientes HYCOM

Este script en Python descarga datos de corrientes oceánicas (u, v) desde el servidor de HYCOM. Utiliza concurrencia para acelerar las descargas y maneja reintentos en caso de fallos.

## 📌 Características

- Descarga datos de corrientes oceánicas (u, v) en formato `.nc`.
- Permite definir una región geográfica de interés mediante coordenadas.
- Descarga datos dentro de un rango de fechas especificado.
- Maneja errores y reintentos automáticos en caso de fallos.
- Utiliza **descargas en paralelo** para mayor eficiencia.

---

## 🛠️ Requisitos

### 🔹 Versión de Python
El script requiere **Python 3.8 o superior**. Puedes verificar tu versión ejecutando:

```bash
python --version
