create or replace package opi as

  procedure fill_tables;

  procedure join_fact_dim01;
  
  procedure select_parallel;

end opi;
/
