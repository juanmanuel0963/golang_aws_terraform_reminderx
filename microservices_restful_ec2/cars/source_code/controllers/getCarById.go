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

func GetCarById(c *gin.Context) {
	// Get car ID from path parameter
	carId, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Invalid user ID",
		})
		return
	}

	// Create a channel to communicate with the goroutine
	carChannel := make(chan models.Car)
	errChannel := make(chan error)

	//Calling Go routine
	go getCarFromDatabase(carId, carChannel, errChannel)

	// Wait for the car to be created and sent through the channel
	select {
	case getCar := <-carChannel:
		c.JSON(http.StatusOK, gin.H{
			"car": getCar,
		})
	case err := <-errChannel:
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": err.Error(),
		})
	}
}

func getCarFromDatabase(carId int, carChannel chan<- models.Car, errChannel chan<- error) {

	defer close(carChannel)
	defer close(errChannel)

	fmt.Println("Go Routine")

	fmt.Println("carId")
	fmt.Println(carId)

	//initializers.ConnectToDB()

	var findCar models.Car
	result := initializers.DB.First(&findCar, carId)

	fmt.Println("findCar")
	fmt.Println(findCar)
	fmt.Println(result.Error)

	if result.Error != nil {
		errChannel <- errors.New(result.Error.Error())
	} else if findCar.ID == 0 {
		errChannel <- errors.New("failed to get car")
	} else {
		// Send the created car through the channel
		carChannel <- findCar
	}

	fmt.Println("closed")
}
