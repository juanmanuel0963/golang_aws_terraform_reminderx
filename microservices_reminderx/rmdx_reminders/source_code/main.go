package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"os"
	"strconv"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/juanmanuel0963/golang_aws_terraform_reminderx/v2/microservices_reminderx/models"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

var db *gorm.DB

func init() {
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
}

func main() {
	//db.AutoMigrate(&models.Commitment{})
	db.AutoMigrate(&models.Commitment{}, &models.Client{}, &models.Commitment{}, &models.Reminder{})
	fmt.Println("Running server...")
	lambda.Start(HandleRequest)
}

func HandleRequest(ctx context.Context, request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	switch request.HTTPMethod {
	case "GET":
		return GetReminders(request)
	case "POST":
		return CreateReminder(request)
	case "PUT":
		return UpdateReminder(request)
	case "DELETE":
		return DeleteReminder(request)
	default:
		return events.APIGatewayProxyResponse{StatusCode: 405}, nil
	}
}

func GetReminders(request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	log.Println("GET")
	log.Println(request.QueryStringParameters)
	adminIDStr := request.QueryStringParameters["adminId"]

	var reminders []models.Reminder_Get
	query := db.Model(&models.Reminder{}).
		Select("reminders.*, clients.first_name as client_first_name, clients.sur_name as client_sur_name, admins.first_name as admin_first_name, admins.sur_name as admin_sur_name").
		Joins("INNER JOIN clients ON reminders.client_id = clients.id INNER JOIN admins ON clients.admin_id = admins.id")

	if adminIDStr != "" {
		adminID, err := strconv.Atoi(adminIDStr)
		if err != nil {
			errorMessage := map[string]string{"error": "Invalid admin ID"}
			responseJSON, _ := json.Marshal(errorMessage)
			return events.APIGatewayProxyResponse{Body: string(responseJSON), StatusCode: 400}, nil
		}
		query = query.Where("admins.id = ?", adminID)
	}

	result := query.Find(&reminders)
	if result.Error != nil {
		errorMessage := map[string]string{"error": "Failed to fetch reminders"}
		responseJSON, _ := json.Marshal(errorMessage)
		return events.APIGatewayProxyResponse{Body: string(responseJSON), StatusCode: 500}, nil
	}

	response, _ := json.Marshal(reminders)
	return events.APIGatewayProxyResponse{Body: string(response), StatusCode: 200}, nil
}

func CreateReminder(request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	log.Println("POST")

	var reminder models.Reminder
	err := json.Unmarshal([]byte(request.Body), &reminder)
	if err != nil {
		errorMessage := map[string]string{"error": fmt.Sprintf("Failed to unmarshal request body: %v", err)}
		responseJSON, _ := json.Marshal(errorMessage)
		return events.APIGatewayProxyResponse{Body: string(responseJSON), StatusCode: 400}, nil
	}

	// Create the reminder if validation passes
	db.Create(&reminder)
	response, _ := json.Marshal(reminder)
	return events.APIGatewayProxyResponse{Body: string(response), StatusCode: 201}, nil
}

func UpdateReminder(request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	log.Println("PUT")
	log.Println(request.QueryStringParameters)
	reminderID, err := strconv.Atoi(request.QueryStringParameters["id"])

	if err != nil {
		errorMessage := map[string]string{"error": "Invalid reminder ID"}
		responseJSON, _ := json.Marshal(errorMessage)
		return events.APIGatewayProxyResponse{Body: string(responseJSON), StatusCode: 400}, nil
	}

	var updatedReminder models.Reminder
	err = json.Unmarshal([]byte(request.Body), &updatedReminder)
	log.Println(updatedReminder)
	if err != nil {
		errorMessage := map[string]string{"error": fmt.Sprintf("Failed to unmarshal request body: %v", err)}
		responseJSON, _ := json.Marshal(errorMessage)
		return events.APIGatewayProxyResponse{Body: string(responseJSON), StatusCode: 400}, nil
	}

	var existingReminder models.Reminder
	result := db.First(&existingReminder, reminderID)
	if result.Error != nil {
		errorMessage := map[string]string{"error": "Reminder not found"}
		responseJSON, _ := json.Marshal(errorMessage)
		return events.APIGatewayProxyResponse{Body: string(responseJSON), StatusCode: 404}, nil
	}

	db.Model(&existingReminder).Updates(&updatedReminder)
	response, _ := json.Marshal(existingReminder)
	return events.APIGatewayProxyResponse{Body: string(response), StatusCode: 200}, nil
}

func DeleteReminder(request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	log.Println("DELETE")
	log.Println(request.QueryStringParameters)
	log.Println(request.PathParameters)

	reminderID, err := strconv.Atoi(request.QueryStringParameters["id"])
	if err != nil {
		errorMessage := map[string]string{"error": "Invalid reminder ID"}
		responseJSON, _ := json.Marshal(errorMessage)
		return events.APIGatewayProxyResponse{Body: string(responseJSON), StatusCode: 400}, nil
	}

	var reminder models.Reminder
	result := db.First(&reminder, reminderID)
	if result.Error != nil {
		errorMessage := map[string]string{"error": "Reminder not found"}
		responseJSON, _ := json.Marshal(errorMessage)
		return events.APIGatewayProxyResponse{Body: string(responseJSON), StatusCode: 404}, nil
	}

	db.Delete(&reminder)
	return events.APIGatewayProxyResponse{StatusCode: 204}, nil
}
