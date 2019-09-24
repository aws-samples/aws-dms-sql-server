#!/usr/bin/env bash
for fn in custom-resource/*; do
  printf "\n--> Installing %s requirements...\n" ${fn}
  pip install crhelper -t ${fn}
done

printf "\n--> Packanging and uploading templates to S3...\n"

aws cloudformation package \
  --template-file main/main.template \
  --s3-bucket ${BUCKET_NAME} \
  --output-template-file main/main-packaged.template

printf "\n--> Deploying %s template...\n" ${STACK_NAME}

aws cloudformation deploy \
  --template-file main/main-packaged.template \
  --stack-name ${STACK_NAME} \
  --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND \
  --region ${REGION} \
  --parameter-overrides \
  AvailabilityZones=${REGION}a,${REGION}b \
  OnPremCidr=${ON_PREM_CIDR} \
  Username=${USER_NAME} \
  UserPassword=${USER_PASSWORD}

EC2_EIP=$(aws cloudformation describe-stacks \
  --stack-name ${STACK_NAME} \
  --query "Stacks[0].Outputs[?OutputKey=='EC2SQLServerEip'].OutputValue" \
  --output text)

RDS_ENDPOINT=$(aws cloudformation describe-stacks \
  --stack-name ${STACK_NAME} \
  --query "Stacks[0].Outputs[?OutputKey=='RDSSQLEndpoint'].OutputValue" \
  --output text)

printf "\n--- Outputs ---"
printf "\n--> EC2SQL Elastic IP: %s" ${EC2_EIP}
printf "\n--> RDS Endpoint: %s\n" ${RDS_ENDPOINT}
