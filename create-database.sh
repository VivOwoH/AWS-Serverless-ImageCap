#!/bin/bash

# RDS connection details
DB_HOST="image-app-db.cqi7uwt3hkvj.us-east-1.rds.amazonaws.com"           # Replace with your RDS endpoint
DB_USER="admin"           # Your RDS admin username
DB_PASSWORD="imagePassword!"       # Your RDS password
SQL_COMMANDS=$(cat <<EOF
/*
  Database Creation Script for the Image Captioning App
*/

DROP DATABASE IF EXISTS image_caption_db;
CREATE DATABASE image_caption_db;
USE image_caption_db;

/* Create captions table with thumbnail support */
CREATE TABLE captions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    image_key VARCHAR(255) NOT NULL,
    caption TEXT,
    thumbnail_key VARCHAR(255),
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    caption_generated_at TIMESTAMP NULL,
    thumbnail_generated_at TIMESTAMP NULL
);

/* Create index for faster queries */
CREATE INDEX idx_uploaded_at ON captions(uploaded_at);
CREATE INDEX idx_image_key ON captions(image_key);
EOF
)

# Execute SQL commands
echo "Creating database and table..."
mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD -e "$SQL_COMMANDS"

# Check if the previous command was successful
if [ $? -eq 0 ]; then
    echo "Database and table created successfully!"
else
    echo "Error: Failed to create database and table. Please check the connection details and try again."
    exit 1
fi
