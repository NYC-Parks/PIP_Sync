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
/*Truncate or delete all existing data*/
begin transaction
truncate table accessnewpip.dbo.tbl_ref_allsites_nosync
truncate table accessnewpip.dbo.tbl_ref_allsites_audit
truncate table accessnewpip.dbo.tbl_pip_allsites
truncate table accessnewpip.dbo.tbl_pip_allsites_audit
delete 
from accessnewpip.dbo.tbl_ref_allsites
commit

/*Execute the stored procedures that perform the merges*/
exec accessnewpip.dbo.usp_i_tbl_temp_ref_allsites 
exec accessnewpip.dbo.usp_m_tbl_ref_allsites
exec accessnewpip.dbo.usp_m_tbl_ref_allsites_nosync
exec accessnewpip.dbo.usp_m_tbl_pip_allsites

/***************************************/
/*run insert_tbl_pip_allsites_structure*/
/***************************************/
exec accessnewpip.dbo.sp_m_tbl_pip_allsites

/*Test some updates in the audit*/
begin transaction
	update accessnewpip.dbo.tbl_pip_allsites
		set rated = 1
		where [prop id] = 'B001'
commit;

begin transaction
	update accessnewpip.dbo.tbl_pip_allsites
		set rated = 0
		where [prop id] = 'B001'
commit;

begin transaction
	update accessnewpip.dbo.tbl_pip_allsites
		set rated = 1
		where [prop id] = 'B001'
commit;

/*Query results*/
select *
from accessnewpip.dbo.tbl_ref_allsites

select *
from accessnewpip.dbo.tbl_ref_allsites_nosync