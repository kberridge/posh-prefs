update-formatdata C:\projects\posh-prefs\SQLProvider.Customized.Format.ps1xml

function prompt {
  Write-Host($pwd.Path) -foregroundcolor yellow
  return "> "
}

function match-col([string]$regex) {
  $input | ?{ $_.Name -match $regex }
}

function match-table([string]$schemaRegex, [string]$tableRegex) {
  $input | ?{ $_.Schema -match $schemaRegex -and $_.Name -match $tableRegex }
}
