# PowerShell script usado para descargar datos desde www.hycom.org
# ----------------------------------------------------------------
# Directorio donde se descargan los datos
#
$nombreDirectorio = "datosDescargados"
$directorioDeDescarga = $PSScriptRoot + "\" + $nombreDirectorio
If (!(Test-Path $directorioDeDescarga))
{
	mkdir $directorioDeDescarga
}
# ----------------------------------------------------------------
# Configuraci'on de la url de descarga
# ----------------------------------------------------------------
# Seleccionar las coordenadas para la regi'on de interes
# Locaci'on: Latitude 6 20' S, Longitud: 11 15' E
#
# East
$east = 11.30
# West
$west = 11.25
# South
$south = -6.33
# North
$north = -6.31
#
# Rango de fechas
$fechaInicial = '01-Jan-1994 12:00:00'
#
$fechaFinal = '31-Jan-1994 23:00:00'
#
# Convertir fechas a formato datetime
$fechaInicia = [datetime]::ParseExact($fechaInicial, 'dd-MMM-yyyy HH:mm:ss', $null)
#
$fechaTermina = [datetime]::ParseExact($fechaFinal, 'dd-MMM-yyyy HH:mm:ss', $null)
#
Write-Host "Descargando datos desde " $fechaInicia.ToString('yyyy-MM-ddTHH:mm:ssZ') " hasta " $fechaTermina.ToString('yyyy-MM-ddTHH:mm:ssZ')
#
# Crear un cliente web que tiene la funci'on de descargar el archivo desde la URL.
$httpClientHandler = [System.Net.Http.HttpClientHandler]::new()
$webClient = [System.Net.Http.HttpClient]::new($httpClientHandler)
$webClient.Timeout = [System.TimeSpan]::FromSeconds(30)
#
for ($fecha = $fechaInicia; $fecha -le $fechaTermina; $fecha = $fecha.AddHours(3)) {
	$banderaError = 1
	while ($banderaError -eq 1) {
		# URL de ejemplo. No eliminar. Utilizado para referencia de formato de fecha y hora.
		# $url = "http://ncss.hycom.org/thredds/ncss/GLBv0.08/expt_53.X/data/2015?var=water_u&var=water_v&north=8.6&west=-57.3&east=-57.25&south=8.5&time=2015-01-01T18:00:00Z&accept=netcdf4"
		$url = "http://ncss.hycom.org/thredds/ncss/GLBv0.08/expt_53.X/data/" + $fecha.ToString('yyyy') + "?var=water_u&var=water_v&north=" + $north.ToString() + "&west=" + $west.ToString() + "&east=" + $east.ToString() + "&south=" + $south.ToString() + "&time=" + $fecha.ToString('yyyy-MM-ddTHH:mm:ssZ') + "&accept=netcdf4"
		# Nombre del archivo descargado
		$nombreArchivo = $fecha.ToString('yyyyMMdd_HH') + ".nc"
		$rutaDeSalida = $PSScriptRoot + "\" + $nombreDirectorio + "\" + $nombreArchivo
		#
		Try {
			# Descargar y guardar los datos de la URL.
			$respuesta = $webClient.GetAsync([System.Uri]::new($url)).Result
			if ($respuesta.IsSuccessStatusCode) {
				 # Guardar el contenido en el archivo de salida
				[System.IO.File]::WriteAllBytes($rutaDeSalida, $respuesta.Content.ReadAsByteArrayAsync().Result)
				Write-Host "Se ha descargado exitosamente:" $nombreArchivo
				$banderaError = 0
			} else {
				#Write-Host "Error en la petición: Código de estado" $respuesta.StatusCode
				#Write-Host "Mensaje de Error:" $respuesta.ReasonPhrase
				Write-Host "Error al intentar acceder al servidor. Intentando descargar nuevamente el archivo:" $nombreArchivo " ..."
				Start-Sleep -Seconds 5 # Pausa antes de reintentar
			}
		}
		Catch {
			Write-Host $_.Exception.Message`n
			$banderaError = 1
			Write-Host "Intentando descargar nuevamente el archivo:" $nombreArchivo " ..."
			Start-Sleep -Seconds 5 # Pausa antes de reintentar
		}
	}
}
# ----------------------------------------------------------------
#
