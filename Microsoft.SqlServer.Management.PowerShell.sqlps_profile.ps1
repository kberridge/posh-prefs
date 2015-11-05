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

function select-from([string]$table, [string[]]$cols='*', [string]$top=$nil, [string]$where=$nil) {
  $colstr = $cols -join ','
  $topstr = if ($top) {"top $top"} else {''}
  $wherestr = if ($where) {"where $where"} else {''}
  $sql = "select $topstr $colstr from $table $wherestr"
  $sql
  invoke-sqlcmd $sql
}

function cddb($db) {
  $parts = @($db.Split(('\', '/')))
  if ($parts.Length -eq 1) {
    cd "\sql\$($parts[0])\default\databases"
  }
  elseif ($parts.Length -eq 2) {
    cd "\sql\$($parts[0])\default\databases\$($parts[1])"
  }
  elseif ($parts.Length -eq 3) {
    cd "\sql\$($parts[0])\$($parts[1])\databases\$($parts[2])"
  }
  else {
    Write-Error "Supports only 1, 2, or 3 path parts"
  }
}

function lsc($table) {
  ls $table\columns
}

if ((test-path function:\TabExpansion) -and !(test-path function:\TabExpansionSqlPsBackup)) {
  rename-item function:\TabExpansion TabExpansionSqlPsBackup
}

function TabExpansion($line, $lastWord) {
  if (!((get-location).Provider.Name -eq "SqlServer")) {
    TabExpansionSqlPsBackup $line $lastWord
  }
  else {
    $index = $lastWord.LastIndexOfAny(@('\', '/'))
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
