# Maven Movies SQL Assignment

SQL assignment based on the **Maven Movies** database, covering subqueries, window functions, CTEs, views, and stored procedures.

##  Project Overview

This project contains solutions to 13 SQL questions from the Maven Movies database assignment.

### SQL Topics Covered
- Subqueries
- Common Table Expressions (CTEs)
- Window Functions
- RANK, DENSE_RANK, ROW_NUMBER and NTILE
- Views
- Stored Procedures
- Aggregate Functions
- JOINs
- GROUP BY and filtering

##  Assignment Questions

| # | Topic | Task |
|---|---|---|
| 1 | Subquery + CTE | Customers with rentals above the average |
| 2 | Window Function | Rank films by rental rate |
| 3 | View | Customer name, email and active status |
| 4 | Aggregation | Top 10 customers by payment amount |
| 5 | CTE + Window Function | Top 20% spending customers |
| 6 | Window Function | Actors ranked by movie count |
| 7 | View | Movie details with category and costs |
| 8 | Stored Procedure | Top 20 most rented movies |
| 9 | Stored Procedure | Movies based on rating |
| 10 | CTE + Window Function | Top 3 films in each category |
| 11 | Window Function | Running total of rentals by category |
| 12 | CTE + Self Join | Actor pairs appearing in the same film |
| 13 | Stored Procedure | Customer total payment using OUT parameter |

##  Database

**Database:** Maven Movies  
**SQL Version:** MySQL 8+

Select the database before running the assignment:

```sql
USE mavenmovies;
```

##  Project Structure

```text
Maven-Movies-SQL-Assignment/
│
├── Maven_Movies_SQL_Assignment.sql
└── README.md
```

##  How to Run

1. Open MySQL Workbench or another MySQL-compatible SQL editor.
2. Load the Maven Movies database.
3. Open `Maven_Movies_SQL_Assignment.sql`.
4. Run:
   ```sql
   USE mavenmovies;
   ```
5. Execute the questions one by one.
6. Check the output after each query.
7. For views and stored procedures, create them first and then run the test/call statements.

##  SQL Concepts Practiced

### Subqueries
Used to compare customer rental counts with the average rental count.

### CTEs
Used to break complex queries into readable steps.

Example:

```sql
WITH customer_rentals AS (
    SELECT customer_id, COUNT(*) AS rental_count
    FROM rental
    GROUP BY customer_id
)
```

### Window Functions

The project uses:

```sql
RANK()
DENSE_RANK()
ROW_NUMBER()
NTILE()
SUM() OVER()
```

These functions are used for ranking, grouping customers into spending segments, and calculating running totals.

### Views

Two reusable reporting views are created:

```text
customer_active_view
movie_details_view
```

### Stored Procedures

The project includes procedures for:

- Finding the top 20 most rented movies
- Finding movies by rating
- Calculating a customer's total payment using an OUT parameter

##  Learning Outcome

This assignment provides practical experience in SQL querying, reporting, ranking, data aggregation, and database programming using the Maven Movies dataset.

##  Author

**Raviranjan Gupta**

SQL / Data Analytics Learning Project