Param
(
[Parameter(Mandatory=$True)] $exeDownloadUrl,
[Parameter(Mandatory=$True)] $exeName,
[Parameter(Mandatory=$True)] $coin,
[Parameter(Mandatory=$True)] $cpu,
[Parameter(Mandatory=$True)] $email
)

$exeDownloadedZipPath = 'C:\cli.zip'
$exeLocalPath = 'C:\cli'
$argumentList = "--user $email --$coin $cpu"

function Disable-ieESC {

    $AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"

    $UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"

    Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0

    Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0

    Stop-Process -Name Explorer
}

# Disable IE Security
Disable-ieESC

# Remove Windows Defender
Remove-WindowsFeature Windows-Defender, Windows-Defender-GUI

# Download exe
Invoke-WebRequest $exeDownloadUrl -OutFile $exeDownloadedZipPath -UseBasicParsing

# UnZip exe
Expand-Archive -LiteralPath $exeDownloadedZipPath -DestinationPath $exeLocalPath -Force

# Run exe
Invoke-Command -ScriptBlock { param($exeName,$exeLocalPath,$argumentList) Start-Process -FilePath $exeName -WorkingDirectory $exeLocalPath -ArgumentList $argumentList} -ArgumentList $exeName,$exeLocalPath,$argumentList -InDisconnectedSession
