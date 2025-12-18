import os
import configparser
from typing import Optional


def get_env_config(env_path: str) -> configparser.ConfigParser:
    env_name = os.path.basename(env_path)

    ini_file = os.path.join(env_path, f"{env_name}.ini")

    env_config = configparser.ConfigParser()
    env_config.read(ini_file)

    return env_config


def validate_required_option(
    env_config: configparser.ConfigParser, section: str, option: str
) -> Optional[KeyError]:
    try:
        if not env_config.has_section(section):
            raise KeyError(f"Missing required section: {section}")

        if not env_config.has_option(section, option):
            raise KeyError(
                f"Missing required option: {option} in section: {section}"
            )

    except KeyError as e:
        return e

    return None


def validate_required_options(
    env_config: configparser.ConfigParser,
    required_options: dict[str, list[str]],
) -> list[Exception]:
    if not required_options:
        return []

    return list(
        filter(
            None,
            [
                validate_required_option(env_config, section, option)
                for section, options in required_options.items()
                for option in options
            ],
        )
    )
