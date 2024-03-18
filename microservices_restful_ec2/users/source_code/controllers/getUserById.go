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

func GetUserById(c *gin.Context) {
	// Get user ID from path parameter
	userId, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Invalid user ID",
		})
		return
	}

	// Create a channel to communicate with the goroutine
	userChannel := make(chan models.User)
	errChannel := make(chan error)

	//Calling Go routine
	go getUserFromDatabase(userId, userChannel, errChannel)

	// Wait for the user to be created and sent through the channel
	select {
	case getUser := <-userChannel:
		c.JSON(http.StatusOK, gin.H{
			"user": getUser,
		})
	case err := <-errChannel:
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": err.Error(),
		})
	}
}

func getUserFromDatabase(userId int, userChannel chan<- models.User, errChannel chan<- error) {

	defer close(userChannel)
	defer close(errChannel)

	fmt.Println("Go Routine")

	fmt.Println("userId")
	fmt.Println(userId)

	var findUser models.User
	result := initializers.DB.First(&findUser, userId)

	fmt.Println("findUser")
	fmt.Println(findUser)
	fmt.Println(result.Error)

	if result.Error != nil {
		errChannel <- errors.New(result.Error.Error())
	} else if findUser.ID == 0 {
		errChannel <- errors.New("failed to get user")
	} else {
		// Send the created user through the channel
		userChannel <- findUser
	}

	fmt.Println("closed")
}

/*
func getUserFromDatabase(userId int, userChannel chan<- BodyUser, errChannel chan<- error) {

	// Simulate a database select by sleeping
	time.Sleep(1 * time.Second)

	// Simulate a database query
	users := []BodyUser{
		{Id: "1", Name: "John Doe", Age: 20},
		{Id: "2", Name: "Jane Doe", Age: 30},
		{Id: "3", Name: "Bob Smith", Age: 40},
	}

	var theUser BodyUser

	// Search for user in slice
	for i, user := range users {

		sId := strconv.Itoa(userId)

		if user.Id == sId {
			fmt.Println(i)
			fmt.Println(user.Id)
			fmt.Println(user.Name)
			///fmt.Println(user.Email)
			theUser = user
		}
	}

	fmt.Println(theUser)

	// Return an error if the user ID is empty
	if theUser.Id == "" {
		errChannel <- errors.New("failed to find user")
	} else {
		// Send the found user through the channel
		userChannel <- theUser
	}

	close(userChannel)
	close(errChannel)
	fmt.Println("closed")
}
*/
