function Invoke-GoogleUrlShortener{
	[CmdletBinding()]
	param (
	 	[Parameter(Mandatory = $true, ParameterSetName = 'ShortUrl')]
	 	[ValidateNotNullorEmpty()]
	 	[string]$ShortUrl,

	 	[Parameter(Mandatory = $true, ParameterSetName = 'LongUrl', ValueFromPipeline = $true)]
	 	[ValidateNotNullorEmpty()]
	 	[string]$LongUrl,

	 	[Parameter(ParameterSetName = 'ShortUrl')]
	 	[switch]$Expand = $false,

	 	[Parameter()]
	 	[string]$Key = $googleAPIKey
	)

	# define base url
	$url = "https://www.googleapis.com/urlshortener/v1/url"

	if($ShortUrl){
		# update url
		$url += "?shortUrl=$($ShortUrl)"
		if($Expand){$url += "&projection=FULL"}
		# run query and capture result
		$result = Invoke-RestMethod $url
		# write result to the pipeline
		if($Expand){
			Write-Output $result
		}
		else{
			Write-Output $result.longUrl
		}
	}

	if($LongUrl){
		# build body
		$body = "{""longUrl"": ""$longUrl""}"
		# invoke a web request and capture the result
		$result = Invoke-WebRequest -Uri $url -Method 'POST' -ContentType 'application/json' -Body $body
		# write result to the pipeline
		Write-Output ($result.content | ConvertFrom-Json).id
	}
}