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
from datetime import datetime, timedelta

OUTPUT_DIR = "/lakehouse/default/Files/lufthansa/"
AIRPORT_CODES = ["FAO", "LIS", "OPO", "FRA", "DRS", "MUC"]
QUESTION = "operations/schedules"
TIMESTAMP = datetime.now()
access_token = get_token()

data = []
for origin in AIRPORT_CODES:
    for destination in AIRPORT_CODES:
        if origin == destination:
            continue
        for i in range(7):
            current_day = TIMESTAMP + timedelta(days=i)
            full_question = QUESTION +"/"+ origin +"/"+ destination +"/"+ current_day.strftime("%Y-%m-%d") 
            new_data = get_all_data(full_question, {"directFlights": "true"}, access_token, False)
            if new_data:
                data.append(new_data[0])
save_data(OUTPUT_DIR+"schedules/", data, TIMESTAMP.strftime("%Y-%m-%d") )

print("Finished Schedules Import")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

from pyspark.sql.functions import explode, col, from_json
from pyspark.sql.types import ArrayType, StructType, StringType

df = spark.read.option("multiLine", "true") \
    .json("Files/lufthansa/schedules/*.json")

flight_struct = StructType() \
    .add("Departure", StructType() \
        .add("AirportCode", StringType()) \
        .add("ScheduledTimeLocal", StructType()
            .add("DateTime", StringType()))) \
    .add("Arrival", StructType() \
        .add("AirportCode", StringType()) \
        .add("ScheduledTimeLocal", StructType()
            .add("DateTime", StringType()))) \
    .add("MarketingCarrier", StructType() \
        .add("AirlineID", StringType()) \
        .add("FlightNumber", StringType())) \
    .add("OperatingCarrier", StructType() \
        .add("AirlineID", StringType()) \
        .add("FlightNumber", StringType())) \
    .add("Equipment", StructType()
        .add("AircraftCode", StringType())) \
    .add("Details", StructType() \
        .add("DaysOfOperation", StringType()) \
        .add("DatePeriod", StructType() \
            .add("Effective", StringType()) \
            .add("Expiration", StringType())))

schema = ArrayType(StructType()
    .add("TotalJourney", StructType().add("Duration", StringType()))
    .add("Flight", flight_struct))

df = df.withColumn(
    "schedule_array", 
    from_json(col("ScheduleResource.Schedule").cast("string"), schema)
)

df = df.select(explode("schedule_array").alias("schedule")) \
    .select(
        col("schedule.TotalJourney.Duration").alias("duration"),
        col("schedule.Flight.Departure.AirportCode").alias("dep_airport"),
        col("schedule.Flight.Departure.ScheduledTimeLocal.DateTime").alias("dep_time"),
        col("schedule.Flight.Arrival.AirportCode").alias("arr_airport"),
        col("schedule.Flight.Arrival.ScheduledTimeLocal.DateTime").alias("arr_time"),
        col("schedule.Flight.MarketingCarrier.AirlineID").alias("mc_airline"),
        col("schedule.Flight.MarketingCarrier.FlightNumber").alias("mc_flight_no"),
        col("schedule.Flight.OperatingCarrier.AirlineID").alias("oc_airline"),
        col("schedule.Flight.OperatingCarrier.FlightNumber").alias("oc_flight_no"),
        col("schedule.Flight.Equipment.AircraftCode").alias("aircraft"),
        col("schedule.Flight.Details.DaysOfOperation").alias("days"),
        col("schedule.Flight.Details.DatePeriod.Effective").alias("start_date"),
        col("schedule.Flight.Details.DatePeriod.Expiration").alias("end_date")
    )

display(df.head(10))

df.write.format("delta") \
    .mode("overwrite") \
    .saveAsTable("schedules_delta")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
