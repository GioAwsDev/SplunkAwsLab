variable "windows_ami_id" {
  description = "Windows Server 2022"
  type        = string
  default     = "ami-00d990e7e5ece7974" # You can set a default value if needed
  
}

variable "ubuntu_ami_id" {
  description = "Ubuntu Desktop"
  type        = string
  default     = "ami-0fe3d2e3c3461f27e" # You can set a default value if needed
}

variable "kali_ami_id" {
  description = "Kali Linux"
  type        = string
  default     = "ami-073bfde00267aa596" # You can set a default value if needed
}

# Define a variable for the key pair name
variable "splunk_lab_key" {
  description = "Name of the key pair to associate with the instance"
  default     = "NameOfKeyPair" # Default value, you can change it as needed
}

variable "region" {
  default = "us-east-1"
}

variable "public_subnet_cidr" {
  default = "10.20.0.0/22"
}