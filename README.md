<!-- BEGIN_TF_DOCS -->
# Creating a backend microservices architecture with Terraform and Golang. Deployment on lambda functions, EC2 instances, and Kubernetes cluster.

This repository aims to demonstrate how we can implement 3 different types of microservices in our backend projects. These 3 types of microservices are: serverless lambda functions, server-based RESTful microservices, and server-based gRPC microservices.

We will deploy the microservices on Lambda functions, EC2 instances, and Kubernetes clusters.

Follow me:

<img src="images/linkedin.png"/> https://www.linkedin.com/in/juanmanuel0963/</img>

<img src="images/architecture_diagram.png"/> </img>

We will be using AWS as our cloud platform. We will be using Golang as our programming language. Github will be our code repository. We will programmatically define the AWS infrastructure and services we will be implementing using Terraform.

We will also be using Terraform to deploy the infrastructure and functional code to the Development and Testing environments. For deploying the infrastructure and functional code to the Production environment, we will be using Jenkins.

<b>Contents</b>

<a href="#defining-deployment-environments">Defining deployment environments</a>

<a href="#defining-infrastructure-with-terraform">Defining infrastructure with Terraform</a>

<a href="#defining-network-level-security">Defining network-level security</a>

<a href="#creating-the-postgresql-database">Creating the Postgresql database</a>

<a href="#creating-the-api-gateway">Creating the API Gateway</a>

<a href="#Creating-lambda-functions">Creating lambda functions</a>

<a href="#lambda-functions-written-in-golang-contacts-insert">Lambda functions written in Golang: Contacts Insert</a>

<a href="#implementing-iam-authentication--authorization-in-lambda-functions">Implementing IAM authentication & authorization in lambda functions</a>

<a href="#testing-lambda-functions-with-postman">Testing lambda functions with Postman</a>

<a href="#creating-ec2-instance-and-configuring-restful-server">Creating EC2 Instance and configuring RESTful Server</a>

<a href="#server-based-restful-microservice-written-in-golang-on-ec2-blogs-management">Server-based RESTful microservice written in Golang on EC2: Blogs management</a>

<a href="#testing-server-based-restful-microservices-with-postman">Testing server-based RESTful microservices with Postman</a>

<a href="#creating-ec2-instances-and-configuring-grpc-client-and-server">Creating EC2 instances and configuring gRPC client and server</a>

<a href="#setting-up-grpc-server">Setting up gRPC Server</a>

<a href="#setting-up-grpc-client">Setting up gRPC Client</a>

<a href="#grpc-microservice-written-in-golang-on-ec2-users-management">gRPC microservice written in Golang on EC2: Users management</a>

<a href="#grpc-server-side-golang-code">gRPC server-side Golang code</a>

<a href="#implementing-go-routines-and-channels-in-restful-microservices">Implementing Go Routines and Channels in Restful microservices</a>

<a href="#implementing-go-routines-and-channels-in-grpc-microservices">Implementing Go Routines and Channels in gRPC microservices</a>

<a href="#cicd-through-terraform">CI/CD through Terraform</a>

<a href="#cicd-through-jenkins">CI/CD through Jenkins</a>

<a href="#creating-kubernetes-cluster">Creating Kubernetes cluster</a>

<a href="#creating-and-deploying-docker-image-to-kubernetes-cluster">Creating and deploying Docker image to Kubernetes cluster</a>

<a href="#setting-up-tls-certificates-for-the-microservices-deployed-in-kubernetes-pods">Setting up TLS certificates for the microservices deployed in Kubernetes Pods</a>

<a href="#designing-and-documenting-apis-wih-openapi-and-swagger">Designing and documenting APIs wih OpenAPI and Swagger</a>


-----------------------------

## Defining deployment environments
For our project, we will define 3 types of environments: Development, Testing, and Production. Previously, we should have created 3 independent accounts within our Organization.

The creation of the Organization and the creation of Accounts are outside the scope of this guide.

