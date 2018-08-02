#====================================================================================================================================
#This script will :
#  1. Trigger migration of single/multiple VM's from 1 host to another host asynchronously.
#     This will choose best volume and best target host for migration.
#  2. Monitor trigerred Jobs.
#  3. Send email once job status changes to anything except "running".
# Input Required:
#     vmListPath      = Name of VM's in a list. Each VM separated by new line.
#     targetHostGroup = Name of the host group from where best target host will be decided.
#====================================================================================================================================

[CmdletBinding()]
param(
[parameter(mandatory=$true)]$vmListPath      = "D:\Users\Sunny\VM-Migration-List.txt" ,
[parameter(mandatory=$true)]$targetHostGroup = "TargetHostGroup"
)

Function Send-Email
{
	param
	(
		[Parameter(Position=0, Mandatory=$true)]$subject, 
		[Parameter(Position=1, Mandatory=$true)]$body,
		[Parameter(Position=2, Mandatory=$true)]$tolist,
		[Parameter(Position=3, Mandatory=$true)][AllowNull()]$cclist,
    [Parameter(Position=4, Mandatory=$true)]$smtpServer,
    [Parameter(Position=3, Mandatory=$true)]$from
	)
  
	$smtp = New-Object Net.Mail.SmtpClient($smtpServer)
	$msg = New-Object Net.Mail.MailMessage
	$msg.From = $from
	foreach($recipient in $tolist)
	{
		$msg.To.Add($recipient)
	}
	foreach($recipient in $cclist)
	{
		$msg.CC.Add($recipient)
	}
	$msg.Body = $body
	$msg.Subject = $subject
	$msg.IsBodyHTML = $true
	$smtp.Send($msg)
}

$emailToList        = @("sunny@xyz.com")
$from               = "sunny@xyz.com"
$smtpServer         = "xyz.com"
$vmList             = Get-Content -Path $vmListPath

#Move Action
foreach ($vm in $vmList)
{
    #Get Virtual machine with a specified name:
    $vm             = Get-SCVirtualMachine | Where {  $_.name -eq $vm }

    #Find best volume from the avaialbale list of volumes of the target host.
    $bestVolume     = Get-VMHostVolume –vmhost $vmhost | where {$_.Name –match “clusterstorage”} | sort-object –descending FreeSpace | select -first 1

    #Creates a unique job ID so you can monitor the status in VMM
    $JobGroupID     = [Guid]::NewGuid().ToString()

    #Finds best target host from the targetHostGroup
    $SCHostGroup    = Get-SCVMHostGroup -Name $targetHostGroup
    $bestTargetHost = Get-SCVMHostRating -HighlyAvailable $true -VMHostGroup $SCHostGroup -VM $vm | Sort-Object Rating -Descending | select -first 1 

    Move-SCVirtualMachine -VM $vm -VMHost $bestTargetHost.VMHost  -HighlyAvailable $true -UseLAN `
                          -Path $bestVolume -RunAsynchronously -UseDiffDiskOptimization -JobGroup $JobGroupID
}

#Get VM Migration job status
$VMMJob = Get-SCJob | where{$_.status -match "running"} | Select-Object -Property ID,Owner,Description,Progress

if([string]::IsNullOrEmpty($VMMJob)) 
{
   Write-Host "No runnning jobs"
   Exit
}
     
while((Get-SCJob -ID $VMMJob.ID).Status -eq 'Running')
{
   
   Start-Sleep -Seconds 3
   Write-host "VMMJob"$VMMJob.Description""
   Write-Host "Progress"$VMMJob.Progress"%"
   Write-host "Owner"$VMMJob.Owner""
}

  
$status = (Get-SCJob -ID $VMMJob.ID).Status           
if($status -notmatch "Running")
{
    $subject = $VMMJob.Description.Name + "is " + $Status
    $body = $VMMJob.Description.Name + "started by " + $VMMJob.Owner + " is " + $status
    Send-Email -tolist $emailToList -subject $subject -body $body -from $from -smtpServer $smtpServer
}
