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
select propnum,
	   [prop id],
	   sourcefc,
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
	   row_hash,
	   count(*) over(partition by [prop id] order by [prop id]) as n_propid,
	   count(*) over(partition by [prop id], sourcefc order by [prop id], sourcefc) as n_propid_within
from accessnewpip.dbo.vw_pip_compatible_inspected_sites
where n_propid > 1 and 
	  n_propid_within = 1 and
	  lower(sourcefc) != 'structure'

select *
from accessnewpip.dbo.vw_pip_compatible_inspected_sites
where n_propid > 1 and 
	  lower(sourcefc) = 'RestrictiveDeclarationSite'
