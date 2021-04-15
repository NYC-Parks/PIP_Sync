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
create procedure dbo.sp_m_tbl_ref_allsites as
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
			   /*(n_propid > 2 and
			    n_propid_within = 1) and*/
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
		where n_propid > 2 and
				n_propid_within > 1 and 
				[prop id] is not null

	/*If the temp table exists, drop it*/
	if object_id('tempdb..#source') is not null
		drop table #source

	/*Join the #dups table to itself and specifically extract the restrictivedeclaration site record when a property record also exists or a zone, playground or property record if a structure record
	exists.*/
	select *,
		   count(*) over(partition by [prop id] order by [prop id]) as n_propid
	into #source
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
			cast(0 as bit) as multidup
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
		   cast(0 as bit) as multidup
	from accessnewpip.dbo.vw_pip_compatible_inspected_sites
	/*select non-null and non-duplicate records*/
	where [prop id] is not null and
		  n_propid = 1) as u

	begin transaction
		merge accessnewpip.dbo.tbl_ref_allsites as tgt using #source as src
		/*Use the omppropid aka prop id as the merge key. Remove records with duplicate or null prop ids.*/
		on (tgt.[prop id] = src.[prop id])
		/*If the records are matched based on the identifiers, but the row hashes are different then perform an update*/
		when matched and tgt.row_hash != src.row_hash and
		     src.[prop id] is not null and
			 src.n_propid = 1
			then update set propnum = src.propnum,
							boro = src.boro,
							ampsdistrict = src.ampsdistrict,
							[prop name] = src.[prop name],
							[site name] = src.[site name],
							[prop location] = src.[prop location],
							[site location] = src.[site location],
							jurisdiction = src. jurisdiction,
							typecategory = src.typecategory,
							acres = src.acres,
							gisobjid = src.gisobjid,
							sourcefc = src.sourcefc,
							gis_deleted = 0
		/*If the record is in GIS, but not in PIP then perform an insert.*/
		when not matched by target and
		     src.[prop id] is not null and
			 src.n_propid = 1
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
						sourcefc)
				values(src.[prop id], src.propnum, src.boro, src.ampsdistrict, src.[prop name], src.[site name], src.[prop location], src.[site location],
					   src.jurisdiction, src.typecategory, src.acres, src.gisobjid, src.sourcefc)
		/*Skip the delete section because we can't break any keys and the cascade effect is not known.*/
		/*If the record is in PIP, but not GIS then perform an update and update the flag, but DO NOT DELETE records.*/
		when not matched by source
			then update set gis_deleted = 1;
	commit;
