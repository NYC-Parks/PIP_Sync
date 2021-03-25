REM @echo off

REM The sqlcmd -S . tells the script to use the local server. This should allow
REM the script to be server agnostic.

REM Run all the create table scripts
REM -------------------------------------------------------------------------
sqlcmd -S . -E -i tbl_ref_allsites.sql

sqlcmd -S . -E -i tbl_ref_allsites_audit.sql

sqlcmd -S . -E -i tbl_ref_allsites_nosync.sql

sqlcmd -S . -E -i tbl_pip_allsites.sql

sqlcmd -S . -E -i tbl_pip_allsites_audit.sql


REM Create most of the functions.
REM -------------------------------------------------------------------------

sqlcmd -S . -E -i fn_get_pipboro.sql

sqlcmd -S . -E -i fn_get_pipdistrict.sql


REM Create the view which is dependent on the functions
REM -------------------------------------------------------------------------
sqlcmd -S . -E -i vw_pip_compatible_inspected_sites.sql

sqlcmd -S . -E -i ALLSITES.sql


REM Create all of the stored procedures.
REM -------------------------------------------------------------------------
sqlcmd -S . -E -i sp_m_tbl_ref_allsites.sql

sqlcmd -S . -E -i sp_m_tbl_ref_allsites_nosync.sql

sqlcmd -S . -E -i sp_m_tbl_pip_allsites.sql


REM Create all of the triggers.
REM -------------------------------------------------------------------------
sqlcmd -S . -E -i trg_fi_tbl_ref_allsites.sql

sqlcmd -S . -E -i trg_fu_tbl_ref_allsites.sql

sqlcmd -S . -E -i trg_fiud_tbl_pip_allsites.sql


REM Load in the PIP data into tbl_pip_allsites
REM -------------------------------------------------------------------------
sqlcmd -S . -E -i update_tbl_pip_allsites.sql