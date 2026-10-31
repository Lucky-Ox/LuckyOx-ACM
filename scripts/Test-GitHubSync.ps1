#requires -Version 7.2
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$scriptUnderTest = Join-Path $PSScriptRoot 'Sync-GitHub.ps1'
$gitPath = (Get-Command git.exe -ErrorAction Stop).Source
$powerShellPath = (Get-Process -Id $PID).Path
$testRoot = Join-Path ([IO.Path]::GetTempPath()) ('LuckyOx ACM sync tests ' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $testRoot | Out-Null

function Git([string]$Directory, [string[]]$Arguments) {
    $output = & $gitPath -C $Directory @Arguments 2>&1
    if ($LASTEXITCODE -ne 0) { throw "Git fixture failed: $($Arguments -join ' ')`n$($output -join "`n")" }
    return ($output -join "`n")
}

function Assert([bool]$Condition, [string]$Message) {
    if (-not $Condition) { throw "FAIL: $Message" }
}

function Fixture([string]$Name) {
    $root = Join-Path $testRoot $Name
    New-Item -ItemType Directory -Path $root | Out-Null
    $remote = Join-Path $root 'remote.git'
    $local = Join-Path $root 'working copy'
    $null = Git $root @('init', '--bare', '--initial-branch=main', $remote)
    $null = Git $root @('clone', $remote, $local)
    $null = Git $local @('config', 'user.name', 'Sync Test')
    $null = Git $local @('config', 'user.email', 'sync-test@example.invalid')
    Set-Content -LiteralPath (Join-Path $local '.gitignore') -Value "*.exe`n.env`nbuild/"
    Set-Content -LiteralPath (Join-Path $local 'template.cpp') -Value '// original'
    Set-Content -LiteralPath (Join-Path $local 'obsolete.cpp') -Value '// obsolete'
    $null = Git $local @('add', '--all')
    $null = Git $local @('commit', '-m', 'fixture')
    $null = Git $local @('push', '-u', 'origin', 'main')
    return @{ Root = $root; Local = $local; Remote = $remote }
}

function Run-Sync([string]$Directory, [switch]$DryRun) {
    $arguments = @('-NoProfile', '-NonInteractive', '-File', $scriptUnderTest, '-RepositoryPath', $Directory, '-GitPath', $gitPath)
    if ($DryRun) { $arguments += '-DryRun' }
    $output = & $powerShellPath @arguments 2>&1
    return @{ Code = $LASTEXITCODE; Output = ($output -join "`n") }
}

$fixture = Fixture 'changes'
Set-Content -LiteralPath (Join-Path $fixture.Local 'template.cpp') -Value '// updated'
Set-Content -LiteralPath (Join-Path $fixture.Local '题解.cpp') -Value '// solution'
Remove-Item -LiteralPath (Join-Path $fixture.Local 'obsolete.cpp')
Set-Content -LiteralPath (Join-Path $fixture.Local 'program.exe') -Value 'ignored binary'
Set-Content -LiteralPath (Join-Path $fixture.Local '.env') -Value 'IGNORED_TEST_VALUE=example'
$before = Git $fixture.Local @('rev-parse', 'HEAD')
$result = Run-Sync $fixture.Local -DryRun
Assert ($result.Code -eq 0) "Dry run succeeds: $($result.Output)"
Assert ((Git $fixture.Local @('rev-parse', 'HEAD')) -eq $before) 'Dry run must not commit'
Assert ([string]::IsNullOrWhiteSpace((Git $fixture.Local @('diff', '--cached', '--name-only')))) 'Dry run must not stage'
Write-Output 'PASS: dry run leaves commits and index unchanged'

$result = Run-Sync $fixture.Local
Assert ($result.Code -eq 0) "Sync changes succeeds: $($result.Output)"
Assert ((Git $fixture.Remote @('show', 'main:template.cpp')) -eq '// updated') 'Modified source must reach remote'
Assert ((Git $fixture.Remote @('show', 'main:题解.cpp')) -eq '// solution') 'New Unicode filename must reach remote'
$files = Git $fixture.Remote @('-c', 'core.quotepath=false', 'ls-tree', '-r', '--name-only', 'main')
Assert (-not ($files -match 'obsolete\.cpp|program\.exe|(^|\n)\.env($|\n)')) 'Deleted files and ignored files must not appear on remote'
Assert ([string]::IsNullOrWhiteSpace((Git $fixture.Local @('status', '--porcelain')))) 'Sync leaves a clean working tree'
Write-Output 'PASS: sync includes additions, modifications and deletions, respecting .gitignore'

$before = Git $fixture.Local @('rev-parse', 'HEAD')
$result = Run-Sync $fixture.Local
Assert ($result.Code -eq 0) "Unchanged sync succeeds: $($result.Output)"
Assert ((Git $fixture.Local @('rev-parse', 'HEAD')) -eq $before) 'No changes must not create empty commits'
Write-Output 'PASS: unchanged run does not create a commit'

$fixture = Fixture 'retry push'
$hookPath = Join-Path $fixture.Remote 'hooks/pre-receive'
[IO.File]::WriteAllText($hookPath, "#!/bin/sh`nexit 1`n", [Text.UTF8Encoding]::new($false))
Set-Content -LiteralPath (Join-Path $fixture.Local 'template.cpp') -Value '// retry upload'
$remoteBefore = Git $fixture.Remote @('rev-parse', 'main')
$result = Run-Sync $fixture.Local
Assert ($result.Code -ne 0) 'A rejected push must report failure'
$localCommit = Git $fixture.Local @('rev-parse', 'HEAD')
Assert ($localCommit -ne $remoteBefore) 'Failed push must retain the local commit'
Assert ((Git $fixture.Remote @('rev-parse', 'main')) -eq $remoteBefore) 'Rejected push must not change remote'
[IO.File]::WriteAllText($hookPath, "#!/bin/sh`nexit 0`n", [Text.UTF8Encoding]::new($false))
$result = Run-Sync $fixture.Local
Assert ($result.Code -eq 0) "Clean working tree retries push: $($result.Output)"
Assert ((Git $fixture.Remote @('rev-parse', 'main')) -eq $localCommit) 'Next run must push the retained commit'
Assert ((Git $fixture.Local @('rev-parse', 'HEAD')) -eq $localCommit) 'Retry must not create a duplicate commit'
Write-Output 'PASS: failed push retains a commit and next run retries it'

$fixture = Fixture 'remote ahead'
$other = Join-Path $fixture.Root 'other checkout'
$null = Git $fixture.Root @('clone', $fixture.Remote, $other)
$null = Git $other @('config', 'user.name', 'Other Test')
$null = Git $other @('config', 'user.email', 'other-test@example.invalid')
Set-Content -LiteralPath (Join-Path $other 'remote.cpp') -Value '// remote update'
$null = Git $other @('add', '--all')
$null = Git $other @('commit', '-m', 'remote update')
$null = Git $other @('push', 'origin', 'main')
Set-Content -LiteralPath (Join-Path $fixture.Local 'template.cpp') -Value '// local work'
$before = Git $fixture.Local @('rev-parse', 'HEAD')
$result = Run-Sync $fixture.Local
Assert ($result.Code -ne 0) 'Remote-ahead history must stop syncing'
Assert ((Git $fixture.Local @('rev-parse', 'HEAD')) -eq $before) 'Remote-ahead check must stop before committing'
Assert ([string]::IsNullOrWhiteSpace((Git $fixture.Local @('diff', '--cached', '--name-only')))) 'Remote-ahead check must stop before staging'
Assert ((Get-Content -Raw -LiteralPath (Join-Path $fixture.Local 'template.cpp')).Trim() -eq '// local work') 'Local work must stay unchanged'
Write-Output 'PASS: remote updates stop the sync without changing local work'

$fixture = Fixture 'other branch'
$null = Git $fixture.Local @('switch', '-c', 'practice')
Set-Content -LiteralPath (Join-Path $fixture.Local 'template.cpp') -Value '// branch work'
$before = Git $fixture.Local @('rev-parse', 'HEAD')
$result = Run-Sync $fixture.Local
Assert ($result.Code -ne 0) 'Unexpected branch must stop syncing'
Assert ((Git $fixture.Local @('rev-parse', 'HEAD')) -eq $before) 'Unexpected branch must not be committed'
Write-Output 'PASS: unexpected branch is not committed or pushed'

$fixture = Fixture 'concurrent run'
$lockPath = Join-Path $fixture.Local '.git/github-sync.lock'
$lockStream = [IO.File]::Open($lockPath, [IO.FileMode]::OpenOrCreate, [IO.FileAccess]::ReadWrite, [IO.FileShare]::None)
try {
    Set-Content -LiteralPath (Join-Path $fixture.Local 'template.cpp') -Value '// pending work'
    $before = Git $fixture.Local @('rev-parse', 'HEAD')
    $result = Run-Sync $fixture.Local
    Assert ($result.Code -eq 0) "Overlapping run should skip: $($result.Output)"
    Assert ((Git $fixture.Local @('rev-parse', 'HEAD')) -eq $before) 'Overlapping run must not commit'
} finally {
    $lockStream.Dispose()
}
Write-Output 'PASS: overlapping runs skip without touching Git history'
Write-Output "All integration tests passed. Fixtures: $testRoot"
