function Invoke-SpotifySearch{
	<#
	.SYNOPSIS
	Search Spotify for Artists, Albums or Tracks.

	.DESCRIPTION
	Search Spotify for Artists, Albums or Tracks. This function leverages the public
	Spotity API for searching through all of the data made available for this purpose.

	.PARAMETER Artist
	Use this parameter to search for artists in Spotify

	.PARAMETER Album
	Use this parameter to search for albums in Spotify

	.PARAMETER Track
	Use this parameter to search for tracks in Spotify

	.PARAMETER Page
	For large datasets the results are paged. Use this parameter to
	indicate what page you want returned.

	.EXAMPLE
	Invoke-SpotifySearch 'Madonna'

	Description
	------------------
	Search for any artists called 'Madonna'

	.EXAMPLE
	Invoke-SpotifySearch -Album 'Dark Side of the Moon'

	Description
	------------------
	Search for any albums called 'Dark Side of the Moon'

	.EXAMPLE
	Invoke-SpotifySearch -Track 'Hymn'

	Description
	------------------
	Search for any tracks called 'Hymn'

	.NOTES
	Name: Invoke-SpotifySearch
	Author: Øyvind Kallstad
	Date: 15.03.2014

	.LINK
	https://github.com/gravejester/PowerShell-API-Wrappers
	#>
	[CmdletBinding(DefaultParameterSetName = 'Artist')]
	param (
	 	[Parameter(HelpMessage = 'Artist to search for', Position = 1, Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'Artist')]
	 	[ValidateNotNullorEmpty()]
	 	[string]$Artist,

	 	[Parameter(HelpMessage = 'Album to search for', Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'Album')]
	 	[ValidateNotNullorEmpty()]
	 	[string]$Album,

	 	[Parameter(HelpMessage = 'Track to search for', Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'Track')]
	 	[ValidateNotNullorEmpty()]
	 	[string]$Track,

	 	[Parameter(HelpMessage = 'What page to show when data returned are paged')]
	 	[int]$Page
	)

	# define base url string
	$urlString = "https://ws.spotify.com/search/1/"

	# handle parameters
	if ($Artist)	{ $urlString += "artist?q=$($Artist)" }
	if ($Album)		{ $urlString += "album?q=$($Album)" }
	if ($Track)		{ $urlString += "track?q=$($Track)" }
	if( $Page)		{ $urlString += "&page=$($Page)" }

	# encode url
	[System.Uri]$url = $urlString

	# run query and catch results
	$result = Invoke-RestMethod $url

	# handle results and output to pipeline
	if($Artist){
		foreach($a in $result.artists.artist){
			$outputObject = ([PSCustomObject] [Ordered] @{
				ID = $a.href
				Name = $a.name
				Popularity = $a.popularity
			})
			# define default display set and write output to pipeline
			$defaultDisplaySet = 'Name','Popularity'
			$defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet',[string[]]$defaultDisplaySet)
			$PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
			$outputObject | Add-Member MemberSet PSStandardMembers $PSStandardMembers
			Write-Output $outputObject
		}
	}

	if($Album){
		foreach($a in $result.albums.album){
			$outputObject = ([PSCustomObject] [Ordered] @{
				ID = $a.href
				Name = $a.name
				Artist = $a.artist.name
				Popularity = $a.popularity
				Availability = $a.availability.territories
			})
			# define default display set and write output to pipeline
			$defaultDisplaySet = 'Name','Artist','Popularity'
			$defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet',[string[]]$defaultDisplaySet)
			$PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
			$outputObject | Add-Member MemberSet PSStandardMembers $PSStandardMembers
			Write-Output $outputObject
		}
	}

	if($Track){
		foreach($t in $result.tracks.track){
			$outputObject = ([PSCustomObject] [Ordered] @{
				ID = $t.href
				Name = $t.name
				Artist = $t.artist.name
				Album = $t.album.name
				TrackNo = $t.'track-number'
				Length = [Math]::Round(((New-Timespan -Seconds $t.length).TotalMinutes),2)
				Popularity = $t.popularity
			})
			# define default display set and write output to pipeline
			$defaultDisplaySet = 'Name','Artist','Album','TrackNo','Length','Popularity'
			$defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet',[string[]]$defaultDisplaySet)
			$PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
			$outputObject | Add-Member MemberSet PSStandardMembers $PSStandardMembers
			Write-Output $outputObject
		}
	}
}

