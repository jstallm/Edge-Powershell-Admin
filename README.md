# Edge Powershell Admin module

This is a Windows Powershell module for managing Apigee Edge.

The goal is to allow Powershell scripts to do these things:

| entity type   | actions             |
| :------------ | :------------------ |
| org           | query, update properties |
| apis          | list, query, inquire revisions, inquire deployment status, import, export, delete, delete revision, deploy, undeploy
| sharedflows   | list, query, inquire revisions, inquire deployment status, import, export, delete, delete revision, deploy, undeploy
| flowhooks     | ?? 
| apiproducts   | list, query, create, delete, change quota, modify public/private, modify description, modify approvalType, modify scopes, add or remove proxy, modify custom attrs
| developers    | list, query, create, delete, make active or inactive, modify custom attrs
| developer app | list, query, create, delete, revoke, approve, add new credential, remove credential, modify custom attrs
| credential    | list, revoke, approve, add apiproduct, remove apiproduct, revoke apiproduct, approve apiproduct
| kvm           | list, query, create, delete, get all entries, get entry, add entry, modify entry, remove entry
| cache         | list, query, create, delete, clear
| keystore      | list, query, create, delete, import cert
| virtualhost   | list, query, create, delete 
| environment   | list, query


Not in scope:

- OAuth2.0 tokens - Listing, Querying, Approving, Revoking, Deleting, or Updating 
- TargetServers: list, create, edit, etc
- data masks
- apimodels
- retrieving analytics or data from custom reports
- DebugSessions (trace)
- anything in BaaS
- OPDK-specific things. such as: starting or stopping services,  manipulating pods, adding servers into environments, etc.

These items may be added later as need and demand warrants.


## A Quick Tour

