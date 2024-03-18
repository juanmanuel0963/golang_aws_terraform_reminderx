package initializers

import (
	"fmt"
	"os"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

var DB *gorm.DB

func ConnectToDB() {

	var err error

	//Only for connections from EC2 instance
	dsn := os.Getenv("db_conn")
	fmt.Println(dsn)

	myDB, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	DB = myDB

	if err != nil {
		fmt.Println("Failed to connect to database")
	} else {
		fmt.Println("Connected successfully to database")
	}

}
