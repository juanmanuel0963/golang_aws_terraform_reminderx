package controllers

import (
	"context"
	"errors"
	"fmt"
	"net/http"
	"os"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/juanmanuel0963/golang_aws_terraform_jenkins/v2/cognito/auth_token/source_code/verify_token"
	pb "github.com/juanmanuel0963/golang_aws_terraform_jenkins/v2/microservices_grpc_ec2/usermgmt_op6_rest_to_grpc_chan/usermgmt"
	"github.com/juanmanuel0963/golang_aws_terraform_jenkins/v2/microservices_restful_ec2/_database/models"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

type BodyUser struct {
	Id    string `json:"id"`
	Name  string `json:"name"`
	Age   int32  `json:"age"`
	Email string `json:"email"`
}

func UserCreate(c *gin.Context) {

	if verify_token.VerifyToken(c) {

		var body BodyUser

		// Bind incoming JSON to user struct
		if err := c.ShouldBindJSON(&body); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{
				"error": err.Error(),
			})
			fmt.Printf("incorrect body: %s", err.Error()+"\n")
			return
		}

		var newUser = models.User{Name: body.Name, Age: body.Age}

		//connection stablish with server
		conn, err := grpc.Dial(os.Getenv("server_address")+":40056", grpc.WithTransportCredentials(insecure.NewCredentials()))

		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"error": err.Error(),
			})
			fmt.Printf("did not connect: %s", err.Error()+"\n")
			return
		}

		defer conn.Close()

		client := pb.NewUserManagementClient(conn)

		// Create a context with a timeout of 60 seconds
		ctx, cancel := context.WithTimeout(context.Background(), 60*time.Second)
		defer cancel()

		//------------------------------

		userToCreate := &pb.NewUser{Name: newUser.Name, Age: newUser.Age}
		contactToCreate := &pb.NewContact{FirstName: newUser.Name, LastName: newUser.Name, Email: body.Email, CompanyId: 1}
		var createdUser *pb.User
		var createdUserErr error
		var createdContact *pb.Contact
		var createdContactErr error

		// Create a channel to communicate with the goroutine
		userChannel := make(chan *pb.User)
		userErrChannel := make(chan error)

		// Create a channel to communicate with the goroutine
		contactChannel := make(chan *pb.Contact)
		contactErrChannel := make(chan error)

		//Calling Go routine for user creation
		go UserCreateServerCall(ctx, userToCreate, client, userChannel, userErrChannel)

		//Calling Go routine for contact creation
		go ContactCreateServerCall(ctx, contactToCreate, client, contactChannel, contactErrChannel)

		//------------------------------

		// Wait for the user to be created and sent through the channel
		select {
		case createdUser = <-userChannel:
			fmt.Printf("User created: Id: %d, Name: %s, Age: %d\n", createdUser.GetId(), createdUser.GetName(), createdUser.GetAge())
		case createdUserErr = <-userErrChannel:
			fmt.Printf("could not create user: %v", createdUserErr.Error())
		case <-ctx.Done():
			fmt.Printf("UserCreateServerCall request timed out")
			createdUserErr = ctx.Err()
		}

		//------------------------------

		// Wait for the contact to be created and sent through the channel
		select {
		case createdContact = <-contactChannel:
			fmt.Printf("Contact created: Id: %d, First Name: %s, Last Name: %s, Email: %s\n", createdContact.GetId(), createdContact.GetFirstName(), createdContact.GetLastName(), createdContact.GetEmail())
		case createdContactErr = <-contactErrChannel:
			fmt.Printf("could not create contact: %v", createdContactErr)
		case <-ctx.Done():
			fmt.Printf("ContactCreateServerCall request timed out")
		}

		//------------------------------

		if createdUser != nil && createdContact != nil {
			c.JSON(http.StatusOK, gin.H{
				"user":    createdUser,
				"contact": createdContact,
			})
		} else if createdUserErr != nil && createdContactErr != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"user_error":    createdUserErr,
				"contact_error": createdContactErr,
			})
		} else if createdUserErr != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"user_error": createdUserErr,
			})
		} else if createdContactErr != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"contact_error": createdContactErr,
			})
		}

	}
}

// Go Routine for user creation which returns success and error channels
func UserCreateServerCall(ctx context.Context, userToCreate *pb.NewUser, client pb.UserManagementClient, userChannel chan<- *pb.User, errChannel chan<- error) {

	defer close(userChannel)
	defer close(errChannel)

	createdUser, err := client.CreateNewUser(ctx, userToCreate)

	if err != nil {
		errChannel <- errors.New(err.Error())
	} else if createdUser.Id == 0 {
		errChannel <- errors.New("failed to create user")
	} else {
		// Send the created user through the channel
		userChannel <- createdUser
	}

	fmt.Println("User create closed")
}

// Go Routine for contact creation which returns success and error channels
func ContactCreateServerCall(ctx context.Context, contactToCreate *pb.NewContact, client pb.UserManagementClient, contactChannel chan<- *pb.Contact, errChannel chan<- error) {

	defer close(contactChannel)
	defer close(errChannel)

	createdContact, err := client.CreateNewContact(ctx, contactToCreate)

	if err != nil {
		errChannel <- errors.New(err.Error())
	} else if createdContact.Id == 0 {
		errChannel <- errors.New("failed to create user")
	} else {
		// Send the created user through the channel
		contactChannel <- createdContact
	}

	fmt.Println("Contact create closed")
}
