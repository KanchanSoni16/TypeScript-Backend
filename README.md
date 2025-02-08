# Pull the code in local system

# Create RDS instance with postgres DB

# Create Database "logs" and Table "log"

1. CREATE DATABASE logs;
2.	\l 
3.	CREATE TABLE log (
    id SERIAL PRIMARY KEY,
    inserted_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    json JSON NOT NULL
);
4.	SELECT * FROM log;


# Run the application 
    npx ts-node src/server.ts

# Test the application  in postman 

## Steps:

    1. Open Postman → Click New Request.
    2. Set Method = POST.
    3. Enter the URL:
        For local testing: http://localhost:3000/log
        For deployed AWS ECS: http://your-ecs-load-balancer.amazonaws.com/log
    4. Click on Body → raw → JSON.
        Enter JSON data:

        {
        "json_data": {
            "message": "Hello, this is a test log",
            "level": "info"
            }
        }
        
    5. Click Send.