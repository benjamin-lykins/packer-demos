# base/debian/debian-12.pkrvars.hcl
# Debian 12 Bookworm — latest supported
# AMI: debian-12-amd64-20250316-2053 (Debian 136693071363)

os_name      = "debian"
os_version   = "12"
source_ami   = "ami-064cdd2e89aa1b4fb"
ssh_username = "admin"
update_cmd   = "sudo apt-get update -y"
