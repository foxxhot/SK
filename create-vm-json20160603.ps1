#入力CSVファイルのパスを指定する
$vm_inputFile = "D:\tb\vm.csv"
$nic_inputFile = "D:\tb\nic.csv"
$pip_inputFile = "D:\tb\pip.csv"
$storage_inputFile = "D:\tb\stg.csv"
$availabilityset_inputFile = "D:\tb\avset.csv"
$vnet_inputFile = "D:\tb\vnet.csv"

#CSVファイルをインポートする
$import_storagecsv = Import-Csv $storage_inputFile -Header "storageAccountName","location","storageAccountType"
$import_availabilitysetcsv = Import-Csv $availabilityset_inputFile -Header "availabilitysetName","location","platformFaultDomainCount","platformUpdateDomainCount"
$import_vnetcsv = Import-Csv $vnet_inputFile -Header "vnetName","location","addressSpace","subnet1Name","subnet1addressPrefix","subnet2Name","subnet2addressPrefix"
$import_niccsv = Import-Csv $nic_inputFile -Header "nicName","location","vnetName","subnetName","privateIPAllocationMethod","privateIPAddress","pipName"
$import_vmcsv = Import-Csv $vm_inputFile -Header "vmName","hostName","location","rgName","vmSize","availabilitySetName",
"imagePublisher","imageOffer","osSku","version","networkInterface1","networkInterface2",`
"networkInterface3","osDiskName","osDiskStorageAccountName","osDiskStorageAccountContainerName","osDiskSize"
$import_pipcsv = Import-Csv $pip_inputFile -Header "pipName","location","AllocationMethod","IdleTimeoutInMinutes","DomainNameLabel"


#JSONテンプレートを格納するオブジェクトを作成する
$json_object = New-Object psobject

#JSONテンプレートのheaderを入力する
$json_object| Add-Member -MemberType NoteProperty -PassThru `$schema "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#"
$json_object| Add-Member -MemberType NoteProperty -PassThru contentVersion "1.0.0.0"

#リソース用のarrayを作成
$resources_array = @()

#dependsOn用のarrayを作成する
$dependsOn_storage_array= @()
$dependsOn_availabilityset_array= @()
$dependsOn_pip_array = @()
$dependsOn_nic_array= @()
$dependsOn_vnet_array=@()

############### storage部分のテンプレートを作成する ###############
foreach($item_storage in $import_storagecsv){
    #storage json情報を格納するオブジェクトを作成する
    $storage = New-Object psobject

    #storage の基本情報をオブジェクトに入れる
    $storage | Add-Member -MemberType NoteProperty -PassThru apiVersion "2015-06-15"
    $storage | Add-Member -MemberType NoteProperty -PassThru type "Microsoft.Storage/storageAccounts"
    $storage | Add-Member -MemberType NoteProperty -PassThru name $item_storage.storageAccountName
    $storage | Add-Member -MemberType NoteProperty -PassThru location $item_storage.location
  
        #storageのpropertiesオブジェクトを作成する
        $storage_properties = New-Object psobject
        $storage_properties | Add-Member -MemberType NoteProperty -PassThru accountType $item_storage.storageAccountType

    $storage | Add-Member -MemberType NoteProperty -PassThru properties $storage_properties

    $resources_array += $storage
            
    #storageのdependsOn情報を作成する
    $dependsOn_storage_current = "Microsoft.Storage/storageAccounts/"+$item_storage.storageAccountName
    $dependsOn_storage_array += $dependsOn_storage_current
}


############### availabilityset部分のテンプレートを作成する ###############
foreach($item_availabilityset in $import_availabilitysetcsv){
    #availabilityset json情報を格納するオブジェクトを作成する
    $availabilityset = New-Object psobject

    #availabilityset の基本情報をオブジェクトに入れる
    $availabilityset | Add-Member -MemberType NoteProperty -PassThru apiVersion "2015-06-15"
    $availabilityset | Add-Member -MemberType NoteProperty -PassThru type "Microsoft.Compute/availabilitySets"
    $availabilityset | Add-Member -MemberType NoteProperty -PassThru name $item_availabilityset.availabilitysetName
    $availabilityset | Add-Member -MemberType NoteProperty -PassThru location $item_availabilityset.location
    $availabilityset | Add-Member -MemberType NoteProperty -PassThru dependsOn $dependsOn_storage_array
  
        #availabilitysetのpropertiesオブジェクトを作成する
        $availabilityset_properties = New-Object psobject
        $availabilityset_properties | Add-Member -MemberType NoteProperty -PassThru platformFaultDomainCount $item_availabilityset.platformFaultDomainCount
        $availabilityset_properties | Add-Member -MemberType NoteProperty -PassThru platformUpdateDomainCount $item_availabilityset.platformUpdateDomainCount
    
    $availabilityset | Add-Member -MemberType NoteProperty -PassThru properties $availabilityset_properties
    $resources_array += $availabilityset
            
    #availabilitysetのdependsOn情報を作成する
    $dependsOn_availabilityset_current = "Microsoft.Compute/availabilitySets/"+$item_availabilityset.availabilitysetName
    $dependsOn_availabilityset_array += $dependsOn_availabilityset_current
}

