# Pre Requisites 

## Things to do before running the project 

1. Pull the code in local system

2. Create RDS instance with postgres DB manually 

3. Create S3 bucket for manually for terraform statefile storing and replace the bucket name into terraform main.tf file

4. Create ECR registory manually which will store docker images 

## Important Pointers / Pre Requisites 

values of below variables are mentioned in .env file created in same directory if you want to run the application in local machine

````sh
DB_USER=postgres
DB_HOST=your_postgres_endpoint
DB_NAME=logs
DB_PASS=db_password
DB_PORT=5432
PORT=3000
````

Values of below variables are created in Github pipeline Secrets to use in pipeline during execution

````sh
AWS_ACCESS_KEY
AWS_ACCOUNT_ID
AWS_REGION
AWS_SECRET_KEY
TF_DB_HOST
TF_DB_NAME
TF_DB_PASS
TF_DB_PORT
TF_DB_USER
TF_PORT
````

# Create Database "logs" and Table "log" in RDS Postgres Database

```sh
    CREATE DATABASE logs;
    
    \l 

    CREATE TABLE log ( id SERIAL PRIMARY KEY, inserted_at TIMESTAMPTZ DEFAULT now() NOT NULL, json JSON NOT NULL);

    ELECT * FROM log;
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

psql -h typescript-postgresql.cd406mieqdzb.us-east-1.rds.amazonaws.com -U postgres -d logs -W
enter DB password

## To verify DB

```sh
1. list all the DB:  
    
     \l 

2. select logs DB:


    \c logs
3. Select all the rows:

    SELECT * FROM log;
```


