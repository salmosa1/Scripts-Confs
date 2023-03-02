-- Ejecutar la Query en el SQL del Docker

Use [Master]
DROP DATABASE [Cronuses]

USE [master]
RESTORE DATABASE [Cronuses] FROM  DISK = N'C:\temp\roca.bak' WITH  FILE = 1,  
MOVE N'Demo Database NAV (11-0)_Data' TO N'C:\Program Files\Microsoft SQL Server\MSSQL13.SQLEXPRESS\MSSQL\DATA\CronusES_Data.mdf',  
MOVE N'Demo Database NAV (11-0)_Log' TO N'C:\Program Files\Microsoft SQL Server\MSSQL13.SQLEXPRESS\MSSQL\DATA\CronusES_Log1.ldf',  NOUNLOAD,  STATS = 1

use [Cronuses]
delete from [dbo].[User]
delete from [dbo].[Access Control]
delete from [dbo].[User Property]
delete from [dbo].[Page Data Personalization]
delete from [dbo].[User Default Style Sheet]
delete from [dbo].[User Metadata]
delete from [dbo].[User Personalization]
