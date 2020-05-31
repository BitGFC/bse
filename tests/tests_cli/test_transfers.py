# -*- coding: utf-8 -*-

import traceback
from bse import cli
from click.testing import CliRunner


_transfers_without_slug = f"""Usage: bse transfers [OPTIONS] SLUG
Try 'bse transfers --help' for help.

Error: Missing argument 'SLUG'.
"""


def test_transfers_without_slug() -> None:
    """Test the transfers command"""
    runner = CliRunner()
    result = runner.invoke(cli.main, "transfers")
    assert result.output == _transfers_without_slug
    traceback.print_exception(*result.exc_info)
    assert result.exit_code > 0