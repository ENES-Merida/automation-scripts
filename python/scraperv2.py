import os
import requests
import time
from datetime import datetime, timedelta
from dateutil import parser
from concurrent.futures import ThreadPoolExecutor, as_completed

def get_user_input():
    """
    Solicita al usuario ingresar los parámetros necesarios para la descarga.
    """
    east = float(input("Ingrese la coordenada este: "))
    west = float(input("Ingrese la coordenada oeste: "))
    south = float(input("Ingrese la coordenada sur: "))
    north = float(input("Ingrese la coordenada norte: "))
    date_start = input("Ingrese la fecha de inicio (dd-MMM-yyyy HH:mm:ss): ")
    date_end = input("Ingrese la fecha de fin (dd-MMM-yyyy HH:mm:ss): ")
    time_step_hours = int(input("Ingrese la cantidad de horas entre cada descarga: "))
    return east, west, south, north, date_start, date_end, time_step_hours

def ensure_directory_exists(directory_path):
    if not os.path.exists(directory_path):
        os.makedirs(directory_path)
        print(f"Carpeta creada: {directory_path}")

def parse_datetime(date_str):
    return parser.parse(date_str)

def build_download_url(time_point, west, east, south, north):
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
    attempt = 0
    while attempt < max_retries:
        try:
            response = requests.get(url, timeout=30)
            response.raise_for_status()
            with open(output_path, 'wb') as f:
                f.write(response.content)
            print(f"[OK] {os.path.basename(output_path)} descargado.")
            return
        except Exception as e:
            attempt += 1
            print(f"[ERROR] Intento {attempt}/{max_retries} fallido: {e}")
            if attempt < max_retries:
                print(f"Reintentando en {wait_seconds} segundos...")
                time.sleep(wait_seconds)
    print(f"[FATAL] No se pudo descargar {os.path.basename(output_path)} después de {max_retries} reintentos.")

def main():
    east, west, south, north, date_start, date_end, time_step_hours = get_user_input()
    result_directory = os.path.join(os.getcwd(), "Data")
    MAX_WORKERS = 5
    
    start_time = time.time()
    ensure_directory_exists(result_directory)
    start_date = parse_datetime(date_start)
    end_date = parse_datetime(date_end)
    
    print(f"Descargando datos desde {start_date.strftime('%Y-%m-%dT%H:%M:%SZ')} "
          f"hasta {end_date.strftime('%Y-%m-%dT%H:%M:%SZ')} ...")
    
    time_points = []
    current_time = start_date
    while current_time <= end_date:
        time_points.append(current_time)
        current_time += timedelta(hours=time_step_hours)
    
    successful_downloads = []
    failed_downloads = []
    
    with ThreadPoolExecutor(max_workers=MAX_WORKERS) as executor:
        future_to_time = {}
        
        for t_point in time_points:
            url = build_download_url(t_point, west, east, south, north)
            filename = t_point.strftime('%Y%m%d_%H') + ".nc"
            output_path = os.path.join(result_directory, filename)
            future = executor.submit(download_file, url, output_path)
            future_to_time[future] = filename
        
        for future in as_completed(future_to_time):
            file_name = future_to_time[future]
            try:
                future.result()
                successful_downloads.append(file_name)
            except Exception as e:
                failed_downloads.append(file_name)
                print(f"[ERROR] Ocurrió un problema con el archivo {file_name}: {e}")
    
    end_time = time.time()
    total_time = end_time - start_time
    minutes = int(total_time // 60)
    seconds = int(total_time % 60)
    
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

if __name__ == "__main__":
    main()
