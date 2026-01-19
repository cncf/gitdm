#!/usr/bin/env pwsh
param([Parameter(ValueFromRemainingArguments=$true)] [string[]]$Args)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$BaseDir = Join-Path $ScriptDir 'src'
$Engine  = Join-Path $BaseDir 'cncfdm.py'

function Test-Python2 {
  param(
    [Parameter(Mandatory=$true)] [string]$Exe,
    [string[]]$ExeArgs = @()
  )
  try {
    & $Exe @ExeArgs -c "import sys; sys.exit(0 if sys.version_info[0] == 2 else 1)" *> $null
    return ($LASTEXITCODE -eq 0)
  } catch {
    return $false
  }
}

function Pick-Python {
  # Allow override via environment variable.
  if ($env:GITDM_PY) {
    return [pscustomobject]@{ Exe = $env:GITDM_PY; Args = @() }
  }

  # Prefer Python Launcher (if Python 2 is installed).
  if (Get-Command py -ErrorAction SilentlyContinue) {
    if (Test-Python2 -Exe 'py' -ExeArgs @('-2')) {
      return [pscustomobject]@{ Exe = 'py'; Args = @('-2') }
    }
  }

  # Prefer explicit Python 2 binaries, then fall back to python only if it is v2.
  foreach ($cand in @('python2', 'pypy2', 'pypy', 'python')) {
    if (Get-Command $cand -ErrorAction SilentlyContinue) {
      if (Test-Python2 -Exe $cand) {
        return [pscustomobject]@{ Exe = $cand; Args = @() }
      }
    }
  }

  return $null
}

$py = Pick-Python
if (-not $py) {
  Write-Error 'gitdm requires Python 2 or PyPy. Install python2/pypy2 or set GITDM_PY.'
  exit 1
}

# Pass through stdin/stdout; add -b to point at src/
if ($MyInvocation.ExpectingInput) {
  $input | & $py.Exe @($py.Args) $Engine -b "$BaseDir/" @Args
} else {
  & $py.Exe @($py.Args) $Engine -b "$BaseDir/" @Args
}
exit $LASTEXITCODE
