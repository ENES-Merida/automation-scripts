%% Script para descargar datos históricos de www.hycom.org
% Configuración inicial
clc; clear; close all;

%% Solicitar parámetros al usuario
% --------------------------------------------------------
% Crear cuadro de diálogo para entrada de datos
prompt = {
    'Longitud Este (0-360 degE):', 
    'Longitud Oeste (0-360 degE):',
    'Latitud Sur (-80 a 80 degN):',
    'Latitud Norte (-80 a 80 degN):',
    'Fecha inicial (dd-MMM-yyyy HH:mm:ss):',
    'Fecha final (dd-MMM-yyyy HH:mm:ss):',
    'Intervalo temporal (horas):'
};
dlgtitle = 'Parámetros de entrada';
dims = [1 50];
definput = {
    '11.30', '11.25', '-6.33', '-6.31',...
    '01-Jan-1994 12:00:00', '31-Jan-1994 23:00:00', '3'
};

% Obtener valores del usuario
answer = inputdlg(prompt, dlgtitle, dims, definput);

% Validar que se ingresaron todos los parámetros
if isempty(answer)
    error('Entrada cancelada por el usuario');
end

%% Procesar parámetros ingresados
% --------------------------------------------------------
% Convertir coordenadas a números
try
    east = str2double(answer{1});
    west = str2double(answer{2});
    south = str2double(answer{3});
    north = str2double(answer{4});
    
    % Validar coordenadas numéricas
    if any(isnan([east, west, south, north]))
        error('Valores geográficos inválidos');
    end
    
    % Validar rangos geográficos
    if west < 0 || west > 360
        error('Longitud Oeste fuera de rango. Valores admitidos: 0 a 360 degE');
    end
    if east < 0 || east > 360
        error('Longitud Este fuera de rango. Valores admitidos: 0 a 360 degE');
    end
    if south < -80 || south > 80
        error('Latitud Sur fuera de rango. Valores admitidos: -80 a 80 degN');
    end
    if north < -80 || north > 80
        error('Latitud Norte fuera de rango. Valores admitidos: -80 a 80 degN');
    end
    
catch
    error('Error en formato de coordenadas. Usar números decimales');
end

% Procesar fechas
try
    startDate = datetime(answer{5}, 'InputFormat', 'dd-MMM-yyyy HH:mm:ss', 'Locale', 'en_US');
    endDate = datetime(answer{6}, 'InputFormat', 'dd-MMM-yyyy HH:mm:ss', 'Locale', 'en_US');
    
    % Validar intervalo temporal
    timeStep = str2double(answer{7});
    if isnan(timeStep) || timeStep <= 0
        error('Intervalo temporal inválido');
    end
catch ME
    error(['Error en formato de fecha: ' ME.message]);
end

%% Configurar directorio de resultados
% --------------------------------------------------------
resultDirectory = fullfile(pwd, 'Data');
if ~exist(resultDirectory, 'dir')
    mkdir(resultDirectory);
end

%% Mostrar resumen de parámetros
% --------------------------------------------------------
fprintf('\n=== Parámetros de descarga ===\n');
fprintf('Región geográfica:\n');
fprintf(' Este: %.2f°E\n Oeste: %.2f°E\n Sur: %.2f°N\n Norte: %.2f°N\n', east, west, south, north);
fprintf('\nRango temporal:\n');
fprintf(' Inicio: %s\n Fin: %s\n Intervalo: %d horas\n',...
    datestr(startDate, 'dd-mmm-yyyy HH:MM'),...
    datestr(endDate, 'dd-mmm-yyyy HH:MM'),...
    timeStep);
fprintf('\nDirectorio de salida: %s\n\n', resultDirectory);

%% Bucle principal de descargas
% --------------------------------------------------------
currentTime = startDate;
while currentTime <= endDate
    error_flag = true;
    
    while error_flag
        try
            %% Construir URL
            url = sprintf(['http://ncss.hycom.org/thredds/ncss/GLBv0.08/'...
                'expt_53.X/data/%04d?var=water_u&var=water_v&'...
                'north=%.2f&west=%.2f&east=%.2f&south=%.2f&'...
                'time=%s&accept=netcdf4'],...
                year(currentTime), north, west, east, south,...
                datestr(currentTime, 'yyyy-mm-ddTHH:MM:SSZ'));
            
            %% Configurar nombre de archivo
            fileName = [datestr(currentTime, 'yyyymmdd_HH') '.nc'];
            outputFile = fullfile(resultDirectory, fileName);
            
            %% Descargar archivo
            websave(outputFile, url);
            fprintf('Descarga exitosa: %s\n', fileName);
            error_flag = false;
            
        catch ME
            fprintf(2, 'Error en descarga: %s\n', ME.message);
            fprintf('Reintentando en 5 segundos...\n');
            pause(5);
        end
    end
    
    %% Avanzar al siguiente intervalo
    currentTime = currentTime + hours(timeStep);
end

fprintf('\n=== Descarga completada ===\n');