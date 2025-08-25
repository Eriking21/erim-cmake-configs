# Get the directory where the script is located.
$scriptDir = $PSScriptRoot

# Get the current working directory.
$targetDir = Get-Location

# Get all files in the script's directory, excluding those that start with "load".
Get-ChildItem -Path $scriptDir -File | Where-Object { $_.Name -notlike 'load*' } | ForEach-Object {
    $linkPath = Join-Path -Path $targetDir -ChildPath $_.Name
    $targetPath = $_.FullName

    Write-Host "Creating hard link for: $($_.Name)"

    # Create the hard link.
    New-Item -ItemType HardLink -Path $linkPath -Target $targetPath
}