############### vnet部分のテンプレートを作成する ###############
foreach($item_vnet in $import_vnetcsv){
    #vnet json情報を格納するオブジェクトを作成する
    $vnet = New-Object psobject

    #vnet の基本情報をオブジェクトに入れる
    $vnet | Add-Member -MemberType NoteProperty -PassThru apiVersion "2015-06-15"
    $vnet | Add-Member -MemberType NoteProperty -PassThru type "Microsoft.Network/virtualNetworks"
    $vnet | Add-Member -MemberType NoteProperty -PassThru name $item_vnet.vnetName
    $vnet | Add-Member -MemberType NoteProperty -PassThru location $item_vnet.location
    $vnet | Add-Member -MemberType NoteProperty -PassThru dependsOn $dependsOn_availabilityset_array
  
        #vnetのpropertiesオブジェクトを作成する
        $vnet_properties = New-Object psobject

            $vnet_properties_addressSpace = New-Object psobject

                $vnet_properties_addressSpace_addressPrefixes_array = @()

                $vnet_properties_addressSpace_addressPrefixes_array += $item_vnet.addressSpace

            $vnet_properties_addressSpace| Add-Member -MemberType NoteProperty -PassThru addressPrefixes $vnet_properties_addressSpace_addressPrefixes_array

            $vnet_properties_subnets_array = @()

                $vnet_properties_subnets = New-Object psobject

                $vnet_properties_subnets | Add-Member -MemberType NoteProperty -PassThru name $item_vnet.subnet1Name

                $vnet_properties_subnets_properties = New-Object psobject

                $vnet_properties_subnets_properties | Add-Member -MemberType NoteProperty -PassThru addressPrefix $item_vnet.subnet1addressPrefix

                $vnet_properties_subnets | Add-Member -MemberType NoteProperty -PassThru properties  $vnet_properties_subnets_properties

            $vnet_properties_subnets_array += $vnet_properties_subnets

            if(($item_vnet.subnet2Name-ne $null) -and ($item_vnet.subnet2Name -ne "")){

                $vnet_properties_subnets = New-Object psobject

                $vnet_properties_subnets | Add-Member -MemberType NoteProperty -PassThru name $item_vnet.subnet2Name

                $vnet_properties_subnets_properties = New-Object psobject

                $vnet_properties_subnets_properties | Add-Member -MemberType NoteProperty -PassThru addressPrefix $item_vnet.subnet2addressPrefix

                $vnet_properties_subnets | Add-Member -MemberType NoteProperty -PassThru properties  $vnet_properties_subnets_properties

                $vnet_properties_subnets_array += $vnet_properties_subnets

            }

        $vnet_properties | Add-Member -MemberType NoteProperty -PassThru addressSpace $vnet_properties_addressSpace

        $vnet_properties | Add-Member -MemberType NoteProperty -PassThru subnets $vnet_properties_subnets_array 

    $vnet | Add-Member -MemberType NoteProperty -PassThru properties $vnet_properties

    $resources_array += $vnet
         
    #vnetのdependsOn情報を作成する
    $dependsOn_vnet_current = "Microsoft.Network/virtualNetworks/"+$item_vnet.vnetName
    $dependsOn_vnet_array += $dependsOn_vnet_current
}

