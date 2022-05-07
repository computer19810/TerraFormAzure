provider "azurevm" {
    
}
resource "azurevm_resource_group" "zhttfrg" {
    name = "ZhtResourceGroup"
    location ="eastasia"
    tags {
        environment = "My Terraform Demo"
    }
  
}
resource "azurevm_virtual_machine" "zhttfvm" {
    name = "ZhtVM"
    location = "eastasis"
    resource_group_name = "${azurevm_resource_group.zhttfrg.name}"
    vm_size = ""
    tags {
        environment = "My Terraform Demo"
    }
  
}