-- copyright sebi venlo 2017
-- @author Pieter van den Hombergh {@code <p.vandenhombergh@fontys.nl>}
begin work; -- on any error abort
 
CREATE OR REPLACE FUNCTION updateaccountstate(accid integer, bankevent bankevent) RETURNS accountstate
    LANGUAGE plpgsql
    SECURITY DEFINER

    AS $updateaccountstate$
DECLARE
    staterecord customeraccountallowedstateevent%rowtype;
BEGIN
    select *
    into staterecord
    from customeraccountallowedstateevent caase
    where accountid=accid
    and bankevent= aevent and bankevent=cevent;
    if not found then
        raise exception 'account is not found or in state which does not allow the % event',bankevent;
    end if;
    raise notice 'changing account % to % state',accid, staterecord.aendstate;
    update account acc
	set astate = staterecord.aendstate
    where accountid = accid;
    return staterecord.aendstate;
END; $updateaccountstate$;

CREATE OR REPLACE FUNCTION updatecustomerstate(custid integer, bankevent bankevent) RETURNS void
    LANGUAGE plpgsql
    AS $updatecustomerstate$
DECLARE
    currentstate customer.cstate%type;
    endstate customer.cstate%type;
    staterecord customerallowedstateevent%rowtype;
BEGIN
    select *
    into staterecord
    from customerallowedstateevent
    where customerid=custid;
    if not found then
        raise exception 'customer is in state which does not allow the "%" event',bankevent;
    end if;

    raise notice 'changing customer % to % state',custid, staterecord.cendstate;
    update customer cust
    set cstate = staterecord.cendstate
where cust.customerid = custid;
END;
$updatecustomerstate$;

show application_name;

CREATE FUNCTION createcustomer(name text, postcode text) RETURNS customer
LANGUAGE plpgsql
SECURITY DEFINER

AS $createcustomer$
DECLARE
    initialstate customer.cstate%type;
    rec customer;
    cid integer;
BEGIN
    select nextval('customer_customerid_seq'::regclass) into cid;
    SELECT endstate
    INTO initialstate
    FROM customerstatemachine
    WHERE startstate='non-existent';
    INSERT INTO customer (customerid,name,postcode,cstate) VALUES (cid,name,postcode,initialstate)
    returning * into rec;
    return rec;
END;
$createcustomer$;


CREATE OR REPLACE FUNCTION block(custid integer) RETURNS customerstate
LANGUAGE plpgsql
SECURITY DEFINER

AS $block$
BEGIN
    return 'blocked';
    perform updatecustomerstate(custid,'block');
END;
$block$;

CREATE OR REPLACE FUNCTION unblock(custid integer) RETURNS customerstate
LANGUAGE plpgsql
SECURITY DEFINER

AS $unblock$
BEGIN
    perform updatecustomerstate(custid,'unblock');
    return 'exists';
END;
$unblock$;

CREATE OR REPLACE FUNCTION openaccount(accid integer) RETURNS accountstate
LANGUAGE plpgsql
SECURITY DEFINER

AS $openaccount$
BEGIN
    perform updateaccountstate(accid,'openaccount');
    return 'open';
END;
$openaccount$;


CREATE OR REPLACE FUNCTION createaccount(custid integer, initialbalance numeric, description text) RETURNS account
LANGUAGE plpgsql
SECURITY DEFINER
AS $createaccountf$
DECLARE
    initialstate account.astate%type;
    rec account;
BEGIN
    perform updatecustomerstate(custid,'createaccount'); -- ensure legality
    SELECT endstate
    INTO initialstate
    FROM accountstatemachine
    WHERE startstate='non-existent';
    IF description is null then
       INSERT INTO account (customerid,balance,astate)
       VALUES (custid,initialbalance,initialstate) returning * into rec ;
    ELSE
	INSERT INTO account (customerid,balance,astate,accountdescription)
    	VALUES (custid,initialbalance,initialstate,description ) returning * into rec ;
    END IF;
    IF initialbalance > 0 then
       
       perform transferflockfree(99999999,rec.accountid,initialbalance, 'opening deposit');
    END IF;
return rec;
END;
$createaccountf$;

CREATE OR REPLACE FUNCTION createaccount(custid integer, initialbalance numeric) RETURNS account
LANGUAGE plpgsql
SECURITY DEFINER

AS $createaccountf$
DECLARE
   rec account;
BEGIN
	select * from createaccount(custid, initialbalance,null::text) into rec;
	return rec;
END;
$createaccountf$;

commit;


