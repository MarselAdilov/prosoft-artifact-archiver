param (
    [string]$root_dir = "./dev_build"
)

function Get-Archive ([string]$root_dir) {
	$projects = Get-ChildItem -Attributes Directory $root_dir
	
	$createdFiles = @()
	# Temp folder for hash sums
	$tmpHashDir = "./tmpHashDir"
	New-Item -Path $tmpHashDir -ItemType Directory -Force | Out-Null
	
	foreach ($project in $projects) {
				  # Creating archive
	        $archive_name = "${project}_artifacts.7z"
	        # Adding hash sums for all project's files
	        Get-ChildItem -Path $project -Recurse -File | Get-FileHash -Algorithm MD5 | Out-File "${tmpHashDir}/md5sums.txt"
	        Get-ChildItem -Path $project -Recurse -File | Get-FileHash -Algorithm SHA1 | Out-File "${tmpHashDir}/sha1sums.txt"
	        Get-ChildItem -Path $project -Recurse -File | Get-FileHash -Algorithm SHA256 | Out-File "${tmpHashDir}/sha256sums.txt"
	        7z a $archive_name $project "${tmpHashDir}/*" -bso0
	
	        # Archive's hash sums
	        $md5 = "${archive_name}.md5"
	        $sha1 = "${archive_name}.sha1"
	        $sha256 = "${archive_name}.sha256"
	        (Get-FileHash $archive_name MD5).Hash | Out-File -Encoding ASCII $md5
	        (Get-FileHash $archive_name SHA1).Hash | Out-File -Encoding ASCII $sha1
	        (Get-FileHash $archive_name SHA256).Hash | Out-File -Encoding ASCII $sha256
	        
	        $createdArchives += @($archive_name)
	        $createdMD5 += @($md5)
	        $createdSHA1 += @($sha1)
	        $createdSHA256 += @($sha256)
	}
	Remove-Item $tmpHashDir -Recurse -Force
	
	return @{
        Projects = $projects
        CreatedArchives = $createdArchives
        CreatedMD5 = $createdMD5
        CreatedSHA1 = $createdSHA1
        CreatedSHA256 = $createdSHA256
	}
}


# For direct script call
if ($MyInvocation.InvocationName -ne '.') {
    Get-Archive -root_dir $root_dir
}