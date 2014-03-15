function Invoke-GoogleGeocodeLookup{
	[CmdletBinding(DefaultParameterSetName = 'address')]
	param (
	 	[Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'address')]
	 	[string]$Address,

	 	[Parameter(Mandatory = $true, ParameterSetName = 'latlong')]
	 	[ValidatePattern({^(\-?\d+(\.\d+)?)$})]
	 	[string]$Latitude,

	 	[Parameter(Mandatory = $true, ParameterSetName = 'latlong')]
	 	[ValidatePattern({^(\-?\d+(\.\d+)?)$})]
	 	[string]$Longitude,

	 	[Parameter(HelpMessage = 'Enter a ccTLD to specify the region bias for the query. Default is "us"', ParameterSetName = 'address')]
	 	[ValidatePattern({^[a-zA-Z]{2}$})]
	 	[string]$RegionBias = 'us',

	 	[Parameter(HelpMessage = 'Indicates whether or not the geocoding request comes from a device with a location sensor')]
	 	[ValidateNotNull()]
	 	[switch]$Sensor = $false,

	 	[Parameter(HelpMessage = 'Google API Key')]
	 	[string]$Key = $googleAPIKey,

	 	[Parameter()]
	 	[ValidateSet('http','https')]
	 	[string]$Protocol = 'http',

	 	[Parameter()]
	 	[switch]$ReturnRawData = $false,

	 	[Parameter()]
	 	[ValidateSet('json','xml')]
	 	[string]$RawDataFormat = 'json'
	)

	# if address parameter is used, perform regular geocode lookup
	if($address){
		# convert address into url-friendly format and build the final url string
		$convertedAddress = $Address.Replace(" ","+")
		$url = "$($Protocol.ToLower())://maps.googleapis.com/maps/api/geocode/$($RawDataFormat.ToLower())?address=$($convertedAddress)&sensor=$($Sensor.ToString().ToLower())&region=$($RegionBias)&key=$($Key)"
	}
	# else, perform a reversed geocode lookup
	else{
		# concatenate latitude and longitude and build the final url string
		$latlng = "$($Latitude),$($Longitude)"
		$url = "$($Protocol.ToLower())://maps.googleapis.com/maps/api/geocode/$($RawDataFormat.ToLower())?latlng=$($latlng)&sensor=$($Sensor.ToString().ToLower())&key=$($Key)"
	}

	# perform query
	$result = Invoke-RestMethod -Uri $url

	# if raw data is what they want, raw data they will get
	if($ReturnRawData){
		Write-Output $result
	}

	else{
		if($result.Status -eq 'OK'){
			foreach ($return in $result.results){
				Write-Output  (,([PSCustomObject] [Ordered] @{
					FormattedAddress     = $return.formatted_address
					StreetNumber         = ($return.address_components | Where-Object {$_.types -eq 'street_number'}).long_name
					StreetAddress        = ($return.address_components | Where-Object {$_.types -eq 'street_address'}).long_name
					Floor                = ($return.address_components | Where-Object {$_.types -eq 'floor'}).long_name
					Route                = ($return.address_components | Where-Object {$_.types -eq 'route'}).long_name
					Establishment        = ($return.address_components | Where-Object {$_.types -eq 'establishment'}).long_name
					Sublocality          = ($return.address_components | Where-Object {$_.types -eq 'sublocality'}).long_name
					Locality             = ($return.address_components | Where-Object {$_.types -eq 'locality'}).long_name
					AdministrativeAreaL2 = ($return.address_components | Where-Object {$_.types -eq 'administrative_area_level_2'}).long_name
					AdministrativeAreaL1 = ($return.address_components | Where-Object {$_.types -eq 'administrative_area_level_1'}).long_name
					Country              = ($return.address_components | Where-Object {$_.types -eq 'country'}).long_name
					PostalCode           = ($return.address_components | Where-Object {$_.types -eq 'postal_code'}).long_name
					PostalTown           = ($return.address_components | Where-Object {$_.types -eq 'postal_town'}).long_name
					Latitude             = $return.geometry.location.lat
					Longitude            = $return.geometry.location.lng
					LocationType         = $return.geometry.location_type
					PartialMatch         = $return.partial_match
				}))
			}
		}
		# the different types of status codes that can return other than ok
		elseif($result.Status -eq 'ZERO_RESULTS'){
			Write-Host "Your search for '$($Address)' returned zero results."
		}
		elseif($result.Status -eq 'OVER_QUERY_LIMIT'){
			Write-Warning 'You are over you quota.'
		}
		elseif($result.Status -eq 'REQUEST_DENIED'){
			Write-Warning 'Request denied!'
		}
		elseif($result.Status -eq 'INVALID_REQUEST'){
			Write-Warning 'Invalid request'
		}
		elseif($result.Status -eq 'UNKNOWN_ERROR'){
			Write-Warning 'Request could not be processed due to a server error. Please try again.'
		}
		else{
			Write-Warning 'Something went wrong! Try running the command with the ReturnRawData switch to see if any additional error messages were sent back from the server.'
		}
	}
}

function Invoke-GoogleTimeZoneLookup{
	[CmdletBinding()]
	param (
	 	[Parameter(Mandatory = $true, ValueFromPipelinebyPropertyName = $true)]
	 	[ValidatePattern({^(\-?\d+(\.\d+)?)$})]
	 	[string]$Latitude,

	 	[Parameter(Mandatory = $true, ValueFromPipelinebyPropertyName = $true)]
	 	[ValidatePattern({^(\-?\d+(\.\d+)?)$})]
	 	[string]$Longitude,

	 	[Parameter()]
	 	[string]$TimeStamp = ((get-date (get-date).touniversaltime() -uformat "%s").Split(",")[0]),

	 	[Parameter(HelpMessage = 'Indicates whether the application requesting data is using a sensor (such as a GPS device) to determine the user''s location')]
	 	[ValidateNotNull()]
	 	[switch]$Sensor = $false,

	 	[Parameter(HelpMessage = 'Google API Key')]
	 	[string]$Key = $googleAPIKey,

	 	[Parameter()]
	 	[switch]$ReturnRawData = $false,

	 	[Parameter()]
	 	[ValidateSet('json','xml')]
	 	[string]$RawDataFormat = 'json'
	)

	$latlng = "$($Latitude),$($Longitude)"
	$url = "https://maps.googleapis.com/maps/api/timezone/$($RawDataFormat.ToLower())?location=$($latlng)&timestamp=$($TimeStamp)&sensor=$($Sensor.ToString().ToLower())&key=$($Key)"

	$result = Invoke-RestMethod -Uri $url

	Write-Output $result
}