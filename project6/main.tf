resource "local_file" "terraform_info" {
  filename = "terraform_version.txt"
  content  = "Terraform Version Control Demo - Version 2"
}
