"""
version: 1.0.2
"""

import json

import boto3
from mypy_boto3_ssm import SSMClient
from mypy_boto3_s3 import S3Client

from dataclasses import dataclass

from typing import Any, Callable

from urllib.parse import unquote_plus

from aws_lambda_powertools.utilities.data_classes import S3Event, event_source

from aws_lambda_powertools import Logger


@dataclass
class TfstateKey:
    repository: str
    environment: str

    def __str__(self) -> str:
        return f"{self.repository}/{self.environment}"


def get_logger() -> Callable[[], Logger]:
    logger = Logger(service="tfstate-output-store")
    return lambda: logger


def get_ssm_client() -> Callable[[], SSMClient]:
    ssm_client = boto3.client("ssm")
    return lambda: ssm_client


def get_s3_client() -> Callable[[], S3Client]:
    s3_client = boto3.client("s3")
    return lambda: s3_client


def read_tfstate_from_s3(
    s3_client: S3Client, bucket_name: str, object_key: str
) -> str:
    response = s3_client.get_object(Bucket=bucket_name, Key=object_key)
    tfstate_data = response["Body"].read().decode("utf-8")
    return tfstate_data


def get_outputs_from_tfstate(tfstate_data: str) -> dict:
    tfstate: dict = json.loads(tfstate_data)
    outputs = tfstate.get("outputs", [])

    return {key: output["value"] for key, output in outputs.items()}


def parse_tfstate_key(object_key: str) -> TfstateKey:
    parts = object_key.split("/")

    if len(parts) < 2:
        raise ValueError(f"Invalid tfstate object key: {object_key}")

    repository = parts[0]
    environment = parts[1].replace(".tfstate", "")

    return TfstateKey(repository=repository, environment=environment)


def save_outputs_to_ssm(
    ssm_client: SSMClient,
    tfstate_key: TfstateKey,
    output_key: str,
    output_value: Any,
) -> None:
    parameter_name = (
        f"/{tfstate_key.repository}/{tfstate_key.environment}/{output_key}"
    )
    ssm_client.put_parameter(
        Name=parameter_name,
        Value=json.dumps(output_value)
        if not isinstance(output_value, str)
        else output_value,
        Type="String",
        Overwrite=True,
        Tier="Standard",
    )


@event_source(data_class=S3Event)
def lambda_handler(event: S3Event, context):
    s3_client = get_s3_client()
    ssm_client = get_ssm_client()
    logger = get_logger()

    bucket_name = event.bucket_name

    for record in event.records:
        object_key = unquote_plus(record.s3.get_object.key)

        tfstate = read_tfstate_from_s3(s3_client(), bucket_name, object_key)

        outputs = get_outputs_from_tfstate(tfstate)

        tfstate_key = parse_tfstate_key(object_key)

        for output_key, output_value in outputs.items():
            logger().info(
                f"Saving output {output_key} from {tfstate_key} to SSM Parameter Store"
            )

            save_outputs_to_ssm(
                ssm_client(),
                tfstate_key,
                output_key,
                output_value,
            )
