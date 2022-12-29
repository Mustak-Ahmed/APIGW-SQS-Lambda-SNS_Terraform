# Integrate API Getway, SQS,Lambda and SNS using Terraform.

automation using terraform for apigw-sqs-lambda-sns.
User sends the request through api getway then it will store in sqs. Lambda will trigger and process the requests and if fail to process any request 
then it will send the request to DLQ and notication will trigger through SNS.

## Running the demo
Clone the repo.
terraform init
terraform plan
terraform apply -auto-approve
