/**
 * Execute the transfer money method, taking the parameters from jsonb object.
 * The jsonb object should contain the following fields:
 * froma: the account that supplies the amount of money
  
 */
CREATE OR REPLACE FUNCTION transferjsonb( job jsonb) RETURNS jsonb
LANGUAGE plpgsql
AS $transferjsonb$
DECLARE
  toa integer;
  froma integer;
  amount numeric;
  description text;
  rs mytransactions;
BEGIN
-- can test for all values with ?& operator
   IF NOT job ?& ARRAY['toa','froma','amount', 'description'] THEN
      RAISE EXCEPTION 'parameter missing ';
   END IF;  

   toa := (job->>'toa')::integer;
   froma := (job->>'froma')::integer;
   amount:= (job->>'amount')::numeric;
   description := (job->>'description')::text;
    SELECT * FROM transferv(froma,toa,amount,description) INTO rs;
    RETURN tojsonb(rs); 

END $transferjsonb$
