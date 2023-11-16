param (
    [string]$PSGalleryLink = "https://www.powershellgallery.com/profiles/NorskNoobing"
)

#Returns bool if "README.md" contains badge field or not
$BadgeExists = (Get-Content "README.md" | Select-String "<!-- PSGallery-Downloads:START -->") -and (Get-Content "README.md" | Select-String "<!-- PSGallery-Downloads:END -->")

if (!$BadgeExists) {
    Write-Error "Badge field has to be added to your README before running workflow."
}

Install-Module "PowerHTML" -Force

#Scrape PSGallery profile for the "Total Downloads" property
$PsgalleryProfile = ((Invoke-WebRequest -Uri $PSGalleryLink | ConvertFrom-Html).InnerText -split '\r?\n').Trim()
$TotalDownloadsIndex = $PsgalleryProfile.IndexOf("Total downloads of packages")
$PsgalleryTotalDownloads = $PsgalleryProfile[$TotalDownloadsIndex-2]

#See LinkStr options here https://shields.io/badges/static-badge
$LinkStr = "https://img.shields.io/badge/PSGallery%20Downloads-$PsgalleryTotalDownloads-blue?style=flat-square&logo=powershell"

#Update badge
(Get-Content "README.md") -Replace @"
<!-- PSGallery-Downloads:START -->.*<!-- PSGallery-Downloads:END -->
"@,@"
<!-- PSGallery-Downloads:START -->[![]($LinkStr)]($PSGalleryLink)<!-- PSGallery-Downloads:END -->
"@ | Out-File "README.md"