############### PIP部分のテンプレートを作成する ###############
foreach($item_pip in $import_pipcsv){
    #pip json情報を格納するオブジェクトを作成する
    $pip = New-Object psobject

    #pip の基本情報をオブジェクトに入れる
    $pip | Add-Member -MemberType NoteProperty -PassThru apiVersion "2015-06-15"
    $pip | Add-Member -MemberType NoteProperty -PassThru type "Microsoft.Network/publicIPAddresses"
    $pip | Add-Member -MemberType NoteProperty -PassThru name $item_pip.pipName
    $pip | Add-Member -MemberType NoteProperty -PassThru location $item_pip.location
    $pip | Add-Member -MemberType NoteProperty -PassThru dependsOn $dependsOn_vnet_array

        #pipのpropertiesオブジェクトを作成する
        $pip_properties = New-Object psobject
        $pip_properties | Add-Member -MemberType NoteProperty -PassThru publicIPAllocationMethod $item_pip.AllocationMethod
            
            $pip_properties_dnsSettings = New-Object psobject
            $pip_properties_dnsSettings | Add-Member -MemberType NoteProperty -PassThru domainNameLabel $item_pip.DomainNameLabel

        $pip_properties | Add-Member -MemberType NoteProperty -PassThru dnsSettings $pip_properties_dnsSettings
    
    #pipのpropertiesオブジェクトを作成する
    $pip | Add-Member -MemberType NoteProperty -PassThru properties $pip_properties 

    $resources_array += $pip
    
    #pipのdependsOn情報を作成する
    $dependsOn_pip_current = "Microsoft.Network/publicIPAddresses/"+$item_pip.pipName
    $dependsOn_pip_array += $dependsOn_pip_current

}


############### NIC部分のテンプレートを作成する ###############
foreach($item_nic in $import_niccsv){
 
        #create nic object
        $nic = New-Object psobject

        #create basic information
        $nic | Add-Member -MemberType NoteProperty -PassThru apiVersion "2015-06-15"
        $nic | Add-Member -MemberType NoteProperty -PassThru type "Microsoft.Network/networkInterfaces"
        $nic | Add-Member -MemberType NoteProperty -PassThru name $item_nic.nicName
        $nic | Add-Member -MemberType NoteProperty -PassThru location $item_nic.location
        $nic | Add-Member -MemberType NoteProperty -PassThru dependsOn $dependsOn_pip_array
  
            #create properties object
            $nic_properties = New-Object psobject

                ### ipConfigurations
                $nic_ipConfigurations_array = @()

                    $nic_ipConfigurations =  New-Object psobject
                    $nic_ipConfigurations | Add-Member -MemberType NoteProperty -PassThru name "ipconfig1"

                    $nic_ipConfigurations_properties = New-Object psobject
                    $nic_ipConfigurations_properties | Add-Member -MemberType NoteProperty -PassThru privateIPAllocationMethod  $item_nic.privateIPAllocationMethod

                    if($item_nic.privateIPAllocationMethod -eq "static"){
                        $nic_ipConfigurations_properties | Add-Member -MemberType NoteProperty -PassThru privateIPAddress  $item_nic.privateIPAddress
                    }

                    if(($item_nic.pipName -ne $null) -and ($item_nic.pipName -ne "")){
                        $nic_ipConfigurations_properties_publicIPAddress = New-Object psobject
                        $pip_id = "[resourceId('Microsoft.Network/publicIPAddresses','"+ $item_nic.pipName+"')]"
                        $nic_ipConfigurations_properties_publicIPAddress | Add-Member -MemberType NoteProperty -PassThru id  $pip_id
                        $nic_ipConfigurations_properties | Add-Member -MemberType NoteProperty -PassThru publicIPAddress $nic_ipConfigurations_properties_publicIPAddress
                    }

                    $nic_ipConfigurations_properties_subnet = New-Object psobject
                    $vnet_id = "resourceId('Microsoft.Network/virtualNetworks','"+ $item_nic.vnetName+"')"
                    $subnet_id = "[concat("+$vnet_id+",'/subnets/"+$item_nic.subnetName+"')]"     
                    $nic_ipConfigurations_properties_subnet | Add-Member -MemberType NoteProperty -PassThru id  $subnet_id 
                    $nic_ipConfigurations_properties | Add-Member -MemberType NoteProperty -PassThru subnet $nic_ipConfigurations_properties_subnet

                    $nic_ipConfigurations | Add-Member -MemberType NoteProperty -PassThru properties $nic_ipConfigurations_properties
            
                $nic_ipConfigurations_array += $nic_ipConfigurations

            $nic_properties | Add-Member -MemberType NoteProperty -PassThru ipConfigurations $nic_ipConfigurations_array

        $nic| Add-Member -MemberType NoteProperty -PassThru properties $nic_properties

    $resources_array += $nic

    $dendesOn_nic_current = "Microsoft.Network/networkInterfaces/"+$item_nic.nicName
    $dependsOn_nic_array += $dendesOn_nic_current

}


