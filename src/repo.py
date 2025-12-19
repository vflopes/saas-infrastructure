import os
import pathlib
from typing import Iterable


def list_folders(base_path: str) -> Iterable[pathlib.Path]:
    return filter(os.path.isdir, pathlib.Path(base_path).iterdir())
