function dw ([string]$arg) {
  get-childitem $arg | format-wide
}

function grep ([string]$arg, [string]$filter="") {
  dir -r -filter $filter | select-string $arg
}

function ff ([string]$arg) {
  dir -r -filter $arg
}

function rrm ([string]$arg) {
  rm -r -force $arg
}

$env:mydocs = "$env:userprofile\documents"

function mydocs { set-location $env:mydocs }
function editprofile { gvim $profile }
function editvimrc { gvim "C:\program files\vim\_vimrc" }

function prompt {
  $cwd = $pwd.Path
  if ( $cwd.length -ge 30 ) {
    $cwd = "..." + $cwd.substring($cwd.length - 30 + 4).trimstart(".")
  }
  $host.UI.RawUI.WindowTitle = $(get-location)
  Write-Host( "$cwd>" ) -nonewline -foregroundcolor yellow
  return " "
}

function su {
  Start-Process 'PowerShell.exe' -Verb runas -WorkingDir $pwd -ARg "-noexit -command & cd $pwd" 
}

$HOST.UI.RawUI.BackgroundColor = 5
$HOST.UI.RawUI.ForegroundColor = 6

cd C:\Projects

# Modules
import-module Pscx
import-module Posh-Hg

# Set up a simple prompt, adding the hg prompt parts inside hg repos
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
