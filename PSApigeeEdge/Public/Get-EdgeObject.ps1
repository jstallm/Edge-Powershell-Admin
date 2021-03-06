Function Get-EdgeObject {
    <#
    .SYNOPSIS
        Get one or more objects from Apigee Edge.

    .DESCRIPTION
        Get one or more objects from Apigee Edge, such as developers, apis, apiproducts.
        This is a lower-level cmdlet. You may want to try the higher-level cmdlets like
        Get-EdgeApi or Get-EdgeDeveloper, etc.

    .PARAMETER Collection
        Type of object to query for.

        Example: 'developers', 'apis', 'caches', or 'apiproducts'

    .PARAMETER Name
        Name of the object to retrieve.

    .PARAMETER Org
        Optional. The Apigee Edge organization.

    .PARAMETER Env
        The Apigee Edge environment. This parameter does not apply to all object types.
        It applies to 'caches' and 'kvms' but not developers or apis.

    .PARAMETER Params
        Hash table with query options for the specific collection type.

    .EXAMPLE
        Get-EdgeObject -Collection developers -Org cap500

        # List developers on Edge organization 'cap500'

    .EXAMPLE
        Get-EdgeObject -Collection developers -Org cap500 -Params @{ expand='true' }

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    PARAM(
        [string]$Collection,
        [string]$Name,
        [string]$Env,
        [string]$Org,
        [Hashtable]$Params
    )

    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
    }

    if( ! $MyInvocation.MyCommand.Module.PrivateData.Connection['MgmtUri']) {
      throw [System.ArgumentNullException] 'MgmtUri', "use Set-EdgeConnection to specify the Edge connection information."
    }
    $MgmtUri = $MyInvocation.MyCommand.Module.PrivateData.Connection['MgmtUri']

    if( ! $PSBoundParameters.ContainsKey('Org')) {
      if( ! $MyInvocation.MyCommand.Module.PrivateData.Connection['Org']) {
        throw [System.ArgumentNullException] 'Org', "use the -Org parameter to specify the organization."
      }
      $Org = $MyInvocation.MyCommand.Module.PrivateData.Connection['Org']
    }

    if($PSBoundParameters['Env']) {
         $PartialPath = Join-Parts -Separator '/' -Parts '/v1/o', $Org, 'e', $Env
    }
    else {
         $PartialPath = Join-Parts -Separator '/' -Parts '/v1/o', $Org
    }

    if($PSBoundParameters['Name']) {
      $BaseUri = Join-Parts -Separator '/' -Parts $MgmtUri, $PartialPath, $Collection, $Name
    }
    else {
      $BaseUri = Join-Parts -Separator '/' -Parts $MgmtUri, $PartialPath, $Collection
    }

    Write-Debug ( "Get-EdgeObject Uri $BaseUri`n" )

    $IRMParams = @{
        Uri = $BaseUri
        Method = 'Get'
        Headers = @{
            Accept = 'application/json'
        }
    }

    Apply-EdgeAuthorization -MgmtUri $MgmtUri -IRMParams $IRMParams

    if($PSBoundParameters.ContainsKey('Params')) {
        $IRMParams.Add( 'Body', $Params )
    }

    Write-Debug ( "Running $($MyInvocation.MyCommand).`n" +
                 "Invoke-RestMethod parameters:`n$($IRMParams | Format-List | Out-String)" )

    Try {
        $TempResult = Invoke-RestMethod @IRMParams
        Write-Debug "Raw:`n$($TempResult | Out-String)"
    }
    Catch {
      # Dig into the exception to get the Response details.
      # Note that value__ is not a typo.
      if ($Throw) {
        Throw $_
      }
      else {
           $Exception = @{
              status = $_.Exception.Response.StatusCode.value__
              description = $_.Exception.Response.StatusDescription
           }
      }
    }
    Finally {
        Remove-Variable IRMParams
    }

    if ($Exception) {
         $Exception
    }
    else {
         $TempResult
    }
}