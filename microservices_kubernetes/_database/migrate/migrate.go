package main

import (
	"fmt"

	"github.com/juanmanuel0963/golang_aws_terraform_jenkins/v2/microservices_restful_ec2/_database/initializers"
	"github.com/juanmanuel0963/golang_aws_terraform_jenkins/v2/microservices_restful_ec2/_database/models"
)

func init() {
	//Deprecate--Only for connections from localhost
	//initializers.LoadEnvVariables()

	//Initialize DB conn
	initializers.ConnectToDB()
}

func main() {

	//----------Users----------

	initializers.DB.AutoMigrate(&models.User{})

	//----------Contacts----------

	initializers.DB.AutoMigrate(&models.Contact{})

	//----------Blogs and Posts----------

	initializers.DB.AutoMigrate(&models.Blog{}, &models.Post{})

	//----------Invoices and Products----------

	initializers.DB.AutoMigrate(&models.Invoice{}, &models.Product{})

	//----------Users - Adding Data----------

	var users = []models.User{
		{Name: "migrate: Juan", Age: 31},
	}

	initializers.DB.Create(&users)

	for _, user := range users {
		fmt.Println("User: ", user.ID) // 1,2,3
	}

	//----------Blogs and Posts - Adding Data----------

	var blogs = []models.Blog{
		{Title: "Programming Blog 1", Posts: []models.Post{{Title: "Golang programming post 1", Body: "Body Golang programming post 1"}, {Title: "Golang programming post 2", Body: "Body Golang programming post 2"}}},
		{Title: "Programming Blog 2", Posts: []models.Post{{Title: "Golang programming post 1", Body: "Body Golang programming post 1"}, {Title: "Golang programming post 2", Body: "Body Golang programming post 2"}}},
		{Title: "Programming Blog 3", Posts: []models.Post{{Title: "Golang programming post 1", Body: "Body Golang programming post 1"}, {Title: "Golang programming post 2", Body: "Body Golang programming post 2"}}},
	}

	initializers.DB.Create(&blogs)

	for _, blog := range blogs {
		fmt.Println("Blog: ", blog.ID) // 1,2,3
		for _, post := range blog.Posts {
			fmt.Println("	Post: ", post.ID) // 1,2,3
		}
	}

	////----------Adding a new Post to a Blog----------
	var id uint
	row := initializers.DB.Table("blogs").Where("id = ?", 1).Select("id").Row()
	row.Scan(&id)

	post := models.Post{Title: "Java programming post", Body: "Body Java programming post", BlogID: id}
	initializers.DB.Create(&post)

	//----------Invoices and Products - Adding Data----------

	var products = []models.Product{
		{Title: "Retail Product 1"},
		{Title: "Technology Product 2"},
		{Title: "Sports Product 3"},
	}

	initializers.DB.Create(&products)

	var newproduct0 = products[0]
	fmt.Println("Product: ", newproduct0.ID)

	var newproduct1 = products[1]
	fmt.Println("Product: ", newproduct1.ID)

	var newproduct2 = products[2]
	fmt.Println("Product: ", newproduct2.ID)

	// Create Invoice and add Products
	var findProduct models.Product
	initializers.DB.First(&findProduct, 412) //Finding hard-coded Product

	var invoices = []models.Invoice{
		{Title: "Invoice 1", Products: []models.Product{newproduct0, newproduct1, newproduct2, findProduct}},
		{Title: "Invoice 2", Products: []models.Product{newproduct0, newproduct1, newproduct2, findProduct}},
		{Title: "Invoice 3", Products: []models.Product{newproduct0, newproduct1, newproduct2, findProduct}},
		{Title: "Invoice find Product", Products: []models.Product{newproduct0, newproduct1, newproduct2, findProduct}},
	}

	initializers.DB.Create(&invoices)

	for _, invoice := range invoices {
		fmt.Println("Invoice: ", invoice.ID) // 1,2,3
		for _, product := range invoice.Products {
			fmt.Println("	Product: ", product.ID) // 1,2,3
		}
	}

}
