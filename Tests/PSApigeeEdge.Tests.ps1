$Verbose = @{}
if($env:APPVEYOR_REPO_BRANCH -and $env:APPVEYOR_REPO_BRANCH -notlike "master")
{
    $Verbose.add("Verbose",$True)
}

$PSVersion = $PSVersionTable.PSVersion.Major
Import-Module $PSScriptRoot\..\PSApigeeEdge -Force

# --- Get data for the tests
$ConnectionData = Get-Content .\ConnectionData.json -Raw | ConvertFrom-JSON


Describe "Set-EdgeConnection" {

    Context 'Strict mode' { 

        Set-StrictMode -Version latest

        It 'sets the connection info' {
            $ConnectionData.password | Should Not BeNullOrEmpty 
            $ConnectionData.user | Should Not BeNullOrEmpty 
            $ConnectionData.org | Should Not BeNullOrEmpty 
            Set-EdgeConnection -Org $ConnectionData.org -User $ConnectionData.user -EncryptedPassword $ConnectionData.password
        }
    }
}


Describe "Get-EdgeApi-1" {

    Context 'Strict mode' { 

        Set-StrictMode -Version latest

        It 'gets a list of proxies' {
            $proxies = Get-EdgeApi
            $proxies.count | Should BeGreaterThan 0
        }
       
        It 'gets details of one apiproxy' {
            $proxies = Get-EdgeApi
            $proxies.count | Should BeGreaterThan 0
            $oneproxy = Get-EdgeApi -Name $proxies[0] -Params @{ expand = 'true' }
            $oneproxy | Should Not BeNullOrEmpty
            $oneproxy.metaData | Should Not BeNullOrEmpty
            $NowMilliseconds = [int64](([datetime]::UtcNow)-(get-date "1/1/1970")).TotalMilliseconds
            $oneproxy.metaData.createdAt | Should BeLessthan $NowMilliseconds
            $oneproxy.metaData.lastModifiedBy | Should Not BeNullOrEmpty
        }
    }
}


Describe "Get-EdgeEnvironment-1" {

    Context 'Strict mode' { 

        Set-StrictMode -Version latest

        It 'gets a list of environments' {
            $envs = Get-EdgeEnvironment
            $envs.count | Should BeGreaterThan 0
        }
        
        It 'gets one environment by name' {
            $envs = Get-EdgeEnvironment
            $OneEnv = Get-EdgeEnvironment -Name $envs[0]
            $NowMilliseconds = [int64](([datetime]::UtcNow)-(get-date "1/1/1970")).TotalMilliseconds
            $OneEnv.createdAt | Should BeLessthan $NowMilliseconds
            $OneEnv.lastModifiedAt | Should BeLessthan $NowMilliseconds
            $OneEnv.name | Should Be $envs[0]
            $OneEnv.properties | Should Not BeNullOrEmpty
        }
    }
}



Describe "Get-EdgeEnvironment-1" {

    Context 'Strict mode' { 

        Set-StrictMode -Version latest

        It 'gets a list of environments' {
            $envs = Get-EdgeEnvironment
            $envs.count | Should BeGreaterThan 0
        }
        
        It 'gets one environment by name' {
            $envs = Get-EdgeEnvironment
            $OneEnv = Get-EdgeEnvironment -Name $envs[0]
            $NowMilliseconds = [int64](([datetime]::UtcNow)-(get-date "1/1/1970")).TotalMilliseconds
            $OneEnv.createdAt | Should BeLessthan $NowMilliseconds
            $OneEnv.lastModifiedAt | Should BeLessthan $NowMilliseconds
            $OneEnv.name | Should Be $envs[0]
            $OneEnv.properties | Should Not BeNullOrEmpty
        }
    }
}


