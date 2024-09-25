$downloadUrl = "https://raw.githubusercontent.com/Azure/Azure-Verified-Modules/main/docs/static/module-indexes/"

$csvFiles = @("TerraformResourceModules.csv", "TerraformPatternModules.csv", "TerraformUtilityModules.csv")

if(Test-Path "temp") {
  Remove-Item "temp" -Recurse -Force
}

if(Test-Path "imports.tf") {
  Remove-Item "imports.tf"
}

New-Item -ItemType Directory -Path "temp"

foreach ($csvFile in $csvFiles) {
  $url = $downloadUrl + $csvFile
  $outputFile = "temp/$csvFile"
  Invoke-WebRequest -Uri $url -OutFile $outputFile
}