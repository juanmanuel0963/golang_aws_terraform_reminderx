package controllers

import (
	"errors"
	"fmt"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/juanmanuel0963/golang_aws_terraform_jenkins/v2/microservices_restful_ec2/_database/initializers"
	"github.com/juanmanuel0963/golang_aws_terraform_jenkins/v2/microservices_restful_ec2/_database/models"
)

type BodyUser struct {
	Id   string `json:"id"`
	Name string `json:"name"`
	Age  int32  `json:"age"`
}

func CreateUser(c *gin.Context) {

	var body BodyUser

	// Bind incoming JSON to user struct
	if err := c.ShouldBindJSON(&body); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	var newUser = models.User{Name: body.Name, Age: body.Age}

	// Create a channel to communicate with the goroutine
	userChannel := make(chan models.User)
	errChannel := make(chan error)

	//Calling Go routine
	go createUser(newUser, userChannel, errChannel)

	// Wait for the user to be created and sent through the channel
	select {
	case createdUser := <-userChannel:
		c.JSON(http.StatusOK, gin.H{
			"user": createdUser,
		})
	case err := <-errChannel:
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": err.Error(),
		})
	}
}

func createUser(newUser models.User, userChannel chan<- models.User, errChannel chan<- error) {

	defer close(userChannel)
	defer close(errChannel)

	result := initializers.DB.Create(&newUser)

	if result.Error != nil {
		errChannel <- errors.New(result.Error.Error())
	} else if newUser.ID == 0 {
		errChannel <- errors.New("failed to create user")
	} else {
		// Send the created user through the channel
		userChannel <- newUser
	}

	fmt.Println("closed")
}

/*
func createUser(newUser models.User, userChannel chan<- models.User, errChannel chan<- error) {
	// Simulate a database insert by sleeping
	time.Sleep(1 * time.Second)

	// Generate a UUID for the new user
	newUser.ID = uint(rand.Int())

	// Simulate a database query
	users := []models.User{
		{Name: "John Doe", Age: 20},
		{Name: "Jane Doe", Age: 30},
		{Name: "Bob Smith", Age: 40},
	}

	// Append the created user to the users slice
	users = append(users, newUser)

	fmt.Println(users)

	// Return an error if the user ID is empty
	if newUser.ID == 0 {
		errChannel <- errors.New("failed to create user")
	} else {
		// Send the created user through the channel
		userChannel <- newUser
	}

	close(userChannel)
	close(errChannel)
	fmt.Println("closed")
}
*/
/*
func createUser(theUser User, userChannel chan<- User, errChannel chan<- error) {
	// Simulate a database insert by sleeping
	time.Sleep(1 * time.Second)

	// Generate a UUID for the new user
	uuid := uuid.NewV4()
	theUser.Id = uuid.String()

	// Simulate a database query
	users := []User{
		{Id: "1", Name: "John Doe", Age: 20},
		{Id: "2", Name: "Jane Doe", Age: 30},
		{Id: "3", Name: "Bob Smith", Age: 40},
	}

	// Append the created user to the users slice
	users = append(users, theUser)

	fmt.Println(users)

	// Return an error if the user ID is empty
	if theUser.Id == "" {
		errChannel <- errors.New("failed to create user")
	} else {
		// Send the created user through the channel
		userChannel <- theUser
	}

	close(userChannel)
	close(errChannel)
	fmt.Println("closed")
}
*/
