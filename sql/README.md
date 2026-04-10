# SQL Scripts

This directory contains the SQL scripts used to build, populate, and query the Niagara Agriculture Database.

The scripts are organized to allow the full database to be reproduced in a clear and sequential workflow.

---

## Files

### niagara_agriculture_schema.sql

This script creates the entire relational database schema.

It includes:

- Table creation statements
- Primary keys
- Foreign key relationships
- Constraints
- Indexes

The script defines the structural foundation of the agricultural management database and ensures referential integrity across all entities.

---

### niagara_agriculture_data.sql

This script populates the database with synthetically generated data.

The inserted records simulate real-world agricultural operations, including information related to:

- Farms
- Crops
- Inventory
- Suppliers
- Agricultural transactions

This dataset allows the database to be used for testing and analytical querying.

---

### niagara_agriculture_queries.sql

This script contains analytical SQL queries used to extract insights from the database.

The queries demonstrate how operational agricultural data can be analyzed to support decision-making. Examples include:

- Crop production summaries
- Inventory monitoring
- Supplier activity analysis
- Aggregated operational statistics

The queries make use of joins, aggregations, filtering conditions, and grouping operations.
