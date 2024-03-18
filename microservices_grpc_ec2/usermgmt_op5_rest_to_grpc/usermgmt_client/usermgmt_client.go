package main

import (
	"github.com/gin-gonic/gin"
	"github.com/juanmanuel0963/golang_aws_terraform_jenkins/v2/microservices_grpc_ec2/usermgmt_op5_rest_to_grpc/controllers"
)

const (
// address = "localhost:50054"
// address = "172.31.92.9:50051"
)

func main() {

	r := gin.Default()
	r.POST("/user_create", controllers.UserCreate)

	//err := r.Run(":" + os.Getenv("PORT"))
	//r.Run() // listen and serve on 0.0.0.0:env(PORT)

	//Local w/TLS
	//err := r.RunTLS(":50055", "cert.pem", "key.pem")

	//Local wout/TLS
	//err := r.Run(":50055")

	//Server
	err := r.RunTLS(":50055", "/home/ubuntu/tls/cert.pem", "/home/ubuntu/tls/key.pem")

	// Listen and Server in https://127.0.0.1:8080

	if err != nil {
		panic("[Error] failed to start Gin server due to: " + err.Error())
	}
}
