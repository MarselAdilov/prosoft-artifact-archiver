param (
    [string]$root_dir = "./dev_build"
)

function Get-Hash {
    param (
        [string]$Algorithm,
        [string]$ProjectPath,
        [string]$TmpHashDir
    )
    
    $outputFile = "${TmpHashDir}/${Algorithm.ToLower()}sums.txt"
    Get-ChildItem -Path $ProjectPath -Recurse -File | ForEach-Object {
        $hash = Get-FileHash -Algorithm $Algorithm -Path $_.FullName 
        "$($hash.Hash)  $($hash.Path)"
    } | Out-File -Encoding UTF8 $outputFile
    
    return $outputFile
}

function Get-Archive ([string]$root_dir) {
    $projects = Get-ChildItem -Attributes Directory -Path $root_dir | ForEach-Object { $_.FullName }
    
    $createdFiles = @()
    # Use system temp directory
    if ($IsWindows) {
        $tmpHashDir = Join-Path $env:TEMP "PowerShell_Archive_$(Get-Random)"
    } else {
        $tmpHashDir = "/tmp/PowerShell_Archive_$(Get-Random)"
    }
    
    New-Item -Path $tmpHashDir -ItemType Directory -Force | Out-Null
    
    try {
        $createdArchives = @()
        $createdMD5 = @()
        $createdSHA1 = @()
        $createdSHA256 = @()
        $createdHashFiles = @()
        
        foreach ($project in $projects) {
            # Creating archive
            $archive_name = "${project}_artifacts.7z"
            
            # Adding hash sums for all project's files using the new function
            $md5File = Get-Hash -Algorithm "MD5" -ProjectPath $project -TmpHashDir $tmpHashDir
            $sha1File = Get-Hash -Algorithm "SHA1" -ProjectPath $project -TmpHashDir $tmpHashDir
            $sha256File = Get-Hash -Algorithm "SHA256" -ProjectPath $project -TmpHashDir $tmpHashDir
            
            7z a $archive_name $project "${tmpHashDir}/*" -bso0

            # Archive's hash sums
            $md5 = "${archive_name}.md5"
            $sha1 = "${archive_name}.sha1"
            $sha256 = "${archive_name}.sha256"
            $md5Hash = (Get-FileHash $archive_name -Algorithm MD5).Hash
            $sha1Hash = (Get-FileHash $archive_name -Algorithm SHA1).Hash
            $sha256Hash = (Get-FileHash $archive_name -Algorithm SHA256).Hash
            
            $md5Hash | Out-File -Encoding ASCII $md5
            $sha1Hash | Out-File -Encoding ASCII $sha1
            $sha256Hash | Out-File -Encoding ASCII $sha256
            
            $createdArchives += @($archive_name)
            $createdMD5 += @($md5)
            $createdSHA1 += @($sha1)
            $createdSHA256 += @($sha256)
            $createdHashFiles += @{
                MD5File = $md5File
                SHA1File = $sha1File
                SHA256File = $sha256File
                MD5Hash = $md5Hash
                SHA1Hash = $sha1Hash
                SHA256Hash = $sha256Hash
            }
        }
        
        return @{
            Projects = $projects
            CreatedArchives = $createdArchives
            CreatedMD5 = $createdMD5
            CreatedSHA1 = $createdSHA1
            CreatedSHA256 = $createdSHA256
            CreatedHashFiles = $createdHashFiles
        }
    }
    catch {
        Write-Error "Error occurred during archive creation: $_"
        throw
    }
    finally {
        # Always clean up temp directory
        if (Test-Path $tmpHashDir) {
            Remove-Item $tmpHashDir -Recurse -Force
        }
    }
}

# For direct script call
if ($MyInvocation.InvocationName -ne '.') {
    Get-Archive -root_dir $root_dir
}