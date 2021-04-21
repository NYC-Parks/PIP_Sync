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
--drop procedure dbo.usp_m_tbl_ref_allsites
create procedure dbo.usp_m_tbl_ref_allsites as
	
	begin transaction
		merge accessnewpip.dbo.tbl_ref_allsites as tgt using accessnewpip.dbo.tbl_temp_ref_allsites as src
		/*Use the omppropid aka prop id as the merge key. Remove records with duplicate or null prop ids.*/
		on (tgt.[prop id] = src.[prop id])
		/*If the records are matched based on the identifiers, but the row hashes are different then perform an update*/
		when matched and (tgt.row_hash != src.row_hash or tgt.shape.STEquals(src.shape) = 0) and
		     src.[prop id] is not null and
			 src.dupflag = 0
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
							shape = src.shape,
							gis_deleted = 0
		/*If the record is in GIS, but not in PIP then perform an insert.*/
		when not matched by target and
		     src.[prop id] is not null and
			 src.dupflag = 0
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
						shape)
				values(src.[prop id], src.propnum, src.boro, src.ampsdistrict, src.[prop name], src.[site name], src.[prop location], src.[site location],
					   src.jurisdiction, src.typecategory, src.acres, src.gisobjid, src.sourcefc, src.shape)
		/*Skip the delete section because we can't break any keys and the cascade effect is not known.*/
		/*If the record is in PIP, but not GIS then perform an update and update the flag, but DO NOT DELETE records.*/
		when not matched by source
			then update set gis_deleted = 1;
	commit;
