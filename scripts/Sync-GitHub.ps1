#requires -Version 7.2
[CmdletBinding()]
param(
    [string]$RepositoryPath = (Split-Path -Parent $PSScriptRoot),
    [string]$GitPath = 'git.exe',
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $false
$env:GIT_TERMINAL_PROMPT = '0'
$env:GCM_INTERACTIVE = 'Never'
$script:logPath = $null
$lockStream = $null

function Write-SyncLog([string]$Message) {
    $line = '[{0}] {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Message
    if ($script:logPath) {
        Add-Content -LiteralPath $script:logPath -Value $line -Encoding utf8
    }
    Write-Host $line
}

function Invoke-Git {
    param([string[]]$GitArguments, [switch]$AllowFailure)
    $output = & $GitPath -C $RepositoryPath @GitArguments 2>&1
    $code = $LASTEXITCODE
    $outputText = ($output | ForEach-Object { $_.ToString() }) -join "`n"
    if ($outputText) { Write-SyncLog $outputText }
    if ($code -ne 0 -and -not $AllowFailure) {
        throw "git $($GitArguments[0]) failed (exit $code). See the log for details."
    }
    return [pscustomobject]@{ Code = $code; Text = $outputText }
}

try {
    $GitPath = (Get-Command $GitPath -ErrorAction Stop).Source
    $RepositoryPath = (Get-Item -LiteralPath $RepositoryPath -Force).FullName
    $root = (Invoke-Git -GitArguments @('rev-parse', '--show-toplevel')).Text.Trim()
    if (-not [StringComparer]::OrdinalIgnoreCase.Equals(
        [IO.Path]::GetFullPath($root).TrimEnd('\', '/'),
        [IO.Path]::GetFullPath($RepositoryPath).TrimEnd('\', '/')
    )) {
        throw 'RepositoryPath must point to the repository root.'
    }

    $gitDirectory = (Invoke-Git -GitArguments @('rev-parse', '--absolute-git-dir')).Text.Trim()
    $script:logPath = Join-Path $gitDirectory 'github-sync.log'
    try {
        $lockStream = [IO.File]::Open(
            (Join-Path $gitDirectory 'github-sync.lock'),
            [IO.FileMode]::OpenOrCreate, [IO.FileAccess]::ReadWrite, [IO.FileShare]::None
        )
    } catch [IO.IOException] {
        Write-SyncLog 'Another sync is running. Skipped.'
        exit 0
    }

    Write-SyncLog "Starting sync: $RepositoryPath"
    $branch = (Invoke-Git -GitArguments @('symbolic-ref', '--quiet', '--short', 'HEAD')).Text.Trim()
    if ($branch -ne 'main') { throw "Expected branch main, found $branch. No files were staged." }
    foreach ($stateFile in @('index.lock', 'MERGE_HEAD', 'CHERRY_PICK_HEAD', 'REVERT_HEAD', 'rebase-merge', 'rebase-apply')) {
        if (Test-Path -LiteralPath (Join-Path $gitDirectory $stateFile)) {
            throw "Git operation is in progress ($stateFile). Finish it before syncing."
        }
    }
    $null = Invoke-Git -GitArguments @('remote', 'get-url', 'origin')

    if ($DryRun) {
        $null = Invoke-Git -GitArguments @('status', '--short')
        Write-SyncLog 'Dry run complete. No files staged, committed or pushed.'
        exit 0
    }

    # Check remote history before staging; never merge, rebase, reset, or force-push.
    $null = Invoke-Git -GitArguments @('fetch', '--no-tags', 'origin', 'refs/heads/main:refs/remotes/origin/main')
    $ancestry = Invoke-Git -GitArguments @('merge-base', '--is-ancestor', 'refs/remotes/origin/main', 'HEAD') -AllowFailure
    if ($ancestry.Code -ne 0) {
        throw 'Remote main has updates not in local main. Reconcile them manually before syncing.'
    }

    $null = Invoke-Git -GitArguments @('add', '--all', '--', '.')
    $diff = Invoke-Git -GitArguments @('diff', '--cached', '--quiet', '--exit-code') -AllowFailure
    if ($diff.Code -eq 1) {
        $message = 'chore: daily sync ' + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
        $null = Invoke-Git -GitArguments @('commit', '-m', $message)
    } elseif ($diff.Code -eq 0) {
        Write-SyncLog 'No new changes to commit.'
    } else {
        throw "Cannot inspect staged changes (exit $($diff.Code))."
    }

    # Push even with a clean working tree, so a previous failed push is retried.
    $null = Invoke-Git -GitArguments @('-c', 'push.followTags=false', 'push', 'origin', 'HEAD:refs/heads/main')
    Write-SyncLog 'Sync completed successfully.'
    exit 0
} catch {
    Write-SyncLog ('ERROR: ' + $_.Exception.Message)
    exit 1
} finally {
    if ($null -ne $lockStream) { $lockStream.Dispose() }
}
