$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
Get-ChildItem -Path $scriptDir -File | Where-Object { $_.Name -notlike 'load*' } | ForEach-Object {
    New-Item -ItemType HardLink -Path $scriptDir -Name $_.Name -Value $_.FullName -Force
}
