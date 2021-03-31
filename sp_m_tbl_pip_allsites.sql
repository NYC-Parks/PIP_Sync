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
--drop procedure dbo.sp_m_tbl_pip_allsites
create procedure dbo.sp_m_tbl_pip_allsites as
	
	begin transaction
		merge accessnewpip.dbo.tbl_pip_allsites as tgt using accessnewpip.dbo.tbl_ref_allsites as src
		/*Use the omppropid aka prop id as the merge key. Remove records with duplicate or null prop ids.*/
		on (tgt.[prop id] = src.[prop id] and
		    lower(src.sourcefc) != 'structure')
		/*If the records are matched based on the identifiers, no updates are necessary*/
		/*when matched
			then update set propnum = src.propnum*/
		/*If the record is in in tbl_pip_allsites, but not tbl_ref_allsites, an accidental deletion took place, so add the record back.*/
		when not matched by target
			then insert([prop id])
				values(src.[prop id]);
		/*Skip the delete section because this cannot occur with the foreign key constraint.*/
		/*when not matched by source
			then update set gis_deleted = 1;*/
	commit;
