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
		return GetCommitments(request)
	case "POST":
		return CreateCommitment(request)
	case "PUT":
		return UpdateCommitment(request)
	case "DELETE":
		return DeleteCommitment(request)
	default:
		return events.APIGatewayProxyResponse{StatusCode: 405}, nil
	}
}

func GetCommitments(request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	log.Println("GET")
	log.Println(request.QueryStringParameters)
	adminIDStr := request.QueryStringParameters["adminId"]
	commitmentIDStr := request.QueryStringParameters["commitmentId"]

	var commitments []models.Commitment_Get
	query := db.Model(&models.Commitment{}).
		Select("commitments.*, clients.first_name as client_first_name, clients.sur_name as client_sur_name, admins.first_name as admin_first_name, admins.sur_name as admin_sur_name").
		Joins("INNER JOIN clients ON commitments.client_id = clients.id INNER JOIN admins ON clients.admin_id = admins.id")

	if adminIDStr != "" {
		adminID, err := strconv.Atoi(adminIDStr)
		if err != nil {
			errorMessage := map[string]string{"error": "Invalid admin ID"}
			responseJSON, _ := json.Marshal(errorMessage)
			return events.APIGatewayProxyResponse{Body: string(responseJSON), StatusCode: 400}, nil
		}
		query = query.Where("admins.id = ?", adminID)
	}

	if commitmentIDStr != "" {
		commitmentID, err := strconv.Atoi(commitmentIDStr)
		if err != nil {
			errorMessage := map[string]string{"error": "Invalid commitment ID"}
			responseJSON, _ := json.Marshal(errorMessage)
			return events.APIGatewayProxyResponse{Body: string(responseJSON), StatusCode: 400}, nil
		}
		query = query.Where("commitments.id = ?", commitmentID)
	}

	result := query.Find(&commitments)
	if result.Error != nil {
		errorMessage := map[string]string{"error": "Failed to fetch commitments"}
		responseJSON, _ := json.Marshal(errorMessage)
		return events.APIGatewayProxyResponse{Body: string(responseJSON), StatusCode: 500}, nil
	}

	response, _ := json.Marshal(commitments)
	return events.APIGatewayProxyResponse{Body: string(response), StatusCode: 200}, nil
}

/*
	func GetCommitments(request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
		log.Println("GET")
		log.Println(request.QueryStringParameters)
		adminIDStr := request.QueryStringParameters["adminId"]

		var commitments []models.Commitment_Get
		query := db.Model(&models.Commitment{}).
			Select("commitments.*, clients.first_name as client_first_name, clients.sur_name as client_sur_name, admins.first_name as admin_first_name, admins.sur_name as admin_sur_name").
			Joins("INNER JOIN clients ON commitments.client_id = clients.id INNER JOIN admins ON clients.admin_id = admins.id")

		if adminIDStr != "" {
			adminID, err := strconv.Atoi(adminIDStr)
			if err != nil {
				errorMessage := map[string]string{"error": "Invalid admin ID"}
				responseJSON, _ := json.Marshal(errorMessage)
				return events.APIGatewayProxyResponse{Body: string(responseJSON), StatusCode: 400}, nil
			}
			query = query.Where("admins.id = ?", adminID)
		}

		result := query.Find(&commitments)
		if result.Error != nil {
			errorMessage := map[string]string{"error": "Failed to fetch commitments"}
			responseJSON, _ := json.Marshal(errorMessage)
			return events.APIGatewayProxyResponse{Body: string(responseJSON), StatusCode: 500}, nil
		}

		response, _ := json.Marshal(commitments)
		return events.APIGatewayProxyResponse{Body: string(response), StatusCode: 200}, nil
	}
*/
func CreateCommitment(request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	log.Println("POST")

	var commitment models.Commitment
	err := json.Unmarshal([]byte(request.Body), &commitment)
	if err != nil {
		errorMessage := map[string]string{"error": fmt.Sprintf("Failed to unmarshal request body: %v", err)}
		responseJSON, _ := json.Marshal(errorMessage)
		return events.APIGatewayProxyResponse{Body: string(responseJSON), StatusCode: 400}, nil
	}

	// Create the commitment if validation passes
	db.Create(&commitment)
	response, _ := json.Marshal(commitment)
	return events.APIGatewayProxyResponse{Body: string(response), StatusCode: 201}, nil
}

func UpdateCommitment(request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	log.Println("PUT")
	log.Println(request.QueryStringParameters)
	commitmentID, err := strconv.Atoi(request.QueryStringParameters["id"])

	if err != nil {
		errorMessage := map[string]string{"error": "Invalid commitment ID"}
		responseJSON, _ := json.Marshal(errorMessage)
		return events.APIGatewayProxyResponse{Body: string(responseJSON), StatusCode: 400}, nil
	}

	var updatedCommitment models.Commitment
	err = json.Unmarshal([]byte(request.Body), &updatedCommitment)
	log.Println(updatedCommitment)
	if err != nil {
		errorMessage := map[string]string{"error": fmt.Sprintf("Failed to unmarshal request body: %v", err)}
		responseJSON, _ := json.Marshal(errorMessage)
		return events.APIGatewayProxyResponse{Body: string(responseJSON), StatusCode: 400}, nil
	}

	var existingCommitment models.Commitment
	result := db.First(&existingCommitment, commitmentID)
	if result.Error != nil {
		errorMessage := map[string]string{"error": "Commitment not found"}
		responseJSON, _ := json.Marshal(errorMessage)
		return events.APIGatewayProxyResponse{Body: string(responseJSON), StatusCode: 404}, nil
	}

	db.Model(&existingCommitment).Updates(&updatedCommitment)
	response, _ := json.Marshal(existingCommitment)
	return events.APIGatewayProxyResponse{Body: string(response), StatusCode: 200}, nil
}

func DeleteCommitment(request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	log.Println("DELETE")
	log.Println(request.QueryStringParameters)
	log.Println(request.PathParameters)

	commitmentID, err := strconv.Atoi(request.QueryStringParameters["id"])
	if err != nil {
		errorMessage := map[string]string{"error": "Invalid commitment ID"}
		responseJSON, _ := json.Marshal(errorMessage)
		return events.APIGatewayProxyResponse{Body: string(responseJSON), StatusCode: 400}, nil
	}

	var commitment models.Commitment
	result := db.First(&commitment, commitmentID)
	if result.Error != nil {
		errorMessage := map[string]string{"error": "Commitment not found"}
		responseJSON, _ := json.Marshal(errorMessage)
		return events.APIGatewayProxyResponse{Body: string(responseJSON), StatusCode: 404}, nil
	}

	db.Delete(&commitment)
	return events.APIGatewayProxyResponse{StatusCode: 204}, nil
}
