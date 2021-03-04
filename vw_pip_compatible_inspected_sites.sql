use accessnewpip
go

set ansi_nulls on
go

set quoted_identifier on
go

create view dbo.vw_pip_compatible_inspected_sites
as
select gispropnum as propnum,
	   gispropnum as [prop id],
	   dbo.fn_getpipboro(department) as boro,
	   dbo.fn_get_pipdistrict(department) as ampsdistrict,
	   signname as [prop name],
	   signname as [site name],
	   location as [prop location],
	   location as [site location],
	   round(acres, 3) as acres,
       jurisdiction,
	   typecategory,
       featurestatus as gis_retired,
	   'Property' AS sourcefc, 
	   gisobjid
from [gisdata].parksgis.dpr.property_evw
union all
/*Verify this should be gispropnum and not be parentid*/
select gispropnum as propnum,
	   omppropid as [prop id],
	   dbo.fn_getpipboro(department) as boro,
	   dbo.fn_get_pipdistrict(department) as ampsdistrict,
	   [prop name],
	   signname as [site name],
	   [prop location],
	   location as [site location],
	   round(acres, 3) as acres,
       jurisdiction,
	   null as typecategory,
       featurestatus as gis_retired,
	   'Playground' AS sourcefc, 
	   gisobjid
	 /*Join to property_evw in order to get prop name and prop location*/
from (select l.*,
			 r.signname as [prop name],
			 r.location as [prop location]
	  from [gisdata].parksgis.dpr.playground_evw as l
	  left join
		   [gisdata].parksgis.dpr.property_evw as r
	  on l.gispropnum = r.gispropnum) as t
/*WHERE OMPPROPID IS NOT NULL*/ UNION ALL
select gispropnum as propnum,
	   omppropid as [prop id],
	   dbo.fn_getpipboro(department) as boro,
	   dbo.fn_get_pipdistrict(department) as ampsdistrict,
	   [prop name],
	   sitename as [site name],
	   [prop location],
	   location as [site location],
	   round(acres, 3) as acres,
       jurisdiction,
	   null as typecategory,
       featurestatus as gis_retired,
	   'Greenstreet' AS sourcefc, 
	   gisobjid
	 /*Join to property_evw in order to get prop name and prop location*/
from (select l.*,
			 r.signname as [prop name],
			 r.location as [prop location]
	  from [gisdata].parksgis.dpr.greenstreet_evw as l
	  left join
		   [gisdata].parksgis.dpr.property_evw as r
	  on l.gispropnum = r.gispropnum) as t
where omppropid not like 'XZ475' or
	  retired like 'False'
/*AND OMPPROPID IS NOT NULL*/ 
union all
select gispropnum as propnum,
	   omppropid as [prop id],
	   dbo.fn_getpipboro(department) as boro,
	   dbo.fn_get_pipdistrict(department) as ampsdistrict,
	   [prop name],
	   sitename as [site name],
	   [prop location],
	   location as [site location],
	   round(acres, 3) as acres,
       jurisdiction, 
	   null as typecategory,
       featurestatus as gis_retired,
	   'Zone' AS sourcefc, 
	   gisobjid
	 /*Join to property_evw in order to get prop name and prop location*/
from (select l.*,
			 r.signname as [prop name],
			 r.location as [prop location]
	  from [gisdata].parksgis.dpr.zone_evw as l
	  left join
		   [gisdata].parksgis.dpr.property_evw as r
	  on l.gispropnum = r.gispropnum) as t
/*WHERE OMPPROPID IS NOT NULL*/ 
union all
select gispropnum as propnum,
	   omppropid as [prop id],
	   dbo.fn_getpipboro(department) as boro,
	   dbo.fn_get_pipdistrict(department) as ampsdistrict,
	   [prop name],
	   name as [site name],
	   [prop location],
	   location as [site location],
	   round(acres, 3) as acres,
       jurisdiction,
	   null as typecategory,
       featurestatus as gis_retired,
	   'Golfcourse' AS sourcefc, 
	   gisobjid
	 /*Join to property_evw in order to get prop name and prop location*/
from (select l.*,
			 r.signname as [prop name],
			 r.location as [prop location]
	  from [gisdata].parksgis.dpr.golfcourse_evw as l
	  left join
		   [gisdata].parksgis.dpr.property_evw as r
	  on l.gispropnum = r.gispropnum) as t
/*WHERE OMPPROPID IS NOT NULL*/ 
union all
select gispropnum as propnum,
	   gispropnum as [prop id],
	   dbo.fn_getpipboro(department) as boro,
	   dbo.fn_get_pipdistrict(department) as ampsdistrict,
	   signname as [prop name],
	   signname as [site name],
	   location as [prop location],
	   location as [site location],
	   round(acres, 3) as acres,
       jurisdiction,
	   null as typecategory,
       featurestatus as gis_retired,
	   'Schoolyard To Playground' AS sourcefc, 
	   gisobjid
from [gisdata].parksgis.dpr.schoolyard_to_playground_evw
/*WHERE OMPPROPID IS NOT NULL*/ 
union all
select gispropnum as propnum,
	   gispropnum as [prop id],
	   dbo.fn_getpipboro(department) as boro,
	   dbo.fn_get_pipdistrict(department) as ampsdistrict,
	   description as [prop name],
	   description as [site name],
	   location as [prop location],
	   location as [site location],
	   null as acres,
       jurisdiction,
	   null as typecategory,
       featurestatus as gis_retired,
	   'Structure' AS sourcefc, 
	   gisobjid
	 /*Join to property_evw in order to get prop name and prop location*/
from [gisdata].parksgis.dpr.structure_evw as l
inner join
	 (select distinct l.system
	  from [gisdata].parksgis.dpr.structure_evw as l
	  inner join
		   [gisdata].parksgis.dpr.structurefunction_evw as r
	  on l.system = r.system
	  where lower(r.structurefunction) in ('recreation center', 'nature center')) as r
on l.system = r.system
/*AND OMPPROPID IS NOT NULL*/ 
union all
select gispropnum as propnum,
	   omppropid as [prop id],
	   dbo.fn_getpipboro(department) as boro,
	   dbo.fn_get_pipdistrict(department) as ampsdistrict,
	   [prop name],
	   name as [site name],
	   [prop location],
	   location as [site location],
	   round(acres, 3) as acres,
       jurisdiction,
	   null as typecategory,
       null as gis_retired,
	   'Unmapped' AS sourcefc, 
	   null as gisobjid
	 /*Join to property_evw in order to get prop name and prop location*/
from (select l.*,
			 r.signname as [prop name],
			 r.location as [prop location]
	  from [gisdata].parksgis.dpr.unmapped_gisallsites_evw as l
	  left join
		   [gisdata].parksgis.dpr.property_evw as r
	  on l.gispropnum = r.gispropnum) as t
/*where gispropnum not in ('BT02', 'BT04')*/ 
union all
select gispropnum as propnum,
	   gispropnum as [prop id],
	   dbo.fn_getpipboro(department) as boro,
	   dbo.fn_get_pipdistrict(department) as ampsdistrict,
	   signname as [prop name],
	   signname as [site name],
	   location as [prop location],
	   location as [site location],
	   round(acres, 3) as acres,
       jurisdiction,
	   null as typecategory,
       featurestatus as gis_retired,
	   'RestrictiveDeclarationSite' AS sourcefc, 
	   gisobjid
	 /*Join to property_evw in order to get prop name and prop location*/
from [gisdata].parksgis.dpr.restrictivedeclarationsite_evw as l
where omppropid not in('M404', 'B591', 'B595')

