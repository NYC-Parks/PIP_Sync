use accessnewpip
go

set ansi_nulls on
go

set quoted_identifier on
go

alter view dbo.allsites as
	select top 100 percent l.propnum,
		   l.[prop id],
		   l.boro,
		   cast(null as nvarchar(25)) as district,
		   l.ampsdistrict,
		   l.[prop name],
		   l.[site name],
		   l.[prop location],
		   l.[site location],
		   l.acres,
		   r.category,
		   r.[sub-category],
		   r.comments,
		   r.rated,
		   r.[reason not rated],
		   cast(null as smallint) as [sub-properties rated],
		   cast(null as bit) as [sub-property],   
		   cast(null as nvarchar(24)) as [gsgroupproject], 
		   cast(null as int) as [lastinspection],
		   cast(null as smalldatetime) as [lastinspectdate],
		   cast(null as nvarchar(10)) as [lastinspectedseason],
		   cast(null as tinyint) as [lastinspectedround],
		   cast(null as int) as [lastinspectyear],
		   cast(null as int) as [sort],  
		   r.[safety index],
		   cast(null as smallint) as [map # (hagstrom)],
		   cast(null as nvarchar(128)) as [map grid (hagstrom)],
		   cast(null as nvarchar(50)) as [council district],
		   cast(null as nvarchar(110)) as zipcode,
		   cast(null as nvarchar(128)) as pipzipcode,
		   cast(null as nvarchar(50)) as communityboard,
		   l.typecategory,
		   l.jurisdiction,
		   cast(null as nvarchar(50)) as [nysassembly],
		   cast(null as nvarchar(50)) as [nyssenate],
		   cast(null as nvarchar(50)) as [uscongress],
		   cast(null as int) as precinct,
		   r.comfortstation,	   
		   cast(null as int) as cscount,
		   cast(null as nvarchar(15)) as pip_prop_id,
		   r.created_date as pipcreated,
		   l.created_date as giscreated,
		   cast(null as nvarchar(5)) as [gis_retired],
		   cast(null as nvarchar(25)) as [gisdistrict],
		   cast(null as nvarchar(25)) as [permitdistrict],
		   cast(null as nvarchar(15)) as [gisboro],
		   cast(null as nvarchar(100)) as [gis site location], 
		   l.sourcefc,
		   l.gisobjid,
		   l.shape
	from accessnewpip.dbo.tbl_ref_allsites as l
	left join
		 accessnewpip.dbo.tbl_pip_allsites as r
	on l.[prop id] = r.[prop id] 
	/*Exclude records that come from structures that do not have corresponding record in tbl_pip_structures (manual workflow).*/
	where lower(l.sourcefc) != 'structure' or
		  (lower(l.sourcefc) = 'structure' and
		   r.[prop id] is not null)
	order by l.propnum, l.[prop id];

go


