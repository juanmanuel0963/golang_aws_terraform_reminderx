package models

import "gorm.io/gorm"

type Client struct {
	gorm.Model         // Includes fields: ID, CreatedAt, UpdatedAt, DeletedAt
	FirstName   string `json:"firstName"`
	SurName     string `json:"surName"`
	CountryCode string `json:"countryCode"`
	PhoneNumber string `json:"phoneNumber"` // Updated field name
	Email       string `json:"email"`
	AdminID     int
	Admin       Admin `gorm:"foreignKey:AdminID"` // use AdminID as foreign key
}

type Client_Get struct {
	gorm.Model            // Includes fields: ID, CreatedAt, UpdatedAt, DeletedAt
	FirstName      string `json:"firstName"`
	SurName        string `json:"surName"`
	CountryCode    string `json:"countryCode"`
	PhoneNumber    string `json:"phoneNumber"` // Updated field name
	Email          string `json:"email"`
	AdminID        int
	Admin          Admin  `gorm:"foreignKey:AdminID"` // use AdminID as foreign key
	AdminFirstName string `json:"adminFirstName"`
	AdminSurName   string `json:"adminSurName"`
}