############### VM 部分のテンプレートを作成する###############
foreach($item_vm in $import_vmcsv){

    #create vm object
    $vm = New-Object psobject

        ########create basic information
        $vm| Add-Member -MemberType NoteProperty -PassThru apiVersion "2015-06-15"
        $vm| Add-Member -MemberType NoteProperty -PassThru type "Microsoft.Compute/virtualMachines"
        $vm| Add-Member -MemberType NoteProperty -PassThru name $item_vm.vmName
        $vm| Add-Member -MemberType NoteProperty -PassThru location $item_vm.location
        $vm| Add-Member -MemberType NoteProperty -PassThru dependsOn $dependsOn_nic_array
    
        ########create properties object
        $vm_properties = New-Object psobject

            ####hardwareProfile
            $vm_properties_hardwareProfile = New-Object psobject
            $vm_properties_hardwareProfile| Add-Member -MemberType NoteProperty -PassThru vmSize $item_vm.vmSize
            $vm_properties |Add-Member -MemberType NoteProperty -PassThru hardwareProfile $vm_properties_hardwareProfile
            
            ####osProfile
            $vm_properties_osProfile = New-Object psobject
            $vm_properties_osProfile| Add-Member -MemberType NoteProperty -PassThru computerName $item_vm.hostName
            $vm_properties_osProfile| Add-Member -MemberType NoteProperty -PassThru adminUsername "feadmin"
            $vm_properties_osProfile| Add-Member -MemberType NoteProperty -PassThru adminPassword "Qweasd123"
            $vm_properties |Add-Member -MemberType NoteProperty -PassThru osProfile $vm_properties_osProfile

            ####storageProfile
            $vm_properties_storageProfile = New-Object psobject
                #imageReference
                $vm_properties_storageProfile_imageReference = New-Object psobject
                $vm_properties_storageProfile_imageReference| Add-Member -MemberType NoteProperty -PassThru publisher $item_vm.imagePublisher
                $vm_properties_storageProfile_imageReference| Add-Member -MemberType NoteProperty -PassThru offer $item_vm.imageOffer
                $vm_properties_storageProfile_imageReference| Add-Member -MemberType NoteProperty -PassThru sku $item_vm.osSku
                $vm_properties_storageProfile_imageReference| Add-Member -MemberType NoteProperty -PassThru version $item_vm.version

                #osDisk
                $vm_properties_storageProfile_osDisk = New-Object psobject
                $vm_properties_storageProfile_osDisk| Add-Member -MemberType NoteProperty -PassThru name "odisk1"
                $vm_properties_storageProfile_osDisk| Add-Member -MemberType NoteProperty -PassThru caching "ReadWrite"
                $vm_properties_storageProfile_osDisk| Add-Member -MemberType NoteProperty -PassThru createOption "FromImage"

                    #osDisk_vhd
                    $vm_properties_storageProfile_osDisk_vhd = New-Object psobject
                    $osDiskurl = "https://"+$item_vm.osDiskStorageAccountName+".blob.core.windows.net/"+$item_vm.osDiskStorageAccountContainerName+"/"+$item_vm.osDiskName+".vhd"
                    $vm_properties_storageProfile_osDisk_vhd | Add-Member -MemberType NoteProperty -PassThru uri $osDiskurl
                    $vm_properties_storageProfile_osDisk| Add-Member -MemberType NoteProperty -PassThru vhd $vm_properties_storageProfile_osDisk_vhd
          
            $vm_properties_storageProfile| Add-Member -MemberType NoteProperty -PassThru imageReference $vm_properties_storageProfile_imageReference
            $vm_properties_storageProfile| Add-Member -MemberType NoteProperty -PassThru osDisk $vm_properties_storageProfile_osDisk
            $vm_properties |Add-Member -MemberType NoteProperty -PassThru storageProfile $vm_properties_storageProfile

            ####networkProfile
            $vm_properties_networkProfile = New-Object psobject
                #networkInterfaces
                $vm_properties_networkProfile_networkInterfaces_array = @()
                $vm_properties_networkProfile_networkInterfaces = New-Object psobject
                    
                    #networkInterfaces_properties
                    $vm_properties_networkProfile_networkInterfaces_properties = New-Object psobject
                    $vm_properties_networkProfile_networkInterfaces_properties |Add-Member -MemberType NoteProperty -PassThru primary "true"
                    $vm_properties_networkProfile_networkInterfaces| Add-Member -MemberType NoteProperty -PassThru properties $vm_properties_networkProfile_networkInterfaces_properties

                    #networkInterfaces_id
                    $nic_id = "[resourceId('Microsoft.Network/networkInterfaces','"+ $item_vm.networkInterface1+"')]"
                    $vm_properties_networkProfile_networkInterfaces| Add-Member -MemberType NoteProperty -PassThru id $nic_id

                $vm_properties_networkProfile_networkInterfaces_array += $vm_properties_networkProfile_networkInterfaces


                if(($item_vm.networkInterface2-ne $null) -and ($item_vm.networkInterface2 -ne "")){
                    $vm_properties_networkProfile_networkInterfaces = New-Object psobject
                    
                    #networkInterfaces_properties
                    $vm_properties_networkProfile_networkInterfaces_properties = New-Object psobject
                    $vm_properties_networkProfile_networkInterfaces_properties |Add-Member -MemberType NoteProperty -PassThru primary "false"
                    $vm_properties_networkProfile_networkInterfaces| Add-Member -MemberType NoteProperty -PassThru properties $vm_properties_networkProfile_networkInterfaces_properties

                    #networkInterfaces_id
                    $nic_id = "[resourceId('Microsoft.Network/networkInterfaces','"+ $item_vm.networkInterface2+"')]"
                    $vm_properties_networkProfile_networkInterfaces| Add-Member -MemberType NoteProperty -PassThru id $nic_id

                    $vm_properties_networkProfile_networkInterfaces_array += $vm_properties_networkProfile_networkInterfaces

                }

                if(($item_vm.networkInterface3-ne $null) -and ($item_vm.networkInterface3 -ne "")){
                    $vm_properties_networkProfile_networkInterfaces = New-Object psobject
                    
                    #networkInterfaces_properties
                    $vm_properties_networkProfile_networkInterfaces_properties = New-Object psobject
                    $vm_properties_networkProfile_networkInterfaces_properties |Add-Member -MemberType NoteProperty -PassThru primary "false"
                    $vm_properties_networkProfile_networkInterfaces| Add-Member -MemberType NoteProperty -PassThru properties $vm_properties_networkProfile_networkInterfaces_properties

                    #networkInterfaces_id
                    $nic_id = "[resourceId('Microsoft.Network/networkInterfaces','"+ $item_vm.networkInterface3+"')]"
                    $vm_properties_networkProfile_networkInterfaces| Add-Member -MemberType NoteProperty -PassThru id $nic_id

                    $vm_properties_networkProfile_networkInterfaces_array += $vm_properties_networkProfile_networkInterfaces

                }

            $vm_properties_networkProfile | Add-Member -MemberType NoteProperty -PassThru networkInterfaces $vm_properties_networkProfile_networkInterfaces_array
            $vm_properties |Add-Member -MemberType NoteProperty -PassThru networkProfile $vm_properties_networkProfile

            ###availabilitySet
            if(($item_vm.availabilitySetName-ne $null) -and ($item_vm.availabilitySetName -ne "")){
                $vm_properties_availabilitySet = New-Object psobject

                    $availabilitySet_id = "[resourceId('Microsoft.Compute/availabilitySets','"+ $item_vm.availabilitySetName+"')]"

                $vm_properties_availabilitySet| Add-Member -MemberType NoteProperty -PassThru id $availabilitySet_id            
            
                $vm_properties |Add-Member -MemberType NoteProperty -PassThru availabilitySet $vm_properties_availabilitySet           
            
            }

            ####diagnosticsProfile
            $vm_properties_diagnosticsProfile = New-Object psobject

                #bootDiagnostics
                $vm_properties_diagnosticsProfile_bootDiagnostics = New-Object psobject
                $vm_properties_diagnosticsProfile_bootDiagnostics| Add-Member -MemberType NoteProperty -PassThru enabled "true"
                $storageUri = "https://"+$item_vm.osDiskStorageAccountName+".blob.core.windows.net/"
                $vm_properties_diagnosticsProfile_bootDiagnostics| Add-Member -MemberType NoteProperty -PassThru storageUri $storageUri 

            $vm_properties_diagnosticsProfile| Add-Member -MemberType NoteProperty -PassThru bootDiagnostics $vm_properties_diagnosticsProfile_bootDiagnostics
            $vm_properties |Add-Member -MemberType NoteProperty -PassThru diagnosticsProfile $vm_properties_diagnosticsProfile

    $vm| Add-Member -MemberType NoteProperty -PassThru properties $vm_properties

    $resources_array += $vm
}

$json_object| Add-Member -MemberType NoteProperty -PassThru resources $resources_array

$json_object|ConvertTo-Json -Depth 10 | Out-File -FilePath D:\deploy.json