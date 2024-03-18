package models

import "gorm.io/gorm"

type Invoice struct {
	gorm.Model
	Title    string
	Products []Product `json:"products" gorm:"many2many:invoice_products" binding:"required"`
}
