package models

import (
	"gorm.io/datatypes"
	"gorm.io/gorm"
)

type Commitment struct {
	gorm.Model                // Includes fields: ID, CreatedAt, UpdatedAt, DeletedAt
	Commitment string         `json:"commitment"`
	Date       datatypes.Date `json:"date"`
	ClientID   int
	Client     Client `gorm:"foreignKey:ClientID"` // use AdminID as foreign key
}

type Commitment_Get struct {
	gorm.Model                     // Includes fields: ID, CreatedAt, UpdatedAt, DeletedAt
	Commitment      string         `json:"commitment"`
	Date            datatypes.Date `json:"date"`
	ClientID        int
	Client          Client `gorm:"foreignKey:ClientID"` // use AdminID as foreign key
	ClientFirstName string `json:"clientFirstName"`
	ClientSurName   string `json:"clientSurName"`
}
