

/****** Object:  View [dbo].[vw_pip_sync]    Script Date: 6/15/2021 12:50:29 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


with allsites as(
select gispropnum  as propnum,
	   gispropnum as [prop id],
	   LEFT([Department],1) as boro,
	   RIGHT([Department], LEN([Department]) - CharIndex('-', [Department])) as ampsdistrict,
	   signname as [prop name],
	   signname as [site name],
	   location as [prop location],
	   location as [site location],
	   round(acres, 3) as acres,
       jurisdiction,
	   typecategory,
       featurestatus,
	   'Property' AS sourcefc, 
	   gisobjid,
	   shape
from parksgis.dpr.property_evw
union all
select parentid as propnum,
	   omppropid as [prop id],
	   LEFT([Department],1) as boro,
	   RIGHT([Department], LEN([Department]) - CharIndex('-', [Department])) as ampsdistrict,
	   isnull([prop name], signname) as [prop name],
	   signname as [site name],
	   isnull([prop location], location) as [prop location],
	   location as [site location],
	   round(acres, 3) as acres,
       jurisdiction,
	   cast(null as nvarchar(100)) as typecategory,
       featurestatus,
	   'Playground' AS sourcefc, 
	   gisobjid,
	   shape
	 /*Join to property_evw in order to get prop name and prop location*/
from (select l.*,
			 r.signname as [prop name],
			 r.location as [prop location]
	  from parksgis.dpr.playground_evw as l
	  left join
		   parksgis.dpr.property_evw as r
	  on l.parentid= r.gispropnum /*and
		 l.omppropid != l.parentid*/) as t
union all
select omppropid as propnum,
	   omppropid as [prop id],
	   LEFT([Department],1) as boro,
	   RIGHT([Department], LEN([Department]) - CharIndex('-', [Department])) as ampsdistrict,
	   sitename as [prop name],
	   sitename as [site name],
	   location as [prop location],
	   location as [site location],
	   round(acres, 3) as acres,
       jurisdiction,
	   cast(null as nvarchar(100)) as typecategory,
       featurestatus,
	   'Greenstreet' AS sourcefc, 
	   gisobjid,
	   shape
	 /*Join to property_evw in order to get prop name and prop location*/
from parksgis.dpr.greenstreet_evw
union all
select parentid as propnum,
	   omppropid as [prop id],
	   LEFT([Department],1) as boro,
	   RIGHT([Department], LEN([Department]) - CharIndex('-', [Department])) as ampsdistrict,
	   isnull([prop name], sitename) as [prop name],
	   sitename as [site name],
	   isnull([prop location], location) as [prop location],
	   location as [site location],
	   round(acres, 3) as acres,
       jurisdiction, 
	   cast(null as nvarchar(100)) as typecategory,
       featurestatus,
	   'Zone' AS sourcefc, 
	   gisobjid,
	   shape
	 /*Join to property_evw in order to get prop name and prop location*/
from (select l.*,
			 r.signname as [prop name],
			 r.location as [prop location]
	  from parksgis.dpr.zone_evw as l
	  left join
		   parksgis.dpr.property_evw as r
	  on l.parentid= r.gispropnum /*and
		 l.omppropid != l.parentid*/) as t
union all
select gispropnum as propnum,
	   omppropid as [prop id],
	   LEFT([Department],1) as boro,
	   RIGHT([Department], LEN([Department]) - CharIndex('-', [Department])) as ampsdistrict,
	   isnull([prop name], name) as [prop name],
	   name as [site name],
	   isnull([prop location], location) as [prop location],
	   location as [site location],
	   round(acres, 3) as acres,
       jurisdiction,
	   cast(null as nvarchar(100)) as typecategory,
       featurestatus,
	   'GolfCourse' AS sourcefc, 
	   gisobjid,
	   shape
	 /*Join to property_evw in order to get prop name and prop location*/
