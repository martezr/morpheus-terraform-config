// AMI Cleanup Script
resource "morpheus_python_script_task" "tech_marketing_aws_ami_cleanup" {
  name                = "Tech Marketing AWS AMI Cleanup"
  code                = "tech_marketing_aws_ami_cleanup"
  source_type         = "local"
  result_type         = "json"
  script_content      = <<EOF
import boto3
from tabulate import tabulate
import datetime
import time
from morpheuscypher import Cypher

# Expiration days
expiration_days = 30
timeLimit = datetime.datetime.now() - 
datetime.timedelta(days=expiration_days)
data = []

# Fetch AWS account credentials from Cypher
access_key=Cypher(morpheus=morpheus).get('secret/aws-access-key')
secret_key=Cypher(morpheus=morpheus).get('secret/aws-secret-key')

ec2 = boto3.resource('ec2', region_name='us-east-1', 
					 aws_access_key_id=access_key,
                     aws_secret_access_key=secret_key)
client = boto3.client('ec2', region_name='us-east-1',
					 aws_access_key_id=access_key,
                     aws_secret_access_key=secret_key)
response = client.describe_images(Owners=['self'])

# Iterate over the AMIs
for ami in response['Images']:
    row = []
    row.append(ami['Name'])
    row.append(ami['ImageId'])

    # Convert the AMI creation date to a date format to compare with the 
current date
    creation_date_raw=ami['CreationDate']
    creation_date_raw_1=tuple(creation_date_raw.split('T'))
    creation_date=creation_date_raw_1[0]
    creation_date_object = datetime.datetime.strptime(creation_date, 
'%Y-%m-%d').date()
    row.append(creation_date_object)
    if creation_date_object <  timeLimit.date():
        row.append(True)
        ec2.deregister_image(ImageId=ami['ImageId'])
    else:
        row.append(False)

    data.append(row)

# Print the formatted table
print(tabulate(data, headers=["Name", "ID", "CreationDate", "Expired"]))
EOF
  additional_packages = "boto3 tabulate morpheus-cypher"
  python_binary       = "/usr/bin/python3"
  retryable           = true
  retry_count         = 1
  retry_delay_seconds = 10
}

resource "morpheus_execute_schedule" "tech_marketing_daily_ami_cleanup" {
  name        = "Run daily at 7 AM"
  description = "This schedule runs daily at 7 AM Mountain Time"
  enabled     = true
  time_zone   = "America/Denver"
  schedule    = "0 7 * * *"
}

resource "morpheus_operational_workflow" "tech_marketing_self_service_op_workflow" {
  name                = "Tech Marketing Self Service Operational Workflow"
  description         = "Tech Marketing operational workflow"
  platform            = "all"
  visibility          = "private"
}
