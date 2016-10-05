create or replace package body opi as


  procedure explain_plan(stmt varchar2, stmt_id varchar2) is -- {
  begin
    delete from plan_table where statement_id = stmt_id;
    execute immediate 'explain plan set statement_id = ''' || stmt_id || ''' for ' || stmt;
  exception when others then
    raise_application_error(-20800, 'explain_plan failed for ' || stmt || ': ' || sqlerrm);
  end explain_plan; -- }

  procedure join_fact_dim01 is -- {

    stmt varchar2(32000);
  begin


    for hi in (
      select 'use_nl   (f d)' nt from dual union all
      select 'use_nl   (d f)' nt from dual union all
      select 'use_hash (f d)' nt from dual union all
      select 'use_hash (d f)' nt from dual union all
      select 'use_merge(f d)' nt from dual union all
      select 'use_merge(d f)' nt from dual
    ) loop

      stmt := 'select /*+ ' || hi.nt || ' */ * 
  from
    opi_fact f join opi_dim01 d on f.dim01 = d.dim
  where
    d.attr01 = ''foo''';

      explain_plan(stmt, hi.nt);
      plan2html.write_out('<code><pre>' || stmt || '</pre></code>');
      plan2html.explained_stmt_to_table(hi.nt);

    end loop;

  end join_fact_dim01; -- }


end opi;
/

show errors
