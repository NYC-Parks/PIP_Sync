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
	set category = s.category, 
		[sub-category] = s.[sub-category], 
		rated = s.rated, 
		[reason not rated] = s.[reason not rated], 
		[safety index] = s.[safety index], 
		comfortstation = s.comfortstation, 
		comments = s.comments
	from accessnewpip.dbo.tbl_pip_allsites as u
	left join
		 accessnewpip.dbo.tbl_ref_allsites as u2
	on u.[prop id] = u2.[prop id]
	left join
		 [dataparks].accessnewpip.dbo.allsites as s--[gisdata].parksgis.dpr.vw_pip_compatible_inspected_sites as s
	on u.[prop id] = s.[prop id] and
	   u2.sourcefc = s.sourcefc
	where s.rated is not null and
		  s.sourcefc != 'Structure'
commit;