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

if ((test-path function:\TabExpansion) -and !(test-path function:\TabExpansionSqlPsBackup)) {
  rename-item function:\TabExpansion TabExpansionSqlPsBackup
}

function TabExpansion($line, $lastWord) {
  if (!((get-location).Provider.Name -eq "SqlServer")) {
    TabExpansionSqlPsBackup $line $lastWord
  }
  else {
    $aindex = $lastWord.LastIndexOf('\')
    $bindex = $lastWord.LastIndexOf('/')
    $index = (($aindex, $bindex) | measure-object -max).Maximum
    if ($index -gt -1) { 
      $parent = $lastWord.substring(0, $index+1) 
      $leaf = $lastWord.substring($index+1)
    }
    else {
      $parent = ""
      $leaf = $lastWord
    }

    $matches = ls -path $parent | ?{ $_.PSChildName -match "^$leaf" }
    if ($matches) { 
      $matches | %{ $parent + $_.PSChildName } 
    } 
    else {$lastWord}
  }
}
