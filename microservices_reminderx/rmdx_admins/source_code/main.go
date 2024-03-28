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
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

type Admin struct {
	gorm.Model           // Includes fields: ID, CreatedAt, UpdatedAt, DeletedAt
	FirstName     string `json:"firstName"`
	SurName       string `json:"surName"`
	CountryCode   string `json:"countryCode"`
	PhoneNumber   string `json:"phoneNumber"` // Updated field name
	Email         string `json:"email"`
	Password      string `json:"password"`
	IsSuperAdmin  bool   `json:"isSuperAdmin"`
	IsAdmin       bool   `json:"isAdmin"`
	ParentAdminID uint   `json:"parentAdminID"`
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
	db.AutoMigrate(&Admin{})
	fmt.Println("Running server...")
	lambda.Start(HandleRequest)
}

func HandleRequest(ctx context.Context, request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	switch request.HTTPMethod {
	case "GET":
		return GetAdmins(request)
	case "POST":
		return CreateAdmin(request)
	case "PUT":
		return UpdateAdmin(request)
	case "DELETE":
		return DeleteAdmin(request)
	default:
		return events.APIGatewayProxyResponse{StatusCode: 405}, nil
	}
}

func GetAdmins(request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	log.Println("GET")
	log.Println(request.QueryStringParameters)
	adminIDStr := request.QueryStringParameters["id"]

	if adminIDStr != "" {
		adminID, err := strconv.Atoi(adminIDStr)
		if err != nil {
			return events.APIGatewayProxyResponse{Body: "Invalid admin ID", StatusCode: 400}, nil
		}

		var admin Admin
		result := db.First(&admin, adminID)
		if result.Error != nil {
			return events.APIGatewayProxyResponse{Body: "Admin not found", StatusCode: 404}, nil
		}

		response, _ := json.Marshal(admin)
		return events.APIGatewayProxyResponse{Body: string(response), StatusCode: 200}, nil
	}

	var admins []Admin
	db.Find(&admins)
	response, _ := json.Marshal(admins)
	return events.APIGatewayProxyResponse{Body: string(response), StatusCode: 200}, nil
}

/*
	func CreateAdmin(request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
		log.Println("POST")
		var admin Admin
		err := json.Unmarshal([]byte(request.Body), &admin)
		if err != nil {
			return events.APIGatewayProxyResponse{Body: fmt.Sprintf("Failed to unmarshal request body: %v", err), StatusCode: 400}, nil
		}
		db.Create(&admin)
		response, _ := json.Marshal(admin)
		return events.APIGatewayProxyResponse{Body: string(response), StatusCode: 201}, nil
	}
*/

func CreateAdmin(request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	log.Println("POST")

	var admin Admin
	err := json.Unmarshal([]byte(request.Body), &admin)
	if err != nil {
		return events.APIGatewayProxyResponse{Body: fmt.Sprintf("Failed to unmarshal request body: %v", err), StatusCode: 400}, nil
	}

	// Check if an admin with the provided email exists
	var countByEmail int64
	db.Model(&Admin{}).Where("email = ?", admin.Email).Count(&countByEmail)
	emailExists := countByEmail > 0

	// Check if an admin with the provided countryCode and phoneNumber exists
	var countByPhone int64
	db.Model(&Admin{}).Where("country_code = ? AND phone_number = ?", admin.CountryCode, admin.PhoneNumber).Count(&countByPhone)
	phoneExists := countByPhone > 0

	if emailExists {
		errorMessage := map[string]string{"error": "An admin with this email already exists"}
		responseJSON, _ := json.Marshal(errorMessage)
		return events.APIGatewayProxyResponse{Body: string(responseJSON), StatusCode: 400}, nil
	}
	if phoneExists {
		errorMessage := map[string]string{"error": "An admin with this phone number already exists"}
		responseJSON, _ := json.Marshal(errorMessage)
		return events.APIGatewayProxyResponse{Body: string(responseJSON), StatusCode: 400}, nil
	}

	// Create the admin if validation passes
	db.Create(&admin)
	response, _ := json.Marshal(admin)
	return events.APIGatewayProxyResponse{Body: string(response), StatusCode: 201}, nil
}

func UpdateAdmin(request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	log.Println("PUT")
	log.Println(request.QueryStringParameters)
	adminID, err := strconv.Atoi(request.QueryStringParameters["id"])

	if err != nil {
		return events.APIGatewayProxyResponse{Body: "Invalid admin ID", StatusCode: 400}, nil
	}

	var updatedAdmin Admin
	err = json.Unmarshal([]byte(request.Body), &updatedAdmin)
	log.Println(updatedAdmin)
	if err != nil {
		return events.APIGatewayProxyResponse{Body: fmt.Sprintf("Failed to unmarshal request body: %v", err), StatusCode: 400}, nil
	}

	var existingAdmin Admin
	result := db.First(&existingAdmin, adminID)
	if result.Error != nil {
		return events.APIGatewayProxyResponse{Body: "Admin not found", StatusCode: 404}, nil
	}

	db.Model(&existingAdmin).Updates(&updatedAdmin)
	response, _ := json.Marshal(existingAdmin)
	return events.APIGatewayProxyResponse{Body: string(response), StatusCode: 200}, nil
}

func DeleteAdmin(request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	log.Println("DELETE")
	log.Println(request.QueryStringParameters)
	log.Println(request.PathParameters)

	adminID, err := strconv.Atoi(request.QueryStringParameters["id"])
	if err != nil {
		return events.APIGatewayProxyResponse{Body: "Invalid admin ID", StatusCode: 400}, nil
	}

	var admin Admin
	result := db.First(&admin, adminID)
	if result.Error != nil {
		return events.APIGatewayProxyResponse{Body: "Admin not found", StatusCode: 404}, nil
	}

	db.Delete(&admin)
	return events.APIGatewayProxyResponse{StatusCode: 204}, nil
}
