%OpenDap download and processing rev5b

% REV1. Se crea el script 
% este script extrae salidas de simulaciones del modelo HYCOM
% puestas disponibles al público por el HYCOM Consortium en un cliente OPENDAP.
%Se genera matriz de vector tiempo y matrices multidimensionales que
%despues se guardan

        %OPeNDAP is an acronym for "Open-source Project for a Network Data 
        %Access Protocol," an endeavor focused on enhancing the retrieval 
        %of remote, structured data through a Web-based architecture and 
        %a discipline-neutral Data Access Protocol (DAP). 
        %Widely used, especially in Earth science, the protocol is layered on HTTP,
        %and its current specification is DAP4,
        %though the previous DAP2 version remains broadly used. 

        %pendientes: la opcion "websave" que estoy utilizando me esta generando
        %muchos errores al descagargas los archivos... mejor utilizar "webwrite"?

% ___________________________________________________________


%REV2.- SE HACEN MEJORAS VARIAS.
%se procesa un archivo mensual individual y se genera matriz
%multidimensional
%lista de opciones terminadas y que pueden descargarse:
        %2.- %HYCOM + NCODA Gulf of Mexico 1/25° Analysis (GOMl0.04/expt_31.0) 
        %PERIODO: 2009-04-01 to 2014-07-31
        %3.- HYCOM + NCODA Gulf of Mexico 1/25° Analysis (GOMl0.04/expt_32.5)
        %PERIODO: 2014-04-01 to 2019-02-03
        
% ___________________________________________________________


%REV3.- SE HACEN MEJORAS VARIAS Y SE AGREGA ESTE PRODUCTO:
        %4.- HYCOM + NCODA Gulf of Mexico 1/25° Analysis (GOMu0.04/expt_90.1m000)
        % Resolution:	1/25° (0.04)
        % Institution:	Naval Research Laboratory
        % Date/Data Range:	2019-01-01 to Present + FORECASTS

        
        %FUTURAS MEJORAS:
        %ACTUALMENTE SE DESCARGAN DE MANERA "FIJA" SALIDAS A UNA FRECUENCIA
        %HORARIA, CON EL SIGUIENTE FORMATO EN LA SOLICITUD PARA EL SERVIDOR:

        %https://tds.hycom.org/thredds/dodsC/GOMu0.04/expt_90.1m000.ascii?depth%5B0:2%5D,lat%5B0:345%5D,lon%5B0:540%5D,time%5B12:20%5D,tau%5B12:20%5D,water_u%5B12:20%5D%5B0:2%5D%5B0:345%5D%5B0:540%5D

        %SIN EMBARGO, ES POSIBLE SOLICITAR LOS DATOS A UNA FRECUENCIA DETERMINADA
        %POR LA VARIABLE ndd; EL FORMATO DE SOLICITUD DEBERIA QUEDAR DE LA
        %SIGUIENTE MANERA:

        %https://tds.hycom.org/thredds/dodsC/GOMu0.04/expt_90.1m000.ascii?depth%5B0:1:2%5D,lat%5B0:1:345%5D,lon%5B0:1:540%5D,time%5B12:1:20%5D,tau%5B12:1:20%5D,water_u%5B12:1:20%5D%5B0:1:2%5D%5B0:1:345%5D%5B0:1:540%5D

        %%%%%%%%%%%%%%%%%%%%%%%
        %nota 1: 11/8/2020 para el producto GOMu0.04/expt_90.1m000 (2019 en adelante)
        %este producto contiene varios vacios de información (e.g. en 2019 conozco que le faltan hasta 20 días)
        %lo que ocasiona que, los rangos numericos de inicio y fin de cada mes para descargar que se
        %determina con las variables: time_model_ini, time_model_fin
        %(e.g. 12:731, que deberian descargar del 2 al 31 de enero de 2020)
        %contengan un desfase si es que falta un dia...
        %En otras palabras, el rango 12:731 corresponde al numero de
        %registro almacenado, pero el tiempo "verdadero" en horas desde
        %2000/1/1/0/0/0 de cada uno de esos registros se encuentra en la
        %variable "MT"
        
        %solucion propuesta: generar una variable que contenga las
        %fechas que no se pudieron descargar al encontrarse inexistentes en
        %el servidor
        
        %nota 2: 11/8/2020
        %la variable tiempo EN TODOS LOS PRODUCTOS es tratada como hora mundial y no local
        
        %nota 3: 11/8/2020
        %revise y confirme que el tratamiento ESPECIAL del vector tiempo para el
        %producto  GOMu0.04/expt_90.1m000 (2019 en adelante),
        %es realizado por la rutina de manera correcta
        %(SECCION 3 CREAR VECTOR DE TIEMPO A TRABAJAR)
        
        %nota 4: 31/10/2020
        %esta rutina considera como "mask" la capa de tierra firme en superficie.
               

        
        
% ___________________________________________________________


%REV4.- SE AGREGA ESTE NUEVO PRODUCTO:
        %5.- The Fleet Numerical Meteorology and Oceanography Center (FNMOC) 
        %Product	     Scale	POR	                      Model Cycle	   Output Time Step
        %AmSeas, Prior	1/36°	2010-05-08–2013-04-04	      1 day	            3 hours
        
        % The regional NCOMs produce 4-day forecasts at 3-hour time steps, updated at 00Z daily. FNMOC interpolates the output onto a regular grid with 1/30 degree (~3km) resolution in the horizontal and 40 levels in the vertical; prior to April 5, 2013, the resolution was roughly 1/36 degree. 
        
        %nota5: 6/11/2020
        %para este nuevo producto (hyc_prod == 5), CARGO un VECTOR DE
        %TIEMPO DE REFERENCIA PARA FILTRAR REGISTROS DISPONIBLES, SI ES EL
        %CASO. 
        %ACTUALMENTE SOLO CONFIGURADO PARA LA OPCION 5, PERO EN LA
        %SIGUIENTE REVISION LO HABILITARE PARA TODOS LOS DEMADS PRODUCTOS
        
        %LA ESTRUCTURA DEL VECTOR DE REFERENCIA ES LA SIGUIENTE:
        
        %         VECTOR TIEMPO DESDE "tref"   UNIDADES DE TIEMPO "ft10" TOMADAS DIRECTAMENTE DEL ARCHIVO (HORAS DESDE XX... DIAS DESDE XX)
        %         2010	5	8	0	0	0	   0
        %         2010	5	8	3	0	0	   3
        %         2010	5	8	6	0	0	   6
        %         2010	5	8	9	0	0	   9
        %         2010	5	8	12	0	0	   12
        %         ...
        %         2013	4	4	21	0	0      25509
        %         
        % LA ULTIMA COLUMNO LA NECESITO PARA AGREGAR LA FECHA DE INICIO DE
        % CADA ARCHIVO; AL FINAL, SE AGREGA UNA REVISION DE ESTO EN LA
        % VARIABLE 'tini_ft10_rev', que se concatena en la ultima columna
        % de la variable 'rev_final' nque se guarda
        

        
% ___________________________________________________________


%REV5.- SE AGREGA LA OPCION DE DESCARGAR LA SSH PARA EL PRODUCTO HYCOM 31.0:



% ___________________________________________________________

%REV5b.- PRIMER INTENTO PARA SIMPLIFICAR REV5, CON EL OBJETIVO QUE PUEDA
%SER UTILIZADO POR OTROS USUARIOS. TAMBIEN SE AGREGA REGISTRO DE PERIODOS
%FALTANTES Y SOBRANTES AL COMPARAR LOS ARCHIVOS DESCARGADOS VS EL PERIODO
%DE DESCARGA SOLICITADO POR EL USUARIO.
%NOTA IMPORTANTE. ESTA IMPLEMENTACIÓN SOLO SE ENCUENTRA HABILITADA CUANDO
%hyc_prod=2, 3 o 4 (productos de la familia HYCOM)


%Miguel Cahuich
%CINVESTAV-Mérida
        
%% 1 DEFINIENDO PRODUCTO A DESCARGAR Y A PROCESAR (USUARIO MODIFICA)

clear all
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% 1.1 DEFINIR EL PRODUCTO A DESCARGAR Y PROCESAR %%%%%%%%%%%%%%

hyc_prod=3;   %flag principal que controla toda la rutina
%seleccionar una opción de la lista de productos disponibles:

