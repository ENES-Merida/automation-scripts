# This script is used to download current hindcast data from www.hycom.org 
# Result directory
# --------------------------------------------------------
$resultDirectory = $PSScriptRoot + "\Data"
If (!(test-path $resultDirectory))
{
    md $resultDirectory
}
# Input
# -------------------------------------------------------
# Select coordinate for region of interest
# Location: Latitude 6° 20' S , Longitude: 11° 15' E
#East
$east = 11.30
#West
$west = 11.25
#South
$south = -6.33
#North
$north = -6.31
$date_start = '01-Jan-1994 12:00:00'
$date_end = '31-Jan-1994 23:00:00' 
# --------------------------------------------------------
# Converting dates to datetime
$startDate = [datetime]::ParseExact($date_start,'dd-MMM-yyyy HH:mm:ss',$null)
$endDate = [datetime]::ParseExact($date_end,'dd-MMM-yyyy HH:mm:ss',$null)
Write-Host "Downloading data from " $startDate.ToString('yyyy-MM-ddTHH:mm:ssZ') " to "  $endDate.ToString('yyyy-MM-ddTHH:mm:ssZ')
for ($time = $startDate; $time -le $endDate; $time=$time.AddHours(3)){
$error_flag = 1
while ($error_flag -eq 1){
	
	# Example url. Do not delete. Used for date time format reference purposes
	#$url = "http://ncss.hycom.org/thredds/ncss/GLBv0.08/expt_53.X/data/2015?var=water_u&var=water_v&north=8.6&west=-57.3&east=-57.25&south=8.5&time=2015-01-01T18:00:00Z&accept=netcdf4" 
	# Download url
	$url = "http://ncss.hycom.org/thredds/ncss/GLBv0.08/expt_53.X/data/" + $time.ToString('yyyy') + "?var=water_u&var=water_v&north=" + $north.ToString() + "&west=" + $west.ToString() + "&east=" + $east.ToString() + "&south=" + $south.ToString() + "&time=" + $time.ToString('yyyy-MM-ddTHH:mm:ssZ') + "&accept=netcdf4"
	# Output file name
	$fileName = $time.ToString('yyyyMMdd_HH') + ".nc"
	$output = $PSScriptRoot + "\Data\" + $fileName
	Try{
		# Creating a web client which has the download file functionality
		#WebProxy = New-Object System.Net.WebProxy("hoeprx01.na.xom.com:8080",$true)
		$WebClient = New-Object System.Net.WebClient
		#$WebClient.Proxy=$WebProxy
		$WebClient.DownloadFile($url,$output)
		Write-Host "Successfully downloaded file:"  $fileName
		
		$error_flag = 0
	}
	Catch {
		Write-Host $_.Exception.Message`n
		$error_flag = 1
		Write-Host  "Retrying downloading file:" $fileName " ...."
	}
}
}
