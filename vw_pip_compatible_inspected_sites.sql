use accessnewpip
go

set ansi_nulls on
go

set quoted_identifier on
go

create view dbo.vw_pip_compatible_inspected_sites
as
with allsites as(
select gispropnum as propnum,
	   gispropnum as [prop id],
	   accessnewpip.dbo.fn_get_pipboro(department) as boro,
	   accessnewpip.dbo.fn_get_pipdistrict(department) as ampsdistrict,
	   signname as [prop name],
	   signname as [site name],
	   location as [prop location],
	   location as [site location],
	   round(acres, 3) as acres,
       jurisdiction,
	   typecategory,
       featurestatus as gis_retired,
	   'Property' AS sourcefc, 
	   gisobjid,
	   shape
from openquery([gisdata], 'select * from parksgis.dpr.property_evw')
union all
/*Verify this should be gispropnum and not be parentid*/
select gispropnum as propnum,
	   omppropid as [prop id],
	   accessnewpip.dbo.fn_get_pipboro(department) as boro,
	   accessnewpip.dbo.fn_get_pipdistrict(department) as ampsdistrict,
	   [prop name],
	   signname as [site name],
	   [prop location],
	   location as [site location],
	   round(acres, 3) as acres,
       jurisdiction,
	   null as typecategory,
       featurestatus as gis_retired,
	   'Playground' AS sourcefc, 
	   gisobjid,
	   shape
	 /*Join to property_evw in order to get prop name and prop location*/
from (select l.*,
			 r.signname as [prop name],
			 r.location as [prop location]
	  from openquery([gisdata], 'select * from parksgis.dpr.playground_evw') as l
	  left join
		   openquery([gisdata], 'select * from parksgis.dpr.property_evw') as r
	  on l.gispropnum = r.gispropnum) as t
/*WHERE OMPPROPID IS NOT NULL*/ UNION ALL
select gispropnum as propnum,
	   omppropid as [prop id],
	   accessnewpip.dbo.fn_get_pipboro(department) as boro,
	   accessnewpip.dbo.fn_get_pipdistrict(department) as ampsdistrict,
	   [prop name],
	   sitename as [site name],
	   [prop location],
	   location as [site location],
	   round(acres, 3) as acres,
       jurisdiction,
	   null as typecategory,
       featurestatus as gis_retired,
	   'Greenstreet' AS sourcefc, 
	   gisobjid,
	   shape
	 /*Join to property_evw in order to get prop name and prop location*/
from (select l.*,
			 r.signname as [prop name],
			 r.location as [prop location]
	  from openquery([gisdata], 'select * from parksgis.dpr.greenstreet_evw') as l
	  left join
		   openquery([gisdata], 'select * from parksgis.dpr.property_evw') as r
	  on l.gispropnum = r.gispropnum) as t
where omppropid not like 'XZ475' or
	  retired like 'False'
/*AND OMPPROPID IS NOT NULL*/ 
union all
select gispropnum as propnum,
	   omppropid as [prop id],
	   accessnewpip.dbo.fn_get_pipboro(department) as boro,
	   accessnewpip.dbo.fn_get_pipdistrict(department) as ampsdistrict,
	   [prop name],
	   sitename as [site name],
	   [prop location],
	   location as [site location],
	   round(acres, 3) as acres,
       jurisdiction, 
	   null as typecategory,
       featurestatus as gis_retired,
	   'Zone' AS sourcefc, 
	   gisobjid,
	   shape
	 /*Join to property_evw in order to get prop name and prop location*/
from (select l.*,
			 r.signname as [prop name],
			 r.location as [prop location]
	  from openquery([gisdata], 'select * from parksgis.dpr.zone_evw') as l
	  left join
		   openquery([gisdata], 'select * from parksgis.dpr.property_evw') as r
	  on l.gispropnum = r.gispropnum) as t
/*WHERE OMPPROPID IS NOT NULL*/ 
union all
select gispropnum as propnum,
	   omppropid as [prop id],
	   accessnewpip.dbo.fn_get_pipboro(department) as boro,
	   accessnewpip.dbo.fn_get_pipdistrict(department) as ampsdistrict,
	   [prop name],
	   name as [site name],
	   [prop location],
	   location as [site location],
	   round(acres, 3) as acres,
       jurisdiction,
	   null as typecategory,
       featurestatus as gis_retired,
	   'Golfcourse' AS sourcefc, 
	   gisobjid,
	   shape
	 /*Join to property_evw in order to get prop name and prop location*/
from (select l.*,
			 r.signname as [prop name],
			 r.location as [prop location]
	  from openquery([gisdata], 'select * from parksgis.dpr.golfcourse_evw') as l
	  left join
		   openquery([gisdata], 'select * from parksgis.dpr.property_evw') as r
	  on l.gispropnum = r.gispropnum) as t
/*WHERE OMPPROPID IS NOT NULL*/ 
union all
select gispropnum as propnum,
	   gispropnum as [prop id],
	   accessnewpip.dbo.fn_get_pipboro(department) as boro,
	   accessnewpip.dbo.fn_get_pipdistrict(department) as ampsdistrict,
	   signname as [prop name],
	   signname as [site name],
	   location as [prop location],
	   location as [site location],
	   round(acres, 3) as acres,
       jurisdiction,
	   null as typecategory,
       featurestatus as gis_retired,
	   'Schoolyard To Playground' AS sourcefc, 
	   null as gisobjid,
	   shape
from openquery([gisdata], 'select * from parksgis.dpr.schoolyard_to_playground_evw')
/*WHERE OMPPROPID IS NOT NULL*/ 
union all
select gispropnum as propnum,
	   gispropnum as [prop id],
	   accessnewpip.dbo.fn_get_pipboro(department) as boro,
	   accessnewpip.dbo.fn_get_pipdistrict(department) as ampsdistrict,
	   description as [prop name],
	   description as [site name],
	   location as [prop location],
	   location as [site location],
	   null as acres,
       jurisdiction,
	   null as typecategory,
       featurestatus as gis_retired,
	   'Structure' AS sourcefc, 
	   gisobjid,
	   shape
	 /*Join to property_evw in order to get prop name and prop location*/
from openquery([gisdata], 'select * from parksgis.dpr.structure_evw') as l
inner join
	 (select distinct l.system
	  from openquery([gisdata], 'select * from parksgis.dpr.structure_evw') as l
	  inner join
		   openquery([gisdata], 'select * from parksgis.dpr.structurefunction_evw') as r
	  on l.system = r.system
	  where lower(r.structurefunction) in ('recreation center', 'nature center')) as r
on l.system = r.system
/*AND OMPPROPID IS NOT NULL*/ 
union all
select gispropnum as propnum,
	   omppropid as [prop id],
	   accessnewpip.dbo.fn_get_pipboro(department) as boro,
	   accessnewpip.dbo.fn_get_pipdistrict(department) as ampsdistrict,
	   [prop name],
	   name as [site name],
	   [prop location],
	   location as [site location],
	   round(acres, 3) as acres,
       jurisdiction,
	   null as typecategory,
       null as gis_retired,
	   'Unmapped' AS sourcefc, 
	   null as gisobjid,
	   null shape
	 /*Join to property_evw in order to get prop name and prop location*/
from (select l.*,
			 r.signname as [prop name],
			 r.location as [prop location]
	  from openquery([gisdata], 'select * from parksgis.dpr.unmapped_gisallsites_evw') as l
	  left join
		   openquery([gisdata], 'select * from parksgis.dpr.property_evw') as r
	  on l.gispropnum = r.gispropnum) as t
/*where gispropnum not in ('BT02', 'BT04')*/ 
union all
select gispropnum as propnum,
	   gispropnum as [prop id],
	   accessnewpip.dbo.fn_get_pipboro(department) as boro,
	   accessnewpip.dbo.fn_get_pipdistrict(department) as ampsdistrict,
	   signname as [prop name],
	   signname as [site name],
	   location as [prop location],
	   location as [site location],
	   round(acres, 3) as acres,
       jurisdiction,
	   null as typecategory,
       featurestatus as gis_retired,
	   'RestrictiveDeclarationSite' AS sourcefc, 
	   null as gisobjid,
	   shape
	 /*Join to property_evw in order to get prop name and prop location*/
from openquery([gisdata], 'select * from parksgis.dpr.restrictivedeclarationsite_evw') as l
where omppropid not in('M404', 'B591', 'B595'))

select propnum, 
	   [prop id],
	   boro, 
	   ampsdistrict,
	   [prop name],
	   [site name],
	   [prop location],
	   [site location],
	   jurisdiction,
	   typecategory,
	   acres,
	   gisobjid,
	   sourcefc,
	   shape,
	   /*Create the row_hash so comparison of data is easier*/
	   hashbytes('SHA2_256', concat(PropNum, Boro, AMPSDistrict, [Prop Name], [Site Name], [Prop Location], [Site Location], 
							       jurisdiction, typecategory, acres, gisobjid, sourcefc)) as row_hash
from allsites
	   

