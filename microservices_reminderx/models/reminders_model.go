package models

import (
	"gorm.io/gorm"
)

type Reminder struct {
	gorm.Model   // Includes fields: ID, CreatedAt, UpdatedAt, DeletedAt
	ClientID     int
	Client       Client `gorm:"foreignKey:ClientID"` // use ClientID as foreign key
	CommitmentID int
	Commitment   Commitment `gorm:"foreignKey:CommitmentID"` // use CommitmentID as foreign key

	Title   string `json:"title"`
	Message string `json:"message"`

	DaysBefore     int    `json:"daysBefore"`
	Frequency      string `json:"frequency"`
	Recipients     string `json:"recipients"`
	Channels       string `json:"channels"`
	ClientSchedule string `json:"clientSchedule"`
	AdminSchedule  string `json:"adminSchedule"`
}

type Reminder_Get struct {
	gorm.Model   // Includes fields: ID, CreatedAt, UpdatedAt, DeletedAt
	ClientID     int
	Client       Client `gorm:"foreignKey:ClientID"` // use ClientID as foreign key
	CommitmentID int
	Commitment   Commitment `gorm:"foreignKey:CommitmentID"` // use CommitmentID as foreign key

	Title   string `json:"title"`
	Message string `json:"message"`

	DaysBefore      int    `json:"daysBefore"`
	Frequency       string `json:"frequency"`
	Recipients      string `json:"recipients"`
	Channels        string `json:"channels"`
	ClientFirstName string `json:"clientFirstName"`
	ClientSurName   string `json:"clientSurName"`
	AdminFirstName  string `json:"adminFirstName"`
	AdminSurName    string `json:"adminSurName"`
	ClientSchedule  string `json:"clientSchedule"`
	AdminSchedule   string `json:"adminSchedule"`
}
