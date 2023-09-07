import boto3
import json
import smtplib
import os
import urllib.parse
from email.mime.text import MIMEText

def send_email(host, port, username, password, subject, body, sender, recipients):
    
    msg = MIMEText(body)
    msg['Subject'] = subject
    msg['From'] = sender
    msg['To'] = ', '.join(recipients)
    
    try:
        with smtplib.SMTP_SSL(host, port) as smtp_server:
            smtp_server.login(username, password)
            print("Logged in SMTP server")
            smtp_server.sendmail(sender, recipients, msg.as_string())
            print("Message sent to %s" % recipients)
            return True
    except Exception as ex:
        print (ex)
        return False

def lambda_handler(event, context):
    
    # Get the object from the event and show its content type
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')
    
    try:
        s3 = boto3.client('s3')
        file_obj = s3.get_object(Bucket=bucket, Key=key)
        file_content = file_obj["Body"].read().decode('utf-8')
        json_content = json.loads(file_content)
        service_user_name = json_content["service_user_name"]
        service_password = json_content["service_password"]
        recipients = [json_content["email"]]
    except Exception as ex:
        print (ex)
        return

    # initialize variables
    username = os.environ['USERNAME']
    password = os.environ['PASSWORD']
    host = os.environ['SMTPHOST']
    port = os.environ['SMTPPORT']
    sender = os.environ.get('MAIL_FROM')

    subject = "Git user for codecommit access %s" % recipients
    body = "Attached below please find the credentials for codecommit access:\n\nUser:%s\nPassword:%s\n" % (service_user_name, service_password)

    cors = '*'

    # send mail
    success = False
    if cors:
        success = send_email(host, port, username, password, subject, body, sender, recipients)

    # prepare response
    response = {
        "isBase64Encoded": False,
        "headers": { "Access-Control-Allow-Origin": cors }
    }
    if success:
        response["statusCode"] = 200
        response["body"] = '{"status":true}'
    elif not cors:
        response["statusCode"] = 403
        response["body"] = '{"status":false}'
    else:
        response["statusCode"] = 400
        response["body"] = '{"status":false}'
    return response