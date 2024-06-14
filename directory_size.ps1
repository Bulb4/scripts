param (
    [string]$TargetDirectory = "."
)

Set-Location -Path $TargetDirectory

$host.ui.RawUI.WindowTitle = $TargetDirectory


$row1 = "________________________________"
$row2 = "__________________"
$conWidth = $row1.Length + $row2.Length + 4

$items = ls
$itemsCount = $items.Count + 4
$itemsCount = ($itemsCount,50 | Measure -Min).Minimum

mode con:cols=$conWidth

$results = $items | select Name,@{n="TotalSize";e={ ls -rec $_ | measure Length -sum | % Sum }} | sort TotalSize
$results = $results | select Name,@{n="TotalSize";e={$_.TotalSize}},@{n=$row2;e={"{0, $($row2.Length - 2)}" -f $_.TotalSize.ToString("N0")}}

$results | Format-Table -Property @{n=$row1;e={$_.Name}}, $row2 -AutoSize -HideTableHeaders

# Wait for user input before closing
Read-Host