## Defining infrastructure with Terraform
The backbone for creating infrastructure resources is the <a href="main.tf" target="_blank">main.tf</a> file, which is located in the root folder. This file in turn refers to sub-files with specific content for configuring and creating resources. Configuration variables are located in the <a href="terraform.tfvars" target="_blank">terraform.tfvars</a> file.

## Defining network-level security
Within each account/environment, we will specify the availability zone we want to use. Within the default assigned Virtual Private Network, we will create a Security Group. 
This Security Group will allow us to define the inbound and outbound rules we need to interact with our infrastructure resources, such as Databases or EC2 instances.

<a href="main.tf" target="_blank">main.tf</a>
 
<img src="images/networking.png"/>

<a href="networking/terraform/main.tf" target="_blank">networking/terraform/main.tf</a>

<img src="images/networking_resources.png"/>

## Creating the Postgresql database
We create the database within the same Security Group defined earlier. The configuration parameters, such as machine type, instance type, and allocated memory space, are brought from the terraform.tfvars file.

<a href="main.tf" target="_blank">main.tf</a>

<img src="images/postgresql.png"/>

<a href="db_postgresql/terraform/main.tf" target="_blank">db_postgresql/terraform/main.tf</a>

<img src="images/postgresql_resources.png"/>

<a href="terraform.tfvars" target="_blank">terraform.tfvars</a>

<img src="images/postgresql_variables.png"/>

Once Terraform has created the initial server and database, we create the "Companies" and "Contacts" tables, as well as the functions to perform CRUD operations on these tables. We do this by executing some sql scripts using a database IDE such as PgAdmin.

<a href="db_postgresql/source_code" target="_blank">db_postgresql/source_code</a>

<img src="images/companies_contacts.png"/>

<img src="images/companies_insert_1.png"/>

<img src="images/companies_insert_2.png"/>

<img src="images/companies_insert_3.png"/>

We will use GORM for database resources definition when creating RESTful microservices and gRPC microservices.

## Creating the API Gateway
The API Gateway will allow us to access a collection of microservices under the same domain name. In this project, the API Gateway will give us access to lambda functions to perform CRUD operations on a Contacts table.

<a href="main.tf" target="_blank">./main.tf</a>

<img src="images/api_gateway.png"/>

<a href="api_gateway/terraform/main.tf" target="_blank">api_gateway/terraform/main.tf</a>

<img src="images/api_gateway_resources.png"/>


## Creating lambda functions
The next step is to create the lambda functions and associate them with the API Gateway we just created. We are going to create several functions int Golang to perform CRUD operations, as well as more specialized functions to perform searches through dynamic filters or paginated searches. The lambda functions that we will create and associate with the API Gateway are as follows:

&#x2022; contacts insert

&#x2022; contacts get by company id

&#x2022; contacts get by contact id

&#x2022; contacts delete by contact id

&#x2022; contacts update by contact id

&#x2022; contacts get by dynamic filter

&#x2022; contacts get by pagination

As always, everything starts with the main.tf file located in the root folder.

<a href="main.tf" target="_blank">main.tf</a>

<img src="images/contacts_insert.png"/>

<a href="microservices_restful_lambda/contacts_insert/terraform/main.tf" target="_blank">microservices_restful_lambda/contacts_insert/terraform/main.tf</a>

<img src="images/contacts_insert_resources_1.png"/>

We use S3 buckets so that Terraform can upload the compiled executable code in a zip file and then migrate it to the lambda function. 

Previously, we must have compiled the source code into an executable file for the target operating system, in this case Linux.

We can compile the code into an executable file by invoking the following commands:

--before build binary to upload to AWS

    $Env:GOOS = "linux" 

--build

    go build main.go


<img src="images/contacts_insert_resources_2.png"/>

<img src="images/contacts_insert_resources_3.png"/>

<img src="images/contacts_insert_resources_4.png"/>


## Lambda functions written in Golang: Contacts Insert

You can find the source code of the contacts insert function written in Golang in the following path:

<a href="microservices_restful_lambda/contacts_insert/source_code/main.go" target="_blank">microservices_restful_lambda/contacts_insert/source_code/main.go</a>

