# Import necessary libraries
import numpy as np
import joblib  # For loading the serialized model
import pandas as pd  # For data manipulation
from flask import Flask, request, jsonify  # For creating the Flask API

# Initialize Flask app with a name
superkart_api = Flask("SuperKart")

# Load the trained model (tuned XGBoost pipeline incl. one-hot encoding)
model = joblib.load("superkart_model.joblib")

FEATURES = ['Product_Weight', 'Product_Sugar_Content', 'Product_Allocated_Area', 'Product_MRP',
            'Store_Size', 'Store_Location_City_Type', 'Store_Type', 'Product_Id_char',
            'Store_Age_Years', 'Product_Type_Category']

# Define a route for the home page
@superkart_api.get('/')
def home():
    return "Welcome to the SuperKart System"

# Define an endpoint to predict sales for a single product
@superkart_api.post('/v1/predict')
def predict_sales():
    data = request.get_json()
    sample = {f: data[f] for f in FEATURES}
    input_data = pd.DataFrame([sample])
    prediction = model.predict(input_data).tolist()[0]
    return jsonify({'Sales': round(float(prediction), 2)})

# Define an endpoint to predict sales for a batch of products
@superkart_api.post('/v1/predictbatch')
def predict_sales_batch():
    file = request.files['file']
    input_data = pd.read_csv(file)
    predictions = model.predict(input_data[FEATURES]).tolist()
    output_dict = {str(i): round(float(pred), 2) for i, pred in enumerate(predictions)}
    return output_dict

# Run the Flask app in debug mode
if __name__ == '__main__':
    superkart_api.run(debug=True)
