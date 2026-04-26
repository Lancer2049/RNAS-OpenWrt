import sys
from pathlib import Path
from fastapi import APIRouter, HTTPException, Body

sys.path.insert(0, str(Path(__file__).parent.parent.parent.parent / "cmd" / "rnas-config"))
from rnas_config import walk_config_tree  # type: ignore

router = APIRouter()
DEFAULT_ROOT = "/etc/rnas"


@router.get("/config")
async def get_all_config():
    config = walk_config_tree(Path(DEFAULT_ROOT))
    return {"config": {k: v for k, v in sorted(config.items())}}


@router.get("/config/{module:path}")
async def get_config_section(module: str):
    config = walk_config_tree(Path(DEFAULT_ROOT))
    matches = {k: v for k, v in config.items() if k.startswith(module.replace("/", "."))}
    if not matches:
        raise HTTPException(status_code=404, detail=f"Config section '{module}' not found")
    return {"module": module, "config": matches}
