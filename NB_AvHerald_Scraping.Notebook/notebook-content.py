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
import re
from bs4 import BeautifulSoup
import json
import time
import os
from datetime import datetime

def get_lastest_headline():
    #Checks the most recent file in the lakehouse to find the last headline scraped.
    directory = "/lakehouse/default/Files/avherald"
    try:
        files = [f for f in os.listdir(directory) if f.endswith('.json')]
        if not files:
            return None
        # Sort files by name to get the latest
        latest_file = sorted(files)[-1]
        with open(os.path.join(directory, latest_file), "r") as f:
            existing_data = json.load(f)
            return existing_data[0]['headline'] if existing_data else None
    except Exception as e:
        print(f"Error reading: {e}")
        return None

def scrape_avherald():
    url = "https://avherald.com/"
    HEADERS = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
    }
    LAST_HEADLINE = get_lastest_headline()
    MAX_PAGE = 50
    current_page = 1
    up_to_date = False
    data_list = []
    last_date = ""
    VALID_LINE_TYPES = ["Incident", "Accident", "Report", "News", "Crash"]

    while current_page <= MAX_PAGE and not up_to_date:
        time.sleep(3)
        print(f"Starting scrape of {url}...")
        response = requests.get(url, headers=HEADERS)
    
        if response.status_code != 200:
            print(f"Failed to retrieve page. Error: {response.status_code}")
            continue
        
        soup = BeautifulSoup(response.text, 'html.parser')
        lines = soup.find_all(class_=["headline_avherald", "bheadline_avherald", "frame"])    
        current_date = ""
        i=0
        while i<len(lines):
            line = lines[i]
            line_class = line.get('class', [])
            if "frame" in line_class and line.get('alt') not in VALID_LINE_TYPES:
                i+=1
                continue

            if "bheadline_avherald" in line_class:
                current_date = line.get_text(strip=True)
                i+=1 
            elif current_date == last_date:
                i+=1
            elif "frame" in line_class:
                line_type = line.get('alt')
                headline = lines[i+1].get_text(strip=True)
                if headline == LAST_HEADLINE:
                    up_to_date = True
                    print(f"Reached previously scraped data. Data up to date")
                    break
                data_list.append({
                    "type": line_type,
                    "headline": headline
                })  
                i+=2
        last_date = current_date
        # Remove day suffixes (st, nd, rd, th) to make it easier to parse
        clean_date_str = re.sub(r'(\d+)(st|nd|rd|th)', r'\1', last_date)
        dt = datetime.strptime(clean_date_str, "%A %b %d %Y")

        print(f"Successfully scraped until {last_date}")
        url = "https://avherald.com/" + "h?list=&opt=0&offset=" + dt.strftime("%Y%m%d")
        current_page += 1

    return data_list

# 3. Execute scraping
scraped_data = scrape_avherald()
if len(scraped_data) > 0:
    # 4. Save to JSON in the Fabric Lakehouse (Files section)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    file_path = f"/lakehouse/default/Files/avherald/{timestamp}.json"

    with open(file_path, "w") as f:
        json.dump(scraped_data, f, indent=4)

    print(f"Finished scraping!!! Successfully scraped {len(scraped_data)} headlines and saved to {file_path}")
else:
    print("No new data detected")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

df = spark.read.option("multiLine", "true") \
    .json("Files/avherald/*.json")

df.write.format("delta") \
    .mode("overwrite") \
    .saveAsTable("avherald_delta")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
