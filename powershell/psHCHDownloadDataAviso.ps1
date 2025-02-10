# PowerShell script usado para descargar datos desde www.hycom.org
# ----------------------------------------------------------------
# Directorio donde se descargan los datos
#
$nombreDirectorio = "ArchivosDescargados"
$directorioDeDescarga = $PSScriptRoot + "\" + $nombreDirectorio
If (!(Test-Path $directorioDeDescarga))
{
	mkdir $directorioDeDescarga
}
# ----------------------------------------------------------------
# Autentificaci'on
# 
$usuario = "imarinotapia@gmail.com"
$contrasenia = "aZtDIU"
# ----------------------------------------------------------------
# Configuraci'on de la url de descarga
# ----------------------------------------------------------------
#
# Rango de fechas
$fechaInicial = '01-1993'
#
$fechaFinal = '08-1998'
#
# Convertir fechas a formato datetime
$fechaInicia = [datetime]::ParseExact($fechaInicial, 'MM-yyyy', $null)
#
$fechaTermina = [datetime]::ParseExact($fechaFinal, 'MM-yyyy', $null)
#
Write-Host "Descargando datos desde " $fechaInicia.ToString('MMM-yyyy') " hasta " $fechaTermina.ToString('MMM-yyyy')
#
# Crear un cliente web que tiene la funci'on de descargar el archivo desde la URL.
$httpClientHandler = [System.Net.Http.HttpClientHandler]::new()
$httpClientHandler.Credentials = New-Object System.Net.NetworkCredential($usuario, $contrasenia)
$webClient = [System.Net.Http.HttpClient]::new($httpClientHandler)
$webClient.Timeout = [System.TimeSpan]::FromSeconds(30)
#
for ($year = $fechaInicia.Year; $year -le $fechaTermina.Year; $year++) {
	$startMonth = ($year -eq $fechaInicia.Year) ? $fechaInicia.Month : 1
	$endMonth = ($year -eq $fechaTermina.Year) ? $fechaTermina.Month : 12
	for ($month = $startMonth; $month -le $endMonth; $month++) {
		$banderaError = 1
		$fechaActual = $month.ToString("00") + "-" + $year
		$fecha = [datetime]::ParseExact($fechaActual, 'MM-yyyy', $null)
		while ($banderaError -eq 1) {
			# URL de ejemplo. No eliminar. Utilizado para referencia.
			# $url = "https://tds.aviso.altimetry.fr/thredds/fileServer/dataset-duacs-climatology-global/delayed-time/monthly_mean/msla_h/dt_global_allsat_msla_h_y1993_m01.nc"
			$url = "https://tds.aviso.altimetry.fr/thredds/fileServer/dataset-duacs-climatology-global/delayed-time/monthly_mean/msla_h/dt_global_allsat_msla_h_y" + $fecha.ToString('yyyy') + "_m" + $fecha.ToString('MM') + ".nc"
			# Nombre del archivo descargado
			$nombreArchivo = "dt_global_allsat_msla_h_y" + $fecha.ToString('yyyy') + "_m" + $fecha.ToString('MM') + ".nc"
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
}
# ----------------------------------------------------------------
#
