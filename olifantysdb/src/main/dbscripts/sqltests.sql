
-- give geert some money some money
begin work;
CREATE OR REPLACE function testtransfer(mon integer,hom integer) RETURNS int
LANGUAGE plpgsql
as $testtransfer$
declare
    monaccount account%rowtype;
    homaccount account%rowtype;
    amount numeric;
    reason text;
    transid int;
begin

    amount :=500;
    reason := 'Test 1';

select a.* into monaccount
    from account a join customer c using(customerid) 
    where accountid = (select min(accountid) from account where customerid=mon) ;
    
    select a.* into homaccount
    from account a join customer c using(customerid) 
    where accountid = (select min(accountid) from account where customerid=hom) ;
    raise notice ' boe % ', monaccount;
    raise notice  'about to transfer % from % to % with reason "%"',amount,homaccount,monaccount,reason;
    update account set astate='open' where accountid in (monaccount.accountid, homaccount.accountid);
    transid := transferflockfree(homaccount.accountid,monaccount.accountid,amount,reason);
    raise notice 'transid %', transid;
    return transid;
end; $testtransfer$;
commit;

select * from customer;
select unblock( 2 );
select unblock( 3 );
update account set astate='open';
select testtransfer(2,3);
select * from mytransactions;
select * from transactions;
select testtransfer(3,2);
select * from transactions;
select * from customerjoinaccount;

insert into account(accountid,balance,maxdebit,customerid,astate,accountdescription)
  values(100,500,1500,1,'open','test account');
select a.* from account a where accountid=100;
select (getaccountevent(100,'deposit'::bankevent)).*;
select getaccounteventtest();
delete from account where accountid=100;
commit;
