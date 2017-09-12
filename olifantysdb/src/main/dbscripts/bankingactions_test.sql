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
create or replace function test1() returns void 
language plpgsql as $test1$
declare transid int;
begin
    transid := transferflockfree(5,4,25,'zomaar');
    raise exception 'should have thrown exception';
    exception 
        when dataexception then
        raise notice 'all is well';
        rollback;
   
end; $test1$;
commit;

select updateaccountstate(5,'openaccount');
select updateaccountstate(4,'openaccount');

select transferflockfree(4,5,25,'zomaar');
select transferflockfree(5,4,25,'zomaar');
select updateaccountstate(5,'freezeaccount');
select transferflockfree(4,5,25,'zomaar');
select transferflockfree(5,4,25,'zomaar');

select * from transactions;