We add the libraries we will need to the import section. 

We define the "Contact" structure to obtain the data that is sent to the lambda function to later extract and insert it into the database

Likewise, we define the "ResponseBody" structure which will be returned by the lambda function informing the status of the transaction and the "Contact" with the new created Id.

<img src="images/contacts_insert_function_1.png"/>

The main() function is the entry point of the lambda function. However, it delegates the responsibility of processing by invoking the FunctionHandler handler. 

The first step that our handler performs is to obtain the message body and extract the data from the "Contact".

At certain control points, the function's execution sequence is logged in CloudWatch. If an error occurs, the details of the generated exception are recorded.

<img src="images/contacts_insert_function_2.png"/>

The next thing we do is to verify that the connection to the database is working properly.

<img src="images/contacts_insert_function_3.png"/>

We insert the data of the "Contact" into the database. In this example, we invoke a Postgresql database function.

<img src="images/contacts_insert_function_4.png"/>

Finally, the response body is prepared. The response is sent first to the API Gateway, which in turn returns a response to the client.

<img src="images/contacts_insert_function_5.png"/>

## Implementing IAM authentication & authorization in lambda functions

In order to allow only authorized clients to execute calls on our lambda functions, we previously added the function to the API Gateway in Terraform and indicated that the authorization type is "AWS_IAM".

<a href="microservices_restful_lambda/contacts_insert/source_code/main.go" target="_blank">microservices_restful_lambda/contacts_insert/source_code/main.go</a>

<img src="images/contacts_insert_resources_5.png"/>

Once Terraform is executed, the following should appear in AWS:

<img src="images/contacts_insert_resources_6.png"/>

Now we can create an IAM user with an associated policy that allows them to execute APIs.

<img src="images/contacts_insert_auth_1.png"/>

<img src="images/contacts_insert_auth_2.png"/>

<img src="images/contacts_insert_auth_3.png"/>

This IAM user must be used as the authorization header in calls to the function.

## Testing lambda functions with Postman

In the following image, an example of a contacts_insert function invocation in Postman is shown. "AWS Signature" is specified as the authorization type, and the AccessKey and SecretKey created in IAM are entered.

<img src="images/contacts_insert_auth_4.png"/>

<img src="images/contacts_insert_auth_5.png"/>

## Creating EC2 instance and configuring RESTful Server

Inside our RESTful server, we will have hosted 4 microservices with the following functions.

<b>Blogs</b>

&#x2022; blog create

&#x2022; blog list

&#x2022; blog get by id

&#x2022; blog update by id

&#x2022; blog delete by id

<b>Posts</b>

&#x2022; post create

&#x2022; post list

&#x2022; post get by id

&#x2022; post get by blog id

&#x2022; post get by dynamic filter

&#x2022; post get by pagination

&#x2022; post update by id

&#x2022; post delete by id

<b>Products</b>

&#x2022; product create

&#x2022; product list

&#x2022; product get by id

&#x2022; product get by invoice id

&#x2022; product update by id

&#x2022; product delete by id

<b>Invoices</b>

&#x2022; Invoice create

&#x2022; invoice list

&#x2022; invoice get by id

&#x2022; invoice update by id

&#x2022; invoice delete by id

We will create an EC2 instance to expose RESTful microservices using the following Terraform instructions.

<a href="main.tf" target="_blank">main.tf</a>

<img src="images/restful_server_1.png"/>

<a href="ec2/grpc_instance/terraform/main.tf" target="_blank">ec2/grpc_instance/terraform/main.tf</a>

<img src="images/restful_server_2.png"/>

The configuration parameters that we will use for the EC2 instance are found in the variables file.

<a href="terraform.tfvars" target="_blank">terraform.tfvars</a>

<img src="images/restful_server_3.png"/>

We create an EventBridge rule of type "Schedule"/"Run Command".

<a href="main.tf" target="_blank">main.tf</a>

<img src="images/restful_server_4.png"/>

This rule executes a cron job periodically. This EventBridge rule is responsible for downloading and installing from Github the latest updated version of the executable Golang code for the RESTful microservices.
This EventBridge rule is also responsible for generating a self-signed TLS certificate, in order to serve requests securely.

