$ErrorActionPreference = "Stop"
$PSDefaultParameterValues['*:ErrorAction']='Stop'

$terrain=$args[0]

Write-Host "Copying mission of Antistasi Plus - $($terrain) to profile folder..."

$path = ".\A3A\Addons\maps\Antistasi_$($terrain).$($terrain)"

$buildFolder = $env:userprofile + "\Documents\Arma 3 - Other Profiles\Socrates\missions";

$devFolderItem = Get-ChildItem -Path $path | Select-Object -First 1;
$devFolder = $devFolderItem.parent;

$folderName = $devFolder.Name;
$pair = $folderName.Split("\.");
$missionFolderName = $pair[0] + "." + $pair[1]; 
$destinationPath = $(Join-Path $buildFolder $missionFolderName);

Remove-Item $destinationPath -Recurse -ErrorAction Ignore;

Copy-Item -Path $(Join-Path $devFolder.FullName "*") -Destination $destinationPath -Recurse -Force;