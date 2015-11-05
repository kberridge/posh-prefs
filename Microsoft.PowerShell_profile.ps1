# Modules
import-module posh-hg
import-module 'C:\Projects\psake'
import-module PsGet
import-module psreadline

set-alias time measure-command
set-alias psake psglass

function foureyes { C:\projects\four-eyes\four-eyes\bin\debug\FourEyes.exe $args }

function cl($path) { cd $path; ls; }
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
  $excludes = '*.exe', '*.dll', '*.pdb', '*.resx', '*.doc', 
    '*.pdf', '*.map', '*.bmp', '*.png', '*.jpg', '*.psd',
    '*.db', '*.jar', '*.zip', '*.fla', '*.gif', '*.sqlite',
    '*.cache', '*.resources'
  dir -r -path $path -filter $filter -exclude $excludes |
    select-string $pattern
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

function hgpl {
  $out = hg pull -u
  $out

  $matches = $null
  foreach ($line in $out) {
    if($line -match "added (\d+) changesets") { break }
  }

  if ($matches) {
    hg sl -l $matches[1]
  }
}

function hgcloseoldbranch($branchname) {
  hg debugsetparent $branchname
  hg branch $branchname
  hg ci --close-branch -m "closes old branch"
}

function freshen() {
  psake build, dbmigrate; psake dbmigrate -e test;
}

function cleanvs([switch]$whatif) {
  if ($whatif) {
    ls . -include bin,obj -recurse | where{$_ -notmatch '.hg'} | remove-item -recurse -whatif
  }
  else {
    ls . -include bin,obj -recurse | where{$_ -notmatch '.hg'} | remove-item -recurse
  }
}

# option to make ctrl+L clear screen support my 2 line prompt
Set-PSReadlineOption -ExtraPromptLineCount 1

# Prompt w/ hg support
function prompt {
  $cwd = $pwd.Path
  if ( $cwd.length -ge 30 ) {
    $cwd = "..." + $cwd.substring($cwd.length - 30 + 4).trimstart(".")
  }
  $host.UI.RawUI.WindowTitle = $(get-location)
  Write-Host($cwd) -nonewline -foregroundcolor yellow

  # Mercurial Prompt
  Write-VcsStatus

  Write-Host
  return "> "
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
    [string]$configuration=$null,
    [alias("v")]
    [string]$version=$null,
    [alias("p")]
    [string]$publishProfile=$null,
    [alias("pwd")]
    [string[]]$certificatePassword=$null
  )

  if ($pbenv) { $properties.environment = $pbenv }
  if ($tags) { $parameters.tags = $tags }
  if ($specs) { $parameters.specs = $specs }
  if ($run) { $parameters.run = $run }  
  if ($configuration) { $properties.BuildConfiguration = $configuration }
  if ($version) { $properties.Version = $version }
  if ($publishProfile) { $properties.PublishProfile = $publishProfile }
  if ($certificatePassword) { $properties.CertificatePassword = $certificatePassword}

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

# Load Jump-Location profile
Import-Module 'C:\Users\kberridge\Documents\WindowsPowerShell\Modules\Jump.Location\Jump.Location.psd1'
