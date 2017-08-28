pushd "\projects"
if (-not (test-path "psake")) {
  git clone https://github.com/psake/psake.git
}
popd

$profilePath = split-path $profile
if (-not (test-path $profilePath)) { mkdir $profilePath > $null }
cp -r .\* $profilePath -exclude ".hg" -force
. $profile
