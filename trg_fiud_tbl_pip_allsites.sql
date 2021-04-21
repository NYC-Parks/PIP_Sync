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
--drop trigger dbo.trg_fiud_tbl_pip_allsites
create trigger dbo.trg_fiud_tbl_pip_allsites
on accessnewpip.dbo.tbl_pip_allsites
for insert, update, delete as

	begin transaction
		insert into accessnewpip.dbo.tbl_pip_allsites_audit([prop id],
															category,
															[sub-category],
															[site category],
															[rating category],
															rated,
															[reason not rated],
															[safety index],
															comfortstation,
															comments,
															created_date,
															dml_verb,
															updated_user)
			select coalesce(r.[prop id], l.[prop id]) as [prop id],
				   coalesce(r.category, l.category) as category,
				   coalesce(r.[sub-category], l.[sub-category]) as [sub-category],
				   coalesce(r.[site category], l.[site category]) as [site category],
				   coalesce(r.[rating category], l.[rating category]) as [rating category],
				   coalesce(r.rated, l.rated) as rated,
				   coalesce(r.[reason not rated], l.[reason not rated]) as [reason not rated],
				   coalesce(r.[safety index], l.[safety index]) as [safety index],
				   coalesce(r.comfortstation, l.comfortstation) as comfortstation,
				   coalesce(r.comments, l.comments) as comments,
				   coalesce(r.created_date, l.created_date) as created_date,
				   	/*Update Statement*/
				   case when l.[prop id] is not null and r.[prop id] is not null then 'U'
				   	/*Insert Statement*/
				   	when l.[prop id] is not null and r.[prop id] is null then 'I'
				   	/*Delete Statement*/
				   	when l.[prop id] is null and r.[prop id] is not null then 'D'
				   	else null
				   end as dml_verb,
				   replace(current_user, 'NYCDPR\', '') as updated_user
		    from inserted as l
			full outer join
				 deleted as r
			on l.[prop id] = r.[prop id]
	commit;