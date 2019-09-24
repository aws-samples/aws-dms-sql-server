import json
import logging

import boto3

from crhelper import CfnResource

logger = logging.getLogger(__name__)
helper = CfnResource(json_logging=False, log_level='DEBUG', boto_level='CRITICAL')
client = boto3.client('iam')

dms_vpc_role = 'dms-vpc-role'
dms_cloudwatch_logs_role = 'dms-cloudwatch-logs-role'
dms_access_for_endpoint = 'dms-access-for-endpoint'
dms_vpc_policy_arn = 'arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole'
dms_cloudwatch_logs_policy_arn = 'arn:aws:iam::aws:policy/service-role/AmazonDMSCloudWatchLogsRole'
dms_access_for_endpoint_policy_arn = 'arn:aws:iam::aws:policy/service-role/AmazonDMSRedshiftS3Role'

dms_assume_role_policy_01 = {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "dms.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}

dms_assume_role_policy_02 = {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "dms",
            "Effect": "Allow",
            "Principal": {
                "Service": "dms.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        },
        {
            "Sid": "redshift",
            "Effect": "Allow",
            "Principal": {
                "Service": "redshift.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}


@helper.create
def create(event, context):
    logger.info("Got Create")

    roles = [
        (dms_vpc_role, dms_vpc_policy_arn, dms_assume_role_policy_01),
        (dms_cloudwatch_logs_role, dms_cloudwatch_logs_policy_arn, dms_assume_role_policy_01),
        (dms_access_for_endpoint, dms_access_for_endpoint_policy_arn, dms_assume_role_policy_02)
    ]
    for role_name, policy_arn, assume_role_policy in roles:
        if not _check_role(role_name):
            _create_role(role_name, policy_arn, assume_role_policy)


@helper.update
def update(event, context):
    logger.info("Got Update")


@helper.delete
def delete(event, context):
    logger.info("Got Delete")


def handler(event, context):
    helper(event, context)


def _check_role(role_name):
    logger.info("Checking if the {} role exists...".format(role_name))

    try:
        client.get_role(
            RoleName=role_name
        )
        return True
    except client.exceptions.NoSuchEntityException as e:
        logger.error(e)
        return False


def _create_role(role_name, policy_arn, assume_role_policy):
    logger.info("Creating role {} ...".format(role_name))

    client.create_role(
        Path='/',
        RoleName=role_name,
        AssumeRolePolicyDocument=json.dumps(assume_role_policy),
        Description='IAM role for AWS DMS'
    )

    logger.info("Attaching {} policy ...".format(policy_arn))
    client.attach_role_policy(
        RoleName=role_name,
        PolicyArn=policy_arn
    )
