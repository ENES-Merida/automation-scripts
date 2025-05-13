#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Script para descargar datos de corrientes (u,v) del servidor de HYCOM (http://ncss.hycom.org/).
Este script replica la lógica del ejemplo en PowerShell, pero en Python. 
Además, emplea paralelización para acelerar las descargas.

Requisitos:
- requests (pip install requests)
- python-dateutil (pip install python-dateutil) para manejar fechas fácilmente.

Funcionamiento:
1. Define la región de interés (oeste, este, sur, norte).
2. Define el rango de fechas de inicio y fin.
3. Genera una lista de tiempos cada 3 horas dentro del rango.
4. Para cada instante de tiempo, construye la URL de descarga.
5. Descarga el archivo .nc correspondiente, guardándolo en la carpeta "Data".
6. Maneja errores de descarga con reintentos.
7. Opcionalmente, utiliza concurrencia (threads) para descargar múltiples archivos en paralelo.
"""
import os
import requests
import time
from datetime import datetime, timedelta
from dateutil import parser
from concurrent.futures import ThreadPoolExecutor, as_completed

# -----------------------------------------------------------------------------
# Parámetros de entrada
# -----------------------------------------------------------------------------

# Coordenadas

west  = float(input("Longitud oeste (west): "))
east  = float(input("Longitud este  (east): "))
south = float(input("Latitud sur   (south): "))
north = float(input("Latitud norte (north): "))


# Fechas de inicio y fin (en formato 'dd-MMM-yyyy HH:mm:ss')
print("Ejemplo: 01-Jan-1994 12:00:00")
date_start= input("Fecha y hora (dd-MMM-yyyy HH:mm:ss): ")
time_point = parser.parse(date_start)

print("Ejemplo:31-Jan-1994 23:00:00 ")
date_end= input("Fecha y hora (dd-MMM-yyyy HH:mm:ss): ")
time_point = parser.parse(date_end)
# Fechas de inicio y fin (en formato 'dd-MMM-yyyy HH:mm:ss')


# Cantidad de horas entre cada descarga
time_step_hours = 3

# Directorio de salida
result_directory = os.path.join(os.getcwd(), "Data")

# Número de hilos (para descargas concurrentes). 
# Ajusta según tu conexión o CPU. 
# Si el servidor bloquea demasiadas conexiones simultáneas, reduce este valor.
MAX_WORKERS = 5

# -----------------------------------------------------------------------------
# Funciones auxiliares
# -----------------------------------------------------------------------------
def ensure_directory_exists(directory_path):
    """
    Crea la carpeta de salida si no existe.
    
    :param directory_path: Ruta de la carpeta a verificar o crear.
    """
    if not os.path.exists(directory_path):
        os.makedirs(directory_path)
        print(f"Carpeta creada: {directory_path}")

def parse_datetime(date_str):
    """
    Convierte una cadena con formato 'dd-MMM-yyyy HH:mm:ss' en objeto datetime.
    
    :param date_str: Cadena de fecha/hora (por ejemplo, '01-Jan-1994 12:00:00').
    :return: Objeto datetime correspondiente.
    """
    # Con dateutil, podemos parsear diferentes formatos fácilmente.
    # Sin embargo, si quisieras forzar el formato exacto: 
    #   dt = datetime.strptime(date_str, '%d-%b-%Y %H:%M:%S')
    # Aquí simplemente dejamos que dateutil lo maneje:
    dt = parser.parse(date_str)
    return dt

def build_download_url(time_point, west, east, south, north):
    """
    Construye la URL para descargar el archivo netCDF a partir de la fecha y los límites geográficos.
    
    :param time_point: Objeto datetime que representa la fecha/hora.
    :param west, east, south, north: Límites geográficos de la zona de interés.
    :return: Cadena con la URL completa para la descarga.
    """
    base_url = "http://ncss.hycom.org/thredds/ncss/GLBv0.08/expt_53.X/data"
  
    
    year_str = time_point.strftime('%Y')
    time_str = time_point.strftime('%Y-%m-%dT%H:%M:%SZ')
    
    url = (
        f"{base_url}/{year_str}"
        f"?var=water_u&var=water_v"
        f"&north={north}"
        f"&west={west}"
        f"&east={east}"
        f"&south={south}"
        f"&time={time_str}"
        f"&accept=netcdf4"
    )
    
    return url

def download_file(url, output_path, max_retries=5, wait_seconds=5, min_bytes=1024):
    attempt = 0
    while attempt < max_retries:
        try:
            r = requests.get(url, timeout=30)
            r.raise_for_status()
            with open(output_path, "wb") as f:
                f.write(r.content)

            # --- VALIDACIÓN BÁSICA ---
            if os.path.getsize(output_path) < min_bytes:
                raise ValueError("archivo demasiado pequeño — posible error del servidor")

            print(f"[OK] {os.path.basename(output_path)} descargado.")
            return
        except Exception as e:
            attempt += 1
            print(f"[ERROR] Intento {attempt}/{max_retries} fallido: {e}")
            if attempt < max_retries:
                time.sleep(wait_seconds)

    # Tras agotar reintentos, forzar fallo real
    raise RuntimeError(f"No se pudo descargar {os.path.basename(output_path)}")

# -----------------------------------------------------------------------------
# Función principal
# -----------------------------------------------------------------------------
import time

def main():
    """
    Función principal que:
    1. Convierte las fechas de inicio y fin en objetos datetime.
    2. Genera una lista de instantes de tiempo (cada 3 horas) entre las dos fechas.
    3. Construye la URL y el nombre de archivo para cada instante.
    4. Descarga todos los archivos en paralelo usando hilos (ThreadPoolExecutor).
    5. Muestra un resumen final con archivos descargados exitosamente y fallidos.
    6. Muestra el tiempo total de ejecución.
    """

    start_time = time.time()  # Iniciar temporizador

    # Aseguramos que exista el directorio de salida
    ensure_directory_exists(result_directory)

    # Convertimos las cadenas de fecha a objetos datetime
    start_date = parse_datetime(date_start)
    end_date = parse_datetime(date_end)

    # Mostramos el rango de fechas
    print(f"Descargando datos desde {start_date.strftime('%Y-%m-%dT%H:%M:%SZ')} "
          f"hasta {end_date.strftime('%Y-%m-%dT%H:%M:%SZ')} ...")

    # Generamos la lista de instantes de tiempo cada 3 horas
    time_points = []
    current_time = start_date
    while current_time <= end_date:
        time_points.append(current_time)
        current_time += timedelta(hours=time_step_hours)

     # —– descarga secuencial, bloqueante hasta el éxito —–
    successful_downloads = []
    failed_downloads = []  # opcional, para registro si quieres

    for t_point in time_points:
        url = build_download_url(t_point, west, east, south, north)
        filename = t_point.strftime('%Y%m%d_%H') + ".nc"
        output_path = os.path.join(result_directory, filename)

        while True:
            try:
                download_file(url, output_path,
                              max_retries=1,   # Internamente sólo 1 intento por llamada
                              wait_seconds=0,  # sin espera (no hace falta)
                              min_bytes=1024)
                successful_downloads.append(filename)
                break  # ¡ya descargó con éxito, sal del while y continúa al siguiente!
            except Exception as e:
                # Aquí podrás ver el error y volver a intentarlo *infinitamente*
                print(f"[REINTENTO INFINITO] Error al bajar {filename}: {e}")
                # no hay sleep, o bien:
                time.sleep(5)  # si prefieres esperar un poco entre reintentos

    # … luego imprimir tu resumen basado en `successful_downloads` (y `failed_downloads` si los guardas)


    end_time = time.time()  # Detener temporizador
    total_time = end_time - start_time  # Calcular tiempo total en segundos

    # Convertir segundos a minutos y segundos
    minutes = int(total_time // 60)
    seconds = int(total_time % 60)

    # Resumen final
    print("\n===== RESUMEN DE DESCARGA =====")
    print(f"Total de archivos intentados: {len(time_points)}")
    print(f"Descargas exitosas: {len(successful_downloads)}")
    print(f"Descargas fallidas: {len(failed_downloads)}")

    if failed_downloads:
        print("\nLos siguientes archivos no se pudieron descargar:")
        for file in failed_downloads:
            print(f"- {file}")

    print(f"\nTiempo total de ejecución: {minutes} minutos y {seconds} segundos.")
    print("Proceso de descarga finalizado.")



# -----------------------------------------------------------------------------
# Ejecución del script
# -----------------------------------------------------------------------------
if __name__ == "__main__":
    main()