package main

import (
	"context"
	"fmt"
	"log"
	"net"

	pb "github.com/juanmanuel0963/golang_aws_terraform_jenkins/v2/microservices_grpc_ec2/usermgmt_op5_rest_to_grpc/usermgmt"
	"github.com/juanmanuel0963/golang_aws_terraform_jenkins/v2/microservices_restful_ec2/_database/initializers"
	"github.com/juanmanuel0963/golang_aws_terraform_jenkins/v2/microservices_restful_ec2/_database/models"
	"google.golang.org/grpc"
	"gorm.io/gorm"
)

var DB *gorm.DB

const (
	port = ":40055"
)

func NewUserManagementServer() *UserManagementServer {
	return &UserManagementServer{}
}

type UserManagementServer struct {
	//DB                  *pgx.Conn
	DB                  *gorm.DB
	first_user_creation bool
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

// When user is added, read full userlist from file into
// userlist struct, then append new user and write new userlist back to file
func (server *UserManagementServer) CreateNewUser(ctx context.Context, in *pb.NewUser) (*pb.User, error) {

	server.first_user_creation = false
	fmt.Printf("User received: Name: %v, Age: %v\n", in.GetName(), in.GetAge())

	user_to_create := &pb.User{Name: in.GetName(), Age: in.GetAge()}

	fmt.Print("User to create: ", user_to_create)

	//----------Users - Adding Data----------

	var users = []models.User{
		{Name: user_to_create.Name, Age: user_to_create.Age},
	}

	initializers.DB.Create(&users)

	for _, user := range users {
		user_to_create.Id = int32(user.ID)
		fmt.Printf("Id User created: %v\n", user.ID) // 1,2,3
	}

	return user_to_create, nil
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
	user_mgmt_server.first_user_creation = true
	if err := user_mgmt_server.Run(); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}
