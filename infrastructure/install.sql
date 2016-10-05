--
-- https://docs.oracle.com/cd/B28359_01/server.111/b28320/statviews_5127.htm
--
drop table plan_table purge;
@?/rdbms/admin/utlxplan.sql

@opi.pks
@opi.pkb
