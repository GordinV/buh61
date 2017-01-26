-- Function: sp_recalc_rekljaak(integer)
/*
select (summa * ifnull(dokvaluuta1.kuurs,1))  from toiming left outer join dokvaluuta1 on (toiming.id = dokvaluuta1.dokid and dokliik = 15)
	where lubaId = 1881 
	and staatus > 0;

select 	sp_recalc_rekljaak(luba.id) from luba where year(algkpv) = 2011 

select * from dokvaluuta1 where dokid = 1881 and dokliik = 23
select * from dokvaluuta1 where dokliik = 15 and dokid in (
select id from toiming where lubaid = 1881)

select sp_insert_valuuta_andmed()

*/
-- DROP FUNCTION sp_recalc_rekljaak(integer);

CREATE OR REPLACE FUNCTION sp_insert_valuuta_andmed()
  RETURNS integer AS
$BODY$
declare
	v_toiming record;
	 lnResult integer;
begin
	 lnResult = 0;
	for v_toiming in 
		select * from toiming where kpv >= date(2011,01,01) and id not in (select dokid from dokvaluuta1 where dokliik = 15)
	loop
		if (select count(id) from dokvaluuta1 where dokliik = 15 and dokid = v_toiming.id) = 0 then
			raise notice ' insert id %',v_toiming.id;
			insert into dokvaluuta1 (dokid, dokliik, valuuta, kuurs,  muud) values 
				(v_toiming.id, 15, 'EUR',15.6466, 'Parandus');
			
			lnResult =  lnResult + 1;	
		end if;
	end loop;

return  lnResult;
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
