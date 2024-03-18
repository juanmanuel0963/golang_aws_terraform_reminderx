package controllers

import (
	"github.com/gin-gonic/gin"
	"github.com/juanmanuel0963/golang_aws_terraform_jenkins/v2/microservices_restful_ec2/_database/initializers"
	"github.com/juanmanuel0963/golang_aws_terraform_jenkins/v2/microservices_restful_ec2/_database/models"
)

func InvoiceCreate(c *gin.Context) {

	type ProductInput struct {
		ProductId uint
	}

	// Get data off req body
	var body struct {
		Title    string
		Products []ProductInput
	}

	c.Bind(&body)

	var productsList []models.Product

	//Finding input Products
	for _, product := range body.Products {
		var productFind models.Product
		initializers.DB.First(&productFind, product.ProductId)

		if productFind.ID > 0 {
			productsList = append(productsList, productFind)
		}
	}

	// Crete an invoice
	invoice := models.Invoice{Title: body.Title, Products: productsList}
	result := initializers.DB.Create(&invoice)

	if result.Error != nil {
		c.Status(400)
		return
	}

	// Return it
	c.JSON(200, gin.H{
		"invoice": invoice,
	})
}

func InvoiceList(c *gin.Context) {

	// Get the invoices list
	var invoices []models.Invoice
	initializers.DB.Find(&invoices)

	//Respond with them
	c.JSON(200, gin.H{
		"invoice": invoices,
	})
}

func InvoiceGet(c *gin.Context) {

	//Get the id off url
	id := c.Param("id")

	// Get the invoice
	var invoice models.Invoice
	initializers.DB.First(&invoice, id)

	//Respond with it
	c.JSON(200, gin.H{
		"invoice": invoice,
	})
}

func InvoiceUpdate(c *gin.Context) {

	//Get the id off url
	id := c.Param("id")

	// Get the data off req body
	var body struct {
		Title string
	}
	c.Bind(&body)

	// Find the invoice were updating
	var invoice models.Invoice
	initializers.DB.First(&invoice, id)

	// Update it
	initializers.DB.Model(&invoice).Updates(models.Invoice{Title: body.Title})

	// Respond with id
	c.JSON(200, gin.H{
		"invoice": invoice,
	})
}

func InvoiceDelete(c *gin.Context) {

	//Get the id off the url
	id := c.Param("id")

	//Delete the invoice
	initializers.DB.Delete(&models.Invoice{}, id)

	//Respond
	c.Status(200)
}
