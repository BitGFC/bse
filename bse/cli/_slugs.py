# -*- coding: utf-8 -*-

import click
from ._exceptions import jsonexception
from bse import register
from bse.transform import Jsonable
from typing import Dict


@click.command(name="slugs")
@click.pass_obj
@jsonexception
def cmd_slugs(obj: Dict[str, str]) -> int:
    """
    Shows the slugs loaded in bse. A slug is the identifier used for a script
    """
    r = register.Register()
    slugs = [
        {"slug": slug, "description": r.load(slug).description} for slug in r.slugs()
    ]
    click.echo(Jsonable.dump(slugs))
    return 0
