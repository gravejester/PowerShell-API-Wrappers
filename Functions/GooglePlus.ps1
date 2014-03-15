function Invoke-GooglePlusPeopleSearch{
	[CmdletBinding()]
	param (
	 	[Parameter(Position = 1, ValueFromPipeline = $true)]
	 	[ValidateNotNullorEmpty()]
	 	[string]$Query,

	 	[Parameter()]
	 	[ValidateRange(1,50)]
	 	[int32]$MaxResults,

	 	[Parameter()]
	 	[string]$Key = $googleAPIKey
	)
	$urlString = "https://www.googleapis.com/plus/v1/people?query=$($Query)&key=$($Key)"
	if($MaxResults){$urlString += "&maxResults=$($MaxResults)"}
	[System.Uri]$url = $urlString
	$result = Invoke-RestMethod $url

	foreach($return in $result.items){
		Write-Output (,([PSCustomObject] [Ordered] @{
			ObjectType = $return.objectType
			ID = $return.id
			DisplayName = $return.displayName
			URL = $return.url
			ImageURL = $return.image.url
		}))
	}
}

function Invoke-GooglePlusPeopleGet{
	[CmdletBinding()]
	param (
	 	[Parameter(Mandatory = $true, ValueFromPipelinebyPropertyName = $true, ValueFromPipeline = $true)]
	 	[ValidateNotNullorEmpty()]
	 	[string]$ID,

	 	[Parameter()]
	 	[string]$Key = $googleAPIKey
	)

	$urlString = "https://www.googleapis.com/plus/v1/people/$($ID)?key=$($Key)"
	[System.Uri]$url = $urlString
	$result = Invoke-RestMethod $url

	Write-Output ([PSCustomObject] [Ordered] @{
		DisplayName = $result.displayName
		Nickname = $result.nickname
		FamilyName = $result.name.familyName
		GivenName = $result.name.givenName
		Gender = $result.gender
		Occupation = $result.occupation
		RelationshipStatus = $result.relationshipStatus
		URLs = $result.urls
		URL = $result.url
		ImageURL = $result.image.url
		ID = $result.id
		IsPlusUser = $result.isPlusUser
		Verified = $result.verified
		CircledBy = $result.circledByCount
		Tagline = $result.tagline
		Organizations = $result.organizations
		PlacesLived = $result.placesLived
		BraggingRights = $result.braggingRights
		AboutMe = $result.aboutMe
	})
}