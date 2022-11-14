import json
import boto3
import os

def send_request(body):
    print(body)
    # Create an SNS client
    sns = boto3.client('sns')
 
    # Publish a simple message to the specified SNS topic
    response = sns.publish(
        TopicArn=os.environ['email_topic'],    
        Message=body,    
    )
 
    # Print out the response
    print(response)
 
def lambda_handler(event, context):
    print(event)
    batch_processes=[]
    for record in event['Records']:
        send_request(record["body"])
         
 
