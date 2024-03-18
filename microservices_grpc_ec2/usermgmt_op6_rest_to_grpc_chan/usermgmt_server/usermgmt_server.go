package main

import (
	"context"
	"errors"
	"fmt"
	"log"
	"net"

	pb "github.com/juanmanuel0963/golang_aws_terraform_jenkins/v2/microservices_grpc_ec2/usermgmt_op6_rest_to_grpc_chan/usermgmt"
	"github.com/juanmanuel0963/golang_aws_terraform_jenkins/v2/microservices_restful_ec2/_database/initializers"
	"github.com/juanmanuel0963/golang_aws_terraform_jenkins/v2/microservices_restful_ec2/_database/models"
	"google.golang.org/grpc"
	"gorm.io/gorm"
)

var DB *gorm.DB

const (
	port = ":40056"
)

func NewUserManagementServer() *UserManagementServer {
	return &UserManagementServer{}
}

type UserManagementServer struct {
	//DB                  *pgx.Conn
	DB *gorm.DB
	pb.UnimplementedUserManagementServer
}

func (server *UserManagementServer) Run() error {
	lis, err := net.Listen("tcp", port)
	if err != nil {
		fmt.Printf("failed to listen: %v", err)
	}

	s := grpc.NewServer()
	pb.RegisterUserManagementServer(s, server)
	fmt.Printf("server listening at %v", lis.Addr())

	return s.Serve(lis)
}

func (server *UserManagementServer) CreateNewUser(ctx context.Context, in *pb.NewUser) (*pb.User, error) {

	fmt.Printf("User received: Name: %v, Age: %v\n", in.GetName(), in.GetAge())

	userToCreate := &pb.User{Name: in.GetName(), Age: in.GetAge()}

	fmt.Println("User to create: ", userToCreate)

	//----------Users - Adding Data----------

	var newUser = models.User{Name: userToCreate.Name, Age: userToCreate.Age}

	// Create a channel to communicate with the goroutine
	userChannel := make(chan models.User)
	errChannel := make(chan error)

	//Calling Go routine
	go createUser(newUser, userChannel, errChannel)

	// Wait for the user to be created and sent through the channel
	select {
	case newUser := <-userChannel:
		userToCreate.Id = int32(newUser.ID)
		return userToCreate, nil
	case err := <-errChannel:
		return nil, err
	case <-ctx.Done():
		return nil, ctx.Err()
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

func (server *UserManagementServer) CreateNewContact(ctx context.Context, in *pb.NewContact) (*pb.Contact, error) {

	fmt.Printf("Contact received: FirstName: %v, LastName: %v, Email: %v\n", in.GetFirstName(), in.GetLastName(), in.GetEmail())

	contactToCreate := &pb.Contact{FirstName: in.GetFirstName(), LastName: in.GetLastName(), Email: in.Email, CompanyId: in.CompanyId}

	fmt.Println("Contact to create: ", contactToCreate)

	//----------Contacts - Adding Data----------

	var newContact = models.Contact{First_name: contactToCreate.FirstName, Last_name: contactToCreate.LastName, Email: contactToCreate.Email, Company_id: contactToCreate.CompanyId}

	// Create a channel to communicate with the goroutine
	contactChannel := make(chan models.Contact)
	errChannel := make(chan error)

	//Calling Go routine
	go createContact(newContact, contactChannel, errChannel)

	// Wait for the user to be created and sent through the channel
	select {
	case newContact := <-contactChannel:
		contactToCreate.Id = int32(newContact.ID)
		return contactToCreate, nil
	case err := <-errChannel:
		return nil, err
	case <-ctx.Done():
		return nil, ctx.Err()
	}
}

func createContact(newContact models.Contact, contactChannel chan<- models.Contact, errChannel chan<- error) {

	defer close(contactChannel)
	defer close(errChannel)

	result := initializers.DB.Create(&newContact)

	if result.Error != nil {
		errChannel <- errors.New(result.Error.Error())
	} else if newContact.ID == 0 {
		errChannel <- errors.New("failed to create contact")
	} else {
		// Send the created user through the channel
		contactChannel <- newContact
	}

	fmt.Println("closed")
}

func (server *UserManagementServer) GetUsers(ctx context.Context, in *pb.GetUsersParams) (*pb.UsersList, error) {

	var users_list *pb.UsersList = &pb.UsersList{}
	/*
		rows, err := server.DB.Query(context.Background(), "select * from users")
		if err != nil {
			return nil, err
		}
		defer rows.Close()
		for rows.Next() {
			user := pb.User{}
			err = rows.Scan(&user.Id, &user.Name, &user.Age)
			if err != nil {
				return nil, err
			}
			users_list.Users = append(users_list.Users, &user)

		}
	*/
	return users_list, nil
}
func init() {
	//Deprecate--Only for connections from localhost
	//initializers.LoadEnvVariables()

	//Initialize DB conn
	initializers.ConnectToDB()
}

func main() {
	var user_mgmt_server *UserManagementServer = NewUserManagementServer()
	user_mgmt_server.DB = DB
	if err := user_mgmt_server.Run(); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}
