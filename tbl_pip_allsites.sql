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
if object_id('accessnewpip.dbo.tbl_pip_allsites') is not null
	drop table accessnewpip.dbo.tbl_pip_allsites;

create table accessnewpip.dbo.tbl_pip_allsites([Prop ID] nvarchar(15) unique foreign key references accessnewpip.dbo.tbl_ref_allsites([Prop ID]),
											   Category nvarchar(128) foreign key references accessnewpip.dbo.tbl_ref_category(Category),
											   [Sub-Category] nvarchar(40) foreign key references accessnewpip.dbo.tbl_ref_subcategory([Sub-Category]),
											   Rated bit not null,
											   [Reason Not Rated] nvarchar(128),
											   [Safety Index] smallint,
											   [ComfortStation] smallint,
											   Comments nvarchar(255));