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
	select l.*,
		   case when r.[prop id] is null then 'This record has never been synced because it is duplicated in the source (GIS).'
				else 'This record was previously synced, but is now duplicated between feature classes in the source (GIS). Data related to this record is no longer being updated in tbl_ref_allsites.'
		   end as sync_issue
	into #gis_allsites_nosync
	from (select distinct case when n_propid_within > 1 then null else propnum end as propnum,
				 [prop id],
			     sourcefc,
				 case when n_propid_within > 1 then null else boro end as boro,
				 case when n_propid_within > 1 then null else ampsdistrict end as ampsdistrict,
				 case when n_propid_within > 1 then null else [prop name] end as [prop name],
				 case when n_propid_within > 1 then null else [site name] end as [site name],
				 case when n_propid_within > 1 then null else [prop location] end as [prop location],
				 case when n_propid_within > 1 then null else [site location] end as [site location],
				 case when n_propid_within > 1 then null else jurisdiction end as jusrisdiction,
				 case when n_propid_within > 1 then null else typecategory end as typecategory,
				 case when n_propid_within > 1 then null else acres end as acres,
				 case when n_propid_within > 1 then null else gisobjid end as gisobjid,
				 case when n_propid_within > 1 then hashbytes('SHA2_256', '-9999') else row_hash end as row_hash,
				 case when n_propid_within > 1 then null else n_propid end as n_propid,
				 case when n_propid_within > 1 then null else n_propid_within end as n_propid_within
	      from accessnewpip.dbo.vw_pip_compatible_inspected_sites) as l
	left join
		 accessnewpip.dbo.tbl_ref_allsites as r
	on l.[prop id] = r.[prop id] and 
	   l.sourcefc = r.sourcefc
	where l.[prop id] is not null and 
		  l.n_propid > 1 
select * from #gis_allsites_nosync
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