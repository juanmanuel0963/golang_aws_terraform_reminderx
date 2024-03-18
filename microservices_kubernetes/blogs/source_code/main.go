package main

import (
	"os"

	"github.com/gin-gonic/gin"
	"github.com/juanmanuel0963/golang_aws_terraform_jenkins/v2/microservices_kubernetes/_database/initializers"
	"github.com/juanmanuel0963/golang_aws_terraform_jenkins/v2/microservices_kubernetes/blogs/source_code/controllers"
)

func init() {
	//initializers.LoadEnvVariables()
	initializers.ConnectToDB()
}

func main() {
	r := gin.Default()
	r.POST("/blog_create", controllers.BlogCreate)
	r.GET("/blog_list", controllers.BlogList)
	r.GET("/blog_get/:id", controllers.BlogGet)
	r.POST("/blog_update/:id", controllers.BlogUpdate)
	r.DELETE("/blog_delete/:id", controllers.BlogDelete)

	//err := r.Run(":" + os.Getenv("PORT"))
	//r.Run() // listen and serve on 0.0.0.0:env(PORT)

	//Local w/ TLS
	//err := r.RunTLS(":"+os.Getenv("PORT"), "cert.pem", "key.pem")

	//Local w/out TLS
	//err := r.Run(":" + os.Getenv("PORT"))
	//err := r.Run(":" + "3000")

	//Server w/ TLS
	//err := r.RunTLS(":"+os.Getenv("PORT"), "/home/ubuntu/tls/cert.pem", "/home/ubuntu/tls/key.pem")
	//err := r.RunTLS(":"+"3000", "cert.pem", "key.pem")

	//Server w/out TLS
	err := r.Run(":" + os.Getenv("PORT"))

	//err := r.RunTLS(":"+os.Getenv("PORT"), "", "")
	// Listen and Server in https://127.0.0.1:8080

	if err != nil {
		panic("[Error] failed to start Gin server due to: " + err.Error())
	}

}
