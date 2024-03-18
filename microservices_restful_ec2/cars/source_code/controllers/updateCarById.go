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

func UpdateCarById(c *gin.Context) {

	// Get car ID from path parameter
	carId, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Invalid your user ID",
		})
		return
	}

	var body BodyCar

	// Bind incoming JSON to user struct
	if err := c.ShouldBindJSON(&body); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	var updateCar = models.Car{Category: body.Category, Color: body.Color, Maker: body.Maker,
		Modelo: body.Modelo, Package: body.Package, Mileage: body.Mileage, Year: body.Year, Price: body.Price}

	// Create a channel to communicate with the goroutine
	carChannel := make(chan models.Car)
	errChannel := make(chan error)

	//Calling Go routine
	go updateCarInDatabase(carId, updateCar, carChannel, errChannel)

	// Wait for the user to be created and sent through the channel
	select {
	case updatedCar := <-carChannel:
		c.JSON(http.StatusOK, gin.H{
			"status": updatedCar,
		})
	case err := <-errChannel:

		fmt.Println(err.Error())

		if err.Error() == "record not found" {
			c.JSON(http.StatusNotFound, gin.H{
				"error": err.Error(),
			})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{
				"error": err.Error(),
			})
		}
	}
}

func updateCarInDatabase(carId int, updateCar models.Car, carChannel chan<- models.Car, errChannel chan<- error) {

	defer close(carChannel)
	defer close(errChannel)

	//fmt.Println("Printing")

	//fmt.Println(updateUser)
	fmt.Println("Go Routine")

	fmt.Println("carId")
	fmt.Println(carId)

	//initializers.ConnectToDB()

	var findCar models.Car
	result := initializers.DB.First(&findCar, carId)

	fmt.Println("findCar")
	fmt.Println(findCar)

	if result.Error != nil {
		//Other error
		errChannel <- errors.New(result.Error.Error())
	} else {
		//Record found

		// Update it
		result = initializers.DB.Model(&findCar).Updates(updateCar)

		fmt.Println("updateCar")
		fmt.Println(updateCar)

		if result.Error != nil {

			//Error updating
			errChannel <- errors.New(result.Error.Error())
		} else {

			//Updated successfully

			//Finding updated record
			var findCar models.Car
			result := initializers.DB.First(&findCar, carId)

			fmt.Println("findCar")
			fmt.Println(findCar)
			fmt.Println(result.Error)

			if result.Error != nil && findCar.ID == 0 {
				//Record not found
				errChannel <- errors.New("record not found")
			} else if result.Error != nil {
				//Other error
				errChannel <- errors.New(result.Error.Error())
			} else {
				// Send the created car through the channel
				carChannel <- findCar
			}
		}

		fmt.Println("closed")
	}
}
