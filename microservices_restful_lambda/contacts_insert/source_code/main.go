package main

import (
	"context"
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"os"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	_ "github.com/lib/pq"
)

type Contact struct {
	Id        int    `json:"id"`
	CompanyId int    `json:"company_id"`
	FirstName string `json:"first_name"`
	LastName  string `json:"last_name"`
	Email     string `json:"email"`
	CreatedAt string `json:"created_at"`
}

type ResponseBody struct {
	StatusCode    int     `json:"status_code"`
	StatusMessage string  `json:"status_message"`
	StatusError   string  `json:"status_error"`
	Contact       Contact `json:"contact"`
}

func main() {
	lambda.Start(FunctionHandler)
}

func FunctionHandler(ctx context.Context, request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {

	//---------------------------------------------------------------------------------
	//----------------------------Unmarshalling Request--------------------------------
	//
	log.Println("Step - Getting request: ", request)
	log.Println("Step - Getting request: ", request.Body)
	log.Println("Step - Getting request: ", []byte(request.Body))
	//
	log.Println("Step - Unmarshalling request body")
	var requestContact Contact
	errUnmarshalling := json.Unmarshal([]byte(request.Body), &requestContact)
	//
	//If an error occurs unmarshalling the request body
	if errUnmarshalling != nil {
		messageStatus := "ERROR_UNMARSHALLING_REQUEST_BODY"
		messageError := errUnmarshalling.Error()
		//Logs the error into CloudWatch
		log.Println("Step - Unmarshalling request body - " + messageStatus + " - " + messageError)
		//Creates the response for the API Gateway
		responseForAPIGateway := CreateErrorResponseForAPIGateway(messageStatus, messageError)
		//Returns the response
		return responseForAPIGateway, nil
	}
	//
	log.Printf("Step - Unmarshalling request body - Hello there Id: %v. FirstName: %v. LastName: %v. Email: %v. CompanyId: %v.", requestContact.Id, requestContact.FirstName, requestContact.LastName, requestContact.Email, requestContact.CompanyId)
	//
	//---------------------------------------------------------------------------------
	//----------------------------DB Connection Test-----------------------------------
	//
	log.Println("Step - DB connection string forming")
	//
	dbUser := os.Getenv("dbUser")
	dbPassword := os.Getenv("dbPassword")
	InstanceConnectionName := os.Getenv("InstanceConnectionName")
	dbName := os.Getenv("dbName")
	dsn := fmt.Sprintf("postgres://%s:%s@%s/%s?sslmode=disable", dbUser, dbPassword, InstanceConnectionName, dbName)
	//
	log.Println("Step - DB connection string: ", dsn)
	//
	log.Println("Step - Openning DB connection")
	//
	var db *sql.DB
	db, errOpenConnection := sql.Open("postgres", dsn)
	//
	//If an error occurs pinging the db
	if errOpenConnection != nil {
		messageStatus := "ERROR_OPENNING_DB_CONNECTION"
		messageError := errOpenConnection.Error()
		//Logs the error into CloudWatch
		log.Println("Step - Openning DB connection - " + messageStatus + " - " + messageError)
		//Creates the response for the API Gateway
		responseForAPIGateway := CreateErrorResponseForAPIGateway(messageStatus, messageError)
		//Returns the response
		return responseForAPIGateway, nil
	}
	//
	log.Println("Step - Ping DB")
	//
	errPingDB := db.Ping()
	//If an error occurs pinging the db
	if errPingDB != nil {
		messageStatus := "ERROR_PINGING_DB"
		messageError := errPingDB.Error()
		//Logs the error into CloudWatch
		log.Println("Step - Ping DB - " + messageStatus + " - " + messageError)
		//Creates the response for the API Gateway
		responseForAPIGateway := CreateErrorResponseForAPIGateway(messageStatus, messageError)
		//Returns the response
		return responseForAPIGateway, nil
	}
	defer db.Close()
	//
	//---------------------------------------------------------------------------------
	//----------------------------Query Execution--------------------------------------
	//

	log.Println("Step - Query execution")

	//addedContactId := 0
	var responseContact Contact
	errQuery := db.QueryRow("SELECT id FROM contacts_insert($1, $2, $3, $4)", requestContact.CompanyId, requestContact.FirstName, requestContact.LastName, requestContact.Email).Scan(&responseContact.Id)
	//_, errQuery := db.Exec("SELECT id FROM contacts_insert($1, $2, $3, $4)", 1, "Juan", "Diaz", "juan@anyemail.com")

	//If an error occurs executing the query
	if errQuery != nil {
		messageStatus := "ERROR_EXECUTING_QUERY"
		messageError := errQuery.Error()
		//Logs the error into CloudWatch
		log.Println("Step - Query execution - " + messageStatus + " - " + messageError)
		//Creates the response for the API Gateway
		responseForAPIGateway := CreateErrorResponseForAPIGateway(messageStatus, messageError)
		//Returns the response
		return responseForAPIGateway, nil
	}

	//-----Fill in the body: contact & message
	responseMessageForClient := ""
	responseStatusCodeForClient := 0
	//
	switch { // missing expression means "true"
	case responseContact.Id > 0:
		responseMessageForClient = "RECORD_OK"
		responseStatusCodeForClient = 200
	case responseContact.Id == 0:
		responseMessageForClient = "RECORD_NOT_FOUND"
		responseStatusCodeForClient = 400
	default:
		responseMessageForClient = "RECORD_UNKNOWN_ERROR"
		responseStatusCodeForClient = 500
	}

	log.Println("Step - Scanning rows verification")

	log.Println("Step - Scanning rows verification - contact.Id: ", responseContact.Id)
	log.Println("Step - Scanning rows verification - responseMessageForClient: ", responseMessageForClient)

	//---------------------------------------------------------------------------------
	//----------------------------Response Marshalling---------------------------------
	//
	//-----Fill in the body: message
	//
	log.Println("Step - Structuring Response Body")
	log.Println("Step - Structuring Response Body - StatusMessage: ", responseMessageForClient)
	log.Println("Step - Structuring Response Body - StatusCode: ", responseStatusCodeForClient)
	log.Println("Step - Structuring Response Body - Contact: ", responseContact)

	//-----Creates the response body for the client: message + status code + contact id-----
	responseForClient := ResponseBody{
		StatusMessage: responseMessageForClient,
		StatusCode:    responseStatusCodeForClient,
		Contact:       responseContact,
	}
	log.Println("Step - Structured Response Body ", responseForClient)
	//
	//-----Marshalls the response body-----
	responseForClientBytes, errMarshalling := json.Marshal((responseForClient))
	log.Println("Step - Marshalling Response Body", responseForClientBytes)
	//
	//If an error occurs marshalling the response body
	if errMarshalling != nil {
		messageStatus := "ERROR_MARSHALLING_RESPONSE_BODY"
		messageError := errMarshalling.Error()
		//Logs the error into CloudWatch
		log.Println("Step - Marshalling Response Body - " + messageStatus + " - " + messageError)
		//Creates the response for the API Gateway
		responseForAPIGateway := CreateErrorResponseForAPIGateway(messageStatus, messageError)
		//Returns the response
		return responseForAPIGateway, nil
	}
	//
	//-----Creates the response body for the API Gateway. It wrapes the response for the client-----
	responseForAPIGateway := events.APIGatewayProxyResponse{
		StatusCode: 200,
		Body:       string(responseForClientBytes),
	}
	//
	log.Println("Step - Final Response ", responseForAPIGateway)
	//
	//-----Returns the response object-----
	return responseForAPIGateway, nil
}

func CreateErrorResponseForAPIGateway(statusMessage string, statusError string) events.APIGatewayProxyResponse {

	//-----Creates the response body for the Client: message + error + status code-----
	responseForClient := ResponseBody{
		StatusMessage: statusMessage,
		StatusError:   statusError,
		StatusCode:    500,
	}
	//
	//-----Marshalls the response body-----
	responseForClientBytes, _ := json.Marshal((responseForClient))
	//
	//-----Creates the response body for the API Gateway. It wrapes the response for the client-----
	responseForAPIGateway := events.APIGatewayProxyResponse{
		StatusCode: 200,
		Body:       string(responseForClientBytes),
	}

	return responseForAPIGateway
}
