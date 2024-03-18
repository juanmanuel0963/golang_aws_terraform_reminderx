package controllers

import (
	"errors"
	"fmt"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/juanmanuel0963/golang_aws_terraform_jenkins/v2/microservices_restful_ec2/_database/initializers"
	"github.com/juanmanuel0963/golang_aws_terraform_jenkins/v2/microservices_restful_ec2/_database/models"
)

func init() {

	//Initialize DB conn
	initializers.ConnectToDB()
}

// DeleteCarByID handles DELETE requests for deleting a specific car by ID
func DeleteCarByID(c *gin.Context) {

	// Get user ID from path parameter
	carId, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Invalid your car ID",
		})
		return
	}

	// Create a channel to communicate with the goroutine
	carChannel := make(chan bool)
	errChannel := make(chan error)

	//Calling Go routine
	go deleteCarInDatabase(carId, carChannel, errChannel)

	// Wait for the user to be deleted and sent through the channel
	select {
	case deleteSuccess := <-carChannel:
		c.JSON(http.StatusNoContent, gin.H{
			"status": deleteSuccess,
		})
	case err := <-errChannel:
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": err.Error(),
		})
	}
}

func deleteCarInDatabase(carId int, carChannel chan<- bool, errChannel chan<- error) {

	defer close(carChannel)
	defer close(errChannel)

	//initializers.ConnectToDB()

	//Delete the car
	result := initializers.DB.Delete(&models.Car{}, carId)

	if result.Error != nil {
		errChannel <- errors.New(result.Error.Error())
	} else {
		// Send success
		carChannel <- true
	}

	fmt.Println("closed")
}
