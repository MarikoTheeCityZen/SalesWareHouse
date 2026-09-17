# SalesWareHouse
**Using SQL entirely We are going to build a data warehouse for a small online platform. Main goal is to sharpen SQL skills as well as get the basic overview of data engineering. With the warehouse as our single point of truth we are going to create a BI dashboard for our platform.**

## Project Overview

The project demonstrates an end-to-end data pipeline using a layered warehouse architecture:

CSV Files
   ↓
Landing
   ↓
Bronze
   ↓
Silver
   ↓
Gold
   ↓
Analytics / Power BI

The goal is to take raw source data, clean and transform it, apply data quality checks, and produce a simple dimensional model for analysis.

## Architecture
Landing

The first layer where the CSV files are loaded with minimal changes. It acts as a temporary ingestion area.

Bronze

Stores the source data in the warehouse together with ingestion metadata such as load time and source system.

Silver

Contains cleaned and transformed data. This layer handles tasks such as:

Data cleaning and standardization
Duplicate handling
Data type conversion
Customer data integration
Product transformations
Product history using SCD Type 2
Data validation
Gold

Contains the final analytical model:

dim_customers
dim_products
fact_sales

The model is designed to support reporting and analytical queries.

## ETL

The pipeline is implemented using SQL Server stored procedures.

etl.load_bronze
       ↓
etl.load_silver
       ↓
etl.load_gold

The project currently uses full refresh loading.

Each pipeline execution is tracked using:

etl.batch_log
etl.table_log

These tables record load status, row counts, execution time, and errors.

## Tools
> SQL Server
> T-SQL
> SQL Server Management Studio
> CSV
> Power BI (for downstream analysis)

**The project is being developed incrementally with a focus on understanding the reasoning behind each stage of the data engineering process.**
