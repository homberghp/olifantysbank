/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
/**
 * Author:  hom
 * Created: Apr 23, 2016
 */
begin work;
with dacc as ( select accountid,balance,maxdebit,customerid,astate,'withdraw'::bankevent as event 
    from account  where accountid=4 for update
)
,racc as ( select accountid,balance,maxdebit,customerid,astate,'deposit'::bankevent as event 
    from account  where accountid=5 for update
)
select dcust.customerid as dcustid,
    dcust.cstate as dstate,
    dacc.accountid as daccid,
    dacc.balance as daccbal,
    dacc.astate as daccstate , 
    csm.event as cevent, 
    asm.event as aevent,
    csm.endstate as cendstate, 
    asm.endstate as aendstate 
  from customer dcust 
  join dacc using(customerid)
  join customer rcust 
  join racc using(customerid) 
  left join accountstatemachine dasm on dacc.astate=dasm.startstate and dacc.event=dasm.event
  left join customerstatemachine dcsm on dcust.cstate=dcsm.startstate and dacc.event=dcsm.event
  left join accountstatemachine rasm on racc.astate=rasm.startstate and racc.event=rasm.event
  left join customerstatemachine rcsm on rcust.cstate=rcsm.startstate and racc.event=dcsm.event
;

rollback;
--commit;