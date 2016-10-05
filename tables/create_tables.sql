drop table opi_fact   purge;
drop table opi_dim01  purge;


create table opi_dim01 (
  dim    varchar2(10),
  attr01 varchar2(10),
  --
  constraint opi_dim01_pk primary key (dim)
);

create table opi_fact (
  pk               number,
  dim01            not null references opi_dim01,
  attr_num_nn      number not null,
  --
  constraint opi_fact_pk primary key (pk)
);
