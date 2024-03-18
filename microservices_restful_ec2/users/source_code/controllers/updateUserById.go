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

func UpdateUserById(c *gin.Context) {

	// Get user ID from path parameter
	userId, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Invalid your user ID",
		})
		return
	}

	var body BodyUser

	// Bind incoming JSON to user struct
	if err := c.ShouldBindJSON(&body); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	var updateUser = models.User{Name: body.Name, Age: body.Age}

	// Create a channel to communicate with the goroutine
	userChannel := make(chan bool)
	errChannel := make(chan error)

	//Calling Go routine
	go updateUserInDatabase(userId, updateUser, userChannel, errChannel)

	// Wait for the user to be created and sent through the channel
	select {
	case updatedUser := <-userChannel:
		c.JSON(http.StatusOK, gin.H{
			"status": updatedUser,
		})
	case err := <-errChannel:
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": err.Error(),
		})
	}
}

func updateUserInDatabase(userId int, updateUser models.User, userChannel chan<- bool, errChannel chan<- error) {

	defer close(userChannel)
	defer close(errChannel)

	//fmt.Println("Printing")

	//fmt.Println(updateUser)
	fmt.Println("Go Routine")

	fmt.Println("userId")
	fmt.Println(userId)

	var findUser models.User
	result := initializers.DB.First(&findUser, userId)

	fmt.Println("findUser")
	fmt.Println(findUser)

	if result.Error != nil {
		errChannel <- errors.New(result.Error.Error())
	} else if findUser.ID == 0 {
		errChannel <- errors.New("failed to find user for updating")
	}

	// Update it
	result = initializers.DB.Model(&findUser).Updates(updateUser)

	fmt.Println("updateUser")
	fmt.Println(updateUser)

	if result.Error != nil {
		errChannel <- errors.New(result.Error.Error())
	} else {
		// Send the created user through the channel
		userChannel <- true
	}

	fmt.Println("closed")
}

/*
func updateUserInDatabase(userId int, inputUser BodyUser, userChannel chan<- BodyUser, errChannel chan<- error) {

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
			//fmt.Println(user.Email)
			// Update user with new name and email
			user.Name = inputUser.Name
			user.Age = inputUser.Age
			//user.Email = inputUser.Email
			//
			users[i].Name = inputUser.Name
			users[i].Age = inputUser.Age
			//users[i].Email = inputUser.Email
			//
			theUser = user
		}
	}

	fmt.Println(theUser)
	fmt.Println(users)

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
