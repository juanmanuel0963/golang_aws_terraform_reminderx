package handler

import (
	"log"

	"github.com/gin-gonic/gin"
)

func AdminsPost(c *gin.Context) {
	// Return it
	c.JSON(200, gin.H{
		"admin": "OK",
	})
}

func AdminsGet(c *gin.Context) {

	//Get the id off url
	id := c.Param("id")
	log.Println(id)

	// Return it
	c.JSON(200, gin.H{
		"admin": "OK " + id,
	})
}

func AdminsDelete(c *gin.Context) {

	//Get the id off url
	id := c.Param("id")
	log.Println(id)

	// Return it
	c.JSON(200, gin.H{
		"admin": "OK " + id,
	})
}

func AdminsPut(c *gin.Context) {

	//Get the id off url
	id := c.Param("id")
	log.Println(id)

	// Return it
	c.JSON(200, gin.H{
		"admin": "OK " + id,
	})
}

func AdminsPatch(c *gin.Context) {

	//Get the id off url
	id := c.Param("id")
	log.Println(id)

	// Return it
	c.JSON(200, gin.H{
		"admin": "OK " + id,
	})
}
