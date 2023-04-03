-----------------xp_cmdshell
-- To allow advanced options to be changed.
EXEC sp_configure 'show advanced options', 1;
GO
-- To update the currently configured value for advanced options.
RECONFIGURE;
GO
-- To enable the feature.
EXEC sp_configure 'xp_cmdshell', 1;
GO
-- To update the currently configured value for this feature.
RECONFIGURE;
GO

--find locked processes
sp_who2 active

--Finding Old historic Queries

SELECT d.plan_handle ,
    d.sql_handle ,
    e.text,
    d.last_execution_time AS [Time]
FROM sys.dm_exec_query_stats d
        CROSS APPLY sys.dm_exec_sql_text(d.plan_handle) AS e
ORDER BY 
    d.last_execution_time DESC

--or


SELECT t.[text]
FROM sys.dm_exec_cached_plans AS p
CROSS APPLY sys.dm_exec_sql_text(p.plan_handle) AS t
WHERE t.[text] LIKE N'%RTA%';
--from http://stackoverflow.com/questions/5299669/how-to-see-query-history-in-sql-server-management-studio
--------------------------------------------
------See Old Queries

Use [GIS_Test]
SELECT execquery.last_execution_time AS [Date Time], execsql.text AS [Script]
FROM sys.dm_exec_query_stats AS execquery
CROSS APPLY sys.dm_exec_sql_text(execquery.sql_handle) AS execsql
ORDER BY execquery.last_execution_time DESC
=================================

===============
------======================------ Update All tables in a db
EXEC sp_MSforeachtable '
    begin
        ALTER TABLE ? ADD d_acres float ;
    end
'

EXEC sp_MSforeachtable '
    begin
        update ? set d_acres = shape.STArea ()/43560 ;
    end
'


------Find tables in a view 
SELECT *
FROM INFORMATION_SCHEMA.VIEWS
WHERE  VIEW_DEFINITION like '%[PARCELS_GCR_FINAL]%'

--enable external scripts for R
sp_configure 'external scripts enabled', 1;
RECONFIGURE WITH OVERRIDE;

---------Update Users and delete schemas
drop user [SBPG\jstopa]
drop schema gis

select DBPrincipal_2.nam[SBPG\etolle]
e as role, DBPrincipal_1.name as owner 
from sys.database_principals as DBPrincipal_1 inner join sys.database_principals as DBPrincipal_2 
on DBPrincipal_1.principal_id = DBPrincipal_2.owning_principal_id 
where DBPrincipal_1.name = 'gis'

select *
from information_schema.schemata
where schema_owner = '[SBPG\czeairs]'

USE [PublicWorks]
GO
ALTER AUTHORIZATION ON ROLE::[SBPG\czeairs] TO [dbo]

USE [PublicWorks]
GO
ALTER AUTHORIZATION ON SCHEMA::ESRIWriteData TO [dbo]
GO
========================================
------Ad Hoc
EXEC sp_configure 'show advanced options', 1
RECONFIGURE
GO
EXEC sp_configure 'ad hoc distributed queries', 1
RECONFIGURE
GO
EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1
GO
EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1
GO
--------------------------------

select @@version

SELECT name
FROM sys.schemas

--check permissions on a network or local drive
--http://www.anthonydebarros.com/2010/03/11/essential-sql-queries/

--Query to fetch the list of table that match a pattern
select *
from information_schema.tables
where table_name like '%Employee%'

--Query to fetch the list of Columns (with table info) that match a pattern.
select *
from information_schema.columns
where column_name like '%EmpId%'

-- using with to make queries easier
  with size as (select [nom_ent], fips, max (shape.STArea()) as maxarea  FROM [Working].[dbo].[DOYLE_MX_STATE] group by [nom_ent], fips)
  select * from [Working].[dbo].[DOYLE_MX_STATE] d 
  join size s 
  on s.maxarea = shape.STArea()
  order by d.fips

-- Query List tables ***** Works well but no sizes
SELECT *
FROM information_schema.tables

--calculate space of table
sp_spaceused
'CENSUS_HOUSE_ALASKA_SIMPLE'

--size for each table in a database
EXEC sp_MSforeachtable @command1="EXEC sp_spaceused '?'"
-----------------------------------------------------------------------
--Same as above but in table form
CREATE TABLE #f
(
    name VARCHAR(255),
    rows INT ,
    reserved varchar(255),
    data varchar(255),
    index_size varchar(255),
    unused varchar(255)
)
INSERT into #f
EXEC sp_MSForEachtable "sp_spaceused '?'"
SELECT *
FROM #f
DROP TABLE #f
-----------------------------------------------------------------------
--database size
EXEC  sp_databases
-- STFID 15 varchar
CONVERT
(VARCHAR
(15), CONVERT
(DECIMAL
(18,0), X.STFID))AS STFID,

--Does Table Exist
if exists (select 1
from INFORMATION_SCHEMA.TABLES
where TABLE_NAME = 'NJDataImport_Date_Geocoded_SJ')
    print 'Exists'

--Find tables with field name
SELECT t.name AS table_name, SCHEMA_NAME(schema_id) AS schema_name, c.name AS column_name
FROM sys.tables AS t INNER JOIN sys.columns c ON t.OBJECT_ID = c.OBJECT_ID
WHERE c.name LIKE '%Class ID%'
ORDER BY schema_name, table_name;

--- All database file sizes and names
SELECT db.name AS [DB Name]
, dbf.[physical_name] AS [File Name]
, dbf.[size] AS [File Size]
, db.[create_date] AS [Create Date]
, ss.[Last User Event]
, ss.[Last User Update]
FROM sys.[databases] AS db
    LEFT OUTER JOIN sys.[master_files] AS dbf ON [db].[database_id] = [dbf].[database_id]
    LEFT OUTER JOIN (SELECT database_id, max(last_user_update) AS [Last User Update], ISNULL(ISNULL(max(last_user_update),max([last_user_seek])),max([last_user_lookup])) AS [Last User Event]
    FROM sys.[dm_db_index_usage_stats]
    GROUP BY database_id) AS ss ON ss.[database_id] = db.[database_id]
