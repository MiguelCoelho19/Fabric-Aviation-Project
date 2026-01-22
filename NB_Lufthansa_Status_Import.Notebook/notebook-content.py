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

%run ./NB_Lufthansa_Functions

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

import json
from datetime import datetime

OUTPUT_DIR = "/lakehouse/default/Files/lufthansa/"
AIRPORT_CODES = ["LIS", "FAO", "OPO", "FRA", "DRS", "MUC"]
QUESTION = "operations/flightstatus/route"
TIMESTAMP = datetime.now()
access_token = get_token()

data = []
for origin in AIRPORT_CODES:
    for destination in AIRPORT_CODES:
        if origin == destination:
            continue
        full_question = QUESTION +"/"+ origin +"/"+ destination +"/"+ TIMESTAMP.strftime("%Y-%m-%d") 
        new_data = get_all_data(full_question, {"limit":100, "offset":0, "serviceType": "all"}, access_token, True)
        if new_data:
            data.append(new_data[0])
save_data(OUTPUT_DIR + "status/", data, TIMESTAMP.strftime("%Y-%m-%d_%H-%M") )

print("Finished Status Import")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

from pyspark.sql.functions import explode, col, input_file_name
from pyspark.sql.types import ArrayType, StructType, StringType

time_struct = StructType().add("DateTime", StringType())
status_struct = StructType().add("Code", StringType()).add("Definition", StringType())

flight_fields = StructType() \
    .add("Departure", StructType() \
        .add("AirportCode", StringType()) \
        .add("ScheduledTimeLocal", time_struct) \
        .add("ScheduledTimeUTC", time_struct) \
        .add("EstimatedTimeLocal", time_struct) \
        .add("EstimatedTimeUTC", time_struct) \
        .add("ActualTimeLocal", time_struct) \
        .add("ActualTimeUTC", time_struct) \
        .add("TimeStatus", status_struct)) \
    .add("Arrival", StructType() \
        .add("AirportCode", StringType()) \
        .add("ScheduledTimeLocal", time_struct) \
        .add("ScheduledTimeUTC", time_struct) \
        .add("EstimatedTimeLocal", time_struct) \
        .add("EstimatedTimeUTC", time_struct) \
        .add("ActualTimeLocal", time_struct) \
        .add("ActualTimeUTC", time_struct) \
        .add("TimeStatus", status_struct)) \
    .add("MarketingCarrier", StructType().add("AirlineID", StringType()).add("FlightNumber", StringType())) \
    .add("OperatingCarrier", StructType().add("AirlineID", StringType()).add("FlightNumber", StringType())) \
    .add("Equipment", StructType().add("AircraftCode", StringType()).add("AircraftRegistration", StringType())) \
    .add("FlightStatus", status_struct) \
    .add("ServiceType", StringType())

root_schema = StructType().add("FlightStatusResource", 
    StructType().add("Flights", 
        StructType().add("Flight", ArrayType(flight_fields))
    )
)

df = spark.read.option("multiLine", "true") \
    .schema(root_schema) \
    .json("Files/lufthansa/status/*.json") \
    .withColumn("source_file", input_file_name())

df = df.select(
    col("source_file"), 
    explode("FlightStatusResource.Flights.Flight").alias("flight")
)

df = df.select(
        col("source_file"),
        col("flight.Departure.AirportCode").alias("dep_airport"),
        col("flight.Departure.ScheduledTimeLocal.DateTime").alias("dep_sc_local_time"),
        col("flight.Departure.ScheduledTimeUTC.DateTime").alias("dep_sc_utc_time"),
        col("flight.Departure.EstimatedTimeLocal.DateTime").alias("dep_es_local_time"),
        col("flight.Departure.EstimatedTimeUTC.DateTime").alias("dep_es_utc_time"),
        col("flight.Departure.ActualTimeLocal.DateTime").alias("dep_ac_local_time"),
        col("flight.Departure.ActualTimeUTC.DateTime").alias("dep_ac_utc_time"),
        col("flight.Departure.TimeStatus.Code").alias("dep_time_status_code"),
        col("flight.Departure.TimeStatus.Definition").alias("dep_time_status"),
        col("flight.Arrival.AirportCode").alias("arr_airport"),
        col("flight.Arrival.ScheduledTimeLocal.DateTime").alias("arr_sc_local_time"),
        col("flight.Arrival.ScheduledTimeUTC.DateTime").alias("arr_sc_utc_time"),
        col("flight.Arrival.EstimatedTimeLocal.DateTime").alias("arr_es_local_time"),
        col("flight.Arrival.EstimatedTimeUTC.DateTime").alias("arr_es_utc_time"),
        col("flight.Arrival.ActualTimeLocal.DateTime").alias("arr_ac_local_time"),
        col("flight.Arrival.ActualTimeUTC.DateTime").alias("arr_ac_utc_time"),
        col("flight.Arrival.TimeStatus.Code").alias("arr_time_status_code"),
        col("flight.Arrival.TimeStatus.Definition").alias("arr_time_status"),
        col("flight.MarketingCarrier.AirlineID").alias("mc_airline_id"),
        col("flight.MarketingCarrier.FlightNumber").alias("mc_flight_number"),
        col("flight.OperatingCarrier.AirlineID").alias("oc_airline_id"),
        col("flight.OperatingCarrier.FlightNumber").alias("oc_flight_number"),
        col("flight.Equipment.AircraftCode").alias("aircraft_code"),
        col("flight.Equipment.AircraftRegistration").alias("aircraft_registration"),
        col("flight.FlightStatus.Code").alias("flight_status_code"),
        col("flight.FlightStatus.Definition").alias("flight_status"),
        col("flight.ServiceType").alias("service_type")
    )

display(df.head(10))

df.write.format("delta") \
    .mode("overwrite")\
    .option("overwriteSchema", "true") \
    .saveAsTable("status_delta")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
