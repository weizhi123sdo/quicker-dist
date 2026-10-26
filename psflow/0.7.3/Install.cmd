@echo off
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -File "%~dp0Install.ps1" -SourceDir "%~dp0." -EntryRole components
if errorlevel 1 (echo Installation failed. Review the message above. & pause & exit /b 1)
echo Runtime prepared. Import the native Quicker action and open PS Flow.
pause
