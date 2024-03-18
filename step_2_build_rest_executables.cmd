::Compiling binaries to upload to AWS
set GOOS=linux
::ls env:
::set $Env:GOOS=linux

::Build Files :: lambda_func_go-------------
cd D:\projects\golang_aws_terraform_reminderx\microservices_restful_lambda\lambda_func_go\source_code
go build main.go
ren main bootstrap


::Build Files :: reminderx_admins-------------
cd D:\projects\golang_aws_terraform_reminderx\microservices_reminderx\rmdx_admins\source_code
go build main.go
ren main bootstrap

::--------Back to root folder-------------
cd D:\projects\golang_aws_terraform_reminderx\

