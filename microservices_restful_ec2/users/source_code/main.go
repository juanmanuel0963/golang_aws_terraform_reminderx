package main

import (
	"os"

	"github.com/gin-gonic/gin"
	"github.com/juanmanuel0963/golang_aws_terraform_jenkins/v2/microservices_restful_ec2/_database/initializers"
	"github.com/juanmanuel0963/golang_aws_terraform_jenkins/v2/microservices_restful_ec2/users/source_code/controllers"
)

func init() {
	initializers.ConnectToDB()
}

func main() {

	r := gin.Default()
	// Set up routes
	r.POST("/users", controllers.CreateUser)
	r.GET("/users/:id", controllers.GetUserById)
	r.GET("/users", controllers.GetAllUsers)
	r.PUT("/users/:id", controllers.UpdateUserById)
	r.DELETE("/users/:id", controllers.DeleteUserById)

	//err := r.Run(":" + os.Getenv("PORT"))
	//r.Run() // listen and serve on 0.0.0.0:env(PORT)

	//Local w/ TLS
	//err := r.RunTLS(":"+os.Getenv("PORT"), "cert.pem", "key.pem")

	//Local w/out TLS
	//err := r.Run(":" + os.Getenv("PORT"))

	//Server
	err := r.RunTLS(":"+os.Getenv("PORT"), "/home/ubuntu/tls/cert.pem", "/home/ubuntu/tls/key.pem")

	// Listen and Server in https://127.0.0.1:8080

	if err != nil {
		panic("[Error] failed to start Gin server due to: " + err.Error())
	}

}
