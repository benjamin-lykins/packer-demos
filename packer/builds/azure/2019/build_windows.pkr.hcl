source "azure-arm" "windows" {

  // Grab the latest version of the Windows Server 2019 Datacenter
  image_publisher = "MicrosoftWindowsServer"
  image_offer     = "WindowsServer"
  image_sku       = var.windows_version == 2022 ? "${var.windows_version}-datacenter-azure-edition" : "${var.windows_version}-datacenter-gensecond"
  os_type         = "Windows"


  //  Managed images and resource group - exported after build. Resource Group needs to exist prior to build.
  // managed_image_name                = "windows-${var.windows_version}-${local.time}-secure"
  // managed_image_resource_group_name = "demo-packer-rg"

  secure_boot_enabled = true
  vtpm_enabled = true
  security_type = "TrustedLaunch"

  shared_image_gallery_destination {
    subscription   = var.azure_subscription_id
    resource_group = "demo-packer-rg"
    gallery_name   = "acg"
    image_name     = "windows-${var.windows_version}"
    image_version  = "1.0.${local.patch_version}"
  }

  vm_size = "Standard_DS1_v2"

  // While build the image, this resource group is utilized.
  build_resource_group_name = "demo-packer-builds-rg"

  // These are passed in the pipeline as GitHub Secrets.

  subscription_id = var.azure_subscription_id
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  tenant_id       = var.azure_tenant_id

  // WinRM Connection, this is recommended for Windows, SSH would be the recommendation for Linux distributions.
  communicator   = "winrm"
  winrm_insecure = true
  winrm_timeout  = "7m"
  winrm_use_ssl  = true
  winrm_username = "packer"
}


build {
  sources = ["source.azure-arm.windows"]


  provisioner "powershell" {
    inline = ["dir c:/"]
  }


  provisioner "powershell" {
    only = ["azure-arm.windows"]
    inline = [
      "# If Guest Agent services are installed, make sure that they have started.",
      "foreach ($service in Get-Service -Name RdAgent, WindowsAzureTelemetryService, WindowsAzureGuestAgent -ErrorAction SilentlyContinue) { while ((Get-Service $service.Name).Status -ne 'Running') { Start-Sleep -s 5 } }",

      "& $env:SystemRoot\\System32\\Sysprep\\Sysprep.exe /oobe /generalize /quiet /quit /mode:vm",
      "while($true) { $imageState = Get-ItemProperty HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Setup\\State | Select ImageState; if($imageState.ImageState -ne 'IMAGE_STATE_GENERALIZE_RESEAL_TO_OOBE') { Write-Output $imageState.ImageState; Start-Sleep -s 10  } else { break } }"
    ]
  }

  hcp_packer_registry {
    bucket_name = "windows-${var.windows_version}-base"
    description = <<EOT
      This is a base image for Windows Server ${var.windows_version} Datacenter.
    EOT
    bucket_labels = {
      "owner"   = "ahs"
      "os"      = "windows",
      "version" = "${var.windows_version}",
    }
    build_labels = {
      "build-time"   = timestamp()
      "build-source" = basename(path.cwd)
    }
  }
}