Add-Type -AssemblyName System.Windows.Forms

$FileBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
$FileBrowser.AddToRecent  = $False
$FileBrowser.ClientGuid = [System.Text.Encoding]::UTF8.GetBytes("a7f7241712082a1d")
$FileBrowser.Description = 'Open VS solution'
$FileBrowser.InitialDirectory = 'D:\projects\in_work'
$FileBrowser.OkRequiresInteraction = $False
$FileBrowser.ShowHiddenFiles = $False
$FileBrowser.ShowNewFolderButton = $False
$FileBrowser.ShowPinnedPlaces = $False
$FileBrowser.UseDescriptionForTitle = $True

if($FileBrowser.ShowDialog() -eq "OK")
{
    $FileBrowser | Format-List *
    $scriptPath = $PSScriptRoot + "\open_vs_sln.bat"
    $solutionName = Get-ChildItem -Path $FileBrowser.SelectedPath -Filter "*.sln" -File | Select-Object -ExpandProperty "Name"
    $solutionPath = $FileBrowser.SelectedPath + "\" + $solutionName
    Start-Process -FilePath $scriptPath -ArgumentList $solutionPath -WindowStyle Hidden
}
