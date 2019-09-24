import json
import logging

import boto3

from botocore.exceptions import ClientError
from crhelper import CfnResource

logger = logging.getLogger(__name__)
helper = CfnResource(json_logging=False, log_level='DEBUG', boto_level='CRITICAL')
client = boto3.client('dms')


@helper.create
def create(event, context):
    logger.info("Got Create")

    properties = event.get('ResourceProperties', None)
    replication_task_arn = properties.get('ReplicationTaskArn')

    _create(replication_task_arn)


@helper.update
def update(event, context):
    logger.info("Got Update")


@helper.delete
def delete(event, context):
    logger.info("Got Delete")

    properties = event.get('ResourceProperties', None)
    replication_task_arn = properties.get('ReplicationTaskArn')

    client.stop_replication_task(
        ReplicationTaskArn=replication_task_arn
    )


def handler(event, context):
    helper(event, context)


def _create(replication_task_arn):
    try:
        with open('task_settings.json') as f:
            data = json.load(f)
        client.modify_replication_task(
            ReplicationTaskArn=replication_task_arn,
            ReplicationTaskSettings=json.dumps(data)
        )
    except FileNotFoundError as e:
        logger.error("Unable to load task config")
        logger.error(e)
    except ClientError as e:
        logger.error(e)
