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

func TestGetCarById(t *testing.T) {

	//Setup new router
	router := SetUpRouter()
	router.GET("/cars/:id", GetCarById)

	var car BodyCar

	//Marshaling body object
	jsonValue, _ := json.Marshal(car)

	//Sending request
	request, _ := http.NewRequest("GET", "/cars/20", bytes.NewBuffer(jsonValue))

	response := httptest.NewRecorder()

	//Getting response
	router.ServeHTTP(response, request)

	fmt.Println(response.Body)

	//Asserting response code
	assert.Equal(t, http.StatusOK, response.Code)
}
