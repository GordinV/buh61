-- Function: fnc_avansijaak(integer)
/*
select * from avans1 where rekvid = 3 and number = '3'

select fnc_avansijaak(15751)
*/
-- DROP FUNCTION fnc_avansijaak(integer);

CREATE OR REPLACE FUNCTION fnc_avansijaak(integer)
  RETURNS numeric AS
$BODY$


declare 
	tnId	ALIAS FOR $1;
	lnTasuSumma numeric(14,2);
	lnSumma numeric(14,2);
	lnJaak numeric(14,2);
	v_avans record;
	lnDokValuuta numeric(14,4);
	lnTasuValuuta numeric(14,4);
	lnId int;
	ldKpv date;
BEGIN

select id into lnId from avans2 where parentid = tnId order by id limit 1;
--raise notice 'LnId %',lnId;

select dokvaluuta1.kuurs into lnDokValuuta from dokvaluuta1 where dokid = lnId and dokliik = 5;
lnDokValuuta = ifnull(lnDokValuuta,1);
--raise notice 'lnDokValuuta %',lnDokValuuta;

-- summa, korkonto
select ifnull(dokprop.konto,space(20)) as konto,avans1.asutusId, avans1.rekvId, avans1.number, avans1.kpv into v_avans
	from avans1 left outer join dokprop on dokprop.id = avans1.dokpropId
	where avans1.id = tnId;

-- tasumine via pдevaraamat

delete from avans3 where parentid = tnId and liik = 1;


insert into avans3 (parentid,dokid,liik, muud, summa )
select tnId, journal.id,1,'JOURNAL',(journal1.summa*ifnull(dokvaluuta1.kuurs,1))	
	from journal1 inner join journal on journal.id = journal1.parentId 
	left outer join dokvaluuta1 on (dokvaluuta1.dokid = journal1.id and dokvaluuta1.dokliik = 1)
	where journal.rekvid = v_avans.rekvid
	and journal.asutusId = v_avans.AsutusId
	and ltrim(rtrim(journal.dok)) = v_avans.number
	and year(journal.kpv) = year(v_avans.Kpv)
	and ltrim(rtrim(journal1.deebet)) = ltrim(rtrim(v_avans.konto));



select sum(summa) into lnTasuSumma from avans3 where parentid = tnId;
raise notice 'lnTasuSumma %',lnTasuSumma;


select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma from avans2  left outer join dokvaluuta1 on (dokvaluuta1.dokid = avans2.id and dokvaluuta1.dokliik = 5) 
where avans2.parentid = tnId;
raise notice 'lnSumma %',lnSumma;

lnJaak =round((ifnull(lnSumma,0) - ifnull(lnTasuSumma,0))/lnDokValuuta,2);
update avans1 set jaak = lnJaak where id = tnId;

RETURN lnJaak;


end;




$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION fnc_avansijaak(integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION fnc_avansijaak(integer) TO public;
GRANT EXECUTE ON FUNCTION fnc_avansijaak(integer) TO vlad;
GRANT EXECUTE ON FUNCTION fnc_avansijaak(integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION fnc_avansijaak(integer) TO dbpeakasutaja;
