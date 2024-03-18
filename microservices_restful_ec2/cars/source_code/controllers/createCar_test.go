package controllers

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestCreateCar(t *testing.T) {

	//Setup new router
	router := SetUpRouter()
	router.POST("/cars", CreateCar)

	car := BodyCar{
		Category: "Sedan",
		Color:    "Black",
		Maker:    "Renault",
		Modelo:   "Logan",
		Package:  "Sedan Logan",
		Mileage:  2000,
		Year:     2020,
		Price:    5400,
	}
	//Marshaling body object
	jsonValue, _ := json.Marshal(car)

	//Sending request
	request, _ := http.NewRequest("POST", "/cars", bytes.NewBuffer(jsonValue))

	//Getting response
	response := httptest.NewRecorder()
	router.ServeHTTP(response, request)

	fmt.Println(response.Body)

	//Asserting response code
	assert.Equal(t, http.StatusCreated, response.Code)
}
