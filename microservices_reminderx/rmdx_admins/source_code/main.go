package main

import (
	"os"

	"github.com/gin-gonic/gin"
)

func init() {

}

func main() {
	r := gin.Default()
	/*
		r.POST("/", AdminsPost)
		r.GET("/:id", AdminsGet)
		r.DELETE("/:id", AdminsDelete)
		r.PUT("/:id", AdminsPut)
		r.PATCH("/:id", AdminsPatch)
	*/
	err := r.Run(":" + os.Getenv("PORT"))

	if err != nil {
		panic("[Error] failed to start Gin server due to: " + err.Error())
	}
}
