Function Delete-EdgeDeveloper {
    <#
    .SYNOPSIS
        Delete an developer app from Apigee Edge.

    .DESCRIPTION
        Delete an developer app from Apigee Edge.

    .PARAMETER Name
        The id or email address of the developer to delete.

    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Delete-EdgeDeveloper -Name dchiesa@example.org

    .EXAMPLE
        Create-EdgeDeveloper

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$True)][string]$Name,
        [string]$Org
    )

    if (!$PSBoundParameters['Name']) {
      throw [System.ArgumentNullException] "Name", 'The -Name parameter is required.'
    }

    $Options = @{ Collection = 'developers'; Name = $Name; }

    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
        $Options['Debug'] = $Debug
    }
    if ($PSBoundParameters['Org']) {
        $Options['Org'] = $Org
    }

    Write-Debug $( [string]::Format("Delete-EdgeDeveloper Options {0}", $(ConvertTo-Json $Options )))
    Delete-EdgeObject @Options
}