<a href="microservices_grpc_ec2/usermgmt_op1_no_persistence/eventbridge_client_install/terraform/main.tf" target="_blank">microservices_grpc_ec2/usermgmt_op1_no_persistence/eventbridge_client_install/terraform/main.tf</a>

<img src="images/restful_server_5.png"/>

Once we have the executable code installed, the next step is to start the service that will allow us to invoke the microservices from anywhere on the internet. For this, we start a GIN server for each microservice.

<img src="images/restful_server_6.png"/>

## Server-based RESTful microservice written in Golang on EC2: Blogs management

Our Blog management microservice is implemented using the model-view-controller pattern.

The init() function initializes the connection to the Postgres database using the GORM connection driver.  

At the beginning of the main() function, the routes for invoking each of the microservice functions and the controller function responsible for each function are specified. 

The microservice is initialized on the GIN web server on a specific port and requires a TLS security certificate, which is generated and self-signed by the application itself.

<a href="microservices_restful_ec2/blogs/source_code/main.go" target="_blank">microservices_restful_ec2/blogs/source_code/main.go</a>

<img src="images/restful_blogs_1.png"/>

<a href="microservices_restful_ec2/_database/initializers/db_conn.go" target="_blank">microservices_restful_ec2/_database/initializers/db_conn.go</a>

<img src="images/restful_blogs_2.png"/>

<a href="microservices_restful_ec2/blogs/source_code/controllers/blog_controller.go" target="_blank">microservices_restful_ec2/blogs/source_code/controllers/blog_controller.go</a>

<img src="images/restful_blogs_3.png"/>

The VerifyToken() function extracts the token sent by the client and makes a connection to the jwt Cognito authentication service created previously for our application. If the token is valid, the execution flow continues normally. If the token is not valid, the client cannot be authenticated and therefore cannot invoke the requested function.

<a href="cognito/auth_token/source_code/verify_token/verify_token.go" target="_blank">cognito/auth_token/source_code/verify_token/verify_token.go</a>

<img src="images/restful_blogs_4.png"/>

<img src="images/restful_blogs_5.png"/>

We can start the service by running the following command. However, this command is executed directly by Terraform through an Eventbridge rule as indicated earlier.

    sudo --preserve-env ./main

## Testing server-based RESTful microservices with Postman

Now that the server-side gRPC microservice is up and listening on the specified port we can test connectivity with Postman.

The following image shows an example of an invocation in Postman to the function blog_create. As seen before, the microservice requires authentication with AWS jwt Cognito. In this case, no authentication function is specified. As a response, the function sends an "Unauthorized" message.

<img src="images/restful_blogs_test_1.png"/>

In the following image, we see an example of an invocation of the blog_create function. In this case, we obtain and specify an AWS jwt Cognito token. 

<img src="images/restful_blogs_test_2.png"/>

As a response, we get the ID and creation date of the blog. You can see that HTTPS was used to invoke the function. This is possible because the microservice generates a self-signed TLS security certificate.

<img src="images/restful_blogs_test_3.png"/>

## Creating EC2 instances and configuring gRPC client and server

We will create a pair of EC2 instances in order to implement a client-server gRPC microservice architecture.

The microservice will contain the following 5 functions with different strategies for user creation and data persistence.

&#x2022; Sending client data to server without persistence function.

&#x2022; Sending client data to server with in-memory persistence.

&#x2022; Sending client data to server with JSON file persistence.

&#x2022; Sending client data to server with Postgresql database persistence.

&#x2022; Sending data from RESTful function to client and from client to server with Postgresql database persistence.

## Setting up gRPC Server

We will create an EC2 instance to expose gRPC server-side microservices using the following Terraform instructions.

<a href="main.tf" target="_blank">main.tf</a>

<img src="images/grpc_server_1.png"/>

<a href="ec2/grpc_instance/terraform/main.tf" target="_blank">ec2/grpc_instance/terraform/main.tf</a>

