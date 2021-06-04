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
--drop procedure dbo.usp_m_tbl_temp_ref_allsites
create procedure dbo.usp_m_tbl_temp_ref_allsites as

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
				/*Convert geometry values to text so they can be unioned*/
				shape.STAsText() as shape,
				row_hash
		into #dups
		from accessnewpip.dbo.vw_pip_sync
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
				/*Create null values as nvarchar(max) the same type as the WKT representation of geometry so they can be unioned*/
				cast(null as nvarchar(max)) as shape,
				cast(null as varbinary(max)) as row_hash
		into #multidups
		from accessnewpip.dbo.vw_pip_sync
		where (n_propid > 2 and
			   n_propid_within > 1) or
			   (n_propid - (n_propid - n_propid_within) > 1) and
			   [prop id] is not null

	/*Join the #dups table to itself and specifically extract the restrictivedeclaration site record when a property record also exists or a zone, playground or property record if a structure record
	exists.*/
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
		   /*Convert WKT nvarchar(max) geometry back to SQL native geometry with SRID = 2263*/
		   geometry::STGeomFromText(shape, 2263) as shape,
		   row_hash,
		   dupflag,
		   syncflag,
		   count(*) over(partition by [prop id] order by [prop id]) as n_propid
	--into accessnewpip.dbo.tbl_temp_ref_allsites
	into #temp_ref_allsites
	from (
	/*Join the duplicates table (#dups) to itself and use where clause to identify logic where one record takes precedence over another*/
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
			l.shape,
			l.row_hash,
			0 as dupflag,
			0 as syncflag
	from #dups as l
	left join
		 #dups as r
	on l.[prop id] = r.[prop id] and
		l.sourcefc != r.sourcefc
	/*If the [prop id] of the record is in property, zone, playground or greenstreet (from GIS) and has a duplicate [prop id] value in the structure
	  table, then take the record from those tables. If the [prop id] of the record is in resrictivedeclartionsite (from GIS) and has a duplicate in
	  property, then take the restrictive declartion site record. Exclude records with null [prop id].*/
	where (lower(l.sourcefc) in('property', 'zone', 'playground', 'greenstreet') and lower(r.sourcefc) = 'structure') or
		  (lower(l.sourcefc) in('restrictivedeclarationsite') and lower(r.sourcefc) = 'property') or
		  r.sourcefc is null
	union
	/*Union all records from source view that are not duplicates (n_propid = 1) and do not have a null [prop id].*/
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
		   /*Convert geometry values to text so they can be unioned*/
		   shape.STAsText() as shape,
		   row_hash,
		   0 as dupflag,
		   0 as syncflag
	from accessnewpip.dbo.vw_pip_sync
	/*select non-null and non-duplicate records*/
	where [prop id] is not null and
		  n_propid = 1
	union
	/*Union all records that have multiple duplicates of [prop id], these can be within or between source feature classes.*/
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
		   shape,
		   row_hash,
		   2 as dupflag,
		   0 as syncflag
	from #multidups
	union
	/*Join the duplicates table (#dups) to itself and use where clause to identify logic where one record takes precedence over another, but this time
	  take the opposite records. Null out all fields but [prop id], propnum and sourcefc. This ensures we can identify the records where another was taken
	  instead.*/
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
		   /*Create null values as nvarchar(max) the same type as the WKT representation of geometry so they can be unioned*/
		   cast(null as nvarchar(max)) as shape,
		   cast(null as varbinary(max)) as row_hash,
		   1 as dupflag,
		   	/*If the [prop id] of the record is in property, zone, playground or greenstreet (from GIS) and has a duplicate [prop id] value in the structure
			  table, then flag the structure record. If the [prop id] of the record is in resrictivedeclartionsite (from GIS) and has a duplicate in
			  property, then flag the property record. Otherwise don't flag the record.*/
		   case when lower(r.sourcefc) in('property', 'zone', 'playground', 'greenstreet') and lower(l.sourcefc) = 'structure' then 1
			    when lower(r.sourcefc) in('restrictivedeclarationsite') and lower(l.sourcefc) = 'property' then 1
				else 0
		   end as syncflag
	from #dups as l
	left join
		 #dups as r
	on l.[prop id] = r.[prop id] and
		l.sourcefc != r.sourcefc
	/*If the [prop id] of the record is in property, zone, playground or greenstreet (from GIS) and has a duplicate [prop id] value in the structure
	  table, then take the record from structures. If the [prop id] of the record is in resrictivedeclartionsite (from GIS) and has a duplicate in
	  property, then take the property record. Exclude records with null [prop id].*/
	where (lower(r.sourcefc) in('property', 'zone', 'playground', 'greenstreet') and lower(l.sourcefc) = 'structure') or
		  (lower(r.sourcefc) in('restrictivedeclarationsite') and lower(l.sourcefc) = 'property') or
		  r.sourcefc is null) as u

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
		   /*Convert WKT nvarchar(max) geometry back to SQL native geometry with SRID = 2263*/
		   shape,
		   row_hash as row_hash_origin,
		   dupflag,
		   syncflag,
		   n_propid,
		   hashbytes('SHA2_256', concat(PropNum, Boro, AMPSDistrict, [Prop Name], [Site Name], 
									    [Prop Location], [Site Location], jurisdiction, typecategory, acres, 
										gisobjid, sourcefc, row_hash, dupflag, syncflag, n_propid)) as row_hash_dest
	into #temp_ref_allsitesf
	from #temp_ref_allsites

begin transaction
	merge accessnewpip.dbo.tbl_temp_ref_allsites as tgt using #temp_ref_allsitesf as src
	on (tgt.[prop id] = src.[prop id] and
		tgt.sourcefc = src.sourcefc and 
		tgt.row_hash_dest = src.row_hash_dest)
	when matched
		then update set tgt.propnum = src.propnum, 
					tgt.boro = src.boro, 
					tgt.ampsdistrict = src.ampsdistrict, 
					tgt.[prop name] = src.[prop name], 
					tgt.[site name] = src.[site name], 
					tgt.[prop location] = src.[prop location], 
					tgt.[site location] = src.[site location], 
					tgt.jurisdiction = src.jurisdiction, 
					tgt.typecategory = src.typecategory, 
					tgt.acres = src.acres, 
					tgt.gisobjid = src.gisobjid, 
					tgt.row_hash_origin = src.row_hash_origin, 
					tgt.dupflag = src.dupflag, 
					tgt.syncflag = src.syncflag, 
					tgt.n_propid = src.n_propid,
					tgt.shape = src.shape
	when not matched by target
		then insert([prop id], 
					propnum, 
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
					row_hash_origin, 
					dupflag, 
					syncflag, 
					n_propid,
					shape)
			values(src.[prop id],
				   src.propnum, 
				   src.boro, 
				   src.ampsdistrict, 
				   src.[prop name], 
				   src.[site name], 
				   src.[prop location], 
				   src.[site location], 
				   src.jurisdiction, 
				   src.typecategory, 
				   src.acres, 
				   src.gisobjid, 
				   src.sourcefc, 
				   src.row_hash_origin, 
				   src.dupflag, 
				   src.syncflag,
				   src.n_propid,
				   src.shape)
	when not matched by source
		then delete;
commit;

if object_id('tempd..#temp_ref_allsites') is not null
	drop table #temp_ref_allsites;

if object_id('tempd..#temp_ref_allsitesf') is not null
	drop table #temp_ref_allsitesf;