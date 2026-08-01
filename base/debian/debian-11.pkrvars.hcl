# base/debian/debian-11.pkrvars.hcl
# Debian 11 Bullseye — previous supported
# AMI: debian-11-amd64-20250428-2096 (Debian 136693071363)

os_name      = "debian"
os_version   = "11"
source_ami   = "ami-09bd9a01cee33eb54"
ssh_username = "admin"
update_cmd   = "sudo apt-get update -y"