<img src="images/grpc_server_2.png"/>

We create an EventBridge rule of type "Schedule"/"Run Command".

<a href="main.tf" target="_blank">main.tf</a>

<img src="images/grpc_server_3.png"/>

This rule executes a cron job periodically. This EventBridge rule is responsible for downloading and installing from Github the latest updated version of the executable Golang code for the gRPC microservice.

<a href="microservices_grpc_ec2/usermgmt_op1_no_persistence/eventbridge_server_install/terraform/main.tf" target="_blank">microservices_grpc_ec2/usermgmt_op1_no_persistence/eventbridge_server_install/terraform/main.tf</a>

<img src="images/grpc_server_4.png"/>

The next step is to start the services for each of the gRPC server-side functions. We do this by executing an EventBridge rule of type "Schedule" / "Run Command". 

<img src="images/grpc_server_5.png"/>

This rule runs a cron job periodically to ensure that the service is always active.

<img src="images/grpc_server_6.png"/>

## Setting up gRPC Client

We will create an EC2 instance to expose gRPC client-side microservices using the following Terraform instructions.

<a href="main.tf" target="_blank">main.tf</a>

<img src="images/grpc_client_1.png"/>

<a href="ec2/grpc_instance/terraform/main.tf" target="_blank">ec2/grpc_instance/terraform/main.tf</a>

<img src="images/grpc_client_2.png"/>

We create an EventBridge rule of type "Schedule"/"Run Command".

<a href="main.tf" target="_blank">main.tf</a>

<img src="images/grpc_client_3.png"/>

This rule executes a cron job periodically. This EventBridge rule is responsible for downloading and installing from Github the latest updated version of the executable Golang code for the gRPC microservice. This EventBridge rule is also responsible for generating a self-signed TLS certificate, in order to serve requests securely.

<a href="microservices_grpc_ec2/usermgmt_op1_no_persistence/eventbridge_client_install/terraform/main.tf" target="_blank">microservices_grpc_ec2/usermgmt_op1_no_persistence/eventbridge_client_install/terraform/main.tf</a>

<img src="images/grpc_client_4.png"/>

The next step is to start the services for each of the gRPC client-side functions. We do this by executing an EventBridge rule of type "Schedule" / "Run Command". 

<img src="images/grpc_client_5.png"/>

This rule runs a cron job periodically to ensure that the service is always active.

<img src="images/grpc_client_6.png"/>

## gRPC microservice written in Golang on EC2: Users management

## gRPC server-side Golang code

We add the necessary libraries to the import section. Specify the port on which the gRPC server-side microservice will be running. Create a structure with the variables we will need, such as the connection to the database and the user management proto buffer. Initialize the database connection using the GORM driver.

<a href="microservices_grpc_ec2/usermgmt_op4_db_postgres/usermgmt_server/usermgmt_server.go" target="_blank">microservices_grpc_ec2/usermgmt_op4_db_postgres/usermgmt_server/usermgmt_server.go</a>

<img src="images/grpc_server_code_1.png"/>

The main() function initializes the variables of the structure and starts the service to run on the specified port.

<img src="images/grpc_server_code_2.png"/>

Our gRPC user management microservice contains a function to create users. 

<img src="images/grpc_server_code_3.png"/>

We can start up the service by executing the following command. However, this command is executed directly by Terraform through an Eventbridge rule as indicated earlier.

    sudo --preserve-env ./usermgmt_server

Now that the microservice is up and listening on the specified port, we can start the client service and send requests to the server.

## gRPC client-side Golang code

We add the necessary libraries to the "import" section, including the user management proto buffer.

<a href="microservices_grpc_ec2/usermgmt_op4_db_postgres/usermgmt_client/usermgmt_client.go" target="_blank">microservices_grpc_ec2/usermgmt_op4_db_postgres/usermgmt_server/usermgmt_server.go</a>

The main() function is responsible for establishing a connection with the server.

<img src="images/grpc_client_code_1.png"/>

For the purpose of the example, it creates a user and invokes the CreateNewUser function on the server.

