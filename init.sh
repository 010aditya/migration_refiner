#!/bin/bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
echo '✅ Ready to run main.py'