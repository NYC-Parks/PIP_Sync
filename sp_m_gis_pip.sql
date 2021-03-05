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
--drop procedure dbo.sp_m_gis_pip
create procedure dbo.sp_m_gis_pip as
	
	select *
	into #gis_allsites
	from (select *,
				 count(*) over(partition by [prop id] order by [prop id]) as n_propid
		  from accessnewpip.dbo.vw_pip_compatible_inspected_sites) as t
		  /*Probably need to build in duplicate and null exclusion here*/
	--where [prop id] is not null and n_propid = 1


	begin transaction
		merge accessnewpip.dbo.tbl_ref_allsites as tgt using #gis_allsites as src
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
							sourcefc = src.sourcefc
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
					   src.jurisdiction, src.typecategory, src.acres, src.gisobjid, src.sourcefc);
		/*Skip the delete section because we can't break any keys and the cascade effect is not known.*/
	commit;

	select l.*,
		   case when r.[prop id] is null then 'This record has never been synced because it is duplicated in the source (GIS).'
				else 'This record was previously synced, but is now duplicated in the source (GIS). Data related to this record is no longer being updated in tbl_ref_allsites.'
		   end as sync_issue
	into #gis_allsites_nosync
	from #gis_allsites as l
	left join
		 accessnewpip.dbo.tbl_ref_allsites as r
	on l.[prop id] = r.[prop id] and 
	   l.sourcefc = r.sourcefc
	where l.[prop id] is not null and 
		  l.n_propid > 1

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
							sourcefc = src.sourcefc
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
						sourcefc)
				values(src.[prop id], src.propnum, src.boro, src.ampsdistrict, src.[prop name], src.[site name], src.[prop location], src.[site location],
					   src.jurisdiction, src.typecategory, src.acres, src.gisobjid, src.sourcefc);
		/*Skip the delete section because we can't break any keys and the cascade effect is not known.*/
	commit;