We can invoke the client service by executing the following command. However, this command is executed directly by Terraform through an Eventbridge rule as indicated earlier.

    sudo --preserve-env ./usermgmt_client

The server responds with the Id of the newly created user.

The user is created in the database with a name and age.

<img src="images/grpc_client_code_2.png"/>

Since the EventBridge rule is executed every minute, we see that a new user has been created in the Postgresql database every minute.

## 	Implementing Go Routines and Channels in Restful microservices

Next, we will create a Restful microservice that will handle user management operations. 
We will implement this microservice using Go Routines and Channels in order to take advantage of parallel request processing.

We define the entry points for each of the operations.

<a href="microservices_restful_ec2/users/source_code/main.go" target="_blank">microservices_restful_ec2/users/source_code/main.go</a>

<img src="images/restful_chan_1.png"/>

<a href="microservices_restful_ec2/users/source_code/controllers/createUser.go" target="_blank">microservices_restful_ec2/users/source_code/controllers/createUser.go</a>

<a href="microservices_restful_ec2/users/source_code/controllers/deleteUserById.go" target="_blank">microservices_restful_ec2/users/source_code/controllers/deleteUserById.go</a>

<a href="microservices_restful_ec2/users/source_code/controllers/getAllUsers.go" target="_blank">microservices_restful_ec2/users/source_code/controllers/getAllUsers.go</a>

<a href="microservices_restful_ec2/users/source_code/controllers/getUserById.go" target="_blank">microservices_restful_ec2/users/source_code/controllers/getUserById.go</a>

<a href="microservices_restful_ec2/users/source_code/controllers/updateUserById.go" target="_blank">microservices_restful_ec2/users/source_code/controllers/updateUserById.go</a>

Within each operation, we implement a call to a Go Routine that returns 2 channels. 

One channel is used to return a successful response, for example, a user successfully created in the database. 

The second response channel is used to return an error if there is any.

<img src="images/restful_chan_2.png"/>

<img src="images/restful_chan_3.png"/>

<img src="images/restful_chan_4.png"/>

## 	Implementing Go Routines and Channels in gRPC microservices

Next, we are going to build a gRPC microservice that can be accessed as if it were a Restful service. 

This microservice will be responsible for receiving data from a client and creating a user and a contact in the database. 

<img src="images/grpc_chan_1.png"/>

<a href="microservices_grpc_ec2/usermgmt_op6_rest_to_grpc_chan/usermgmt_client/usermgmt_client.go" target="_blank">microservices_grpc_ec2/usermgmt_op6_rest_to_grpc_chan/usermgmt_client/usermgmt_client.go</a>

<a href="microservices_grpc_ec2/usermgmt_op6_rest_to_grpc_chan/controllers/usermgmt_client_controller.go" target="_blank">microservices_grpc_ec2/usermgmt_op6_rest_to_grpc_chan/controllers/usermgmt_client_controller.go</a>

<a href="microservices_grpc_ec2/usermgmt_op6_rest_to_grpc_chan/usermgmt_server/usermgmt_server.go" target="_blank">microservices_grpc_ec2/usermgmt_op6_rest_to_grpc_chan/usermgmt_server/usermgmt_server.go</a>

To accomplish this task, we will implement two Go Routines, one for creating the user and another for creating the contact. 

<img src="images/grpc_chan_2.png"/>

Each Go Routine will return two channels: one channel to return the created user or contact, and another channel to return an error if necessary.

<img src="images/grpc_chan_3.png"/>

The gRPC client sends the data to the gRPC server, which in turn is responsible for creating the user and contact in the database. 

<img src="images/grpc_chan_4.png"/>

The gRPC server also implements Go Routines and Channels to make the processing more efficient.

<img src="images/grpc_chan_5.png"/>

<img src="images/grpc_chan_6.png"/>

## 	CI/CD through Terraform

Below you will find the steps to make infrastructure and executable code changes in the "Dev" and "Test" environments in AWS using the command line and Terraform.

Before running the deployment, we must build the executable files for each of the microservices. We do this by executing steps 1 to 3.

Step 1: Delete executable files. 

