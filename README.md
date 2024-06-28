# VC_HMAC_Auth

An example of calling Veracode from PowerShell 7, calculating and providing the HMAC

If you want a quick portfolio-wide test, consider changing:

$urlPath = "/api/5.0/getbuildlist.do"

to:

$urlPath = "/api/5.0/getapplist.do"

Tested under PowerShell 7.4.2