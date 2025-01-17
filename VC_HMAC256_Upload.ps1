[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

<# Example output: 74BE83415200E845ABC1C729F2ADBB2E12D00AD0009A19F9FE658F873B6D14CA #>
Function Get-RandomHex {
    param(
        [int] $Bits = 256
    )
    $bytes = [byte[]]::new($Bits/8)
    [System.Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($bytes)
    -join ($bytes | ForEach-Object { "{0:X2}" -f $_ })
}

<# Returns a Byte array from a Hex String #>
Function GetByteArray {

    [cmdletbinding()]

    param(
        [parameter(Mandatory=$true)]
        [String] $HexString
    )

    $Bytes = [byte[]]::new($HexString.Length / 2)

    For($i=0; $i -lt $HexString.Length; $i+=2){
        $Bytes[$i/2] = [convert]::ToByte($HexString.Substring($i, 2), 16)
    }

    $Bytes   
}

<# Returns nonce as a byte array#>
Function GetNonce {

    $nonce = Get-RandomHex -Bits 128 
    $nonceByteArray = GetByteArray $nonce

    $nonceByteArray
}

Function ComputeHash ($CHData, $CHKey) {
    
    $hmac = [System.Security.Cryptography.HMACSHA256]::new()
    $hmac.Key = $CHKey

    $Result = $hmac.ComputeHash($CHData)

    $Result

}

<# Construct Signature #>
Function CalculateDataSignature($apiKeyBytes, $nonceBytes, $dateStamp, $dataCDS) {

    $requestVersion = "vcode_request_version_1"
    $requestVersionBytes = [Text.Encoding]::UTF8.GetBytes($requestVersion)
    [byte[]] $kNonce = ComputeHash $nonceBytes $apiKeyBytes
    [byte[]] $kDate = ComputeHash  $dateStamp $kNonce
    [byte[]] $kSignature = ComputeHash $requestVersionBytes $kDate

    $dataSignature = ComputeHash $dataCDS $kSignature 

    $dataSignature

}

Function CalculateAuthorizationHeader($IdCA, $apiKeyCA, $urlBaseCA, $urlPathCA, $MethodCA, $urlQueryParams)    {
    
    try {

        if (-not ([string]::IsNullOrEmpty($urlQueryParams)))
        {
            $urlPathCA += '?' + ($urlQueryParams);
        }
              
        $dataCA = "id={0}&host={1}&url={2}&method={3}" -f $IdCA, $urlBaseCA, $urlPathCA, $MethodCA
        $dataCABytes = [Text.Encoding]::UTF8.GetBytes($dataCA)
        $dateStamp = [Math]::Round((New-TimeSpan -start (Get-Date -Date "1/1/1970") -end (Get-Date).ToUniversalTime()).TotalMilliseconds)
        [byte[]] $dateStampbytes = [Text.Encoding]::UTF8.GetBytes($dateStamp.ToString())
        [byte[]] $nonceBytesCA = GetNonce
        $nonceHex = [System.BitConverter]::ToString($nonceBytesCA) -replace '-'
        [byte[]] $apiKeyBytes = GetByteArray $apiKeyCA
        [byte[]] $dataSignatureCA = CalculateDataSignature $apiKeyBytes $nonceBytesCA $dateStampbytes $dataCABytes
        $dateSignatureHex = [System.BitConverter]::ToString($dataSignatureCA) -replace '-'
        $authorizationParam = "id={0},ts={1},nonce={2},sig={3}" -f $IdCA, $dateStamp, $nonceHex, $dateSignatureHex 

        $AuthorizationScheme = "VERACODE-HMAC-SHA-256" + " " + $authorizationParam
        
        $AuthorizationScheme
        
   }
    catch {
    
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        
        Write-Host $ErrorMessage
        Write-Host $FailedItem
        Write-Host $_.Exception
        Break
    }
    
}


<# The script uses environment variables to hide your API ID and Key. 
 # You will need to set up two environment variables called Veracode_API_ID and Veracode_API_Key, if you use the script as is.
 # You may use your credentials as plain text. However, that is not recommended. 
#>         
$apiId = $env:Veracode_API_ID
$apiKey = $env:Veracode_API_Key

$urlBase = "analysiscenter.veracode.com"
$urlPath = "/api/5.0/uploadfile.do"
$method = "POST"
$urlQueryParams = 'app_id=2186724' <# Add sandbox_id and whatever else you need here as a parameter. File will be in the body#>
$filePath = "C:\users\test\test.zip"

<# Construct Header #>
$authorization = CalculateAuthorizationHeader $apiId $apiKey $urlBase $urlPath $method $urlQueryParams

$headers = [System.Collections.Generic.Dictionary[string, string]]::new()
$headers.Add("Authorization", $authorization)
$headers.Add("Accept", "*/*")
$headers.Add("Accept-Encoding", "deflate")
$headers.Add("Connection", "keep-alive")

$url = 'https://' + $urlBase + $urlPath + '?' + $urlQueryParams

# Create the multipart content
$multipartContent = [System.Net.Http.MultipartFormDataContent]::new()

# Add file content
$fileContent = [System.Net.Http.ByteArrayContent]::new([System.IO.File]::ReadAllBytes($filePath))
$fileContent.Headers.ContentDisposition = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
$fileContent.Headers.ContentDisposition.Name = '"file"'
$fileContent.Headers.ContentDisposition.FileName = '"test.zip"'
$fileContent.Headers.Add("Content-Type", "application/zip")
$multipartContent.Add($fileContent)

# Create HTTP client and send request
$httpClient = [System.Net.Http.HttpClient]::new()
$httpClient.DefaultRequestHeaders.Accept.Add([System.Net.Http.Headers.MediaTypeWithQualityHeaderValue]::new("application/xml"))

foreach ($header in $headers.GetEnumerator()) {
    $httpClient.DefaultRequestHeaders.Add($header.Key, $header.Value)
}

$response = $httpClient.PostAsync($url, $multipartContent).Result
$responseContent = $response.Content.ReadAsStringAsync().Result

Write-Output $response.StatusCode
Write-Output $responseContent
