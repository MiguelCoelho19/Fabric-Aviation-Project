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

OUTPUT_DIR = "/lakehouse/default/Files/lufthansa/"
access_token = get_token()

CODES = ["FAO", "LIS", "OPO", "DRS", "MUC"]
airport_data = []
city_data = []
for c in CODES:
    airport_data.append(get_all_data("references/airports/" + c,
        {"lang": "EN"}, access_token, False)[0])
    city_data.append(get_all_data("references/cities/" + c,
        {"lang": "EN"}, access_token, False)[0])
    
#API doesn't have info about FRA airport
airport_data.append({"AirportResource": {"Airports": {"Airport": {"AirportCode": "FRA", "Position": {"Coordinate": {"Latitude": 50.0377, "Longitude": 8.5593}}, "CityCode": "FRA", "CountryCode": "DE", "LocationType": "Airport", "Names": {"Name": {"@LanguageCode": "EN", "$": "Frankfurt"}}, "UtcOffset": "+01:00", "TimeZoneId": "Europe/Berlin"}}, "Meta": {"@Version": "1.0.0", "Link": [{"@Href": "", "@Rel": "self"}, {"@Href": "", "@Rel": "related"}, {"@Href": "", "@Rel": "related"}, {"@Href": "", "@Rel": "alternate"}]}}})
city_data.append(get_all_data("references/cities/FRA", {"lang": "EN"}, access_token, False)[0])
save_data(OUTPUT_DIR, airport_data, "references/airports")
save_data(OUTPUT_DIR, city_data, "references/cities")

QUESTIONS = [
    ["references/countries", {"limit":100, "offset":0, "lang": "EN"}],
    ["references/airlines", {"limit":100, "offset":0, "lang": "EN"}],
    ["references/aircraft", {"limit":100, "offset":0}]
]

for q in QUESTIONS:
    data = get_all_data(q[0], q[1], access_token, True)
    save_data(OUTPUT_DIR, data, q[0])

print("Finished Monthly Import")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

from pyspark.sql.functions import explode, col

df_aircraft = spark.read.option("multiLine", "true") \
    .json("Files/lufthansa/references_aircraft.json")
df_airlines = spark.read.option("multiLine", "true") \
    .json("Files/lufthansa/references_airlines.json")
df_airports = spark.read.option("multiLine", "true") \
    .json("Files/lufthansa/references_airports.json")
df_cities = spark.read.option("multiLine", "true") \
    .json("Files/lufthansa/references_cities.json")
df_countries = spark.read.option("multiLine", "true") \
    .json("Files/lufthansa/references_countries.json")



df_aircraft = df_aircraft.select(explode("AircraftResource.AircraftSummaries.AircraftSummary").alias("aircraft")) \
    .select(
        col("aircraft.AircraftCode").alias("aircraft_code"),
        col("aircraft.Names.Name.$").alias("aircraft_name"),
        col("aircraft.AirlineEquipCode").alias("airline_equip_code"),
    )

df_airlines = df_airlines.select(explode("AirlineResource.Airlines.Airline").alias("airline")) \
    .select(
        col("airline.AirlineID").alias("airline_id"),
        col("airline.AirlineID_ICAO").alias("airline_id_icao"),
        col("airline.Names.Name.$").alias("airline_name")
    )

df_airports = df_airports.select("AirportResource.Airports.Airport").alias("airport") \
    .select(
        col("airport.AirportCode").alias("airport_code"),
        col("airport.Position.Coordinate.Latitude").alias("latitude"),
        col("airport.Position.Coordinate.Longitude").alias("longitude"),
        col("airport.CityCode").alias("city_code"),
        col("airport.CountryCode").alias("country_code"),
        col("airport.LocationType").alias("location_type"),
        col("airport.Names.Name.$").alias("airport_name"),
        col("airport.UtcOffset").alias("utc_offset"),
        col("airport.TimeZoneId").alias("time_zone_id")
    )

df_cities = df_cities.select(col("CityResource.Cities.City").alias("cities")) \
    .select(
        col("cities.CityCode").alias("city_code"),
        col("cities.CountryCode").alias("country_code"),
        col("cities.Names.Name.$").alias("city_name"),
        col("cities.UtcOffset").alias("utc_offset"),
        col("cities.TimeZoneId").alias("time_zone_id")
    )

df_countries = df_countries.select(explode("CountryResource.Countries.Country").alias("countries")) \
    .select(
        col("countries.CountryCode").alias("country_code"),
        col("countries.Names.Name.$").alias("country_name")
    )


df_aircraft.write.format("delta") \
    .mode("overwrite") \
    .saveAsTable("aircraft_delta")
df_airlines.write.format("delta") \
    .mode("overwrite") \
    .saveAsTable("airlines_delta")
df_airports.write.format("delta") \
    .mode("overwrite") \
    .saveAsTable("airports_delta")
df_cities.write.format("delta") \
    .mode("overwrite") \
    .saveAsTable("cities_delta")
df_countries.write.format("delta") \
    .mode("overwrite") \
    .saveAsTable("countries_delta")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
