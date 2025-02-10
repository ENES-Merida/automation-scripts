# PowerShell script usado para descargar datos desde www.hycom.org
# ----------------------------------------------------------------
# Directorio donde se descargan los datos
#
$directorioDeDescarga = $PSScriptRoot + "\datosDescargados"
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
$fechaInicial = '16-Jan-1994 18:00:00'
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
for ($fecha = $fechaInicia; $fecha -le $fechaTermina; $fecha = $fecha.AddHours(3)) {
	$banderaError = 1
	while ($banderaError -eq 1) {
		# URL de ejemplo. No eliminar. Utilizado para referencia de formato de fecha y hora.
		# $url = "http://ncss.hycom.org/thredds/ncss/GLBv0.08/expt_53.X/data/2015?var=water_u&var=water_v&north=8.6&west=-57.3&east=-57.25&south=8.5&time=2015-01-01T18:00:00Z&accept=netcdf4"
		$url = "http://ncss.hycom.org/thredds/ncss/GLBv0.08/expt_53.X/data/" + $fecha.ToString('yyyy') + "?var=water_u&var=water_v&north=" + $north.ToString() + "&west=" + $west.ToString() + "&east=" + $east.ToString() + "&south=" + $south.ToString() + "&time=" + $fecha.ToString('yyyy-MM-ddTHH:mm:ssZ') + "&accept=netcdf4"
		# Nombre del archivo descargado
		$nombreArchivo = $fecha.ToString('yyyyMMdd_HH') + ".nc"
		$rutaDeSalida = $PSScriptRoot + "\datosDescargados\" + $nombreArchivo
		#
		Try {
			Invoke-WebRequest -Uri $url -OutFile $rutaDeSalida
			$banderaError = 0
			Write-Host "El archivo " $nombreArchivo "se ha descargado."
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
