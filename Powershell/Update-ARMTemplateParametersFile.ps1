param(
 [Parameter(Mandatory=$True)]
 [string]
 $parametersFilePath
)

try
{
    #Read parameters.json file
    $paramsFile = Get-Content -Path $parametersFilePath | ConvertFrom-Json 
    
    #Initialize Updated Parameters object
    $updatedParam = New-Object -TypeName PSObject
    $updatedParam | Add-Member -MemberType NoteProperty -Name '$schema' -Value $paramsFile.'$schema'
    $updatedParam | Add-Member -MemberType NoteProperty -Name "contentVersion" -Value $paramsFile.contentVersion
    
    $paramHashTable = @{}
    foreach($param in $paramsFile.parameters.psobject.Properties)
    {
        $paramValueHashTable = @{}
        if($param.Value.value -eq "")
        {
            #Get values from variables
            $paramKey = $param.Name
            Write-Host "Looking for $paramKey environment variable value. "
            $secretValue = (get-item env:$paramKey).Value
                
            $paramValueHashTable["value"] = $secretValue
            $paramHashTable[$param.Name] = $paramValueHashTable
            Write-Host "Found . Environment variable value will be updated in file. "
        }
        else
        {
            $paramValueHashTable["value"] = $param.Value.value
            $paramHashTable[$param.Name] = $paramValueHashTable
        }
    }
    
    $updatedParam | Add-Member -MemberType NoteProperty -Name "parameters" -Value $paramHashTable
    $updatedParam | ConvertTo-Json -Depth 5 | Out-File $parametersFilePath -Encoding utf8 -Force
}
catch
{
    throw $Error[0]
}
