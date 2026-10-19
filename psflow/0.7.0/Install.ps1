[CmdletBinding()]
param(
  [string]$Root = '',
  [string]$SourceDir = '',
  [ValidateSet('', 'browser', 'local')][string]$Mode = '',
  [ValidateSet('', 'inspect', 'clear-cache', 'remove-local', 'uninstall-runtime', 'delete-user-data', 'remove-components', 'repair-runtime', 'rollback-app', 'install-local')][string]$Maintenance = '',
  [string]$ExpectedBuildId = '',
  [switch]$ConfirmDeleteData,
  [string]$RequestId = '',
  [ValidateRange(1,65535)][int]$Port = 47831
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
[Console]::OutputEncoding = New-Object Text.UTF8Encoding($false)
# A Core PowerShell parent may omit Windows PowerShell's built-in module path.
# This process-only path restores OS cmdlets without depending on PATH tools.
$env:PSModulePath = (Join-Path $PSHOME 'Modules') + [IO.Path]::PathSeparator + $env:PSModulePath
# Filled by build-distribution.py. This descriptor is pinned into both entrypoints.
$release = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('ewogICJzY2hlbWEiOiAicHNmbG93YnJpZGdlLmRpc3RyaWJ1dGlvbi8xIiwKICAidmVyc2lvbiI6ICIwLjcuMCIsCiAgImJhc2VVcmwiOiAiaHR0cHM6Ly9naXRodWIuY29tL3dlaXpoaTEyM3Nkby9xdWlja2VyLWRpc3QvcmVsZWFzZXMvZG93bmxvYWQvcHNmbG93LXYwLjcuMC8iLAogICJjb21wYW5pb24iOiB7CiAgICAic2NoZW1hIjogInBzZmxvd2JyaWRnZS5jb21wYW5pb24vMSIsCiAgICAicHJvZHVjdElkIjogIlBTRmxvd0JyaWRnZSIsCiAgICAicHJvdG9jb2xWZXJzaW9uIjogMSwKICAgICJzdXBwb3J0ZWRQcm90b2NvbCI6IHsKICAgICAgIm1pbiI6IDEsCiAgICAgICJtYXgiOiAxCiAgICB9LAogICAgIm1haW5BY3Rpb25TaGFyZUNvZGUiOiAiYTJkZTMzMGYtZGYwYi00MTJhLWJhMzItNDgzODNlM2MwNTVjIiwKICAgICJtYW5hZ2VyQWN0aW9uU2hhcmVDb2RlIjogImRjZGU0NDAzLWM2ZjItNGQ4MC04MjMxLWMwNzNlMjUwNGE3MSIKICB9LAogICJhcHAiOiB7CiAgICAiYnVpbGRJZCI6ICJkNjU5MjgwMjQ5NTNjZmM2IiwKICAgICJmaWxlbmFtZSI6ICJQU0Zsb3dCcmlkZ2UtUXVpY2tlci0wLjcuMC1kNjU5MjgwMjQ5NTNjZmM2LnppcCIsCiAgICAiYnl0ZXMiOiAzNjU1MjcsCiAgICAic2hhMjU2IjogImQ2NTkyODAyNDk1M2NmYzY0OGVhZjNmZjQ3YjJkYjY5Yzk1YjcyYTI2N2U4Zjk4MTg0MzNhNmM4NDQ1ZTNmMjIiLAogICAgIm1hbmlmZXN0U2hhMjU2IjogIjYwNjgyZmJhZjJkMzhiYzNlZmYwN2E3MTM5NGFiMmQ0MTFmMTBhNzg0ZWM3YjM0MTlkMWJkODI1NDc0ODc5NDEiCiAgfSwKICAicnVudGltZSI6IHsKICAgICJwYWNrYWdlRm9ybWF0IjogMywKICAgICJydW50aW1lSWQiOiAid2luLXg2NC1ub2RlMjQuMjIuMC04NjhhMmUyZDk4NmI4ZjRjLXIxIiwKICAgICJub2RlVmVyc2lvbiI6ICIyNC4yMi4wIiwKICAgICJkZXBlbmRlbmN5RmluZ2VycHJpbnQiOiAiODY4YTJlMmQ5ODZiOGY0YzBhYzQ4MThmMzM2YTI4ODA5YzY4YjQ4NTZmMjRhNTM1ODBhZGM2ZWQzMjA2OTc5OCIsCiAgICAiZmlsZW5hbWUiOiAicnVudGltZS13aW4teDY0LW5vZGUyNC4yMi4wLTg2OGEyZTJkOTg2YjhmNGMtcjEuemlwIiwKICAgICJieXRlcyI6IDQzNzc0MjQwLAogICAgInNoYTI1NiI6ICI4ODQ0MzQyMGM1MGQ2NDYzNGMxNDFkZjI1ODA1OWMzNzFiNDQwZWI3NmExYWNjZmRmYTJiNjRmZWNjZTg3MTNlIiwKICAgICJmaWxlc01hbmlmZXN0U2hhMjU2IjogImM4ZjBmYjU0ZDRkNmVhZDUxYzQyZGUxNDYzOGQ3MDI2NGIzZThiODhmOWIyN2JlNTA0ODM3NjA5NWZhZTcxMTgiLAogICAgInNvdXJjZVNoYTI1NiI6ICI1NGMxOTA2ZjcyNTk1ZWM5NGI4NWM0Y2E1ZDVlZTY0YjQyNzRmNTJjYTliY2ZkNGZhMjE4MWZlYjQzYzdjMjE3IiwKICAgICJ1cmwiOiAiaHR0cHM6Ly9naXRodWIuY29tL3dlaXpoaTEyM3Nkby9xdWlja2VyLWRpc3QvcmVsZWFzZXMvZG93bmxvYWQvcHNmbG93LXJ1bnRpbWUtbm9kZTI0LjIyLjAtc2hhcnAwLjM1LjUtcjEvcnVudGltZS13aW4teDY0LW5vZGUyNC4yMi4wLTg2OGEyZTJkOTg2YjhmNGMtcjEuemlwIgogIH0sCiAgImxvY2FsQmFja2VuZCI6IHsKICAgICJzY2hlbWEiOiAicHNmbG93YnJpZGdlLmxvY2FsLWJhY2tlbmQvMSIsCiAgICAicnVudGltZUlkIjogIndpbmRvd3MteDY0LWNweXRob24tMy4xMC4xMS1mbG93Y2xpLTEuMC4wIiwKICAgICJweXRob25WZXJzaW9uIjogIjMuMTAuMTEiLAogICAgImZpbGVuYW1lIjogImxvY2FsLWJhY2tlbmQtd2luZG93cy14NjQuemlwIiwKICAgICJieXRlcyI6IDM5MTY3MDIxNywKICAgICJzaGEyNTYiOiAiMmIyYjRiOWRlNWZhOGZmNGVkZmEyM2I0ZGRjYzI1N2ViMmM1NzZlZTYwZGU5ZWRlNTZhNDYwNGZiNzJlNTI0MSIsCiAgICAiZmlsZXNNYW5pZmVzdFNoYTI1NiI6ICI5YTY3ZmFjYzBiNjNjYmQ5Mjk1MzdkN2RmYWJkOWYyNjQ2ZWUxZjI1N2EwNjYwNzk5NTFkOTQzYjZlMTI5YmU4IiwKICAgICJmaWxlQ291bnQiOiAxNjY3LAogICAgImV4cGFuZGVkQnl0ZXMiOiA5MDgxNzI2MTIsCiAgICAic291cmNlIjogewogICAgICAidXBzdHJlYW1SZXBvIjogImh0dHBzOi8vZ2l0aHViLmNvbS9jZG0xNjg4OC9mbG93LWltYWdlLWNsaS1sb2NhbC1hcGkuZ2l0IiwKICAgICAgInVwc3RyZWFtQ29tbWl0IjogIjMyMzU0NTg1OGM3NzgzMjBiYTc1N2UxODBhMDQ5ODQ5OTNlMzJiZDMiLAogICAgICAidXBzdHJlYW1BdXRob3IiOiAiY2RtMTY4ODgiLAogICAgICAidXBzdHJlYW1MaWNlbnNlIjogIk1JVCIsCiAgICAgICJjcHl0aG9uRW1iZWRVcmwiOiAiaHR0cHM6Ly93d3cucHl0aG9uLm9yZy9mdHAvcHl0aG9uLzMuMTAuMTEvcHl0aG9uLTMuMTAuMTEtZW1iZWQtYW1kNjQuemlwIiwKICAgICAgImNweXRob25FbWJlZFNoYTI1NiI6ICI2MDg2MTlmODYxOTA3NTYyOWM5YzY5ZjM2MTM1MmEwZGE2ZWQ3ZTYyZjgzYTBlMTljNjNlMGVhMzJlYjc2MjlkIiwKICAgICAgInJ1bnRpbWVCdWlsZElkIjogImEzYmNiMWE2OGY1MmFlODgwNjJlNzViOGQ4OTQwY2Y1YzEwNjRmNjgyNTc5MDk3NTJmZDc5ODIyMDBmMTA0NDYiLAogICAgICAicGF0Y2hDb3VudCI6IDcsCiAgICAgICJ3aGVlbENvdW50IjogMjUKICAgIH0sCiAgICAiYm9vdHN0cmFwQ29udHJhY3QiOiB7CiAgICAgICJydW50aW1lU3ViZGlyIjogInJ1bnRpbWUvZmxvdy1hcGkiLAogICAgICAicHl0aG9uUGF0aCI6ICJydW50aW1lL2Zsb3ctYXBpLy52ZW52L1NjcmlwdHMvcHl0aG9uLmV4ZSIsCiAgICAgICJlbnRyeU1vZHVsZSI6ICJmbG93X2NsaS5hcGlfc2VydmVyIiwKICAgICAgImRlZmF1bHRBcmdzIjogWwogICAgICAgICItbSIsCiAgICAgICAgImZsb3dfY2xpLmFwaV9zZXJ2ZXIiLAogICAgICAgICItLWhvc3QiLAogICAgICAgICIxMjcuMC4wLjEiLAogICAgICAgICItLXBvcnQiLAogICAgICAgICI4Nzg3IgogICAgICBdLAogICAgICAicmVxdWlyZWRFbnYiOiB7CiAgICAgICAgIlBMQVlXUklHSFRfQlJPV1NFUlNfUEFUSCI6ICJ7cnVudGltZVJvb3R9Ly5sb2NhbC1icm93c2VycyIsCiAgICAgICAgIlBZVEhPTlVURjgiOiAiMSIsCiAgICAgICAgIlBZVEhPTklPRU5DT0RJTkciOiAidXRmLTgiCiAgICAgIH0KICAgIH0sCiAgICAidXJsIjogImh0dHBzOi8vZ2l0aHViLmNvbS93ZWl6aGkxMjNzZG8vcXVpY2tlci1kaXN0L3JlbGVhc2VzL2Rvd25sb2FkL3BzZmxvdy1sb2NhbC1weXRob24zMTAxMS1wbGF5d3JpZ2h0MTY0LXIxL2xvY2FsLWJhY2tlbmQtd2luZG93cy14NjQuemlwIgogIH0sCiAgIm1pcnJvcnMiOiBbCiAgICAiaHR0cHM6Ly9naXRlZS5jb20vd2VpemhpT1dPL3F1aWNrZXItYWN0aW9ucy9yYXcvbWFpbi9wc2Zsb3cvMC43LjAvIiwKICAgICJodHRwczovL2dpdGh1Yi5jb20vd2VpemhpMTIzc2RvL3F1aWNrZXItZGlzdC9yZWxlYXNlcy9kb3dubG9hZC9wc2Zsb3ctdjAuNy4wLyIKICBdCn0=')) | ConvertFrom-Json
if (-not $Root) { $Root = Join-Path $env:LOCALAPPDATA 'PSFlowBridge' }
$Root = [IO.Path]::GetFullPath($Root)
$appsDir = Join-Path $Root 'apps'
$portableDir = Join-Path $Root 'runtime\portable'
$utf8 = New-Object Text.UTF8Encoding($false)
$statusFile = $env:PSFB_INSTALL_STATUS_FILE
$progressFile = $env:PSFB_INSTALL_PROGRESS_FILE
$lastProgress = -1
$progressWriteError = ''
$mutex = New-Object Threading.Mutex($false, 'Local\PSFlowBridgeDistribution')
$locked = $false
$bootstrapStarted = $false
$targetRoot = ''
$driverRoot = ''
$oldName = ''
$oldBinding = $null
$oldPointers = @{}
$modeFile = Join-Path $Root 'mode.json'
$oldModeText = $null
$modeChanged = $false

