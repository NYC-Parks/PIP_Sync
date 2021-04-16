/***********************************************************************************************************************
																													   	
 Created By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management         											   
 Modified By: <Modifier Name>																						   			          
 Created Date:  <MM/DD/YYYY>																							   
 Modified Date: <MM/DD/YYYY>																							   
											       																	   
 Project: <Project Name>	
 																							   
 Tables Used: <Database>.<Schema>.<Table Name1>																							   
 			  <Database>.<Schema>.<Table Name2>																								   
 			  <Database>.<Schema>.<Table Name3>				
			  																				   
 Description: <Lorem ipsum dolor sit amet, legimus molestiae philosophia ex cum, omnium voluptua evertitur nec ea.     
	       Ut has tota ullamcorper, vis at aeque omnium. Est sint purto at, verear inimicus at has. Ad sed dicat       
	       iudicabit. Has ut eros tation theophrastus, et eam natum vocent detracto, purto impedit appellantur te	   
	       vis. His ad sonet probatus torquatos, ut vim tempor vidisse deleniti.>  									   
																													   												
***********************************************************************************************************************/
use accessnewpip
go
--drop procedure dbo.sp_m_tbl_ref_allsites
create procedure dbo.sp_i_tbl_temp_ref_allsites as

	/*If the temp table exists, drop it*/
	if object_id('accessnewpip.dbo.tbl_temp_ref_allsites') is not null
		drop table accessnewpip.dbo.tbl_temp_ref_allsites;

	/*If the temp table exists, drop it*/
	if object_id('tempdb..#dups') is not null
		drop table #dups;

	/*Select any records that are duplicated just twice (by [prop id]) between source feature classes, but are not duplicated within the same source feature class.*/
		select [propnum],
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
				row_hash
		into #dups
		from accessnewpip.dbo.vw_pip_compatible_inspected_sites
		where (n_propid = 2 and 
			   n_propid_within = 1) or
			   /*If the count of records with the same [prop id] minus the count of records with the same [prop id] minus the count of records within the
			     same feature class that have the same [prop id] is equal to 1 then keep the record. For example, for a [prop id] that exists once
				 in the 'Zone' sourcefc and three times in the 'Structure' sourcefc, the equation for the 'Zone' records is 4 - (4 - 1) = 1 and the 'Strucutures'
				 records is 4 - (4 - 3) = 3, meaning the 'Zone' record is retained.*/
			   (n_propid - (n_propid - n_propid_within) = 1) and
			   [prop id] is not null

	/*If the temp table exists, drop it*/
	if object_id('tempdb..#multidups') is not null
		drop table #multidups

	/*Select any records that are duplicated more than twice (by [prop id]) between source feature classes and may also be duplicated within the same source feature class two or more times.
		In order to track the existince of these records, all values except the propnum, [prop id] and sourcefc are nulled out.*/
		select distinct [propnum],
				[prop id],
				cast(null as nvarchar(1)) as boro,
				cast(null as nvarchar(25)) as ampsdistrict,
				cast(null as nvarchar(100)) [prop name],
				cast(null as nvarchar(100)) as [site name],
				cast(null as nvarchar(100)) as [prop location],
				cast(null as nvarchar(100)) as [site location],
				cast(null as nvarchar(25)) as jurisdiction,
				cast(null as nvarchar(100)) as typecategory,
				cast(null as real) as acres,
				cast(null as int) as gisobjid,
				sourcefc,
				cast(null as varbinary(max)) as row_hash
		into #multidups
		from accessnewpip.dbo.vw_pip_compatible_inspected_sites
		where (n_propid > 2 and
			   n_propid_within > 1) or
			   (n_propid - (n_propid - n_propid_within) > 1) and
			   [prop id] is not null

	/*If the temp table exists, drop it*/
	if object_id('accessnewpip.dbo.tbl_temp_ref_allsites') is not null
		drop table accessnewpip.dbo.tbl_temp_ref_allsites

	/*Join the #dups table to itself and specifically extract the restrictivedeclaration site record when a property record also exists or a zone, playground or property record if a structure record
	exists.*/
	select *,
		   count(*) over(partition by [prop id] order by [prop id]) as n_propid
	into accessnewpip.dbo.tbl_temp_ref_allsites
	from (
	select l.[propnum],
			l.[prop id],
			l.boro,
			l.ampsdistrict,
			l.[prop name],
			l.[site name],
			l.[prop location],
			l.[site location],
			l.jurisdiction,
			l.typecategory,
			l.acres,
			l.gisobjid,
			l.sourcefc,
			l.row_hash,
			0 as dupflag,
			0 as syncflag
	from #dups as l
	left join
		 #dups as r
	on l.[prop id] = r.[prop id] and
		l.sourcefc != r.sourcefc
	where (lower(l.sourcefc) in('property', 'zone', 'playground', 'greenstreet') and lower(r.sourcefc) = 'structure') or
		  (lower(l.sourcefc) in('restrictivedeclarationsite') and lower(r.sourcefc) = 'property') or
		  r.sourcefc is null
	union
	select [propnum],
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
		   row_hash,
		   0 as dupflag,
		   0 as syncflag
	from accessnewpip.dbo.vw_pip_compatible_inspected_sites
	/*select non-null and non-duplicate records*/
	where [prop id] is not null and
		  n_propid = 1
	union 
	select [propnum],
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
		   row_hash,
		   2 as dupflag,
		   0 as syncflag
	from #multidups
	union
	select distinct l.[propnum],
		   l.[prop id],
		   cast(null as nvarchar(1)) as boro,
		   cast(null as nvarchar(25)) as ampsdistrict,
		   cast(null as nvarchar(100)) [prop name],
		   cast(null as nvarchar(100)) as [site name],
		   cast(null as nvarchar(100)) as [prop location],
		   cast(null as nvarchar(100)) as [site location],
		   cast(null as nvarchar(25)) as jurisdiction,
		   cast(null as nvarchar(100)) as typecategory,
		   cast(null as real) as acres,
		   cast(null as int) as gisobjid,
		   l.sourcefc,
		   cast(null as varbinary(max)) as row_hash,
		   1 as dupflag,
		   case when lower(r.sourcefc) in('property', 'zone', 'playground', 'greenstreet') and lower(l.sourcefc) = 'structure' then 1
			    when lower(r.sourcefc) in('restrictivedeclarationsite') and lower(l.sourcefc) = 'property' then 1
				else 0
		   end as syncflag
	from #dups as l
	left join
		 #dups as r
	on l.[prop id] = r.[prop id] and
		l.sourcefc != r.sourcefc
	where (lower(r.sourcefc) in('property', 'zone', 'playground', 'greenstreet') and lower(l.sourcefc) = 'structure') or
		  (lower(r.sourcefc) in('restrictivedeclarationsite') and lower(l.sourcefc) = 'property') or
		  r.sourcefc is null) as u