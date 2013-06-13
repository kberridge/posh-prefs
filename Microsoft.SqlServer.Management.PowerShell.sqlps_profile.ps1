update-formatdata C:\projects\posh-prefs\SQLProvider.Customized.Format.ps1xml

function prompt {
  Write-Host($pwd.Path) -foregroundcolor yellow
  return "> "
}

filter match-col([string]$colRegex) {
  if ($_.Name -match $colRegex) { $_ }
}

filter match-table([string]$schemaRegex, [string]$tableRegex) {
  if ($_.Schema -match $schemaRegex -and $_.Name -match $tableRegex) { $_ }
}

function select-from([string]$table) {
  invoke-sqlcmd "select top 100 * from $table"
}
