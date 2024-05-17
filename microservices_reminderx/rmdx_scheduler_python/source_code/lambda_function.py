import boto3
import json
import uuid

scheduler = boto3.client('scheduler')

def lambda_handler(event, context):
    try:
        # Parsing request body to get Id and name parameters
        body = json.loads(event['body'])
        id = body.get('id')
        name = body.get('name')
        email = body.get('email')
        phone = body.get('phone')
        message = body.get('message')
        reminder_day = body.get('reminder_day')
        reminder_hour = body.get('reminder_hour')
        reminder_minute = body.get('reminder_minute')

        # Print the id, name, and email parameters
        print("id:", id)
        print("name:", name)
        print("email:", email)
        print("phone:", phone)
        print("message:", message)
        print("reminder_day:", reminder_day)
        print("reminder_hour:", reminder_hour)
        print("reminder_minute:", reminder_minute)

        # Validating if the phone variable is not null and not empty
        send_sms = False
        if phone is not None and phone.strip() != "":
            print("Phone variable is not null and not empty.")
            send_sms = True
        else:
            print("Phone variable is null or empty.")
            # Handle the case where phone variable is null or empty
    
        # Validating if the email variable is not null and not empty
        send_email = False
        if email is not None and email.strip() != "":
            print("Email variable is not null and not empty.")
            send_email = True
        else:
            print("Email variable is null or empty.")
            # Handle the case where email variable is null or empty
    
        # Constructing the filter policy
        filter_policy = {
            "send_email": ["true" if send_email else "false"],
            "send_sms": ["true" if send_sms else "false"]
        }

        # Creating schedule with received Id, name, email, phone, and message parameters
        response = scheduler.create_schedule(
            FlexibleTimeWindow={'Mode': 'OFF'},
            ScheduleExpression=f'cron({reminder_minute} {reminder_hour} {reminder_day} * ? *)',  # cron expression for reminder_day and reminder_time
            ScheduleExpressionTimezone='America/Bogota',  # Using IANA time zone name
            Target={
                'Arn': 'arn:aws:sns:us-east-1:826738023599:sch-NotificationTopics',  # SNS topic ARN
                'Input': json.dumps({"id": id, "name": name, "email": email, "phone": phone, "message": message, "filter_policy": filter_policy}),  # Passing Id, name, email, phone, and message in the input
                'RoleArn': 'arn:aws:iam::826738023599:role/sch-EventBridgeSchedulerAssumePolicy',
            },
            Name=str(uuid.uuid4())  # Customer1-UUID
        )
    
        schedule_id = response['ScheduleArn'].split('/')[-1]  # Extracting schedule ID from ARN
    
        print("schedule_id:", schedule_id)
        print("response:", response)

        # Return the response object with schedule ID in the body of the Lambda function's response
        return {
            'statusCode': 200,
            'body': json.dumps({'response': response, 'schedule_id': schedule_id})
        }
    
    except Exception as e:
        print("Error:", str(e))
        
        return {
            'statusCode': 500,
            'body': {
                'message': 'Failed to create Schedule',
                'result': json.dumps({'error': str(e)})
            }
        }