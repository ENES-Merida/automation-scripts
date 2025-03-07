%% Este script se utiliza para descargar datos de pronóstico histórico de www.hycom.org

%% Directorio de resultados
% --------------------------------------------------------
resultDirectory = fullfile(pwd, 'Data');  % Crea ruta a la carpeta Data
if ~exist(resultDirectory, 'dir')         % Verifica si el directorio existe
    mkdir(resultDirectory);                % Crea el directorio si no existe
end

%% Parámetros de entrada
% -------------------------------------------------------
%% Coordenadas de la región de interés
% Ubicación: Latitud 6° 20' S, Longitud: 11° 15' E
east = 11.30;    % Longitud este
west = 11.25;    % Longitud oeste
south = -6.33;   % Latitud sur
north = -6.31;   % Latitud norte

%% Rango de fechas
date_start = '01-Jan-1994 12:00:00';  % Fecha inicial
date_end = '31-Jan-1994 23:00:00';    % Fecha final

%% Conversión de fechas
% --------------------------------------------------------
startDate = datetime(date_start, 'InputFormat', 'dd-MMM-yyyy HH:mm:ss');  % Convertir a objeto datetime
endDate = datetime(date_end, 'InputFormat', 'dd-MMM-yyyy HH:mm:ss');      % Convertir a objeto datetime

fprintf('Descargando datos desde %s hasta %s\n',...
    datestr(startDate, 'yyyy-mm-ddTHH:MM:SSZ'),...  % Mostrar fecha formateada
    datestr(endDate, 'yyyy-mm-ddTHH:MM:SSZ'));      % Mostrar fecha formateada

%% Bucle principal de descargas
% --------------------------------------------------------
currentTime = startDate;  % Inicializar tiempo actual
while currentTime <= endDate  % Iterar mientras no se supere la fecha final
    error_flag = true;        % Bandera para reintentos
    
    %% Bucle de reintentos
    while error_flag
        %% Construcción de URL
        url = sprintf(['http://ncss.hycom.org/thredds/ncss/GLBv0.08/',...
            'expt_53.X/data/%04d?var=water_u&var=water_v&',...  % Año con 4 dígitos
            'north=%.2f&west=%.2f&east=%.2f&south=%.2f&',...    % Coordenadas
            'time=%s&accept=netcdf4'],...                       % Tiempo ISO8601
            year(currentTime), north, west, east, south,...      % Valores numéricos
            datestr(currentTime, 'yyyy-mm-ddTHH:MM:SSZ'));       % Formato de tiempo
        
        %% Configurar nombre de archivo
        fileName = [datestr(currentTime, 'yyyymmdd_HH'), '.nc'];  % Formato yyyymmdd_HH.nc
        outputFile = fullfile(resultDirectory, fileName);         % Ruta completa
        
        %% Intento de descarga
        try
            websave(outputFile, url);                             % Descargar archivo
            fprintf('Descarga exitosa: %s\n', fileName);          % Mensaje de éxito
            error_flag = false;                                   % Desactivar bandera de error
            
        catch ME  % Capturar cualquier error
            fprintf('Error: %s\n', ME.message);                   % Mostrar mensaje de error
            fprintf('Reintentando descarga: %s...\n', fileName);  % Mensaje de reintento
            pause(2);  % Pausa de 2 segundos antes de reintentar
        end
    end
    
    %% Avanzar tiempo
    currentTime = currentTime + hours(3);  % Incrementar 3 horas
end