BeforeAll {
    # Creating a test directory in system temp
    if ($IsWindows) {
        $baseDir = Join-Path $env:TEMP "dev_build_test_$(Get-Random)"
    } else {
        $baseDir = "/tmp/dev_build_test_$(Get-Random)"
    }
    
    $components = @("grpedit", "modservice", "rsysconf", "scada")
        
    foreach ($component in $components) {
        $compPath = Join-Path $baseDir $component
        $testsPath = Join-Path $compPath "tests"
        New-Item -ItemType Directory -Path $testsPath -Force | Out-Null
        New-Item -ItemType File -Path (Join-Path $compPath "distr.deb") -Force | Out-Null
        New-Item -ItemType File -Path (Join-Path $compPath "syms.7z") -Force | Out-Null
        New-Item -ItemType File -Path (Join-Path $testsPath "test_reports.txt.7z") -Force | Out-Null
        New-Item -ItemType File -Path (Join-Path $testsPath "test_reports.xunit.7z") -Force | Out-Null
    }
        
    . $PSScriptRoot/Get-Archive.ps1
    $result = Get-Archive -root_dir $baseDir
    $projectsNumber = $result.Projects.Count
}

Describe 'Get-Hash' {
    It 'Should create MD5 hash file correctly' {
        # Create a temporary test directory
        if ($IsWindows) {
            $testDir = Join-Path $env:TEMP "test_hash_$(Get-Random)"
            $tmpHashDir = Join-Path $env:TEMP "test_tmp_$(Get-Random)"
        } else {
            $testDir = "/tmp/test_hash_$(Get-Random)"
            $tmpHashDir = "/tmp/test_tmp_$(Get-Random)"
        }
        
        try {
            New-Item -ItemType Directory -Path $testDir -Force | Out-Null
            New-Item -ItemType Directory -Path $tmpHashDir -Force | Out-Null
            New-Item -ItemType File -Path (Join-Path $testDir "test_file.txt") -Force | Out-Null
            "Test content" | Out-File -FilePath (Join-Path $testDir "test_file.txt") -Encoding UTF8
            
            $hashFile = Get-Hash -Algorithm "MD5" -ProjectPath $testDir -TmpHashDir $tmpHashDir
            
            $hashFile | Should -Exist
            $hashFile | Should -Be "${tmpHashDir}/md5sums.txt"
            $content = Get-Content $hashFile
            $content | Should -Not -BeNullOrEmpty
            $content | Should -Match "^[A-F0-9]{32}  "
        }
        finally {
            if (Test-Path $testDir) { Remove-Item $testDir -Recurse -Force }
            if (Test-Path $tmpHashDir) { Remove-Item $tmpHashDir -Recurse -Force }
        }
    }
    
    It 'Should create SHA1 hash file correctly' {
        # Create a temporary test directory
        if ($IsWindows) {
            $testDir = Join-Path $env:TEMP "test_hash_$(Get-Random)"
            $tmpHashDir = Join-Path $env:TEMP "test_tmp_$(Get-Random)"
        } else {
            $testDir = "/tmp/test_hash_$(Get-Random)"
            $tmpHashDir = "/tmp/test_tmp_$(Get-Random)"
        }
        
        try {
            New-Item -ItemType Directory -Path $testDir -Force | Out-Null
            New-Item -ItemType Directory -Path $tmpHashDir -Force | Out-Null
            New-Item -ItemType File -Path (Join-Path $testDir "test_file.txt") -Force | Out-Null
            
            $hashFile = Get-Hash -Algorithm "SHA1" -ProjectPath $testDir -TmpHashDir $tmpHashDir
            
            $hashFile | Should -Exist
            $hashFile | Should -Be "${tmpHashDir}/sha1sums.txt"
            $content = Get-Content $hashFile
            $content | Should -Not -BeNullOrEmpty
            $content | Should -Match "^[A-F0-9]{40}  "
        }
        finally {
            if (Test-Path $testDir) { Remove-Item $testDir -Recurse -Force }
            if (Test-Path $tmpHashDir) { Remove-Item $tmpHashDir -Recurse -Force }
        }
    }
    
    It 'Should create SHA256 hash file correctly' {
        # Create a temporary test directory
        if ($IsWindows) {
            $testDir = Join-Path $env:TEMP "test_hash_$(Get-Random)"
            $tmpHashDir = Join-Path $env:TEMP "test_tmp_$(Get-Random)"
        } else {
            $testDir = "/tmp/test_hash_$(Get-Random)"
            $tmpHashDir = "/tmp/test_tmp_$(Get-Random)"
        }
        
        try {
            New-Item -ItemType Directory -Path $testDir -Force | Out-Null
            New-Item -ItemType Directory -Path $tmpHashDir -Force | Out-Null
            New-Item -ItemType File -Path (Join-Path $testDir "test_file.txt") -Force | Out-Null
            
            $hashFile = Get-Hash -Algorithm "SHA256" -ProjectPath $testDir -TmpHashDir $tmpHashDir
            
            $hashFile | Should -Exist
            $hashFile | Should -Be "${tmpHashDir}/sha256sums.txt"
            $content = Get-Content $hashFile
            $content | Should -Not -BeNullOrEmpty
            $content | Should -Match "^[A-F0-9]{64}  "
        }
        finally {
            if (Test-Path $testDir) { Remove-Item $testDir -Recurse -Force }
            if (Test-Path $tmpHashDir) { Remove-Item $tmpHashDir -Recurse -Force }
        }
    }
}

