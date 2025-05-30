$baseDir = "dev_build"
$components = @("grpedit", "modservice", "rsysconf", "scada")

foreach ($component in $components) {
$compPath = Join-Path $baseDir $component
$testsPath = Join-Path $compPath "tests"

New-Item -ItemType Directory -Path $testsPath -Force | Out-Null
New-Item -ItemType File -Path (Join-Path $compPath "distr.deb") -Force | Out-Null
New-Item -ItemType File -Path (Join-Path $compPath "syms.7z") -Force | Out-Null
New-Item -ItemType File -Path (Join-Path $testsPath "test_reports.txt.7z") -Force | Out-Null
New-Item -ItemType File -Path (Join-Path $testsPath "test_reports.xunit.7z") -Force | Out-Null
}

if (Get-Command tree -ErrorAction SilentlyContinue) {
tree $baseDir
} else {
Get-ChildItem $baseDir -Recurse
}