<a href="step_1_delete_exe_files.cmd" target="_blank">step_1_delete_exe_files.cmd</a>

Step 2: Build RESTful executables. 

<a href="step_2_build_rest_executables.cmd" target="_blank">step_2_build_rest_executables.cmd</a>

Step 3: Build gRPC executables. 

<a href="step_3_build_grpc_executables.cmd" target="_blank">step_3_build_grpc_executables.cmd</a>

Step 4: Upload files to Github.

Once the code is compiled, we must upload the changes to the Github repository.

Step 5: Deploy to Dev environment. 

<a href="step_5_deploy_dev.cmd" target="_blank">step_5_deploy_dev.cmd</a>

    ::AWS authentication - Dev Environment-------------

    set AWS_PROFILE=dev
    
    ::--------Terraform - Infrastructure setup-------------
    
    terraform workspace new dev
    
    terraform workspace select dev
    
    terraform workspace list
    
    terraform init
    
    terraform validate
    
    terraform plan -var db_password="your_password" -out "output_plan_dev.tfplan"
    
    terraform apply -auto-approve "output_plan_dev.tfplan"

After a few minutes of execution, we get confirmation that the changes were successfully executed.

<img src="jenkins-config/jenkins-6.jpg"/>

Step 6: Deploy to Test environment. 

Right after deploying to the "Development" environment, you can execute the deployment to the "Test" environment by running step 6.

<a href="step_6_deploy_test.cmd" target="_blank">step_6_deploy_test.cmd</a>

    ::AWS authentication - Test Environment-------------

    set AWS_PROFILE=test
    
    ::--------Terraform - Infrastructure setup-------------
    
    terraform workspace new test
    
    terraform workspace select test
    
    terraform workspace list
    
    terraform init
    
    terraform validate
    
    terraform plan -var db_password="your_password" -out "output_plan_tools.tfplan"
    
    terraform apply -auto-approve "output_plan_tools.tfplan"

## 	CI/CD through Jenkins

With the following configuration in Jenkins, we can create a new pipeline to execute the deployment of the infrastructure we have created in Terraform and the executable Golang code of our Lambda, RESTful, and gRPC microservices.

<img src="jenkins-config/jenkins-0.jpg"/>

Our Jenkins pipeline is responsible for downloading the latest version of Terraform and Golang code from the Github repository. Then it connects to the AWS cloud using the access credentials that we have previously configured in AWS.

<img src="jenkins-config/jenkins-1.jpg"/>

<img src="jenkins-config/jenkins-2.jpg"/>

<img src="jenkins-config/jenkins-3.jpg"/>

We save the AWS access credentials as Jenkins credentials.

<img src="jenkins-config/access_keys.jpg"/>

We manually run the "Pipeline". It can also be configured to run periodically at the interval of our preference.

<img src="jenkins-config/jenkins-4.jpg"/>

After a few minutes of execution, we get confirmation that the changes were successfully executed.

<img src="jenkins-config/jenkins-5.jpg"/>

## 	Creating Kubernetes cluster

Next, we are going to create the Kubernetes infrastructure described in the following image using Terraform.

The Terraform instructions are located in the file <a href="main.tf" target="_blank">main.tf</a>.

<img src="images/architecture_diagram_kubernetes.png"/>


VPC

We will start creating our Kubernetes infrastructure by defining a new VPC. All the other Kubernetes resources we create next will exist within the VPC.

<img src="images/k8s_vpc.png"/>

Internet Gateway

<img src="images/k8s_gateway.png"/>

Subnets

<img src="images/k8s_subnets.png"/>

Public IPs

<img src="images/k8s_ips.png"/>

NAT Gateways

<img src="images/k8s_nat_gateway.png"/>

Routing Tables

<img src="images/k8s_routing_tables.png"/>

Route Table Association

<img src="images/k8s_route_table_association.png"/>

Kubernetes Cluster

<img src="images/k8s_kubernetes_cluster.png"/>

Node Groups

<img src="images/k8s_node_groups.png"/>

Container Registry

