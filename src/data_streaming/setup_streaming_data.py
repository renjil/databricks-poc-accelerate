# Databricks notebook source
dbutils.widgets.text("location","")

# COMMAND ----------

pip install faker

# COMMAND ----------

import numpy as np
import pandas as pd
import random
from faker import Faker
fake = Faker()

# COMMAND ----------

def generate_weather_data(records):

  direction = ["North", "South", "East", "West"]
  weather_data = [{  
      "uuid": fake.uuid4(),
      "date": fake.date_this_year(),
      "time": fake.time(),
      "temperature": random.randrange(10, 40), 
      "weathercode": random.randrange(1, 10),
      "windspeed": float(random.randrange(214, 489))/100, 
      "winddirection": np.random.choice(direction),
      "humidity": random.randrange(1, 10)} for x in range(records)]  
  return weather_data

def generate_weather_json():
  w_pdf = pd.DataFrame(generate_weather_data(10))
  w_df = spark.createDataFrame(w_pdf)
  w_df.coalesce(1).write.mode('append').json(getArgument("location"))
  return getArgument("location")


# COMMAND ----------

# generate stream of data
import time

i = 0
while(i < 5):
  output_path = generate_weather_json()
  print(f"weather data written to {output_path}")
  i += 1
  time.sleep(5)
