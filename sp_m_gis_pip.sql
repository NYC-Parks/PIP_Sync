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

create procedure dbo.sp_m_gis_pip as

	begin transaction
		
		with gis_allsites as(
			select *
			from [gisdata].parksgis.dpr.vw_pip_compatible_inspected_sites
			/*Probably need to build in duplicate and null exclusion here*/)

		merge accessnewpip.dbo.tbl_ref_allsites as tgt using gis_allsites as src
		on (tgt.[prop id] = src.[prop id])
		/*If the records are matched based on the identifiers, but the record in GIS has a greater edit date than the record in PIP
		  then update the whole record.*/
		when matched and tgt.last_edited_date < src.last_edited_date
			then update set col = src.col
		when not matched by target
			then insert(col)
				values(src.col)
		/*Skip the delete section because we can't break any keys and the cascade effect is not known.*/
	commit;

	select *
	from sys.servers