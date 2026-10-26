#!/usr/bin/env bash
# SuperKart: build and run the Flask backend + Streamlit frontend in this Codespace
set -e
cd "$(dirname "$0")"

echo "== 1/5 Creating Docker network"
docker network create superkart-net >/dev/null 2>&1 || true
docker rm -f backend frontend >/dev/null 2>&1 || true

echo "== 2/5 Building and starting the backend (Flask API on port 7860)"
docker build -q -t superkart-backend ./backend
docker run -d --name backend --network superkart-net -p 7860:7860 superkart-backend

echo "== 3/5 Building and starting the frontend (Streamlit on port 8501)"
docker build -q -t superkart-frontend ./frontend
docker run -d --name frontend --network host -e BACKEND_URL=http://localhost:7860 superkart-frontend

echo "== Waiting for the API to start"
for i in $(seq 1 30); do curl -s localhost:7860/ >/dev/null && break; sleep 2; done

echo "== 4/5 Testing the API"
echo "-- GET /"
curl -s localhost:7860/; echo
echo "-- POST /v1/predict (single inference)"
curl -s -X POST localhost:7860/v1/predict -H 'Content-Type: application/json' -d '{"Product_Weight":12.66,"Product_Sugar_Content":"Low Sugar","Product_Allocated_Area":0.027,"Product_MRP":117.08,"Store_Size":"Medium","Store_Location_City_Type":"Tier 2","Store_Type":"Supermarket Type2","Product_Id_char":"FD","Store_Age_Years":16,"Product_Type_Category":"Non Perishables"}'; echo
echo "-- POST /v1/predictbatch (batch inference)"
curl -s -X POST localhost:7860/v1/predictbatch -F file=@Batch_Data_SuperKart.csv; echo

echo "== 5/5 Making port 7860 public and saving files to GitHub"
gh codespace ports visibility 7860:public -c "$CODESPACE_NAME" >/dev/null 2>&1 \
  && echo "Port 7860 is now Public" \
  || echo "!! Could not set port 7860 to Public automatically - do it in the Ports tab (right-click 7860 > Port Visibility > Public)"
git add backend frontend setup.sh Batch_Data_SuperKart.csv
git commit -q -m "Add SuperKart Flask backend and Streamlit frontend" || true
git push -q || echo "!! git push failed - files are still running fine in this Codespace"

echo
echo "=================================================================="
echo "API (forwarded URL, port 7860): https://${CODESPACE_NAME}-7860.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"
echo "Streamlit app (port 8501):      https://${CODESPACE_NAME}-8501.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"
echo "=================================================================="
