package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"os"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/juanmanuel0963/golang_aws_terraform_reminderx/v2/microservices_reminderx/models"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

// Add a new struct for handling login requests
type LoginRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

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
	db.AutoMigrate(&models.Commitment{}, &models.Client{}, &models.Commitment{}, &models.Reminder{})
	fmt.Println("Running server...")
	lambda.Start(HandleRequest)
}

func HandleRequest(ctx context.Context, request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	switch request.HTTPMethod {
	case "POST":
		return AuthenticateAdmin(request)
	default:
		return events.APIGatewayProxyResponse{StatusCode: 405}, nil
	}
}

// Add a new handler for user authentication
func AuthenticateAdmin(request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	log.Println("POST")

	var loginReq LoginRequest
	err := json.Unmarshal([]byte(request.Body), &loginReq)
	if err != nil {
		errorMessage := map[string]string{"error": "Invalid request body"}
		responseJSON, _ := json.Marshal(errorMessage)
		return events.APIGatewayProxyResponse{Body: string(responseJSON), StatusCode: 400}, nil
	}

	// Retrieve user from database based on email
	var user models.Admin
	result := db.Where("email = ?", loginReq.Email).First(&user)
	if result.Error != nil {
		errorMessage := map[string]string{"error": "Invalid email or password"}
		responseJSON, _ := json.Marshal(errorMessage)
		return events.APIGatewayProxyResponse{Body: string(responseJSON), StatusCode: 401}, nil
	}

	// Check if password matches
	if user.Password != loginReq.Password {
		errorMessage := map[string]string{"error": "Invalid email or password"}
		responseJSON, _ := json.Marshal(errorMessage)
		return events.APIGatewayProxyResponse{Body: string(responseJSON), StatusCode: 401}, nil
	}

	// Prepare response JSON
	response := map[string]interface{}{
		"ID": user.ID,
	}

	// Marshal response to JSON
	jsonResponse, err := json.Marshal(response)
	if err != nil {
		errorMessage := map[string]string{"error": "Failed to marshal response"}
		responseJSON, _ := json.Marshal(errorMessage)
		return events.APIGatewayProxyResponse{Body: string(responseJSON), StatusCode: 500}, nil
	}

	// Return success response with user ID
	return events.APIGatewayProxyResponse{Body: string(jsonResponse), StatusCode: 200}, nil
}
