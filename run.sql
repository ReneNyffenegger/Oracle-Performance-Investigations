truncate table plan2html_t;

exec opi.join_fact_dim01

$del   c:\temp\opi.html
@spool c:\temp\opi.html
select html from plan2html_t order by seq;
@spool_off
$c:\temp\opi.html