%1.-  HYCOM + NCODA Gulf of Mexico 1/25° Reanalysis
%Product	              Scale	           Model Cycle	   Output Time Step
%GOMu0.04/expt_50.1	       1/25°	           NA	            3 hours
%AVAILABLE PERIOD: 1993-01-02 to 2012-12-30 (NO IMPLEMENTADA AUN, PERO EN UN FUTURO SE HARÁ)
    
        %2.- %HYCOM + NCODA Gulf of Mexico 1/25° Analysis
        %Product	               Scale	           Model Cycle	   Output Time Step
        %GOMl0.04/expt_31.0        1/25°                  1 day           1 hour
        %AVAILABLE PERIOD: 2009-04-02 to 2014-07-30
        
                %3.- HYCOM + NCODA Gulf of Mexico 1/25° Analysis
                %Product	               Scale	           Model Cycle	   Output Time Step
                %GOMl0.04/expt_32.5        1/25°                 1 day             1 hour
                %AVAILABLE PERIOD: 2014-04-02 to 2019-02-02
            
                                    
                        %4.- HYCOM + NCODA Gulf of Mexico 1/25° Analysis
                        %Product	               Scale	           Model Cycle	   Output Time Step
                        %GOMu0.04/expt_90.1m000     1/25°                1 day               1 hour
                        %AVAILABLE PERIOD: 2019-01-02 to Present + FORECASTS
                              
                        
                                        %5.- The Fleet Numerical Meteorology and Oceanography Center (FNMOC) Analysis
                                        %Product	      Scale	           Model Cycle	   Output Time Step
                                        %AmSeas, Prior	   1/36°	         1 day	            3 hours
                                        %AVAILABLE PERIOD: 2010-05-09 to 2013-04-03
                                        %(NO IMPLEMENTADA POR COMPLETO EN
                                        %ESTA RUTINA)

                                        
% Nota. Por "seguridad", se indican cómo periodos disponibles para descargar,
% las fechas de inicio y fin de la simulación más un número determinado de
% horas para obtener el número no-fraccional más cercano (por ejemplo,
% el producto hyc_prod=2 "GOMl0.04/expt_31.0" se encuentra en realidad disponible
% desde 2009-4-1-19-0-0 pero aquí se indica cómo periodo de inicio de
% descarga el 2009-04-02).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% 1.3 DEFINIR PERIODO A DESCARGAR %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %%hyc_prod=2.    %2009-04-02 to 2014-07-30
% year_ini=2009;
% month_ini=4;
% tini=[year_ini month_ini 2 0 0 0]; 
% 
% year_fin=2009;
% month_fin=7;
% tfin=[year_fin month_fin 2 23 0 0]; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %%hyc_prod=3  %2014-04-02 to 2019-02-02

year_ini=2016;
month_ini=5;
tini=[year_ini month_ini 1 14 0 0]; 

year_fin=2016;
month_fin=5;
tfin=[year_fin month_fin 6 14 0 0];  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%hyc_prod=4  %2019-01-02 to Present + FORECASTS
% year_ini=2019;
% month_ini=1;
% tini=[year_ini month_ini 2 0 0 0]; 
% 
% year_fin=2019;
% month_fin=12;
% tfin=[year_fin month_fin 31 23 0 0];  %no bajar archivos por encima de la fecha actual

% year_ini=2020;
% month_ini=1;
% tini=[year_ini month_ini 1 0 0 0]; 
% 
% year_fin=2020;
% month_fin=12;
% tfin=[year_fin month_fin 31 23 0 0];  %no bajar archivos por encima de la fecha actual


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% 1.2 DEFINIR LA VARIABLE A DESCARGAR %%%%%%%%%%%%%%%%%%%


%defino variables a extraer
fflag = 4; %3 zonal u; 4 meridional v; 5 SSH [3/1/2021; ESTE ÚLTIMO SOLO CUANDO hyc_prod=2 (PRODUCTO HYCOM 31.0)]



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% 1.4 DEFINIR DOMINIO ESPACIAL DE LOS DATOS %%%%%%%%%%%%%%%%%%%
 
% % % %dominio a extraer COZUMEL REV1 SOLO CANAL
% lower_left_lat=19.996328; %var3
% lower_left_lon=-87.483851; %var4
% upper_right_lat=21.008066;  %var5  
% upper_right_lon=-86.471972; %var6


% % %extraer todo el golfo de mexico completo
lower_left_lat=10.186588; %var3
lower_left_lon=-110.927232; %var4
upper_right_lat=36.808400;  %var5  
upper_right_lon=-64.102623; %var6



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% 1.5 DEFINIR PROFUNDIDADES DESEADAS %%%%%%%%%%%%%%%%%%%%%%%%%%

%lista de opciones:

%%%hyc_prod=2, 2009-04-02 to 2014-07-30
    %40 niveles
    %[0,5,10,15,20,25,30,40,50,60,70,80,90,100,125,150,200,250,300,400,500,600,700,800,900,1000,1100,1200,1300,1400,1500,1750,2000,2500,3000,3500,4000,4500,5000,5500]

%%%hyc_prod=3, 2014-04-02 to 2019-02-02
    %40 niveles
    %[0,5,10,15,20,25,30,40,50,60,70,80,90,100,125,150,200,250,300,400,500,600,700,800,900,1000,1100,1200,1300,1400,1500,1750,2000,2500,3000,3500,4000,4500,5000,5500]

%%hyc_prod=4, 2019-01-02 to Present + FORECASTS
    %40 niveles
    %[0,2,4,6,8,10,12,15,20,25,30,35,40,45,50,60,70,80,90,100,125,150,200,250,300,350,400,500,600,700,800,900,1000,1250,1500,2000,2500,3000,4000,5000]

%%hyc_prod=5, 2010-05-09 to 2013-04-03
    %40 niveles
    %[0,2,4,6,8,10,12,15,20,25,30,35,40,45,50,60,70,80,90,100,125,150,200,250,300,350,400,500,600,700,800,900,1000,1250,1500,2000,2500,3000,4000,5000]

%rango releccionado:
prof_level=1:1;
%prof_level=1:2;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% 1.6 DEFINIR NOMBRE DE CARPETA DE RESULTADOS %%%%%%%%%%%%%%%%%

%fres='7___cozumel_test';  %prueba tiempo producto 31.0
%fres='7___cozumel_test2';  %segunda tiempo producto 31.0
%fres='5___cozumel_test2';  %primer tiempo producto 32.5
%fres='7___cozumel_test3'; %tercera prueba producto 90.1
%fres='7___cozumel_test4'; %cuarta prueba producto 90.1
%fres='7___cozumel_test3';  %tercer tiempo producto 31.0
%fres='5___cozumel_test3';  %segunda prueba producto 32.5
%fres='7___cozumel_test4';  %cuarta prueba producto 31.0
%fres='8___cozumel_test5'; %quinta prueba producto 90.1; primera en 2020
%fres='6_replica_GoM_s1';  %tratamos de replicar el archivo generado para el GoM que se utilizó en la sesión 1
%fres='7___cozumel_test5';  %quinta prueba producto 31.0
%fres='8___cozumel_test5b'; %quinta prueba producto 90.1; primera en 2020  (REPETICION)
fres='6_replica_GoM_2';

