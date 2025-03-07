$downloadUrl = "https://azure.github.io/Azure-Verified-Modules/governance/avm-standard-github-labels.csv"

if(Test-Path "temp") {
  Remove-Item "temp" -Recurse -Force
}

New-Item -ItemType Directory -Path "temp"

$url = $downloadUrl
$outputFile = "temp/labels.csv"
Invoke-WebRequest -Uri $url -OutFile $outputFile
