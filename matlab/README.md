# Descargador de Datos Históricos de HYCOM

Este script en MATLAB permite descargar datos históricos de pronóstico oceánico desde el servidor de [HYCOM](http://www.hycom.org). Los datos descargados son en formato NetCDF y contienen información sobre las corrientes oceánicas (componentes `water_u` y `water_v`) para una región y período de tiempo específicos.

---

## Requisitos

1. **MATLAB** (versión R2016b o superior)
   - Toolboxes requeridos:
     - Ninguno adicional (funciona con MATLAB base)
2. **Conexión a Internet** (para descargar los datos)
3. **Permisos de escritura** en el directorio donde se ejecute el script

---

## Cómo Usar

1. **Ejecutar el script**:
   - Abre MATLAB y navega al directorio donde guardaste el script.
   - Ejecuta el script con el comando:
     ```matlab
     descarga_hycom
     ```

2. **Ingresar parámetros**:
   - Aparecerá un cuadro de diálogo donde debes ingresar:
     - **Coordenadas geográficas**:
       - Longitud Este (0-360°E)
       - Longitud Oeste (0-360°E)
       - Latitud Sur (-80 a 80°N)
       - Latitud Norte (-80 a 80°N)
     - **Rango temporal**:
       - Fecha inicial (formato: `dd-MMM-yyyy HH:mm:ss`, ej: `01-Jan-1994 12:00:00`)
       - Fecha final (mismo formato)
       - Intervalo temporal en horas (ej: `3` para datos cada 3 horas)

3. **Esperar a que finalice**:
   - El script descargará los archivos automáticamente y mostrará el progreso en la consola.

---

## Salida (Output)

### Archivos Descargados
- Los archivos se guardan en la carpeta `Data` dentro del directorio donde se ejecuta el script.
- Cada archivo tiene el formato: `AAAAMMDD_HH.nc`, donde:
  - `AAAA`: Año (4 dígitos)
  - `MM`: Mes (2 dígitos)
  - `DD`: Día (2 dígitos)
  - `HH`: Hora (2 dígitos, formato 24 horas)


### Ejemplo de Nombre de Archivo
- `19940101_12.nc`: Datos del 1 de enero de 1994 a las 12:00 UTC.

---

## Ejemplo de Uso

### Parámetros de Entrada:
- Longitud Este: `11.30`
- Longitud Oeste: `11.25`
- Latitud Sur: `-6.33`
- Latitud Norte: `-6.31`
- Fecha inicial: `01-Jan-1994 12:00:00`
- Fecha final: `31-Jan-1994 23:00:00`
- Intervalo temporal: `3` horas

### Resultado:
- Se descargarán archivos cada 3 horas entre las fechas especificadas.
- Los archivos se guardarán en la carpeta `Data` con nombres como `19940101_12.nc`, `19940101_15.nc`, etc.

---

## Notas Adicionales

- **Rangos Geográficos**:
  - Longitudes deben estar entre 0 y 360°E.
  - Latitudes deben estar entre -80 y 80°N.

- **Formato de Fechas**:
  - Usar el formato exacto: `dd-MMM-yyyy HH:mm:ss` (ej: `15-Aug-2024 00:00:00`).

- **Reintentos Automáticos**:
  - Si falla una descarga, el script reintentará automáticamente después de 5 segundos.