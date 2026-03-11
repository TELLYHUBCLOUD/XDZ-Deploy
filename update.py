from sys import exit
from importlib import import_module
from logging import (
    FileHandler,
    StreamHandler,
    INFO,
    basicConfig,
    error as log_error,
    info as log_info,
    getLogger,
    ERROR,
)
from os import path, remove, environ
from pymongo.mongo_client import MongoClient
from pymongo.server_api import ServerApi
from subprocess import run as srun, call as scall

getLogger("pymongo").setLevel(ERROR)

var_list = [
    "BOT_TOKEN",
    "TELEGRAM_API",
    "TELEGRAM_HASH",
    "OWNER_ID",
    "DATABASE_URL",
    "BASE_URL",
    "UPSTREAM_REPO",
    "UPSTREAM_BRANCH",
    "UPDATE_PKGS",
]

if path.exists("log.txt"):
    with open("log.txt", "r+") as f:
        f.truncate(0)

if path.exists("rlog.txt"):
    remove("rlog.txt")

basicConfig(
    format="[%(asctime)s] [%(levelname)s] - %(message)s",
    datefmt="%d-%b-%y %I:%M:%S %p",
    handlers=[FileHandler("log.txt"), StreamHandler()],
    level=INFO,
)

try:
    settings = import_module("config")
    config_file = {
        key: value.strip() if isinstance(value, str) else value
        for key, value in vars(settings).items()
        if not key.startswith("__")
    }
except ModuleNotFoundError:
    log_info("Config.py file is not Added! Checking ENVs..")
    config_file = {}

env_updates = {
    key: value.strip() if isinstance(value, str) else value
    for key, value in environ.items()
    if key in var_list
}
if env_updates:
    log_info("Config data is updated with ENVs!")
    config_file.update(env_updates)

# -------------------- BOT TOKEN CHECK -------------------- #

BOT_TOKEN = config_file.get("BOT_TOKEN", "")
if not BOT_TOKEN:
    log_error("BOT_TOKEN variable is missing! Exiting now")
    exit(1)

BOT_ID = BOT_TOKEN.split(":", 1)[0]

# -------------------- DATABASE SYNC -------------------- #

if DATABASE_URL := config_file.get("DATABASE_URL", "").strip():
    try:
        conn = MongoClient(DATABASE_URL, server_api=ServerApi("1"))
        db = conn.beast
        old_config = db.settings.deployConfig.find_one({"_id": BOT_ID}, {"_id": 0})
        config_dict = db.settings.config.find_one({"_id": BOT_ID})
        if (
            old_config is not None and old_config == config_file or old_config is None
        ) and config_dict is not None:
            config_file["UPSTREAM_REPO"] = config_dict["UPSTREAM_REPO"]
            config_file["UPSTREAM_BRANCH"] = config_dict.get("UPSTREAM_BRANCH", "wzv3")
            config_file["UPDATE_PKGS"] = config_dict.get("UPDATE_PKGS", "True")
        conn.close()
    except Exception as e:
        log_error(f"Database ERROR: {e}")

# ---------------- SAFE AUTO UPDATE SYSTEM ---------------- #

UPSTREAM_REPO = config_file.get("UPSTREAM_REPO", "").strip()
UPSTREAM_BRANCH = config_file.get("UPSTREAM_BRANCH", "").strip() or "ux1"

if UPSTREAM_REPO and UPSTREAM_BRANCH:
    log_info(f"UPSTREAM_REPO: FEACH DONE  | UPSTREAM_BRANCH: {UPSTREAM_BRANCH}")
    log_info("Starting upstream update process...")

    # Handle Gist raw link
    if "gist.githubusercontent.com" in UPSTREAM_REPO:
        try:
            from requests import get as rget
            UPSTREAM_REPO = rget(UPSTREAM_REPO).text.strip()
        except Exception as e:
            log_error(f"Failed to fetch Gist URL: {e}")

    # Remove old git directory
    if path.exists(".git"):
        srun(["rm", "-rf", ".git"], check=True)

    # SAFE UPDATE COMMAND
    update_cmd = (
        f"git init -q && "
        f"git remote add origin {UPSTREAM_REPO} && "
        f"git fetch origin -q && "
        f"git reset --hard origin/{UPSTREAM_BRANCH} -q"
    )

    update = srun(update_cmd, shell=True)

    if update.returncode == 0:
        log_info(f"Successfully updated from {UPSTREAM_BRANCH} branch.")
    else:
        log_error("Something went Wrong ! Recheck your details or Ask Support !")
        log_info(f"UPSTREAM_REPO: {UPSTREAM_REPO} | UPSTREAM_BRANCH: {UPSTREAM_BRANCH}")
else:
    log_info("UPSTREAM_REPO or UPSTREAM_BRANCH not set. Skipping update.")

# ---------------- PACKAGE UPDATE SYSTEM ---------------- #

UPDATE_PKGS = config_file.get("UPDATE_PKGS", "True")
if (isinstance(UPDATE_PKGS, str) and UPDATE_PKGS.lower() == "true") or UPDATE_PKGS is True:
    scall("uv pip install -U -r requirements.txt", shell=True)
    log_info("Successfully Updated all the Packages!")
