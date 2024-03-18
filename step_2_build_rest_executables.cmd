::Compiling binaries to upload to AWS
set GOOS=linux
::ls env:
::set $Env:GOOS=linux

::Build Files :: lambda_func_go-------------
cd D:\projects\golang_aws_terraform_jenkins\microservices_restful_lambda\lambda_func_go\source_code
go build main.go
ren main bootstrap

::Build Files :: contacts_delete_by_contact_id-------------
cd D:\projects\golang_aws_terraform_jenkins\microservices_restful_lambda\contacts_delete_by_contact_id\source_code
go build main.go
ren main bootstrap

::Build Files :: contacts_get_by_company_id-------------
cd D:\projects\golang_aws_terraform_jenkins\microservices_restful_lambda\contacts_get_by_company_id\source_code
go build main.go
ren main bootstrap

::Build Files :: contacts_get_by_contact_id-------------
cd D:\projects\golang_aws_terraform_jenkins\microservices_restful_lambda\contacts_get_by_contact_id\source_code
go build main.go
ren main bootstrap

::Build Files :: contacts_get_by_dynamic_filter-------------
cd D:\projects\golang_aws_terraform_jenkins\microservices_restful_lambda\contacts_get_by_dynamic_filter\source_code
go build main.go
ren main bootstrap

::Build Files :: contacts_get_by_pagination-------------
cd D:\projects\golang_aws_terraform_jenkins\microservices_restful_lambda\contacts_get_by_pagination\source_code
go build main.go
ren main bootstrap

::Build Files :: contacts_insert-------------
cd D:\projects\golang_aws_terraform_jenkins\microservices_restful_lambda\contacts_insert\source_code
go build main.go
ren main bootstrap

::Build Files :: contacts_update_by_contact_id-------------
cd D:\projects\golang_aws_terraform_jenkins\microservices_restful_lambda\contacts_update_by_contact_id\source_code
go build main.go
ren main bootstrap

::Build Files :: reminderx_admins-------------
cd D:\projects\golang_aws_terraform_jenkins\microservices_lambda_reminderx\rmdx_admins\source_code
go build main.go
ren main bootstrap

::Build Files :: Blogs-------------
::Blogs - web server
cd D:\projects\golang_aws_terraform_jenkins\microservices_restful_ec2\blogs\source_code
go build main.go


::Build Files :: Posts-------------
::Posts - web server
cd D:\projects\golang_aws_terraform_jenkins\microservices_restful_ec2\posts\source_code
go build main.go


::Build Files :: Products-------------
::Products - web server
cd D:\projects\golang_aws_terraform_jenkins\microservices_restful_ec2\products\source_code
go build main.go

::Build Files :: Invoices-------------
::Invoices - web server
cd D:\projects\golang_aws_terraform_jenkins\microservices_restful_ec2\invoices\source_code
go build main.go

::Build Files :: Users-------------
::Users - web server
cd D:\projects\golang_aws_terraform_jenkins\microservices_restful_ec2\users\source_code
go build main.go

::Build Files :: Cars-------------
::Users - web server
cd D:\projects\golang_aws_terraform_jenkins\microservices_restful_ec2\cars\source_code
go build main.go

::--------Back to root folder-------------
cd D:\projects\golang_aws_terraform_jenkins\

