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
--drop procedure dbo.sp_m_tbl_ref_allsites_nosync
create procedure dbo.sp_m_tbl_ref_allsites_nosync as
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
		where n_propid = 2 and 
				n_propid_within = 1 and
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
			1 as dupflag
	from #dups as l
	left join
		 #dups as r
	on l.[prop id] = r.[prop id] and
		l.sourcefc != r.sourcefc
	where (lower(r.sourcefc) in('property', 'zone', 'playground') and lower(l.sourcefc) = 'structure') or
		  (lower(r.sourcefc) in('restrictivedeclarationsite') and lower(l.sourcefc) = 'property')
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
		   2 as dupflag
	from #multidups
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
		   0 as dupflag
	from accessnewpip.dbo.vw_pip_compatible_inspected_sites
	/*select non-null and non-duplicate records*/
	where [prop id] is not null and
		  n_propid = 1) as u
	
	if object_id('tempdb..#gis_allsites_nosync') is not null
		drop table #gis_allsites_nosync;

	select l.*,
		   case when l.dupflag = 1 then 'Based on existing logic, an existing version of this records [prop id] has been synced from a different feature class'
				when l.dupflag = 2 then 'Records with this [prop id] exist three or more times between source feature classes or more than once within the same feature class.'
				else 'This record was previously synced, but is now duplicated between feature classes in the source (GIS). Data related to this record is no longer being updated in tbl_ref_allsites.'
		   end as sync_issue
	into #gis_allsites_nosync
	from (select *
		  from #source) as l
	left join
		 accessnewpip.dbo.tbl_ref_allsites as r
	on l.[prop id] = r.[prop id] and 
	   l.sourcefc = r.sourcefc
	where l.dupflag > 0

	begin transaction
		merge accessnewpip.dbo.tbl_ref_allsites_nosync as tgt using #gis_allsites_nosync as src
		/*Use the omppropid aka prop id as the merge key. Remove records with duplicate or null prop ids.*/
		on (tgt.[prop id] = src.[prop id] and
			tgt.sourcefc = src.sourcefc)
		/*If the records are matched based on the identifiers, but the row hashes are different then perform an update*/
		when matched and tgt.row_hash != src.row_hash
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
							sync_issue = src.sync_issue
		/*If the record is in GIS, but not in PIP then perform an insert.*/
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
						sync_issue)
				values(src.[prop id], src.propnum, src.boro, src.ampsdistrict, src.[prop name], src.[site name], src.[prop location], src.[site location],
					   src.jurisdiction, src.typecategory, src.acres, src.gisobjid, src.sourcefc, src.sync_issue)
		/*Delete records from this table they no longer have a duplicate prop id*/
		when not matched by source
			then delete;
	commit;