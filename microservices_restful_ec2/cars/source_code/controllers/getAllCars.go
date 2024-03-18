package controllers

import (
	"errors"
	"fmt"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/juanmanuel0963/golang_aws_terraform_jenkins/v2/microservices_restful_ec2/_database/initializers"
	"github.com/juanmanuel0963/golang_aws_terraform_jenkins/v2/microservices_restful_ec2/_database/models"
)

func init() {

	//Initialize DB conn
	initializers.ConnectToDB()
}

// GetAllCars retrieves all cars
func GetAllCars(c *gin.Context) {

	// Create a channel to communicate with the goroutine
	carsChannel := make(chan []models.Car)
	errChannel := make(chan error)

	//Calling Go routine
	go getAllCarsFromDatabase(carsChannel, errChannel)

	// Wait for the user to be created and sent through the channel
	select {
	case theCars := <-carsChannel:
		c.JSON(http.StatusOK, gin.H{
			"cars": theCars,
		})
	case err := <-errChannel:
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": err.Error(),
		})
	}
}

func getAllCarsFromDatabase(carsChannel chan<- []models.Car, errChannel chan<- error) {

	defer close(carsChannel)
	defer close(errChannel)

	//initializers.ConnectToDB()

	// Get the cars list
	var cars []models.Car
	result := initializers.DB.Find(&cars)

	fmt.Println(cars)

	if result.Error != nil {
		errChannel <- errors.New(result.Error.Error())
	} else if len(cars) == 0 {
		errChannel <- errors.New("failed to get all cars")
	} else {
		// Send the created user through the channel
		carsChannel <- cars
	}

	fmt.Println("closed")
}
