# Amazon DMS infrastructure with sample SQL server databases
> Warning: This project is currently being developed and the code shouldn't be used in production.

A CloudFormation template that deploys AWS Database Migration Service (DMS) which continuously replicates data between 
AWS EC2 SQL server and Amazon RDS database.

## Requirements:
- configured AWS CLI
- configured AWS CLI profile
- installed Python package manager PIP
- S3 bucket in region where the solution will be deployed

## Usage
1. Get the solution by cloning this repository:

`$ git clone https://github.com/aws-samples/aws-dms-sql-server.git`

2. Create S3 bucket: 

`$ aws s3 mb s3://<BUCKET_NAME>/`

3. Create a `.env` file and populate it with your own values:

`$ cp main/.env.example main/.env`

4. Run the deployment script: 

`$ env $(cat  main/.env | xargs) ./main/deploy.sh`


## Limitations
- MSSQL server 2017 doesnt support continues replication. The solution is using MSSQL server 2016 by default.

## Cleanup
All the resources are deployed using CLoudFormation nested stacks. 
Deleting the main stack will delete all the resources created.
