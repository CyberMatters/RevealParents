# Copyright 2021 Dany GIANG

Clear-Host
Write-Host "`n"
Write-Host ******************************************`n
Write-Host ************* RevealParents **************`n
Write-Host **** by Dany Giang aka CyberMatters ****`n
Write-Host ******************************************`n

function display-info{
	Param ([Object]$a)

	Write-Host "`n`n------------ PROCESS INFO BELOW : ------------`n`n"
	Write-Host "ProcessName :`n`n"=> $a.ProcessName"`n"
	Write-Host "ProcessName :`n`n"=> $a.Path"`n"
	Write-Host "ProcessId :`n`n"=> $a.ProcessId"`n"
	
	if($a.CommandLine -ne $null){
		Write-Host "CommandLine :`n`n"=> $a.CommandLine"`n"
	}
	else{
		Write-Host "CommandLine :`n`n => No associated CommandLine`n"
	}

	if ($a.Path -ne $null){
		$MD5 = (Get-FileHash -Algorithm MD5 $a.Path).Hash
		Write-Host "Process MD5 hash :`n`n"=> $MD5"`n"

		$sha1 = (Get-FileHash -Algorithm SHA1 $a.Path).Hash
		Write-Host "Process SHA1 hash :`n`n"=> $sha1"`n"

		$sha256 = (Get-FileHash -Algorithm SHA256 $a.Path).Hash
		Write-Host "Process SHA256 hash :`n`n"=> $sha256"`n"
	}
	else {
		Write-Host "Hashes :`n`n => No associated image`n"
	}

	Write-Host "CreationDate :`n`n"=> $a.CreationDate"`n"
	Write-Host "ParentProcessId :`n`n"=> $a.ParentProcessId"`n"

	Write-Host "---------------------------------------------------------------------------------"
}

try{

	[Int]$my_pid = Read-Host -Prompt "`nInput PID of the process you want to investigate"
	
	if ($my_pid -gt 0){

		$process_info = gwmi win32_process -Filter "ProcessId = $my_pid"

		if ($process_info -ne $null){

			Write-Host "`n`n`n`n--------------------- CHECKING THE TARGET PROCESS -----------------`n" 

			display-info -a $process_info

			# Recursively check the parents

			Write-Host "`n`n--------------------- CHECKING RECURSIVELY THE PARENT PROCESSES -----------------" 

			do {
				$my_ppid = $process_info.ParentProcessId
				$process_info = gwmi win32_process -Filter "ProcessId = $my_ppid"
				
				if ($process_info -ne $null){
					
					display-info -a $process_info

					if($process_info.ProcessId -eq 0){
						$break = "true"
					}
				}
				else {
					$break = "true"
				}
			} while ($break -ne "true")
		}

		else {
			Write-Host "`n/!\ The process is not running /!\`n"
		}
	}
	else {
		Write-Host "`n/!\ The pid must be positive /!\`n"
	}
}
catch [system.exception] {
	"`n/!\ INPUT ERROR :  The pid must be a positive integer and the target process must be running /!\`n"
}
