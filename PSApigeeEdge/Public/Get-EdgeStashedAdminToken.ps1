function Get-EdgeStashedAdminToken
{
    <#
    .SYNOPSIS
        Retrieve a stashed OAuth token for Edge Administration.

    .DESCRIPTION
        Retrieve an OAuth token for Edge Administration, from the stash. This works only with Edge SaaS.
        You must have previously called Set-EdgeConnection to specify the user + password,
        and Get-EdgeAdminToken at some point in the past. If the token is expired, this function returns null.

    .LINK
        Set-EdgeConnection

    .LINK
        Get-EdgeNewAdminToken

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    PARAM()
    PROCESS {
        if ($PSBoundParameters['Debug']) {
            $DebugPreference = 'Continue'
        }
        $MgmtUri = $MyInvocation.MyCommand.Module.PrivateData.Connection['MgmtUri']
        if (! $MgmtUri.Equals("https://api.enterprise.apigee.com") ) {
            Write-Debug ( "Get-EdgeStashedAdminToken MgmtUri not Saas" )
            return $null
        }

        $TokenData = Read-EdgeTokenStash
        if (!$TokenData) {
            Write-Debug ( "Get-EdgeStashedAdminToken Cannot read token stash" )
            return $null
        }

        $User = $MyInvocation.MyCommand.Module.PrivateData.Connection['User']
        if (!$User) {
            throw [System.ArgumentNullException] "There is no User set. Have you called Set-EdgeConnection ?"
        }
        $UserToken = $TokenData.psobject.properties |?{ $_.MemberType -eq 'NoteProperty' -and $_.Name -eq $User }
        if ( ($UserToken -eq $null) -or $( Get-EdgeTokenIsExpired $UserToken )) {
            Write-Debug ( "Get-EdgeStashedAdminToken Token is null or Expired" )
            return $null
        }

        $UserToken
    }
}
