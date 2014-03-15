function Invoke-GoogleTranslate{
	[CmdletBinding()]
	param (
	 	[Parameter(Mandatory = $true, Position = 1, ValueFromPipeline = $true)]
	 	[ValidateNotNullorEmpty()]
	 	[string]$Text,

	 	[Parameter()]
	 	[ValidateNotNullorEmpty()]
	 	[string]$TargetLanguage = 'en',

	 	[Parameter()]
	 	[string]$SourceLanguage,

	 	[Parameter()]
	 	[ValidateSet('text','html')]
	 	[string]$Format = 'text',

	 	[Parameter()]
	 	[ValidateNotNullorEmpty()]
	 	[string]$Key = $googleAPIKey
	)

	$url = "https://www.googleapis.com/language/translate/v2?key=$($Key)&target=$($TargetLanguage)&q=$($Text)"
	if($SourceLanguage){$url += "&source=$($SourceLanguage)"}
	$result = Invoke-RestMethod $url
	Write-Output $result.data.translations
}

function Get-GoogleTranslateLanguages{
	[CmdletBinding()]
	param (
		[Parameter()]
		[string]$TargetLanguage = 'en',

	 	[Parameter()]
	 	[string]$Key = $googleAPIKey
	)
	$url = "https://www.googleapis.com/language/translate/v2/languages?key=$($Key)&target=$($TargetLanguage)"
	$result = Invoke-RestMethod $url
	Write-Output $result.data.languages
}

function Invoke-GoogleTranslateDetectLanguage{
	[CmdletBinding()]
	param (
	 	[Parameter()]
	 	[string]$Text,

	 	[Parameter()]
	 	[string]$Key = $googleAPIKey
	)
	$url = "https://www.googleapis.com/language/translate/v2/detect?key=$($Key)&q=$($Text)"
	$result = Invoke-RestMethod $url
	Write-Output $result.data.detections
}