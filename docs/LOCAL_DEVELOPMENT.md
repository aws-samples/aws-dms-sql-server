# Local Development

This section details how to run the solution locally and deploy your code changes from the command line.

### Pre-Requisites

The following dependencies must be installed:
- Python >=3.8 and pip
- virtualenv

### Build local development environment
Once you have installed pre-requisites, you must run the following command to create a `virtualenv` and install all dependencies before commencing development.

1. Create a S3 bucket
   ```
   BUCKET_NAME="your-s3-bucket-name"
   AWS_REGION="aws-region(e.g. us-east-1)"
   aws s3 mb s3://${BUCKET_NAME} --region $AWS_REGION
   ```

1. Create a `.custom.mk` file and populate it with your own values
   ```
   cp .custom.mk.example .custom.mk
   ```
1. Initialize the local environment
   ```
   make init
   ```

1. Activate `virtualenv` environment.
   ```
   source venv/bin/activate
   ```

### Deploy the stack
To deploy the solution manually from the source to your AWS account, run the following:

   ```
   make deploy
   ```

This will deploy the nested stack using the AWS CLI profile of the current shell. By default this will be the profile `default`.

### Test changes
The following command will run `pre-commit` tests. This should be run before every new commit.

```
make test
```

### Clean the virtual environment
This command will delete the virtual environment and all installed packages install via `make init`
```
make clean
```

### Delete the resources created via CloudFormation
Below command will delete deployed stack
```
make delete
```
