package controllers

import (
	"context"
	"fmt"
	"net/http"
	"os"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/juanmanuel0963/golang_aws_terraform_jenkins/v2/cognito/auth_token/source_code/verify_token"
	pb "github.com/juanmanuel0963/golang_aws_terraform_jenkins/v2/microservices_grpc_ec2/usermgmt_op5_rest_to_grpc/usermgmt"
	"github.com/juanmanuel0963/golang_aws_terraform_jenkins/v2/microservices_restful_ec2/_database/models"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

func UserCreate(c *gin.Context) {

	if verify_token.VerifyToken(c) {
		// Get data off req body
		var body struct {
			Name string
			Age  int32
		}

		c.Bind(&body)

		var new_users = models.User{Name: body.Name, Age: body.Age}
		/*
			var new_users = []models.User{
				{Name: "op5: REST to GRPC", Age: 51},
			}
		*/
		//conn, err := grpc.Dial(address, grpc.WithTransportCredentials(insecure.NewCredentials()))
		conn, err := grpc.Dial(os.Getenv("server_address")+":40055", grpc.WithTransportCredentials(insecure.NewCredentials()))
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"error": err.Error(),
			})
			fmt.Printf("did not connect: %s", err.Error()+"\n")
			return
		}

		defer conn.Close()
		client := pb.NewUserManagementClient(conn)

		ctx, cancel := context.WithTimeout(context.Background(), time.Second)
		defer cancel()

		//for _, user := range new_users {
		//}
		r, err := client.CreateNewUser(ctx, &pb.NewUser{Name: new_users.Name, Age: new_users.Age})

		if err != nil {
			fmt.Printf("could not create user: %v", err)
			c.Status(400)
			return
		} else {
			fmt.Printf("User Created: Id: %d, Name: %s, Age: %d\n", r.GetId(), r.GetName(), r.GetAge())
		}

		// Return it
		c.JSON(200, gin.H{
			"user": r,
		})
	}
}