Describe 'Get-Archive' {
    It 'Projects are found' {
        $projectsNumber | Should -BeGreaterThan 0
    }
    It 'Archives have been created correctly' {
        $result.CreatedArchives.Count | Should -Be $projectsNumber
        foreach ($i in 0..($projectsNumber-1)) {
            $result.CreatedArchives[$i] | Should -Be "$($result.Projects[$i])_artifacts.7z"
        }
    }
    It 'MD5 hash sums have been created correctly' {
        $result.CreatedArchives.Count | Should -Be $projectsNumber
        foreach ($i in 0..($projectsNumber-1)) {
            $result.CreatedMD5[$i] | Should -Be "$($result.CreatedArchives[$i]).md5"
            Get-Content $result.CreatedMD5[$i] | Should -Be (Get-FileHash $result.CreatedArchives[$i] -Algorithm MD5).Hash
            # Test with returned hash values
            Get-Content $result.CreatedMD5[$i] | Should -Be $result.CreatedHashFiles[$i].MD5Hash
        }
    }
    It 'SHA1 hash sums have been created correctly' {
        $result.CreatedArchives.Count | Should -Be $projectsNumber
        foreach ($i in 0..($projectsNumber-1)) {
            $result.CreatedSHA1[$i] | Should -Be "$($result.CreatedArchives[$i]).sha1"
            Get-Content $result.CreatedSHA1[$i] | Should -Be (Get-FileHash $result.CreatedArchives[$i] -Algorithm SHA1).Hash
            # Test with returned hash values
            Get-Content $result.CreatedSHA1[$i] | Should -Be $result.CreatedHashFiles[$i].SHA1Hash
        }
    }
    It 'SHA256 hash sums have been created correctly' {
        $result.CreatedArchives.Count | Should -Be $projectsNumber
        foreach ($i in 0..($projectsNumber-1)) {
            $result.CreatedSHA256[$i] | Should -Be "$($result.CreatedArchives[$i]).sha256"
            Get-Content $result.CreatedSHA256[$i] | Should -Be (Get-FileHash $result.CreatedArchives[$i] -Algorithm SHA256).Hash
            # Test with returned hash values
            Get-Content $result.CreatedSHA256[$i] | Should -Be $result.CreatedHashFiles[$i].SHA256Hash
        }
    }
    It 'Hash files are created and accessible' {
        $result.CreatedHashFiles.Count | Should -Be $projectsNumber
        foreach ($i in 0..($projectsNumber-1)) {
            $result.CreatedHashFiles[$i].MD5File | Should -Not -BeNullOrEmpty
            $result.CreatedHashFiles[$i].SHA1File | Should -Not -BeNullOrEmpty
            $result.CreatedHashFiles[$i].SHA256File | Should -Not -BeNullOrEmpty
            $result.CreatedHashFiles[$i].MD5Hash | Should -Not -BeNullOrEmpty
            $result.CreatedHashFiles[$i].SHA1Hash | Should -Not -BeNullOrEmpty
            $result.CreatedHashFiles[$i].SHA256Hash | Should -Not -BeNullOrEmpty
        }
    }
}

AfterAll {
    # Clean up created archives and hash files
    if ($result) {
        foreach ($archive in $result.CreatedArchives) {
            if (Test-Path $archive) { Remove-Item $archive -Force }
        }
        foreach ($md5 in $result.CreatedMD5) {
            if (Test-Path $md5) { Remove-Item $md5 -Force }
        }
        foreach ($sha1 in $result.CreatedSHA1) {
            if (Test-Path $sha1) { Remove-Item $sha1 -Force }
        }
        foreach ($sha256 in $result.CreatedSHA256) {
            if (Test-Path $sha256) { Remove-Item $sha256 -Force }
        }
    }
    
    # Remove test directory
    if (Test-Path $baseDir) {
        Remove-Item $baseDir -Recurse -Force
    }
}