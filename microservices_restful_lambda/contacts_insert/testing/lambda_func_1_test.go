package main

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"
	"testing"
	"time"

	"github.com/aws/aws-sdk-go/aws/credentials"
	v4 "github.com/aws/aws-sdk-go/aws/signer/v4"
)

// CloudWatch Logs
// https://us-east-1.console.aws.amazon.com/lambda/home?region=us-east-1#/functions/contacts_insert_romantic_shark?tab=monitoring
// Test with AWS signature
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

func Test_with_aws_signature(t *testing.T) {

	//-----------------------------------------------------------
	fmt.Println("Step - Creating credentials and signer instances")
	//-----------------------------------------------------------
	//
	creds := credentials.NewStaticCredentials(ACCESS_KEY, SECRET_KEY, "")
	signer := v4.NewSigner(creds)

	//-----------------------------------------------------------
	fmt.Println("Step - Creating a contact instance")
	//-----------------------------------------------------------
	//
	contact := Contact{
		CompanyId: 1,
		FirstName: "LeBron",
		LastName:  "James",
		Email:     "lebron@anyemail.com",
	}
	//-----------------------------------------------------------
	fmt.Println("Step - Marshalling contact object into JSON format")
	//-----------------------------------------------------------
	//
	jsonBody, errMarshalling := json.Marshal(contact)
	if errMarshalling != nil {
		t.Errorf("Step - Marshalling contact - Error, got %v", errMarshalling)
	}
	fmt.Println(string(jsonBody))
	//
	//-----------------------------------------------------------
	fmt.Println("Step - Building a new http request")
	//-----------------------------------------------------------
	//
	request, body := buildHttpRequest("execute-api", "us-east-1", string(jsonBody))
	fmt.Println(body)
	//
	//-----------------------------------------------------------
	fmt.Println("Step - Signing the request")
	//-----------------------------------------------------------
	//
	signer.Sign(request, body, "execute-api", "us-east-1", time.Now())
	//
	//-----------------------------------------------------------
	fmt.Println("Step - Executing the http request")
	//-----------------------------------------------------------
	//
	response, errRequest := http.DefaultClient.Do(request)
	if errRequest != nil {
		t.Errorf("Step - Executing the http request - Error, got %v", errRequest)
	}
	//-----Close the response object-----
	defer response.Body.Close()
	//
	//-----------------------------------------------------------
	fmt.Println("Step - Validating if the http response is a code 200")
	//-----------------------------------------------------------
	//
	if expect, got := http.StatusOK, response.StatusCode; expect != got {
		t.Errorf("Step - Validating if the http response is a code 200. Expect %v, got %v", expect, got)
	}
	//
	//-----------------------------------------------------------
	fmt.Println("Step - Decoding the http response body")
	//-----------------------------------------------------------
	//
	var responseBody ResponseBody
	errDecoding := json.NewDecoder(response.Body).Decode(&responseBody)
	if errDecoding != nil {
		t.Errorf("Step - Decoding the http response body - Error, got %v", errDecoding)
	}

	fmt.Println("Step - Decoding the http response body - Message:")
	fmt.Println(responseBody.StatusMessage)

	fmt.Println("Step - Decoding the http response body - Contact:")
	fmt.Println(responseBody.Contact)

	//-----------------------------------------------------------
	fmt.Println("Step - Validating if the response Contact.Id > 0")
	//-----------------------------------------------------------
	//
	if expect, got := true, responseBody.Contact.Id > 0; expect != got {
		t.Errorf("Step - Validating if the Contact.Id > 0, expect %v, got %v", expect, got)
	}
}

func buildHttpRequest(serviceName, region string, body string) (*http.Request, io.ReadSeeker) {

	endpoint := SERVICE_URL
	request, _ := http.NewRequest("POST", endpoint, strings.NewReader(body))
	request.Header.Set("Content-Type", "application/json")
	return request, strings.NewReader(body)
}
