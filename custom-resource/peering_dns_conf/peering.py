import logging

import boto3

from crhelper import CfnResource

logger = logging.getLogger(__name__)
helper = CfnResource(json_logging=False, log_level='DEBUG', boto_level='CRITICAL')
client = boto3.client('ec2')


@helper.create
def create(event, context):
    logger.info("Got Create")

    properties = event.get('ResourceProperties', None)
    vpc_peering_connection_id = properties.get('VpcPeeringConnectionId')

    client.modify_vpc_peering_connection_options(
        AccepterPeeringConnectionOptions={
            'AllowDnsResolutionFromRemoteVpc': True
        },
        RequesterPeeringConnectionOptions={
            'AllowDnsResolutionFromRemoteVpc': True
        },
        VpcPeeringConnectionId=vpc_peering_connection_id
    )
    return helper.PhysicalResourceId


@helper.update
def update(event, context):
    logger.info("Got Update")


@helper.delete
def delete(event, context):
    logger.info("Got Delete")


def handler(event, context):
    helper(event, context)
