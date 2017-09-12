
begin work;

CREATE OR REPLACE FUNCTION updateaccountstate(accountid integer, bankevent bankevent) returns accountstate
    LANGUAGE plpgsql
    AS $updatecustomerstate$
DECLARE
    fromrecord customeraccountallowedstateevent%rowtype;

BEGIN
    select * from customeraccountallowedstateevent
        where accountid= accountid
             and cevent = bankevent
             and aevent = bankevent
        for update into fromrecord;

    IF NOT FOUND THEN
            RAISE EXCEPTION 'account % does not exists, or in illegal state update %',accountid, bankevent ;
    END IF;
    -- if passed the raising, can do the update
    update account set astate = fromrecord.aendstate
    where accountid= accountid
             and cevent = bankevent
             and aevent = bankevent
        for update into fromrecord;
    return fromrecord.aendstate ;
END; $updatecustomerstate$;


CREATE OR REPLACE FUNCTION freezeaccount(accountid integer) RETURNS account
    LANGUAGE plpgsql
    AS $freezeaccount$
BEGIN
   
END;
commit;