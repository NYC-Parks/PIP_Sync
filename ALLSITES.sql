USE [accessNewPIP]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[ALLSITES] AS
SELECT TOP 100 PERCENT
	G.PropNum
	, A.[Prop ID]
	, G.Boro
	, G.District
	, G.AMPSDistrict
	, G.[Prop Name]
	, G.[Site Name]
	, G.[Prop Location]
	, G.[Site Location]
	, G.Acres --CAST(G.Acres AS REAL) AS Acres
	, G.Category
	, G.[Sub-Category]
	, G.Comments
	, G.Rated
	, G.[Reason Not Rated]
	, G.[Sub-Properties Rated]
	, G.[Sub-Property]

	, A.[GSGroupProject] 
	, A.[LastInspection]
	, A.[LastInspectDate]
	, A.[LastInspectedSeason]
	, A.[LastInspectedRound]
	, A.[LastInspectYear]
	, A.[Sort]

	, G.[Safety Index]
	, G.[Map # (Hagstrom)]
	, G.[Map Grid (Hagstrom)]
	, G.[Council District]
	, G.ZipCode
	, G.PIPZipCode
	, G.COMMUNITYBOARD
	, G.TypeCategory
	, G.Jurisdiction
	, G.[NYSAssembly]
    , G.[NYSSenate]
    , G.[USCongress]
	, G.Precinct
	, G.ComfortStation

	, G.CSCount
	, A.[Prop ID] AS PIP_PROP_ID
	, G.pipCreated
	, G.[GISCreated]
    , G.[GIS_Retired]
    , G.[GISDistrict]
    , G.[PermitDistrict]
    , G.[GISBoro]
    , G.[GIS Site Location]

	, G.SourceFC
	, G.GISOBJID
FROM dbo.ALLSITES_GIS AS G 
	RIGHT OUTER JOIN dbo.ALLSITES_PIP AS A ON G.[Prop ID] = A.[Prop ID]
ORDER BY G.PropNum, G.[Prop ID]

GO