function Invoke-SpotifyLookup{
	<#
	.SYNOPSIS
	Look up Spotify data.

	.DESCRIPTION
	Lookup Spotify data. Use together with Invoke-SpotifySearch to get the ID
	of the element you want to look up.

	.PARAMETER ID
	The unique ID of the data entity you want to look up. Use Invoke-SpotifySearch to find the ID.

	.EXAMPLE
	Invoke-SpotifySearch -Artist 'Madonna' | Select-Object -First 1 | Invoke-SpotifyLookup

	Description
	------------------
	Search for any artists called 'Madonna', select the first one and get available data.
	The data returned in this example is all Madonnas released albums as known by Spotify.

	.EXAMPLE
	Invoke-SpotifySearch -Album 'Dark Side of the Moon' | Select-Object -First 1 | Invoke-SpotifyLookup

	Description
	------------------
	Search for any album called 'Dark Side of the Moon', select the first one and get available data.
	The data returned are the name of the album and the artist(s), as well as a full track listing but
	also the availability of the album in Spotify.

	.NOTES
	Name: Invoke-SpotifyLookup
	Author: Øyvind Kallstad
	Date: 15.03.2014

	.LINK
	https://github.com/gravejester/PowerShell-API-Wrappers
	#>
	[CmdletBinding()]
	param (
	 	[Parameter(Position = 1, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelinebyPropertyName = $true)]
	 	[string]$ID
	)

	# define base url string
	$urlString = "https://ws.spotify.com/lookup/1/?uri=$($ID)"

	# get type of id
	$idType = $ID.Split(":")[1]

	# handle parameters
	if($idType -eq 'artist'){$urlString += "&extras=albumdetail"}
	if($idType -eq 'album')	{$urlString += "&extras=trackdetail"}

	# encode url
	[System.Uri]$url = $urlString

	# run query and catch results
	$result = Invoke-RestMethod $url

	# handle results and output to pipeline
	if($idType -eq 'track'){
		# create the output object
		$outputObject = ([PSCustomObject] [Ordered] @{
			Name = $result.track.name
			Artist = $result.track.artist.name
			Album = $result.track.album.name
			Available = $result.track.available
			TrackNo = $result.track.'track-number'
			Length = [Math]::Round(((New-Timespan -Seconds $result.track.length).TotalMinutes),2)
			Popularity = $result.track.popularity
		})
		# write the output to the pipeline
		Write-Output $outputObject
	}

	if($idType -eq 'album'){
		$albumTracks = @()
		foreach($albumTrack in $result.album.tracks.track){
			# create a albumTrack object
			$albumTrackObject = ([PSCustomObject] [Ordered] @{
				ID = $albumTrack.href
				Name = $albumTrack.name
				Artist = $albumTrack.artist.name
				Available = $albumTrack.available
				DiscNo = $albumTrack.'disc-number'
				TrackNo = $albumTrack.'track-number'
				Length = [Math]::Round(((New-Timespan -Seconds $albumTrack.length).TotalMinutes),2)
				Popularity = $albumTrack.popularity
			})
			# define default display set and add it to the object
			$defaultDisplaySet = 'Name','Artist','DiscNo','TrackNo','Length','Popularity'
			$defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet',[string[]]$defaultDisplaySet)
			$PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
			$albumTrackObject | Add-Member MemberSet PSStandardMembers $PSStandardMembers
			# overload the ToString method
			$albumTrackObject | Add-Member -MemberType 'ScriptMethod' -Name 'ToString' -Value {$this.Name} -Force
			# add the object to the albumTracks collection
			$albumTracks += $albumTrackObject
		}
		# create the output object
		$outputObject = ([PSCustomObject] [Ordered] @{
			Name = $result.album.name
			Artist = $result.album.artist.name
			Released = $result.album.released
			Availability = $result.album.availability.territories
			Tracks = $albumTracks
		})
		# write the output object to the pipeline
		Write-Output $outputObject
	}

	if($idType -eq 'artist'){
		$albums = @()
		foreach($artistAlbum in $result.artist.albums.album){
			# create albums object
			$albumsObject = ([PSCustomObject] [Ordered] @{
				ID = $artistAlbum.href
				Name = $artistAlbum.name
				Artist = $artistAlbum.artist.name
				Released = $artistAlbum.released
				Availability = $artistAlbum.availability.territories
			})
			# define default display set and add it to the object
			$defaultDisplaySet = 'Name','Artist','Released'
			$defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet',[string[]]$defaultDisplaySet)
			$PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
			$albumsObject | Add-Member MemberSet PSStandardMembers $PSStandardMembers
			# overload the ToString method
			$albumsObject | Add-Member -MemberType 'ScriptMethod' -Name 'ToString' -Value {$this.Name} -Force
			# add the object to the albums collections
			$albums += $albumsObject
		}
		# create the output object
		$outputObject = ([PSCustomObject] [Ordered] @{
			Artist = $result.artist.name
			Albums = $albums
		})
		# write the output to the pipeline
		Write-Output $outputObject
	}
}