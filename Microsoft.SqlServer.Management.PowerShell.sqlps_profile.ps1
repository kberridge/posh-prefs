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

function select-from([string]$table, [string[]]$cols='*', [string]$top=$nil) {
  $colstr = $cols -join ','
  $topstr = if ($top) {"top $top"} else {''}
  $sql = "select $topstr $colstr from $table"
  $sql
  invoke-sqlcmd $sql
}
