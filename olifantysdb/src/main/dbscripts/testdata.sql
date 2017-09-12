/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
/**
 * Author:  hom
 * Created: Apr 24, 2016
 */

begin work;
select createcustomer('Oliver Olifantys, Banker','5911 CX') where not exists (select 1 from customer where name like 'Oliver%');
select createcustomer('Geert Monsieur','3630') where not exists (select 1 from customer where name like 'Geert%');
select createcustomer('Pieter van den Hombergh','5913 WH') where not exists (select 1 from customer where name like 'Pieter%');
select createcustomer('Thijs Dorssers','5913 WH') where not exists (select 1 from customer where name like 'Thijs%');
select createcustomer('Fontys Hogescholen','5410 PG') where not exists (select 1 from customer where name like 'Fontys%');
select * from customer;
-- create an account with a high number

insert into account (accountid,balance,customerid,maxdebit,astate,accountdescription) select 99999999,1000000,1,5*1000000, 'open','Bankers Master Account, caveat tax payer'
  where not exists (select 1 from account where accountid=99999999);
select * from customerjoinaccount;

select createaccount(2,1000,'salaris rekening'); -- mon starts with 1000
select createaccount(2,3000,'spaar rekening'); -- mon ac 2 starts with 3000
select createaccount(3,500,'salaris rekening'); -- hom with 500
select createaccount(3,2500,null); -- hom ac 2with 2500
select createaccount(4,500); -- dos with 500
select createaccount(5,250000, 'Business account'); -- fontys dos ac 2with 250000

select * from customerjoinaccount order by customerid,accountid;

commit;
