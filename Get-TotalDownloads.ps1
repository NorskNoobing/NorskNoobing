param (
    [string]$PsgalleryUsername = "NorskNoobing",
    [string]$LinkStr = "https://img.shields.io/badge/PSGallery%20Downloads-"
)

Install-Module "PowerHTML" -Force

#Scrape PSGallery profile for the "Total Downloads" property
$PsgalleryProfile = ((Invoke-WebRequest -Uri "https://www.powershellgallery.com/profiles/$PsgalleryUsername" | ConvertFrom-Html).InnerText -split '\r?\n').Trim()
$TotalDownloadsIndex = $PsgalleryProfile.IndexOf("Total downloads of packages")
$PsgalleryTotalDownloads = $PsgalleryProfile[$TotalDownloadsIndex-2]

#Returns bool if "README.md" contains badge or not
$LinkMatchRegex = "$($LinkStr.replace(".","\.").replace("/","\/"))[0-9]*"
$BadgeExists = Get-Content "README.md" | Select-String -pattern $LinkMatchRegex

if ($BadgeExists) {
    #Update badge
    (Get-Content "README.md") -Replace "$LinkMatchRegex",
    "$LinkStr$PsgalleryTotalDownloads" | Out-File "README.md"
} else {
    Write-Error "Badge has to be added to your README before running workflow."
}