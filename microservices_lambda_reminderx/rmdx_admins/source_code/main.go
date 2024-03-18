package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"os"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

type Admin struct {
	gorm.Model        // Includes fields: ID, CreatedAt, UpdatedAt, DeletedAt
	FirstName  string `json:"firstName"`
	Email      string `json:"email"`
	Password   string `json:"password"`
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
	db.AutoMigrate(&Admin{})
}

func main() {
	if os.Getenv("_LAMBDA_SERVER_PORT") != "" {

		fmt.Println("Running locally...")
		http.HandleFunc("/admins", LocallyAdminsHandler)
		http.ListenAndServe(":"+os.Getenv("_LAMBDA_SERVER_PORT"), nil)

	} else {

		fmt.Println("Running server...")
		lambda.Start(HandleRequest)

	}
}

func HandleRequest(ctx context.Context, request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	switch request.HTTPMethod {
	case "GET":
		return GetAdmins(request)
	case "POST":
		return CreateAdmin(request)
	default:
		return events.APIGatewayProxyResponse{StatusCode: 405}, nil
	}
}

func GetAdmins(request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	var admins []Admin
	db.Find(&admins)
	response, _ := json.Marshal(admins)
	return events.APIGatewayProxyResponse{Body: string(response), StatusCode: 200}, nil
}

func CreateAdmin(request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	var admin Admin
	err := json.Unmarshal([]byte(request.Body), &admin)
	if err != nil {
		return events.APIGatewayProxyResponse{Body: fmt.Sprintf("Failed to unmarshal request body: %v", err), StatusCode: 400}, nil
	}
	db.Create(&admin)
	response, _ := json.Marshal(admin)
	return events.APIGatewayProxyResponse{Body: string(response), StatusCode: 201}, nil
}

func LocallyAdminsHandler(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case http.MethodGet:
		LocallyGetAdminsHandler(w, r)
	case http.MethodPost:
		LocallyCreateAdminHandler(w, r)
	default:
		w.WriteHeader(http.StatusMethodNotAllowed)
	}
}

func LocallyGetAdminsHandler(w http.ResponseWriter, r *http.Request) {
	var admins []Admin
	db.Find(&admins)
	response, _ := json.Marshal(admins)
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	w.Write(response)
}

func LocallyCreateAdminHandler(w http.ResponseWriter, r *http.Request) {
	var admin Admin
	err := json.NewDecoder(r.Body).Decode(&admin)
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		return
	}

	db.Create(&admin)
	response, _ := json.Marshal(admin)
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	w.Write(response)
}
