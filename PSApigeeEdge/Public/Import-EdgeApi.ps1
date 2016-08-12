Function Import-EdgeApi {
    <#
    .SYNOPSIS
        Import an apiproxy from a zip file or directory, into Apigee Edge.

    .DESCRIPTION
        Import an apiproxy from a zip file or directory, into Apigee Edge.

    .PARAMETER Name
        The name to use for the apiproxy, once imported.

    .PARAMETER Source
        The source of the apiproxy bundle to import.

    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Import-EdgeApi -Name oauth2-pwd-cc -Source bundle.zip

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$True)][string]$Name,
        [Parameter(Mandatory=$True)][string]$Source,
        [string]$Org
    )
    
    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
    }

    if (!$PSBoundParameters['Name']) {
      throw [System.ArgumentNullException] "You must specify the -Name option."
    }
    if (!$PSBoundParameters['Source']) {
      throw [System.ArgumentNullException] "You must specify the -Source option."
    }

    if( ! $PSBoundParameters.ContainsKey('Org')) {
      if( ! $MyInvocation.MyCommand.Module.PrivateData['Org']) {
        throw [System.ArgumentNullException] "use the -Org parameter to specify the organization."
      }
      else {
        $Org = $MyInvocation.MyCommand.Module.PrivateData['Org']
      }
    }
    if( ! $MyInvocation.MyCommand.Module.PrivateData['MgmtUri']) {
      throw [System.ArgumentNullException] 'use Set-EdgeConnection to specify the Edge connection information.'
    }
    $MgmtUri = $MyInvocation.MyCommand.Module.PrivateData['MgmtUri']

    if( ! $MyInvocation.MyCommand.Module.PrivateData['SecurePass']) {
      throw [System.ArgumentNullException] 'use Set-EdgeConnection to specify the Edge connection information.'
    }

    $BaseUri = Join-Parts -Separator '/' -Parts $MgmtUri, '/v1/o', $Org, 'apis'

    $IRMParams = @{
        Uri = "${BaseUri}?action=import&name=${Name}"
        Method = 'POST'
        Headers = @{
            Accept = 'application/json'
            'content-type' = 'application/octet-stream'
            Authorization = 'Basic ' + $( Get-EdgeBasicAuth )
        }
        InFile = $Source
    }

    Try {
        $TempResult = Invoke-WebRequest @IRMParams -UseBasicParsing 

        Write-Debug "Raw:`n$($TempResult | Out-String)"
    }
    Catch {
        Throw $_
    }
    Finally {
        Remove-Variable IRMParams
    }
    if ($TempResult.StatusCode -eq 201) {
      ConvertFrom-Json $TempResult.Content
    }
    else {
      $TempResult
    }

}
