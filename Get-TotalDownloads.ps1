param (
    [string]$PSGalleryLink = "https://www.powershellgallery.com/profiles/NorskNoobing",
    [string][ValidateSet("md","html")]$Language = "html"
)

#Returns bool if "README.md" contains badge field or not
$BadgeExists = (Get-Content "README.md" | Select-String "<!-- PSGallery-Downloads:START -->") -and (Get-Content "README.md" | Select-String "<!-- PSGallery-Downloads:END -->")

if (!$BadgeExists) {
    Write-Error "Badge field has to be added to your README before running workflow."
}

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

#Check README language parameter
switch ($Language) {
    md {
        #Use md syntax
        $TemplateStr = "[![]($ShieldLinkStr)]($PSGalleryLink)"
    }
    html {
        #Use html syntax
        $TemplateStr = @"
<a href="$PSGalleryLink">
    <img src="$ShieldLinkStr">
</a>
"@
    }
}

#Update badge
(Get-Content "README.md" -Raw) -Replace @"
(?smi)(<!-- PSGallery-Downloads:START -->)(.*)(<!-- PSGallery-Downloads:END -->)
"@,"<!-- PSGallery-Downloads:START -->$TemplateStr<!-- PSGallery-Downloads:END -->" | Out-File "README.md"