create or replace package body opi as

  type vc_t is table of varchar2(4000);

  procedure fill_tables is-- {
    

    procedure fill_fact is -- {

      t0 timestamp;
      t1 timestamp;

      a  number;
      r  number;

      type   fact_t is table of opi_fact%rowtype index by pls_integer;
      fact_r fact_t;

      size_forall_insert constant number := 100000;
      nof_records        constant number := size_forall_insert * case when user = 'RENE' then 10 else 100 end;

      dim01_pk vc_t := vc_t( -- {
          'AB'  , 
          'CDE' , 
          'FGH' , 
          'IJ'  , 
          'KLM' , 
          'N'   , 
          'OPQR', 
          'ST'  , 
          'UVW' , 
          'XYZ' ); -- }

      procedure fill_dim01 is -- {
  
          v_attr01 opi_dim01.attr01%type;
      begin
  
          for i in 1 .. dim01_pk.count loop -- {
  
              if i = 5 then
                 v_attr01 := 'foo';
              else
                 v_attr01 := 'bar';
              end if;
              
              insert into opi_dim01 values (dim01_pk(i), v_attr01);
  
           end loop; -- }
  
      end fill_dim01; -- }

    begin

--    delete opi_fact;
      execute immediate 'truncate table opi_fact';

      delete opi_dim01;

      fill_dim01;

      t0 := systimestamp;

      for i in 1 .. nof_records loop -- {

          r := dbms_random.value;

          a := case 
               when  r < 0.3    then  1
               when  r < 0.5    then  2
               when  r < 0.6    then  3
               when  r < 0.61   then  4
               when  r < 0.799  then  5
               when  r < 0.8    then  6
               when  r < 0.82   then  7
               when  r < 0.85   then  8
               when  r < 0.91   then  9
               else                10 end;

           fact_r(mod(i - 1, size_forall_insert)).pk          := i;
           fact_r(mod(i - 1, size_forall_insert)).dim01       := dim01_pk(a);
           fact_r(mod(i - 1, size_forall_insert)).attr_num_nn := trunc(dbms_random.value(10000, 100000));

           if mod(i, size_forall_insert) =  0 then
              forall j in 0 .. size_forall_insert-1 insert into opi_fact values fact_r(j);
           end if;

      end loop; -- }


      t1 := systimestamp;

--    dbms_output.put_line('Time to insert: ' || to_char('90.9999', extract(second from t1 - t0)));
      dbms_output.put_line('Time to insert: ' ||                    extract(second from t1 - t0 ));

      dbms_stats.gather_table_stats(user, 'opi_fact' );
      dbms_stats.gather_table_stats(user, 'opi_dim01');


    end fill_fact; -- }

  begin

    fill_fact;

  end fill_tables; -- }

  procedure explain_plan(stmt varchar2, stmt_id varchar2) is -- {
  begin
    delete from plan_table where statement_id = stmt_id;
    execute immediate 'explain plan set statement_id = ''' || stmt_id || ''' for ' || stmt;
  exception when others then
    raise_application_error(-20800, 'explain_plan failed for ' || stmt || ': ' || sqlerrm);
  end explain_plan; -- }

  procedure join_fact_dim01 is -- {
    stmt varchar2(32000);

    sum_   number;
    count_ number;

    t0     timestamp;
    t1     timestamp;
  begin


    for hi in (
      select 'use_nl   (f d)' nt from dual union all
      select 'use_nl   (d f)' nt from dual union all
      select 'use_hash (f d)' nt from dual union all
      select 'use_hash (d f)' nt from dual union all
      select 'use_merge(f d)' nt from dual union all
      select 'use_merge(d f)' nt from dual
    ) loop

      stmt := 'select /*+ ' || hi.nt || ' */ sum(attr_num_nn), count(*)
  from
    opi_fact f join opi_dim01 d on f.dim01 = d.dim
  where
    d.attr01 = ''foo''';

      explain_plan(stmt, hi.nt);
      plan2html.write_out('<code><pre>' || stmt || '</pre></code>');
      plan2html.explained_stmt_to_table(hi.nt);

      t0 := systimestamp;
      execute immediate stmt into sum_, count_;
      t1 := systimestamp;

      plan2html.write_out('count: ' || count_ || ', it took ' || round(extract(second from t1-t0), 3) || ' seconds for the select statement to complete.');
      plan2html.write_out('<p>');

    end loop;

  end join_fact_dim01; -- }


end opi;
/

show errors
