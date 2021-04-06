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
	insert into accessnewpip.dbo.tbl_pip_allsites([prop id], category, [sub-category], rated, [reason not rated], [safety index], comfortstation, comments)
		select omppropid as [prop id],
			   category,
			   sub_category as [sub-category], 
			   case when pip_ratable = 'yes' then 1 else 0 end as rated, 
			   reason_not_rated as [reason not rated], 
			   safety_index as [safety index], 
			   null as comfortstation, 
			   comments, *
		from openquery([gisdata], 'select * from parksgis.dpr.structure_evw')
		where omppropid in('QR-05', 'M010_temp3', 'QR-01', 'X034_temp', 'MR-01', 'Q468_temp', 'XR-03', 'MR-07', 'X261_temp',  'BR-03',
						   'QR-03', 'MR-08', 'MR-10', 'MR-03', 'XR-02', 'QR-04', 'BR-06', 'BR-02', 'XR-05', 'X250_temp', 'MR-12', 'XR-04',
						   'MR-02', 'BR-05', 'R149-BLG0001', 'RR-02_temp1', 'QR-02', 'MR-06', 'BR-04', 'BR-08', 'MR-11', 'MR-04', 'XR-01',
						   'BR-07', 'MR-05', 'MR-13', 'BR-01', 'B406_temp', 'MR-09', 'RR-01')
commit;


