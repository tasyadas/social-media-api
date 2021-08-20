# Social Media API

## Description
Social media application is used to share information with other people. This application will only be used by people that work in a certain company so we cannot use existing public social media.

## Prerequisites
1. Make new mysql database in your machine and import database_schema.sql
2. Setup database configuration by adding database name and password in .env-example and rename it to .env
3. Open your terminal and navigate to the current cloned repo, after that run `source .env`
4. run `bundle install` for installing all required dependencies
5. run `ruby main.rb`

## Run test suites and API

### Run test suites with rspec
Navigate to spec directory in your terminal and then you can run
#### rspec models/{modelname_spec}.rb
for test models file and
#### rspec controllers/{controllername_spec}.rb
for test controller file

### Run API
You can run the API by importing the postman collection provided in this repo into your postman app
