package main

import (
	"os"

	"github.com/gin-gonic/gin"
	"github.com/juanmanuel0963/golang_aws_terraform_jenkins/v2/microservices_restful_ec2/_database/initializers"
	"github.com/juanmanuel0963/golang_aws_terraform_jenkins/v2/microservices_restful_ec2/posts/source_code/controllers"
)

func init() {
	//initializers.LoadEnvVariables()
	initializers.ConnectToDB()
}

func main() {
	r := gin.Default()
	r.POST("/post_create", controllers.PostCreate)
	r.GET("/post_list", controllers.PostList)
	r.GET("/post_get/:id", controllers.PostGet)
	r.GET("/post_get_by_blogid/:blogid", controllers.PostGetByBlogId)
	r.POST("/post_get_by_dynamic_filter", controllers.PostGetByDynamicFilter)
	r.POST("/post_get_by_pagination", controllers.PostGetByPagination)
	r.POST("/post_update/:id", controllers.PostUpdate)
	r.DELETE("/post_delete/:id", controllers.PostDelete)

	//err := r.Run(":" + os.Getenv("PORT"))
	//r.Run() // listen and serve on 0.0.0.0:env(PORT)

	err := r.RunTLS(":"+os.Getenv("PORT"), "/home/ubuntu/tls/cert.pem", "/home/ubuntu/tls/key.pem")
	// Listen and Server in https://127.0.0.1:8080

	if err != nil {
		panic("[Error] failed to start Gin server due to: " + err.Error())
	}
}
