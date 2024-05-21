param (
    [string]$PSGalleryLink = "https://www.powershellgallery.com/profiles/NorskNoobing"
)

#Install required modules
$RequiredModulesNameArray = @('PowerHTML')
$RequiredModulesNameArray.ForEach({
    if (Get-InstalledModule $_ -ErrorAction SilentlyContinue) {
        Import-Module $_ -Force
    } else {
        Install-Module $_ -Force -Repository PSGallery
    }
})

#Scrape PSGallery profile for the "Total Downloads" property
$PsgalleryProfile = ((Invoke-WebRequest -Uri $PSGalleryLink | ConvertFrom-Html).InnerText -split '\r?\n').Trim()
$TotalDownloadsIndex = $PsgalleryProfile.IndexOf("Total downloads of packages")
$PsgalleryTotalDownloads = $PsgalleryProfile[$TotalDownloadsIndex-2]

#See ShieldLinkStr options here https://shields.io/badges/static-badge
$ShieldLinkStr = "https://img.shields.io/badge/PSGallery%20Downloads-$PsgalleryTotalDownloads-blue?style=flat-square&logo=powershell"

#Download psgallery downloads shield svg
Invoke-WebRequest -Uri $ShieldLinkStr -OutFile "$PSScriptRoot/Images/Dynamic/PSGalleryTotalDownloads.svg"