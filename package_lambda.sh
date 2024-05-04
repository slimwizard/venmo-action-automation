#!/bin/bash

# Create and move to build directory
mkdir -p lambda_build
cd lambda_build || exit 1

# Install Python packages into the build directory
pip install -r ../../requirements.txt -t ./ > /dev/null 2>&1  # Suppress output

# Add the Lambda function code to the build directory
cp ../../handler.py ./

# Zip all contents
zip -r ../handler.zip ./* > /dev/null  # Suppress output
cd ..

# Remove the build directory
rm -rf lambda_build

# Output the path to the zip file in JSON format
echo "{\"zipfile\":\"./handler.zip\"}"