ORDER BY db.[name],dbf.[physical_name]

-- Insert values in a table 
insert into [GIS_Test].[dbo].[AuctionList]
VALUES
    ('BER-400085' , '1')


--update records in the database
UPDATE    vwCurrent_Polling_Places_test
SET              ParishName = REPLACE(ParishName, 'LAFJDSKFJSDF' , 'LAFOURCHE')

--Delete Records from a table
DELETE FROM dbo.NORA_NEIGHBORHOOD WHERE Program = 'GNP'

--link server linkserver (one way only)
SELECT *
into [NJ_RAD_DATA].[temp].[NJDataImport_Geocoded_for_SQL082]
FROM
    [SQL08-dev-vm64].[NJ_RAD_Import].[Temp].[test]


--just show replaced records in database
SELECT 
(ParishName, 'LAFOURCHE', 'LAFJDSKFJSDF') AS Parish_Name, ParishName
FROM vwCurrent_Polling_Places_test

--copy a table
SELECT *
INTO newTable
FROM vwCurrent_Polling_Places

--datetime   http://www.sqlusa.com/bestpractices/datetimeconversion/
convert
(datetime, STUFF
(STUFF
(convert
(bigint,[DateValue]),5,0,'-'),8,0,'-') + ' ' +  [DepartTime],121 )


drop table #testTable


SELECT PrecinctValue, ParishName,
    Case ParishName
		When 'LAFOURCHE' Then 'LASDJFASDKLFASDFF'
		When 'Jefferson' then '2Jeff'
		Else ParishName
	End as test, PollPlaceName
dbo
.vwStateCountyID
into #testTable from vwCurrent_Polling_Places_test
Select t.*
from #testTable t

##Add column
ALTER TABLE FIC_NAMES
ADD
( 	Address_Error 	varchar
(150),
  		GeoAddress 			varchar
(150)
  		City 			varchar
(150)
  		State 			varchar
(150)
  		Zip 			varchar
(5)
  		Zip9 			varchar
(10) );

---Drop column
ALTER TABLE Sales
DROP COLUMN UnitPrice;


----Update records
Update  vwCurrent_Polling_Places_test
	Set ParishName = Case	
		When ParishName = 'LAFOURCHE' Then 'LASDJFASDKLFASDFF'
		When ParishName = 'Jefferson' then '2Jeff'
		Else ParishName
	End




when Residence_StreetName = 'LOUIS PRIMA DR W' then 'W LOUIS PRIMA DR' 
when Residence_StreetName = 'LOUIS PRIMA DR E' then 'E LOUIS PRIMA DR' 
when Residence_StreetName = 'MARTIN LUTHER KING JR ST' then 'MARTIN LUTHER KING JR BLVD' 
when Residence_StreetName = 'GEORGE NICK CONNOR DR' then 'NICK CONNOR DR' 
when Residence_StreetName = 'ORETHA C HALEY BLVD' then 'ORETHA CASTLE HALEY BLVD' 
when Residence_StreetName = 'PARKWOOD CT S' then 'S PARKWOOD CT' 
when Residence_StreetName = 'PARKWOOD CT N' then 'N PARKWOOD CT' 
when Residence_StreetName = 'PARKWOOD CT N' then 'E PARKWOOD CT' 
when Residence_StreetName = 'ALBA ROAD E' then 'E ALBA ROAD' 
when Residence_StreetName = 'ALBA ROAD W' then 'W ALBA ROAD' 
when Residence_StreetName = 'MARINERS COVE W' then 'W MARINERS COVE' 
when Residence_StreetName = 'MARINERS COVE E' then 'E MARINERS COVE' 
when Residence_StreetName = 'MARINERS COVE N' then 'N MARINERS COVE' 
when Residence_StreetName = 'MARINERS COVE S' then 'S MARINERS COVE' 
when Residence_StreetName = 'GENTILLY RD' then 'OLD GENTILLY RD' 
when Residence_StreetName = 'BISHOP C L MORTON SR DR' then 'BISHOP MORTON DR' 
when Residence_StreetName = 'ALBA ROAD E' then 'E ALBA ROAD' 
when Residence_StreetName = 'ALBA ROAD W' then 'W ALBA ROAD' 
when Residence_StreetName = 'CLEMATIS AVE' then 'CLEMATIS ST' 
when Residence_StreetName = 'Route 6' then 'Ridgeway Blvd (Highway 11)' 
when Residence_StreetName = 'VELIE ST' then 'VALIE ST' 
when Residence_StreetName = 'OCEAN ST' then 'BISHOP MORTON DR' 
when Residence_StreetName = '1-10 SERVICE RD' then 'I-10 SERVICE RD' 
when Residence_StreetName = 'BEHRMAN AVE' then 'BEHRMAN HWY' 
when Residence_StreetName = 'GUILDFORD RD' then 'GUILFORD RD'


------Als query to create a master table on unique values
INSERT INTO PostalMaster
SELECT
    Distinct JoinField
from p0106

INSERT INTO PostalMaster
SELECT
    Distinct JoinField
from p0705
WHERE 
	Joinfield not in (select joinfield
from postalmaster)


--------Update Geocode Addresses
Update  dbo.ENTERGYACCOUNTSREGEOCODES20100819GC
	Set ARC_Street = Case	
When Arc_street like'%E Beauregard St%' then replace (arc_street , 'E Beauregard St','Beauregard St E')

		Else Arc_street
	End

--------Query Table Names	
select *
from INFORMATION_SCHEMA.TABLES
where TABLE_SCHEMA = 'dbo' and TABLE_NAME like '%_Pin%'
order by TABLE_NAME


-----reduce shapes geometry
UPDATE dbo.SEAFARERSSTATES

SET
ShapeSimple = Shape.Reduce(.001)



