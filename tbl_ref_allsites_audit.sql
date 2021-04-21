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
if object_id('accessnewpip.dbo.tbl_ref_allsites_audit') is not null
	drop table accessnewpip.dbo.tbl_ref_allsites_audit;

create table accessnewpip.dbo.tbl_ref_allsites_audit(PropNum nvarchar(25),
													 [Prop ID] nvarchar(15) not null foreign key references accessnewpip.dbo.tbl_ref_allsites([Prop ID]) on delete cascade,
													 Boro nvarchar(1),
													 AMPSDistrict nvarchar(25),
													 [Prop Name] nvarchar(128),
													 [Site Name] nvarchar(100),
													 [Prop Location] nvarchar(128),
													 [Site Location] nvarchar(128),
													 jurisdiction nvarchar(25),
													 typecategory nvarchar(100),
													 acres real,
													 gisobjid int, 
													 sourcefc nvarchar(30) not null,
													 shape geometry,
													 gis_deleted bit,
													 created_date datetime default getdate());