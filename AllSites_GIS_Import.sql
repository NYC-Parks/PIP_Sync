USE [accessNewPIP]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[AllSites_GIS_Import] AS
BEGIN
	SET NOCOUNT ON
	/* #########################################################################################################
		Test for missing [Prop ID], and [District] stopping the update if any are found.
	######################################################################################################### */
	DECLARE @errorMessage AS NVARCHAR(MAX); -- general error variable
	DECLARE @missingPropID AS NVARCHAR(MAX);
			--@missingDistrict AS NVARCHAR(MAX);

	WITH MissingPropID AS (
		SELECT
			COUNT(*) Missing
			, SourceFC
		FROM [GISDATA].[ParksGIS].[DPR].[vw_PIP_Compatible_Inspected_Sites]
		WHERE 
			[Prop ID] IS NULL 
			OR LEN(LTRIM(RTRIM([Prop ID]))) < 1
		GROUP BY SourceFC
	)

	SELECT @missingPropID = 'Missing Prop ID: ' + STUFF((SELECT ', ' + SourceFC + ' (' + CAST(Missing AS NVARCHAR) + ')' FROM MissingPropID t FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'),1,1,'');

	--WITH MissingDistrict AS (
		--SELECT
			--COUNT(*) Missing
			--, SourceFC
		--FROM [GISDATA].[ParksGIS].[DPR].[vw_PIP_Compatible_Inspected_Sites]
		--WHERE 
			--[AMPSDistrict] IS NULL 
			--District IS NULL
			--OR LEN(LTRIM(RTRIM([AMPSDistrict]))) < 1
		--GROUP BY SourceFC
	--)

	--SELECT @missingDistrict = 'Missing District: ' + STUFF((SELECT ', ' + SourceFC + ' (' + CAST(Missing AS NVARCHAR) + ')' FROM MissingDistrict t FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'),1,1,'');

	IF @missingPropID IS NOT NULL
		BEGIN
			SELECT @errorMessage = @missingPropID
		END

	--IF @missingPropID IS NOT NULL AND @missingDistrict IS NOT NULL
		--BEGIN
			--SELECT @errorMessage = @errorMessage  + '  --  '
		--END

	--IF @missingDistrict IS NOT NULL
		--BEGIN
			--SELECT @errorMessage = ISNULL(@errorMessage,'') + @missingDistrict
		--END

	/* #########################################################################################################
		Test for duplicate [Prop ID]s, stopping the update if any are found.
	######################################################################################################### */
	DECLARE @duplicateList AS NVARCHAR(MAX);

	WITH AllDuplicates AS (
		SELECT DISTINCT
			[Prop ID]
		FROM [GISDATA].[ParksGIS].[DPR].[vw_PIP_Compatible_Inspected_Sites]
		GROUP BY [Prop ID] 
		HAVING (COUNT([Prop ID]) > 1)
	)

	SELECT @duplicateList = STUFF((SELECT ', ' + [Prop ID] FROM AllDuplicates t FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'),1,1,'');
	IF @duplicateList IS NOT NULL
		BEGIN
			SELECT @errorMessage = ' Duplicates found: ' + @duplicateList + ' -- Additional Errors -- ' + ISNULL(@errorMessage,'')
			RAISERROR(@errorMessage, 18, 1)
			RETURN
		END 

	/* #########################################################################################################
		Halt procedure if any errors are found
	######################################################################################################### */
	IF @@ERROR IS NOT NULL
		BEGIN 
			SELECT @errorMessage
		END

	/* #########################################################################################################
		Back up the old ALLSITES_GIS
	######################################################################################################### */
	DELETE FROM [dbo].[AllSites_GIS_Backup]

	INSERT INTO [dbo].[AllSites_GIS_Backup]
		SELECT * FROM [dbo].[ALLSITES_GIS]

	/* #########################################################################################################
		Drop the old data and insert the new data
	######################################################################################################### */
	DELETE FROM [ALLSITES_GIS];

	INSERT INTO [AllSites_GIS] (
		PropNum
		, [Prop ID]
		, Boro
		, District
		, AMPSDistrict
		, [Prop Name]
		, [Site Name]
		, [Prop Location]
		, [Site Location]
		, Acres
		, Category
		, [Sub-Category]
		, Comments
		, Rated
		, [Reason Not Rated]
		, [Sub-Properties Rated]
		, [Sub-Property]
		, [Safety Index]
		, [Map # (Hagstrom)]
		, [Map Grid (Hagstrom)]
		, [Council District]
		, ZipCode
		, PIPZipCode
		, CommunityBoard
		, TypeCategory
		, Jurisdiction
		, NYSAssembly
		, NYSSenate
		, USCongress
		, ComfortStation 
		, CSCount
		, PIPCreated
		, PIPCB
		, Precinct
		, GISCreated
		, GIS_Retired
		, GISDistrict
		, PermitDistrict
		, GISBoro
		, [GIS Site Location]
		, SourceFC
		, GISOBJID
		)
	SELECT  
		PropNum
		, [Prop ID]
		, Boro
		, District
		, AMPSDistrict
		, [Prop Name]
		, [Site Name]
		, [Prop Location]
		, [Site Location]
		, Acres
		, Category
		, [Sub-Category]
		, Comments
		, Rated
		, [Reason Not Rated]
		, [Sub-Properties Rated]
		, [Sub-Property]
		, [Safety Index]
		, [Map # (Hagstrom)]
		, [Map Grid (Hagstrom)]
		, [Council District]
		, ZipCode
		, PIPZipCode
		, CommunityBoard
		, TypeCategory
		, Jurisdiction
		, NYSAssembly
		, NYSSenate
		, USCongress
		, ComfortStation 
		, CSCount
		, PIPCreated
		, PIPCB
		, Precinct
		, GISCreated
		, GIS_Retired
		, GISDistrict
		, PermitDistrict
		, GISBoro
		, [GIS Site Location]
		, SourceFC
		, GISOBJID
	FROM [GISDATA].[ParksGIS].[DPR].[vw_PIP_Compatible_Inspected_Sites]
	WHERE
		[Prop ID] IS NOT NULL
		--AND District IS NOT NULL

	/* #########################################################################################################
		Add any missing entries to the AllSites_PIP table to ensure they show up in the view
	######################################################################################################### */

	INSERT INTO dbo.AllSites_PIP (
		[Prop ID]
		, [PropNum]
		, [Boro]
		, [District]
		, [Prop Name]
		, [Category]
		)
	SELECT
		[Prop ID]
		, COALESCE([PropNum], 'N/A') [PropNum]
		, COALESCE([Boro], 'N') [Boro]
		, COALESCE([District], 'N/A') [District]
		, COALESCE([Prop Name], 'N/A') [Prop Name]
		, COALESCE([Category], 'N/A') [Category]
	FROM dbo.AllSites_GIS
	WHERE
		[PropNum] IS NOT NULL
		AND [Prop ID] NOT IN ( 
			SELECT
				[Prop ID]
			FROM dbo.AllSites_PIP
		)
		AND LEN([Prop ID]) <= 15 -- some structures have system IDs that are too long for the PIP field
END


GO


