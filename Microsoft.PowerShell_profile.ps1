# Modules
import-module Posh-Hg
import-module 'C:\Projects\psake'

set-alias time measure-command
set-alias psake invoke-psake

function dw { get-childitem $args | format-wide }

function grep ([string]$arg, [string]$filter="") {
  dir -r -filter $filter | select-string $arg
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
  param(
      [Parameter(Mandatory=$true, Position=0)]
      [string]$Task,
      [alias("e")]
      [string]$pbenv=$null,
      [alias("t")]
      [string[]]$tags=$null,
      [alias("s")]
      [string[]]$specs=$null,
      [alias("r")]
      [string]$run=$null
  )

  $props = @{}
  if ($pbenv) {
    $props.environment = $pbenv
  }
  $params = @{}
  if ($tags) {
    $params.tags = $tags
  }
  if ($specs) {
    $params.specs = $specs
  }
  if ($run) {
    $params.run = $run
  }

  invoke-psake $Task -properties $props -parameters $params
}
