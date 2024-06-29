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
	//db.AutoMigrate(&models.Admin{})
	db.AutoMigrate(&models.Commitment{}, &models.Client{}, &models.Commitment{}, &models.Reminder{})
	fmt.Println("Running server...")
	lambda.Start(HandleRequest)
}

func HandleRequest(ctx context.Context, request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	switch request.HTTPMethod {
	case "GET":
		return GetClients(request)
	case "POST":
		return CreateClient(request)
	case "PUT":
		return UpdateClient(request)
	case "DELETE":
		return DeleteClient(request)
	default:
		return events.APIGatewayProxyResponse{StatusCode: 405}, nil
	}
}

func GetClients(request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	log.Println("GET")
	log.Println(request.QueryStringParameters)

	adminIDStr := request.QueryStringParameters["adminId"]
	clientIDStr := request.QueryStringParameters["clientId"]

	var clients []models.Client

	query := db.Model(&models.Client{}).
		Select("clients.*, admins.first_name as admin_first_name, admins.sur_name as admin_sur_name").
		Joins("INNER JOIN admins ON clients.admin_id = admins.id")

	if adminIDStr != "" {
		adminID, err := strconv.Atoi(adminIDStr)
		if err != nil {
			errorMessage := map[string]string{"error": "Invalid admin ID"}
			responseJSON, _ := json.Marshal(errorMessage)
			return events.APIGatewayProxyResponse{Body: string(responseJSON), StatusCode: 400}, nil
		}
		query = query.Where("admins.id = ?", adminID)
	}

	if clientIDStr != "" {
		clientID, err := strconv.Atoi(clientIDStr)
		if err != nil {
			errorMessage := map[string]string{"error": "Invalid client ID"}
			responseJSON, _ := json.Marshal(errorMessage)
			return events.APIGatewayProxyResponse{Body: string(responseJSON), StatusCode: 400}, nil
		}
		query = query.Where("clients.id = ?", clientID)
	}

	result := query.Find(&clients)
	if result.Error != nil {
		errorMessage := map[string]string{"error": "Failed to fetch clients"}
		responseJSON, _ := json.Marshal(errorMessage)
		return events.APIGatewayProxyResponse{Body: string(responseJSON), StatusCode: 500}, nil
	}

	response, _ := json.Marshal(clients)
	return events.APIGatewayProxyResponse{Body: string(response), StatusCode: 200}, nil
}

func CreateClient(request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	log.Println("POST")

	var client models.Client
	err := json.Unmarshal([]byte(request.Body), &client)
	if err != nil {
		errorMessage := map[string]string{"error": fmt.Sprintf("Failed to unmarshal request body: %v", err)}
		responseJSON, _ := json.Marshal(errorMessage)
		return events.APIGatewayProxyResponse{Body: string(responseJSON), StatusCode: 400}, nil
	}

	// Check if adminID is present in the request body
	if client.AdminID == 0 {
		errorMessage := map[string]string{"error": "adminId is required"}
		responseJSON, _ := json.Marshal(errorMessage)
		return events.APIGatewayProxyResponse{Body: string(responseJSON), StatusCode: 400}, nil
	}

	// Check if AdminID exists in the database
	var admin models.Admin
	result := db.First(&admin, client.AdminID)
	if result.Error != nil {
		errorMessage := map[string]string{"error": "adminId does not exist"}
		responseJSON, _ := json.Marshal(errorMessage)
		return events.APIGatewayProxyResponse{Body: string(responseJSON), StatusCode: 400}, nil
	}

	// Check if an client with the provided email exists
	var countByEmail int64
	db.Model(&models.Client{}).Where("email = ?", client.Email).Count(&countByEmail)
	emailExists := countByEmail > 0

	// Check if an client with the provided countryCode and phoneNumber exists
	var countByPhone int64
	db.Model(&models.Client{}).Where("country_code = ? AND phone_number = ?", client.CountryCode, client.PhoneNumber).Count(&countByPhone)
	phoneExists := countByPhone > 0

	if emailExists {
		errorMessage := map[string]string{"error": "A client with this email already exists"}
		responseJSON, _ := json.Marshal(errorMessage)
		return events.APIGatewayProxyResponse{Body: string(responseJSON), StatusCode: 400}, nil
	}
	if phoneExists {
		errorMessage := map[string]string{"error": "A client with this phone number already exists"}
		responseJSON, _ := json.Marshal(errorMessage)
		return events.APIGatewayProxyResponse{Body: string(responseJSON), StatusCode: 400}, nil
	}

	// Create the client if validation passes
	db.Create(&client)
	response, _ := json.Marshal(client)
	return events.APIGatewayProxyResponse{Body: string(response), StatusCode: 201}, nil
}

func UpdateClient(request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	log.Println("PUT")
	log.Println(request.QueryStringParameters)
	clientID, err := strconv.Atoi(request.QueryStringParameters["id"])

	if err != nil {
		errorMessage := map[string]string{"error": "Invalid Client ID"}
		responseJSON, _ := json.Marshal(errorMessage)
		return events.APIGatewayProxyResponse{Body: string(responseJSON), StatusCode: 400}, nil
	}

	var updatedClient models.Client
	err = json.Unmarshal([]byte(request.Body), &updatedClient)
	log.Println(updatedClient)
	if err != nil {
		errorMessage := map[string]string{"error": fmt.Sprintf("Failed to unmarshal request body: %v", err)}
		responseJSON, _ := json.Marshal(errorMessage)
		return events.APIGatewayProxyResponse{Body: string(responseJSON), StatusCode: 400}, nil
	}

	var existingClient models.Client
	result := db.First(&existingClient, clientID)
	if result.Error != nil {
		errorMessage := map[string]string{"error": "Client not found"}
		responseJSON, _ := json.Marshal(errorMessage)
		return events.APIGatewayProxyResponse{Body: string(responseJSON), StatusCode: 404}, nil
	}

	db.Model(&existingClient).Updates(&updatedClient)
	response, _ := json.Marshal(existingClient)
	return events.APIGatewayProxyResponse{Body: string(response), StatusCode: 200}, nil
}

func DeleteClient(request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	log.Println("DELETE")
	log.Println(request.QueryStringParameters)
	log.Println(request.PathParameters)

	clientID, err := strconv.Atoi(request.QueryStringParameters["id"])
	if err != nil {
		errorMessage := map[string]string{"error": "Invalid Client ID"}
		responseJSON, _ := json.Marshal(errorMessage)
		return events.APIGatewayProxyResponse{Body: string(responseJSON), StatusCode: 400}, nil
	}

	var client models.Client
	result := db.First(&client, clientID)
	if result.Error != nil {
		errorMessage := map[string]string{"error": "Client not found"}
		responseJSON, _ := json.Marshal(errorMessage)
		return events.APIGatewayProxyResponse{Body: string(responseJSON), StatusCode: 404}, nil
	}

	db.Delete(&client)
	return events.APIGatewayProxyResponse{StatusCode: 204}, nil
}
