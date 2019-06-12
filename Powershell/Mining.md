**Files Required**:  
+ ARM Template       : VM-DeployAndRunScript.json
+ ARM Params         : parameters.json
+ Powershell Scripts : Trigger-MiningOnWindows.ps1 , Update-ARMParamsFile.ps1

**Azure pipelines Flow**:  
+ **Task 1**: Powershell task will use Update-ARMParamsFile.ps1 script to update the parameters.json file .
+ **Task 2**: ARM Deployment task will deploy the VM-DeployAndRunScript.json template .
  + VM-DeployAndRunScript.json template first deploys the VM.
  + Then runs the post deployment script (Trigger-MiningOnWindows.ps1) .
