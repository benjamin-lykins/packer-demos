source "azure-arm" "windows" {

  // Grab the latest version of the Windows Server 2019 Datacenter
  image_publisher = "MicrosoftWindowsServer"
  image_offer     = "WindowsServer"
  image_sku       = "${var.windows_version}-Datacenter"
  os_type         = "Windows"


  //  Managed images and resource group - exported after build. Resource Group needs to exist prior to build.
  managed_image_name                = "windows-${var.windows_version}-${local.time}"
  managed_image_resource_group_name = "packer-rg"

  shared_image_gallery  {
    subscription_id = var.azure_subscription_id
    resource_group  = "packer-rg"
    gallery_name    = "packer-gallery"
    image_name      = "windows-${var.windows_version}-${local.time}"
    image_version   = "1.0.0"
  }

  vm_size = "Standard_DS1_v2"

  // While buildding the image, this resource group is utilized.
  build_resource_group_name = "packer-builds-rg"

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
    pause_before = "5s"
    inline = [
      "Write-Host '***** this is a demo message *****'"
    ]
  }

  // provisioner "windows-update" {
  // }

  provisioner "cnspec" {
    on_failure      = "continue"
    score_threshold = 85
    sudo {
      active = true
    }
  }

  # Generalising the image
  # This only runs on the Azure source.
  provisioner "powershell" {
    only = ["source.azure-arm.windows"]
    inline = [
      "Write-host '=== Azure image build completed successfully ==='",
      "Write-host '=== Generalising the image ... ==='",
      "& $env:SystemRoot\\System32\\Sysprep\\Sysprep.exe /generalize /oobe /quit",
      "while($true) { $imageState = Get-ItemProperty HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Setup\\State | Select ImageState; if($imageState.ImageState -ne 'IMAGE_STATE_GENERALIZE_RESEAL_TO_OOBE') { Write-Output $imageState.ImageState; Start-Sleep -s 10  } else { break } }"
    ]
  }
}