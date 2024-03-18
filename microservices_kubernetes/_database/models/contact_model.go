package models

import "gorm.io/gorm"

type Contact struct {
	gorm.Model
	First_name string
	Last_name  string
	Email      string
	Company_id int32
}