----Building Spatial Index
CREATE SPATIAL INDEX [IX_Spatial_SEAFARERSMARINERMAPPINGDATAGCJOIN] ON dbo.SEAFARERSMARINERMAPPINGDATAGCJOIN
(
Shape
)USING GEOMETRY_GRID
WITH (
BOUNDING_BOX =(-20299072.8819782, 1653639.52513546, -4765856.16901563, 9948455.50283838), GRIDS =(LEVEL_1 = MEDIUM,LEVEL_2 = MEDIUM,LEVEL_3 = MEDIUM,LEVEL_4 = MEDIUM),
CELLS_PER_OBJECT = 16, PAD_INDEX = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
----Building Spatial Index for Louisiana
CREATE SPATIAL INDEX [IX_Spatial_SEAFARERSMARINERMAPPINGDATAGCJOIN] ON dbo.SEAFARERSMARINERMAPPINGDATAGCJOIN
(
Shape
)USING GEOMETRY_GRID
WITH (
BOUNDING_BOX =(-94.1, 28.7, -88.7, 33.1)
		, GRIDS =(LEVEL_1 = MEDIUM,LEVEL_2 = MEDIUM,LEVEL_3 = MEDIUM,LEVEL_4 = MEDIUM)
		, CELLS_PER_OBJECT = 16
		, PAD_INDEX = OFF
		, SORT_IN_TEMPDB = OFF
		, DROP_EXISTING = OFF
		, ALLOW_ROW_LOCKS = ON
		, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

------ Randy Spatial Index

--CREATE A SPATIAL INDEX ON POLYGON SHAPE COLUMN
if exists (select name
from sysindexes
where name = 'sidx_Shape_CensusByBlock')
       begin
    drop index sidx_Shape_CensusByBlock  ON [Private.Data].[CensusByBlock]
end

declare @strSQL nvarchar(500),@MinX as varchar(10), @MinY as varchar(10), @MaxX as varchar(10), @MaxY as varchar(10)
SET @MinX = (select MIN(shape.STEnvelope().STPointN(1).STX)
from [Private.Data].[CensusByBlock])
SET @MinY = (select MIN(shape.STEnvelope().STPointN(1).STY)
from [Private.Data].[CensusByBlock])
SET @MaxX = (select MAX(shape.STEnvelope().STPointN(3).STX)
from [Private.Data].[CensusByBlock])
SET @MaxY = (select MAX(shape.STEnvelope().STPointN(3).STY)
from [Private.Data].[CensusByBlock])

set @strSQL = 'create SPATIAL INDEX sidx_Shape_CensusByBlock ON [Private.Data].[CensusByBlock](Shape) 
WITH (BOUNDING_BOX = (' + @MinX + ', ' + @MinY + ', ' + @MaxX + ', ' + @MaxY + '))'

exec sp_executesql @strSQL



--CREATE A SPATIAL INDEX ON POINT SHAPE COLUMN
if exists (select name
from sysindexes
where name = 'sidx_gnis_ptsintrest')
       begin
    drop index sidx_gnis_ptsintrest  ON [Private].[gnis_ptsintrest]
end

declare @strSQL nvarchar(500),@MinX as varchar(10), @MinY as varchar(10), @MaxX as varchar(10), @MaxY as varchar(10)
SET @MinX = (select MIN(Shape.STX)
from [Private].[gnis_ptsintrest])
SET @MinY = (select MIN(Shape.STY)
from [Private].[gnis_ptsintrest])
SET @MaxX = (select MAX(Shape.STX)
from [Private].[gnis_ptsintrest])
SET @MaxY = (select MAX(Shape.STY)
from [Private].[gnis_ptsintrest])

set @strSQL = 'create SPATIAL INDEX sidx_gnis_ptsintrest ON [Private].[gnis_ptsintrest](Shape) 
WITH (BOUNDING_BOX = (' + @MinX + ', ' + @MinY + ', ' + @MaxX + ', ' + @MaxY + '))'

exec sp_executesql @strSQL
 
 MS
Excel Function for calculating percentiles.
 =
IF(B3 < PERCENTILE.INC(B:
B,0.1), 1,
IF(AND(B3<PERCENTILE.INC(B:B,0.2),B3>PERCENTILE.INC
(
B:
B,0.1)),2,
IF(AND(B3<PERCENTILE.INC(B:B,0.3),B3>PERCENTILE.INC
(
B:
B,0.2)),3,
IF(AND(B3<PERCENTILE.INC(B:B,0.4),B3>PERCENTILE.INC
(
B:
B,0.3)),4,
IF(AND(B3<PERCENTILE.INC(B:B,0.5),B3>PERCENTILE.INC
(
B:
B,0.4)),5,
IF(AND(B3<PERCENTILE.INC(B:B,0.6),B3>PERCENTILE.INC
(
B:
B,0.5)),6,
IF(AND(B3<PERCENTILE.INC(B:B,0.7),B3>PERCENTILE.INC
(
B:
B,0.6)),7,
IF(AND(B3<PERCENTILE.INC(B:B,0.8),B3>PERCENTILE.INC
(
B:
B,0.7)),8,
IF(AND(B3<PERCENTILE.INC(B:B,0.9),B3>PERCENTILE.INC
(
B:
B,0.8)),9,
IF(AND(B3<PERCENTILE.INC(B:B,1.0),B3>PERCENTILE.INC
(
B:
B,0.9)),10,0))))))))))

--Ntile quantile rank percentile
SELECT
    GeoID,
    Hispanic,
    NTILE(10) OVER(ORDER BY Hispanic) AS Tier
FROM
    GIS.dbo.vwSolarAttributes
ORDER BY
	Hispanic
--------------------------------PERCENTILE_CONT (continuous  or PERCENTILE_DISC 
select
    PERCENTILE_CONT (0.5) within group  (ORDER BY GrassCut) over (PARTITION BY grasscut) as Val
	, NTILE(2) OVER (ORDER BY GrassCut) AS Tier
from temp.[dbo].[ProblemPointsBG]
) as c
	where Tier =1
---------------------------

UPDATE    dbo.OCDPROGRAMADDRESSESGCREDO20120217
SET         dbo.OCDPROGRAMADDRESSESGCREDO20120217.Loc_name  =   dbo.OCD_PROGRAMADDRESSGEOCODES20120222.Loc_name ,
dbo.OCDPROGRAMADDRESSESGCREDO20120217.Status  = dbo.OCD_PROGRAMADDRESSGEOCODES20120222.Status,
dbo.OCDPROGRAMADDRESSESGCREDO20120217.Score  = dbo.OCD_PROGRAMADDRESSGEOCODES20120222.Score,
dbo.OCDPROGRAMADDRESSESGCREDO20120217.Match_type  = dbo.OCD_PROGRAMADDRESSGEOCODES20120222.Match_type,
dbo.OCDPROGRAMADDRESSESGCREDO20120217.Match_addr  = dbo.OCD_PROGRAMADDRESSGEOCODES20120222.Match_addr,
dbo.OCDPROGRAMADDRESSESGCREDO20120217.X  = dbo.OCD_PROGRAMADDRESSGEOCODES20120222.X,
dbo.OCDPROGRAMADDRESSESGCREDO20120217.Y  = dbo.OCD_PROGRAMADDRESSGEOCODES20120222.Y,
dbo.OCDPROGRAMADDRESSESGCREDO20120217.ARC_Street  = dbo.OCD_PROGRAMADDRESSGEOCODES20120222.ARC_Street,
dbo.OCDPROGRAMADDRESSESGCREDO20120217.Shape  = dbo.OCD_PROGRAMADDRESSGEOCODES20120222.Shape
FROM dbo.OCDPROGRAMADDRESSESGCREDO20120217 INNER JOIN
    dbo.OCD_PROGRAMADDRESSGEOCODES20120222 ON 
                      dbo.OCDPROGRAMADDRESSESGCREDO20120217.pkAddressID = dbo.OCD_PROGRAMADDRESSGEOCODES20120222.pkAddressI AND
        dbo.OCDPROGRAMADDRESSESGCREDO20120217.fkApplicationID = dbo.OCD_PROGRAMADDRESSGEOCODES20120222.fkApplicat


--Get List of Values as a table
select distinct *
from (values
        ('400320'),
        ('226412'),
        ('400138'),
        ('400520'),
        ('024952'),
        ('228079')) as C(x)

UPDATE              OCD_GEOCODES_PREK_VALASSIS_JEFFERSON
SET                      


 Loc_name = B.Loc_name
, Status =B.Status
, Score =B.Score
, Match_type =B.Match_type
, Match_addr =B.Match_addr
, Side =B.Side
, X =B.X
, Y =B.Y
, Shape =B.Shape
FROM
    OCD_GEOCODES_PREK_VALASSIS_JEFFERSON
    INNER JOIN
    OCD_GEOCODES_PREK_VALASSIS_JEFFERSON_REGEOCODE AS B
    ON OCD_GEOCODES_PREK_VALASSIS_JEFFERSON.OBJECTID_1 = B.OBJECTID_1
where B.BadGeoCode <> 1


ALTER SCHEMA TargetSchema TRANSFER SourceSchema.TableName;
ALTER SCHEMA Data TRANSFER dbo.RepublicanPrimary2012
SELECT *
FROM sys.schemas

--Transactions for Update Statements
BEGIN TRAN
update aa set City='chennai',LastName='vinoth';
-- if update is what you want then
COMMIT TRAN
-- if NOT then
ROLLBACK

--Updating shape from x and y
UPDATE [dbo].[LHCGeocodes20121023] --[ElectionDEMO].[import].[NM_PollingPlaces]
SET [Shape] = geometry::STPointFromText('POINT(' + CAST([X] AS VARCHAR(20)) + ' ' + CAST([Y] AS VARCHAR(20)) + ')', 4269)
-- 3857 for WebMerc
-- 3452 for state plane

--update X and Y from Shape
update  [dbo].[gretnaaddrpts18feb2014] set Y = [ogr_geometry].STY

SELECT
    Shape.STSrid,
    COUNT(*)
FROM
    [NOLA_SchoolEnrollment].[import].[OPSBSTUDENTS20120411_Standardized]
GROUP BY
	Shape.STSrid

UPDATE
	[NOLA_SchoolEnrollment].[import].[OPSBSTUDENTS20120411_Standardized]
SET
	Shape.STSrid = 4269

SELECT [shape].STAsText() as WKT
from [gis].[dbo].[PRBusinessHooversData]
SELECT [shape].ToString() as WKT
from [gis].[dbo].[PRBusinessHooversData]
SELECT [shape].STY as WKT
from [gis].[dbo].[PRBusinessHooversData]

select shape.AsTextZM()
FROM [MEM].[dbo].[PART77SURFACE]
select shape.STAsText()
FROM [MEM].[dbo].[PART77SURFACE]
select shape.ToString()
FROM [MEM].[dbo].[PART77SURFACE]
POLYGON
(
(-89.982999999999947 35.082517920000157 470.60000000000582, -89.978000000000009 35.055119750000244 270.60000000000582, -89.974999999999966 35.055167470000072 270.60000000000582, -89.96999999999997 35.082708640000135 470.60000000000582, -89.982999999999947 35.082517920000157 470.60000000000582))
POLYGON
((-89.982999999999947 35.082517920000157, -89.978000000000009 35.055119750000244, -89.974999999999966 35.055167470000072, -89.96999999999997 35.082708640000135, -89.982999999999947 35.082517920000157))
POLYGON
((-89.982999999999947 35.082517920000157 470.60000000000582, -89.978000000000009 35.055119750000244 270.60000000000582, -89.974999999999966 35.055167470000072 270.60000000000582, -89.96999999999997 35.082708640000135 470.60000000000582, -89.982999999999947 35.082517920000157 470.60000000000582))
geometry::STGeomFromText

select *

--Zoneupdates
DELETE
[Private.Data].SettlementZones
WHERE
SettlementZoneID > = 54035 AND SettlementZoneID <= 54110

INSERT INTO
[Private.Data].SettlementZones
SELECT
    3,
    CASE WHEN Zone = 'A' THEN 'Economic Damage Zone A'
WHEN Zone = 'B' THEN 'Economic Damage Zone B'
WHEN Zone = 'C' THEN 'Economic Damage Zone C' END,
    Category + ': ' + Descriptio,
    Shape
FROM
    Sde.dbo.[BP_ECONOMICLOSSZONESUPDATED]
------------------------------------------------------------------------------------------------  sctmsadmin


----------------

DELETE
[Private.Data].SettlementZones
WHERE
SettlementZoneID > = 54035 AND SettlementZoneID <= 54110

INSERT INTO
[Private.Data].SettlementZones
SELECT
    3,
    Category,
    Descriptio,
    Shape
FROM
    Sde.sde.[BP_ECONOMICLOSSZONESUPDATED]


---------ReIndex full DATABASE
USE [GIS_Test] 
 GO
EXEC sp_MSforeachtable @command1="print '?' DBCC DBREINDEX ('?', ' ', 80)"
 GO
EXEC sp_updatestats
GO


---shrink files...
USE [excelTest];
GO
-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE [excelTest]
SET RECOVERY SIMPLE;
GO
-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE ([excelTest]
_Log, 1);
GO
-- Reset the database recovery model.
ALTER DATABASE [excelTest]
SET RECOVERY FULL;
GO


--------------Doyle Shrink File -----------------

---shrink files...
USE [Testing];
GO
-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE [Testing]
SET RECOVERY SIMPLE;
GO
-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (Testing_Log, 1);
GO
-- Reset the database recovery model.
ALTER DATABASE [Testing]
SET RECOVERY FULL;
GO


---shrink files...
USE [excelTest];
GO
-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE [excelTest]
SET RECOVERY SIMPLE;
GO
-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE ([excelTest]
_Log, 1);
GO
-- Reset the database recovery model.
ALTER DATABASE [excelTest]
SET RECOVERY FULL;
GO


-- get envelope
SELECT geometry::EnvelopeAggregate(Shape).STPointN(1).STX AS MinX,
    geometry::EnvelopeAggregate(Shape).STPointN(1).STY AS MinY,
    geometry::EnvelopeAggregate(Shape).STPointN(3).STX AS MaxX,
    geometry::EnvelopeAggregate(Shape).STPointN(3).STY AS MaxX
FROM trash.rb_AL092012INITIALRADII


--ShapeValid 
select [Shape].IsValidDetailed()
from ____
-- for SQL2012
select [Shape].IsValid()
from ____

--Label Point
select shape.STPointOnSurface().ToString()
from [test03].[dbo].[PARCELS]
--Spatial Join on centroid 
on C.Shape.STIntersects
(P.Shape.STPointOnSurface
()) = 1 and DISTRICT = 'A'


--Union Shapes UnionAggregate http://msdn.microsoft.com/en-us/library/ff929295.aspx and http://www.gisdoctor.com/site/2012/01/30/spatial-sql-geographer-%E2%80%93-part-3-%E2%80%93-basic-spatial-sql-scripts/
SELECT
    Name,
    geometry::UnionAggregate(shape) AS Shape
FROM
    [dbo].[NEIGHBORHOODCENTROIDTRAVELSHED_UNION]
where Name = 'Acipco-Finley : 0 - 30'
GROUP BY
	Name

-- geometry types
SELECT 'Polygon' AS gtype, count (*), [ShapeValid].STGeometryType()
from [test].[temp2].[ClaimGeometries_20140929_Special_Version2]
group by [ShapeValid].STGeometryType()

--UPDATE COLUMN BASED ON A "SPATIAL JOIN"
UPDATE A
SET A.STFID = B.GEOID10 FROM import.active_retailers A JOIN import.LOTTERYME_BLOCKS B
    ON A.ogr_geometry.STIntersects(B.Shape) = 1

--SpatialJoins
select
    A.[GEOID10]
		, B.[NAME] as PlaceName
		, B.[NAMELSAD] as PlaceFullName 
		, B.[LSAD] as PlaceType
		, C.[ZCTA5CE10] as Zip
FROM [Census].[TL_2010_10_TABBLOCK10] A
    left outer JOIN [Census].[TL_2013_10_PLACE] B
    ON A.ShapeCentroid.STIntersects(B.Shape) = 1
    left outer join [Census].[TL2013_DE_ZCTA510] C
    on A.ShapeCentroid.STIntersects (C.Shape) = 1

--Spatial Join Intersects
SELECT
    G.ID,
    G.ClaimID,
    J.[Jurisdicti],--Jurisdiction,
    G.Shape.STIntersection(J.Shape) AS Shape
FROM
    [dbo].[GISCLOSURESPECIALINTERSECT2] G
    LEFT OUTER JOIN
    [dbo].[GISCLOSUREAREASDISSOLVED] J
    ON
        J.Shape.STIntersects(G.Shape) = 1


UPDATE       LHCGeocodesComplete
SET                Loc_name = JGC.Loc_name, X = JGC.x, Y = JGC.y
FROM LHCGeocodesComplete INNER JOIN
    lhcjeffersonaddrgeocodes  JGC ON LHCGeocodesComplete.StateID = JGC.stateid
WHERE        (JGC.Status <> 'U') and LHCGeocodesComplete.[Loc_name] not in ('US_RoofTop', 'PointAddress')


UPDATE       LHCGeocodesComplete
SET                Loc_name = 'OrleansAddPnt', X = OGC.x, Y = OGC.y
FROM LHCGeocodesComplete INNER JOIN
    [dbo].[lhcorleansaddrgeocodes]  OGC ON LHCGeocodesComplete.StateID = OGC.stateid
WHERE        (OGC.Status <> 'U')
--and  LHCGeocodesComplete.[Loc_name] not in ('US_RoofTop', 'PointAddress')



UPDATE    LHCGeocodesComplete
SET              Loc_name = REPLACE(REPLACE(Loc_name, 'StreetLocator' , 'JeffStreet'), 'HouseLocator' , 'JeffAddPt')


select count (*) , [Loc_name]
from [dbo].[LHCGeocodesComplete]
group by [Loc_name]



DELETE FROM dbo.LHCGeocodesComplete

insert into LHCGeocodesComplete
select *
from [dbo].[LHCGeocodes20121023]


--UPDATE COLUMN BASED ON A "SPATIAL JOIN"
UPDATE A
SET A.STFID = B.GEOID10 FROM [gdal].[dbo].[VacantAddress_Orleans2_2_20120801] A JOIN [gdal].[dbo].[censusblocks2010Orleans] B
    ON A.shape.STIntersects(B.ogr_geometry) = 1
where A.Y > 1

--Calculating Distance between two points
STU.Shape.STDistance
(SCH.Shape)*100/1.60934 as Distance

--Changing Users on database
exec sp_change_users_login 'UPDATE_ONE', 'sqluser', 'sqluser' -- change sqluser to desired user

--ACS DataImports
select  * INTO e20115de0103000  FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0','Text;database=
C:
\GIS\data\national\census\DE\Delaware_Tracts_Block_Groups_Only;HDR=No;FORMAT=Delimited
(,)', '
SELECT *
FROM [e20115de0103000.txt]
') AliasOfTxtFile
Exec SP_rename '[sql08gdal].[Census2010ACS5year].[e20105la0059000].[Column 6]','B19131001', 'COLUMN'; --Change Name of column first
ALTER TABLE [sql08gdal].[Census2010ACS5year].[e20105la0059000] ALTER COLUMN [B19131001] bigint	--Change Size of column next
UPDATE  Census2010ACS5year.e20105la0059000 SET B19202A001 = CONVERT(int, CASE B19202A001 WHEN '.' THEN NULL ELSE B19202A001 END) -- update columns that have periods
--Chas Census tract string
substring ([geoid], 8,5)+substring ([geoid], 23,10) as CensusTract 

--Excel Files
ALTER view [dbo].[VWpplaces] as SELECT * FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0','EXCEL 12.0;Database=
C:
\GIS\Projects\Elections\Pres_Poll_Places_Results.xlsx;HDR=YES;IMEX=1','
SELECT *
FROM [Sheet1$]
');


--DBF Files
SELECT *FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0','dBase IV;Database=
C:
\GIS\Projects\GCR\Mona\PLD','
SELECT *
FROM [PLDTaxes]
') AliasOfDBF

--TextFile
select * from openrowset('Microsoft.ACE.OLEDB.12.0','text;Database=
C:
\TEMP;HDR=Yes;Format=Delimited
(,)','
select *
from [DC12.csv]
') AliasOfTxtFile --or
select * from openrowset('Microsoft.ACE.OLEDB.12.0','text;Database=
C:
\TEMP','
select *
from [DC12.csv]
') AliasOfTxtFile
select * INTO BridgeInventory2012AK12 from openrowset('Microsoft.ACE.OLEDB.12.0','text;Database=
C:
\Users\rpoche\Google Drive\gcr\gis\2012NationalBridgeInventory','
select *
from AK12.txt
')AliasOfDBF

--Works Great 
select  * INTO temp  FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0','Text;Database=
C:
\GIS\data\national\census\ACS2011;HDR=No;FORMAT=Delimited
(,)', '
SELECT *
FROM [g20115la.csv]
') AliasOfTxtFile
--All into one Row
select  * INTO [dbo].g20095la3BULK  FROM OPENROWSET(BULK N'
C:
\GIS\Projects\WestJeff\CensusACS\Louisiana_Tracts_Block_Groups_Only2009\g20095la.txt',SINGLE_BLOB) AliasOfTxtFile
--FromExcel
SELECT * FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0', 'Excel 12.0;Database=
C:
\Users\file name.xslx,[Sheet1$])
--dbf files fox pro, not working because of driver not 64bit
select *
from
    openrowset('VFPOLEDB','C:\GIS\data\national\census\LA\STF3A1990\stf301la.dbf';'';
    '','SELECT * FROM stf301la')
CREATE TABLE [dbo].[g20115la]
(
    [Column 0] varchar(1270)
)
Format=TabDelimited
Format=Fixed
C:
\Users\rpoche\Downloads\zbp11detail
--Insert data quick from Excel
CREATE TABLE [dbo].[BPTable1]
(
    [ID] [int] NULL,
    [Company] [varchar](150) NULL,
    [Address] [varchar](150) NULL
    INSERT INTO [BPTable1]
        (types,color,size)
    VALUES
        ('golden', 'yellow\'
    s my favorite colour','large');
INSERT INTO [BPTable1] (types,color,size) VALUES ('mac','reddish','medium');

-- random letters
  select char(cast((90 - 65 )*rand() + 65 as integer))
--random letters in excel
=CHAR(RANDBETWEEN(65,90))&CHAR(RANDBETWEEN(65,90))&CHAR(RANDBETWEEN(65,90))&"-"&RANDBETWEEN(1,999)


---Joining on Likes
SELECT [dbo].[BPTable1].[Company], [dbo].[BPTable2].[Company] FROM [dbo].[BPTable1] FULL Outer JOIN [dbo].[BPTable2] ON [dbo].[BPTable2].[Company] LIKE  [dbo].[BPTable1].[Company]  + '%' --substring ([dbo].[BPTable1].[Company],1,50)  + '%'



-- Getting top 10% of records in each group
SELECT sum([AAPop18]) as maxAAPop, Precinct2011, parish
FROM [election].[dbo].[vwPrecinctRace] g1
WHERE sum([AAPop18])  IN ( SELECT TOP 10 PERCENT sum([AAPop18])  FROM [election].[dbo].[vwPrecinctRace] g2 WHERE g1.parish = g2.parish ORDER BY Score DESC )
ORDER BY maxAAPop DESC

-- or 
  SELECT * INTO PrecinctMinorityCalc2 from (
 SELECT  [minPer], Precinct2011, parish
FROM  [dbo].[PrecinctMinorityCalc] g1
WHERE [minPer]  IN ( SELECT TOP 10 PERCENT [minPer]  FROM [election]. [dbo].[PrecinctMinorityCalc] g2 WHERE g1.parish = g2.parish ORDER BY [minPer] DESC )
) as A


--Divide by zero error
select ( [AAPop18] / nullif( [TotalPop18]*1.0, 0 ) ) AS minPer FROM [election].[dbo].[testTable]


-- better than convert cast 
where substring (str( la_rac_S000_JT00_2011.h_geocode,15),1,5) = '22071'

CREATE TABLE [dbo].[g20115la2] (
[Column 0] varchar(1270)
)

INSERT INTO [dbo].[g20115la2] select * from  OPENROWSET('Microsoft.ACE.OLEDB.12.0','Text;Database=
    C:
    \GIS\Projects\WestJeff\CensusACS\Louisiana_Tracts_Block_Groups_Only2009\;HDR=No;Format=FixedLength
    (1270)', '
    SELECT *
    FROM [g20095la.txt]
    ') AliasOfTxtFile
stf314ia
stf310ia
stf328ia
stf330ia
INSERT INTO [dbo].[stf310ia] SELECT * FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0','EXCEL 12.0;Database=\\ws-884bqw1\c$\GIS\projects\23088-WestJeff\Census1990\STF3\stf314ia.xls;HDR=YES;IMEX=1','
    SELECT *
    FROM [Sheet1$]
    ');

BULK INSERT g20115la3
   FROM '
    C:
    \GIS\Projects\WestJeff\CensusACS\Louisiana_Tracts_Block_Groups_Only2009\g20095la.txt';
   
   
 ---1990 Block Group STF3a data
     select  [STATEFP] + [CNTY]  + case when len ([TRACTBNA]) = 6 then [TRACTBNA] else [TRACTBNA] +'00'  end  + [BLCKGR]  as STFID FROM [WestJeff].[Census1990].[stf301la] where sumlev ='150'
	 
--------------Add multiple rows in one column
	 select convert (varchar (30), CAT.[RustID]) as strRustID
, stuff ((select ',' + convert (varchar (15), GCRID) as [text()] from [dbo].[GCRRustTranslationTable] tr  where CAT.[RustID] = TR.RustID 
for XML Path ('')),1,1,'') as GCRIDMulti
from [dbo].[GCRRustTranslationTable] CAT

---- combine values
    ,string_agg (g.gislink ,',') as gislink_parcel

    ---or ---- Stuff
	 select convert (varchar (30), Ref_ID) as ID
, stuff ((select ',' + convert (varchar (15),  PermitTypes) as [text()] from [test02].[dbo].[MPN_CODEENF_FINAL] tr  where CAT.Ref_ID = TR.Ref_ID 
for XML Path ('')),1,1,'') as GCRIDMulti
from [test02].[dbo].[MPN_CODEENF_FINAL] CAT
   where Ref_ID in (  16304,21491,23294,27297,13060,23748,16771,20008,22093,7979,15616,15693,11347,11397,9567)
order by Ref_ID

--measure of compactness
4*pi() * (a5.Shape.STArea() / power (convert (float, a5.Shape.STLength ( )),2) )  as shapescore


-------Add unique ID to view
SELECT convert (int, Row_number() OVER(ORDER BY [CRASH_NUM] ASC)) AS 'RowNumber', * from  (SELECT   * from table) X

http://msdn.microsoft.com/en-us/library/ms974559.aspx
http://www.connectionstrings.com/ace-oledb-12-0/
Server machine 'NJDCA1UATAPP09.FEDCLOUD.CGIPDC.CGINET' is currently being configured by another administrative operation. Please try again later.' 
4*pi() * (Shape.STArea() / power (convert (float, Shape.STLength ( )),2) ) between 0.48 and 1.0    --Measure of compactness
---ExcelStuff
="create table SignID (" &A3&" int NOT NULL, "&B3&" varchar(16) NULL, " &C3 &" varchar(32) NULL)" --For Creating tables
="Insert into SignCondition values ("&A5&",'"&B5&"',"&"'"&C5&"')"
    --For Inserting Values
    -- RUN AFTER STANDARDIZATION
    UPDATE
        [Elections].[import].[SOS_Voter_Registration_PreProcessed]
SET
        [ZP4_RHouseNumber] = LTRIM(RTRIM([ZP4_RHouseNumber])),
        [ZP4_RStreetDirection] = LTRIM(RTRIM([ZP4_RStreetDirection])),
        [ZP4_RStreetName] = LTRIM(RTRIM([ZP4_RStreetName])),
        [ZP4_RStreetPostDirection] = LTRIM(RTRIM([ZP4_RStreetPostDirection])),
        [ZP4_RStreetSuffix] = LTRIM(RTRIM([ZP4_RStreetSuffix]))
    UPDATE
        [Elections].[import].[SOS_Voter_Registration_PreProcessed]
SET
        GeoAddress = CASE WHEN LEN([ZP4_RHouseNumber]) > 0 THEN [ZP4_RHouseNumber] + ' ' ELSE '' END +
                                CASE WHEN LEN([ZP4_RStreetDirection]) > 0 THEN [ZP4_RStreetDirection] + ' ' ELSE '' END +
                                CASE WHEN LEN([ZP4_RStreetName]) > 0 THEN [ZP4_RStreetName] + ' ' ELSE '' END +
                                CASE WHEN LEN([ZP4_RStreetSuffix]) > 0 THEN [ZP4_RStreetSuffix] + ' ' ELSE '' END +
                                CASE WHEN LEN([ZP4_RStreetPostDirection]) > 0 THEN [ZP4_RStreetPostDirection] + ' ' ELSE '' END
								
								
Standard Deviation
    or calculating values
    with
        data
        as
        (
                            select 1 as num
            union all
                select 2 as num
        )
    select stDev (num)
    from data
    -------------------------------
    -------------------------------
    -------------------------------
    -------------------------------
    -------------------------------
    -- Al's Custom Geocoder
    -------------------------------
    --Grant Permissions on Database
    ALTER DATABASE gis SET TRUSTWORTHY ON
GO
    -- Turn on CLR
    sp_configure 'clr enabled', 1
GO
    RECONFIGURE
GO
    -------------------------------
    -------------------------------''//]]
    --Code to setup process (see email "FW: SQL CLR Geocode")
    ---
    -- sql query to get results
    DECLARE @GeocodeTable TABLE(
        geocode ESRIGEocodeResult)
    INSERT INTO
	@GeocodeTable
    SELECT
        gis.[dbo].[udfCLR_GeocodeAddress_MultipleInput]('1710 Robert St', 'New Orleans', 'LA', '70115')
    INSERT INTO
	@GeocodeTable
    SELECT
        gis.[dbo].[udfCLR_GeocodeAddress_SingleInput]('2606 Chester Street, Metairie, LA 70001')
    SELECT
        geocode.X,
        geocode.Y,
        geocode.shape,
        geocode.addressType AS AddressType,
        geocode.score AS Score,
        geocode.matchAddress AS MatchAddress
    FROM
        @GeocodeTable
    -------------------------------
    -------------------------------
    --DECLARE @test dbo.ESRIGeocodeResult;
    --SELECT @test = EntergyOutage.[dbo].[udfCLR_GeocodeAddress_NEW]('1710 robert st, new orleans la 70115')
    --SELECT @test.inputAddress, @test.matchAddress, @test.addressType, @test.X, @test.Y, @test.score, @test.shape


    DECLARE @GeocodeTable TABLE(
        ogr_fid int,
        geocode ESRIGEocodeResult)


    INSERT INTO
	@GeocodeTable
    SELECT
        ogr_fid, [dbo].[udfCLR_GeocodeAddress_MultipleInput]([p_add], [p_city], [p_state], [p_zip])
    from [gis].[dbo].[pubfac]



    SELECT
        ogr_fid,
        geocode.X as X,
        geocode.Y as Y,
        geocode.shape as Shape,
        geocode.addressType AS Loc_Name,
        geocode.score AS Score,
        geocode.matchAddress AS MatchAddress
    FROM
        @GeocodeTable



    DECLARE @GeocodeTable TABLE(
        [Institution_ID] varchar (250),
        [Institution_Name] varchar (250) ,
        [Institution_Address] varchar (250),
        geocode ESRIGEocodeResult)
    INSERT INTO
	@GeocodeTable
    SELECT
        [Institution_ID]
      , [Institution_Name], [Institution_Address]	, college.[dbo].[udfCLR_GeocodeAddress_MultipleInput](  [Institution_Address], [Institution_City] , [Institution_State], [Institution_Zip])
    from [Institutions]

    SELECT
        [Institution_ID]
      , [Institution_Name],
        [Institution_Address],
        geocode.X as X,
        geocode.Y as Y,
        geocode.shape as Shape,
        geocode.addressType AS Loc_Name,
        geocode.score AS Score,
        geocode.matchAddress AS MatchAddress
    into temp
    --drop table temp
    FROM
        @GeocodeTable

    -------------------------------




    DECLARE @GeocodeTable TABLE(
        [Institution_ID] varchar (250),
        [Campus_ID] varchar (250),
        [Campus_Name] varchar (250) ,
        [Campus_Address] varchar (250),
        geocode ESRIGEocodeResult)
    INSERT INTO
	@GeocodeTable
    SELECT --TOP (3)
        isnull ([Institution_ID],'0') , isnull ([Campus_ID],'0')
      , isnull ([Campus_Name],'0'), isnull ([Campus_Address],'0')	, college.[dbo].[udfCLR_GeocodeAddress_MultipleInput](  isnull ([Campus_Address],'0'), isnull([Campus_City],'0') , isnull([Campus_State],'0'), isnull([Campus_Zip],'0'))
    from [Campus]
    --	where convert (bigint,[Institution_ID]) -->= 300001--  between 123572 and 300000
    SELECT
        [Institution_ID]
	, [Campus_ID]
      , [Campus_Name],
        [Campus_Address],
        geocode.X as X,
        geocode.Y as Y,
        geocode.shape as Shape,
        geocode.addressType AS Loc_Name,
        geocode.score AS Score,
        geocode.matchAddress AS MatchAddress
    into temp_5
    --drop table temp_4
    FROM
        @GeocodeTable	

	--select distinct [Institution_Zip] from [Institutions] order by [Institution_Zip]

--Good Blog Posts
https://docs.microsoft.com/en-us/sql/relational-databases/spatial/query-spatial-data-for-nearest-neighbor?view=sql-server-ver15
https://tereshenkov.wordpress.com/
https://tereshenkov.wordpress.com/2015/02/05/sql-server-spatial-functions-for-gis-users/
https://tereshenkov.wordpress.com/2018/02/17/sql-server-spatial-functions-for-gis-users-part-2/


--update based on group by 
 update p  set p.assessorparcelnumber = grouped.Par
from MH_PROJECTS652_PARCELS p
join (  
select string_agg (PARCEL_ID,',') as par , gislink
 from [dbo].[MARYSVILLE2HYATT_OH_UNION_PARCELS] o
inner join MH_PROJECTS652_PARCELS p
on p.shape.STPointOnSurface().STIntersects (o.shape) = 1
group by p.gislink
) as grouped
on p.gislink = grouped.gislink


----remove spaces
select LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE('	 26-3.2-06-000-000-017.00',CHAR(10),'[]'),CHAR(13),'[]'),char(9),'[]'),CHAR(32),'[]'),'][',''),'[]',CHAR(32)))) as result
