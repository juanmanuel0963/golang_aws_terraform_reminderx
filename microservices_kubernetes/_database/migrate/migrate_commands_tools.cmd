set GOOS=windows
set GOARCH=amd64
::set $Env:GOOS=windows  
::set $Env:GOARCH=amd64
del migrate
del migrate.exe
go build migrate.go
go run migrate.go
