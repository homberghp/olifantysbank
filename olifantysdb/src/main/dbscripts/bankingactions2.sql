
begin work;

create or replace rule bankingactionupdate  as
    ON UPDATE to customeraccountallowedstateevent
    DO instead (
        update account set balance= new.balance where accountid=new.accountid;
        );

create or replace function checkbankingrules(donorevent accountevent, transactionrole text) returns void
language plpgsql
SECURITY DEFINER
as $checkbankingrules$
declare
    fromstaterecord record;
begin
    with dasm as (
        select *,donorevent.accountid,donorevent.balance 
        from accountstatemachine asm 
        where startstate=donorevent.astate and asm.event=donorevent.event
    ), dcsm as (
        select customerid,cstate,event,endstate 
        from customer cust 
        left join customerstatemachine csm on csm.startstate=cust.cstate 
        where customerid=donorevent.customerid 
    ) 
    select acc.accountid, c.customerid, 
        acc.astate, 
        dasm.event as aevent, 
        dasm.endstate as aendstate, 
        c.cstate, 
        dcsm.event as cevent, 
        dcsm.endstate as cendstate, 
        acc.balance
    from account acc join customer c using(customerid)
    left join dasm on acc.astate=dasm.startstate and acc.accountid=dasm.accountid
    left join dcsm on dcsm.customerid=c.customerid
    where acc.accountid = donorevent.accountid and c.customerid=dcsm.customerid and dcsm.event=donorevent.event
    into fromstaterecord;
    
    -- raise notice 'staterecord (a,c,as,ae,aes,cs,ce,ces,bal)= %',fromstaterecord;

    IF fromstaterecord.aendstate isnull OR fromstaterecord.cendstate ISNULL then
        raise exception 'not obeying banking rules for event "%", role "%" customer (%) in state "%", account (%) in state "%"', 
        donorevent.event,transactionrole,fromstaterecord.customerid,fromstaterecord.cstate, fromstaterecord.accountid,donorevent.astate
        using errcode='dataexception';
    end if;

end; $checkbankingrules$;

CREATE OR REPLACE FUNCTION transferflockfree(froma integer, toa integer, amount  numeric, reason text) RETURNS int

LANGUAGE plpgsql
SECURITY DEFINER
AS $transfer$
DECLARE
    fromstaterecord record;--customeraccountallowedstateevent%rowtype;
    tostaterecord   record;-- customeraccountallowedstateevent%rowtype;
    donorevent    accountevent;
    receiverevent accountevent;
    trans_id int;
BEGIN
    -- check validity of amount
    if amount <= 0 then
        raise exception '% is an illegal amount for a transfer',amount;
    end if;
    -- check conditions for accounts from and to
    -- get the relevant info in a fixed order, set by accountid
    -- starting with lowest number avoids deadlocks.
    if fromA < toA then
        -- from first
        donorevent := getaccountevent(fromA, 'withdraw'::bankevent);
        receiverevent := getaccountevent(toA, 'deposit'::bankevent);
    else 
        -- to first
        receiverevent := getaccountevent(toA, 'deposit'::bankevent);
        donorevent := getaccountevent(fromA, 'withdraw'::bankevent);
    end if;
    
    if donorevent.balance + donorevent.maxdebit - amount < 0 then
        raise EXCEPTION 'from account #% payment rule violation balance = %,maxdebit = %, amount = %', froma, donorevent.balance,event.maxdebit , amount;
    end if;

    -- check donor account and customer
    perform checkbankingrules(donorevent,'donor');
    -- check receiver account and customer
    perform checkbankingrules(receiverevent,'receiver');

    -- checks if withdrawal and deposit is allowed is now complete.
    select nextval('transactions_transid_seq'::regclass) into trans_id;

    insert into transactions (transid,amount,receiver,donor,description,ts)
        values(trans_id,amount,toa,froma,reason,now()::timestamp);

    update customeraccountallowedstateevent
        set balance = balance-amount
        where accountid = froma and cevent='withdraw' and aevent='withdraw';

    update customeraccountallowedstateevent
        set balance = balance+amount
        where accountid = toa and cevent='deposit' and aevent='deposit';

    return trans_id;
END; $transfer$;

CREATE OR REPLACE FUNCTION transfer(froma integer, toa integer, amount  numeric, reason text, out transid int) RETURNS int
LANGUAGE plpgsql
SECURITY DEFINER

AS $withdraw$
BEGIN 
    transid= transferflockfree(froma, toa,  amount, reason);
END; $withdraw$;

CREATE OR REPLACE FUNCTION transferv(froma integer, toa integer, amount  numeric, reason text) RETURNS mytransactions
LANGUAGE plpgsql
SECURITY DEFINER

AS $withdraw$
DECLARE 
  rec mytransactions;
  trans_id int;
BEGIN 
    trans_id= transferflockfree(froma, toa,  amount, reason);
    SELECT * FROM mytransactions WHERE accountid=froma and transid=trans_id into rec;
    RETURN rec;
END; $withdraw$;



CREATE OR REPLACE FUNCTION withdraw(in froma integer, in amount  numeric, in reason text, out transid int ) RETURNS int
LANGUAGE plpgsql
SECURITY DEFINER

AS $withdraw$
declare 
    bankaccount integer;
    transid int;
begin
    bankaccount=99999999;
    transid=transferflockfree(froma,bankaccount,amount,reason);
end; $withdraw$;

CREATE OR REPLACE FUNCTION deposit(in toa integer, in amount  numeric, in reason text, out transid int ) RETURNS int
LANGUAGE plpgsql
SECURITY DEFINER

AS $withdraw$
declare 
   bankaccount integer;
   transid int;
begin
    bankaccount=99999999;
    transid = transferflockfree(bankaccount,toa,amount,reason);
end; $withdraw$;

commit;
