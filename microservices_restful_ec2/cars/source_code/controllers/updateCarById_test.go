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

func TestUpdateCarById(t *testing.T) {

	//Setup new router
	router := SetUpRouter()
	router.PUT("/cars/:id", UpdateCarById)

	car := BodyCar{
		Category: "Truck",
		Color:    "Red",
		Maker:    "Ford",
		Modelo:   "F100",
		Package:  "Truck F100",
		Mileage:  1500,
		Year:     2020,
		Price:    10000,
	}

	//Marshaling body object
	jsonValue, _ := json.Marshal(car)

	//Sending request
	request, _ := http.NewRequest("PUT", "/cars/20", bytes.NewBuffer(jsonValue))

	response := httptest.NewRecorder()

	//Getting response
	router.ServeHTTP(response, request)

	fmt.Println("-----")
	fmt.Println(response.Body)

	//Asserting response code
	assert.Equal(t, http.StatusOK, response.Code)
}

func TestUpdateCarById_RecordNotFound(t *testing.T) {

	//Setup new router
	router := SetUpRouter()
	router.PUT("/cars/:id", UpdateCarById)

	car := BodyCar{
		Category: "Truck",
		Color:    "Red",
		Maker:    "Ford",
		Modelo:   "F100",
		Package:  "Truck F100",
		Mileage:  1500,
		Year:     2020,
		Price:    10000,
	}

	//Marshaling body object
	jsonValue, _ := json.Marshal(car)

	//Sending request
	request, _ := http.NewRequest("PUT", "/cars/3", bytes.NewBuffer(jsonValue))

	response := httptest.NewRecorder()

	//Getting response
	router.ServeHTTP(response, request)

	fmt.Println("-----")
	fmt.Println(response.Body)

	//Asserting response code
	assert.Equal(t, http.StatusNotFound, response.Code)
}
