# Modules
import-module Posh-Hg
import-module 'C:\Projects\psake'

set-alias time measure-command
set-alias psake psglass

function dw { get-childitem $args | format-wide }

function grep {
<#
.SYNOPSIS
  Searches for matches in files
.DESCRIPTION
  grep forsomething -path .\subfolder -filter *.cs
#>
  param(
    [Parameter(Position=0, Mandatory=1)]
    [string]$pattern, 
    [string]$path='.', 
    [string]$filter=$null
  )
  dir -r -path $path -filter $filter | select-string $pattern
}

function ff([string] $filter) { dir -r -filter $filter }
function rrm { rm -r -force $args }

function editprofile { gvim $profile }
function editvimrc { gvim "C:\program files\vim\_vimrc" }

function su {
  Start-Process 'PowerShell.exe' -Verb runas -WorkingDir $pwd -ARg "-noexit -command & cd $pwd" 
}

function hgcb { hg ci --close-branch -m "closed branch"; hg up default; }

function hgbak([string]$dirname, [string]$backupdir='U:\Projects\') {
  $backuppath = $backupdir + $dirname
  if ((test-path $backuppath) -eq $false) {
    mkdir $backuppath > $null
    hg clone . $backuppath -U
  }
  else {
    hg push $backuppath --new-branch
  }
}

function hgtoday([string]$user='berridge') {
  hg sl -u $user -d (get-date -format d)
}

function cleanvs([switch]$whatif) {
  if ($whatif) {
    ls . -include bin,obj PBS.Libraries -recurse | where{$_ -notmatch '.hg'} | remove-item -recurse -whatif
  }
  else {
    ls . -include bin,obj PBS.Libraries -recurse | where{$_ -notmatch '.hg'} | remove-item -recurse
  }
}

# Prompt w/ hg support
function prompt {
  $cwd = $pwd.Path
  if ( $cwd.length -ge 30 ) {
    $cwd = "..." + $cwd.substring($cwd.length - 30 + 4).trimstart(".")
  }
  $host.UI.RawUI.WindowTitle = $(get-location)
  Write-Host($cwd) -nonewline -foregroundcolor yellow

  # Mercurial Prompt
  $Global:HgStatus = Get-HgStatus
  Write-HgStatus $HgStatus

  Write-Host
  return "> "
}

if(-not (Test-Path Function:\DefaultTabExpansion)) {
    Rename-Item Function:\TabExpansion DefaultTabExpansion
}

# Set up tab expansion and include hg expansion
function TabExpansion($line, $lastWord) {
    $lastBlock = [regex]::Split($line, '[|;]')[-1]
    
    switch -regex ($lastBlock) {
        # mercurial and tortoisehg tab expansion
        '(hg|thg) (.*)' { HgTabExpansion($lastBlock) }
        # Fall back on existing tab expansion
        default { DefaultTabExpansion $line $lastWord }
    }
}

# function which serves your psake that understands parameters
function psglass {
  param (
    [Parameter(Position=0,Mandatory=0)]
    [string[]]$taskList = @(),
    [Parameter(Position=1,Mandatory=0)]
    [switch]$docs = $false,
    [Parameter(Position=2,Mandatory=0)]
    [System.Collections.Hashtable]$parameters = @{},
    [Parameter(Position=3, Mandatory=0)]
    [System.Collections.Hashtable]$properties = @{},
    [alias("e")]
    [string]$pbenv=$null,
    [alias("t")]
    [string[]]$tags=$null,
    [alias("s")]
    [string[]]$specs=$null,
    [alias("r")]
    [string]$run=$null,
    [alias("c")]
    [string]$configuration=$null
  )

  if ($pbenv) { $properties.environment = $pbenv }
  if ($tags) { $parameters.tags = $tags }
  if ($specs) { $parameters.specs = $specs }
  if ($run) { $parameters.run = $run }  
  if ($configuration) { $properties.BuildConfiguration = $configuration }

  $psakeParams = @{ taskList = $taskList; docs = $docs; parameters = $parameters; properties = $properties }

  if (Test-Path '..\vendor\psake') { $psakeDir = '..\vendor\psake' }
  elseif (Test-Path '.\vendor\psake') { $psakeDir = '.\vendor\psake' }
  elseif (Test-Path '.\Libraries\psake') { $psakeDir = '.\Libraries\psake' }
  elseif (Test-Path '..\Libraries\psake') { $psakeDir = '..\Libraries\psake' }
  
  if ($psakeDir) {
    & "$psakeDir\psake.ps1" @psakeParams
  }
  else {
    invoke-psake @psakeParams
  } 
}
