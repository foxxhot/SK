1.Create vm, nic, pip csv file from parameter file.

2.open vm.ps1, modify the path to the current location of vm.csv

3.run vm.ps1 and generate vm.json

4.open nic.ps1, modify the path to the current location of nic.csv

5.run nic.ps1 and generate nic.json

6.copy the content of vm.json nic.json into parameter.json

7.modify the password and admin in parameter.json

8.modify the parameter of the vnet, storage, availabilityset in azure-deploy.json

9.modify the path in deploy.json

10.run deloy.json

11.run pip.json
