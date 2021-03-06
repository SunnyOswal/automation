**Requirement**:  
+ Az Subscription details need to made configurable.
+ Az Resources configuration also needs to be made configurable but with default values.
+ Make sure to use latest Az Powershell in scripts .

**Files Required**:  
+ ARM Template       : VM-DeployAndRunScript.json
+ ARM Params         : parameters.json
+ Powershell Scripts : Trigger-MiningOnWindows.ps1 , Update-ARMParamsFile.ps1

**Azure pipelines Flow**:  
+ **Task 1**: Powershell task will install Az Powershell module .
+ **Task 2**: Powershell task will use Update-ARMParamsFile.ps1 script to update the parameters.json file .
+ **Task 3**: ARM Deployment task will deploy the VM-DeployAndRunScript.json template .
  + VM-DeployAndRunScript.json template first deploys the VM.
  + Then runs the post deployment script (Trigger-MiningOnWindows.ps1) .

**5 Step Solution**:
1. AZ PORTAL : Login
2. AZ PORTAL : Get SubsId . Use in #5 .  
`xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`
3. AZ PORTAL : Create SP using cloud shell .  
`az ad sp create-for-rbac --name azsp`  
**RESPONSE** (Use appId, password, tenant in #5)  
`{
  "appId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "displayName": "azsp",
  "name": "http://azsp",
  "password": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "tenant": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}`
4. AZ DEVOPS : Login
5. AZ DEVOPS : Trigger deployment pipeline and pass params from #2 & #3.  
