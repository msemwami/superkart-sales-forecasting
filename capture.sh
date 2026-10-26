#!/usr/bin/env bash
# Runs setup, captures app screenshots and saves everything to GitHub
cd "$(dirname "$0")"
mkdir -p screenshots
bash setup.sh 2>&1 | tee screenshots/setup_log.txt
echo "== Installing headless browser for screenshots (1-2 min)"
pip install -q playwright >/dev/null 2>&1 && python3 -m playwright install --with-deps chromium >/dev/null 2>&1
python3 shots.py http://localhost:8501 && echo "Screenshots saved"
git add screenshots shots.py capture.sh
git commit -q -m "Add deployment log and Streamlit screenshots" || true
git push -q && echo "== ALL DONE: pushed to GitHub"
