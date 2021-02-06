USE [ParksGIS]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [DPR].[vw_PIP_Compatible_Inspected_Sites]
AS
SELECT        GISPROPNUM AS PropNum, OMPPROPID AS [Prop ID]/*, LEFT(DEPARTMENT,1) AS Boro*/ , LEFT(DEPARTMENT, 1) AS Boro, District, RIGHT(Department, 
                         LEN(Department) - CharIndex('-', Department)) AS AMPSDistrict, Prop_Name AS [Prop Name], Site_Name AS [Site Name], Prop_Location AS [Prop Location], 
                         Site_Location AS [Site Location], ROUND(ACRES, 3) AS Acres, Category, SUBCATEGORY AS [Sub-Category], Comments_1 AS Comments, 
                         CASE WHEN PIP_RATABLE LIKE 'Yes' THEN 1 /*ELSE 0*/ ELSE 0 END AS Rated, Reason_Not_Rated AS [Reason Not Rated], 
                         Sub_Properties_Rated AS [Sub-Properties Rated], Sub_Property AS [Sub-Property], Safety_Index AS [Safety Index], Map____Hagstrom_ AS [Map # (Hagstrom)], 
                         Map_Grid__Hagstrom_ AS [Map Grid (Hagstrom)], COUNCILDISTRICT AS [Council District], ZipCode, PIPZipCode, CommunityBoard, TypeCategory, Jurisdiction, 
                         NYS_ASSEMBLY AS [NYSAssembly], NYS_SENATE AS [NYSSenate], US_CONGRESS AS [USCongress], ComfortStation, CSCount, PIPCreated, NULL AS PIPCB, 
                         CAST(LEFT(SUBSTRING(Precinct, PATINDEX('%[0-9.-]%', Precinct), 8000), PATINDEX('%[^0-9.-]%', SUBSTRING(Precinct, PATINDEX('%[0-9.-]%', Precinct), 8000) + 'X') - 1)
                          AS INT) Precinct, created_date AS [GISCreated], RETIRED AS [GIS_Retired], District AS [GISDistrict], PERMITDISTRICT AS [PermitDistrict], Borough AS [GISBoro], 
                         LOCATION AS [GIS Site Location], 'Property' AS SourceFC, GISOBJID
FROM            ParksGIS.dpr.Property_EVW Prop
/*WHERE OMPPROPID IS NOT NULL*/ UNION ALL
SELECT        ParentID AS PropNum, OMPPROPID AS [Prop ID], LEFT(DEPARTMENT, 1) AS Boro, District, RIGHT(Department, LEN(Department) - CharIndex('-', Department)) 
                         AS AMPSDistrict, Prop_Name AS [Prop Name], Site_Name AS [Site Name], Prop_Location AS [Prop Location], Site_Location AS [Site Location], ROUND(ACRES, 3) 
                         AS Acres, Category, SUBCATEGORY AS [Sub-Category], Comments_1 AS Comments, CASE WHEN PIP_RATABLE LIKE 'Yes' THEN 1 ELSE 0 END AS Rated, 
                         Reason_Not_Rated AS [Reason Not Rated], Sub_Properties_Rated AS [Sub-Properties Rated], Sub_Property AS [Sub-Property], Safety_Index AS [Safety Index], 
                         Map____Hagstrom_ AS [Map # (Hagstrom)], Map_Grid__Hagstrom_ AS [Map Grid (Hagstrom)], COUNCILDISTRICT AS [Council District], ZipCode, PIPZipCode, 
                         CommunityBoard, TypeCategory, Jurisdiction, NYS_ASSEMBLY AS [NYSAssembly], NYS_SENATE AS [NYSSenate], US_CONGRESS AS [USCongress], 
                         ComfortStation, CSCount, PIPCreated, NULL AS PIPCB, CAST(LEFT(SUBSTRING(Precinct, PATINDEX('%[0-9.-]%', Precinct), 8000), PATINDEX('%[^0-9.-]%', 
                         SUBSTRING(Precinct, PATINDEX('%[0-9.-]%', Precinct), 8000) + 'X') - 1) AS INT) Precinct, created_date AS [GISCreated], RETIRED AS [GIS_Retired], 
                         District AS [GISDistrict], PERMITDISTRICT AS [PermitDistrict], Borough AS [GISBoro], LOCATION AS [GIS Site Location], 'Playground' AS SourceFC, GISOBJID
FROM            ParksGIS.dpr.Playground_EVW
/*WHERE OMPPROPID IS NOT NULL*/ UNION ALL
SELECT        GISPROPNUM AS PropNum, OMPPROPID AS [Prop ID], LEFT(DEPARTMENT, 1) AS Boro, District, RIGHT(Department, LEN(Department) - CharIndex('-', Department)) 
                         AS AMPSDistrict, Prop_Name AS [Prop Name], Site_Name AS [Site Name], Prop_Location AS [Prop Location], Site_Location AS [Site Location], ROUND(ACRES, 3) 
                         AS Acres, Category, SUBCATEGORY AS [Sub-Category], Comments_1 AS Comments, CASE WHEN PIP_RATABLE LIKE 'Yes' THEN 1 ELSE 0 END AS Rated, 
                         Reason_Not_Rated AS [Reason Not Rated], Sub_Properties_Rated AS [Sub-Properties Rated], Sub_Property AS [Sub-Property], Safety_Index AS [Safety Index], 
                         Map____Hagstrom_ AS [Map # (Hagstrom)], Map_Grid__Hagstrom_ AS [Map Grid (Hagstrom)], COUNCILDISTRICT AS [Council District], ZipCode, PIPZipCode, 
                         CommunityBoard, TypeCategory, Jurisdiction, NYS_ASSEMBLY AS [NYSAssembly], NYS_SENATE AS [NYSSenate], US_CONGRESS AS [USCongress], 
                         ComfortStation_1, CSCount, PIPCreated, NULL AS PIPCB, CAST(LEFT(SUBSTRING(Precinct, PATINDEX('%[0-9.-]%', Precinct), 8000), PATINDEX('%[^0-9.-]%', 
                         SUBSTRING(Precinct, PATINDEX('%[0-9.-]%', Precinct), 8000) + 'X') - 1) AS INT) Precinct, created_date AS [GISCreated], RETIRED AS [GIS_Retired], 
                         District AS [GISDistrict], PERMITDISTRICT AS [PermitDistrict], Borough AS [GISBoro], LOCATION AS [GIS Site Location], 'Greenstreet' AS SourceFC, GISOBJID
FROM            ParksGIS.dpr.GreenStreet_EVW
WHERE        OMPPROPID NOT LIKE 'XZ475' OR
                         RETIRED LIKE 'False'
/*AND OMPPROPID IS NOT NULL*/ UNION ALL
SELECT        ParentID AS PropNum, OMPPROPID AS [Prop ID], LEFT(DEPARTMENT, 1) AS Boro, District, RIGHT(Department, LEN(Department) - CharIndex('-', Department)) 
                         AS AMPSDistrict, Prop_Name AS [Prop Name], SITENAME AS [Site Name], Prop_Location AS [Prop Location], Site_Location AS [Site Location], ROUND(ACRES, 3) 
                         AS Acres, Category, SUBCATEGORY AS [Sub-Category], Comments_1 AS Comments, CASE WHEN PIP_RATABLE LIKE 'Yes' THEN 1 ELSE 0 END AS Rated, 
                         Reason_Not_Rated AS [Reason Not Rated], Sub_Properties_Rated AS [Sub-Properties Rated], Sub_Property AS [Sub-Property], Safety_Index AS [Safety Index], 
                         Map____Hagstrom_ AS [Map # (Hagstrom)], Map_Grid__Hagstrom_ AS [Map Grid (Hagstrom)], COUNCILDISTRICT AS [Council District], ZipCode, PIPZipCode, 
                         CommunityBoard, TypeCategory, Jurisdiction, NYS_ASSEMBLY AS [NYSAssembly], NYS_SENATE AS [NYSSenate], US_CONGRESS AS [USCongress], 
                         ComfortStation_1, CSCount, PIPCreated, NULL AS PIPCB, CAST(LEFT(SUBSTRING(Precinct, PATINDEX('%[0-9.-]%', Precinct), 8000), PATINDEX('%[^0-9.-]%', 
                         SUBSTRING(Precinct, PATINDEX('%[0-9.-]%', Precinct), 8000) + 'X') - 1) AS INT) Precinct, created_date AS [GISCreated], RETIRED AS [GIS_Retired], 
                         District AS [GISDistrict], PERMITDISTRICT AS [PermitDistrict], Borough AS [GISBoro], LOCATION AS [GIS Site Location], 'Zone' AS SourceFC, GISOBJID
FROM            ParksGIS.dpr.Zone_EVW
/*WHERE OMPPROPID IS NOT NULL*/ UNION ALL
SELECT        ParentID AS PropNum, OMPPROPID AS [Prop ID], LEFT(DEPARTMENT, 1) AS Boro, District, RIGHT(Department, LEN(Department) - CharIndex('-', Department)) 
                         AS AMPSDistrict, Prop_Name AS [Prop Name], Site_Name AS [Site Name], Prop_Location AS [Prop Location], Site_Location AS [Site Location], ROUND(ACRES, 3) 
                         AS Acres, Category, SUBCATEGORY AS [Sub-Category], Comments_1 AS Comments, CASE WHEN PIP_RATABLE LIKE 'Yes' THEN 1 ELSE 0 END AS Rated, 
                         Reason_Not_Rated AS [Reason Not Rated], Sub_Properties_Rated AS [Sub-Properties Rated], Sub_Property AS [Sub-Property], Safety_Index AS [Safety Index], 
                         Map____Hagstrom_ AS [Map # (Hagstrom)], Map_Grid__Hagstrom_ AS [Map Grid (Hagstrom)], COUNCILDISTRICT AS [Council District], ZipCode, PIPZipCode, 
                         CommunityBoard, TypeCategory, Jurisdiction, NYS_ASSEMBLY AS [NYSAssembly], NYS_SENATE AS [NYSSenate], US_CONGRESS AS [USCongress], 
                         ComfortStation, CSCount, PIPCreated, NULL AS PIPCB, CAST(LEFT(SUBSTRING(Precinct, PATINDEX('%[0-9.-]%', Precinct), 8000), PATINDEX('%[^0-9.-]%', 
                         SUBSTRING(Precinct, PATINDEX('%[0-9.-]%', Precinct), 8000) + 'X') - 1) AS INT) Precinct, created_date AS [GISCreated], RETIRED AS [GIS_Retired], 
                         District AS [GISDistrict], PERMITDISTRICT AS [PermitDistrict], Borough AS [GISBoro], LOCATION AS [GIS Site Location], 'GolfCourse' AS SourceFC, GISOBJID
FROM            ParksGIS.dpr.GolfCourse_EVW
/*WHERE OMPPROPID IS NOT NULL*/ UNION ALL
SELECT        GISPROPNUM AS PropNum, OMPPROPID AS [Prop ID], LEFT(DEPARTMENT, 1) AS Boro, District, RIGHT(Department, LEN(Department) - CharIndex('-', Department)) 
                         AS AMPSDistrict, Prop_Name AS [Prop Name], Site_Name AS [Site Name], Prop_Location AS [Prop Location], Site_Location AS [Site Location], ROUND(ACRES, 3) 
                         AS Acres, Category, SUBCATEGORY AS [Sub-Category], Comments_1 AS Comments, CASE WHEN PIP_RATABLE LIKE 'Yes' THEN 1 ELSE 0 END AS Rated, 
                         Reason_Not_Rated AS [Reason Not Rated], Sub_Properties_Rated AS [Sub-Properties Rated], Sub_Property AS [Sub-Property], Safety_Index AS [Safety Index], 
                         Map____Hagstrom_ AS [Map # (Hagstrom)], Map_Grid__Hagstrom_ AS [Map Grid (Hagstrom)], COUNCILDISTRICT AS [Council District], ZipCode, PIPZipCode, 
                         CommunityBoard, TypeCategory, Jurisdiction, NYS_ASSEMBLY AS [NYSAssembly], NYS_SENATE AS [NYSSenate], US_CONGRESS AS [USCongress], 
                         ComfortStation_1, CSCount, PIPCreated, NULL AS PIPCB, CAST(LEFT(SUBSTRING(Precinct, PATINDEX('%[0-9.-]%', Precinct), 8000), PATINDEX('%[^0-9.-]%', 
                         SUBSTRING(Precinct, PATINDEX('%[0-9.-]%', Precinct), 8000) + 'X') - 1) AS INT) Precinct, created_date AS [GISCreated], RETIRED AS [GIS_Retired], 
                         District AS [GISDistrict], PERMITDISTRICT AS [PermitDistrict], Borough AS [GISBoro], LOCATION AS [GIS Site Location], 
                         'Schoolyard To Playground' AS SourceFC, NULL AS GISOBJID
FROM            ParksGIS.dpr.Schoolyard_To_Playground_EVW
/*WHERE OMPPROPID IS NOT NULL*/ UNION ALL
SELECT        GISPROPNUM AS PropNum, OMPPROPID AS [Prop ID], LEFT(DEPARTMENT, 1) AS Boro, District, RIGHT(Department, LEN(Department) - CharIndex('-', Department)) 
                         AS AMPSDistrict, Prop_Name AS [Prop Name], Site_Name AS [Site Name], Prop_Location AS [Prop Location], Site_Location AS [Site Location], ROUND(ACRES, 3) 
                         AS Acres, Category, Sub_Category AS [Sub-Category], Comments_1 AS Comments, CASE WHEN PIP_RATABLE LIKE 'Yes' THEN 1 ELSE 0 END AS Rated, 
                         Reason_Not_Rated AS [Reason Not Rated], Sub_Properties_Rated AS [Sub-Properties Rated], Sub_Property AS [Sub-Property], Safety_Index AS [Safety Index], 
                         Map____Hagstrom_ AS [Map # (Hagstrom)], Map_Grid__Hagstrom_ AS [Map Grid (Hagstrom)], COUNCILDISTRICT AS [Council District], ZipCode, PIPZipCode, 
                         CommunityBoard, TypeCategory, Jurisdiction, NYS_ASSEMBLY AS [NYSAssembly], NYS_SENATE AS [NYSSenate], US_CONGRESS AS [USCongress], 
                         ComfortStation_1, CSCount, PIPCreated, NULL AS PIPCB, CAST(LEFT(SUBSTRING(Precinct, PATINDEX('%[0-9.-]%', Precinct), 8000), PATINDEX('%[^0-9.-]%', 
                         SUBSTRING(Precinct, PATINDEX('%[0-9.-]%', Precinct), 8000) + 'X') - 1) AS INT) Precinct, created_date AS [GISCreated], RETIRED AS [GIS_Retired], 
                         District AS [GISDistrict], PERMITDISTRICT AS [PermitDistrict], Borough AS [GISBoro], LOCATION AS [GIS Site Location], 'Structure' AS SourceFC, GISOBJID
FROM            ParksGIS.dpr.Structure_EVW
WHERE        PIP_RATABLE LIKE 'Yes'
/*AND OMPPROPID IS NOT NULL*/ UNION ALL
SELECT        GISPROPNUM AS PropNum, OMPPROPID AS [Prop ID], LEFT(DEPARTMENT, 1) AS Boro, 
                         District/*, RIGHT(Department,LEN(Department) - CharIndex('-',Department)) AS AMPSDistrict*/ , REPLACE(RIGHT(Department, LEN(Department) - CharIndex('-', 
                         Department)), '-', '') AS AMPSDistrict, Prop_Name AS [Prop Name], Site_Name AS [Site Name], Prop_Location AS [Prop Location], Site_Location AS [Site Location], 
                         ROUND(ACRES, 3) AS Acres, Category, SUBCATEGORY AS [Sub-Category], Comments AS Comments, 
                         CASE WHEN PIP_RATABLE LIKE 'Yes' THEN 1 ELSE 0 END AS Rated, Reason_Not_Rated AS [Reason Not Rated], Sub_Properties_Rated AS [Sub-Properties Rated], 
                         Sub_Property AS [Sub-Property], Safety_Index AS [Safety Index], Map____Hagstrom_ AS [Map # (Hagstrom)], Map_Grid__Hagstrom_ AS [Map Grid (Hagstrom)], 
                         COUNCILDISTRICT AS [Council District], ZipCode, PIPZipCode, CommunityBoard, TypeCategory, Jurisdiction, NYSAssembly, NYSSenate, USCongress, 
                         ComfortStation, CSCount, PIPCreated, NULL AS PIPCB, CAST(LEFT(SUBSTRING(Precinct, PATINDEX('%[0-9.-]%', Precinct), 8000), PATINDEX('%[^0-9.-]%', 
                         SUBSTRING(Precinct, PATINDEX('%[0-9.-]%', Precinct), 8000) + 'X') - 1) AS INT) Precinct/*, created_date AS [GISCreated]*/ , NULL AS [GISCreated], 
                         RETIRED AS [GIS_Retired], District AS [GISDistrict], PERMITDISTRICT AS [PermitDistrict], Borough AS [GISBoro], LOCATION AS [GIS Site Location], 
                         'Unmapped' AS SourceFC, NULL AS GISOBJID
FROM            ParksGIS.dpr.Unmapped_GISAllSites_evw
/*WHERE GISPROPNUM NOT IN ('BT02', 'BT04')*/ UNION ALL
SELECT        GISPROPNUM AS PropNum, OMPPROPID AS [Prop ID], LEFT(DEPARTMENT, 1) AS Boro, District, RIGHT(Department, LEN(Department) - CharIndex('-', Department)) 
                         AS AMPSDistrict, Prop_Name AS [Prop Name], Site_Name AS [Site Name], Prop_Location AS [Prop Location], Site_Location AS [Site Location], ROUND(ACRES, 3) 
                         AS Acres, Category, SUBCATEGORY AS [Sub-Category], Comments_1 AS Comments, CASE WHEN PIP_RATABLE LIKE 'Yes' THEN 1 ELSE 0 END AS Rated, 
                         Reason_Not_Rated AS [Reason Not Rated], Sub_Properties_Rated AS [Sub-Properties Rated], Sub_Property AS [Sub-Property], Safety_Index AS [Safety Index], 
                         Map____Hagstrom_ AS [Map # (Hagstrom)], Map_Grid__Hagstrom_ AS [Map Grid (Hagstrom)], COUNCILDISTRICT AS [Council District], ZipCode, PIPZipCode, 
                         CommunityBoard, TypeCategory, Jurisdiction, NYS_ASSEMBLY AS [NYSAssembly], NYS_SENATE AS [NYSSenate], US_CONGRESS AS [USCongress], 
                         ComfortStation_1, CSCount, PIPCreated, NULL AS PIPCB, CAST(LEFT(SUBSTRING(Precinct, PATINDEX('%[0-9.-]%', Precinct), 8000), PATINDEX('%[^0-9.-]%', 
                         SUBSTRING(Precinct, PATINDEX('%[0-9.-]%', Precinct), 8000) + 'X') - 1) AS INT) Precinct, created_date AS [GISCreated], RETIRED AS [GIS_Retired], 
                         District AS [GISDistrict], PERMITDISTRICT AS [PermitDistrict], Borough AS [GISBoro], LOCATION AS [GIS Site Location], 
                         'RestrictiveDeclarationSite' AS SourceFC, NULL AS GISOBJID
FROM            ParksGIS.dpr.RestrictiveDeclarationSite_EVW
WHERE        OMPPROPID NOT IN ('M404', 'B591', 'B595')

