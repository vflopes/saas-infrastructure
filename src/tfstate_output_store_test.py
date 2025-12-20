import unittest
from unittest.mock import patch, Mock


class TestTfstateStoreFunctions(unittest.TestCase):
    def test_tfstate_key_to_str(self):
        from src.tfstate_output_store import TfstateKey

        tfstate_key = TfstateKey(repository="my-repo", environment="prod")
        self.assertEqual(str(tfstate_key), "my-repo/prod")

    def test_get_logger(self):
        from src.tfstate_output_store import get_logger

        logger_func = get_logger()
        logger = logger_func()
        self.assertIsNotNone(logger)
        self.assertEqual(logger.service, "tfstate-output-store")

    @patch("boto3.client")
    def test_get_ssm_client(self, mock_boto_client):
        mock_boto_client.return_value = Mock()

        from src.tfstate_output_store import get_ssm_client

        ssm_client_func = get_ssm_client()
        ssm_client = ssm_client_func()

        self.assertIsNotNone(ssm_client)
        mock_boto_client.assert_called_with("ssm")

    @patch("boto3.client")
    def test_get_s3_client(self, mock_boto_client):
        mock_boto_client.return_value = Mock()

        from src.tfstate_output_store import get_s3_client

        s3_client_func = get_s3_client()
        s3_client = s3_client_func()

        self.assertIsNotNone(s3_client)
        mock_boto_client.assert_called_with("s3")

    def test_read_tfstate_from_s3(self):
        from src.tfstate_output_store import read_tfstate_from_s3

        mock_s3_client = Mock()
        mock_response = {
            "Body": Mock(
                read=Mock(
                    return_value=b'{"outputs": {"key": {"value": "value"}}}'
                )
            )
        }
        mock_s3_client.get_object.return_value = mock_response

        tfstate_data = read_tfstate_from_s3(
            mock_s3_client, "my-bucket", "my-object-key"
        )

        self.assertEqual(
            tfstate_data, '{"outputs": {"key": {"value": "value"}}}'
        )
        mock_s3_client.get_object.assert_called_with(
            Bucket="my-bucket", Key="my-object-key"
        )

    def test_get_outputs_from_tfstate(self):
        from src.tfstate_output_store import get_outputs_from_tfstate

        tfstate_data = '{"outputs": {"key1": {"value": "value1"}, "key2": {"value": "value2"}}}'

        outputs = get_outputs_from_tfstate(tfstate_data)

        expected_outputs = {"key1": "value1", "key2": "value2"}
        self.assertEqual(outputs, expected_outputs)

    def test_parse_tfstate_key(self):
        from src.tfstate_output_store import parse_tfstate_key, TfstateKey

        object_key = "my-repo/prod.tfstate"
        tfstate_key = parse_tfstate_key(object_key)

        expected_tfstate_key = TfstateKey(
            repository="my-repo", environment="prod"
        )
        self.assertEqual(tfstate_key, expected_tfstate_key)

        with self.assertRaises(ValueError):
            parse_tfstate_key("invalidkey")  # Missing '/' character

    def test_save_outputs_to_ssm(self):
        from src.tfstate_output_store import (
            save_outputs_to_ssm,
            TfstateKey,
        )

        mock_ssm_client = Mock()
        tfstate_key = TfstateKey(repository="my-repo", environment="prod")
        output_key = "output1"
        output_value = "value1"

        save_outputs_to_ssm(
            mock_ssm_client, tfstate_key, output_key, output_value
        )

        mock_ssm_client.put_parameter.assert_called_with(
            Name="/my-repo/prod/output1",
            Value="value1",
            Type="String",
            Overwrite=True,
            Tier="Standard",
        )


class TestTfstateLambdaHandler(unittest.TestCase):
    @patch("src.tfstate_output_store.get_s3_client")
    @patch("src.tfstate_output_store.get_ssm_client")
    @patch("src.tfstate_output_store.get_logger")
    def test_lambda_handler(
        self, mock_get_logger, mock_get_ssm_client, mock_get_s3_client
    ):
        from aws_lambda_powertools.utilities.data_classes import S3Event
        from src.tfstate_output_store import lambda_handler

        mock_logger = Mock()
        mock_get_logger.return_value = lambda: mock_logger

        mock_s3_client = Mock()
        mock_get_s3_client.return_value = lambda: mock_s3_client

        mock_ssm_client = Mock()
        mock_get_ssm_client.return_value = lambda: mock_ssm_client

        tfstate_data = '{"outputs": {"key1": {"value": "value1"}}}'
        mock_response = {
            "Body": Mock(read=Mock(return_value=tfstate_data.encode("utf-8")))
        }
        mock_s3_client.get_object.return_value = mock_response

        event = S3Event(
            {
                "Records": [
                    {
                        "s3": {
                            "bucket": {"name": "my-bucket"},
                            "object": {"key": "my-repo/prod.tfstate"},
                        }
                    }
                ]
            }
        )

        lambda_handler(event, None)

        mock_s3_client.get_object.assert_called_with(
            Bucket="my-bucket", Key="my-repo/prod.tfstate"
        )
        mock_ssm_client.put_parameter.assert_called_with(
            Name="/my-repo/prod/key1",
            Value="value1",
            Type="String",
            Overwrite=True,
            Tier="Standard",
        )


if __name__ == "__main__":
    unittest.main()
