BeforeAll {
	# Creating a test directory
	$baseDir = "dev_build_test"
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
		$result = Get-Archive -root_dir "./dev_build_test"
		$projectsNumber = $result.Projects.Count
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
		}
    }
    It 'SHA1 hash sums have been created correctly' {
		$result.CreatedArchives.Count | Should -Be $projectsNumber
		foreach ($i in 0..($projectsNumber-1)) {
			$result.CreatedSHA1[$i] | Should -Be "$($result.CreatedArchives[$i]).sha1"
			Get-Content $result.CreatedSHA1[$i] | Should -Be (Get-FileHash $result.CreatedArchives[$i] -Algorithm SHA1).Hash
		}
    }
    It 'SHA256 hash sums have been created correctly' {
		$result.CreatedArchives.Count | Should -Be $projectsNumber
		foreach ($i in 0..($projectsNumber-1)) {
			$result.CreatedSHA256[$i] | Should -Be "$($result.CreatedArchives[$i]).sha256"
			Get-Content $result.CreatedSHA256[$i] | Should -Be (Get-FileHash $result.CreatedArchives[$i] -Algorithm SHA256).Hash
		}
    }
}

AfterAll {
    Remove-Item './dev_build_test' -Recurse -Force
}