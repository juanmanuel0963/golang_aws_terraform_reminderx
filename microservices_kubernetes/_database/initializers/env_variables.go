package initializers

import (
	"fmt"
	"log"
	"os"

	"github.com/joho/godotenv"
)

func LoadEnvVariables() {

	err := godotenv.Load(os.Getenv("path_env_variables"))

	if err != nil {
		log.Fatal("Error loading .env file")
	}

	fmt.Println("Successfully loaded .env file")
}
