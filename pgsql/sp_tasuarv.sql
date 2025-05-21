-- Function: sp_tasuarv(integer, integer, integer, date, numeric, integer, integer)

-- DROP FUNCTION sp_tasuarv(integer, integer, integer, date, numeric, integer, integer);

CREATE OR REPLACE FUNCTION sp_tasuarv(integer, integer, integer, date, numeric, integer, integer)
  RETURNS numeric AS
$BODY$declare 
	tnDokId alias for 	$1;
	tnArvId alias for 	$2; 
	tnRekvId alias for 	$3; 
	tdkpv	 alias for 	$4; 
	tnSumma  alias for 	$5; 
	tnDokTyyp alias for 	$6; 
	tnNomId	  alias for 	$7;
	lnArvSumma numeric (12,4);
	lnTasuSumma numeric (12,4);
	lnJaak numeric (12,4);
	lnId int;
	lcKonto varchar(20);
	qryArv record;
	lnKuurs numeric (14,4);
	lcValuuta varchar(20);
	lcDok varchar(20);

begin
	lnArvSumma := 0;
	lnTasuSumma := 0;
	lnJaak := 0;
-- KUSTUTA VANA TASU INF
	delete FROM Arvtasu WHERE Arvtasu.sorderid = tnDokId and arvId = tnArvId ;
-- uus kiri		
	select dokprop.konto, arv.liik, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs, ifnull(dokvaluuta1.valuuta,'EEK')::varchar as valuuta into qryArv 
		from dokprop inner join arv on arv.doklausid = dokprop.id 
		left outer join dokvaluuta1 on (dokvaluuta1.dokid = arv.id and dokvaluuta1.dokliik = 3)
		where arv.id = tnArvId;

	qryArv.Konto := ifnull(qryArv.Konto,space(20));

	if tnDokTyyp = 2 then
		-- kassa order
		select sum(summa*ifnull(dokvaluuta1.kuurs,1)) into lnTasuSumma 
			from korder2 left outer join dokvaluuta1 on (korder2.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 11)
			where korder2.parentid = tnDokId;

		select dokvaluuta1.kuurs, dokvaluuta1.valuuta into lnKuurs, lcValuuta
			from dokvaluuta1 where dokid = tnDokId and dokliik = 10;

		select number into lcDok from korder1 where id 	= tnDokId;
			
	else

	
		if tnDokTyyp = 1 then
			select sum(summa*ifnull(dokvaluuta1.kuurs,1)) into lnTasuSumma 
				from mk1 left outer join dokvaluuta1 on (dokvaluuta1.dokid = mk1.id and dokvaluuta1.dokliik = 4) 
				where mk1.parentid = tnDokId;

			select dokvaluuta1.kuurs, dokvaluuta1.valuuta into lnKuurs, lcValuuta
				from dokvaluuta1 
				where dokid in (select id from mk1 where parentid = tnDokId order by id desc limit 1) 
				and dokliik = 4;

			select number into lcDok from mk where id 	= tnDokId;

		else
		
			if qryArv.liik = 0 then
				select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnTasuSumma 
				from journal1 left outer join dokvaluuta1 on (dokvaluuta1.dokid = journal1.id and dokvaluuta1.dokliik = 1)
				where journal1.parentid = tnDokId and kreedit = qryArv.konto;
			else
				select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnTasuSumma 
				from journal1 left outer join dokvaluuta1 on (dokvaluuta1.dokid = journal1.id and dokvaluuta1.dokliik = 1) 
				where journal1.parentid = tnDokId and alltrim(deebet) = alltrim(qryArv.konto);
			end if;

			select dokvaluuta1.kuurs, dokvaluuta1.valuuta into lnKuurs, lcValuuta
				from dokvaluuta1 
				where dokid in (select id from journal1 where parentid = tnDokId order by id desc limit 1)    
				and dokliik = 1;

			select str(number)::varchar into lcDok from journalid where journalid 	= tnDokId;

			
		end if;
		-- kreedit arve
		if ifnull(lnTasuSumma,0) = 0 then
			--kontrollime kas on kreedit arve
			select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnArvSumma 
				from arv1 left outer join dokvaluuta1 on (dokvaluuta1.dokid = arv1.id and dokvaluuta1.dokliik = 2) 
				where arv1.parentid = tnArvId;
			if ifnull(lnArvSumma,0) < 0 then

				-- kreedit arve
				if qryArv.liik = 0 then
					select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnTasuSumma 
						from journal1 left outer join dokvaluuta1 on (dokvaluuta1.dokid = journal1.id and dokvaluuta1.dokliik = 1)
						where parentid = tnDokId and deebet = qryArv.konto;
				else
					select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnTasuSumma 
						from journal1 left outer join dokvaluuta1 on (dokvaluuta1.dokid = journal1.id and dokvaluuta1.dokliik = 1)
						where parentid = tnDokId and kreedit = qryArv.konto;
				end if;

				select dokvaluuta1.kuurs, dokvaluuta1.valuuta into lnKuurs, lcValuuta
					from dokvaluuta1 
					where dokid in (select id from journal1 where parentid = tnDokId order by id desc limit 1)    
					and dokliik = 1;

				select str(number)::varchar into lcDok from journalid where journalid 	= tnDokId;
				
			end if;			
		end if;

	end if;

	lcValuuta = ifnull(lcValuuta,'EEK');
	lnKuurs = ifnull(lnKuurs,1);

	lnTasuSumma := ifnull(lnTasuSumma,0) / qryArv.Kuurs;
	lcDok = ifnull(lcDok,'');


	if tnDokId is not null and not empty(tnDokId) and tdKpv is not null and (year() - year(tdKpv) < 10) then 	
		insert into arvtasu (rekvId, arvId, kpv, summa, sorderId, pankKassa, nomId, dok) values
		(tnRekvId, tnArvId, tdKpv, lnTasuSumma, tnDokId, tnDokTyyp, tnNomId, lcDok);
		
		lnId:= cast(CURRVAL('public.arvtasu_id_seq') as int4);

	--valuuta

	insert into dokvaluuta1 (dokliik,dokid, valuuta, kuurs) 
		values (21, lnId,qryArv.Valuuta, qryArv.Kuurs);

	end if;
	
	return sp_updateArvJaak(tnArvId, tdKpv);


end; 

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_tasuarv(integer, integer, integer, date, numeric, integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_tasuarv(integer, integer, integer, date, numeric, integer, integer) TO vlad;
GRANT EXECUTE ON FUNCTION sp_tasuarv(integer, integer, integer, date, numeric, integer, integer) TO public;
GRANT EXECUTE ON FUNCTION sp_tasuarv(integer, integer, integer, date, numeric, integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_tasuarv(integer, integer, integer, date, numeric, integer, integer) TO taabel;
GRANT EXECUTE ON FUNCTION sp_tasuarv(integer, integer, integer, date, numeric, integer, integer) TO dbpeakasutaja;