%% 1.2 DEFINIENDO AMBIENTE DE TRABAJO (USUARIO MODIFICA SOLO UNA VEZ
%clear all

%clearvars -except U_LP_NORM tlocal_3

%directorio librerias:
        %path1= 'P:\Miguel\HYCOM\ScriptsHycomm';
        path1= 'D:\Miguel_1\HYCOM\ScriptsHycomm';
        %'C:\Users\MiguelC\OneDrive\DOCTORADO_One_Drive\DOCENCIA\ICHTHYOP_\sesion_2\lib'

%carpeta donde se encuentran archivo de coordenadas completas del modelo:
%lista de opciones:

        if hyc_prod == 2 
                %2.- %HYCOM + NCODA Gulf of Mexico 1/25° Analysis (GOMl0.04/expt_31.0) 
                %2009-04-01 to 2014-07-31
                path2='D:\Miguel_1\HYCOM\hycom_out_GOMl0_04_expt_31.0_anal'; %31.0 analysis

        elseif hyc_prod == 3
                %3.- HYCOM + NCODA Gulf of Mexico 1/25° Analysis (GOMl0.04/expt_32.5)
                %2014-04-01 to 2019-02-03
                path2= 'D:\Miguel_1\HYCOM\hycom_out_GOMl0_04_expt_32.5_anal';  %32.5 analysis
                %'C:\Users\MiguelC\OneDrive\DOCTORADO_One_Drive\DOCENCIA\ICHTHYOP_\sesion_2\hfiles\hycom_out_GOMl0_04_expt_32.5_anal';

        elseif hyc_prod == 4
                %4.- HYCOM + NCODA Gulf of Mexico 1/25° Analysis (GOMu0.04/expt_90.1m000)
                %2019-01-01 to Present + FORECASTS
                path2='D:\Miguel_1\HYCOM\hycom_out_GOMu0_04_expt_90.1_anal'; %90.1 analysis

        elseif hyc_prod == 5
                %5.- The Fleet Numerical Meteorology and Oceanography Center (FNMOC) 
                %Product	     Scale	POR	                      Model Cycle	   Output Time Step
                %AmSeas, Prior	1/36°	2010-05-08–2013-04-04	      1 day	            3 hours
                path2='D:\Miguel_1\HYCOM\NCODA_AmSeas_2010_2013';%AmSeas, Prior	1/36°

        else
        end
        
%carpeta donde se guardan los resultados
        %path2_2='C:\Users\Lapcof03\Documents\miguel_temp\hyc_32_5_2014__2019\camp_rev2_f_2017_2018';
        %path2_2='C:\Users\Lapcof03\Documents\miguel_temp\hyc_32_5_2014__2019\yuc_rev3_f_2017_2018';
        %path2_2='C:\Users\Lapcof03\Documents\miguel_temp\hyc_90_1_2019__adel\yuc_rev3_f_2019';
        %path2_2='C:\Users\Lapcof03\Documents\miguel_temp\hyc_90_1_2019__adel\camp_rev2_f_2019';
        %path2_2='C:\Users\Lapcof03\Documents\miguel_temp\hyc_32_5_2014__2019\YP_rev2_2017_2018';
        %path2_2='C:\Users\Lapcof03\Documents\miguel_temp\hyc_90_1_2019__adel\YP_rev3_2019_Tanya';     
        %path2_2='C:\Users\Lapcof03\Documents\miguel_temp\hyc_90_1_2019__adel\YP_rev4_2019_Tanya';
        %path2_2='D:\Miguel_1\HYCOM\hycom_out_GOMl0_04_expt_31.0_anal\cozumel_rev3_sep_2020_0__150m_test';
        %path2_2='D:\Miguel_1\HYCOM\NCODA_AmSeas_2010_2013\cozumel_rev1';
        %path2_2='D:\Miguel_1\HYCOM\NCODA_AmSeas_2010_2013\cozumel_rev2_0_150m_complete';
        %path2_2='D:\Miguel_1\HYCOM\hycom_out_GOMl0_04_expt_31.0_anal\cozumel_rev4_ene_2021_0_m_test_ssh';
        %path2_2='D:\Miguel_1\HYCOM\hycom_out_GOMl0_04_expt_31.0_anal\cozumel_rev4_ene_2021_0_m_final_ssh';
        %path2_2='D:\Miguel_1\HYCOM\hycom_out_GOMu0_04_expt_90.1_anal\7___cozumel_test';  %cozumel test 2019
        %path2_2='D:\Miguel_1\HYCOM\hycom_out_GOMu0_04_expt_90.1_anal\7___cozumel_test2'; %segunda prueba de inspeccion; quiero generar correctamente el vector tiempo
        %path2_2='D:\Miguel_1\HYCOM\hycom_out_GOMl0_04_expt_31.0_anal\7___cozumel_test';  %prueba tiempo producto 31.0
        path2_2=path2;
                
%shapefile peninsula de yucatan:
        path3= 'D:\D\L\4_SIG\YUC_PENINSULA\YUC_PENINSULA.shp'; 
        %'C:\Users\MiguelC\OneDrive\DOCTORADO_One_Drive\DOCENCIA\ICHTHYOP_\sesion_2\YUC_PENINSULA\YUC_PENINSULA.shp';

%% 2 BANDERAS PARA LOS PRODUCTOS           
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% NO MODIFICAR SECCIONES SIGUIENTES

% BANDERAS PARA DESCARGA DE LOS DATOS

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (hyc_prod == 1) || (hyc_prod == 2) || (hyc_prod == 3)

        %banderas de variables a extraer
        if fflag == 1
        var_flag='s'; %salinidad
        var_flag2='s'; %salinidad
        leg_g='Water salinity';
        leg_u='psu';

        elseif fflag == 2
        var_flag='t'; %temperatura
        var_flag2='t'; %temperatura
        leg_g='Water temperature';
        leg_u='degC';

        elseif fflag == 3
        var_flag='u';  %zonal u
        var_flag2='u';  %zonal u
        leg_g='Eastward water velocity';
        leg_u='m/s';

        elseif fflag == 4
        var_flag='v';  %meridional v
        var_flag2='v';  %meridional v
        leg_g='Nothward water velocity';
        leg_u='m/s';
        
        elseif fflag == 5 %SSH. NEW 03/01/2020. SE BAJA EN 2D Y NO SE NECESITA INDICAR LAS PROFUNDIDADES A DESCARGAR
        var_flag='ssh';  %ssh
        var_flag2='h';  %ssh
        leg_g='Sea surface elevation';
        leg_u='m';


        else
        end

elseif hyc_prod == 4

     %banderas de variables a extraer
        if fflag == 1
        var_flag='salinity'; %salinidad
        var_flag2='s'; %salinidad
        leg_g='Water salinity';
        leg_u='psu';

        elseif fflag == 2
        var_flag='water_temp'; %temperatura
        var_flag2='t'; %temperatura
        leg_g='Water temperature';
        leg_u='degC';

        elseif fflag == 3
        var_flag='water_u';  %zonal u
        var_flag2='u';  %zonal u
        leg_g='Eastward water velocity';
        leg_u='m/s';

        elseif fflag == 4
        var_flag='water_v';  %meridional v
        var_flag2='v';  %meridional v
        leg_g='Nothward water velocity';
        leg_u='m/s';

        else
        end

        
elseif hyc_prod == 5 %NEW

     %banderas de variables a extraer
        if fflag == 1
        var_flag='salinity'; %salinidad
        var_flag2='s'; %salinidad
        leg_g='Water salinity';
        leg_u='psu';

        elseif fflag == 2
        var_flag='water_temp'; %temperatura
        var_flag2='t'; %temperatura
        leg_g='Water temperature';
        leg_u='degC';

        elseif fflag == 3
        var_flag='water_u';  %zonal u
        var_flag2='u';  %zonal u
        leg_g='Eastward water velocity';
        leg_u='m/s';

        elseif fflag == 4
        var_flag='water_v';  %meridional v
        var_flag2='v';  %meridional v
        leg_g='Nothward water velocity';
        leg_u='m/s';

        else
        end
        
        
    
else 
end


% % LAS SIGUIENTES LINEAS NO DEBEN MODIFICARSE
% 
% % Componentes de archivos a descargar
% 
% if hyc_prod == 1
% 
% %HYCOM + NCODA Gulf of Mexico 1/25° Reanalysis (GOMu0.04/expt_50.1) 1993 TO
% %2012
% url1 = 'hycom_gomu_501_';
% url2 = '00_t0';
% url3 = '.nc';
% 
% elseif hyc_prod == 2
% url1 = 'archv.';
% url2 = '3z';
% url3 = '.nc';
% 
% elseif hyc_prod == 3
% url1 = 'archv.';
% url2 = '3z';
% url3 = '.nc';
%  
% 
% else 
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Definiendo componentes generales del servidor url

if hyc_prod == 1
    
%HYCOM + NCODA Gulf of Mexico 1/25° Reanalysis (GOMu0.04/expt_50.1) 1993 TO
%2012
% ft1='ftp.hycom.org';
% ft2='datasets';
% ft3='GOMu0.04';
% ft4='expt_50.1';
% ft5='data';
% ft6='netcdf';

elseif hyc_prod == 2


ft1='http://tds.hycom.org';
ft2='thredds';
ft3='dodsC';
ft4='GOMl0.04';
ft5='expt_31.0';
ft6='hrly.ascii';
ft7='Depth';
ft8='Latitude';
ft9='Longitude';
ft10='MT';
ft11='Date';
ft12=var_flag;
%http://tds.hycom.org/thredds/dodsC/GOMl0.04/expt_31.0/hrly.ascii?Depth%5B0:1:8%5D,Latitude%5B0:1:38%5D,Longitude%5B0:1:54%5D,MT%5B0:1:20%5D,Date%5B0:1:20%5D,u%5B0:1:20%5D%5B0:1:8%5D%5B0:1:38%5D%5B0:1:54%5D

elseif hyc_prod == 3

ft1='http://tds.hycom.org';
ft2='thredds';
ft3='dodsC';
ft4='GOMl0.04';
ft5='expt_32.5';
ft6='hrly.ascii';
ft7='Depth';
ft8='Latitude';
ft9='Longitude';
ft10='MT';
ft11='Date';
ft12=var_flag;



elseif hyc_prod == 4

ft1='https://tds.hycom.org';
ft2='thredds';
ft3='dodsC';
ft4='GOMu0.04';
ft5='expt_90.1m000';
ft6='.ascii';
ft7='depth';
ft8='lat';
ft9='lon';
ft10='time';
ft11='tau';
ft12=var_flag;
%https://tds.hycom.org/thredds/dodsC/GOMu0.04/expt_90.1m000.ascii?depth%5B0:2%5D,lat%5B0:345%5D,lon%5B0:540%5D,time%5B12:20%5D,tau%5B12:20%5D,water_u%5B12:20%5D%5B0:2%5D%5B0:345%5D%5B0:540%5D


elseif hyc_prod == 5 %new

ft1='https://www.ncei.noaa.gov';
ft2='thredds-coastal';
ft3='dodsC';
ft4='ncom_amseas_agg_20091119_20130404';
ft5='Amseas_May_2010_to_Apr_04_2013_best.ncd';
ft6='.ascii';
ft7='lon';
ft8='lat';
ft9='depth';
ft10='time';
ft11='time_run';
ft12=var_flag;

%con "time run"
%https://www.ncei.noaa.gov/thredds-coastal/dodsC/ncom_amseas_agg_20091119_20130404/Amseas_May_2010_to_Apr_04_2013_best.ncd.ascii?lon[369:1:405],lat[554:1:594],depth[0:1:1],time[176:1:178],time_run[176:1:178],water_u[176:1:178][0:1:1][554:1:594][369:1:405]

% sin "time_run"
%https://www.ncei.noaa.gov/thredds-coastal/dodsC/ncom_amseas_agg_20091119_20130404/Amseas_May_2010_to_Apr_04_2013_best.ncd.ascii?lon[369:1:405],lat[554:1:594],depth[0:1:21],time[176:1:415],water_u[176:1:415][0:1:21][554:1:594][369:1:405]
                   
                  
else
end
    
        

%HYCOM + NCODA Gulf of Mexico 1/25° Analysis (GOMl0.04/expt_31.0) 2009-04-01 to 2014-07-31


            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%NO MODIFICAR SECCIONES SIGUIENTES

% AJUSTES ESPECIFICOS PARA LOS PRODUCTOS


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        

%%%%%%%%%%% 2.4 OFFSET PARA LECTURA DE ASCII FILES %%%%%%%%%%%%%%%%%%%

if (hyc_prod == 1) ||  (hyc_prod == 2) ||  (hyc_prod == 3)

        
        if (fflag == 3) || (fflag == 4)  %solo implementado con u y v para matrices en 4d para hyc_prod == 2 al 3/1/2021

           %FILA Y COLUMNAS GENERALES DE OFFSET
            R1=1; 
            C1=1; 

            R2=26; %FILA DONDE SE ENCUENTRA EL VECTOR TIEMPO
            R3=28; %FILA DONDE EMPIEZAN LOS RESULTADOS
            R4=8; %FILA DONDE TERMINAN LOS RESUTADOS - 1 (DE ABAJO HACIA ARRIBA)

            %CIF=3; %cifras significativas para redondear horas

        elseif fflag == 5  %solo implementado con ssh para matrices 3d para hyc_prod == 2 al 3/1/2021

            %FILA Y COLUMNAS GENERALES DE OFFSET
            R1=1; 
            C1=1; 

            R2=26-4; %FILA DONDE SE ENCUENTRA EL VECTOR TIEMPO
            R3=28-4; %FILA DONDE EMPIEZAN LOS RESULTADOS
            R4=8-2; %FILA DONDE TERMINAN LOS RESUTADOS - 1 (DE ABAJO HACIA ARRIBA)

            %CIF=3; %cifras significativas para redondear horas


        else
        end
        
        
elseif hyc_prod == 4

        %FILA Y COLUMNAS GENERALES DE OFFSET
        R1=1; 
        C1=1; 

        R2=24; %FILA DONDE SE ENCUENTRA EL VECTOR TIEMPO
        R3=28; %FILA DONDE EMPIEZAN LOS RESULTADOS
        R4=8; %FILA DONDE TERMINAN LOS RESUTADOS - 1 (DE ABAJO HACIA ARRIBA)

        %CIF=3; %cifras significativas para redondear horas


elseif hyc_prod == 5  %NEW

        %FILA Y COLUMNAS GENERALES DE OFFSET
        R1=1; 
        C1=1; 

        R2=24; %FILA DONDE SE ENCUENTRA EL VECTOR TIEMPO
        R3=28; %FILA DONDE EMPIEZAN LOS RESULTADOS
        R4=8; %FILA DONDE TERMINAN LOS RESUTADOS - 1(DE ABAJO HACIA ARRIBA)

        %CIF=3; %cifras significativas para redondear horas



else
end
                
                

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%ESTIMAR LA FRECUENCIA DE CADA DATO


if hyc_prod == 1
ndd=1/8; %%HYCOM + NCODA Gulf of Mexico 1/25° Reanalysis (GOMu0.04/expt_50.1) 1993 TO
%2012
elseif hyc_prod == 2
ndd=1/24;  %HYCOM + NCODA Gulf of Mexico 1/25° Analysis (GOMl0.04/expt_31.0) 2009-04-01 to 2014-07-31
elseif hyc_prod == 3
ndd=1/24;  
elseif hyc_prod == 4
ndd=1/24; 
elseif hyc_prod == 5 %NEW
ndd=1/8; 
else
end

%% 3 CREAR VECTOR DE TIEMPO A TRABAJAR 

%Tiempo de inicio de referencia de los datos para la solicitud en el
%servidor OPENDAP
%Nota 1. Este número correspondería al primer registro que potencialmente se podría descargar
% del servidor opendap
%Nota 2. Este número se utiliza para estimar las variables time_model_ini, time_model_fin
% que se "insertan" en este tipo de estructura para solicitar el rango de registros a descargar:
% http://tds.hycom.org/thredds/dodsC/GOMl0.04/expt_31.0/hrly.ascii?Depth%5B0:1:8%5D,Latitude%5B0:1:38%5D,Longitude%5B0:1:54%5D,MT%5B0:1:20%5D,Date%5B0:1:20%5D,u%5B0:1:20%5D%5B0:1:8%5D%5B0:1:38%5D%5B0:1:54%5D


if hyc_prod == 1

        %HYCOM + NCODA Gulf of Mexico 1/25° Reanalysis (GOMu0.04/expt_50.1) 1993 TO
        %2012
        %tref=[];

elseif hyc_prod == 2
        %2.- %HYCOM + NCODA Gulf of Mexico 1/25° Analysis (GOMl0.04/expt_31.0) 
                %2009-04-01 to 2014-07-31
        tref=[2009 4 1 19 0 0];  %days since the experiment starts (GOMl0.04/expt_31.0)


elseif hyc_prod == 3
            %3.- HYCOM + NCODA Gulf of Mexico 1/25° Analysis (GOMl0.04/expt_32.5)
                    %2014-04-01 to 2019-02-03
        tref=[2014 4 1 13 0 0];  %days since the experiment starts (GOMl0.04/expt_32.5)

elseif hyc_prod == 4
            %4.- HYCOM + NCODA Gulf of Mexico 1/25° Analysis (GOMu0.04/expt_90.1m000)
            %2019-01-01 to Present + FORECASTS
        tref=[2019 1 1 12 0 0];  %days since the experiment starts (GOMu0.04/expt_90.1m000)

elseif hyc_prod == 5 %NEW
            % %5.-  %5.- The Fleet Numerical Meteorology and Oceanography Center (FNMOC) 
            %Product	     Scale	Model Cycle	   Output Time Step
            %AmSeas, Prior	1/36°	1 day	            3 hours
            % TimeCoverage:
            % Start: 2010-05-08T00:00:00Z
            % End: 2013-04-04T21:00:00Z
        tref=[2010 5 8 0 0 0];  %days since the experiment starts

else
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%crear grupos de tiempos de inicio y fin por mes/año

time_ini2=datenum(tini); %fecha a seleccionar en numero de dias
time_fin2=datenum(tfin); %fecha a seleccionar en numero de dias


if hyc_prod == 5 % CARGO VECTOR DE TIEMPO DE REFERENCIA PARA FILTRAR REGISTROS DISPONIBLES, SI ES EL CASO; ACTUALMENTE SOLO CONFIGURADO PARA LA OPCION 5
    
                    cd(path2);
                    load('time_available.mat','time_available');
                    t_2=datenum(time_available(:,1:6));      
                    idx=t_2 >= time_ini2 & t_2 <= time_fin2;
                    time_1=t_2(idx,1);
                    time_2=datevec(time_1);
                    clear idx


                     %se crean grupos por año y mes
                    [groups_u,~,inds] = unique(time_2(:,[1 2]), 'rows');
                    [ii,jj] = ndgrid(inds,1:size(time_2,2));
                    time_3 = accumarray([ii(:),jj(:)],time_2(:),[],@mean);
                    time_3=time_3(:,1:2);
                    clear ans groups_u ii inds jj Mat1 out1

                    %bucle para tiempos de inicio y fin
                    tini3=[]; tfin3=[];
                    for i=1:size(time_3,1)
                        ind=time_2(:,[1 2]) == time_3(i,[1 2]);
                        ind2=double(ind);  ind2=ind2'; ind2=sum(ind2); ind2=ind2';
                        ind3=ind2(:,1) == 2;
                        time_4=time_1(ind3,:);
                        tini2=min(time_4); tfin2=max(time_4);
                        tini3=vertcat(tini3,tini2); tfin3=vertcat(tfin3,tfin2);
                        clear tini2 tfin2 time_4 ind3 ind2 ind
                    end
                    clear time_ini2 time_fin2 i time_1 time_2


                    %busco los indices de las nuevas fechas de inicio y fin en el vector
                    %original
                    tini3_temp=[];
                    tfin3_temp=[];
                    tini_ft10=[];

                    for i=1:size(tini3,1)
                        idx2=find(t_2 >= tini3(i,1) & t_2 <= tfin3(i,1));
                        tini3_temp(i,:)=min(idx2);
                        tfin3_temp(i,:)=max(idx2);
                        
                        tini_ft10(i,:)=time_available(tini3_temp(i),7);
                        tfin_ft10(i,:)=time_available(tfin3_temp(i),7);
                        
                        %time_1=t_2(idx,1);
                        %time_2=datevec(time_1);
                        clear idx2 i
                    end
                    clear t_2 time_available
                    
                    
                    % NUMERO DE REGISTRO DEFINITIVO PARA INICIAR LA
                    % DESCARGA
                    time_model_ini=tini3_temp-1;  %RESTO MENOS 1 DEBIDO PARA HACER COINCIDIR CON EL SERVIDOR OPENDAP
                    time_model_fin=tfin3_temp-1;  %RESTO MENOS 1 DEBIDO PARA HACER COINCIDIR CON EL SERVIDOR OPENDAP


                    clear  tref time_fin2 time_ini2 year_ini month_ini
                    clear year_fin month_fin time_ini3 time_fin3 tref2
                    clear  tfin4 tini4  tini3_temp  tfin3_temp


        
        
        
        
else  % creo mi propio vector de referencia
    
                    time_1=(time_ini2:ndd:time_fin2); time_1=time_1';
                    time_2=datevec(time_1);


                    %se crean grupos por año y mes
                    [groups_u,~,inds] = unique(time_2(:,[1 2]), 'rows');
                    [ii,jj] = ndgrid(inds,1:size(time_2,2));
                    time_3 = accumarray([ii(:),jj(:)],time_2(:),[],@mean);
                    time_3=time_3(:,1:2);
                    clear ans groups_u ii inds jj Mat1 out1

                    %bucle para tiempos de inicio y fin
                    tini3=[]; tfin3=[];
                    for i=1:size(time_3,1)
                        ind=time_2(:,[1 2]) == time_3(i,[1 2]);
                        ind2=double(ind);  ind2=ind2'; ind2=sum(ind2); ind2=ind2';
                        ind3=ind2(:,1) == 2;
                        time_4=time_1(ind3,:);
                        tini2=min(time_4); tfin2=max(time_4);
                        tini3=vertcat(tini3,tini2); tfin3=vertcat(tfin3,tfin2);
                        clear tini2 tfin2 time_4 ind3 ind2 ind
                    end
                    clear time_ini2 time_fin2 i


                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


                    % ESTIMAR NUMERO DE HORAS DESDE UNA FECHA EN ESPECIFICO
                      %3.- HYCOM + NCODA Gulf of Mexico 1/25° Analysis (GOMl0.04/expt_32.5)
                           %2014-04-01 to 2019-02-03

                    if (hyc_prod == 2) ||  (hyc_prod == 3) ||  (hyc_prod == 4)

                            %time_ini2=datenum(tini); %fecha a seleccionar en numero de dias
                            tini4=tini3*24; %fecha a seleccionar en numero de horas
                            %time_fin2=datenum(tfin); %fecha a seleccionar en numero de dias
                            tfin4=tfin3*24; %fecha a seleccionar en numero de horas

            %         elseif hyc_prod == 5
            % 
            %                 %time_ini2=datenum(tini); %fecha a seleccionar en numero de dias
            %                 tini4=tini3*8; %fecha a seleccionar en numero de horas
            %                 %time_fin2=datenum(tfin); %fecha a seleccionar en numero de dias
            %                 tfin4=tfin3*8; %fecha a seleccionar en numero de horas


                    else
                    end




                    %%%%%%%%%%%%%%%%%%%%%%%%%%%

                    if (hyc_prod == 2) ||  (hyc_prod == 3) ||  (hyc_prod == 4)

                            tref=datenum(tref);
                            tref2=tref*24; %number of hours from...

            %         elseif hyc_prod == 5
            % 
            %                 tref=datenum(tref);
            %                 tref2=tref*8; %number of hours from...

                    else
                    end


                    %%%%%%%%%%%%%%%%%%%%%%%%%%%

                    %dias finales contados desde since...
                    time_model_ini=tini4-tref2;
                    time_model_fin=tfin4-tref2;


                    clear  tref time_fin2 time_ini2 year_ini month_ini
                    clear year_fin month_fin time_ini3 time_fin3 tref2
                    clear  tfin4 tini4




end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% t90_1_3
% SEGUNDO TIEMPO DE REFERENCIA PARA LOS PRODUCTOS 4 (HYCOM 90.1) || 5 (NCOM-AMSEAS)
% QUE SE UTILIZA PARA ESTIMAR LA FECHA DEL ARCHIVO
%NOTA 1: en estos productos (hyc_prod == 4 || hyc_prod == 5), la fecha se estima a partir de las horas del archivo 
%contadas desde una fecha de referencia establecidas en la variable t90_1_3 
%NOTA 2: En contraste, si hyc_prod == 2 || hyc_prod == 3
% se lee la fecha directamente del archivo (ver BLOQUE 6 "LEYENDO ARCHIVOS ASCII DESCARGADOS")
% por esta razón para estos productos no se establece una variable t90_1_3

if hyc_prod == 4

        t90_1=[2000,1,1,0,0,0]; %'units','hours since 2000-01-01 00:00:00'
        t90_1_2=datenum(t90_1);
        t90_1_3=t90_1_2*24; %lo expresamos en horas

        clear t90_1  t90_1_2

elseif hyc_prod == 5

        t90_1=[2010,5,8,0,0,0]; %units: hours since 2010-05-08 00:00:00.000 UTC
        t90_1_2=datenum(t90_1);
        t90_1_3=t90_1_2*24; %lo expresamos en horas

        clear t90_1  t90_1_2

else
end

%% 4 GENERO INDICES DE LATITUD Y LONGITUD DE ACUERDO AL SUBGRID INDICADO

cd(path2);

load('lat_2.mat','lat_2');  load('lon_2.mat','lon_2'); load('prof.mat','prof');
%load('h0.mat','h0'); %tambien cargo batimetria para generar mascara

prof_level=prof_level'; %hago esto para no alterar la rutina

lat_3=flipud(lat_2(:,1));

%%%%%%%%%%%%% FILTRANDO EL SUBGRID DE ACUERDO A ESQUINAS DEL DOMINIO

% indices intervalo latitud
ind_lat0 = lat_2(:,1) >= lower_left_lat &  lat_2(:,1) <= upper_right_lat;
ind_lat = find(lat_3 >= lower_left_lat &  lat_3 <= upper_right_lat);

% indices intervalo longitud
ind_lon0 = lon_2(1,:) >= lower_left_lon &  lon_2(1,:) <= upper_right_lon;
ind_lon0=ind_lon0';
ind_lon = find(lon_2(1,:) >= lower_left_lon &  lon_2(1,:) <= upper_right_lon);

clear  lat_3


% creo rangos en formato de string de la latitud y longitud
ind_lat2=[min(ind_lat)-1; max(ind_lat)-1]; %RESTO MENOS 1 DEBIDO PARA HACER COINCIDIR CON EL SERVIDOR OPENDAP
ind_lat3=num2str(ind_lat2(1,1)); ind_lat4=num2str(ind_lat2(2,1));
ind_lat5=strcat(ind_lat3,':',ind_lat4);
clear  ind_lat2 ind_lat3 ind_lat4 

ind_lon2=[min(ind_lon)-1; max(ind_lon)-1];  %RESTO MENOS 1 DEBIDO PARA HACER COINCIDIR CON EL SERVIDOR OPENDAP
ind_lon3=num2str(ind_lon2(1,1)); ind_lon4=num2str(ind_lon2(2,1));
ind_lon5=strcat(ind_lon3,':',ind_lon4);
clear  ind_lon2 ind_lon3 ind_lon4



% creo rangos en formato de la profundidad
ind_prof=[min(prof_level)-1; max(prof_level)-1]; 
ind_prof2=num2str(ind_prof(1,1)); ind_prof3=num2str(ind_prof(2,1));
ind_prof4=strcat(ind_prof2,':',ind_prof3);
clear ind_prof ind_prof2 ind_prof3


%%%%%%%%%%%%% CREO UN SUBGRID PARA GRAFICAR
% 
% % indices intervalo latitud
% ind_lat_sub = lat_2(:,1) >= lower_left_lat &  lat_2(:,1) <= upper_right_lat;
% 
% %clear ind1
% 
% % indices intervalo longitud
% ind_lon_sub = lon_2(1,:) >= lower_left_lon &  lon_2(1,:) <= upper_right_lon;
% ind_lon_sub=ind_lon';

% filtro latitud y longitud

lat_sub=lat_2(ind_lat0,ind_lon0);
lon_sub=lon_2(ind_lat0,ind_lon0);

% filtro profundidad

prof_sub=(prof(prof_level,1));

% % creo mascara a partir de un subgrid de la batimetria
% 
% h0_2=h0';
% h0_3=flip(h0_2,1);
% h0_mask=h0_3(ind_lat_sub,ind_lon_sub);



% 
%figura para observar SUBDOMINIO MAR CARIBE
figure  %figura de la presion
geoshow('landareas.shp', 'FaceColor', 'none');
hold on
geoshow((path3),'EdgeColor', 'red','FaceColor', 'none');
hold on
% geoshow((path5), 'EdgeColor', 'red','FaceColor', 'none');
% hold on
plot(lon_sub,lat_sub,'.b')


%lat_3=lat_2(ind_lat(:,1)); 


clear ind_lat_sub    ind_lon_sub h0_2 h0_3

%% 5 DESCARGO DE SERVIDOR OPENDAP LOS DATOS

cd(path2_2);
mkdir(fres); cd(fres);


%GENERO STRING DE ETIQUETAS

%ind_time=[];

%for i=12:12
%for i=16:size(time_model_fin,1)
for i=1:size(time_model_fin,1)
    time_model_ini2=num2str(time_model_ini(i,1));
    time_model_fin2=num2str(time_model_fin(i,1));
    time_model=strcat(time_model_ini2,':',time_model_fin2);
    
    
    % Creo condicional para que el orden del URL cambie de acuerdo con el
    % producto a descargar
    
            if (hyc_prod == 1) || (hyc_prod == 2) || (hyc_prod == 3)
                
                    if (fflag == 3) || (fflag == 4) %se crea link para u, v

                        ind_time=strcat(ft1,'/',ft2,'/',ft3,'/',ft4,'/',ft5,'/',ft6,'?',ft7,...
                            '%5B',ind_prof4,'%5D,',ft8,'%5B',ind_lat5,'%5D,',ft9,...
                            '%5B',ind_lon5,'%5D,',ft10,'%5B',time_model,'%5D,',...
                            ft11,'%5B',time_model,'%5D,',var_flag,...
                            '%5B',time_model,'%5D','%5B',ind_prof4,'%5D',...
                            '%5B',ind_lat5,'%5D','%5B',ind_lon5,'%5D');

                    elseif fflag == 5  %se crea condicional para crear link para bajar datos en 2d. SSH. actualmente implementado solamente para hyc_prod == 2. 3/1/2021

                         ind_time=strcat(ft1,'/',ft2,'/',ft3,'/',ft4,'/',ft5,'/',ft6,'?',ft8,'%5B',ind_lat5,'%5D,',ft9,...
                            '%5B',ind_lon5,'%5D,',ft10,'%5B',time_model,'%5D,',...
                            ft11,'%5B',time_model,'%5D,',var_flag,...
                            '%5B',time_model,'%5D',...
                            '%5B',ind_lat5,'%5D','%5B',ind_lon5,'%5D');


                    else
                    end

            elseif hyc_prod == 4

                    ind_time=strcat(ft1,'/',ft2,'/',ft3,'/',ft4,'/',ft5,ft6,'?',ft7,...
                        '%5B',ind_prof4,'%5D,',ft8,'%5B',ind_lat5,'%5D,',ft9,...
                        '%5B',ind_lon5,'%5D,',ft10,'%5B',time_model,'%5D,',...
                        ft11,'%5B',time_model,'%5D,',var_flag,...
                        '%5B',time_model,'%5D','%5B',ind_prof4,'%5D',...
                        '%5B',ind_lat5,'%5D','%5B',ind_lon5,'%5D');
                    
            elseif hyc_prod == 5 %NEW
                    
                    ind_time=strcat(ft1,'/',ft2,'/',ft3,'/',ft4,'/',ft5,ft6,'?',ft7,'[',...
                             ind_lon5,'],',ft8,'[',ind_lat5,'],',ft9,'[',ind_prof4,'],',...
                             ft10,'[',time_model,'],',ft11,'[',time_model,'],',...
                             var_flag,'[',time_model,']','[',ind_prof4,']','[',ind_lat5,']','[',ind_lon5,']');



            else
            end
    
    
    url = ind_time;
    filename = strcat(num2str(i),'_',num2str(time_3(i,1)),...
        '_',num2str(time_3(i,2)),'.txt');
    options = weboptions('Timeout',Inf);
    outfilename = websave(filename,url,options);
    
    clear outfilename filename url ind_time time_model   time_model_ini2  time_model_fin2 i
    
    
end

%% 6 LEYENDO ARCHIVOS ASCII DESCARGADOS    

path(path,genpath(path1));  %agrego variables/scripts de esta carpeta al ambiente

%cd(path2_2);
cd(path2_2);
cd(fres);


mkdir(var_flag2);

movefile('*.txt',var_flag2);

cd(var_flag2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%creo directorio de archivos a leer

ftpobj=pwd;
dirs = dir(ftpobj); 

%condiciono para no elejir carpetas y solo elejir
%archivos
dirFlags = [dirs.isdir]; B = double(dirFlags);
C=B-1; D=C*-1; E=logical(D);  dirFlags=E; clear B C D E
subFolders = dirs(dirFlags);

%ordeno subfolders por su nombre
[~,ndx]=natsortfiles({subFolders.name});
dirs2 = subFolders(ndx);

clear ndx subFolders dirs dirFlags  subFolders

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%leo individualmente cada archivo ascii, lo proceso y genero resultados

rev_prel=[];
multi_all=[];
b_5_all=[];


%for i=43:size(dirs2,1)
for i=1:size(dirs2,1)
        
        baseFileName0=dirs2(i).name;
        %time_model_0=time_model_fin(i)-time_model_ini(i); 
        
        b_1 = dlmread(baseFileName0,',',R1,C1);  %leo toda la base de datos, delimitada por comma
        b_2 = b_1(R2,:);  %leo solo vector tiempo       
        b_6=b_1(R3:end-R4,1:size(ind_lon,2)); %leer datos
        
%        %2/2/2020. Lectura del primer registro del vector tiempo
%        if hyc_prod == 4  %hycom exp 90.1
%             b_1b = importdata(baseFileName0,' ');  %leo toda la base de datos, delimitada por comma
%             b_1c = b_1b.textdata; 
%             b_1c2 = find(contains(b_1c,'time['));
%             b_1d=char(b_1c(b_1c2(3,1)+1,:));
%         elseif (hyc_prod == 2) || (hyc_prod == 3)   %hycom exp 31.0 y exp 32.5
%             b_1b = importdata(baseFileName0,'\t');  %leo toda la base de datos, delimitada por comma
%             %b_1c = b_1b.textdata; 
%             b_1c2 = find(contains(b_1b,'Date['));
%             %b_1d=char(b_1c(b_1c2(3,1)+1,:));
%             b_1c3=b_1b(b_1c2(2,1)+1);
%             b_1c4=char(b_1c3);
%             b_1c5=strsplit(b_1c4);
%             b_1c6=b_1c5(1,1);
%             b_1d=char(b_1c6);
% 
%         else
%        end      
        
       
       %4/2/2020. Lectura del primer registro del vector tiempo
       %Modificación para lectura del primer paso de tiempo que se localiza en la primer columna. Utilizamos textscan
      
       if hyc_prod == 4  %hycom exp 90.1
           b_1b = fopen(baseFileName0);
           b_1c = textscan(b_1b,'%s %*[^\n]');
           fclose(b_1b);
           b_1c1=b_1c{1};
           b_1c2 = find(contains(b_1c1,'time['));
           b_1c3=b_1c1(b_1c2(1,1)+1,1);
           b_1c4=char(b_1c3);
           b_1d=b_1c4;
           
       elseif (hyc_prod == 2) || (hyc_prod == 3)   %hycom exp 31.0 y exp 32.5
           b_1b = fopen(baseFileName0);
           b_1c = textscan(b_1b,'%s %*[^\n]');
           fclose(b_1b);
           b_1c1=b_1c{1};
           b_1c2 = find(contains(b_1c1,'Date['));
           b_1c3=b_1c1(b_1c2+1,1);
           b_1c4=char(b_1c3);
           b_1d=b_1c4;
       else
       end
       
       
       %concatenamos el primer registro con el resto del vector tiempo
       %extraido
        b_1e=b_1d(1:end-1);
        b_1f=str2double(b_1e);
        clear b_1b b_1c b_1d b_1e b_1c2 b_1c3 b_1c4 b_1c5 b_1c6 b_1c1
        b_2=horzcat(b_1f,b_2);
        clear b_1f

        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %arreglar vector tiempo
        
        b_2=b_2';
        
        %eliminar ceros en el vector tiempo (esto pasa si se seleccionan menos de 24 horas para el mes en cuestion)
        idx=b_2 > 0; 
        b_2b=b_2(idx);
        b_2=b_2b;
        clear b_2b idx
     
        
        %b_2_t=round(b_2,4);
        %b_3=num2str(b_2); 
        b_4=[];
        %ndd2=round(ndd,CIF);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        %LEER EL TIEMPO DESDE EL ARCHIVO
        
        if (hyc_prod == 1) || (hyc_prod == 2) || (hyc_prod == 3) %en estos productos se lee la fecha directamente del archivo
        
                for jk=1:size(b_2,1)
                     b_3=num2str(b_2(jk,1));
                     y=b_3(1:4); y=str2double(y);
                     m=b_3(5:6); m=str2double(m);
                     d=b_3(7:8); d=str2double(d);
                     h=b_3(9:end); h=str2double(h); h2=h/ndd; %fraccion de dia
                     h2=round(h2); %horas exactas
                     h3 = isnan(h2); h3=double(h3);

                         if h3 == 1 %compruebo si la hora 0 es 0
                             h2=0;
                         else 
                         end

                     b_3_2=[y m d h2 0 0];
                     b_4=vertcat(b_4,b_3_2);
                     clear b_3_2 h2 h d m y b_3 h3 h2

                end

                %b_5=vertcat(datevec(tini3(i,1)),b_4);
                
                 %arreglado el 2/2/2020
                 b_5=b_4;


                clear jk b_4 b_2

                
                
                
        elseif hyc_prod == 4  %en estos productos la fecha se estima a partir de las horas del archivo contadas desde una fecha de referencia establecidas en la variable t90_1_3 (hours since 2000-01-01 00:00:00) 
        
                 for jk=1:size(b_2,1)
                     b_3=b_2(jk,1);
                     t90_1_4=t90_1_3+b_3; %sumamos el valor de la variable time (en horas) que trae un archivo del producto 90.1
                     t90_1_5=t90_1_4/24; %lo regreso a dias
                     %t90_1_5=t90_1_4*ndd; %lo regreso a dias. mejora del 3/2/2020
                     t90_1_6=datevec(t90_1_5); %esta es la fecha final que trae el archivo             
                     b_4=vertcat(b_4,t90_1_6);
                     clear b_3_2 h2 h d m y b_3 h3 h2
                     clear  t90_1_4 t90_1_5 t90_1_6
                  
                 end

                 %b_5=vertcat(datevec(tini3(i,1)),b_4);
                 
                 %arreglado el 2/2/2020
                 b_5=b_4;

                 clear jk b_4 b_2
                 
                 
                 
                 
          elseif hyc_prod == 5  %NEW; en estos productos la fecha se estima a partir de las horas del archivo contadas desde una fecha de referencia establecidas en la variable t90_1_3 (hours since 2010-05-08 00:00:00.000 UTC) 
        
                 for jk=1:size(b_2,1)
                     b_3=b_2(jk,1);
                     t90_1_4=t90_1_3+b_3; %sumamos el valor de la variable time (en horas) que trae un archivo del producto
                     t90_1_5=t90_1_4/24; %lo regreso a dias
                     t90_1_6=datevec(t90_1_5); %esta es la fecha final que trae el archivo             
     
                     b_4=vertcat(b_4,t90_1_6);
                     clear b_3_2 h2 h d m y b_3 h3 h2
                     clear  t90_1_4 t90_1_5 t90_1_6
                  
                 end
                 
                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                 % ADICIONALMENTE, EN EL PRODUCTO 5 AGREGAMOS EL TIEMPO INICIAL EN CUESTION QUE SE EXTRAJO EN EL BLOQUE 3
                  
                 t90_1_4=t90_1_3+tini_ft10(i,1); %sumamos el valor de la variable time (en horas) que trae un archivo del producto
                 t90_1_5=t90_1_4/24; %lo regreso a dias
                 t90_1_6=datevec(t90_1_5); %esta es la fecha final que trae el archivo
                 
                 b_5=vertcat(t90_1_6,b_4);

%                 %arreglado el 2/2/2020
%                  b_5=b_4;

                 clear  t90_1_4 t90_1_5 t90_1_6
                 clear jk b_4 b_2

            
        else
            
        end
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %generar arreglo matriz datos extraida
        %u_2014_092_00_3z2=u_2014_092_00_3z(:,:,1);
        
        if (hyc_prod == 1) || (hyc_prod == 2) || (hyc_prod == 3)  || (hyc_prod == 5) 
        
                %rellenar con NaN valores atipicos
                b_7=b_6; 
                idx=b_7(:,:) > 100;
                b_7(idx)=NaN;
                clear b_6 idx
        
        
        elseif hyc_prod == 4
            
                %rellenar con NaN valores atipicos
                b_7=b_6; 
                idx=b_7(:,:) == -30000;
                b_7(idx)=NaN;
                b_7b=b_7*0.001; %multiplico por factor de escalamiento
                %rev
                b_7b_max=nanmax(b_7b(:));  b_7b_min=nanmin(b_7b(:)); 
                b_7=b_7b;
                clear  b_7b_max b_7b_min b_7b
                clear b_6 idx
            
            
        else 
        end
            
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %rotar individualmente cada matriz ya que la latitud se encuentra
        %al reves
        b_8=b_7;
        b_10=[];
        for jk=1:size(b_5,1)*size(prof_level,1) %este es el numero total de matrices en 2d
            contador_fin=jk*size(ind_lat,1);
            contador_ini=(contador_fin-size(ind_lat,1))+1;
            b_9=b_8(contador_ini:contador_fin,:);
            b_9=flipud(b_9);
            b_10=vertcat(b_10,b_9);
            clear b_9 contador_fin contador_ini jk
        end
        clear b_8 b_7 b 
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
         %Creo matriz multidimensional del año/mes

        
        %creo matriz a ser rellenada
        multi = nan(size(ind_lat,1), size(ind_lon,2), size(prof_level,1), size(b_5,1)); %matriz de nan que va a ser rellenada
                       
       %se hace un bucle por cada paso de tiempo
        for jk=1:size(b_5,1) %b_5: numero de pasos de tiempo

            contador_time_fin=size(prof_level,1)*size(ind_lat,1)*jk;
            contador_time_ini=(contador_time_fin-size(prof_level,1)*size(ind_lat,1))+1;

            b_11=b_10(contador_time_ini:contador_time_fin,:);

                        multi2 = nan(size(ind_lat,1), size(ind_lon,2), size(prof_level,1));

                        %creo bucle para generar archivo de tres dimensiones por todas las profundidads
                        %de cada paso de tiempo
                        for k=1:size(prof_level,1)
                            contador_fin=k*size(ind_lat,1);
                            contador_ini=(contador_fin-size(ind_lat,1))+1;
                            b_12=b_11(contador_ini:contador_fin,:);
                            %b_9=flipud(b_9);
                            %b_10=vertcat(b_10,b_9);
                            multi2(:,:,k)=b_12;
                            clear b_12 contador_fin contador_ini k
                        end
            multi( :, :, :, jk ) = multi2; 

            %multi_rev=multi(:,:,1,1);

            clear b_11 multi2 contador_time_fin contador_time_ini jk

        end
        
        
     multi_all=cat(4,multi_all,multi); %concateno todos los datos de todos los meses

     b_5_all=cat(1,b_5_all,b_5); %concateno todos los pasos de tiempo


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %creo revision preliminar
    rev_final_0=size(b_10,1)/size(b_5,1); %se divide el numero de filas de la matriz, entre el numeto total de pasos de tiempo 
    rev_final_0=rev_final_0/size(prof_level,1); %se divide el resultado anterior entre el numero de profundidades, debe dar el tamaño de la latitud
    rev_final_1=rev_final_0-size(ind_lat,1);  %latitud derivada de las matrices menos la latitud inicialmente indicada en el script; debe ser igual a cero para todo OK

    %revision de unidades definidas en ft10, en la variable tini_ft10_rev
    %tini_ft10_rev=(datenum(b_5(2,:))-datenum(b_5(1,:)))-ndd; % la diferencia entre el primer y segundo paso de tiempo, deber ser igual a la freq de los datos (inverso de 3 hr o 1 hr, dado por la variable ndd)
    % si el resultado en tini_ft10_rev es distinto a cero,
    % es debido a algun (s) registro faltante

    %rev_final_2=horzcat(time_3(i,:),rev_final_1,tini_ft10_rev);
    rev_final_2=horzcat(time_3(i,:),rev_final_1);
    rev_prel=vertcat(rev_prel,rev_final_2);
    clear  rev_final_0 rev_final_1 rev_final_2 tini_ft10_rev

    clear i b_1 b_10 b_5 baseFileName0 multi b_2

 
end

%% 7 Comparar vector tiempo solicitado con el vector tiempo resultante

%time_2: vector tiempo solicitado; b_5_all: vector tiempo extraido directamente de los archivos

tiempo_solicitado=time_2;
tiempo_encontrado=b_5_all;

% %archivos faltantes
faltantes=setdiff(time_2,b_5_all,'rows'); 

% %archivos sobrantes
sobrantes=setdiff(b_5_all,time_2,'rows');

%% 8 Guardar periodos mensuales existentes y resultados generales del análisis  

cd(path2_2);
cd(fres);
cd(var_flag2);

% generar nuevos grupos de meses con base en el vector tiempo extraido directamente de los archivos

%se crean grupos por año y mes
[groups_u,~,inds] = unique(b_5_all(:,[1 2]), 'rows');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ahora guardo cada archivo (año/mes)

for i=1:size(groups_u,1)
    
        inds2=inds==i;

        b6=b_5_all(inds2,:);  % vector tiempo del grupo "i"
        multi6=multi_all(:,:,:,inds2);  % datos del grupo "i"
      
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Creo nombres del archivo (año/mes)
        
        b_5_1=sprintf('%04d',b6(1,1)); b_5_2=sprintf('%02d',b6(1,2));
        multi_name=strcat(var_flag2,'_',b_5_1,'_',b_5_2); clear  b_5_1 b_5_2
                       
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % guardo resultados
        
        eval([multi_name '= multi6']);
        multi_name_2=strcat(multi_name,'.mat');
        save(multi_name_2,multi_name,'-v7.3');

        
        % guardo vector tiempo
        t_name=strcat('t_',multi_name);
        eval([t_name '= b6']);
        t_name_2=strcat(t_name,'.mat');
        
        save(t_name_2,t_name,'-v7.3');
        
        %revision final para confirmar y tambien guardo resultados
        %save('rev_final.mat','rev_final'); %debe ser igual a cero para todo OK
        
           
        clear t_name_2 t_name multi_name_2 multi_name multi
        clear v_* u_* s_* t_* t_v_* t_u_* t_s_* t_t_*
        clear b_5 b_10 baseFileName0 clear b_1 ans i
        clear h_*
        clear  inds2  b6  multi6 
        
end



clear dirs2 multi_all


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mkdir finals


var_flag2b=strcat(var_flag2,'_*'); var_flag3b=strcat('t_',var_flag2,'_*');

movefile(var_flag2b,'finals');
movefile(var_flag3b,'finals');
%movefile('rev_final.mat','finals');

cd finals
%guardo resultados completos del analisis
%save('time_n_mat_name.mat','time_n_mat_name');
save('ind_lat.mat','ind_lat');
save('ind_lon.mat','ind_lon');
save('prof_level.mat','prof_level');
save('prof_sub.mat','prof_sub'); %guardo niveles de profundidad del subdominio extraido, en metros
save('lat_sub.mat','lat_sub'); %guardo coordenadas del subdominio extraido
save('lon_sub.mat','lon_sub'); %guardo coordenadas del subdominio extraido
%save('h0_mask.mat','h0_mask'); %guardo mascara de batimetria del subdominio extraido

%informacion adicional

save('ind_lat0.mat','ind_lat0'); %guardo estos indices para que no "me pierda"
save('ind_lon0.mat','ind_lon0'); %guardo estos indices para que no "me pierda"

save('lat_2.mat','lat_2'); %guardo coordenadas completas para que no "me pierda"
save('lon_2.mat','lon_2'); %guardo coordenadas completas para que no "me pierda"
%save('h0.mat','h0'); %guardo batimetria completa para que no "me pierda"

save('ind_lat5.mat','ind_lat5'); %guardo estos indices para que no "me pierda"
save('ind_lon5.mat','ind_lon5'); %guardo estos indices para que no "me pierda"
save('ind_prof4.mat','ind_prof4'); %guardo estos indices para que no "me pierda"
%save('time_3.mat','time_3'); %estos son los grupos en formato "año/mes", en los cuales
%se extrajeron los datos

save('ft4.mat','ft4'); %prodcuto descargado
save('ft5.mat','ft5'); %experimento

%guardo la revision preliminar
save('rev_prel.mat','rev_prel');

%guardo registro de archivos faltantes & sobrantes
save('faltantes.mat','faltantes');
save('sobrantes.mat','sobrantes');

%guardo registro de vector tiempo solicitado vs vector tiempo recuperado en
%los datos
save('tiempo_solicitado.mat','tiempo_solicitado');
save('tiempo_encontrado.mat','tiempo_encontrado');
clear time_2 b_5_all

%guardo esta rutina
% save('opendap_download_rev5b.m'); %experimento

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% creo mascara de batimetria a partir de un archivo procesado

%creo directorio de archivos a leer

ftpobj=pwd;
dirs = dir(ftpobj); 

%condiciono para no elejir carpetas y solo elejir
%archivos
dirFlags = [dirs.isdir]; B = double(dirFlags);
C=B-1; D=C*-1; E=logical(D);  dirFlags=E; clear B C D E
subFolders = dirs(dirFlags);

%ordeno subfolders por su nombre
[~,ndx]=natsortfiles({subFolders.name});
dirs_mask = subFolders(ndx);

clear ndx subFolders dirs dirFlags  subFolders

var_flag3=horzcat(var_flag2,'_');

d4=[];
for i=1:size(dirs_mask)
d1=dirs_mask(i).name;
d2=d1(1:2);

    if d2==var_flag3
        d3=1;
    else
        d3=0;
    end
    d4(i)=d3;
    clear d1 d2 d3 i
   
end
d4=d4';
d5=logical(d4);
dirs_mask2=dirs_mask(d5);
clear d4 d5 dirs_mask

%cargo primer registro
d1=dirs_mask2(1).name;
d2=(d1(1:end-4));
d3=load(d1, d2);
d4=struct2cell(d3);
d5=cell2mat(d4);
d6=d5(:,:,1,1);  % ESTE ES EL NIVEL MAS SOMERO
mask=d6;
save('mask.mat','mask');
clear d1 d2 d3 d4 d5 d6 dirs_mask2

