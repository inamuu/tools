# coding: utf-8

import os
import csv
import mysql.connector
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Retrieve MySQL connection info from .env
db_host = os.getenv('DB_HOST')
db_name = os.getenv('DB_NAME')
db_user = os.getenv('DB_USER')
db_password = os.getenv('DB_PASSWORD')

# Function to get the first record of a given table


def get_first_record(table, cursor):
    query = f"SELECT * FROM {table} ORDER BY 1 DESC LIMIT 1"
    cursor.execute(query)
    return cursor.fetchone()

# Main execution block


def main():
    # Connect to MySQL
    try:
        connection = mysql.connector.connect(
            host=db_host,
            user=db_user,
            database=db_name,
            password=db_password,
        )
    except mysql.connector.Error as e:
        print(f"Error connecting to MySQL: {e}")
        return

    cursor = connection.cursor()

    # Read table names from list.txt
    try:
        with open('files/list.txt', 'r') as file:
            tables = file.read().splitlines()
    except FileNotFoundError:
        print("list.txt not found.")
        return

    # Open a CSV file to write the records
    with open('files/output.csv', 'w', newline='', encoding='utf-8') as csv_file:
        csv_writer = csv.writer(csv_file)

        # Fetch the first record from each table and write to the CSV file
        for table in tables:
            try:
                record = get_first_record(table, cursor)
                csv_writer.writerow([table] + list(record))
                print(f"First record from {table} written to CSV.")
            except mysql.connector.Error as e:
                print(f"Error querying table {table}: {e}")

    cursor.close()
    connection.close()


# Run the main function
if __name__ == "__main__":
    main()