function Fail([string]$Code,[string]$Message) { throw ($Code + ': ' + $Message) }

function Hash([string]$File) {
  $algorithm=[Security.Cryptography.SHA256]::Create();$stream=[IO.File]::OpenRead($File)
  try { return [BitConverter]::ToString($algorithm.ComputeHash($stream)).Replace('-','').ToLowerInvariant() }
  finally { $stream.Dispose();$algorithm.Dispose() }
}
function Inside([string]$Base,[string]$Relative) {
  $boundary = [IO.Path]::GetFullPath($Base).TrimEnd('\') + '\'
  $result = [IO.Path]::GetFullPath((Join-Path $Base $Relative))
  if (-not $result.StartsWith($boundary,[StringComparison]::OrdinalIgnoreCase)) { Fail 'path_invalid' 'Archive path is outside its destination.' }
  return $result
}
function AtomicText([string]$File,[string]$Text) {
  [IO.Directory]::CreateDirectory((Split-Path -Parent $File)) | Out-Null
  $temporary = $File + '.' + [guid]::NewGuid().ToString('N') + '.tmp'
  try {
    [IO.File]::WriteAllText($temporary,$Text,$utf8)
    if (Test-Path -LiteralPath $File) { [IO.File]::Replace($temporary,$File,[Management.Automation.Language.NullString]::Value) }
    else { [IO.File]::Move($temporary,$File) }
  } finally { if (Test-Path -LiteralPath $temporary) { Remove-Item -LiteralPath $temporary -Force } }
}
function Now([string]$Phase,[string]$Detail = '',[int]$Percent = -1,[int]$GlobalStart = -1,[int]$GlobalEnd = -1) {
  if (-not $progressFile) { return }
  if ($Percent -ge 0 -and $GlobalStart -ge 0 -and $GlobalEnd -ge $GlobalStart) {
    $span = $GlobalEnd - $GlobalStart
    if ($span -gt 0) {
      $scaled = [int][math]::Floor($GlobalStart + ($Percent * $span) / 100)
      if ($scaled -lt $GlobalStart) { $scaled = $GlobalStart }
      if ($scaled -gt $GlobalEnd) { $scaled = $GlobalEnd }
      $Percent = $scaled
    } else {
      $Percent = $GlobalStart
    }
  }
  if ($Percent -ge 0) {
    if ($Percent -ge 100 -and $Phase -ne 'complete') { $Percent = 99 }
    if ($Percent -lt $lastProgress) { $Percent = $lastProgress }
    $script:lastProgress = $Percent
  }
  try { AtomicText $progressFile (@{phase=$Phase;detail=$Detail;percent=$Percent;updatedAt=[DateTime]::UtcNow.ToString('o')}|ConvertTo-Json -Compress) }
  catch {
    # Progress reporting is diagnostic only: one write failure must not abort
    # the install, but it must not disappear either.
    if (-not $script:progressWriteError) {
      $script:progressWriteError = $_.Exception.Message
      [Console]::Error.WriteLine('PSFB_PROGRESS_WRITE_FAILED: ' + $script:progressWriteError)
    }
  }
}
function Remove-IfExists([string]$Path) {
  if (-not (Test-Path -LiteralPath $Path)) { return }
  $resolved = [IO.Path]::GetFullPath($Path)
  if (-not $resolved.StartsWith([IO.Path]::GetFullPath($Root).TrimEnd('\') + '\',[StringComparison]::OrdinalIgnoreCase)) { Fail 'path_invalid' 'Removal target is outside the application data root.' }
  Remove-Item -LiteralPath $resolved -Recurse -Force
}
function RemoveStage([string]$Stage,[string]$Base) {
  if (-not (Test-Path -LiteralPath $Stage)) { return }
  $resolved = Inside $Base (Split-Path -Leaf $Stage)
  if ($resolved -ne [IO.Path]::GetFullPath($Stage) -or (Split-Path -Leaf $Stage) -notlike '.staging-*') { Fail 'path_invalid' 'Unsafe staging cleanup refused.' }
  if ((Get-Item -LiteralPath $Stage).Attributes -band [IO.FileAttributes]::ReparsePoint) { Fail 'path_invalid' 'Staging reparse point refused.' }
  Remove-Item -LiteralPath $resolved -Recurse -Force
}
function CurrentName([string]$Pointer = 'current') {
  $file = Join-Path $appsDir $Pointer
  if (-not (Test-Path -LiteralPath $file -PathType Leaf)) { return '' }
  $name = [IO.File]::ReadAllText($file).Trim()
  if ($name -notmatch '^[0-9a-f]{16}(?:-repair-[0-9a-f]+)?$') { Fail 'pointer_invalid' 'Application pointer is invalid.' }
  return $name
}
function ReadHealth {
  $configFile = Join-Path $Root 'config.json'
  if (-not (Test-Path -LiteralPath $configFile -PathType Leaf)) { return $null }
  $config = [IO.File]::ReadAllText($configFile) | ConvertFrom-Json
  if (-not $config.pairingToken) { return $null }
  try {
    return Invoke-RestMethod -Uri ('http://127.0.0.1:' + $Port + '/api/health') -Headers @{ Authorization = ('Bearer ' + $config.pairingToken) } -TimeoutSec 2
  } catch { return $null }
}
function ProbeHealth {
  $request = [Net.HttpWebRequest]::Create('http://127.0.0.1:' + $Port + '/api/health')
  $request.Method = 'GET'; $request.Timeout = 3000; $request.ReadWriteTimeout = 3000; $request.UserAgent = 'PSFlowBridge-Installer'
  $configFile = Join-Path $Root 'config.json'
  if (Test-Path -LiteralPath $configFile -PathType Leaf) {
    try { $token = ([IO.File]::ReadAllText($configFile) | ConvertFrom-Json).pairingToken; if ($token) { $request.Headers['Authorization'] = 'Bearer ' + $token } } catch { }
  }
  try {
    $response = $request.GetResponse()
    try {
      $reader = New-Object IO.StreamReader($response.GetResponseStream())
      $body = $reader.ReadToEnd(); $reader.Dispose()
    } finally { $response.Dispose() }
    $health = $body | ConvertFrom-Json
    if ($health.app -ne 'PSFlowBridge' -or $null -eq $health.busy -or $health.busy -isnot [bool]) {
      Fail 'maintenance_unknown' 'Cannot confirm helper service status; maintenance aborted.'
    }
    $active = $health.activeTasks
    if ($null -eq $active -or $active -is [bool] -or $active -notmatch '^\d+$') {
      Fail 'maintenance_unknown' 'Cannot query helper active tasks; maintenance aborted.'
    }
    $activeTasks = [int]$active
    if ($activeTasks -eq 0 -and -not [bool]$health.busy) {
      if ($health.draining) { Fail 'maintenance_busy' 'Helper service is draining; maintenance postponed.' }
      return $true
    }
    $jobs = ReadJobs
    $live = @($jobs | Where-Object { $_.status -in @('uploading','queued','attaching','waiting_user','generating','downloading','importing') -or ($_.status -eq 'unknown' -and -not $_.waitingStopped) })
    if ($live.Count -gt 0) {
      Fail 'maintenance_busy' ('Helper has ' + $live.Count + ' active task(s); maintenance postponed.')
    }
    if ($activeTasks -eq 0 -and -not $health.draining) { return $true }
    Fail 'maintenance_unknown' 'Helper service status uncertain; maintenance aborted.'
  } catch [System.Net.WebException] {
    return $false
  }
}
function ReadJobs {
  $jobsDir = Join-Path $Root 'jobs'
  if (-not (Test-Path -LiteralPath $jobsDir -PathType Container)) { return @() }
  $result = @()
  # Job rows live in jobs/<id>/job.json; a recursive enumeration cannot be
  # shadowed by an adjacent directory created between the check and the loop.
  foreach ($file in [IO.Directory]::EnumerateFiles($jobsDir,'job.json',[IO.SearchOption]::AllDirectories)) {
    try { $job = [IO.File]::ReadAllText($file) | ConvertFrom-Json; if ($job) { $result += $job } } catch { }
  }
  return $result
}
function RequireIdle { ProbeHealth | Out-Null }
function ValidArchive([string]$File,$Artifact) {
  return (Test-Path -LiteralPath $File -PathType Leaf) -and (Get-Item -LiteralPath $File).Length -eq [long]$Artifact.bytes -and (Hash $File) -eq $Artifact.sha256
}
function DownloadArtifact([Uri]$Download,$Temporary,$Artifact,[long]$ArtifactBytes,[int]$GlobalStart,[int]$GlobalEnd) {
  $request = [Net.HttpWebRequest]::Create($Download)
  $request.Timeout = 120000; $request.ReadWriteTimeout = 45000
  $request.UserAgent = 'PSFlowBridge-Installer'
  Now 'download' ('Downloading ' + $Artifact.filename + ' from ' + $Download.Host + ' (0 MB / ' + [math]::Round($ArtifactBytes/1MB,1) + ' MB)') 0 $GlobalStart $GlobalEnd
  try { $response = $request.GetResponse() }
  catch {
    $status = 0
    $webError = $_.Exception
    if ($webError -isnot [Net.WebException] -and $webError.GetBaseException() -is [Net.WebException]) { $webError = $webError.GetBaseException() }
    if ($webError -is [Net.WebException] -and $webError.Response) { $status = [int]$webError.Response.StatusCode }
    if ($status -eq 0) { return 'Cannot connect to download server.' }
    return $(switch ($status) {
      404 { 'Remote release artifact missing (404).' }
      403 { 'Remote download access denied (403).' }
      429 { 'Remote download rate limited (429).' }
      default { 'Download failed (HTTP ' + $status + ').' }
    })
  }
  try {
    $inputStream = $null; $outputStream = $null
    try {
      $inputStream = $response.GetResponseStream()
      if (Test-Path -LiteralPath $Temporary) { Remove-Item -LiteralPath $Temporary -Force }
      $outputStream = [IO.File]::Create($Temporary)
      $buffer = New-Object byte[] 65536; [long]$received = 0; $lastReport = [long]0
      while (($read = $inputStream.Read($buffer,0,$buffer.Length)) -gt 0) {
        $received += $read
        if ($received -gt $ArtifactBytes) { return 'Download exceeds its pinned size.' }
        if ($received - $lastReport -ge 4MB) {
          $lastReport = $received
          $percent = [int][math]::Floor(($received / $ArtifactBytes) * 100)
          if ($percent -gt 100) { $percent = 100 }
          Now 'download' ('Downloading ' + $Artifact.filename + ' (' + [math]::Round($received/1MB,1) + ' MB / ' + [math]::Round($ArtifactBytes/1MB,1) + ' MB)') $percent $GlobalStart $GlobalEnd
        }
        $outputStream.Write($buffer,0,$read)
      }
      Now 'download' ('Downloaded ' + $Artifact.filename + ' (' + [math]::Round($received/1MB,1) + ' MB)') 100 $GlobalStart $GlobalEnd
    } finally {
      if ($outputStream) { $outputStream.Dispose() }
      if ($inputStream) { $inputStream.Dispose() }
    }
  } finally { $response.Dispose() }
  return ''
}
function GetArchive($Artifact,[int]$GlobalStart = 0,[int]$GlobalEnd = 100) {
  if ($Artifact.filename -notmatch '^[A-Za-z0-9._-]+$' -or $Artifact.sha256 -notmatch '^[0-9a-f]{64}$' -or [long]$Artifact.bytes -le 0) { Fail 'descriptor_invalid' 'Invalid pinned artifact descriptor.' }
  $cache = Join-Path $Root ('downloads\' + $Artifact.filename)
  if (ValidArchive $cache $Artifact) { return $cache }
  [IO.Directory]::CreateDirectory((Split-Path -Parent $cache)) | Out-Null
  $temporary = $cache + '.' + [guid]::NewGuid().ToString('N') + '.tmp'
  try {
    $source = if($SourceDir){Join-Path $SourceDir $Artifact.filename}else{''}
    if ($source -and (Test-Path -LiteralPath $source -PathType Leaf)) {
      if (-not (ValidArchive $source $Artifact)) { Fail 'artifact_corrupt' 'Offline artifact size or SHA-256 does not match the release.' }
      Now 'download' ('Checking cached ' + $Artifact.filename) 0 $GlobalStart $GlobalEnd
      Copy-Item -LiteralPath $source -Destination $temporary
      Now 'download' ('Loaded cached ' + $Artifact.filename) 100 $GlobalStart $GlobalEnd
    } else {
      # Try the pinned URL, then every mirror, then baseUrl. A source that
      # returns 404/403/429 or a bad archive falls through to the next one.
      $candidates = New-Object System.Collections.Generic.List[string]
      if ($Artifact.PSObject.Properties['url'] -and $Artifact.url) { $candidates.Add([string]$Artifact.url) }
      if ($release.PSObject.Properties['mirrors'] -and $release.mirrors) {
        foreach ($mirror in @($release.mirrors)) {
          if ($mirror) { $candidates.Add(([string]$mirror).TrimEnd('/') + '/' + [string]$Artifact.filename) }
        }
      }
      if ($release.PSObject.Properties['baseUrl'] -and $release.baseUrl) {
        $candidates.Add(([string]$release.baseUrl).TrimEnd('/') + '/' + [string]$Artifact.filename)
      }
      $downloads = New-Object System.Collections.Generic.List[Uri]
      $seen = @{}
      foreach ($candidate in $candidates) {
        if ($seen.ContainsKey($candidate)) { continue }
        $seen[$candidate] = $true
        $uri = $null
        try { $uri = [Uri]$candidate } catch { continue }
        if (-not $uri.IsAbsoluteUri -or $uri.UserInfo -or $uri.Query -or $uri.Fragment -or ($uri.Scheme -ne 'https' -and -not ($uri.Scheme -eq 'http' -and $uri.IsLoopback))) { continue }
        $downloads.Add($uri)
      }
      if ($downloads.Count -eq 0) { Fail 'download_url_invalid' 'Download hosting must use HTTPS.' }
      $artifactBytes = [long]$Artifact.bytes
      $failures = New-Object System.Collections.Generic.List[string]
      $done = $false
      foreach ($download in $downloads) {
        $errorText = DownloadArtifact $download $temporary $Artifact $artifactBytes $GlobalStart $GlobalEnd
        if ($errorText) { $failures.Add($download.Host + ': ' + $errorText); continue }
        if (-not (ValidArchive $temporary $Artifact)) {
          if (Test-Path -LiteralPath $temporary) { Remove-Item -LiteralPath $temporary -Force }
          $failures.Add($download.Host + ': Downloaded artifact size or SHA-256 does not match the release.')
          continue
        }
        $done = $true
        break
      }
      if (-not $done) { Fail 'download_failed' ('Download failed: ' + ($failures -join ' | ')) }
    }
    if (-not (ValidArchive $temporary $Artifact)) { Fail 'artifact_corrupt' 'Downloaded artifact size or SHA-256 does not match the release.' }
    if (Test-Path -LiteralPath $cache) { [IO.File]::Replace($temporary,$cache,[Management.Automation.Language.NullString]::Value) }
    else { [IO.File]::Move($temporary,$cache) }
    return $cache
  } finally { if (Test-Path -LiteralPath $temporary) { Remove-Item -LiteralPath $temporary -Force } }
}
function ExpandChecked([string]$Archive,[string]$Destination,[long]$MaxBytes,[int]$GlobalStart = 0,[int]$GlobalEnd = 100) {
  Add-Type -AssemblyName System.IO.Compression.FileSystem
  [IO.Directory]::CreateDirectory($Destination) | Out-Null
  $zip = [IO.Compression.ZipFile]::OpenRead($Archive)
  Now 'verify' ('Verifying and expanding ' + (Split-Path -Leaf $Archive)) 0 $GlobalStart $GlobalEnd
  $expanded = 0
  try {
    if ($zip.Entries.Count -gt 10000) { Fail 'archive_limit' 'Too many archive entries.' }
    [long]$total = 0
    foreach ($entry in $zip.Entries) {
      $total += $entry.Length
      if ($total -gt $MaxBytes) { Fail 'archive_limit' 'Archive expansion budget exceeded.' }
      if ($entry.FullName -match '(^[\\/]|:)' -or $entry.FullName -match '(^|[\\/])\.\.([\\/]|$)') { Fail 'path_invalid' 'Unsafe archive entry.' }
      $file = Inside $Destination $entry.FullName
      if (-not $entry.Name) { [IO.Directory]::CreateDirectory($file) | Out-Null; continue }
      [IO.Directory]::CreateDirectory((Split-Path -Parent $file)) | Out-Null
      $source = $entry.Open(); $sink = [IO.File]::Create($file)
      try { $source.CopyTo($sink) } finally { $sink.Dispose(); $source.Dispose() }
      $expanded++
      if ($expanded % 500 -eq 0) {
        $percent = [int][math]::Floor(($expanded / $zip.Entries.Count) * 100)
        if ($percent -gt 99) { $percent = 99 }
        Now 'verify' ('Expanding ' + (Split-Path -Leaf $Archive) + ' (' + $expanded + '/' + $zip.Entries.Count + ' files)') $percent $GlobalStart $GlobalEnd
      }
    }
    Now 'verify' ('Expanded ' + (Split-Path -Leaf $Archive) + ' (' + $expanded + ' files); verifying manifests') 99 $GlobalStart $GlobalEnd
  } finally { $zip.Dispose() }
}
function TestRuntime([string]$Directory,$Pin) {
  try {
    $manifestFile = Join-Path $Directory 'runtime-files.json'
    if ((Hash $manifestFile) -ne $Pin.filesManifestSha256) { return $false }
    $manifest = [IO.File]::ReadAllText($manifestFile) | ConvertFrom-Json
    if ($manifest.schema -ne 'psflowbridge.runtime-files/1') { return $false }
    foreach ($entry in $manifest.files) {
      $file = Inside $Directory $entry.path
      if (-not (Test-Path -LiteralPath $file -PathType Leaf) -or (Get-Item -LiteralPath $file).Length -ne $entry.bytes -or (Hash $file) -ne $entry.sha256) { return $false }
    }
    return $manifest.files.Count -gt 0 -and (Test-Path -LiteralPath (Join-Path $Directory 'node.exe')) -and (Test-Path -LiteralPath (Join-Path $Directory 'node_modules\sharp'))
  } catch { return $false }
}
function TestApp([string]$Directory,[string]$ManifestHash = '') {
  try {
    $manifestFile = Join-Path $Directory 'manifest.json'
    if ($ManifestHash -and (Hash $manifestFile) -ne $ManifestHash) { return $false }
    $manifest = [IO.File]::ReadAllText($manifestFile) | ConvertFrom-Json
    if ($manifest.schema -ne 'psflowbridge.package/1' -or -not $manifest.files.Count) { return $false }
    foreach ($entry in $manifest.files) {
      if (-not $entry.entry.StartsWith('PSFlowBridge-package/')) { return $false }
      $file = Inside $Directory $entry.entry.Substring(21)
      if (-not (Test-Path -LiteralPath $file -PathType Leaf) -or (Hash $file) -ne $entry.sha256) { return $false }
    }
    return $true
  } catch { return $false }
}
function Binding([string]$Name) {
  $file = Join-Path $appsDir ($Name + '\runtime-binding.json')
  if (Test-Path -LiteralPath $file -PathType Leaf) { return [IO.File]::ReadAllText($file) | ConvertFrom-Json }
  return $null
}
function RunLocalPython([string]$Python,[string]$Script,[string]$Extra = '') {
  $psi = New-Object Diagnostics.ProcessStartInfo
  $psi.FileName = $Python
  $psi.Arguments = '"' + $Script + '"' + $Extra
  $psi.UseShellExecute = $false; $psi.CreateNoWindow = $true; $psi.WindowStyle = 'Hidden'
  $psi.RedirectStandardOutput = $true; $psi.RedirectStandardError = $true
  $psi.WorkingDirectory = Split-Path -Parent $Python
  $psi.EnvironmentVariables['PSFB_ROOT'] = $Root
  $psi.EnvironmentVariables['FLOW_CLI_HOME'] = Join-Path $Root 'flow-state'
  $psi.EnvironmentVariables['FLOW_CONFIG'] = Join-Path $Root 'flow-state\config.toml'
  $psi.EnvironmentVariables['PYTHONUTF8'] = '1'
  $psi.EnvironmentVariables.Remove('PYTHONHOME'); $psi.EnvironmentVariables.Remove('PYTHONPATH')
  $process = [Diagnostics.Process]::Start($psi)
  try {
    $output = $process.StandardOutput.ReadToEndAsync(); $errors = $process.StandardError.ReadToEndAsync()
    if(-not $process.WaitForExit(20000)){try{$process.Kill()}catch{};Fail 'local_selftest_failed' 'Python backend self-test timed out.'}
    if($process.ExitCode -ne 0){Fail 'local_selftest_failed' 'Local backend self-test failed.'}
  } finally { $process.Dispose() }
}
function TestLocalFiles([string]$Directory,$Pin) {
  try {
    $file = Join-Path $Directory 'local-backend-files.json'
    if((Hash $file) -ne $Pin.filesManifestSha256){return $false}
    $manifest = [IO.File]::ReadAllText($file) | ConvertFrom-Json
    if($manifest.schema -ne 'psflowbridge.local-backend-files/1' -or $manifest.runtimeId -ne $Pin.runtimeId -or -not $manifest.files.Count){return $false}
    foreach($entry in $manifest.files){$path=Inside $Directory $entry.path;if(-not(Test-Path -LiteralPath $path -PathType Leaf) -or (Get-Item -LiteralPath $path).Length -ne $entry.bytes -or (Hash $path) -ne $entry.sha256){return $false}}
    return (Test-Path -LiteralPath (Join-Path $Directory '.venv\Scripts\python.exe')) -and (Test-Path -LiteralPath (Join-Path $Directory 'flow_cli\api_server.py'))
  } catch { return $false }
}
function EnsureLocalBackend([string]$Application) {
  # A non-owned listener on the fixed backend port is someone else's session
  # (another install, or the sender machine's own backend). Refuse before the
  # staged interpreter is promoted so the running service is never disturbed.
  $expectedBuildId = ''
  if ($release.PSObject.Properties['localBackend'] -and $release.localBackend) {
    if ($release.localBackend.PSObject.Properties['runtimeBuildId']) { $expectedBuildId = [string]$release.localBackend.runtimeBuildId }
    elseif ($release.localBackend.PSObject.Properties['source'] -and $release.localBackend.source.PSObject.Properties['runtimeBuildId']) { $expectedBuildId = [string]$release.localBackend.source.runtimeBuildId }
  }
  $foreignListener = @(Get-NetTCPConnection -State Listen -LocalPort 8787 -ErrorAction SilentlyContinue)
  if ($foreignListener.Count -gt 0) {
    $boundary = [IO.Path]::GetFullPath($Root).TrimEnd('\') + '\'
    $allOwned = $true
    foreach ($listener in $foreignListener) {
      $owner = Get-CimInstance Win32_Process -Filter ("ProcessId=" + $listener.OwningProcess) -ErrorAction SilentlyContinue
      $path = [string]$owner.ExecutablePath
      if (-not $path -or -not $path.StartsWith($boundary,[StringComparison]::OrdinalIgnoreCase)) {
        $allOwned = $false
        break
      }
    }
    if (-not $allOwned) {
      $isCompatibleReused = $false
      $backendCfgFile = Join-Path $Root 'backend.json'
      if (Test-Path -LiteralPath $backendCfgFile -PathType Leaf) {
        try {
          $backendCheck = Invoke-RestMethod -Uri 'http://127.0.0.1:8787/health' -TimeoutSec 2 -ErrorAction Stop
          if ($backendCheck -and $backendCheck.app -eq 'PSFlowBridge-FlowAPI' -and $backendCheck.status -eq 'ok' -and -not $backendCheck.draining) {
            $liveBuildId = [string]$backendCheck.runtimeBuildId
            if ($expectedBuildId -and $liveBuildId -eq $expectedBuildId) {
              $cfg = [IO.File]::ReadAllText($backendCfgFile) | ConvertFrom-Json
              if ($cfg -and $cfg.enabled -and $cfg.apiKey -and [string]$cfg.apiKey.Length -ge 16) {
                $modelsResp = Invoke-RestMethod -Uri 'http://127.0.0.1:8787/v1/models' -Headers @{ Authorization = ('Bearer ' + $cfg.apiKey) } -TimeoutSec 2 -ErrorAction Stop
                if ($modelsResp -and $modelsResp.data) {
                  $isCompatibleReused = $true
                }
              }
            }
          }
        } catch { }
      }
      if (-not $isCompatibleReused) {
        Fail 'local_runtime_busy' 'Port 8787 is occupied by an external unverified process.'
      }
    }
  }
  $directory = Join-Path $Root 'runtime\flow-api'
  $newBackend = $false
  if(-not $release.PSObject.Properties['localBackend'] -or -not $release.localBackend){Fail 'local_runtime_missing' 'Local backend not packaged.'}
  $pin = $release.localBackend
  if(-not (TestLocalFiles $directory $pin)) {
    # Runs after the runtime self-test has already reported 90 percent, so the
    # local backend must occupy the remaining 90-99 band instead of 65-93.
    $archive = GetArchive $pin 90 94
    $parent = Split-Path -Parent $directory
    $stage = Join-Path $parent ('.staging-' + [guid]::NewGuid().ToString('N'))
    $backup = Join-Path $parent ('.staging-' + [guid]::NewGuid().ToString('N'))
    $oldMoved = $false
    $promoted = $false
    try {
      ExpandChecked $archive $stage 1073741824 94 97
      if(-not(TestLocalFiles $stage $pin)){Fail 'local_runtime_invalid' 'Staged Python backend integrity failed.'}
      Now 'verify' 'Local Python backend verified; running self-test' 97
      $probe = Join-Path $Root ('logs\local-probe-' + [guid]::NewGuid().ToString('N') + '.py')
      [IO.Directory]::CreateDirectory((Split-Path -Parent $probe)) | Out-Null
      try {
        [IO.File]::WriteAllText($probe,"import sys`nfrom pathlib import Path`nsys.path.insert(0, str(Path(sys.argv[1])))`nimport flow_cli.api_server`n",$utf8)
        RunLocalPython (Join-Path $stage '.venv\Scripts\python.exe') $probe (' "' + $stage + '"')
      } finally {if(Test-Path -LiteralPath $probe){Remove-Item -LiteralPath $probe -Force}}
      if(Test-Path -LiteralPath $directory){
        if((Get-Item -LiteralPath $directory).Attributes -band [IO.FileAttributes]::ReparsePoint){Fail 'path_invalid' 'Backend reparse point refused.'}
        [IO.Directory]::Move($directory,$backup)
        $oldMoved = $true
      }
      [IO.Directory]::Move($stage,$directory)
      $promoted = $true
      $newBackend = $true
      RunLocalPython (Join-Path $directory '.venv\Scripts\python.exe') (Join-Path $Application 'backend\prepare-runtime.py')
    } catch {
      if($promoted){Remove-IfExists $directory}
      if($oldMoved -and (Test-Path -LiteralPath $backup)){[IO.Directory]::Move($backup,$directory)}
      throw
    } finally {RemoveStage $stage $parent}
    # The new backend is committed. Backup cleanup must not enter the rollback
    # handler: a partial cleanup cannot be used to restore the old installation.
    if($oldMoved){try{RemoveStage $backup $parent}catch{Now 'verify' 'Old backend backup retained for manual cleanup' 98}}
  }
  # Existing complete environments keep their original package graph. A clean
  # first install initializes credentials locally, after all executable files pass.
  if($newBackend -or -not(Test-Path -LiteralPath (Join-Path $Root 'backend.json'))){
    $activeBackendListeners = @(Get-NetTCPConnection -State Listen -LocalPort 8787 -ErrorAction SilentlyContinue)
    if(-not $newBackend -and $activeBackendListeners.Count){
      $compatibleActive = $false
      $backendCfgFile = Join-Path $Root 'backend.json'
      if (Test-Path -LiteralPath $backendCfgFile -PathType Leaf) {
        try {
          $bc = Invoke-RestMethod -Uri 'http://127.0.0.1:8787/health' -TimeoutSec 2 -ErrorAction Stop
          if ($bc -and $bc.app -eq 'PSFlowBridge-FlowAPI' -and $bc.status -eq 'ok' -and -not $bc.draining -and $expectedBuildId -and [string]$bc.runtimeBuildId -eq $expectedBuildId) {
            $cfg = [IO.File]::ReadAllText($backendCfgFile) | ConvertFrom-Json
            if ($cfg -and $cfg.enabled -and $cfg.apiKey -and [string]$cfg.apiKey.Length -ge 16) {
              $modelsResp = Invoke-RestMethod -Uri 'http://127.0.0.1:8787/v1/models' -Headers @{ Authorization = ('Bearer ' + $cfg.apiKey) } -TimeoutSec 2 -ErrorAction Stop
              if ($modelsResp -and $modelsResp.data) {
                $compatibleActive = $true
              }
            }
          }
        } catch { }
      }
      if (-not $compatibleActive) {
        Fail 'local_runtime_busy' 'Existing backend configuration is missing while its port is active; no code was replaced.'
      }
    }
    if(-not $newBackend){RunLocalPython (Join-Path $directory '.venv\Scripts\python.exe') (Join-Path $Application 'backend\prepare-runtime.py')}
  }
}
function InvokeBootstrap([string]$Application,$Runtime,[bool]$Force,[string]$TargetMode = "",[int]$ProgressPercent = 95,[ValidateRange(1,3600)][int]$TimeoutSeconds = 180) {
  $runtimePath = Inside $portableDir $Runtime.directory
  if (-not (TestRuntime $runtimePath $Runtime.pin)) { Fail 'runtime_invalid' 'Pinned runtime integrity failed.' }
  $node = Join-Path $runtimePath 'node.exe'
  $bootstrapStatus = Join-Path $Root ('logs\bootstrap-status-' + [guid]::NewGuid().ToString('N') + '.json')
  [IO.Directory]::CreateDirectory((Split-Path -Parent $bootstrapStatus)) | Out-Null
  $psi = New-Object Diagnostics.ProcessStartInfo
  $psi.FileName = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
  $psi.Arguments = '-NoProfile -ExecutionPolicy Bypass -File "' + (Join-Path $driverRoot 'bootstrap.ps1') + '" -Root "' + $Root + '" -TargetPackageRoot "' + $Application + '"'
  $psi.UseShellExecute = $false; $psi.CreateNoWindow = $true; $psi.WindowStyle = 'Hidden'
  $psi.EnvironmentVariables['PSFB_NODE'] = $node
  $psi.EnvironmentVariables['PSFB_DEPENDENCY_ROOT'] = $runtimePath
  $psi.EnvironmentVariables['PSFB_BUILD_ID'] = (Split-Path -Leaf (Split-Path -Parent $Application)).Substring(0,16)
  $psi.EnvironmentVariables['PSFB_DATA_DIR'] = $Root
  $psi.EnvironmentVariables['PSFB_PORT'] = [string]$Port
  $psi.EnvironmentVariables['PSFB_RUNTIME_ID'] = [string]$Runtime.pin.runtimeId
  $modeToUse = if($TargetMode){$TargetMode}else{$effectiveMode}
  $psi.EnvironmentVariables['PSFB_REQUIRE_LOCAL'] = $(if($modeToUse -eq 'local'){'1'}else{''})
  $psi.EnvironmentVariables['PSFB_FORCE_RESTART'] = $(if($Force){'1'}else{''})
  $psi.EnvironmentVariables['PSFB_STATUS_FILE'] = $bootstrapStatus
  Now 'bootstrap' 'Payload staged; starting runtime' $ProgressPercent
  $process = [Diagnostics.Process]::Start($psi)
  try {
    # Long startups used to look frozen because nothing was written for three
    # minutes. Emit a heartbeat every ten seconds while the child is alive.
    $clock = [Diagnostics.Stopwatch]::StartNew()
    $nextHeartbeat = 0
    while (-not $process.WaitForExit(1000)) {
      $elapsed = [int][math]::Floor($clock.Elapsed.TotalSeconds)
      if ($elapsed -ge $TimeoutSeconds) {
        try{$process.Kill()}catch{}
        Fail 'startup_timeout' ('Startup timed out after ' + $TimeoutSeconds + 's; check service health before retrying.')
      }
      if ($elapsed -ge $nextHeartbeat) {
        Now 'bootstrap' ('Waiting for runtime (' + $elapsed + 's / ' + $TimeoutSeconds + 's)') $ProgressPercent
        $nextHeartbeat = $elapsed + 10
      }
    }
    if (-not (Test-Path -LiteralPath $bootstrapStatus)) { Fail 'startup_failed' 'Bootstrap returned no status.' }
    $result = [IO.File]::ReadAllText($bootstrapStatus) | ConvertFrom-Json
    if ($process.ExitCode -ne 0 -or $result.status -ne 'running') { Fail ([string]$result.code) ([string]$result.message) }
    return $result
  } finally { $process.Dispose() }
}
function StopOwnedProcesses {
  $boundary = [IO.Path]::GetFullPath($Root).TrimEnd('\') + '\'
  $candidates = @()
  try {
    $allProcs = Get-CimInstance Win32_Process -ErrorAction SilentlyContinue
    foreach ($p in $allProcs) {
      $exe = [string]$p.ExecutablePath
      if ($exe -and $exe.StartsWith($boundary, [StringComparison]::OrdinalIgnoreCase)) {
        $leaf = Split-Path -Leaf $exe
        if ($leaf -ieq 'node.exe' -or $leaf -ieq 'python.exe') {
          $candidates += $p
        }
      }
    }
  } catch { }
  foreach ($p in $candidates) {
    try {
      $proc = [Diagnostics.Process]::GetProcessById($p.ProcessId)
      if ($proc -and -not $proc.HasExited) {
        $proc.Kill()
        $proc.WaitForExit(3000)
      }
    } catch { }
  }
}

function Result($Value,[int]$ExitCode) {
  if ($Value -is [System.Collections.IDictionary]) {
    $ht = [ordered]@{}
    $ht['protocolVersion'] = 1
    $ht['productId'] = 'PSFlowBridge'
    $ht['requestId'] = $(if($RequestId){$RequestId}else{''})
    $ht['operation'] = $(if($Value.Contains('operation')){$Value['operation']}elseif($Maintenance){$Maintenance}else{'install'})
    if ($Value.Contains('effectiveMode') -and $Value['effectiveMode']) {
      $ht['effectiveMode'] = $Value['effectiveMode']
    }
    foreach ($k in $Value.Keys) {
      if ($k -notin @('protocolVersion','productId','requestId','operation','effectiveMode')) {
        $ht[$k] = $Value[$k]
      }
    }
    $Value = $ht
  }
  $json = $Value | ConvertTo-Json -Depth 12 -Compress
  if ($statusFile) { AtomicText $statusFile $json }
  [Console]::WriteLine($json)
  exit $ExitCode
}
try {
  try{$locked=$mutex.WaitOne(30000)}catch [Threading.AbandonedMutexException]{$locked=$true}
  if (-not $locked) { Fail 'install_busy' 'Another installation is in progress.' }
  if ($release.schema -ne 'psflowbridge.distribution/1') { Fail 'descriptor_invalid' 'Unsupported distribution descriptor.' }
  if (-not [Environment]::Is64BitOperatingSystem) { Fail 'platform_unsupported' 'This package requires Windows x64.' }
    # effectiveMode must be defined before any install/maintenance path reads it.
    # Requested mode is never treated as observed mode: it stays null unless verified by live service.
    $effectiveMode = $null
    # ==========================================
  # Maintenance Operations: inspect & removals
  # ==========================================
  if ($Maintenance -eq 'inspect') {
    # Pure read-only inspection. Never stops, starts or modifies services or files.
    $setupFile = Join-Path $Root 'setup.json'
    $desiredMode = 'browser'
    if (Test-Path -LiteralPath $modeFile -PathType Leaf) {
      try { $dm = ([IO.File]::ReadAllText($modeFile) | ConvertFrom-Json).mode; if ($dm) { $desiredMode = $dm } } catch { }
    }
    # Contract: requested mode must never be treated as observed mode. effectiveMode is null unless verified by live service.
    $effectiveMode = $null

    # App check
    $currentAppPointer = Join-Path $appsDir 'current'
    $installedAppBuildId = $null
    $installedAppPath = $null
    $appPresent = $false
    $appValid = $false
    $appCompatible = $false
    if (Test-Path -LiteralPath $currentAppPointer -PathType Leaf) {
      $cName = [IO.File]::ReadAllText($currentAppPointer).Trim()
      if ($cName) {
        $installedAppPath = Join-Path $appsDir ($cName + '\PSFlowBridge-package')
        if (Test-Path -LiteralPath $installedAppPath -PathType Container) {
          $appPresent = $true
          $installedAppBuildId = $cName
          if (TestApp $installedAppPath) {
            $appValid = $true
            if ($cName.StartsWith([string]$release.app.buildId)) {
              $appCompatible = $true
            }
          }
        }
      }
    }

    # Runtime check
    $runtimePresent = $false
    $runtimeValid = $false
    $runtimeCompatible = $false
    $installedRuntimeId = $null
    $installedRuntimePath = $null
    if ($installedAppBuildId) {
      $bFile = Join-Path $appsDir ($installedAppBuildId + '\runtime-binding.json')
      if (Test-Path -LiteralPath $bFile -PathType Leaf) {
        try {
          $b = [IO.File]::ReadAllText($bFile) | ConvertFrom-Json
          if ($b -and $b.directory) {
            $installedRuntimePath = Join-Path $portableDir $b.directory
            if (Test-Path -LiteralPath $installedRuntimePath -PathType Container) {
              $runtimePresent = $true
              $installedRuntimeId = $b.directory
              if (TestRuntime $installedRuntimePath $b.pin) {
                $runtimeValid = $true
                if ($b.pin.filesManifestSha256 -eq $release.runtime.filesManifestSha256) {
                  $runtimeCompatible = $true
                }
              }
            }
          }
        } catch { }
      }
    }
    if (-not $runtimePresent -and (Test-Path -LiteralPath $portableDir -PathType Container)) {
      foreach ($rDir in [IO.Directory]::EnumerateDirectories($portableDir)) {
        $leaf = Split-Path -Leaf $rDir
        if ($leaf -like '.staging-*') { continue }
        $runtimePresent = $true
        $installedRuntimeId = $leaf
        $installedRuntimePath = $rDir
        if (TestRuntime $rDir $release.runtime) {
          $runtimeValid = $true
          $runtimeCompatible = $true
        }
        break
      }
    }

    # LocalBackend check: verify actual files against manifest, do not rely on schema alone
    $localBackendPresent = $false
    $localBackendValid = $false
    $localBackendCompatible = $false
    $installedBackendRuntimeId = $null
    $backendDir = Join-Path $Root 'runtime\flow-api'
    $backendPy = Join-Path $backendDir '.venv\Scripts\python.exe'
    $backendApi = Join-Path $backendDir 'flow_cli\api_server.py'
    if ((Test-Path -LiteralPath $backendPy -PathType Leaf) -and (Test-Path -LiteralPath $backendApi -PathType Leaf)) {
      $localBackendPresent = $true
      $bfManifest = Join-Path $backendDir 'local-backend-files.json'
      $bfm = $null
      if (Test-Path -LiteralPath $bfManifest -PathType Leaf) {
        try { $bfm = [IO.File]::ReadAllText($bfManifest) | ConvertFrom-Json } catch { }
      }
      if ($bfm -and $bfm.schema -eq 'psflowbridge.local-backend-files/1') {
        $installedBackendRuntimeId = [string]$bfm.runtimeId
        $allFilesValid = $true
        if ($bfm.files -and $bfm.files.Count -gt 0) {
          foreach ($entry in $bfm.files) {
            $targetFile = Inside $backendDir $entry.path
            if (-not (Test-Path -LiteralPath $targetFile -PathType Leaf) -or (Hash $targetFile) -ne $entry.sha256) {
              $allFilesValid = $false
              break
            }
          }
        } else { $allFilesValid = $false }
        if ($allFilesValid) {
          $localBackendValid = $true
          if ($release.PSObject.Properties['localBackend'] -and $release.localBackend) {
            if ((Hash $bfManifest) -eq $release.localBackend.filesManifestSha256) {
              $localBackendCompatible = $true
            }
          } else {
            $localBackendCompatible = $true
          }
        }
      }
    }

    # Service check: only check without starting or stopping
    $helperRunning = $false
    $helperPid = $null
    $helperEffectiveMode = $null
    $backendRunning = $false

    $health = ReadHealth
    if ($health -and $health.app -eq 'PSFlowBridge') {
      $helperRunning = $true
      $helperEffectiveMode = [string]$health.effectiveMode
      if ($helperEffectiveMode) { $effectiveMode = $helperEffectiveMode }
      if ($health.PSObject.Properties['pid']) { $helperPid = [int]$health.pid }
      elseif ($health.PSObject.Properties['helperPid']) { $helperPid = [int]$health.helperPid }
    }

    $bListeners = @(Get-NetTCPConnection -State Listen -LocalPort 8787 -ErrorAction SilentlyContinue)
    if ($bListeners.Count -gt 0) {
      $boundary = [IO.Path]::GetFullPath($Root).TrimEnd('\') + '\'
      foreach ($bl in $bListeners) {
        $owner = Get-CimInstance Win32_Process -Filter ("ProcessId=" + $bl.OwningProcess) -ErrorAction SilentlyContinue
        $path = [string]$owner.ExecutablePath
        if ($path -and $path.StartsWith($boundary, [StringComparison]::OrdinalIgnoreCase)) {
          $backendRunning = $true
          break
        }
      }
    }

    # canRunBrowser requires app and runtime to be present, valid and compatible
    $canRunBrowser = [bool]($appValid -and $appCompatible -and $runtimeValid -and $runtimeCompatible)
    # canRunLocal requires canRunBrowser plus valid compatible localBackend
    $canRunLocal = [bool]($canRunBrowser -and $localBackendValid -and $localBackendCompatible)

    $inv = [pscustomobject]@{
      app = [pscustomobject]@{
        present = $appPresent
        valid = $appValid
        compatible = $appCompatible
        path = $(if($installedAppPath){$installedAppPath}else{''})
        buildId = $installedAppBuildId
        expectedBuildId = [string]$release.app.buildId
      }
      runtime = [pscustomobject]@{
        present = $runtimePresent
        valid = $runtimeValid
        compatible = $runtimeCompatible
        path = $(if($installedRuntimePath){$installedRuntimePath}else{''})
        runtimeId = $installedRuntimeId
        expectedRuntimeId = [string]$release.runtime.runtimeId
      }
      localBackend = [pscustomobject]@{
        present = $localBackendPresent
        valid = $localBackendValid
        compatible = $localBackendCompatible
        path = $(if($localBackendPresent){$backendDir}else{''})
        runtimeId = $installedBackendRuntimeId
        expectedRuntimeId = $(if($release.PSObject.Properties['localBackend'] -and $release.localBackend){[string]$release.localBackend.runtimeId}else{''})
      }
    }

    $svc = [pscustomobject]@{
      helperRunning = $helperRunning
      helperPid = $helperPid
      helperEffectiveMode = $helperEffectiveMode
      backendRunning = $backendRunning
    }

    Result @{
      protocolVersion = 1
      productId = 'PSFlowBridge'
      requestId = $RequestId
      operation = 'inspect'
      ok = $true
      status = 'ready'
      desiredMode = $desiredMode
      effectiveMode = $effectiveMode
      canRunBrowser = $canRunBrowser
      canRunLocal = $canRunLocal
      dataRoot = $Root
      inventory = $inv
      service = $svc
    } 0
  }

  # Post-inspect actions create Root directory if needed
  [IO.Directory]::CreateDirectory($Root) | Out-Null

  if ($Maintenance) { RequireIdle }

  if ($Maintenance -eq 'clear-cache') {
    Now 'clear-cache' 'Clearing download and staging caches' 0
    $removed = @{}
    $failed = @()
    $bucketRoot = Join-Path $Root 'downloads'
    $deletedFiles = 0
    $deletedBytes = [long]0
    if (Test-Path -LiteralPath $bucketRoot -PathType Container) {
      $items = @(Get-ChildItem -LiteralPath $bucketRoot -File -Recurse -ErrorAction SilentlyContinue)
      foreach ($fileItem in $items) {
        $len = [long]$fileItem.Length
        try {
          Remove-Item -LiteralPath $fileItem.FullName -Force -ErrorAction Stop
          $deletedFiles++
          $deletedBytes += $len
        } catch {
          $failed += ('downloads/' + $fileItem.Name)
        }
      }
      try {
        Remove-Item -LiteralPath $bucketRoot -Recurse -Force -ErrorAction Stop
      } catch {
        if ($failed.Count -eq 0) { $failed += 'downloads' }
      }
    }
    $stagingDirsRemoved = 0
    foreach ($stageDir in @($portableDir, $appsDir)) {
      if (-not (Test-Path -LiteralPath $stageDir -PathType Container)) { continue }
      foreach ($child in [IO.Directory]::EnumerateDirectories($stageDir)) {
        $leaf = Split-Path -Leaf $child
        if ($leaf -notlike '.staging-*') { continue }
        $resolved = [IO.Path]::GetFullPath($child)
        if ($resolved.StartsWith([IO.Path]::GetFullPath($stageDir).TrimEnd('\') + '\.staging-', [StringComparison]::OrdinalIgnoreCase)) {
          try {
            [IO.Directory]::Delete($resolved, $true)
            $stagingDirsRemoved++
          } catch {
            $failed += $leaf
          }
        }
      }
    }
    $removed['downloadCacheFiles'] = $deletedFiles
    $removed['downloadCacheBytes'] = $deletedBytes
    $removed['stagingDirs'] = $stagingDirsRemoved
    $kept = @('apps', 'runtime', 'user-state.json', 'flow-state', 'config.json', 'mode.json', 'setup.json', 'jobs', 'action-jobs', '.trash', 'cache/hd-originals', 'logs')
    Now 'clear-cache' 'Caches cleared' 100
    $ok = ($failed.Count -eq 0)
    Result @{
      protocolVersion = 1
      productId = 'PSFlowBridge'
      requestId = $RequestId
      operation = $Maintenance
      ok = $ok
      status = $(if($ok){'removed'}else{'failed'})
      removed = $removed
      failed = $failed
      kept = $kept
      dataRoot = $Root
    } $(if($ok){0}else{1})
  }

  if ($Maintenance -eq 'remove-local') {
    Now 'remove-local' 'Stopping local service and removing backend files' 0
    StopOwnedProcesses
    $removed = @{}
    $failed = @()
    $pythonRoot = Join-Path $Root 'runtime\flow-api'
    $backendRemoved = $false
    if (Test-Path -LiteralPath $pythonRoot) {
      try {
        Remove-IfExists $pythonRoot
        $backendRemoved = $true
      } catch { $failed += 'runtime/flow-api' }
    }
    $removed['localBackend'] = $backendRemoved

    # Sync mode.json to browser
    if (Test-Path -LiteralPath $modeFile) {
      try {
        $m = Get-Content -LiteralPath $modeFile -Raw | ConvertFrom-Json
        if ($m.mode -eq 'local') {
          AtomicText $modeFile (@{mode='browser';updatedAt=[DateTime]::UtcNow.ToString('o')}|ConvertTo-Json -Compress)
          $removed['mode'] = 'browser'
        }
      } catch { $failed += 'mode.json' }
    }

    # Sync setup.json if mode was local
    $setupFile = Join-Path $Root 'setup.json'
    if (Test-Path -LiteralPath $setupFile) {
      try {
        $s = Get-Content -LiteralPath $setupFile -Raw | ConvertFrom-Json
        if ($s.mode -eq 'local') {
          $sSnapshot = @{schemaVersion=1;completed=$true;mode='browser';updatedAt=[DateTime]::UtcNow.ToString('o')}|ConvertTo-Json -Compress
          AtomicText $setupFile $sSnapshot
          $removed['setupMode'] = 'browser'
        }
      } catch { $failed += 'setup.json' }
    }

    $kept = @('apps', 'runtime/portable', 'user-state.json', 'flow-state', 'config.json', 'jobs', 'action-jobs', '.trash', 'cache/hd-originals', 'downloads', 'logs')
    Now 'remove-local' 'Local backend removed' 100
    $ok = ($failed.Count -eq 0)
    Result @{
      protocolVersion = 1
      productId = 'PSFlowBridge'
      requestId = $RequestId
      operation = $Maintenance
      ok = $ok
      status = $(if($ok){'removed'}else{'failed'})
      removed = $removed
      failed = $failed
      kept = $kept
      dataRoot = $Root
    } $(if($ok){0}else{1})
  }

  if ($Maintenance -eq 'uninstall-runtime') {
    Now 'uninstall-runtime' 'Stopping service and uninstalling runtimes' 0
    StopOwnedProcesses
    $removed = @{}
    $failed = @()

    # Remove apps
    if (Test-Path -LiteralPath $appsDir) {
      try { Remove-IfExists $appsDir; $removed['apps'] = $true } catch { $failed += 'apps' }
    }

    # Remove runtime
    $runtimeDir = Join-Path $Root 'runtime'
    if (Test-Path -LiteralPath $runtimeDir) {
      try { Remove-IfExists $runtimeDir; $removed['runtime'] = $true } catch { $failed += 'runtime' }
    }

    # Remove setup.json to reset onboarding without deleting user data
    $setupFile = Join-Path $Root 'setup.json'
    if (Test-Path -LiteralPath $setupFile) {
      try { Remove-Item -LiteralPath $setupFile -Force; $removed['setup.json'] = $true } catch { $failed += 'setup.json' }
    }

    # Reset mode.json to browser
    if (Test-Path -LiteralPath $modeFile) {
      try {
        AtomicText $modeFile (@{mode='browser';updatedAt=[DateTime]::UtcNow.ToString('o')}|ConvertTo-Json -Compress)
        $removed['mode'] = 'browser'
      } catch { $failed += 'mode.json' }
    }

    $kept = @('user-state.json', 'flow-state', 'config.json', 'jobs', 'action-jobs', '.trash', 'cache/hd-originals', 'downloads', 'logs')
    Now 'uninstall-runtime' 'Runtimes uninstalled' 100
    $ok = ($failed.Count -eq 0)
    Result @{
      protocolVersion = 1
      productId = 'PSFlowBridge'
      requestId = $RequestId
      operation = $Maintenance
      ok = $ok
      status = $(if($ok){'removed'}else{'failed'})
      removed = $removed
      failed = $failed
      kept = $kept
      dataRoot = $Root
    } $(if($ok){0}else{1})
  }

  if ($Maintenance -eq 'delete-user-data') {
    if (-not $ConfirmDeleteData) {
      Fail 'confirmation_required' 'Explicit -ConfirmDeleteData switch is required to delete personal user data.'
    }
    Now 'delete-user-data' 'Stopping service and deleting personal data' 0
    StopOwnedProcesses
    $removed = @{}
    $failed = @()
    $targets = @('user-state.json', 'flow-state', 'jobs', 'action-jobs', '.trash', 'cache\hd-originals', 'config.json', 'mode.json', 'setup.json', 'backend.json')
    foreach ($t in $targets) {
      $p = Join-Path $Root $t
      if (Test-Path -LiteralPath $p) {
        try {
          Remove-IfExists $p
          $removed[$t] = $true
        } catch { $failed += $t }
      }
    }
    $kept = @('apps', 'runtime', 'downloads', 'logs')
    Now 'delete-user-data' 'Personal data deleted' 100
    $ok = ($failed.Count -eq 0)
    Result @{
      protocolVersion = 1
      productId = 'PSFlowBridge'
      requestId = $RequestId
      operation = $Maintenance
      ok = $ok
      status = $(if($ok){'removed'}else{'failed'})
      removed = $removed
      failed = $failed
      kept = $kept
      dataRoot = $Root
    } $(if($ok){0}else{1})
  }

  if ($Maintenance -eq 'remove-components') {
    Now 'remove' 'Checking installed components' 0
    StopOwnedProcesses
    $removed = @{}
    $failed = @()
    $bucketRoot = Join-Path $Root 'downloads'
    $beforeBytes = [long]0
    if (Test-Path -LiteralPath $bucketRoot -PathType Container) {
      $beforeBytes = [long]((Get-ChildItem -LiteralPath $bucketRoot -File -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum)
    }
    $cacheCount = 0
    if (Test-Path -LiteralPath $bucketRoot -PathType Container) {
      $cacheCount = @(Get-ChildItem -LiteralPath $bucketRoot -File -Recurse -ErrorAction SilentlyContinue).Count
    }
    try { Remove-IfExists $bucketRoot } catch { $failed += 'downloads' }
    $pythonRoot = Join-Path $Root 'runtime\flow-api'
    $pythonRemoved = $false
    if (Test-Path -LiteralPath $pythonRoot) {
      try {
        Remove-IfExists $pythonRoot
        $pythonRemoved = $true
      } catch { $failed += 'runtime/flow-api' }
    }
    Now 'remove' 'Removing temporary installation files' 90
    foreach ($stageDir in @($portableDir,$appsDir)) {
      if (-not (Test-Path -LiteralPath $stageDir -PathType Container)) { continue }
      foreach ($child in [IO.Directory]::EnumerateDirectories($stageDir)) {
        if ((Split-Path -Leaf $child) -notlike '.staging-*') { continue }
        $resolved = [IO.Path]::GetFullPath($child)
        if ($resolved.StartsWith([IO.Path]::GetFullPath($stageDir).TrimEnd('\') + '\.staging-',[StringComparison]::OrdinalIgnoreCase)) {
          try { [IO.Directory]::Delete($resolved,$true) } catch { $failed += 'staging' }
        }
      }
    }
    if (Test-Path -LiteralPath $modeFile) {
      try {
        $m = Get-Content -LiteralPath $modeFile -Raw | ConvertFrom-Json
        if ($m.mode -eq 'local') {
          AtomicText $modeFile (@{mode='browser';updatedAt=[DateTime]::UtcNow.ToString('o')}|ConvertTo-Json -Compress)
          $removed['mode'] = 'browser'
        }
      } catch { $failed += 'mode.json' }
    }
    $setupFile = Join-Path $Root 'setup.json'
    if (Test-Path -LiteralPath $setupFile) {
      try {
        $s = Get-Content -LiteralPath $setupFile -Raw | ConvertFrom-Json
        if ($s.mode -eq 'local') {
          $sSnapshot = @{schemaVersion=1;completed=$true;mode='browser';updatedAt=[DateTime]::UtcNow.ToString('o')}|ConvertTo-Json -Compress
          AtomicText $setupFile $sSnapshot
          $removed['setupMode'] = 'browser'
        }
      } catch { $failed += 'setup.json' }
    }
    $removed['downloadCacheFiles'] = $cacheCount
    $removed['downloadCacheBytes'] = $beforeBytes
    $removed['pythonBackend'] = $pythonRemoved
    $kept = @('user-state.json','flow-state','config.json','jobs','action-jobs','.trash','cache/hd-originals','apps','logs')
    if (-not $removed.ContainsKey('mode')) { $kept += 'mode.json' }
    Now 'remove' 'Components removed' 100
    $ok = ($failed.Count -eq 0)
    Result @{
      protocolVersion = 1
      productId = 'PSFlowBridge'
      requestId = $RequestId
      operation = $Maintenance
      maintenance = $Maintenance
      ok = $ok
      status = $(if ($ok) { 'removed' } else { 'failed' })
      removed = $removed
      failed = $failed
      kept = $kept
      dataRoot = $Root
    } $(if ($ok) { 0 } else { 1 })
  }

  if (Test-Path -LiteralPath $modeFile -PathType Leaf) {
    try { $oldModeText = Get-Content -LiteralPath $modeFile -Raw } catch { }
  }
  $currentSavedMode = 'browser'
  try {
    $savedMode = ($oldModeText | ConvertFrom-Json).mode
    if ($savedMode -in @('browser','local')) { $currentSavedMode = $savedMode }
  } catch { }
  if (-not $Mode) { $Mode = $currentSavedMode }

  if ($Maintenance -eq 'install-local') { $Mode = 'local' }
  if($Mode -ne $currentSavedMode){RequireIdle}
  if($Mode){$effectiveMode=$Mode}

  $oldName = CurrentName 'current'
  if (-not $Maintenance -and $oldName) {
    $currentAppDir = Join-Path $appsDir ($oldName + '\PSFlowBridge-package')
    if (TestApp $currentAppDir) {
      $instManifestFile = Join-Path $currentAppDir 'manifest.json'
      if (Test-Path -LiteralPath $instManifestFile -PathType Leaf) {
        try { $instMan = [IO.File]::ReadAllText($instManifestFile) | ConvertFrom-Json } catch { $instMan = $null }
        if ($instMan -and $instMan.version -and $release.version) {
          if ([version]$instMan.version -gt [version]$release.version) {
            Fail 'downgrade_rejected' ('Installed application version (' + $instMan.version + ') is newer than installer release (' + $release.version + '). Please update the companion action, or use rollback-app to revert explicitly.')
          }
        }
      }
    }
  }
  $name = [string]$release.app.buildId
  if ($name -notmatch '^[0-9a-f]{16}$') { Fail 'descriptor_invalid' 'Invalid application build id.' }
  if ($oldName -and $oldName.StartsWith($name) -and (TestApp (Join-Path $appsDir ($oldName + '\PSFlowBridge-package')) $release.app.manifestSha256)) { $name = $oldName }
  $install = Join-Path $appsDir $name
  $driverRoot = Join-Path $install 'PSFlowBridge-package'
  if (-not (TestApp $driverRoot $release.app.manifestSha256)) {
    $archive = GetArchive $release.app 0 20
    $stage = Join-Path $appsDir ('.staging-' + [guid]::NewGuid().ToString('N'))
    try {
      ExpandChecked $archive $stage 33554432 2 22
      if (-not (TestApp (Join-Path $stage 'PSFlowBridge-package') $release.app.manifestSha256)) { Fail 'package_invalid' 'Staged application integrity failed.' }
      if (Test-Path -LiteralPath $install) { $name += '-repair-' + [guid]::NewGuid().ToString('N'); $install = Join-Path $appsDir $name }
      [IO.Directory]::Move($stage,$install)
      AtomicText (Join-Path $install '.complete') $release.app.sha256
      $driverRoot = Join-Path $install 'PSFlowBridge-package'
    } finally { RemoveStage $stage $appsDir }
  }
  $targetRoot = $driverRoot
  $runtime = $null
  if ($Maintenance -eq 'rollback-app') {
    $name = CurrentName 'previous'
    if (-not $name -or $name -eq $oldName) { Fail 'rollback_unavailable' 'No previous application is available.' }
    $targetRoot = Join-Path $appsDir ($name + '\PSFlowBridge-package')
    if (-not (TestApp $targetRoot)) { Fail 'rollback_invalid' 'Previous application integrity failed.' }
    $runtime = Binding $name
    if (-not $runtime) { $runtime = $oldBinding }
  } elseif ($Maintenance -ne 'repair-runtime' -and $oldBinding -and $oldBinding.pin.filesManifestSha256 -eq $release.runtime.filesManifestSha256) { $runtime = $oldBinding }
  if ($runtime -and -not (TestRuntime (Inside $portableDir $runtime.directory) $runtime.pin)) { $runtime = $null }
  if (-not $runtime) {
    $runtimeName = [string]$release.runtime.runtimeId
    if ($runtimeName -notmatch '^[A-Za-z0-9._-]+$') { Fail 'descriptor_invalid' 'Invalid runtime id.' }
    $runtimePath = Inside $portableDir $runtimeName
    if ($Maintenance -eq 'repair-runtime' -or -not (TestRuntime $runtimePath $release.runtime)) {
      $archive = GetArchive $release.runtime 22 55
      $stage = Join-Path $portableDir ('.staging-' + [guid]::NewGuid().ToString('N'))
      try {
        ExpandChecked $archive $stage 536870912 25 65
        if (-not (TestRuntime $stage $release.runtime)) { Fail 'runtime_invalid' 'Staged runtime integrity failed.' }
        if (Test-Path -LiteralPath $runtimePath) { $runtimeName += '-repair-' + [guid]::NewGuid().ToString('N'); $runtimePath = Inside $portableDir $runtimeName }
        [IO.Directory]::Move($stage,$runtimePath)
      } finally { RemoveStage $stage $portableDir }
    }
    $runtime = [pscustomobject]@{ directory=$runtimeName; pin=$release.runtime }
  }
  # All executable files are verified before this self-test. PATH and NODE_PATH are not used.
  $runtimePath = Inside $portableDir $runtime.directory
  $probeFile = Join-Path $Root ('logs\runtime-probe-' + [guid]::NewGuid().ToString('N') + '.cjs')
  [IO.Directory]::CreateDirectory((Split-Path -Parent $probeFile)) | Out-Null
  [IO.File]::WriteAllText($probeFile,"const s=require(process.argv[2]);s({create:{width:8,height:8,channels:3,background:'#c04040'}}).resize(4,4).png().toBuffer().then(b=>s(b).metadata()).then(m=>{if(m.width!==4||m.height!==4)process.exit(1)}).catch(()=>process.exit(1));",$utf8)
  $probe = Start-Process -FilePath (Join-Path $runtimePath 'node.exe') -ArgumentList @(('"'+$probeFile+'"'),('"'+(Join-Path $runtimePath 'node_modules\sharp')+'"')) -WindowStyle Hidden -PassThru
  Now 'verify' 'Running image library self-test' 87
  try { if(-not $probe.WaitForExit(10000)){try{$probe.Kill()}catch{};Fail 'runtime_selftest_failed' 'Runtime image self-test timed out.'};$probe.Refresh();if($probe.ExitCode -ne 0){Fail 'runtime_selftest_failed' 'Runtime image self-test failed.'} }
  finally { $probe.Dispose();Remove-Item -LiteralPath $probeFile -Force }
  Now 'verify' 'Image library self-test passed' 90
  if($effectiveMode -eq 'local'){Now 'prepare' 'Configuring local Python environment' 90}
  if($effectiveMode -eq 'local'){EnsureLocalBackend $targetRoot}
  if($Mode){
    $currentSavedMode = $(if($oldModeText){($oldModeText|ConvertFrom-Json).mode}else{''})
    if($currentSavedMode -ne $Mode){
      AtomicText $modeFile (@{mode=$Mode;updatedAt=[DateTime]::UtcNow.ToString('o')}|ConvertTo-Json -Compress)
      $modeChanged = $true
    }
  }
  # effectiveMode is read from disk by the helper; changing that file does not
  # prove the Python service was started. Local mode always checks both services.
  if (-not $Maintenance -and -not $modeChanged -and $effectiveMode -eq 'browser' -and $oldName -eq $name) {
    $health = ReadHealth
    if ($health -and $health.app -eq 'PSFlowBridge' -and $health.buildId -eq $release.app.buildId -and $health.effectiveMode -eq $effectiveMode -and -not $health.draining -and $health.PSObject.Properties['runtimeId'] -and $health.runtimeId -eq $runtime.pin.runtimeId -and $health.PSObject.Properties['runtimeRoot'] -and [string]::Equals([string]$health.runtimeRoot,$runtimePath,[StringComparison]::OrdinalIgnoreCase)) {
      Now 'complete' 'Runtime healthy' 100
      Result @{ok=$true;status='running';reused=$true;packageRoot=$targetRoot;nodePath=(Join-Path $runtimePath 'node.exe');runtimeId=$runtime.pin.runtimeId;buildId=$health.buildId;effectiveMode=$health.effectiveMode;dataRoot=$Root} 0
    }
  }
  $bootstrapStarted = $true
  $bootstrapPercent = $(if($effectiveMode -eq 'local'){99}else{95})
  $started = InvokeBootstrap $targetRoot $runtime ($Maintenance -eq 'repair-runtime') $effectiveMode $bootstrapPercent
  # Health validation: the running helper's effectiveMode must match our intended effectiveMode
  $finalHealth = ReadHealth
  if (-not $finalHealth -or $finalHealth.app -ne 'PSFlowBridge' -or $finalHealth.effectiveMode -ne $effectiveMode) {
    Fail 'mode_mismatch' ('Helper service mode mismatch: expected ' + $effectiveMode + ', actual ' + $(if($finalHealth){$finalHealth.effectiveMode}else{'no-response'}))
  }
  AtomicText (Join-Path (Split-Path -Parent $targetRoot) 'runtime-binding.json') ($runtime | ConvertTo-Json -Depth 12)
  Now 'complete' 'Runtime healthy' 100
  Result @{ok=$true;status='running';packageRoot=$targetRoot;nodePath=(Join-Path $runtimePath 'node.exe');runtimeId=$runtime.pin.runtimeId;buildId=$started.buildId;effectiveMode=$finalHealth.effectiveMode;maintenance=$Maintenance;dataRoot=$Root} 0
} catch {
  $message = $_.Exception.Message
  if($modeChanged){if($null -ne $oldModeText){AtomicText $modeFile $oldModeText}elseif(Test-Path -LiteralPath $modeFile){Remove-Item -LiteralPath $modeFile -Force}}
  $recovered = $false
  if ($bootstrapStarted -and $oldName -and $driverRoot) {
    try {
      $previousRoot = Join-Path $appsDir ($oldName + '\PSFlowBridge-package')
      if (-not $oldBinding -and (Get-Variable runtime -ErrorAction SilentlyContinue)) { $oldBinding = $runtime }
      if ($oldBinding -and (TestApp $previousRoot)) {
        $origMode = $(if($null -ne $oldModeText){try{($oldModeText|ConvertFrom-Json).mode}catch{'browser'}}else{'browser'})
        $restored = InvokeBootstrap $previousRoot $oldBinding $false $origMode 98
        foreach ($pointer in @('current','previous')) { $file=Join-Path $appsDir $pointer;if($null -ne $oldPointers[$pointer]){AtomicText $file $oldPointers[$pointer]}elseif(Test-Path -LiteralPath $file -PathType Leaf){Remove-Item -LiteralPath $file -Force} }
        $recovered = $true
      }
    } catch { }
  }
  # The last progress record is always the failure, even after a rollback
  # bootstrap wrote its own heartbeat.
  Now 'failed' $message 99
  Result @{ok=$false;status='error';error=$message;recovered=$recovered;dataRoot=$Root} 1
} finally { if($locked){$mutex.ReleaseMutex()};$mutex.Dispose() }
