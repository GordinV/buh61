-- Function: sp_updatearvjaak(integer, date)

-- DROP FUNCTION sp_updatearvjaak(integer, date);

CREATE OR REPLACE FUNCTION sp_updatearvjaak(integer, date)
  RETURNS numeric AS
$BODY$
declare tnArvId alias for 	$1; 	
	tdKpv alias for 	$2; 	
	lnArvSumma numeric (12,4);
	lnTasuSumma numeric (12,4);
	lnJaak numeric (12,4);
	ldKpv date;
	v_arvtasu record;
	lnJournalId int;

	lnKuurs numeric(12,4);
begin
/*	lnArvSumma := 0;
	lnTasuSumma := 0;
	lnJaak := 0;
*/
-- kontrollin kas on vigased kirjad
select sorderid into lnJournalid from arvtasu where arvid = tnArvId and pankkassa = 3 order by id desc limit 1;

if ifnull(lnJournalId,0) > 0 then

for v_arvtasu in
	select * from arvtasu where arvid = tnArvId and pankkassa <> 3
	loop
		if v_arvtasu.pankkassa = 1 and (select count(mk1.id) from mk1 inner join mk on mk.id = mk1.parentid 
				where mk1.journalid = lnJournalid and mk.id = v_arvtasu.sorderid) > 0 then
			raise notice 'leitud vigane kiri, kustutan..%',v_arvtasu.id;
			delete from arvtasu where id = v_arvtasu.id;
		end if;
		if v_arvtasu.pankkassa = 2 and (select count(id) from korder1 where journalid = lnJournalid and korder1.id = v_arvtasu.sorderid) > 0 then
			raise notice 'leitud vigane kiri, kustutan..%',v_arvtasu.id;
			delete from arvtasu where id = v_arvtasu.id;
		end if;
	end loop;
end if;

	SELECT (arv.summa * ifnull(dokvaluuta1.kuurs,1))::numeric, ifnull(dokvaluuta1.kuurs,1)  into lnArvSumma , lnKuurs
		FROM arv left outer join dokvaluuta1 on (dokvaluuta1.dokid = arv.id and dokvaluuta1.dokliik = 3) 
		WHERE arv.id = tnArvId ;

	SELECT sum(arvtasu.summa * ifnull(dokvaluuta1.kuurs,1)), max(arvtasu.kpv) into lnTasuSumma, ldKpv 
		FROM arvtasu left outer join dokvaluuta1 on (arvtasu.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 21) 
		WHERE arvtasu.arvId = tnArvId;
		
	lnTasuSumma := ifnull(lnTasuSumma,0);	
	ldKpv := ifnull(ldKpv,tdKpv);	
	lnArvsumma := ifnull(lnArvSumma,0);


	
	if lnArvSumma < 0 then
		-- kreeditarve
		if lnTasuSumma < 0 then
			lnJaak := -1 * ((-1 * lnArvSumma) - (-1 * lnTasuSumma));			
		else
			lnJaak := lnArvSumma + lnTasuSumma;
		end if;
	else
		lnJaak := lnArvSumma - lnTasuSumma;
	end if;
	if lnTasuSumma = 0 then
		ldKpv := null;
	end if;

	lnJaak = lnJaak / lnKuurs; 	

	UPDATE arv SET tasud = ldkpv,
		jaak = lnJaak  WHERE id = tnArvId;		

	return lnJaak;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_updatearvjaak(integer, date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_updatearvjaak(integer, date) TO vlad;
GRANT EXECUTE ON FUNCTION sp_updatearvjaak(integer, date) TO public;
GRANT EXECUTE ON FUNCTION sp_updatearvjaak(integer, date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_updatearvjaak(integer, date) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION sp_updatearvjaak(integer, date) TO taabel;
