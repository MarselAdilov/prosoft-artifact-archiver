# Create dev_build dir
createDevDir:
	pwsh -File ./create_structure.ps1

# Delete dev_build dir
deleteDevDir:
	pwsh -File ./remove_structure.ps1
	
# Start main script
archive:
	pwsh -File ./Get-Archive.ps1
	
# Start Pester
test:
	pwsh -Command "Invoke-Pester -Output Detailed ./Get-Archive.Tests.ps1"