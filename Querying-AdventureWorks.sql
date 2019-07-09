/*
______          ______               _        
|  _  \         | ___ \             | |       
| | | |_____   _| |_/ /___  __ _  __| |_   _  
| | | / _ \ \ / /    // _ \/ _` |/ _` | | | | 
| |/ /  __/\ V /| |\ \  __/ (_| | (_| | |_| | 
|___/ \___| \_/ \_| \_\___|\__,_|\__,_|\__, | 
                                        __/ | 
                                       |___/  
*/

-- T-SQL Querying (AdventureWorks)


-- ========================
-- sp_*
-- ========================

-- Reports information about a specified database or all databases.
-- https://docs.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-helpdb-transact-sql
sp_helpdb 

-- Using sp_datatype_info to get the data type of a variable
-- https://docs.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-datatype-info-transact-sql
sp_datatype_info

-- sp_who: Provides information about current users, sessions, and processes in an instance of the Microsoft SQL Server Database Engine. 
-- https://docs.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-who-transact-sql
EXEC sp_who
EXEC sp_who 'active'
EXEC sp_who2

-- ========================
-- DBCC
-- ========================
-- Provides transaction log space usage statistics for all databases.
-- https://docs.microsoft.com/en-us/sql/t-sql/database-console-commands/dbcc-sqlperf-transact-sql
DBCC SQLPERF (LOGSPACE)

-- |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

-- ========================
-- System Catalog Views 
-- ========================

-- https://docs.microsoft.com/en-us/sql/relational-databases/system-catalog-views/catalog-views-transact-sql
/*
Catalog views return information that is used by the SQL Server Database Engine. 
We recommend that you use catalog views because they are the most general interface 
to the catalog metadata and provide the most efficient way to obtain, transform, 
and present customized forms of this information. All user-available catalog 
metadata is exposed through catalog views.
*/
SELECT name, user_access_desc, is_read_only, state_desc, recovery_model_desc  
FROM sys.databases;  