<img src="images/k8s_container_registry.png"/>

## 	Creating and deploying Docker image to Kubernetes cluster

In the following executable file, you will find step-by-step instructions to compile locally the Docker image and publish it to the Kubernetes cluster just created.

<a href="step_8_deploy_k8s_blogs_dev.cmd" target="_blank">step_8_deploy_k8s_blogs_dev.cmd</a>

Below is the step-by-step execution of the instructions.

Compiling microservices source code

<img src="images/k8s-deployment-1.png"/>

Cleaning up Docker images

<img src="images/k8s-deployment-2.png"/>

Building Docker image

Docker file with instructions for image building can be found here: <a href="microservices_kubernetes/blogs/Dockerfile" target="_blank">Dockerfile</a>

<img src="images/k8s-deployment-3.png"/>

Tagging Docker image. Connecting to AWS Kubernetes. Pushing Docker image to AWS Container Registry

<img src="images/k8s-deployment-4.png"/>

Updating .kube/config.json. Deleting current Kubernetes namespace. Creating namespace

<img src="images/k8s-deployment-5.png"/>

Applying kubernetes configuration file. 

In the following Kubernetes configuration file, you will find step-by-step instructions for services creation from Docker image stored in the Amazon Container Registry.

<a href="microservices_kubernetes/k8s_deployment/blogs_app.yaml" target="_blank">blogs_app.yaml</a>

<img src="images/k8s-deployment-6.png"/>

Getting list of PODs and Services created

<img src="images/k8s-deployment-7.png"/>

Testing Kubernetes services

In the following images, we can verify that the URL used to invoke the microservices is the same "EXTERNAL-IP" automatically generated for the "external-blog-app-service" service. Furthermore, this is the same URL generated for the external load balancer.

Listing Blogs

<img src="images/k8s-testing-1.png"/>

Quering by Blog Id

<img src="images/k8s-testing-2.png"/>

## 	Setting up TLS certificates for the microservices deployed in Kubernetes Pods.

In order to securely invoke the deployed microservices in Kubernetes Pods, we are going to implement TLS certificates at the load balancer level. 

We can generate self-signed TLS certificates locally using the following golang instruction.

Windows

go run 'C:\Program Files\Go\src\crypto\tls\generate_cert.go' -rsa-bits 2048 -host localhost

Linux

go run /usr/local/go/src/crypto/tls/generate_cert.go -rsa-bits 2048 -host localhost

On the AWS Certificate Manager we will import the self-signed certificate that have been created previously.

<img src="images/k8s-ssl-2.png"/>

<img src="images/k8s-ssl-3.png"/>

We must modify the Kubernetes deployment file <a href="microservices_kubernetes/k8s_deployment/blogs_app.yaml" target="_blank">blogs_app.yaml</a>. We add the following lines highlighted in yellow:

<img src="images/k8s-ssl-1.png"/>

The value assigned to the "service.beta.kubernetes.io/aws-load-balancer-ssl-cert" key is taken from the ARN of the external service's load balancer.

<img src="images/k8s-ssl-4.png"/>

In the following images, we can verify that the microservices are invoked via HTTPS and respond successfully to list all the blogs and to query a specific blog.

<img src="images/k8s-ssl-5.png"/>

The microservice's URL corresponds to the DNS name of the external load balancer.

<img src="images/k8s-ssl-6.png"/>

## 	Designing and documenting APIs wih OpenAPI and Swagger 

OpenAPI allows us to follow an "API-first design" approach. Through a configuration file, we can define the types of verbs to be executed (POST, GET, PUT, DELETE), as well as the request and response body parameters.

<a href="microservices_restful_ec2/cars/api_design/cars-api.yaml" target="_blank">View the OpenAPI design file</a>

<img src="images/openapi-1.png"/>

Once we have finished defining the OpenAPI configuration file, we can open it in Swagger format in order to generate the API documentation.

<a href="http://cars-api-golang.s3-website-us-east-1.amazonaws.com/" target="_blank">View online the Cars API Swagger documentation</a>

<img src="images/openapi-2.png"/>