from (select l.*,
			 r.signname as [prop name],
			 r.location as [prop location]
	  from parksgis.dpr.golfcourse_evw as l
	  left join
		   parksgis.dpr.property_evw as r
	  on l.gispropnum = r.gispropnum and
		 l.omppropid != l.gispropnum) as t
union all
select gispropnum as propnum,
	   gispropnum as [prop id],
	   LEFT([Department],1) as boro,
	   RIGHT([Department], LEN([Department]) - CharIndex('-', [Department])) as ampsdistrict,
	   signname as [prop name],
	   signname as [site name],
	   location as [prop location],
	   location as [site location],
	   round(acres, 3) as acres,
       jurisdiction,
	   cast(null as nvarchar(100)) as typecategory,
       featurestatus,
	   'Schoolyard To Playground' AS sourcefc, 
	   null as gisobjid,
	   shape
from parksgis.dpr.schoolyard_to_playground_evw
union all
select gispropnum as propnum,
	   omppropid as [prop id],
	   LEFT([Department],1) as boro,
	   RIGHT([Department], LEN([Department]) - CharIndex('-', [Department])) as ampsdistrict,
	   description as [prop name],
	   description as [site name],
	   location as [prop location],
	   location as [site location],
	   null as acres,
       jurisdiction,
	   cast(null as nvarchar(100)) as typecategory,
       featurestatus,
	   'Structure' AS sourcefc, 
	   gisobjid,
	   shape
from parksgis.dpr.structure_evw
union all
select gispropnum as propnum,
	   omppropid as [prop id],
	   LEFT([Department],1) as boro,
	   RIGHT([Department], LEN([Department]) - CharIndex('-', [Department])) as ampsdistrict,
	   isnull([prop name], name) as [prop name],
	   name as [site name],
	   isnull([prop location], location) as [prop location],
	   location as [site location],
	   round(acres, 3) as acres,
       jurisdiction,
	   cast(null as nvarchar(100)) as typecategory,
       null as featurestatus,
	   'Unmapped' AS sourcefc, 
	   null as gisobjid,
	   null shape
	 /*Join to property_evw in order to get prop name and prop location*/
from (select l.*,
			 r.signname as [prop name],
			 r.location as [prop location]
	  from parksgis.dpr.unmapped_gisallsites_evw as l
	  left join
		   parksgis.dpr.property_evw as r
	  on l.gispropnum = r.gispropnum and
		 l.omppropid != l.gispropnum) as t
union all
select gispropnum as propnum,
	   gispropnum as [prop id],
	   LEFT([Department],1) as boro,
	   RIGHT([Department], LEN([Department]) - CharIndex('-', [Department])) as ampsdistrict,
	   signname as [prop name],
	   signname as [site name],
	   location as [prop location],
	   location as [site location],
	   round(acres, 3) as acres,
       jurisdiction,
	   cast(null as nvarchar(100)) as typecategory,
       featurestatus,
	   'RestrictiveDeclarationSite' AS sourcefc, 
	   null as gisobjid,
	   shape
from parksgis.dpr.restrictivedeclarationsite_evw)



select row_number() over(order by [prop id]) as objectid,
	   propnum, 
	   [prop id] as [propid],
	   boro, 
	   ampsdistrict,
	   [prop name] as [propname],
	   [site name] as [sitename],
	   [prop location] as [proplocation],
	   [site location] as [sitelocation],
	   jurisdiction,
	   typecategory,
	   cast(acres as real) as acres,
	   gisobjid,
	   sourcefc,
	   featurestatus,
	   shape,
	   /*Create the row_hash so comparison of data is easier*/
	   hashbytes('SHA2_256', concat(PropNum, Boro, AMPSDistrict, [Prop Name], [Site Name], [Prop Location], [Site Location], 
							       jurisdiction, typecategory, cast(acres as real), gisobjid, sourcefc)) as row_hash,
	   count(*) over(partition by [prop id] order by [prop id]) as n_propid,
	   count(*) over(partition by [prop id], sourcefc order by [prop id], sourcefc) as n_propid_within
from allsites
	   

GO
