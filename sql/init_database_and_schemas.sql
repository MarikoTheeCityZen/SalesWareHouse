--switch to master DB and create our DB iff it does not exist(Idempotency)
use master;
go

if DB_ID(N'SalesWH') IS NULL
begin
	CREATE DATABASE SalesWH;
end

--switch to our target DB and create our 4 schema layers iff they also dont exist

use SalesWH;
go

--mainly for data import/ingestation froum our csv files
if SCHEMA_ID(N'landing') is null
	exec('create schema landing;')
go
--holds original data as it comes
if SCHEMA_ID(N'bronze') is null
begin
	exec('CREATE SCHEMA bronze;')
end
go
--holds cleaned,transformed and validated data
if SCHEMA_ID(N'silver') is null
begin
	exec('CREATE SCHEMA silver;')
end
go
--holds the final data model
if SCHEMA_ID(N'gold') is null
begin
	exec('CREATE SCHEMA gold;')
end
go

--Holds logs for our etl pipeline
if SCHEMA_ID(N'etl') is null
begin
	exec('CREATE SCHEMA etl;')
end
