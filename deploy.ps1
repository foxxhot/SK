$templatePath = "C:\Users\hu.yi\Desktop\Jsontest\tb\azure-deploy.json"
$parameterPath = "C:\Users\hu.yi\Desktop\Jsontest\tb\parameter.json"
$rgName = "tb-rg1"
New-AzureRmResourceGroupDeployment -Name $rgName -ResourceGroupName $rgName -Mode Incremental -TemplateParameterFile $parameterPath -TemplateFile $templatePath -Verbose