/***********************************************************************************************************************
																													   	
 Created By: Dan Gallagher, daniel.gallagher@parks.nyc.gov, Innovation & Performance Management         											   
 Modified By: <Modifier Name>																						   			          
 Created Date:  <MM/DD/YYYY>																							   
 Modified Date: <MM/DD/YYYY>																							   
											       																	   
 Project: <Project Name>	
 																							   
 Tables Used: <Database>.<Schema>.<Table Name1>																							   
 			  <Database>.<Schema>.<Table Name2>																								   
 			  <Database>.<Schema>.<Table Name3>				
			  																				   
 Description: <NOTE: PROP ID should be primary key in this table if you want to make edits in SSMS editor. Can be applied at end of runbook via "table properties" dialog >  									   
																													   												
***********************************************************************************************************************/
if object_id('accessnewpip.dbo.tbl_pip_allsites') is not null
	drop table accessnewpip.dbo.tbl_pip_allsites;

create table accessnewpip.dbo.tbl_pip_allsites([prop id] nvarchar(15) not null unique foreign key references accessnewpip.dbo.tbl_ref_allsites([prop id]),
											   category nvarchar(128), --foreign key references accessnewpip.dbo.tbl_ref_category(category),
											   [sub-category] nvarchar(40), --foreign key references accessnewpip.dbo.tbl_ref_subcategory([sub-category]),
											   [site category] nvarchar(128),
											   [rating category] nvarchar(128),
											   rated bit not null default 0,
											   [reason not rated] nvarchar(128),
											   [safety index] smallint,
											   comfortstation smallint,
											   comments nvarchar(255),
											   created_date datetime not null default getdate());
