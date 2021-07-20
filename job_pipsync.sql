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
use msdb ;  
go  

/*If the job already exists, delete it.*/
if exists(select * from msdb.dbo.sysjobs where name = 'job_pipsync')
	begin	
		exec sp_delete_job @job_name = N'job_pipsync';  
	end;
go


/*If the schedule doesn't exist, create it.*/
if not exists(select * from msdb.dbo.sysschedules where name = 'Once_Daily_0001')
	begin	
		exec dbo.sp_add_schedule  
			@schedule_name = N'Once_Daily_0001',  
			@freq_type = 4,  
			@freq_interval = 1,
			@active_start_time = 000100 ;  
	end;
go

/*Create a parameter to store the job_id*/
declare @job_id uniqueidentifier;
declare @owner sysname;
--exec master.dbo.usp_sql_owner @file_path = 'D:\Projects', @result = @owner output;

/*Create the job*/
exec dbo.sp_add_job @job_name = N'job_pipsync', 
					@enabled = 1,
					@description = N'Execute stored procedures that power the accessnewpip list of sites.',
					@owner_login_name = @owner,
					@job_id = @job_id output;

exec dbo.sp_add_jobserver  
   @job_id = @job_id,  
   @server_name = N'(LOCAL)';  

/*Merge vw_pip_sync with tbl_temp_ref_allsites-- MEF made adjusments to usp_m_tbl_temp_ref_allsites to accommodate [SystemDB].[dbo].[TBL_PIP_SYNC] so this is actually a merge of that*/
exec dbo.sp_add_jobstep  
    @job_id = @job_id,  
    @step_name = N'usp_m_tbl_temp_ref_allsites',  
    @subsystem = N'TSQL',  
    @command = N'exec accessnewpip.dbo.usp_m_tbl_temp_ref_allsites',
	@on_success_action = 3,
	@on_fail_action = 3;

/*Merge tbl_temp_ref_allsites with tbl_ref_allsites*/
exec dbo.sp_add_jobstep  
	@job_id = @job_id,  
	@step_name = N'usp_m_tbl_ref_allsites',  
	@subsystem = N'TSQL',  
	@command = N'exec accessnewpip.dbo.usp_m_tbl_ref_allsites',
	@on_success_action = 3,
	@on_fail_action = 3;

/*Merge tbl_temp_ref_allsites with tbl_ref_allsites_nosync*/
exec dbo.sp_add_jobstep  
	@job_id = @job_id,  
	@step_name = N'usp_m_tbl_ref_allsites_nosync',  
	@subsystem = N'TSQL',  
	@command = N'exec accessnewpip.dbo.usp_m_tbl_ref_allsites_nosync',
	@on_success_action = 3,
	@on_fail_action = 3;

/*Merge tbl_ref_allsites with tbl_pip_allsites*/
exec dbo.sp_add_jobstep  
	@job_id = @job_id,  
	@step_name = N'usp_m_tbl_pip_allsites',  
	@subsystem = N'TSQL',  
	@command = N'exec accessnewpip.dbo.usp_m_tbl_pip_allsites',
	@on_success_action = 1,
	@on_fail_action = 2;

exec dbo.sp_attach_schedule  
   @job_id = @job_id,  
   @schedule_name = N'Once_Daily_0001';  

