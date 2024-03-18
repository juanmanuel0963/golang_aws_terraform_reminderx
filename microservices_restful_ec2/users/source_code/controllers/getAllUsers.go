package controllers

import (
	"errors"
	"fmt"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/juanmanuel0963/golang_aws_terraform_jenkins/v2/microservices_restful_ec2/_database/initializers"
	"github.com/juanmanuel0963/golang_aws_terraform_jenkins/v2/microservices_restful_ec2/_database/models"
)

// GetAllUsers retrieves all users
func GetAllUsers(c *gin.Context) {

	// Create a channel to communicate with the goroutine
	usersChannel := make(chan []models.User)
	errChannel := make(chan error)

	//Calling Go routine
	go getAllUserFromDatabase(usersChannel, errChannel)

	// Wait for the user to be created and sent through the channel
	select {
	case theUsers := <-usersChannel:
		c.JSON(http.StatusOK, gin.H{
			"users": theUsers,
		})
	case err := <-errChannel:
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": err.Error(),
		})
	}
}

func getAllUserFromDatabase(usersChannel chan<- []models.User, errChannel chan<- error) {

	defer close(usersChannel)
	defer close(errChannel)

	// Get the users list
	var users []models.User
	result := initializers.DB.Find(&users)

	fmt.Println(users)

	if result.Error != nil {
		errChannel <- errors.New(result.Error.Error())
	} else if len(users) == 0 {
		errChannel <- errors.New("failed to get all users users")
	} else {
		// Send the created user through the channel
		usersChannel <- users
	}

	fmt.Println("closed")
}

/*
func getAllUserFromDatabase(usersChannel chan<- []BodyUser, errChannel chan<- error) {

	// Simulate a database select by sleeping
	time.Sleep(1 * time.Second)

	// Simulate a database query
	users := []BodyUser{
		{Id: "1", Name: "John Doe", Age: 20},
		{Id: "2", Name: "Jane Doe", Age: 30},
		{Id: "3", Name: "Bob Smith", Age: 40},
	}

	fmt.Println(users)

	// Return an error if the user ID is empty
	if len(users) == 0 {
		errChannel <- errors.New("failed to find users")
	} else {
		// Send the found user through the channel
		usersChannel <- users
	}

	close(usersChannel)
	close(errChannel)
	fmt.Println("closed")
}
*/
