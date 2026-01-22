# Fabric notebook source

# METADATA ********************

# META {
# META   "kernel_info": {
# META     "name": "synapse_pyspark"
# META   },
# META   "dependencies": {
# META     "lakehouse": {
# META       "default_lakehouse": "4f909ca9-0c8b-420a-8995-81f1b427b6c0",
# META       "default_lakehouse_name": "LH_Bronze_Layer",
# META       "default_lakehouse_workspace_id": "85a5c217-5ffd-4fc8-a29e-97e1a49d9530",
# META       "known_lakehouses": [
# META         {
# META           "id": "4f909ca9-0c8b-420a-8995-81f1b427b6c0"
# META         }
# META       ]
# META     }
# META   }
# META }

# CELL ********************

import requests
import json
import time
from datetime import datetime

# Configuration
CLIENT_ID = 'wea4mxmnzbafvmx9pca7mwccz'
CLIENT_SECRET = 'HyxCaK9hXP'
TOKEN_URL = "https://api.lufthansa.com/v1/oauth/token"
BASE_URL = "https://api.lufthansa.com/v1"

# Get Access Token
def get_token():
    auth_payload = {
        'client_id': CLIENT_ID,
        'client_secret': CLIENT_SECRET,
        'grant_type': 'client_credentials'
    }
    print("Requesting access token...")
    res = requests.post(TOKEN_URL, data=auth_payload)
    res.raise_for_status()
    print("Access token acquired")
    return res.json()['access_token']

def ask_question(question, params, access_token):
    time.sleep(3)
    headers = {
        'Authorization': f'Bearer {access_token}',
        'Accept': 'application/json',
        'User-Agent': "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
    }

    try:        
        print(f"Fetching data for question: {question} : {params}")
        url = f"{BASE_URL}/{question}"
        response = requests.get(url, headers=headers, params=params)
              
        if response.status_code != 200:
            return [response.status_code, []]
        data = response.json()
        return [response.status_code, data]

    except Exception as e:
        print(f"Error: {str(e)} for {question} Aborting...")
        return 400.5 #To distinguish from a status code retured by database

def get_all_data(question, params, access_token, increase):
    data = []
    failures = 0
    all_stored = False
    while failures<3 and not all_stored:
        res = ask_question(question, params, access_token)
        status = res[0]
        if status == 200:
            data.append(res[1])            
            if not increase:
                break
            params["offset"] += params["limit"]
            new_data = next(iter(res[1].values()))
            total_count = new_data["Meta"]["TotalCount"]
            all_stored = total_count < params["offset"]
        elif status == 401: #Token expired
            print("Token expired, refreshing...")
            access_token = get_token()
            continue
        elif status == 404: #Information requested doesn't exist
            print("Resource not found. Next...")
            break
        elif status == 400:
            print("Bad request. Trying again...")
            failures += 1
            continue
        else:
            break
    if failures == 3:
        print("Failed too many times. Skipping...")
    return data

def save_data(directory, data, file_name):
    safe_name = file_name.replace("/", "_")
    full_path = directory + safe_name + ".json"
        
    with open(full_path, "w") as f:
        json.dump(data, f)
    
    print(f"Successfully saved to {full_path}")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
