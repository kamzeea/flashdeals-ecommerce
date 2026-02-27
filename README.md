# FlashDeals E-Commerce Database System  
**Academic Database Systems Project | MySQL**

## Project Overview

FlashDeals is an academic **database systems** project focused on designing and analyzing a **relational database architecture** for a flash-sale e-commerce platform. The project was completed as part of **ITEC 445 – Database Systems II** and explores core enterprise database concepts including **schema normalization**, **transaction management**, **access control**, and **query performance optimization**.

The system models a **high-concurrency online marketplace** where database reliability, consistency, and efficient data retrieval are critical.

**Full Technical Report:**  
*(https://github.com/kamzeea/flashdeals-ecommerce-database-system/blob/main/docs/Flash%20Deals%20Final%20Report.docx)*

---

## Project Objectives

- Design a **normalized relational database schema** supporting e-commerce workflows  
- Explore database **security** and **role-based authorization** models  
- Analyze **query performance** using indexing strategies  
- Understand **ACID-compliant** transaction processing  
- Examine **concurrency control** and **isolation behavior** in MySQL  

---

## Technical Concepts Explored

### Relational Database Design

- **Entity–Relationship (ER) modeling**  
- **Third Normal Form (3NF)** normalization  
- **Primary and foreign key constraints**  
- **Referential integrity** enforcement  
- Logical **schema design**  

### SQL & Database Programming

- **Data Definition Language (DDL)**  
- **Data Manipulation Language (DML)**  
- **Stored procedures**  
- **Database triggers**  
- **Views** and abstraction layers  

### Transaction Management

- **ACID properties** (Atomicity, Consistency, Isolation, Durability)  
- Transaction boundaries: `BEGIN`, `COMMIT`, `ROLLBACK`  
- Isolation level comparison:  
  - `READ UNCOMMITTED`  
  - `READ COMMITTED`  
  - `REPEATABLE READ`  
  - `SERIALIZABLE`  
- Concurrency awareness and **locking** concepts  

### Performance Optimization Concepts

- **B-tree indexing** strategies  
- **Composite indexes**  
- **Covering indexes**  
- Query execution analysis using `EXPLAIN`  
- Reduction of **full table scans**  

### Database Security Concepts

- **Role-Based Access Control (RBAC)**  
- **Least-privilege** authorization model  
- **AES-based** data encryption concepts  
- **Audit logging** mechanisms  
- **Authentication tracking**  

---

## Technologies Used

- **MySQL 8.0**  
- **SQL**  
- **InnoDB** Storage Engine  
- **Stored Procedures & Triggers**  
- **Query Optimization** techniques  
- **GitHub** (version control)  

---

## System Architecture (High-Level)

The database schema contains multiple interconnected entities supporting core e-commerce operations:

- User **account management**  
- **Merchant** and **product** management  
- **Flash deal** lifecycle and scheduling  
- **Order processing** transactions  
- **Review** and **notification** systems  
- **Audit** and **security tracking** tables  

The schema follows **normalization principles** to minimize redundancy while preserving **transactional consistency**.

---

## Key Technical Implementations

- Multi-table **relational schema** design  
- Indexed **query optimization** experiments  
- **Transaction workflow** simulations  
- **Audit logging** via trigger-based mechanisms  
- **Role-based permission** structures  
- Demonstration of **concurrency scenarios**  

---

## Learning Outcomes

Through this project, I gained exposure to:

- **Enterprise-style database architecture**  
- **Query performance** considerations and indexing impact  
- **Transaction safety** and **isolation trade-offs**  
- **Security design** at the database layer  
- Challenges of **concurrent data modification**  

This experience strengthened my conceptual understanding of **database systems** and highlighted areas for continued hands-on development in **SQL** and database administration.

---

## Project Context

This was a **course-based academic implementation** intended to explore database engineering concepts. The focus was on **conceptual understanding and experimentation** rather than production deployment.
```
