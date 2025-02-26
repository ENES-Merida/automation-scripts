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
east = 11.30
west = 11.25
south = -6.33
north = -6.31

# Fechas de inicio y fin (en formato 'dd-MMM-yyyy HH:mm:ss')
date_start = '01-Jan-1994 12:00:00'
date_end   = '31-Jan-1994 23:00:00'

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

def download_file(url, output_path, max_retries=5, wait_seconds=5):
    """
    Descarga un archivo desde la URL especificada y lo guarda en output_path.
    Si falla, reintenta hasta max_retries veces.
    
    :param url: URL de descarga.
    :param output_path: Ruta de destino donde se guardará el archivo descargado.
    :param max_retries: Número máximo de reintentos en caso de error.
    :param wait_seconds: Tiempo de espera (en segundos) antes de cada reintento.
    """
    attempt = 0
    while attempt < max_retries:
        try:
            response = requests.get(url, timeout=30)  # Ajusta el timeout según sea necesario
            response.raise_for_status()  # Lanza excepción si hay un error HTTP
            with open(output_path, 'wb') as f:
                f.write(response.content)
            print(f"[OK] {os.path.basename(output_path)} descargado.")
            return  # Éxito, salimos de la función
        except Exception as e:
            attempt += 1
            print(f"[ERROR] Intento {attempt}/{max_retries} fallido: {e}")
            if attempt < max_retries:
                print(f"Reintentando en {wait_seconds} segundos...")
                time.sleep(wait_seconds)
    # Si llega aquí, no se pudo descargar tras varios reintentos
    print(f"[FATAL] No se pudo descargar {os.path.basename(output_path)} después de {max_retries} reintentos.")

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

    successful_downloads = []
    failed_downloads = []

    # Preparamos las descargas en paralelo
    with ThreadPoolExecutor(max_workers=MAX_WORKERS) as executor:
        future_to_time = {}

        # Se programa cada descarga
        for t_point in time_points:
            url = build_download_url(t_point, west, east, south, north)
            filename = t_point.strftime('%Y%m%d_%H') + ".nc"
            output_path = os.path.join(result_directory, filename)

            # Asignamos la tarea (future) para descargar
            future = executor.submit(download_file, url, output_path)
            future_to_time[future] = filename

        # Esperamos a que terminen todas las descargas
        for future in as_completed(future_to_time):
            file_name = future_to_time[future]
            try:
                future.result()  # Si hay excepción dentro de download_file, se lanzará aquí
                successful_downloads.append(file_name)
            except Exception as e:
                failed_downloads.append(file_name)
                print(f"[ERROR] Ocurrió un problema con el archivo {file_name}: {e}")

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
