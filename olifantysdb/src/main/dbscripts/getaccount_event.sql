/**
 * Author:  hom
 * Created: Apr 23, 2016
 */

/**
 * Get account plus event for update.
 */
begin work;
create or replace function getaccountevent (ac integer, event bankevent, out eventresult accountevent) returns accountevent
LANGUAGE plpgsql
AS $getaccountevent$

DECLARE 
BEGIN
    select accountid , balance, maxdebit , customerid , 
            astate, event
        from account 
        where accountid = ac into eventresult for update;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'account % does not exists',ac;
    END IF;
    return;
END; $getaccountevent$;

create or replace function getaccounteventtest() returns void
language plpgsql
as $getaccounteventtest$
declare  
  tresult accountevent%rowtype;
  aresult record;
begin
    tresult := getaccountevent(100,'withdraw'::bankevent);
    select * from customer where customerid = tresult.customerid into aresult;
    raise notice 'tresult %  ',aresult;
    return;
end; $getaccounteventtest$;

commit;
