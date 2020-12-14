## MS SQL Server - AWS Database Migration Service (DMS) Replication Demo

[![Build Status](https://github.com/aws-samples/aws-dms-sql-server/workflows/Publish%20Version/badge.svg)](https://github.com/aws-samples/aws-dms-sql-server/actions)


#### Database migration from a simulated on-premises MS SQL Server to an Amazon RDS instance in AWS Cloud

An AWS CloudFormation template that deploys AWS Database Migration Service (AWS DMS) to continuously migrate tables from an MS SQL Server database to an Amazon Relational Database Service (RDS) instance.

### Index

* [Introduction](#introduction)
* [Summary](#summary)
* [Architecture](#architecture)
* [Usage](#usage)
  * [Prerequisites](#prerequisites)
  * [Deployment](#deployment)
  * [Populating database guide](#populating-database-guide)
* [Clean up](#clean-up)
* [Contributing](#contributing)

#### Introduction

This repository demonstrates the ease of database migration from an on-premises SQL Server to an Amazon RDS instance.

Deployment of this template will create two separate "environments". The first, an Amazon EC2 instance running an MS SQL
Server represents an on-premises environment and is therefore the *source* while the second environment, an Amazon RDS SQL Server instance is the *target* for the migration.

The database is migrated using AWS DMS. It continuously synchronises changes in the "on-premises" instance with the cloud RDS instance.

#### Summary

This sample will deploy the two SQL Server instances (one EC2 and one Amazon RDS) in their own VPCs.
The SQL Server running in the EC2 instance represents the on-premises infrastructure and the Amazon RDS instance represents,
then create a sample database in both. No tables will be created at this point - creating of tables inside the database is left to the user.
A DMS migration task will also be created. Upon starting that task (eg; using console or aws cli), tables in the database will be continually replicated across from the EC2 instance to the Amazon RDS instance.

### Architecture

The AWS DMS demo uses:
* [AWS Database Migration Service (DMS)](https://aws.amazon.com/dms) to migrate and provide continuous replication of a database.
* [Amazon Relational Database Service (RDS)](https://aws.amazon.com/rds) as a target database to replicate to.
* [Amazon EC2](https://aws.amazon.com/ec2) as a source database for simulating an on-premises database server to migrate from.
* [Amazon Virtual Private Cloud](https://aws.amazon.com/vpc) to launch AWS resources in a logically isolated virtual network.

An overview of the architecture is below:

![Architecture](docs/arch_diagram.png)

### Usage

#### Prerequisites

To deploy the solution, you will require an AWS account. If you don’t already have an AWS account,
create one at <https://aws.amazon.com> by following the on-screen instructions.
Your access to the AWS account must have IAM permissions to launch AWS CloudFormation templates that create IAM roles.

#### Deployment

The application is deployed as an [AWS CloudFormation](https://aws.amazon.com/cloudformation) template.

> **Note**
You are responsible for the cost of the AWS services used while running this sample deployment. There is no additional
>cost for using this sample. For full details, see the pricing pages for each AWS service you will be using in this sample. Prices are subject to change.

1. Deploy the latest CloudFormation template by following the link below for your preferred AWS region:

|Region|Launch Template|
|------|---------------|
|**US East (N. Virginia)** (us-east-1) | [![Launch the Amazon DMS Data Replication Demo Stack with CloudFormation](docs/deploy-to-aws.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/new?stackName=aws-dms-sql-server&templateURL=https://s3.amazonaws.com/solution-builders-us-east-1/aws-dms-sql-server/latest/main.template)|
|**US West (Oregon)** (us-west-2) | [![Launch the Amazon DMS Data Replication Demo Stack with CloudFormation](docs/deploy-to-aws.png)](https://console.aws.amazon.com/cloudformation/home?region=us-west-2#/stacks/new?stackName=aws-dms-sql-server&templateURL=https://s3.amazonaws.com/solution-builders-us-west-2/aws-dms-sql-server/latest/main.template)|
|**EU (Ireland)** (eu-west-1) | [![Launch the Amazon DMS Data Replication Demo Stack with CloudFormation](docs/deploy-to-aws.png)](https://console.aws.amazon.com/cloudformation/home?region=eu-west-1#/stacks/new?stackName=aws-dms-sql-server&templateURL=https://s3.amazonaws.com/solution-builders-eu-west-1/aws-dms-sql-server/latest/main.template)|
|**EU (London)** (eu-west-2) | [![Launch the Amazon DMS Data Replication Demo Stack with CloudFormation](docs/deploy-to-aws.png)](https://console.aws.amazon.com/cloudformation/home?region=eu-west-2#/stacks/new?stackName=aws-dms-sql-server&templateURL=https://s3.amazonaws.com/solution-builders-eu-west-2/aws-dms-sql-server/latest/main.template)|
|**EU (Frankfurt)** (eu-central-1) | [![Launch the Amazon DMS Data Replication Demo Stack with CloudFormation](docs/deploy-to-aws.png)](https://console.aws.amazon.com/cloudformation/home?region=eu-central-1#/stacks/new?stackName=aws-dms-sql-server&templateURL=https://s3.amazonaws.com/solution-builders-eu-central-1/aws-dms-sql-server/latest/main.template)|
|**AP (Sydney)** (ap-southeast-2) | [![Launch the Amazon DMS Data Replication Demo Stack with CloudFormation](docs/deploy-to-aws.png)](https://console.aws.amazon.com/cloudformation/home?region=ap-southeast-2#/stacks/new?stackName=aws-dms-sql-server&templateURL=https://s3.amazonaws.com/solution-builders-ap-southeast-2/aws-dms-sql-server/latest/main.template)|

2. If prompted, login using your AWS account credentials.
1. You should see a screen titled "*Create Stack*" at the "*Specify template*" step. The fields specifying the CloudFormation
template are pre-populated. Click the *Next* button at the bottom of the page.
1. On the "*Specify stack details*" screen you may customize the following parameters of the CloudFormation stack:

|Parameter label|Default|Description|
|---------------|-------|-----------|
|Availability Zones|Requires input|The list of Availability Zones to use for the subnets in the VPCs. *Use two AZs*.|
|On premise CIDR IP|Requires input|The CIDR Allowed RDP and SQL access to the EC2 and RDS host. CIDR block parameter must be in the form x.x.x.x/0-32.|
|EC2 instance type|m5.2xlarge|The EC2 instance type for Microsoft SQL server.|
|Windows server AMI|/aws/service/ami-windows-latest/Windows_Server-2019-English-Full-SQL_2016_SP2_Standard|Query for the Latest Windows AMI Using Systems Manager Parameter Store https://aws.amazon.com/blogs/mt/query-for-the-latest-windows-ami-using-systems-manager-parameter-store/|
|MSSQL Server version|13|MSSQL Server version. This is used to Change Auth mode from Windows only to SQL and Windows Auth. For MSSQL server 2017 use number 14, for MSSQL server 2016 use number 13.|
|RDS instance type|db.m5.large|Instance class of RDS instance.|
|Database engine type|sqlserver-se|MS SQL engine type. The Enterprise, Standard, Workgroup, and Developer editions are supported. The Web and Express editions aren't supported by AWS DMS.|
|Database engine version|13.00.5216.0.v1|SQL Server 2016 SP2 (CU3) engine version13.00.5216.0, for all editions and all AWS Regions.|
|Windows server and database username|dms_user|The database and instance admin account. Minimum 5 characters must begin with a letter and contain only alphanumeric or "_".|
|Windows server and database password|Requires input|The password for instance user account. Minimum 8 characters, at least one of each of the following; uppercase, lowercase, number, and symbol character such as !@#$%^&*()<>[]{}|_+-=.|
|Database name|dms_sample|Database name.|

   When completed, click *Next*
1. [Configure stack options](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-console-add-tags.html) if desired, then click *Next*.
1. On the review you screen, you must check the boxes for:
   * "*I acknowledge that AWS CloudFormation might create IAM resources*"
   * "*I acknowledge that AWS CloudFormation might create IAM resources with custom names*"
   * "*I acknowledge that AWS CloudFormation might require the following capability: CAPABILITY_AUTO_EXPAND*"

   These are required to allow CloudFormation to create a Role to allow access to resources needed by the stack and name the resources in a dynamic way.
1. Click *Create Stack*
1. Wait for the CloudFormation stack to launch. Completion is indicated when the "Stack status" is "*CREATE_COMPLETE*".
   * You can monitor the stack creation progress in the "Events" tab.
1. Note the *EC2SQLServerEip* and *RDSSQLEndpoint* displayed in the *Outputs* tab of the main stack. This can be used to access the EC2 host and RDS instance.

### Populating database guide

[Database guide](docs/database/README.md)

### Limitations
- MSSQL server 2017 doesnt support continues replication. The solution is using MSSQL server 2016 by default.

### Clean up

To remove the stack:

1. Open the AWS CloudFormation Console
1. Click the *aws-dms-sql-server* project, right-click and select "*Delete Stack*"
1. Your stack will take some time to be deleted. You can track its progress in the "Events" tab.
1. When it is done, the status will change from DELETE_IN_PROGRESS" to "DELETE_COMPLETE". It will then disappear from the list.

## Contributing

Contributions are more than welcome. Please read the [code of conduct](CODE_OF_CONDUCT.md) and the [contributing guidelines](CONTRIBUTING.md).

## License

This sample code is made available under a modified MIT license. See the LICENSE file.
