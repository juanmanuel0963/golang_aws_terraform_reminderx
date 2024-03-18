package models

import "gorm.io/gorm"

type Car struct {
	gorm.Model
	Category string
	Color    string
	Maker    string
	Modelo   string
	Package  string
	Mileage  int32
	Year     int32
	Price    int32
}
