# VC_HMAC_Auth

An example of calling Veracode from PowerShell 7, calculating and providing the HMAC

If you want a quick portfolio-wide test, consider changing:

`$urlPath = "/api/5.0/getbuildlist.do"`

to:

`$urlPath = "/api/5.0/getapplist.do"`

Tested under PowerShell 7.4.2:

```
❯ $PSVersionTable

Name                           Value
----                           -----
PSVersion                      7.4.2
PSEdition                      Core
GitCommitId                    7.4.2
OS                             Microsoft Windows 10.0.19045
Platform                       Win32NT
PSCompatibleVersions           {1.0, 2.0, 3.0, 4.0…}
PSRemotingProtocolVersion      2.3
SerializationVersion           1.1.0.1
WSManStackVersion              3.0

❯ .\Veracode_HMAC256.ps1
Request Status Code: 200
Response: <?xml version="1.0" encoding="UTF-8"?>

<buildlist xmlns:xsi="http&#x3a;&#x2f;&#x2f;www.w3.org&#x2f;2001&#x2f;XMLSchema-instance" xmlns="https&#x3a;&#x2f;&#x2f;analysiscenter.veracode.com&#x2f;schema&#x2f;2.0&#x2f;buildlist" xsi:schemaLocation="https&#x3a;&#x2f;&#x2f;analysiscenter.veracode.com&#x2f;schema&#x2f;2.0&#x2f;buildlist https&#x3a;&#x2f;&#x2f;analysiscenter.veracode.com&#x2f;resource&#x2f;2.0&#x2f;buildlist.xsd" buildlist_version="1.3" account_id="44841" app_id="2123802" app_name="Test analysis"><build build_id="35815216" version="WAR broken down, all the dependencies" policy_updated_date="2024-06-13T20&#x3a;31&#x3a;30-04&#x3a;00"/>
</buildlist>
```

```
❯ .\Veracode_HMAC256_Upload.ps1

OK
<?xml version="1.0" encoding="UTF-8"?>

<filelist xmlns:xsi="http&#x3a;&#x2f;&#x2f;www.w3.org&#x2f;2001&#x2f;XMLSchema-instance" xmlns="https&#x3a;&#x2f;&#x2f;analysiscenter.veracode.com&#x2f;schema&#x2f;2.0&#x2f;filelist" xsi:schemaLocation="https&#x3a;&#x2f;&#x2f;analysiscenter.veracode.com&#x2f;schema&#x2f;2.0&#x2f;filelist https&#x3a;&#x2f;&#x2f;analysiscenter.veracode.com&#x2f;resource&#x2f;2.0&#x2f;filelist.xsd" filelist_version="1.1" account_id="44841" app_id="2186724" build_id="38075124"><file file_id="14493564819" file_name="test.zip" file_status="Uploaded"/>
   <file file_id="14493933963" file_name="test.zip" file_status="Uploaded"/>
   <file file_id="14493921228" file_name="test1.zip" file_status="Uploaded"/>
</filelist>
```
