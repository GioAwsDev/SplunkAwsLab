# SplunkAwsLab

This terraform template will create 1 Kali Linux, 1 Ubuntu Desktop, 1 Windows Server 2022 Data Center edition EC2 instance in the Us-East-1 region.  

You will need to change the following variables to run this template: 

variable "public_subnet_cidr"

variable "ssh_winkali_cidr" 

variable "ssh_splunk_cidr" 

variable "splunk_lab_key"

If running this template in a different region, you'll need to update the AMI variables as well for your particular region.  Please note that Kali Linux and Ubuntu Desktop AMI's will need to be subscribed to prior to launching this template.  

In order to login to the Ubuntu (Splunk Instance) you will need to use the instance ID as the password which is an output of the template.