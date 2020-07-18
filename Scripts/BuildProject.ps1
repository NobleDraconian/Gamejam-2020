$Required_RojoVersion = "6.0.0-rc.1"
$ProjectFile = $args[0];

cmd.exe /c where /q rojo;
if (-Not $?) {
	Write-Output "Rojo does not appear to be installed on your system or is not on your system path.";
	Write-Output "In order to compile the game, you will need rojo $Required_RojoVersion or above installed.";
} else {
	try {
		# Compiling project with rojo
		$RojoVersion = rojo --version;
		Write-Output "Building project with $RojoVersion...";
		cmd.exe /c rojo.exe build ..\$ProjectFile --output ..\Temp\CurrentBuild.rbxlx;
		if (-Not $?) {
			Throw;
		}

		#Generating checksum and adding it to the compiled game file
		Write-Output "`nGenerating checksum...";
		$Checksum = wsl.exe sha256sum '../Temp/CurrentBuild.rbxlx'
		[IO.File]::WriteAllLines("..\Temp\Checksum.txt", $Checksum)
		cmd.exe /c remodel.exe run AddChecksum.lua
		if (-Not $?) {
			Throw;
		}
		cmd.exe /c del ..\Temp\Checksum.txt
		Write-Output "Checksum generated.";

		Write-Output "`nBuild succeeded.";
	}
	catch {
		Write-Error "`nBuild failed.";
	}
}