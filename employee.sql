create table DEPARTMENTS (  
  deptno        number,  
  name          varchar2(50) not null,  
  location      varchar2(50),  
  constraint pk_departments primary key (deptno)  
);

create table EMPLOYEES (  
  empno             number,  
  name              varchar2(50) not null,  
  job               varchar2(50),  
  manager           number,  
  hiredate          date,  
  salary            number(7,2),  
  commission        number(7,2),  
  deptno           number,  
  constraint pk_employees primary key (empno),  
  constraint fk_employees_deptno foreign key (deptno) 
      references DEPARTMENTS (deptno)  
);

create or replace trigger  DEPARTMENTS_BIU
    before insert or update on DEPARTMENTS
    for each row
begin
    if inserting and :new.deptno is null then
        :new.deptno := to_number(sys_guid(), 
          'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');
    end if;
end;
/



create or replace trigger EMPLOYEES_BIU
    before insert or update on EMPLOYEES
    for each row
begin
    if inserting and :new.empno is null then
        :new.empno := to_number(sys_guid(), 
            'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');
    end if;

    select table_name "Table", 
       index_name "Index", 
       column_name "Column", 
       column_position "Position"
from  user_ind_columns 
where table_name = 'EMPLOYEES' or 
      table_name = 'DEPARTMENTS'
order by table_name, column_name, column_position
end;
/


insert into departments (name, location) values
   ('Finance','Milton Keynes');

insert into departments (name, location) values
   ('Software Development','Bedford');

select * from departments;


insert into EMPLOYEES 
   (name, job, salary, deptno) 
   values
   ('Sam Smith','Programmer', 
    5000, 
  (select deptno 
  from departments 
  where name = 'Development'));

insert into EMPLOYEES 
   (name, job, salary, deptno) 
   values
   ('Mara Martin','Database Analyst', 
   6000, 
   (select deptno 
   from departments 
   where name = 'Finance'));

insert into EMPLOYEES 
   (name, job, salary, deptno) 
   values
   ('Yun Yates','Analyst', 
   5500, 
   (select deptno 
   from departments 
   where name = 'Development'));



------index foreign keys-----
create index employee_dept_no_fk_idx 
on employees (deptno)


create unique index employee_ename_idx
on employees (name)

------querying data ---------------
select e.name employee,
           d.name department,
           e.job,
           d.location
from departments d, employees e
where d.deptno = e.deptno(+)
order by e.name;

select e.name employee,
          (select name 
           from departments d 
           where d.deptno = e.deptno) department,
           e.job
from employees e
order by e.name;

-----adding columns ----------

alter table EMPLOYEES 
add country_code varchar2(2);

-----querying oracle data dictionary -------------
select table_name, tablespace_name, status
from user_tables
where table_Name = 'EMPLOYEES';

select column_id, column_name , data_type
from user_tab_columns
where table_Name = 'EMPLOYEES'
order by column_id;


----------------update data-----------------
update employees
set country_code = 'US';

update employees
set commission = 2000
 where name = 'L Ryan';


select name, country_code, salary, commission
from employees
order by name;

---------aggregate queries ---------------

select 
      count(*) employee_count,
      sum(salary) total_salary,
      sum(commission) total_commission,
      min(salary + nvl(commission,0)) min_compensation,
      max(salary + nvl(commission,0)) max_compensation
from employees;
------------compressing data-------------------

alter table EMPLOYEES compress for oltp; 
alter table DEPARTMENTS compress for oltp;


---------- deleting data ----------------------------
delete from employees 
where name = 'Sam Smith';


drop table departments cascade constraints;
drop table employees cascade constraints;

elect object_name, 
       original_name, 
       type, 
       can_undrop, 
       can_purge
from recyclebin;

flashback table DEPARTMENTS to before drop;
flashback table EMPLOYEES to before drop;
select count(*) departments 
from departments;
select count(*) employees
from employees;






