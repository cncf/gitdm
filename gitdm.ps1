#!/usr/bin/env pwsh
param([Parameter(ValueFromRemainingArguments=$true)] [string[]]$Args)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$BaseDir = Join-Path $ScriptDir 'src'
$Engine  = Join-Path $BaseDir 'cncfdm.py'

function Pick-Python {
  if ($env:GITDM_PY) { return $env:GITDM_PY }
  foreach ($cand in @('py -2','python2','pypy','pypy2')) {
    try {
      if ($cand -eq 'py -2') {
        & py -2 - <<'PY'
import sys
print(2 if sys.version_info[0]==2 else 3)
PY
        if ($LASTEXITCODE -eq 0) { return 'py -2' }
      } else {
        if (Get-Command ($cand.Split(' ')[0]) -ErrorAction SilentlyContinue) { return $cand }
      }
    } catch { }
  }
  if (Get-Command python -ErrorAction SilentlyContinue) {
    $ver = & python - <<'PY'
import sys
print(sys.version_info[0])
PY
    if ($ver -eq 2) { return 'python' }
  }
  return $null
}

$py = Pick-Python
if (-not $py) {
  Write-Error 'gitdm requires Python 2 or PyPy. Install python2/pypy or set GITDM_PY.'
  exit 1
}

# Pass through stdin/stdout; add -b to point at src/
& $py $Engine -b "$BaseDir/" @Args
exit $LASTEXITCODE