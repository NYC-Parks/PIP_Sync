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
begin transaction
	update u
	set u.[prop id] = s.[prop id],
		u.category = s.category,
		u.[sub-category] = s.[sub-category],
		u.rated = s.rated,
		u.[reason not rated] = s.[reason not rated],
		u.[safety index] = s.[safety index],
		u.comfortstation = s.comfortstation,
		u.comments = s.comments
	from accessnewpip.dbo.tbl_pip_allsites as u
	inner join
		 [gisdata].parksgis.dpr.vw_pip_compatible_inspected_sites as s
	on u.[prop id] = s.[prop id]
commit;
