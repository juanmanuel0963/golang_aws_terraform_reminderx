package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"strings"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/scheduler"
	"github.com/google/uuid"
)

//var db *gorm.DB

func init() {
	/*
		dbHost := os.Getenv("RMDX_INSTANCE_ADDRESS")
		dbUser := os.Getenv("RMDX_USER_NAME")
		dbPassword := os.Getenv("RMDX_PASSWORD")
		dbName := os.Getenv("RMDX_DB_NAME")
		dbPort := os.Getenv("RMDX_PORT")

		dsn := fmt.Sprintf("host=%s user=%s password=%s dbname=%s port=%s sslmode=disable", dbHost, dbUser, dbPassword, dbName, dbPort)

		var err error
		db, err = gorm.Open(postgres.Open(dsn), &gorm.Config{})
		if err != nil {
			panic(err)
		}
	*/
}

func main() {
	//db.AutoMigrate(&models.Commitment{})
	/*
		db.AutoMigrate(&models.Commitment{}, &models.Client{}, &models.Commitment{}, &models.Reminder{})
		fmt.Println("Running server...")
	*/
	lambda.Start(HandleRequest)
}

func HandleRequest(ctx context.Context, request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	switch request.HTTPMethod {
	//case "GET":
	//	return GetReminders(request)
	case "POST":
		return CreateScheduler(request)
	//case "PUT":
	//	return UpdateReminder(request)
	case "DELETE":
		return DeleteScheduler(request)
	default:
		return events.APIGatewayProxyResponse{StatusCode: 405}, nil
	}
}

func CreateScheduler(request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {

	log.Println("POST")

	sess := session.Must(session.NewSession())

	// Create a Scheduler client with additional configuration
	svc := scheduler.New(sess, aws.NewConfig().WithRegion("us-east-1"))

	var body map[string]interface{}
	err := json.Unmarshal([]byte(request.Body), &body)
	if err != nil {
		fmt.Println("Error:", err)
		return events.APIGatewayProxyResponse{StatusCode: 500, Body: "Failed to parse request body"}, err
	}

	id := body["id"].(string)
	name := body["name"].(string)
	email := body["email"].(string)
	phone := body["phone"].(string)
	message := body["message"].(string)
	reminderDay := body["reminder_day"].(string)
	reminderHour := body["reminder_hour"].(string)
	reminderMinute := body["reminder_minute"].(string)

	fmt.Println("id:", id)
	fmt.Println("name:", name)
	fmt.Println("email:", email)
	fmt.Println("phone:", phone)
	fmt.Println("message:", message)
	fmt.Println("reminder_day:", reminderDay)
	fmt.Println("reminder_hour:", reminderHour)
	fmt.Println("reminder_minute:", reminderMinute)

	sendSMS := false
	if phone != "" {
		fmt.Println("Phone variable is not null and not empty.")
		sendSMS = true
	} else {
		fmt.Println("Phone variable is null or empty.")
		// Handle the case where phone variable is null or empty
	}

	sendEmail := false
	if email != "" {
		fmt.Println("Email variable is not null and not empty.")
		sendEmail = true
	} else {
		fmt.Println("Email variable is null or empty.")
		// Handle the case where email variable is null or empty
	}

	filterPolicy := map[string][]string{
		"send_email": {fmt.Sprintf("%t", sendEmail)},
		"send_sms":   {fmt.Sprintf("%t", sendSMS)},
	}

	response, err := svc.CreateSchedule(&scheduler.CreateScheduleInput{
		FlexibleTimeWindow:         &scheduler.FlexibleTimeWindow{Mode: aws.String("OFF")},
		ScheduleExpression:         aws.String(fmt.Sprintf("cron(%s %s %s * ? *)", reminderMinute, reminderHour, reminderDay)),
		ScheduleExpressionTimezone: aws.String("America/Bogota"),
		Target: &scheduler.Target{
			Arn:     aws.String("arn:aws:sns:us-east-1:826738023599:sch-NotificationTopics"),
			Input:   aws.String(fmt.Sprintf(`{"id": "%s", "name": "%s", "email": "%s", "phone": "%s", "message": "%s", "filter_policy": %s}`, id, name, email, phone, message, toJSON(filterPolicy))),
			RoleArn: aws.String("arn:aws:iam::826738023599:role/sch-EventBridgeSchedulerAssumePolicy"),
		},
		Name: aws.String(uuid.New().String()),
	})

	if err != nil {
		fmt.Println("Error:", err)
		return events.APIGatewayProxyResponse{StatusCode: 500, Body: "Failed to create Schedule"}, err
	}

	// Extracting schedule ID from ARN
	scheduleArn := aws.StringValue(response.ScheduleArn)
	arnParts := strings.Split(scheduleArn, "/")
	scheduleID := arnParts[len(arnParts)-1]

	fmt.Println("response:", response)
	fmt.Println("schedule_arn:", scheduleArn)
	fmt.Println("schedule_id:", scheduleID)

	responseBody := map[string]interface{}{
		"schedule_arn": scheduleArn,
		"schedule_id":  scheduleID,
	}

	responseJSON, err := json.Marshal(responseBody)
	if err != nil {
		fmt.Println("Error:", err)
		return events.APIGatewayProxyResponse{StatusCode: 500, Body: "Failed to marshal response"}, err
	}

	return events.APIGatewayProxyResponse{StatusCode: 200, Body: string(responseJSON)}, nil
}

func toJSON(v interface{}) string {
	bytes, _ := json.Marshal(v)
	return string(bytes)
}

func DeleteScheduler(request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	log.Println("DELETE")
	log.Println(request.QueryStringParameters)
	log.Println(request.PathParameters)

	// Create a new AWS session
	sess := session.Must(session.NewSession())

	// Create a Scheduler client with additional configuration
	svc := scheduler.New(sess, aws.NewConfig().WithRegion("us-east-1"))

	// Get schedule_id from query string parameters
	scheduleID, ok := request.QueryStringParameters["schedule_id"]
	if !ok {
		log.Println("schedule_id not found in query string parameters")
		return events.APIGatewayProxyResponse{StatusCode: 400, Body: "schedule_id not found in query string parameters"}, nil
	}

	// Delete the schedule using the provided schedule ID
	_, err := svc.DeleteSchedule(&scheduler.DeleteScheduleInput{
		Name:        aws.String(scheduleID),
		ClientToken: aws.String(uuid.New().String()), // Generate a unique client token
	})

	if err != nil {
		log.Println("Error deleting schedule:", err)
		return events.APIGatewayProxyResponse{StatusCode: 500, Body: fmt.Sprintf(`{"error": "%s"}`, err.Error())}, nil
	}

	return events.APIGatewayProxyResponse{StatusCode: 200, Body: fmt.Sprintf(`{"message": "Schedule %s deleted successfully"}`, scheduleID)}, nil
}