[![Quick Tour](http://img.youtube.com/vi/5xwo4PAOeFM/0.jpg)](http://www.youtube.com/watch?v=5xwo4PAOeFM "Click to open the Quick Tour video")


<iframe width="420" height="315" src="https://www.youtube.com/embed/" frameborder="0" allowfullscreen></iframe>

## Pre-Requisites to use

You need Windows, and Powershell v3.0 or later. If you're running Windows 10,
then you have Powershell 5.0, so you're good.

## Status

This project is a work-in-progress. Here's the status:

| entity type   | implemented              | not implemented yet
| :------------ | :----------------------- | :--------------------
| org           | query | update properties 
| apis          | list, query, inquire revisions, inquire deployment status, import, export, delete, delete revision, deploy, undeploy
| sharedflows   | list, query, inquire revisions, inquire deployment status, deploy, undeploy  | import, export, delete, delete revision,
| flowhooks     | 
| apiproducts   | list, query, create, delete, modify description, modify approvalType, modify scopes, add or remove proxy, add or remove custom attrs, modify public/private, change quota | 
| developers    | list, query, make active or inactive, create, delete, modify custom attrs | 
| developer app | list, query, create, delete, revoke, approve, add new credential, remove credential | modify custom attrs
| credential    | list, revoke, approve, add apiproduct, remove apiproduct, revoke apiproduct, approve apiproduct |
| kvm           | list, query, create, delete, get all entries, get entry, add entry, modify entry, remove entry |
| cache         | list, query, create, delete, clear | 
| keystore      | list, query, create, delete | import cert
| virtualhost   | list, query | create, delete 
| environment   | list, query |

Pull requests are welcomed.


## Get PSApigee Edge

You have two options. You need to use only one of these options. 


### Option A: install from the Powershell Gallery

This will get you the latest "Released" version of the module.

1. As administrator, start powershell:  `powershell`

2. Run `install-module`

```
PS C:\dev\ps> Install-Module PSApigeeEdge

Untrusted repository
You are installing the modules from an untrusted repository. If you trust this repository, change its
InstallationPolicy value by running the Set-PSRepository cmdlet. Are you sure you want to install the modules from
'PSGallery'?
[Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "N"): Y
```

You will need to do this just once, ever, for the machine. To upgrade, you can `remove-module PSApigeeEdge` and then run the `Install-Module` step again. 


### Option B: Clone from Github

This will get you the latest source. Usually these are the same. 

1. Clone the repo:  `git clone git@github.com:DinoChiesa/Edge-Powershell-Admin.git`

2. Start powershell: `powershell`

3. import the module, like this:

```
PS> Import-Module c:\path\to\PSApigeeEdge
```

Then, you can run the cmdlets provided by this module.

You will need to run steps 2 and 3, for every powershell instance that uses PSApigeeEdge function. 



## Usage Examples

Following are some examples. This is not a complete list!  Check the contents of the Public directory for the full list of functions available in this module. Each one is documented. 

### List commands provided by the module

```
PS C:\dev\ps> Get-Command -Module PSApigeeEdge

CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Function        Delete-EdgeApi                                     0.0.1      PSApigeeEdge
Function        Delete-EdgeObject                                  0.0.1      PSApigeeEdge
Function        Deploy-EdgeApi                                     0.0.1      PSApigeeEdge
Function        Export-EdgeApi                                     0.0.1      PSApigeeEdge
....
```

NB: The above list is not complete.

### Set Connection information

```
PS C:\dev\ps> Set-EdgeConnection -Org cap500 -User dino@apigee.com
Please enter the password for dino@apigee.com: ***********
```

All commands that interact with Apigee Edge rely on this connection information.
You need to do this only once during a Powershell session. If you wish to connect as a different user, you should run this command again.

By default, the module will attempt to connect to the Apigee-managed cloud Edge service, which is available at https://api.enterprise.apigee.com . To connect to a self-managed Apigee Edge, specify the base URL of the Edge management server, using the MgmtUri parameter:


```
PS C:\dev\ps> Set-EdgeConnection -Org cap500 -User dino@apigee.com -MgmtUri http://192.168.10.56:8080
Please enter the password for dino@apigee.com: ***********
```


If you employ the module from a script that runs without user interaction, you will want to
specify the encrypted password, like so:

```
Set-EdgeConnection -Org $Connection.org -User $Connection.User -EncryptedPassword $Connection.password
```

Or, of course you can splat the connection information, like this:

```
$connection = @{
   Org = 'myorg'
   User = 'dino@example.com'
   MgmtUri = 'http://192.168.56.10:8080'
   EncryptedPassword = '003093039039...xx'
   }
Set-EdgeConnection @connection
```

To get the encrypted password, for safe storage on the machine, you can do this:

```
   $SecurePass = Read-Host -assecurestring "Please enter the password"
   $encryptedPassword = ConvertFrom-SecureString $SecurePass
```

By the way, this secure string and encrypted secure string stuff is just basic Powershell; it's not special to this module. Please note: The encryption of secure strings in Powershell is machine-specific. 

Finally, there's an option to set the connection information from a file:

```
Set-EdgeConnection -File .\ConnectionData-myorg.json
```

...and in this case the file must be JSON format, and should look like this:

```
{
  "Org" : "myorg",
  "User" : "dchiesa@google.com",
  "EncryptedPassword" : "01000000d08c9ddf0115d1118c7....."
}
```

You can use any of the parameters describe above in this file. We recommend you do not store the password in cleartext, but use the encrypted password form.

After setting this connection information, you can run any of the following commands without re-entering your credentials.

Beginning with v0.2.14, if you are connecting to the Apigee-managed Edge SaaS, the Set-EdgeConnection command will attempt to obtain an OAuth token for the admin API, via a POST request to https://login.apigee.com/oauth/token , as documented on [this page](http://docs.apigee.com/api-services/content/using-oauth2-security-apigee-edge-management-api).

The Set-EdgeConnection will first look for a stashed token, which it stores in a file called .apigee-edge-tokens in the TEMP directory of your machine. This is the logic:

* if it finds a stashed, un-expired token for the user you specify, it will use that.
* if it finds a stashed, expired token for the user you specify, it will attempt to refresh the token.
* if that does not work, it will fall back to requiring a password.

Normally tokens live for 30 minutes. It's possible that a PS script will find an un-expired token in the stash, and then during the course of the run, the token may expire. In that case the module is designed to refresh the token automatically. 

Notes:

* access to the token stash in your TEMP directory will imply the ability to connect to Apigee Edge. 
* The stash can contain multiple tokens. They're indexed by user name (email address).


### List Developers

```
PS C:\dev\ps> Get-EdgeDeveloper
mpalmgre@example.org
dchiesa@example.org
dchiesa+workshop1@apigee.com
mmcsweyn@example.org
Lois@example.com
akshays@slalom.com
ecerruti@gmail.com
justinmadalone@gmail.com
PS C:\dev\ps>
```


### List Developers Verbosely

```
PS C:\dev\ps> (Get-EdgeDeveloper -Params @{ expand = 'true' }).developer | Format-List

apps             : {my-hospitality-app-oauth, my-hospitality-app}
companies        : {}
email            : mpalmer@example.org
developerId      : 0wYm1ALhbLl3er5G
firstName        : Matt
lastName         : Palmer
userName         : mpalmer
organizationName : cap500
status           : active
attributes       : {}
createdAt        : 1470173119147
createdBy        : dchiesa+devportal@apigee.com
lastModifiedAt   : 1470174224727
lastModifiedBy   : dchiesa+devportal@apigee.com

apps             : {dpc1, dpc2, dpc3, DPC4...}
companies        : {}
email            : dchiesa@example.org
developerId      : IiwTHAerQeO1OAqG
firstName        : Dino
lastName         : Chiesa
userName         : DC
organizationName : cap500
status           : active
attributes       : {}
createdAt        : 1469831492534
createdBy        : dchiesa+devportal@apigee.com
lastModifiedAt   : 1469831492534
lastModifiedBy   : dchiesa+devportal@apigee.com

 ...

```


### List API Products Verbosely

```
PS C:\dev\ps> (Get-EdgeApiProduct -Params @{ expand = 'true' }).apiProduct | Format-List

apiResources   : {}
approvalType   : auto
attributes     : {@{name=access; value=public}}
createdAt      : 1469813885881
createdBy      : DChiesa@apigee.com
description    : API Bundle for a basic Hospitality App.
displayName    : DPC Hospitality Basic Product
environments   : {test}
lastModifiedAt : 1470151304300
lastModifiedBy : DChiesa@apigee.com
name           : DPC Hospitality Basic Product
proxies        : {dpc_hotels, dpc_hotels_oauth, oauth2-pwd-cc}
scopes         : {read, write, delete}

  ...

```


### List API Products Succinctly

```
PS C:\dev\ps> get-edgeapiproduct
Reservations
ooxa-proxy-1-Product
mcp_Hospitality Basic Product
ApiTechForum
oauthtest3
Aircraft Maintenance
verifyapikey1-Product
Stock Quote Product
Loyalty
Offers1
DPC Hospitality Basic Product
```


### List API Proxies

```
PS C:\dev\ps> Get-EdgeApi
mcp_hotels_oauth
JTM_OpenAPI-Specification-for-Hotels-1_oauth
rqa-perf
jsprop
JTM_OpenAPI-Specification-for-Hotels
oauth
oauth2-pwd-cc
MM_hotels
dino-test
virtualearth-passthru
```


### Get Details of an API Proxy Revision

```
PS C:\dev\ps> Get-EdgeApi -Name oauth2-pwd-cc -Revision 2

configurationVersion : @{majorVersion=4; minorVersion=0}
contextInfo          : Revision 2 of application oauth2-pwd-cc, in organization cap500
createdAt            : 1470082739958
createdBy            : DChiesa@apigee.com
description          : Dispense OAuth v2.0 Bearer tokens for password and client_credentials grant_types. In this proxy, the user authentication is
                       handled by a mock service.
displayName          : oauth2-pwd-cc
lastModifiedAt       : 1470082739958
lastModifiedBy       : DChiesa@apigee.com
name                 : oauth2-pwd-cc
policies             : {AE-ConsumerKey, AM-CleanResponseHeaders, AM-NoContent, BasicAuth-1...}
proxyEndpoints       : {oauth-dispensary, resource}
resourceFiles        : @{resourceFile=System.Object[]}
resources            : {jsc://dateFormat.js, jsc://groomTokenResponse.js, jsc://mapRolesToScopes.js, jsc://maybeFormatFault.js...}
revision             : 2
targetEndpoints      : {}
targetServers        : {}
type                 : Application
```


### Get Deployment status of an API

```
PS C:\dev\ps> Get-EdgeApiDeployment -Name oauth2-pwd-cc

name revision
---- --------
test {@{configuration=; name=8; server=System.Object[]; state=deployed}}

PS C:\dev\ps> Get-EdgeApiDeployment -Name oauth2-pwd-cc | Format-List

name     : test
revision : {@{configuration=; name=8; server=System.Object[]; state=deployed}}

```

### Deploy an API Proxy

```
PS C:\dev\ps> Deploy-EdgeApi -Name oauth2-pwd-cc -Env test -Revision 8

aPIProxy      : oauth2-pwd-cc
configuration : @{basePath=/; steps=System.Object[]}
environment   : test
name          : 8
organization  : cap500
revision      : 8
server        : {@{status=deployed; type=System.Object[]; uUID=a4850e3b-6ce9-482a-9521-d9869be8482e}, @{status=deployed; type=System.Object[];
                uUID=647de67b-1142-4c07-8b22-c5d6f85616a4}, @{status=deployed; type=System.Object[]; uUID=6b4a729b-16e2-45c0-8560-51eb37f50ece},
                @{status=deployed; type=System.Object[]; uUID=589aa4f0-0a1b-492c-be1a-da3e295cf44d}...}
state         : deployed
```

### Undeploy an API Proxy

```
PS C:\dev\ps> UnDeploy-EdgeApi -Name oauth2-pwd-cc -Env test -Revision 8


aPIProxy      : oauth2-pwd-cc
configuration : @{basePath=/; steps=System.Object[]}
environment   : test
name          : 8
organization  : cap500
revision      : 8
server        : {@{status=undeployed; type=System.Object[]; uUID=a4850e3b-6ce9-482a-9521-d9869be8482e}, @{status=undeployed; type=System.Object[];
                uUID=647de67b-1142-4c07-8b22-c5d6f85616a4}, @{status=undeployed; type=System.Object[]; uUID=6b4a729b-16e2-45c0-8560-51eb37f50ece},
                @{status=undeployed; type=System.Object[]; uUID=589aa4f0-0a1b-492c-be1a-da3e295cf44d}...}
state         : undeployed

```


### Export an API Proxy

This creates a zip file with the contents of the API Proxy.

```
PS C:\dev\ps> Export-EdgeApi -Name oauth2-pwd-cc -Revision 8
oauth2-pwd-cc-r8-20160805-175438.zip
```


### Import an API Proxy

You can use a zipfile as a source, or a directory that contains an "Exploded" apiproxy tree.

#### Import a Proxy from a ZipFile

```
PS C:\dev\ps> Import-EdgeApi -Name dino-test-6 -Source oauth2-pwd-cc-r8-20160805-175438.zip

configurationVersion : @{majorVersion=4; minorVersion=0}
contextInfo          : Revision 1 of application dino-test-6, in organization cap500
createdAt            : 1470444956300
createdBy            : dino@apigee.com
description          : Dispense OAuth v2.0 Bearer tokens for password and client_credentials grant_types. In this proxy, the user authentication is
                       handled by a mock service.
displayName          : oauth2-pwd-cc
lastModifiedAt       : 1470444956300
lastModifiedBy       : dino@apigee.com
name                 : dino-test-6
policies             : {AE-ConsumerKey, AM-CleanResponseHeaders, AM-NoContent, AM-Response...}
proxyEndpoints       : {oauth-dispensary, resource}
resourceFiles        : @{resourceFile=System.Object[]}
resources            : {jsc://dateFormat.js, jsc://groomTokenResponse.js, jsc://mapRolesToScopes.js, jsc://maybeFormatFault.js...}
revision             : 1
targetEndpoints      : {}
targetServers        : {}
type                 : Application

```

Note: I have seen situations in which an access denied error prevents this command from succeeding, if the source ZIP file is Read-only. Needs further investigation. Until that is resolved, make sure your zip file is writeable. The command does not modify the zip, but for now it appears that the zip needs to be writable.

#### Import a Proxy from a Directory

```
PS C:\dev\ps> Import-EdgeApi -Name dino-test-6 -Source c:\my\directory

```

### Delete an API Proxy

```
PS C:\dev\ps> Delete-EdgeApi dino-test-4


configurationVersion : @{majorVersion=4; minorVersion=0}
contextInfo          : Revision null of application -NA-, in organization -NA-
name                 : dino-test-4
policies             : {}
proxyEndpoints       : {}
resourceFiles        : @{resourceFile=System.Object[]}
resources            : {}
targetEndpoints      : {}
targetServers        : {}
type                 : Application

```

### Delete a revision of an API Proxy

```
PS C:\dev\ps> Delete-EdgeApi -Name oauth2-pwd-cc -Revision 3


configurationVersion : @{majorVersion=4; minorVersion=0}
contextInfo          : Revision 3 of application oauth2-pwd-cc, in organization cap500
createdAt            : 1470082789542
createdBy            : DChiesa@apigee.com
description          : Dispense OAuth v2.0 Bearer tokens for password and client_credentials grant_types. In this proxy, the user authentication is
                       handled by a mock service.
displayName          : oauth2-pwd-cc
lastModifiedAt       : 1470082789542
lastModifiedBy       : DChiesa@apigee.com
name                 : oauth2-pwd-cc
policies             : {}
proxyEndpoints       : {}
resourceFiles        : @{resourceFile=System.Object[]}
resources            : {}
revision             : 3
targetEndpoints      : {}
targetServers        : {}
type                 : Application

```



### List Environments

```
PS C:\dev\ps> get-EdgeEnvironment
test
prod
```

### Query an Environment by Name

```
PS C:\dev\ps> get-EdgeEnvironment -name test

createdAt      : 1408425529572
createdBy      : lyeo@apigee.com
lastModifiedAt : 1464341439395
lastModifiedBy : sanjoy@apigee.com
name           : test
properties     : @{property=System.Object[]}

```

### List Developer Apps for a Developer

```
PS C:\dev\ps\PSApigeeEdge> (Get-EdgeDevApp -Developer mpalmgre@example.org -Params @{ expand = 'true' }).app

accessType     : read
appFamily      : default
appId          : cc631102-80cd-4491-a99a-121cec08e0bb
attributes     : {@{name=DisplayName; value=My Hospitality App oauth}, @{name=lastModified; value=2016-08-02 22:07 PM}, @{name=lastModifier;
                 value=mpalmgre@example.org}, @{name=creationDate; value=2016-08-02 22:07 PM}}
callbackUrl    :
createdAt      : 1470175621212
createdBy      : dchiesa+devportal@apigee.com
credentials    : {@{apiProducts=System.Object[]; attributes=System.Object[]; consumerKey=9893938398398dddddddjj;
                 consumerSecret=982kedkjdkdjdkj; expiresAt=1485727621253; issuedAt=1470175621253; scopes=System.Object[]; status=approved}}
developerId    : 0wYm1ALhbLl3er5G
lastModifiedAt : 1470175621212
lastModifiedBy : dchiesa+devportal@apigee.com
name           : my-hospitality-app-oauth
scopes         : {}
status         : approved

accessType     : read
appFamily      : default
appId          : ddb7d94b-c389-4df4-a5fb-34a31e9508f7
attributes     : {@{name=DisplayName; value=My Hospitality App}, @{name=lastModified; value=2016-08-02 21:27 PM}, @{name=lastModifier;
                 value=mpalmgre@example.org}, @{name=creationDate; value=2016-08-02 21:27 PM}}
callbackUrl    :
createdAt      : 1470173267571
createdBy      : dchiesa+devportal@apigee.com
credentials    : {@{apiProducts=System.Object[]; attributes=System.Object[]; consumerKey=dkjdkjdkjdkjdk88181;
                 consumerSecret=xyxyyxyyxy; expiresAt=-1; issuedAt=1470173903609; scopes=System.Object[]; status=approved}}
developerId    : 0wYm1ALhbLl3er5G
lastModifiedAt : 1470173903384
lastModifiedBy : mpalmgre@example.org
name           : my-hospitality-app
scopes         : {}
status         : approved
```


### Revoke a Developer App

```
PS C:\dev\ps> Update-EdgeDevAppStatus  -Developer developer1@example.org -AppName Devapp-Dinotest-20170322 -Action revoke
```

### Approve a Developer App

```
PS C:\dev\ps> Update-EdgeDevAppStatus  -Developer developer1@example.org -AppName Devapp-Dinotest-20170322 -Action approve
```

### Approve a Specific Credential on a Developer App

```
PS C:\dev\ps> Update-EdgeDevAppStatus  -Developer developer1@example.org -AppName Devapp-Dinotest-20170322 =Key 18919ukjdjd -Action approve
```

### Approve a Specific Product for a Credential on a Developer App

```
PS C:\dev\ps> Update-EdgeDevAppStatus  -Developer developer1@example.org -AppName Devapp-Dinotest-20170322 =Key 18919ukjdjd -ApiProduct Product123 -Action approve
```



### Create a Key Value Map (KVM)

This method specifies the values in a Powershell Hashtable:

```
PS C:\dev\ps> Create-EdgeKvm -Name kvm1 -Env env1 -Values @{
                 key1 = 'value1'
                 key2 = 'value2'
                 key3 = 'CEBF0408-F5BF-4A6E-B841-FBF107BB3B60'
            }

```

Using the -Source option allows you to load the initial values from a JSON file.
The JSON can be a simple hash with no nesting, only top-level properties, like so: 

```
PS C:\dev\ps> type .\data.json
{
  "threshold" : 1780,
  "allowErrors" : true,
  "header-name" : "X-Client-ID",
  "targetUrl" : "http://192.168.78.12:9090"
}
PS C:\dev\ps> Create-EdgeKvm -Name kvm1 -Env env1 -Source .\data.json

```

The JSON can also include nested properties, like so:

```
PS C:\dev\ps> type .\data.json
{
  "threshold" : 5280,
  "alertEmail" : "opdk@apigee.com",
  "targetUrl" : "http://192.168.66.12:9090",
  "settings" : {
     "one" : 1,
     "two" : 2,
     "three" : true
  }
}
PS C:\dev\ps> Create-EdgeKvm -Name kvm2 -Env env1 -Source .\data.json

```

In this case, the value associated to a key with a nested hash, will be a string, containing the JSON-stringified version of the nested hash. In the above, the key 'settings' will be associated with the string '{"one":1,"two":2,"three":true}'.


## Running Tests

The tests for this module rely with [Pester](https://github.com/pester/Pester).

To run the tests:

```
  PS C:\dev\ps> cd Edge-Powershell-Admin
  PS C:\dev\ps\Edge-Powershell-Admin> invoke-pester   
```

You will need a file named ConnectionData.json, which is not provided in this source repo.  It should have this structure:

```
{
  "Org" : "myorg",
  "MgmtUri" : "http://192.168.56.10:8080",
  "User" : "dino@example.org",
  "Password" : "Secret123"
}
```

If you wish to not store your password in a file in plaintext, you can convert the string to a secure string and then an encrypted string, like this:

```
 $SecurePass = ConvertTo-SecureString -String $Password -AsPlainText -Force
 ConvertFrom-SecureString $SecurePass
```

... and store the value like so in the ConnectionData.json file:

```
{
  "Org" : "myorg",
  "MgmtUri" : "https://api.enterprise.apigee.com",
  "User" : "dino@example.org",
  "EncryptedPassword" : "01000000d08c9ddf0115d1118c7a00c04fc297e....6e0b49de4241b4b01e8f"
}
```


You can connect to a different Edge using different Connection files:

```
  Invoke-Pester -Script @{
    Path = '.\Tests\PSApigeeEdge.Tests.ps1'
    Parameters = @{Connection = 'MyCustomConnectionData.json'}
  }
```


## Other Notes

This module is available [on the Powershell Gallery](https://www.powershellgallery.com/packages/PSApigeeEdge)

## License and Copyright

This material is [Copyright (c) 2016-2017 Google Inc.](NOTICE),
and is licensed under [the Apache 2.0 source license](LICENSE).


## Bugs

* The tests are incomplete.
* Does not handle Encrypted KVM at this time

