region     = "us-east-1"
access_key = ""
secret_key = ""
#db_postgresql
identifier              = "db-server-postgresql"
storage_type            = "gp2"
allocated_storage       = 20
engine                  = "postgres"
engine_version          = "13.13"
instance_class          = "db.t3.micro"
db_port                 = "5432"
db_name                 = "db_postgresql"
db_username             = "db_master"
db_password             = ""
parameter_group_name    = "default.postgres13"
publicly_accessible     = true
deletion_protection     = true
skip_final_snapshot     = true
backup_retention_period = 0
backup_window           = "21:00-21:30"
maintenance_window      = "Fri:21:30-Fri:22:00"
apply_immediately       = true
#ec2 instances type
ami_id = "ami-053b0d53c279acc90" #2023-05-19
#ami_id                  = "ami-0557a15b87f6559cf" #2023-02-08
#ami_id                  = "ami-0149b2da6ceec4bb0" #2022-09-14
instance_type = "t2.micro"
key_name      = "env.key_pair"
#
grpc_server_1_instance_name     = "grpc_server_1"
grpc_server_1_tag_name          = "grpc_server_1 - Ubuntu 1GB"
grpc_server_1_server_install    = "software_install"
grpc_server_1_op1_function_name = "op1_grpc_start_service"
grpc_server_1_op2_function_name = "op2_grpc_start_service"
grpc_server_1_op3_function_name = "op3_grpc_start_service"
grpc_server_1_op4_function_name = "op4_grpc_start_service"
grpc_server_1_op5_function_name = "op5_grpc_start_service"
grpc_server_1_op6_function_name = "op6_grpc_start_service"
#grpc_client_1 
grpc_client_1_instance_name     = "grpc_client_1"
grpc_client_1_tag_name          = "grpc_client_1 - Ubuntu 1GB"
grpc_client_1_client_install    = "software_install"
grpc_client_1_op1_function_name = "op1_grpc_start_service"
grpc_client_1_op2_function_name = "op2_grpc_start_service"
grpc_client_1_op3_function_name = "op3_grpc_start_service"
grpc_client_1_op4_function_name = "op4_grpc_start_service"
grpc_client_1_op5_function_name = "op5_grpc_start_service"
grpc_client_1_op6_function_name = "op6_grpc_start_service"
#restful_server_1 
restful_server_1_instance_name  = "restful_server_1"
restful_server_1_tag_name       = "restful_server_1 - Ubuntu 1GB"
restful_server_1_client_install = "software_install"
#restful_ec2_blogs
restful_ec2_blogs_install_start = "blogs_start_service"
restful_ec2_blogs_port          = "3000"
#restful_ec2_posts
restful_ec2_posts_install_start = "posts_start_service"
restful_ec2_posts_port          = "3001"
#restful_ec2_invoices
restful_ec2_invoices_install_start = "invoices_start_service"
restful_ec2_invoices_port          = "3002"
#restful_ec2_products
restful_ec2_products_install_start = "products_start_service"
restful_ec2_products_port          = "3003"
#restful_ec2_users
restful_ec2_users_install_start = "users_start_service"
restful_ec2_users_port          = "3004"
#restful_ec2_cars
restful_ec2_cars_install_start = "cars_start_service"
restful_ec2_cars_port          = "3005"
#restful_ec2_database_migrate
restful_ec2_database_migrate = "database_migrate"
