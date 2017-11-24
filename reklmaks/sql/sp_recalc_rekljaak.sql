-- Function: sp_recalc_rekljaak(integer)

-- DROP FUNCTION sp_recalc_rekljaak(integer);

CREATE OR REPLACE FUNCTION sp_recalc_rekljaak(integer)
  RETURNS integer AS
$BODY$
declare
	tnid alias for $1;
	lnSumma numeric;
	lnAlgsaldo numeric;
	lnKr1 numeric;
	lnKr2 numeric;
	lnDb numeric;
	lnIntress numeric;
	lnjaak numeric;
	lnVolg numeric;
	lnResult int; 
	v_dekl record;
	v_intress record;
	v_luba record;
begin
lnResult := 0;

-- algsaldo

select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnAlgsaldo from toiming left outer join dokvaluuta1 on (toiming.id = dokvaluuta1.dokid and dokliik = 24)
	where lubaId = tnId 
	and tyyp = 'ALGSALDO'  
	and staatus > 0;

lnAlgsaldo= ifnull(lnAlgsaldo,0);

select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnKr1 from toiming left outer join dokvaluuta1 on (toiming.id = dokvaluuta1.dokid and dokliik = 24)
	where lubaId = tnId 
	and tyyp = 'DEKL' 
	and not empty (saadetud) 
	and staatus > 0
	and tahtaeg >= date();
lnKr1 = ifnull(lnKr1,0);

select sum(summa * ifnull(dokvaluuta1.kuurs,1) ) into lnKr2 from toiming left outer join dokvaluuta1 on (toiming.id = dokvaluuta1.dokid and dokliik = 24)
	where lubaId = tnId 
	and (tyyp = 'DEKL' and not empty (saadetud)) OR tyyp IN ('INTRESS','PARANDUS')
	and staatus > 0 
	and tahtaeg <= date();
--and staatus = 1

lnKr2 = ifnull(lnKr2,0);



lnSumma = 0;
/*
for v_dekl in
	select id, kpv, summa, tahtaeg from toiming where tyyp = 'DEKL' and staatus = 2 and lubaId = tnId
loop
	-- tasud summa
	select sum(summa) into lnSumma from dekltasu where deklId = v_dekl.id;
	if v_dekl.tahtaeg >= date() then
		lnKr1 = lnKr1 + v_dekl.summa - ifnull(lnSumma,0);
	else
		lnKr2 = lnKr2 + v_dekl.summa - ifnull(lnSumma,0);
	end if;
	raise notice 'OSALINE TASUD lnKr1:%',lnKr1;
	raise notice 'OSALINE TASUD DEKL:%',lnKr2;

end loop;
*/
select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnIntress from toiming left outer join dokvaluuta1 on (toiming.id = dokvaluuta1.dokid and dokliik = 24)
	where lubaId = tnId and tyyp = 'INTRESS' and staatus > 0;
lnIntress = ifnull(lnIntress,0);


lnSumma = 0;

-- tasud summa
select sum(summa * ifnull(dokvaluuta1.kuurs,1) ) into lnSumma 
	from dekltasu left outer join dokvaluuta1 on (dekltasu.id = dokvaluuta1.dokid and dokliik = 7) 
	where deklId  in (
		select toiming.id from toiming where tyyp = 'INTRESS' and staatus > 0 and lubaId = tnId
		);

lnIntress = lnIntress - ifnull(lnSumma,0);
raise notice 'Intress:%',lnIntress;

-- avans

select sum(toiming.summa * ifnull(dokvaluuta1.kuurs,1)) into lnDb from toiming  left outer join dokvaluuta1 on (toiming.id = dokvaluuta1.dokid and dokliik = 24)  
	where toiming.tyyp = 'TASU' and toiming.lubaId = tnId;

lnDb = ifnull(lnDb,0);
raise notice 'lnDb:%',lnDb;


lnSumma = (lnAlgsaldo + lnKr1 + lnKr2 ) - lnDb;
-- volg = lnKr2 - lnDb
lnVolg = 0;

lnVolg = (lnAlgsaldo  + lnKr2 ) - lnDb;

if lnVolg < 0 then
	lnVolg = 0;
end if;
select jaak, volg, intress, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs, staatus into v_luba from luba 
	left outer join dokvaluuta1 on (luba.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 23)
	where luba.id = tnId;

lnSumma = round(lnSumma / v_luba.kuurs,2);
lnVolg = round(lnVolg / v_luba.kuurs,2);
lnIntress = round(lnIntress / v_luba.kuurs,2);

raise notice 'lnSumma %, lnVolg %, lnIntress %', lnSumma, lnVolg, lnIntress;

if ifnull(v_luba.Jaak,0) <> lnSumma or ifnull(v_luba.volg,0)  <> lnVolg or ifnull(v_luba.intress,0) <> lnIntress  then
	raise notice 'Updating:';
	update luba set jaak = lnSumma,
		volg = lnVolg,
		intress = lnIntress
		where id = tnId;
	lnResult = 1;
end if;

if v_luba.staatus = 0 then
	raise notice 'Luba anuleeritud, nullime saldo:';
	update luba set jaak = 0,
		volg = 0,
		intress = 0
		where id = tnId;
	lnResult = 1;	
end if;


return  lnResult;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION sp_recalc_rekljaak(integer)
  OWNER TO vlad;
