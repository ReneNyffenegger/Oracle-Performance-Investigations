truncate table plan2html_t;

exec opi.select_parallel

$del   c:\temp\opi.html
@spool c:\temp\opi.html
select html from plan2html_t order by seq;
@spool_off
$c:\temp\opi.html
