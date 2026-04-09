# Niagara Agriculture Database Design & Implementation

## Overview

This project presents the design and implementation of a relational database for an agricultural management system. The objective was to model and manage operational data related to farms, crops, suppliers, and inventory using SQL.

The project focuses on database design principles, data integrity enforcement, and analytical querying to support agricultural decision-making. The database was built using a structured relational model with clearly defined relationships, constraints, and optimized query structures.

---

## Objectives

The main goals of this project were:

- Design a normalized relational database schema for agricultural operations
- Implement the database structure using SQL Data Definition Language (DDL)
- Populate the database with synthetically generated operational data
- Develop SQL queries to retrieve and analyze agricultural information
- Demonstrate best practices in database design and data integrity management

---

## Technologies Used

- SQL
- Relational Database Design
- Data Definition Language (DDL)
- Data Manipulation Language (DML)
- ER Modeling
- Query Optimization

---

## Project Structure
```
niagara-agriculture-database
│
├── README.md
│
├── sql
│   ├── niagara_agriculture_schema.sql
│   ├── niagara_agriculture_data.sql
│   └── niagara_agriculture_queries.sql
│
├── diagrams
│   └── er_diagram.png
│
└── docs
    └── database_description.md
```

## Database Schema

The database schema defines the relational structure of the agricultural management system. It includes multiple interconnected tables representing key entities within agricultural operations.

Key design components include:

- **Primary keys** for unique entity identification  
- **Foreign key relationships** to enforce referential integrity  
- **Constraints** to maintain data consistency  
- **Indexes** to improve query performance  

The schema was designed following relational database normalization principles to reduce redundancy and improve data organization.

---

## Synthetic Data Generation

To simulate a realistic operational environment, synthetic data was generated and inserted into each table. This data represents typical agricultural management information such as:

- Farms and their locations
- Crop types and production data
- Inventory levels
- Supplier information
- Agricultural transactions

This allows the database to be used for query testing and analytical exploration.

---

## Analytical Queries

The project includes a set of SQL queries designed to extract meaningful insights from the database.

These queries demonstrate how the database can support operational analysis such as:

- Monitoring crop production levels
- Tracking inventory availability
- Evaluating supplier contributions
- Summarizing agricultural activity across farms

The queries make use of **joins, aggregations, filtering conditions, and grouping operations** to analyze the stored data.

---

## How to Run the Project

To reproduce the database and run the queries, execute the SQL scripts in the following order:

### Step 1 — Create the database schema

```
sql/niagara_agriculture_schema.sql
```

### Step 2 — Populate the database with data
```
sql/niagara_agriculture_data.sql
```
This script inserts synthetic data into each table.

### Step 3 — Execute analytical queries
```
sql/niagara_agriculture_queries.sql
```
This script contains the SQL queries used to extract operational insights from the database.

## Entity Relationship Diagram
The following ER diagram illustrates the structure and relationships between the entities in the database.

![ER Diagram](https://github.com/user-attachments/assets/c9880a1b-6c15-4033-b56b-297e4881d6e4)


## Key Learning Outcomes
Through this project, the following database and analytical skills were applied:

- Relational database design
- SQL schema implementation
- Data integrity enforcement using constraints
- Synthetic data generation
- Analytical query development
- Operational data analysis using SQL
