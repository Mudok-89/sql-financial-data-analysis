# SQL Financial Data Analysis

SQL project based on an anonymized financial dataset from a Czech bank. The analysis focuses on loans, clients, accounts, transactions, cards, and district-level financial insights.

## Project background
This project was completed as a final workshop in an SQL data analysis course. It uses an anonymized real-world financial dataset containing information about clients, accounts, loans, transactions, payment orders, cards, and districts.

## Project goal
The goal of the project was to practice analytical SQL on a realistic banking dataset and answer business-oriented questions related to loan history, repayment status, customer characteristics, and regional patterns.

## Analytical areas covered

### 1. Database exploration and relationship analysis
The project starts with exploration of the main tables and identification of primary and foreign keys across the financial database. It also includes validation of relationship types between selected entities such as accounts and transactions.

### 2. Loan history analysis
Analysis of granted loans over time, including:
- yearly trends
- quarterly trends
- monthly trends
- total loan volume
- average loan amount
- total number of granted loans

This part also uses `ROLLUP` to create hierarchical summaries.

### 3. Loan status analysis
Analysis of loan repayment status, including distinction between fully paid and unpaid loans based on status values.

### 4. Account and loan ranking
Analysis of accounts with fully repaid loans, including:
- number of loans per account
- total loan amount per account
- average loan amount
- ranking of accounts using window functions such as `DENSE_RANK()` and `ROW_NUMBER()`

### 5. Fully paid loans by gender
Analysis of fully repaid loan balances split by customer gender, including validation queries to verify correctness of joins and filters.

### 6. Client analysis
Customer-level analysis focused on:
- repaid loan amounts by gender
- comparison between male and female borrowers
- average borrower age by gender

### 7. District-level analysis
Regional analysis focused on:
- number of clients by district
- number of loans by district
- total loan amount by district
- district share of total repaid loan volume

This section combines multiple tables and uses both temporary tables and CTEs.

### 8. Conditional customer selection
Filtering and selecting customers based on multiple business conditions, such as:
- account balance
- number of loans
- birth year

This part also includes analysis of why a query may return an empty result set.

### 9. Expiring cards procedure
Creation of a stored procedure to build a table containing cards expiring within the current week, including client and district information.

## Files in this repository
- `financial_data_analysis.sql` – main SQL solution
- `project_brief.pdf` – original project brief
- `.csv` files – source data files used in the project

## Skills demonstrated
- SQL querying and database exploration
- identifying primary and foreign keys
- understanding table relationships
- filtering and aggregation
- `GROUP BY`, `HAVING`
- date functions (`YEAR`, `QUARTER`, `MONTH`, `EXTRACT`)
- `ROLLUP`
- multi-table `JOINs`
- Common Table Expressions (`CTEs`)
- temporary tables
- window functions (`DENSE_RANK`, `ROW_NUMBER`, `SUM() OVER`)
- business-oriented reporting
- validation and control queries
- customer and loan analysis
- district-level / regional analysis
- stored procedures
- debugging empty result sets
- financial domain analysis

## Business value
This project demonstrates how SQL can be used to answer practical analytical questions in the financial domain. The outputs can support reporting on loan performance, customer segmentation, repayment behavior, and regional lending activity.

## Dataset
The project uses an anonymized financial dataset from a Czech bank. The dataset includes information on:
- clients
- accounts
- loans
- transactions
- payment orders
- cards
- districts

## Notes
The original assignment is included in the repository as a separate PDF file.
