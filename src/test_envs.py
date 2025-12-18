import unittest
from unittest.mock import patch, Mock


class TestEnvConfigRetrieval(unittest.TestCase):
    @patch("os.path")
    @patch("configparser.ConfigParser")
    def test_get_env_config(self, mock_config_parser, mock_path):
        mock_path.basename.return_value = "test_env"
        mock_path.join.return_value = "/fake/path/test_env/test_env.ini"

        mock_config = mock_config_parser.return_value

        from src.envs import get_env_config

        env_config = get_env_config("/fake/path/test_env")

        self.assertEqual(env_config, mock_config)

        mock_path.basename.assert_called_once_with("/fake/path/test_env")
        mock_path.join.assert_called_once_with(
            "/fake/path/test_env", "test_env.ini"
        )
        mock_config.read.assert_called_once_with(
            "/fake/path/test_env/test_env.ini"
        )


class TestEnvConfigValidation(unittest.TestCase):
    def setUp(self) -> None:
        from configparser import ConfigParser

        self.mock_config = Mock(spec=ConfigParser)
        self.mock_config.has_section.return_value = True
        self.mock_config.has_option.return_value = True

    def test_validate_required_option_missing_section(self):
        self.mock_config.has_section.return_value = False

        from src.envs import validate_required_option

        error = validate_required_option(
            self.mock_config, "some_section", "some_option"
        )

        self.assertIsInstance(error, KeyError)
        self.assertIn("required section", str(error))

        self.mock_config.has_section.assert_called_once_with("some_section")
        self.mock_config.has_option.assert_not_called()

    def test_validate_required_option_missing_option(self):
        self.mock_config.has_option.return_value = False

        from src.envs import validate_required_option

        error = validate_required_option(
            self.mock_config, "some_section", "some_option"
        )

        self.assertIsInstance(error, KeyError)
        self.assertIn("required option", str(error))

        self.mock_config.has_section.assert_called_once_with("some_section")
        self.mock_config.has_option.assert_called_once_with(
            "some_section", "some_option"
        )

    def test_validate_required_option_all_present(self):
        from src.envs import validate_required_option

        error = validate_required_option(
            self.mock_config, "some_section", "some_option"
        )
        self.assertIsNone(error)

        self.mock_config.has_section.assert_called_once_with("some_section")
        self.mock_config.has_option.assert_called_once_with(
            "some_section", "some_option"
        )

    def test_validate_required_options_empty(self):
        from src.envs import validate_required_options

        errors = validate_required_options(self.mock_config, {})

        self.assertEqual(errors, [])

    def test_validate_required_options_multiple(self):
        from src.envs import validate_required_options

        self.mock_config.has_section.side_effect = [True, False, True]
        self.mock_config.has_option.side_effect = [False, True]

        required_options = {
            "section1": ["option1", "option2"],
            "section2": ["option3"],
        }

        errors = validate_required_options(self.mock_config, required_options)

        self.assertEqual(len(errors), 2)
        self.assertIsInstance(errors[0], KeyError)
        self.assertIsInstance(errors[1], KeyError)


if __name__ == "__main__":
    unittest.main()
