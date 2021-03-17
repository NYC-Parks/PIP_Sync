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
		   null as district,
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
		   null as [sub-properties rated],
		   null as [sub-property],   
		   null as [gsgroupproject], 
		   null as [lastinspection],
		   null as [lastinspectdate],
		   null as [lastinspectedseason],
		   null as [lastinspectedround],
		   null as [lastinspectyear],
		   null as [sort],  
		   r.[safety index],
		   null as [map # (hagstrom)],
		   null as [map grid (hagstrom)],
		   null as [council district],
		   null as zipcode,
		   null as pipzipcode,
		   null as communityboard,
		   l.typecategory,
		   l.jurisdiction,
		   null as [nysassembly],
		   null as [nyssenate],
		   null as [uscongress],
		   null as precinct,
		   r.comfortstation,	   
		   null as cscount,
		   l.[prop id] as pip_prop_id,
		   r.created_date as pipcreated,
		   l.created_date as giscreated,
		   null as [gis_retired],
		   null as [gisdistrict],
		   null as [permitdistrict],
		   null as [gisboro],
		   null as [gis site location], 
		   l.sourcefc,
		   l.gisobjid
	from accessnewpip.dbo.tbl_ref_allsites as l
	left join
		 accessnewpip.dbo.tbl_pip_allsites as r
	on l.[prop id] = r.[prop id]
	order by l.propnum, l.[prop id];

go


