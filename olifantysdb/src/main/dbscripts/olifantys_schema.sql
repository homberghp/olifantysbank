-- copyright sebi venlo 2017
-- @author Pieter van den Hombergh {@code <p.vandenhombergh@fontys.nl>}
begin work; -- on any error abort
 

-- a postgresql enum type is very much like a Java enum. Limitted set of values and type safe.

CREATE TYPE bankevent AS ENUM('createcustomer', 'createaccount', 
    'openaccount', 'freezeaccount', 'closeaccount', 'deposit',
    'withdraw','block','unblock','endcustomer');
comment on type bankevent is 'the events that are used in the stored procedures
The name of a domain is singular, not plural because it defines a type, if not, the using tables would have
a columntype definition with an indication of plurar, which it is not.';

CREATE TYPE accountstate AS ENUM('non-existent','frozen', 'open', 'closed');
COMMENT on TYPE accountstate is 'the states of an account';

CREATE TYPE customerstate AS ENUM ('non-existent','exists', 'blocked', 'ended');
COMMENT on TYPE customerstate is 'the states of a customer';

CREATE TABLE accountstatemachine (
    startstate accountstate,
    event bankevent NOT NULL ,--default 'createcustomer' ,
    endstate accountstate NOT NULL,
    PRIMARY KEY(startstate,event)
);

COMMENT ON TABLE accountstatemachine IS 'The statmachine table for the account, with start state, event and end state
The state/event combinations define the legal combinations.
The semantics for unkown state/event combinations should be raising exceptions.
';

CREATE TABLE customerstatemachine (
    startstate customerstate,
    event bankevent NOT NULL,
    endstate customerstate NOT NULL,
		PRIMARY KEY(startstate,event)
);

INSERT INTO accountstatemachine (startstate,event,endstate) VALUES
    ('non-existent','createaccount','frozen'),
    ('frozen','deposit','frozen'),
    ('frozen','openaccount','open'),
    ('open','openaccount','open'), -- nop, but allowed
    ('frozen','closeaccount','closed'),
    ('open','freezeaccount','frozen'),
    ('frozen','freezeaccount','frozen'),
    ('open','deposit','open'),  -- nop but allowed
    ('open','withdraw','open');

INSERT INTO customerstatemachine (startstate,event,endstate) VALUES
    ('non-existent','createcustomer','exists'),
    ('exists','createaccount','exists'),
    ('exists','openaccount','exists'),
    ('exists','freezeaccount','exists'),
    ('exists','closeaccount','exists'),
    ('exists','deposit','exists'),
    ('exists','withdraw','exists'),
    ('exists','block','blocked'),
    ('blocked','block','blocked'), -- nop but allowed
    ('exists','endcustomer','ended'),
    ('blocked','closeaccount','blocked'),
    ('blocked','deposit','blocked'),
    ('blocked','freezeaccount','blocked'),
    ('blocked','unblock','exists'),
    ('exists','unblock','exists'), -- nop but allowed
    ('blocked','endcustomer','ended');


CREATE TABLE customer (
    customerid serial PRIMARY KEY,
    name text NOT NULL,
    postcode text NOT NULL,
    cstate customerstate NOT NULL
);

CREATE TABLE account (
    accountid serial PRIMARY KEY,
    balance numeric NOT NULL,
    maxdebit numeric default 0.0 not null check(maxdebit >=0),
    customerid integer NOT NULL references customer(customerid) on update cascade on delete restrict,
    astate accountstate NOT NULL,
    accountdescription text default 'Olifantys Bank Premium Account',
    check (balance + maxdebit >= 0)
);

CREATE TABLE    transactions (
     transid serial primary key,
     amount numeric,
    receiver integer references account(accountid) on update cascade on delete restrict,
    donor integer references account(accountid) on update cascade on delete restrict,
    description text,
    ts timestamp default now()
);


CREATE VIEW customeraccountallowedstateevent AS
SELECT c.customerid,c.cstate,a.accountid,a.balance,a.astate , csm.event as cevent, asm.event as aevent,
    csm.endstate as cendstate, asm.endstate as aendstate
   FROM customer c
   JOIN account  a using(customerid)
   LEFT JOIN customerstatemachine csm on c.cstate=csm.startstate
   LEFT JOIN accountstatemachine asm on a.astate=asm.startstate;
COMMENT ON VIEW customeraccountallowedstateevent is 'shows the allowed event combinations for account and customer';

CREATE VIEW customerallowedstateevent as
 SELECT c.customerid,c.cstate, csm.event as cevent,
    csm.endstate as cendstate
   FROM customer c
   JOIN customerstatemachine csm on c.cstate=csm.startstate;

COMMENT ON VIEW customerallowedstateevent IS 'shows the allowed event combinations for customer';

CREATE VIEW customerjoinaccount as select * from customer join account using(customerid);

CREATE VIEW accountevent as select a.accountid,a.balance,a.maxdebit,a.customerid,a.astate,null::bankevent as event from account a where false;

DROP VIEW if exists mytransactions;
CREATE VIEW mytransactions as 
select t1.donor as accountid, t1.receiver as otherparty,t1.transid, null as credit,t1.amount as debit,
t1.description, t1.ts as datetime, a1.balance , c1.name as otherpartyname
from transactions t1 
   join account a1 on (t1.receiver=a1.accountid)
   join customer c1 on(a1.customerid=c1.customerid)
union
select t2.receiver as accountid, t2.donor as otherparty,t2.transid, t2.amount as credit, null as debit,
t2.description, t2.ts as datetime, a2.balance  ,c2.name as otherpartyname
from transactions t2 
   join account a2 on (t2.donor=a2.accountid) 
   join customer c2 on(a2.customerid=c2.customerid)
;


grant select,references on account,customer,transactions,mytransactions to teller;
commit;


