USE [accessNewPIP]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--elect * from inspectionmain
CREATE PROCEDURE [dbo].[ALLSITES_BACKUP_AND_REFRESH]
AS 

 -- SELECT [PropID], COUNT([PropID]) AS CNT FROM GIS_ALLSITES_LIVEDATA GROUP BY [PropID] HAVING COUNT([PropID]) > 1 ORDER BY CNT DESC

 DECLARE @CurrentDate as varchar(8);
 SET @CurrentDate = CAST(YEAR(GETDATE()) as varchar(4)) + 
  RIGHT('0' + CAST(MONTH(GETDATE()) as varchar(2)), 2) + 
  RIGHT('0' + CAST(DAY(GETDATE()) as varchar(2)), 2);
 
 DECLARE @SQL nvarchar(120), @ALLSITES_COPY_TABLE nvarchar(48);
 
 SET @ALLSITES_COPY_TABLE = '[ALLSITES_GIS_' + @CurrentDate + ']';
 -- DROP TABLE @ALLSITES_COPY_TABLE;
 
 IF (SELECT OBJECT_ID(N'dbo.ALLSITES_GIS_' + @CurrentDate, N'U')) IS NULL
 BEGIN
    SET @SQL = 'SELECT * INTO ' + @ALLSITES_COPY_TABLE + ' FROM [ALLSITES_GIS]';
    exec sp_executesql @SQL;
 END
 
 DELETE FROM [ALLSITES_GIS];
 
 -- GlobalID, COMMISSIONDATE, GISDistrict, 
 INSERT INTO [ALLSITES_GIS] 
       ([SYSTEM], GISPROPNUM, Prop_ID, Name, LOCATION, [Table], GISACRES, 
        AMPSDistrictORIG, AMPSDistrict, COUNCILDISTRICT, COMMUNITYBOARD, BOROUGH, Zip, 
        GIS_Retired, SUBCATEGORY, PermitDistrict, TypeCategory, Jurisdiction, 
        NYSAssembly, NYSSenate, USCongress, Precinct)
 SELECT [SYSTEM], GISPROPNUM, PropID, Name, LOCATION, SourceTable, GISACRES, 
        AMPSDistrict,  dbo.FormatGisDistrict(ISNULL(AMPSDistrict, '')), 
        COUNCILDISTRICT, COMMUNITYBOARD, BOROUGH, Zip, 
        GIS_Retired, SUBCATEGORY, PermitDistrict, TYPECATEGORY, JURISDICTION, 
        NYSAssembly, NYSSenate, USCongress, dbo.intPrecinct(precinct) 
 FROM [GIS_ALLSITES_LIVEDATA];
 
 SELECT [Prop_ID], COUNT([Prop_ID]) AS CNT
 FROM [accessNewPIP].[dbo].[ALLSITES_GIS]
 GROUP BY [Prop_ID] HAVING COUNT([Prop_ID]) > 1 ORDER BY CNT DESC
GO


