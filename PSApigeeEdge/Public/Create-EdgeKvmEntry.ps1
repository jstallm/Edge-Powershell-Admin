Function Create-EdgeKvmEntry {
    <#
    .SYNOPSIS
        Create a named entry in an existing key-value map in Apigee Edge.

    .DESCRIPTION
        Create a named entry in an existing key-value map in Apigee Edge.
        The KVM must exist, and the entry must not exist. This works only on CPS-enabled organizations.

    .PARAMETER Name
        Required. The name of the key-value map, in which the entry exists. 

    .PARAMETER Entry
        Required. The name (or key) of the value to create.

    .PARAMETER Value
        Required. A string value to use for the entry.
          
    .PARAMETER Env
        Optional. A string, the name of the environment with which the key-value map is
        associated. KVMs can be associated to an organization, an environment, or an API Proxy.
        If you specify neither Env nor Proxy, the Name will be resolved in the list of
        organization-wide Key-Value Maps.

    .PARAMETER Proxy
        Optional. A string, the API Proxy within Apigee Edge with which the key-value map is
        associated. KVMs can be associated to an organization, an environment, or an API Proxy.
        If you specify neither Env nor Proxy, the Name will be resolved in the list of 
        organization-wide Key-Value Maps.

    .PARAMETER Org
        Optional. The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Create-EdgeKvmEntry -Name kvm101 -Env test -Entry newkey1 -Value 'newly created value'

    .EXAMPLE
        Create-EdgeKvmEntry -Name kvm102 -Proxy api1 -Entry key1 -Value 'value for proxy-specific KVM'

    .LINK
        Delete-EdgeKvmEntry

    .LINK
        Update-EdgeKvmEntry

    .FUNCTIONALITY
        ApigeeEdge
    #>

    [cmdletbinding()]
    PARAM(
        [Parameter(Mandatory=$True)][string]$Name,
        [Parameter(Mandatory=$True)][string]$Entry,
        [Parameter(Mandatory=$True)][string]$Value,
        [string]$Env,
        [string]$Proxy,
        [string]$Org
    )
    
    $Options = @{ }
    
    if ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
        $Options.Add( 'Debug', $Debug )
    }
    if ($PSBoundParameters['Org']) {
        $Options.Add( 'Org', $Org )
    }

    if ($PSBoundParameters.ContainsKey('Env') -and $PSBoundParameters.ContainsKey('Proxy')) {
        throw [System.ArgumentException] "You may specify only one of -Env and -Proxy."    
    }
    
    if (!$PSBoundParameters['Name']) {
      throw [System.ArgumentNullException] "Name", "You must specify the -Name option."
    }
    if (!$PSBoundParameters['Entry']) {
      throw [System.ArgumentNullException] "Entry", "You must specify the -Entry option."
    }
    if (!$PSBoundParameters['Value']) {
      throw [System.ArgumentNullException] "Value", "You must specify the -Value option."
    }
    
    $basepath = if ($PSBoundParameters['Env']) {
        $( Join-Parts -Separator '/' -Parts 'e', $Env, 'keyvaluemaps' )
    }
    elseif ($PSBoundParameters['Proxy']) {
        $(Join-Parts -Separator "/" -Parts 'apis', $Proxy, 'keyvaluemaps' )
    }
    else {
        'keyvaluemaps'
    }
    
    $Options.Add( 'Collection', $( Join-Parts -Separator '/' -Parts $basepath, $Name, 'entries' ) )
    $Options.Add( 'Payload', @{ name = $Entry; value = $Value } )

    Write-Debug ([string]::Format("Options {0}`n", $( ConvertTo-Json $Options -Compress ) ) )
    
    Send-EdgeRequest @Options
}
