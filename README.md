# Pre Requisites 

## Things to do before running the project 

1. Pull the code in local system and create .env and terraform.tfvars file with required value

#### .env file
````sh
DB_USER=postgres
DB_HOST=<RDS instance Endpoint>
DB_NAME=logs
DB_PASS=<your_db_password>
DB_PORT=5432
PORT=3000
````
#### terraform.tvvars file
````sh
aws_account_id = "445567088716"
aws_region     = "us-east-1"
db_user     = "postgres"
db_password = <your_db_password>
db_name     = "logs"
db_port     = "5432"
port        = "3000"
````
2. Create S3 bucket for manually for terraform statefile storing and replace the bucket name into terraform main.tf file

3. Create ECR registory manually which will store docker images 

## Important Pointers 

Below mentioned Values need to be added into Github pipeline Secrets to use in pipeline during execution

````sh
AWS_ACCESS_KEY
AWS_ACCOUNT_ID
AWS_REGION
AWS_SECRET_KEY
TF_DB_NAME
TF_DB_PASS
TF_DB_PORT
TF_DB_USER
TF_PORT
````
# Run the application manually
    npx ts-node src/server.ts

# Test the application  in postman 

## Steps:

    1. Open Postman → Click New Request.
    2. Set Method = POST.
    3. Enter the URL:
        For local testing: http://localhost:3000/log
    4. Click on Body → raw → JSON.
        Enter JSON data:

        {
        "json_data": {
            "message": "Hello, this is a test log",
            "level": "info"
            }
        }

    5. Click Send.
    6. Set Method = Get
    7. Enter the URL:
        For local testing: http://localhost:3000/logs
    8. Click Send.


# Test Data in Database:
````sh
psql -h <RDS_Endpoint> -U postgres -d logs -W
enter DB password
````
## To verify DB

```sh
1. list all the DB:  
     \l 
2. select logs DB:
    \c logs
3. Select all the rows:
    SELECT * FROM log;
```


# Install Node.js and TypeScript
1.	Install Node.js (LTS)
2.	npm install -g typescript
3.	tsc -v
4.	mkdir TypeScript-Backend && cd TypeScript-Backend
5.	tsc  - - init
6.	npm install express pg dotenv cors helmet morgan
7.	npm install --save-dev typescript ts-node @types/node @types/express @types/cors @types/morgan nodemon @types/pg
8.	Config file correction
````sh
{
  "compilerOptions": {
    "target": "ES6",
    "module": "CommonJS",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true
  }
}
````