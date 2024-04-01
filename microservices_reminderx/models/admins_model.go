package models

import "gorm.io/gorm"

type Admin struct {
	gorm.Model           // Includes fields: ID, CreatedAt, UpdatedAt, DeletedAt
	FirstName     string `json:"firstName"`
	SurName       string `json:"surName"`
	CountryCode   string `json:"countryCode"`
	PhoneNumber   string `json:"phoneNumber"` // Updated field name
	Email         string `json:"email"`
	Password      string `json:"password"`
	IsSuperAdmin  bool   `json:"isSuperAdmin"`
	IsAdmin       bool   `json:"isAdmin"`
	ParentAdminID uint   `json:"parentAdminID"`
}
