function Invoke-FreebaseSearch{
	[CmdletBinding()]
	param (
	 	[Parameter(Position = 1)]
	 	[string]$Query,

	 	[Parameter()]
	 	[string]$Filter,

	 	[Parameter()]
	 	[string]$Type,

	 	[Parameter()]
	 	[string]$Domain,

	 	[Parameter()]
	 	[string]$Output,

	 	[Parameter()]
	 	[switch]$Exact = $false,

	 	[Parameter()]
	 	[int32]$Limit,

	 	[Parameter()]
	 	[ValidateNotNullorEmpty()]
	 	[string]$Key = $googleAPIKey
	)

	# check that we are using at least one of either the Query or the Filter parameter
	if(-not $Query -and -not $Filter){ Write-Warning 'All parameters are optional but you must have one of either Query or Filter.' }

	# define the main url string
	$urlString = "https://www.googleapis.com/freebase/v1/search?query=$($Query)&key=$($Key)&spell=always"

	# add any additional parameters to the url string
	if($Filter)	{ $urlString += "&filter=$($Filter)" }
	if($Type)	{ $urlString += "&type=$($Type)" }
	if($Limit)	{ $urlString += "&limit=$($Limit)" }
	if($Domain)	{ $urlString += "&domain=$($Domain)" }
	if($Exact)	{ $urlString += "&exact=true" }
	if($Output)	{ $urlString += "&output=$($Output)" }

	# encode the url string
	[System.Uri]$url = $urlString

	# run query and catch the result
	$result = Invoke-RestMethod $url

	# write the result to the pipeline
	Write-Output $result
}

function Invoke-FreebaseTopic{
	[CmdletBinding()]
	param (
	 	[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelinebyPropertyName = $true)]
	 	[string]$ID,

	 	[Parameter()]
	 	[string]$Filter = "suggest",

	 	[Parameter()]
	 	[int32]$Limit,

	 	[Parameter()]
	 	[switch]$AutoExpandProperty = $true,

	 	[Parameter()]
	 	[ValidateNotNullorEmpty()]
	 	[string]$Key = $googleAPIKey
	)

	# define the main url string
	$urlString = "https://www.googleapis.com/freebase/v1/topic$($ID)"

	# add any additional parameters to the url string
	if($Filter)	{ $urlString += "?filter=$($Filter)" }
	if($Limit)	{ $urlString += "&limit=$($Limit)" }

	# add the API key to the url string
	$urlString += "&key=$($Key)"

	# encode the url string
	[System.Uri]$url = $urlString

	# run the query and catch the result
	$result = Invoke-RestMethod $url

	# write the result to the pipeline
	if($AutoExpandProperty){
		Write-Output $result | Select-Object -ExpandProperty 'property'
	}
	else{
		Write-Output $result
	}
}

function Invoke-FreebaseImage{
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelinebyPropertyName = $true)]
		[string]$ID
	)

	# define the url string
	$url = "https://usercontent.googleapis.com/freebase/v1/image$($ID)"

	# run the query and catch the result
	$result = Invoke-WebRequest $url

	# write the result to the pipeline
	Write-Output $result
}

function Invoke-FreebaseMqlRead{
	[CmdletBinding()]
	param (
	 	[Parameter(Mandatory = $true)]
	 	[String]$Query,

	 	[Parameter()]
	 	[string]$AsOfTime,

	 	[Parameter()]
	 	[switch]$AutoExpandResult = $true,

	 	[Parameter()]
	 	[ValidateNotNullorEmpty()]
	 	[string]$Key = $googleAPIKey
	)

	# define the main url string
	$urlString = "https://www.googleapis.com/freebase/v1/mqlread?query=$($Query)&key=$($Key)"

	# add any additional parameters to the url string
	if($AsOfTime)	{ $urlString += "&as_of_time=$($AsOfTime)" }

	# encode the url string
	[System.Uri]$url = $urlString

	# run the query and catch the result
	$result = Invoke-RestMethod $url

	# write the result to the pipeline
	if($AutoExpandResult){
		Write-Output $result.result
	}
	else{
		Write-Output $result
	}
}

function Invoke-FreebaseReconciliation{
	[CmdletBinding()]
	param (
	 	[Parameter()]
	 	[string]$Name,

	 	[Parameter()]
	 	[string]$Kind,

	 	[Parameter()]
	 	[string]$Prop,

	 	[Parameter()]
	 	[int32]$Limit,

	 	[Parameter()]
	 	[ValidateRange(0.5,1.0)]
	 	[double]$Confidence,

	 	[Parameter()]
	 	[ValidateNotNullorEmpty()]
	 	[string]$Key = $googleAPIKey
	)

	# define the main url string
	$urlString = "https://www.googleapis.com/freebase/v1/reconcile?name=$($Name)&key=$($Key)"

	# add any additional parameters to the url string
	if($Kind)		{ $urlString += "&kind=$($Kind)" }
	if($Prop)		{ $urlString += "&prop=$($Prop)" }
	if($Limit)		{ $urlString += "&limit=$($Limit)" }
	if($Confidence)	{ $urlString += "&confidence=$($Confidence)" }

	# encode the url string
	[System.Uri]$url = $urlString

	# run the query and catch the result
	$result = Invoke-RestMethod $url

	# write the result to the pipeline
	Write-Output $result
}