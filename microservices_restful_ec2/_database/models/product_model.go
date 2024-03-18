package models

import "gorm.io/gorm"

type Product struct {
	gorm.Model
	Title    string
	Invoices []Invoice `json:"invoices" gorm:"many2many:invoice_products" binding:"required"`
}
