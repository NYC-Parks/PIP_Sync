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
if object_id('accessnewpip.dbo.tbl_temp_ref_allsites') is not null
	drop table accessnewpip.dbo.tbl_temp_ref_allsites;

create table accessnewpip.dbo.tbl_temp_ref_allsites(propnum nvarchar(25) null,
													[prop id] nvarchar(25) null,
													boro nvarchar(1) null,
													ampsdistrict nvarchar(25) null,
													[prop name] nvarchar(100) null,
													[site name] nvarchar(100) null,
													[prop location] nvarchar(100) null,
													[site location] nvarchar(100) null,
													jurisdiction nvarchar(25) null,
													typecategory nvarchar(100) null,
													acres real null,
													gisobjid int null,
													sourcefc varchar(26) not null,
													shape geometry null,
													row_hash_origin varbinary(max) null,
													row_hash_dest as hashbytes('SHA2_256', concat(PropNum, Boro, AMPSDistrict, [Prop Name], [Site Name], 
																								  [Prop Location], [Site Location], jurisdiction, typecategory, acres, 
																								  gisobjid, sourcefc, row_hash_origin, dupflag, syncflag, n_propid)) persisted,
													dupflag int not null,
													syncflag int not null,
													n_propid int null)