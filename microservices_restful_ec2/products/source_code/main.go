package main

import (
	"os"

	"github.com/gin-gonic/gin"
	"github.com/juanmanuel0963/golang_aws_terraform_jenkins/v2/microservices_restful_ec2/_database/initializers"
	"github.com/juanmanuel0963/golang_aws_terraform_jenkins/v2/microservices_restful_ec2/products/source_code/controllers"
)

func init() {
	//initializers.LoadEnvVariables()
	initializers.ConnectToDB()
}

func main() {
	r := gin.Default()
	r.POST("/product_create", controllers.ProductCreate)
	r.GET("/product_list", controllers.ProductList)
	r.GET("/product_get/:id", controllers.ProductGet)
	r.GET("/product_get_by_invoiceid/:invoiceid", controllers.ProductGetByInvoiceId)
	r.POST("/product_update/:id", controllers.ProductUpdate)
	r.DELETE("/product_delete/:id", controllers.ProductDelete)

	//err := r.Run(":" + os.Getenv("PORT"))
	//r.Run() // listen and serve on 0.0.0.0:env(PORT)

	err := r.RunTLS(":"+os.Getenv("PORT"), "/home/ubuntu/tls/cert.pem", "/home/ubuntu/tls/key.pem")
	// Listen and Server in https://127.0.0.1:8080

	if err != nil {
		panic("[Error] failed to start Gin server due to: " + err.Error())
	}
}
