%% Script para descargar datos históricos de www.hycom.org
% Configuración inicial
clc; clear; close all;

%% Directorio de resultados
% --------------------------------------------------------
resultDirectory = fullfile(pwd, 'Data');  % Crear ruta relativa
if ~exist(resultDirectory, 'dir')         % Verificar si existe
    mkdir(resultDirectory);               % Crear directorio si no existe
end

%% Parámetros de entrada
% --------------------------------------------------------
east = 11.30;    % Longitud este
west = 11.25;    % Longitud oeste
south = -6.33;   % Latitud sur
north = -6.31;   % Latitud norte

%% Configuración de fechas
% --------------------------------------------------------
date_start = '01-Jan-1994 12:00:00';
date_end = '31-Jan-1994 23:00:00';

% Convertir fechas usando formato inglés para evitar problemas de localización
try
    startDate = datetime(date_start, 'InputFormat', 'dd-MMM-yyyy HH:mm:ss', 'Locale', 'en_US');
    endDate = datetime(date_end, 'InputFormat', 'dd-MMM-yyyy HH:mm:ss', 'Locale', 'en_US');
catch
    error('Formato de fecha inválido. Usar formato ''01-Jan-1994 12:00:00''');
end

%% Validación de fechas
% --------------------------------------------------------
if isempty(startDate) || isempty(endDate)
    error('Fechas inválidas. Verificar formato');
end

fprintf('Descargando datos desde %s hasta %s\n\n',...
    datestr(startDate, 'yyyy-mm-ddTHH:MM:SSZ'),...
    datestr(endDate, 'yyyy-mm-ddTHH:MM:SSZ'));

%% Bucle principal de descargas
% --------------------------------------------------------
currentTime = startDate;  % Inicializar tiempo actual
while currentTime <= endDate
    error_flag = true;    % Bandera de reintentos
    
    % Bucle de reintentos para cada archivo
    while error_flag
        %% Construir URL
        url = sprintf(['http://ncss.hycom.org/thredds/ncss/GLBv0.08/'...
            'expt_53.X/data/%04d?var=water_u&var=water_v&'...         % Año
            'north=%.2f&west=%.2f&east=%.2f&south=%.2f&'...          % Coordenadas
            'time=%s&accept=netcdf4'],...                             % Tiempo
            year(currentTime), north, west, east, south,...
            datestr(currentTime, 'yyyy-mm-ddTHH:MM:SSZ'));
        
        %% Configurar nombre de archivo
        fileName = [datestr(currentTime, 'yyyymmdd_HH') '.nc'];
        outputFile = fullfile(resultDirectory, fileName);
        
        %% Intento de descarga
        try
            websave(outputFile, url);  % Descargar archivo
            fprintf('Descarga exitosa: %s\n', fileName);
            error_flag = false;  % Éxito - salir del bucle
            
        catch ME  % Manejo de errores
            fprintf(2, 'Error: %s\n', ME.message);
            fprintf('Reintentando en 5 segundos...\n');
            pause(5);  % Pausa antes de reintentar
        end
    end
    
    %% Avanzar al siguiente intervalo temporal
    currentTime = currentTime + hours(3);  % Incrementar 3 horas
end

fprintf('\nDescarga completada!\n');