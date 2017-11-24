-- Function: sp_tasuarv(integer, integer, integer, date, numeric, integer, integer)

/*
select sp_TASUARV(34343,100143,3, DATE(2010, 6,29),100.00,2,236)
*/

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

begin
	lnArvSumma := 0;
	lnTasuSumma := 0;
	lnJaak := 0;
-- KUSTUTA VANA TASU INF
	delete FROM Arvtasu WHERE Arvtasu.sorderid = tnDokId and arvId = tnArvId ;
-- uus kiri		
	select dokprop.konto, arv.liik into qryArv from dokprop inner join arv on arv.doklausid = dokprop.id where arv.id = tnArvId;

	qryArv.Konto := ifnull(qryArv.Konto,space(20));
	if tnDokTyyp = 2 then
		-- kassa order
		select sum(summa*ifnull(dokvaluuta1.kuurs,1)) into lnTasuSumma 
			from korder2 left outer join dokvaluuta1 on (korder2.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 11)
			where korder2.parentid = tnDokId;

		select dokvaluuta1.kuurs, dokvaluuta1.valuuta into lnKuurs, lcValuuta
			from dokvaluuta1 where dokid = tnDokId and dokliik = 10;
	else

	
		if tnDokTyyp = 1 then
			select sum(summa*ifnull(dokvaluuta1.kuurs,1)) into lnTasuSumma 
				from mk1 left outer join dokvaluuta1 on (dokvaluuta1.dokid = mk1.id and dokvaluuta1.dokliik = 4) 
				where mk1.parentid = tnDokId;

			select dokvaluuta1.kuurs, dokvaluuta1.valuuta into lnKuurs, lcValuuta
				from dokvaluuta1 
				where dokid in (select id from mk1 where parentid = tnDokId order by id desc limit 1) 
				and dokliik = 4;

		else
			if qryArv.liik = 0 then
				select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnTasuSumma 
				from journal1 left outer join dokvaluuta1 on (dokvaluuta1.dokid = journal1.id and dokvaluuta1.dokliik = 1)
				where journal1.parentid = tnDokId and kreedit = qryArv.konto
				and journal1.parentid not in (select sorderid from arvtasu where arvid = tnArvId);
			else
				select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnTasuSumma 
				from journal1 left outer join dokvaluuta1 on (dokvaluuta1.dokid = journal1.id and dokvaluuta1.dokliik = 1) 
				where journal1.parentid = tnDokId and deebet = qryArv.konto 				
				and journal1.parentid not in (select sorderid from arvtasu where arvid = tnArvId);

			end if;

			select dokvaluuta1.kuurs, dokvaluuta1.valuuta into lnKuurs, lcValuuta
				from dokvaluuta1 
				where dokid in (select id from journal1 where parentid = tnDokId order by id desc limit 1)    
				and dokliik = 1;
			
		end if;
		-- kreedit arve
		if ifnull(lnTasuSumma,0) = 0 then
			raise notice 'kreedit arve';
			--kontrollime kas on kreedit arve
			select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnArvSumma 
				from arv1 left outer join dokvaluuta1 on (dokvaluuta1.dokid = arv1.id and dokvaluuta1.dokliik = 2) 
				where arv1.parentid = tnArvId;
			if ifnull(lnArvSumma,0) < 0 then
				raise notice 'lnArvSumma: %',lnArvSumma;
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

				
			end if;			
		end if;

	end if;
	lnTasuSumma := ifnull(lnTasuSumma,0);
	raise notice 'arvtasu SUMMA: %',lnTasuSumma;

	lcValuuta = ifnull(lcValuuta,'EEK');
	lnKuurs = ifnull(lnKuurs,1);

	insert into arvtasu (rekvId, arvId, kpv, summa, sorderId, pankKassa, nomId) values
	(tnRekvId, tnArvId, tdKpv, lnTasuSumma, tnDokId, tnDokTyyp, tnNomId);
	lnId:= cast(CURRVAL('public.arvtasu_id_seq') as int4);

	--valuuta

	insert into dokvaluuta1 (dokliik,dokid, valuuta, kuurs) 
		values (21, lnId,lcValuuta, lnKuurs);

	raise notice 'arvtasu id: %',lnId;
	return sp_updateArvJaak(tnArvId, tdKpv);


end; 

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_tasuarv(integer, integer, integer, date, numeric, integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_tasuarv(integer, integer, integer, date, numeric, integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_tasuarv(integer, integer, integer, date, numeric, integer, integer) TO dbpeakasutaja;

-- Function: sp_tasuarv(integer, integer, integer, date, numeric, integer, integer)

/*
select sp_TASUARV(34343,100143,3, DATE(2010, 6,29),100.00,2,236)
*/

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

begin
	lnArvSumma := 0;
	lnTasuSumma := 0;
	lnJaak := 0;
-- KUSTUTA VANA TASU INF
	delete FROM Arvtasu WHERE Arvtasu.sorderid = tnDokId and arvId = tnArvId ;
-- uus kiri		
	select dokprop.konto, arv.liik into qryArv from dokprop inner join arv on arv.doklausid = dokprop.id where arv.id = tnArvId;

	qryArv.Konto := ifnull(qryArv.Konto,space(20));
	if tnDokTyyp = 2 then
		-- kassa order
		select sum(summa*ifnull(dokvaluuta1.kuurs,1)) into lnTasuSumma 
			from korder2 left outer join dokvaluuta1 on (korder2.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 11)
			where korder2.parentid = tnDokId;

		select dokvaluuta1.kuurs, dokvaluuta1.valuuta into lnKuurs, lcValuuta
			from dokvaluuta1 where dokid = tnDokId and dokliik = 10;
	else

	
		if tnDokTyyp = 1 then
			select sum(summa*ifnull(dokvaluuta1.kuurs,1)) into lnTasuSumma 
				from mk1 left outer join dokvaluuta1 on (dokvaluuta1.dokid = mk1.id and dokvaluuta1.dokliik = 4) 
				where mk1.parentid = tnDokId;

			select dokvaluuta1.kuurs, dokvaluuta1.valuuta into lnKuurs, lcValuuta
				from dokvaluuta1 
				where dokid in (select id from mk1 where parentid = tnDokId order by id desc limit 1) 
				and dokliik = 4;

		else
			if qryArv.liik = 0 then
				select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnTasuSumma 
				from journal1 left outer join dokvaluuta1 on (dokvaluuta1.dokid = journal1.id and dokvaluuta1.dokliik = 1)
				where journal1.parentid = tnDokId and kreedit = qryArv.konto
				and journal1.parentid not in (select sorderid from arvtasu where arvid = tnArvId);
			else
				select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnTasuSumma 
				from journal1 left outer join dokvaluuta1 on (dokvaluuta1.dokid = journal1.id and dokvaluuta1.dokliik = 1) 
				where journal1.parentid = tnDokId and deebet = qryArv.konto 				
				and journal1.parentid not in (select sorderid from arvtasu where arvid = tnArvId);

			end if;

			select dokvaluuta1.kuurs, dokvaluuta1.valuuta into lnKuurs, lcValuuta
				from dokvaluuta1 
				where dokid in (select id from journal1 where parentid = tnDokId order by id desc limit 1)    
				and dokliik = 1;
			
		end if;
		-- kreedit arve
		if ifnull(lnTasuSumma,0) = 0 then
			raise notice 'kreedit arve';
			--kontrollime kas on kreedit arve
			select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnArvSumma 
				from arv1 left outer join dokvaluuta1 on (dokvaluuta1.dokid = arv1.id and dokvaluuta1.dokliik = 2) 
				where arv1.parentid = tnArvId;
			if ifnull(lnArvSumma,0) < 0 then
				raise notice 'lnArvSumma: %',lnArvSumma;
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

				
			end if;			
		end if;

	end if;
	lnTasuSumma := ifnull(lnTasuSumma,0);
	raise notice 'arvtasu SUMMA: %',lnTasuSumma;

	lcValuuta = ifnull(lcValuuta,'EEK');
	lnKuurs = ifnull(lnKuurs,1);

	insert into arvtasu (rekvId, arvId, kpv, summa, sorderId, pankKassa, nomId) values
	(tnRekvId, tnArvId, tdKpv, lnTasuSumma, tnDokId, tnDokTyyp, tnNomId);
	lnId:= cast(CURRVAL('public.arvtasu_id_seq') as int4);

	--valuuta

	insert into dokvaluuta1 (dokliik,dokid, valuuta, kuurs) 
		values (21, lnId,lcValuuta, lnKuurs);

	raise notice 'arvtasu id: %',lnId;
	return sp_updateArvJaak(tnArvId, tdKpv);


end; 

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_tasuarv(integer, integer, integer, date, numeric, integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_tasuarv(integer, integer, integer, date, numeric, integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_tasuarv(integer, integer, integer, date, numeric, integer, integer) TO dbpeakasutaja;


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

	SELECT (arv.summa * ifnull(dokvaluuta1.kuurs,1))::numeric  into lnArvSumma 
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

	UPDATE arv SET tasud = ldkpv,
		jaak = lnJaak WHERE id = tnArvId;		

	return lnJaak;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_updatearvjaak(integer, date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_updatearvjaak(integer, date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_updatearvjaak(integer, date) TO dbpeakasutaja;



-- Function: sp_salvesta_arv1(integer, integer, integer, numeric, numeric, integer, numeric, integer, numeric, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, integer, character varying)

-- DROP FUNCTION sp_salvesta_arv1(integer, integer, integer, numeric, numeric, integer, numeric, integer, numeric, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, integer, character varying);

/*

select sp_salvesta_arv1(501::int,466::int,48::int,1.00::numeric,25.00::numeric,0::int,0.00::numeric,0::int,25.00::numeric,''::text,''::varchar,''::varchar,''::varchar,''::varchar,''::varchar,'3512'::varchar,'800599'::varchar,25.00::numeric,0::int,''::varchar,'EEK'::varchar,1.00::numeric,'EEK'::varchar)

select * from dokvaluuta1 order by id desc limit 5

SELECT Arv.id, Arv.number, Arv.kpv as kpv, Arv.tahtaeg, Arv.summa, Arv.tasud,  Arv.tasudok,  ARV.USERID, Asutus.nimetus AS asutus,  arv.asutusid, 
Arv.journalid, arv.liik, arv.operId, arv.jaak, arv.objektId, 
ARV.DOKLAUSID, ifnull(dokprop.konto,space(20)) as konto, arv.muud,
ifnull(dokvaluuta1.valuuta,'EEK')::VARCHAR as valuuta, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs 
FROM  Arv INNER join  asutus Asutus on asutus.id = ARV.asutusId inner join userid on arv.userid = userid.id 
left outer join dokprop on dokprop.id = arv.doklausId left outer join dokvaluuta1 on (arv.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 2)
order by arv.id desc limit 10


SELECT Arv.id, Arv.number, Arv.kpv as kpv, Arv.tahtaeg, Arv.summa, Arv.tasud,  Arv.tasudok,  ARV.USERID, Asutus.nimetus AS asutus,  arv.asutusid, Arv.journalid, 
arv.liik, arv.operId, arv.jaak, arv.objektId, ARV.DOKLAUSID, ifnull(dokprop.konto,space(20)) as konto, arv.muud,ifnull(dokvaluuta1.valuuta,'EEK')::VARCHAR as valuuta, 
ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs 
FROM  Arv INNER join  asutus Asutus on asutus.id = ARV.asutusId inner join userid on arv.userid = userid.id left outer join dokprop on dokprop.id = arv.doklausId 
left outer join dokvaluuta1 on (arv.id = dokvaluuta1.dokid and dokliik = 3) 
order by arv.id desc limit 10

*/
CREATE OR REPLACE FUNCTION sp_salvesta_arv1(integer, integer, integer, numeric, numeric, integer, numeric, integer, numeric, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, integer, character varying, character varying,numeric,character varying)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnparentid alias for $2;
	tnnomid alias for $3;
	tnkogus alias for $4;
	tnhind alias for $5;
	tnsoodus alias for $6;
	tnkbm alias for $7;
	tnmaha alias for $8;
	tnsumma alias for $9;
	ttmuud alias for $10;
	tckood1 alias for $11;
	tckood2 alias for $12;
	tckood3 alias for $13;
	tckood4 alias for $14;
	tckood5 alias for $15;
	tckonto alias for $16;
	tctp alias for $17;
	tnkbmta alias for $18;
	tnisikid alias for $19;
	tctunnus alias for $20;
	tcValuuta alias for $21;
	tnKuurs alias for $22;
	tcProj alias for $23;
	lnarv1Id int;
	lnId int; 
	lrCurRec record;
	v_dokvaluuta record;
begin

if tnId = 0 then
	-- uus kiri
	insert into arv1 (parentid,nomid,kogus,hind,soodus,kbm,maha,summa,muud,kood1,kood2,kood3,kood4,kood5,konto,tp,kbmta,isikid,tunnus,proj) 
		values (tnparentid,tnnomid,tnkogus,tnhind,tnsoodus,tnkbm,tnmaha,tnsumma,ttmuud,tckood1,tckood2,tckood3,tckood4,tckood5,tckonto,tctp,tnkbmta,tnisikid,tctunnus,tcProj);


	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
	--	raise notice 'lnId %',lnId;
		lnarv1Id:= cast(CURRVAL('public.arv1_id_seq') as int4);
	--	raise notice 'lnaastaId %',lnaastaId;
	else
		lnarv1Id = 0;
	end if;

	if lnarv1Id = 0 then
		raise exception ':%','Ei saa lisada kiri';
	end if;

	-- valuuta

	insert into dokvaluuta1 (dokid, dokliik, valuuta, kuurs) 
		values (lnarv1Id,2,tcValuuta, tnKuurs);


else
	-- muuda 
	select * into lrCurRec from arv1 where id = tnId;
	if lrCurRec.parentid <> tnparentid or lrCurRec.nomid <> tnnomid or lrCurRec.kogus <> tnkogus or lrCurRec.hind <> tnhind or lrCurRec.soodus <> tnsoodus 
		or lrCurRec.kbm <> tnkbm or lrCurRec.maha <> tnmaha or lrCurRec.summa <> tnsumma or ifnull(lrCurRec.muud,space(1)) <> ifnull(ttmuud,space(1)) 
		or lrCurRec.kood1 <> tckood1 or lrCurRec.kood2 <> tckood2 or lrCurRec.kood3 <> tckood3 or lrCurRec.kood4 <> tckood4 or lrCurRec.kood5 <> tckood5 
		or lrCurRec.konto <> tckonto or lrCurRec.tp <> tctp or lrCurRec.kbmta <> tnkbmta 
		or lrCurRec.isikid <> tnisikid or lrCurRec.tunnus <> tctunnus or lrCurRec.proj <> tcProj then 
	update arv1 set 
		parentid = tnparentid,
		nomid = tnnomid,
		kogus = tnkogus,
		hind = tnhind,
		soodus = tnsoodus,
		kbm = tnkbm,
		maha = tnmaha,
		summa = tnsumma,
		muud = ttmuud,
		kood1 = tckood1,
		kood2 = tckood2,
		kood3 = tckood3,
		kood4 = tckood4,
		kood5 = tckood5,
		konto = tckonto,
		tp = tctp,
		kbmta = tnkbmta,
		isikid = tnisikid,
		tunnus = tctunnus,
		proj = tcProj
	where id = tnId;
	end if;
	lnarv1Id := tnId;

	-- valuuta
	if (select count(id) from dokvaluuta1 where dokliik = 2 and dokid = lnarv1Id) = 0 then

		insert into dokvaluuta1 (dokliik, dokid, valuuta, kuurs) 
			values (2, lnarv1Id,tcValuuta, tnKuurs);
	else
		select * into v_dokvaluuta from dokvaluuta1 where dokliik = 2 and dokid = lnarv1Id ;

		if tcValuuta <> v_dokvaluuta.valuuta or tnKuurs <> v_dokvaluuta.kuurs then

			update dokvaluuta1 set valuuta = tcValuuta, kuurs = tnKuurs where id = v_dokvaluuta.id;

						
		end if;
	
	end if;
	
end if;

	-- kontrollin valuuta arv taabelis

	if (select count(id) from dokvaluuta1 where dokliik = 3 and dokid = tnParentId) = 0 then
	
		insert into dokvaluuta1 (dokid, dokliik, valuuta, kuurs) 
			values (tnParentId,3,tcValuuta, tnKuurs);
	else
	
			update dokvaluuta1 set valuuta = tcValuuta, kuurs = tnKuurs where dokid = tnParentId and dokliik = 3;

	end if;

	perform sp_updatearvjaak(tnParentId, date());

         return  lnarv1Id;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_arv1(integer, integer, integer, numeric, numeric, integer, numeric, integer, numeric, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, integer, character varying, character varying,numeric,character varying) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_arv1(integer, integer, integer, numeric, numeric, integer, numeric, integer, numeric, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, integer, character varying, character varying,numeric,character varying) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_arv1(integer, integer, integer, numeric, numeric, integer, numeric, integer, numeric, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, integer, character varying, character varying,numeric,character varying) TO dbpeakasutaja;


-- Function: sp_salvesta_pv_kaart(integer, integer, integer, numeric, date, numeric, numeric, integer, character varying, integer, date, text, text, numeric)
/*
select sp_salvesta_pv_kaart(567165::int,17110::int,date(2007,12,30),20.0000::numeric,0.0000::numeric,128817::int,'155405'::varchar,1::int,'tehasenumber 08.pikkus-6.1 m.laius-1.88 m.pardakorgus -0.77 m.paadikere on plastiline'::text,'NARVA NOORTE MEREMEESTE KLUBI'::text,'155405-007-00'::varchar,'Purjepaat JAL-6(plastik)'::varchar,73::int)


select sp_salvesta_pv_kaart(579008::int,31525::int,date(2010, 7, 7),20.0000::numeric,0.0000::numeric,128585::int,'155400'::varchar,1::int,'test kaart'::text,''::text,'test'::varchar,'test kaart 123'::varchar,73::int)
select * from asutus where id = 17110
select * from curPohivara where KOOD = 'test'

select id  from pv_kaart where parentid = 567165;

select * from pv_kaart where parentid = 579008

*/


--DROP FUNCTION sp_salvesta_pv_kaart(integer, integer, integer, numeric, date, numeric, numeric, integer, character varying, integer, date, text, text, numeric);

CREATE OR REPLACE FUNCTION sp_salvesta_pv_kaart(integer, integer, date, numeric, numeric, integer, character varying, integer, text, text,character varying,character varying, integer)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnvastisikid alias for $2;
	tdsoetkpv alias for $3;
	tnkulum alias for $4;
	tnalgkulum alias for $5;
	tngruppid alias for $6;
	tckonto alias for $7;
	tntunnus alias for $8;
	ttselg alias for $9;
	ttrentnik alias for $10;
	tcKood alias for $11;
	tcNimetus alias for $12;
	tnRekvId alias for $13;
	lnpv_kaartId int;
	lnId int; 
	lnParentId int;
	lrCurRec record;
begin

raise notice 'vats %',tnVastisikId;
if tnId = 0 then
	-- uus kiri

	lnParentId = sp_salvesta_library(tnId, tnRekvId, tcKood, tcNimetus, 'POHIVARA', ttSelg, 0, 1, 0, 0, 0);

	if lnParentId = 0 then
		raise notice 'Viga, ei saa salvesta dokument';
		return 0;
	end if;
	
	insert into pv_kaart (parentid,vastisikid,soetkpv,kulum,algkulum,gruppid,konto,tunnus,muud) 
		values (lnparentid,tnvastisikid,tdsoetkpv,tnkulum,tnalgkulum,tngruppid,tckonto,tntunnus,ttRentnik);

	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
		lnpv_kaartId:= cast(CURRVAL('public.pv_kaart_id_seq') as int4);
	else
		lnpv_kaartId = 0;
	end if;

	if lnpv_kaartId = 0 then
		raise exception ':%','Ei saa lisada kiri';
	end if;

else
	-- muuda 

--	select parentid into lnParentId from pv_kaart where id = tnId;
	lnParentId = sp_salvesta_library(tnId, tnRekvId, tcKood, tcNimetus, 'POHIVARA', ttSelg, 0, 0, 0, 0, 0);

	if lnParentId = 0 then
		raise notice 'Viga, ei saa salvesta dokument';
		return 0;
	end if;


	update pv_kaart set 
			vastisikid = tnvastisikid,
			soetkpv = tdsoetkpv,
			kulum = tnkulum,
			algkulum = tnalgkulum,
			gruppid = tngruppid,
			konto = tckonto,
			tunnus = tntunnus,
			muud = ttRentnik
		where parentid = tnId;

	lnpv_kaartId := tnId;
end if;

         return  lnParentId;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_pv_kaart(integer, integer, date, numeric, numeric, integer, character varying, integer, text, text,character varying,character varying, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_pv_kaart(integer, integer, date, numeric, numeric, integer, character varying, integer, text, text,character varying,character varying, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_pv_kaart(integer, integer, date, numeric, numeric, integer, character varying, integer, text, text,character varying,character varying, integer) TO dbpeakasutaja;


-- Function: gen_lausend_mk(integer)

-- DROP FUNCTION gen_lausend_mk(integer);

CREATE OR REPLACE FUNCTION gen_lausend_mk(integer)
  RETURNS integer AS
$BODY$
declare 	tnId alias for $1;	
		lnJournalNumber int4;	
		lcDbKonto varchar(20);	
		lcKrKonto varchar(20);	
		lcDbTp varchar(20);	
		lcKrTp varchar(20);	
		lnAsutusId int4;	
		lnJournalId int4;	
		lnJournal1Id int4;	
		v_mk mk%rowtype;	
		v_mk1 record;	
		v_dokprop dokprop%rowtype;	
		v_aa aa%rowtype;
		lnUserId int;
		lcDok varchar;
begin
	select * into v_mk from mk where id = tnId;	

	If v_mk.doklausid = 0 then		
		Return 0;	
	End if;
	select * into v_dokprop from dokprop where id = v_mk.doklausid;	
	
	If not found Or v_dokprop.registr = 0 then		
		Return 0;	
	End if;	

	select * into v_aa from aa where id = v_mk.aaId;		

	for v_mk1 in select mk1.*, ifnull(dokvaluuta1.valuuta,'EEK')::varchar as valuuta, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs 
		from mk1 left outer join dokvaluuta1 on (dokvaluuta1.dokid = mk1.id and dokvaluuta1.dokliik = 4) 
		where parentid = v_mk.Id
	loop		

		If v_mk1.journalid > 0 then			
			Select number into lnJournalNumber from journalid where journalid = v_mk1.journalId;			
			update mk1 set journalId = 0 where id = v_mk1.id;
			v_mk1.journalId := sp_del_journal(v_mk1.journalid,1);		
		End if;		

		If v_mk.opt = 0 then			
			-- kreedit pank			
			lcDbKonto := v_mk1.konto;			
			lcKrKonto := v_aa.konto;			
			lcKrTp := v_aa.tp;			
			lcDbTp := v_mk1.tp;			
			lnAsutusId := v_mk1.Asutusid;		
		Else			
			lcKrKonto := v_mk1.konto;			
			lcDbKonto := v_aa.konto;			
			lcDbTp := v_aa.tp;			
			lcKrTp := v_mk1.tp;			
			lnAsutusId := v_mk1.Asutusid;		
		End if;

		if v_mk.arvid > 0 then
			select arv.number into lcDok from arv where id = v_mk.arvId;
		else
			lcDok = v_mk.number;
		end if;
		lcDok = ifnull(lcDok,'');
		select id into lnUserId from userid where userid.rekvid = v_mk.rekvid and userid.kasutaja = CURRENT_USER::varchar;

		lnJournalId:= sp_salvesta_journal(0, v_mk.rekvId, lnUserId, v_mk.kpv, v_mk1.AsutusId, 
			ltrim(rtrim(v_dokprop.selg))+space(1)+ltrim(rtrim(v_mk.selg)), lcDok,'AUTOMATSELT LAUSEND (GEN_LAUSEND_MK)',v_mk.id) ;


		if lnJournalId = 0 then
			return 0;
		end if;

		lnJournal1Id = sp_salvesta_journal1(0,lnJournalId,v_mk1.summa,''::varchar,''::text,
				v_mk1.kood1,v_mk1.kood2,v_mk1.kood3,v_mk1.kood4,v_mk1.kood5,
					lcDbKonto,lcDbTp,lcKrKonto,lcKrTp,v_mk1.valuuta,v_mk1.kuurs,v_mk1.summa*v_mk1.kuurs,
					v_mk1.tunnus,v_mk1.proj);

		update mk1 set journalId = lnJournalId where id = v_mk1.id;		

		if v_mk1.journalid > 0 then		
			update journalid set number = lnJournalNumber where journalid = lnJournalId;		
		end if;

		if v_mk.arvid > 0 then
		    update arvtasu set journalid = lnJournalId
			   where arvtasu.arvid = v_mk.arvId
			   and sorderId = v_mk.id;
		end if;

	End loop;
	return lnJournalId;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION gen_lausend_mk(integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION gen_lausend_mk(integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION gen_lausend_mk(integer) TO dbpeakasutaja;


-- Function: sp_salvesta_leping2(integer, integer, integer, numeric, numeric, integer, date, date, numeric, integer, text, text, integer)

-- DROP FUNCTION sp_salvesta_leping2(integer, integer, integer, numeric, numeric, integer, date, date, numeric, integer, text, text, integer);

/*
select sp_salvesta_leping2(20::int,20::int,58::int,1.0000::numeric,150.0000::numeric,0.0000::numeric,NULL,NULL,0.0000::numeric,1::int,''::text,''::text,1::int,'EUR'::varchar,15.6500::numeric)
*/

CREATE OR REPLACE FUNCTION sp_salvesta_leping2(integer, integer, integer, numeric, numeric, integer, date, date, numeric, integer, text, text, integer, varchar, numeric)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnparentid alias for $2;
	tnnomid alias for $3;
	tnkogus alias for $4;
	tnhind alias for $5;
	tnsoodus alias for $6;
	tdsoodusalg alias for $7;
	tdsooduslopp alias for $8;
	tnsumma alias for $9;
	tnstatus alias for $10;
	ttmuud alias for $11;
	ttformula alias for $12;
	tnkbm alias for $13;
	tcValuuta alias for $14;
	tnKuurs alias for $15;
	lnleping2Id int;
	lnId int; 
	lrCurRec record;
	v_dokvaluuta record;
begin

if tnId = 0 then
	-- uus kiri
	insert into leping2 (parentid,nomid,kogus,hind,soodus,soodusalg,sooduslopp,summa,status,muud,formula,kbm) 
		values (tnparentid,tnnomid,tnkogus,tnhind,tnsoodus,tdsoodusalg,tdsooduslopp,tnsumma,tnstatus,ttmuud,ttformula,tnkbm);


	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
		lnleping2Id:= cast(CURRVAL('public.leping2_id_seq') as int4);
	else
		lnleping2Id = 0;
	end if;

	if lnleping2Id = 0 then
		raise exception 'Viga:%','Ei saa lisada kiri';
	end if;

	-- valuuta

	insert into dokvaluuta1 (dokliik,dokid, valuuta, kuurs) 
		values (22, lnleping2Id,tcValuuta, tnKuurs);


else
	-- muuda 
	select * into lrCurRec from leping2 where id = tnId;
	if lrCurRec.parentid <> tnparentid or lrCurRec.nomid <> tnnomid or lrCurRec.kogus <> tnkogus or lrCurRec.hind <> tnhind 
		or lrCurRec.soodus <> tnsoodus or ifnull(lrCurRec.soodusalg,date(1900,01,01)) <> ifnull(tdsoodusalg,date(1900,01,01)) 
		or ifnull(lrCurRec.sooduslopp,date(1900,01,01)) <> ifnull(tdsooduslopp,date(1900,01,01)) or lrCurRec.summa <> tnsumma 
		or lrCurRec.status <> tnstatus or ifnull(lrCurRec.muud,space(1)) <> ifnull(ttmuud,space(1)) or lrCurRec.formula <> ttformula 
		or lrCurRec.kbm <> tnkbm then 

	update leping2 set 
		parentid = tnparentid,
		nomid = tnnomid,
		kogus = tnkogus,
		hind = tnhind,
		soodus = tnsoodus,
		soodusalg = tdsoodusalg,
		sooduslopp = tdsooduslopp,
		summa = tnsumma,
		status = tnstatus,
		muud = ttmuud,
		formula = ttformula,
		kbm = tnkbm
	where id = tnId;
	end if;
	lnleping2Id := tnId;


	-- valuuta
	if (select count(id) from dokvaluuta1 where dokliik = 22 and dokid = lnleping2Id) = 0 then

		insert into dokvaluuta1 (dokliik, dokid, valuuta, kuurs) 
			values (22, lnleping2Id,tcValuuta, tnKuurs);
	else
		select * into v_dokvaluuta from dokvaluuta1 where dokliik = 22 and dokid = lnleping2Id ;

		if tcValuuta <> v_dokvaluuta.valuuta or tnKuurs <> v_dokvaluuta.kuurs then

			update dokvaluuta1 set valuuta = tcValuuta, kuurs = tnKuurs where id = v_dokvaluuta.id;
			
		end if;
	
	end if;


end if;

         return  lnleping2Id;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_leping2(integer, integer, integer, numeric, numeric, integer, date, date, numeric, integer, text, text, integer, varchar, numeric) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_leping2(integer, integer, integer, numeric, numeric, integer, date, date, numeric, integer, text, text, integer, varchar, numeric) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_leping2(integer, integer, integer, numeric, numeric, integer, date, date, numeric, integer, text, text, integer, varchar, numeric) TO dbpeakasutaja;


-- Function: sp_salvesta_leping1(integer, integer, integer, integer, character, date, date, text, text, text)

-- DROP FUNCTION sp_salvesta_leping1(integer, integer, integer, integer, character, date, date, text, text, text);

CREATE OR REPLACE FUNCTION sp_salvesta_leping1(integer, integer, integer, integer, character, date, date, text, text, text)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnasutusid alias for $2;
	tnrekvid alias for $3;
	tndoklausid alias for $4;
	tcnumber alias for $5;
	tdkpv alias for $6;
	tdtahtaeg alias for $7;
	ttselgitus alias for $8;
	ttdok alias for $9;
	ttmuud alias for $10;
	lnleping1Id int;
	lnId int; 
	lrCurRec record;
begin

if tnId = 0 then
	-- uus kiri
	insert into leping1 (asutusid,rekvid,doklausid,number,kpv,tahtaeg,selgitus,dok,muud) 
		values (tnasutusid,tnrekvid,tndoklausid,tcnumber,tdkpv,tdtahtaeg,ttselgitus,ttdok,ttmuud);


	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
		lnleping1Id:= cast(CURRVAL('public.leping1_id_seq') as int4);
	else
		lnleping1Id = 0;
	end if;

	if lnmk1Id = 0 then
		raise exception 'Viga:%','Ei saa lisada kiri';
	end if;

else
	-- muuda 
	select * into lrCurRec from leping1 where id = tnId;
	if lrCurRec.asutusid <> tnasutusid or lrCurRec.rekvid <> tnrekvid or lrCurRec.doklausid <> tndoklausid or lrCurRec.number <> tcnumber or lrCurRec.kpv <> tdkpv or ifnull(lrCurRec.tahtaeg,date(1900,01,01)) <> ifnull(tdtahtaeg,date(1900,01,01)) or lrCurRec.selgitus <> ttselgitus or ifnull(lrCurRec.dok,space(1)) <> ifnull(ttdok,space(1)) or ifnull(lrCurRec.muud,space(1)) <> ifnull(ttmuud,space(1)) then 
	update leping1 set 
		asutusid = tnasutusid,
		rekvid = tnrekvid,
		doklausid = tndoklausid,
		number = tcnumber,
		kpv = tdkpv,
		tahtaeg = tdtahtaeg,
		selgitus = ttselgitus,
		dok = ttdok,
		muud = ttmuud
	where id = tnId;
	end if;
	lnleping1Id := tnId;
end if;

         return  lnleping1Id;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_leping1(integer, integer, integer, integer, character, date, date, text, text, text) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_leping1(integer, integer, integer, integer, character, date, date, text, text, text) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_leping1(integer, integer, integer, integer, character, date, date, text, text, text) TO dbpeakasutaja;


-- Function: sp_calc_tahtpaevad(integer, integer)

-- DROP FUNCTION sp_calc_tahtpaevad(integer, integer);

CREATE OR REPLACE FUNCTION sp_calc_tahtpaevad(integer, integer)
  RETURNS numeric AS
$BODY$
DECLARE tnRekvId alias for $1;
	tnKuu alias for $2;
	lnTunnid int2;
begin

	SELECT count(id) into lnTunnid FROM holidays WHERE rekvid = tnRekvid and kuu = tnKuu  AND luhipaev = 1;
	lnTunnid := 3 * lnTunnid;

	RETURN lnTunnid;
end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_calc_tahtpaevad(integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_calc_tahtpaevad(integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_calc_tahtpaevad(integer, integer) TO dbpeakasutaja;



-- Function: gen_lausend_mahakandmine(integer)

-- DROP FUNCTION gen_lausend_mahakandmine(integer);

CREATE OR REPLACE FUNCTION gen_lausend_mahakandmine(integer)
  RETURNS integer AS
$BODY$

declare 	tnId alias for $1;
		lnJournalNumber int4;
		lcDbKonto varchar(20);
		lcKrKonto varchar(20);
		lcDbTp varchar(20);
		lcKrTp varchar(20);
		lnAsutusId int4;
		lnJournalId int4;
		lnJournal1Id int4;
		lnUsrId int;
		v_pv_oper record;
		v_pv_kaart record;
		v_library record;
		v_dokprop dokprop%rowtype;
		v_aa aa%rowtype;

		lnKontrol int;
		lcAllikas varchar(20);
		lcviga varchar;
		lcDok varchar;

begin

	select pv_oper.*, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs, ifnull(dokvaluuta1.valuuta,'EEK')::varchar as valuuta into v_pv_oper 
		from pv_oper left outer join dokvaluuta1 on (pv_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 13)
		where pv_oper.id = tnId;

	If v_pv_oper.doklausid = 0 then
		raise notice 'Konteerimine ei ole vajalik, dok tyyp ei ole defineeritud';
		Return 0;

	End if;

	select * into v_dokprop from dokprop where id = v_pv_oper.doklausid ;

	If not Found Or v_dokprop.registr = 0 then
		raise notice 'Konteerimine ei ole vajalik';
		Return 0;

	End if;

	select library.rekvid, library.kood,pv_kaart.* into v_pv_kaart 
		from library inner join pv_kaart on pv_kaart.parentid = library.id 
		where pv_kaart.parentid = v_pv_oper.parentId;

	lcDok := 'Inv.number '+IFNULL(v_pv_kaart.kood,SPACE(1));	

	select recalc into lnKontrol from rekv where id = v_pv_kaart.rekvid;
	lcAllikas = 'LE-P';



	If v_pv_oper.journalid > 0 then

		select number into lnJournalNumber from journalId where journalId = v_pv_oper.journalId;
		update pv_oper set journalid = 0 where pv_oper.id = v_pv_oper.id;


		perform sp_del_journal(v_pv_oper.journalid,1); 

	End if;


	select * into v_aa from aa where parentid = v_pv_kaart.rekvId;	
	lcDbKonto := v_pv_oper.konto;
	lcKrKonto := v_pv_kaart.konto;
	lcKrTp := v_pv_oper.tp;

	lcDbTp := v_pv_oper.tp;
	lnAsutusId = v_pv_oper.Asutusid;
	lcAllikas = 'LE-P';

	SELECT id INTO lnUsrID from userid WHERE rekvid = v_pv_kaart.rekvId and kasutaja = CURRENT_USER::VARCHAR;

	lnJournalId:= sp_salvesta_journal(0, v_pv_kaart.rekvId, lnUsrID, v_pv_oper.kpv, lnAsutusId, 
		ltrim(rtrim(v_dokprop.selg)), lcDok,'AUTOMATSELT LAUSEND (GEN_LAUSEND_MAHAKANDMINE)',v_pv_oper.id) ;

	if lnJournalId = 0 then
		return 0;
	end if; 	

	if not empty(v_pv_oper.kood2) then
		lcAllikas = v_pv_oper.kood2;
	end if;

	select tun1 into v_library from library where kood = lcDbKonto and library = 'KONTOD';
	if empty (v_library.tun1) OR v_library.tun1 = 0 then
		lcDbTp := space(1);
	end if;
	select tun1 into v_library from library where kood = lcKrKonto and library = 'KONTOD';
	if empty (v_library.tun1) OR v_library.tun1 = 0 then
		lcKrTp := space(1);
	end if;

	lnJournal1Id = sp_salvesta_journal1(0,lnJournalId,v_pv_oper.Summa,''::varchar,''::text,
				v_pv_oper.kood1,v_pv_oper.kood2,v_pv_oper.kood3,v_pv_oper.kood4,v_pv_oper.kood5,
				lcDbKonto,lcDbTp,lcKrKonto,lcKrTp,v_pv_oper.valuuta,v_pv_oper.kuurs,v_pv_oper.summa*v_pv_oper.kuurs,
				v_pv_oper.tunnus,v_pv_oper.proj);

	update pv_oper set journalId = lnJournalId where id = v_pv_oper.id;


	if v_pv_oper.journalId > 0 and ifnull(lnJournalNumber,0) > 0 then

		update journalid set number = lnJournalNumber where journalid = lnJournalId;
	end if;


	return lnJournalId;

end; 

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION gen_lausend_mahakandmine(integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION gen_lausend_mahakandmine(integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION gen_lausend_mahakandmine(integer) TO dbpeakasutaja;

-- Function: sp_salvesta_pv_oper(integer, integer, integer, integer, integer, date, numeric, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, character varying, character varying, character varying, numeric)

-- DROP FUNCTION sp_salvesta_pv_oper(integer, integer, integer, integer, integer, date, numeric, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, character varying, character varying, character varying, numeric);

CREATE OR REPLACE FUNCTION sp_salvesta_pv_oper(integer, integer, integer, integer, integer, date, numeric, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, character varying, character varying, character varying, numeric)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnparentid alias for $2;
	tnnomid alias for $3;
	tndoklausid alias for $4;
	tnliik alias for $5;
	tdkpv alias for $6;
	tnsumma alias for $7;
	ttmuud alias for $8;
	tckood1 alias for $9;
	tckood2 alias for $10;
	tckood3 alias for $11;
	tckood4 alias for $12;
	tckood5 alias for $13;
	tckonto alias for $14;
	tctp alias for $15;
	tnasutusid alias for $16;
	tctunnus alias for $17;
	tcProj alias for $18;
	tcValuuta alias for $19;
	tnKuurs alias for $20;
	lnpv_operId int;
	lnId int; 
	lnSumma numeric(12,2);
	v_pv_kaart record;
	lrCurRec record;
	lnPvElu numeric(6,2);
	lnKulum numeric(12,2);

	lnSoetSumma numeric (12,4);
	lnParandatudSumma numeric (12,4);
	lnUmberhindatudSumma numeric (12,4);
	
	lnDokKuurs numeric(14,4);
	lcString varchar;
	v_dokvaluuta record;
	ldKpv date;


begin

if tnId = 0 then
	-- uus kiri
	insert into pv_oper (parentid,nomid,doklausid,liik,kpv,summa,muud,kood1,kood2,kood3,kood4,kood5,konto,tp,asutusid,tunnus, proj) 
		values (tnparentid,tnnomid,tndoklausid,tnliik,tdkpv,tnsumma,ttmuud,tckood1,tckood2,tckood3,tckood4,tckood5,tckonto,tctp,tnasutusid,tctunnus, tcProj);

	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
		lnpv_operId:= cast(CURRVAL('public.pv_oper_id_seq') as int4);
	else
		lnpv_operId = 0;
	end if;

	if lnpv_operId = 0 then
		raise exception ':%','Ei saa lisada kiri';
	end if;

			-- valuuta

	insert into dokvaluuta1 (dokid, dokliik, valuuta, kuurs) 
		values (lnpv_operId,13,tcValuuta, tnKuurs);



else
	-- muuda 
	select * into lrCurRec from pv_oper where id = tnId;
	if  lrCurRec.nomid <> tnnomid or lrCurRec.doklausid <> tndoklausid or lrCurRec.liik <> tnliik or lrCurRec.kpv <> tdkpv 
		or lrCurRec.summa <> tnsumma or ifnull(lrCurRec.muud,space(1)) <> ifnull(ttmuud,space(1)) or lrCurRec.kood1 <> tckood1 
		or lrCurRec.kood2 <> tckood2 or lrCurRec.kood3 <> tckood3 or lrCurRec.kood4 <> tckood4 or lrCurRec.kood5 <> tckood5 
		or lrCurRec.konto <> tckonto or lrCurRec.tp <> tctp or lrCurRec.asutusid <> tnasutusid or lrCurRec.tunnus <> tctunnus then 

	update pv_oper set 
		nomid = tnnomid,
		doklausid = tndoklausid,
		liik = tnliik,
		kpv = tdkpv,
		summa = tnsumma,
		muud = ttmuud,
		kood1 = tckood1,
		kood2 = tckood2,
		kood3 = tckood3,
		kood4 = tckood4,
		kood5 = tckood5,
		konto = tckonto,
		tp = tctp,
		asutusid = tnasutusid,
		proj = tcProj,
		tunnus = tctunnus
	where id = tnId;
	end if;

	lnpv_operId := tnId;
end if;


	-- valuuta
	if (select count(id) from dokvaluuta1 where dokliik = 13 and dokid =lnpv_operId) = 0 then

		insert into dokvaluuta1 (dokliik, dokid, valuuta, kuurs) 
			values (13, lnpv_operId,tcValuuta, tnKuurs);
	else
		select * into v_dokvaluuta from dokvaluuta1 where dokliik = 13 and dokid = lnpv_operId ;

		if tcValuuta <> v_dokvaluuta.valuuta or tnKuurs <> v_dokvaluuta.kuurs then

			update dokvaluuta1 set valuuta = tcValuuta, kuurs = tnKuurs where id = v_dokvaluuta.id;

						
		end if;
	
	end if;


	if tnLiik = 1 then
-- 
		Select id into lnId from pv_kaart where parentid = tnParentId;
		lnId = ifnull(lnId,0);
		if lnId > 0 then
			if (select count(id) from dokvaluuta1 where dokliik = 18 and dokid = lnId) = 0 then
	
				insert into dokvaluuta1 (dokid, dokliik, valuuta, kuurs) 
					values (tnParentId,18,tcValuuta, tnKuurs);
			else
	
				update dokvaluuta1 set valuuta = tcValuuta, kuurs = tnKuurs where dokid = lnId and dokliik = 18;

			end if;
		end if;
		update pv_kaart set soetmaks = tnSumma where id = lnId;


	end if;


	select soetmaks, parhind, algkulum, kulum, soetkpv, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs into v_pv_kaart 
		from pv_kaart left outer join dokvaluuta1 on (dokvaluuta1.dokid = pv_kaart.id and dokliik = 18) where parentId = tnparentid;

	lnKulum := v_pv_kaart.kulum;
	ldKpv := v_pv_kaart.soetkpv;

	-- PARANDAME PARANDATUD SUMMA.

--	lnSumma = get_pv_summa(tnparentid);
/*
	if tnLiik = 5 then
		ldKpv := tdKpv;
		lnUmberhindatudSumma := tnSumma*tnKuurs;

		-- parandame pv kulum
		raise notice 'v_pv_kaart.kulum %',v_pv_kaart.kulum;

		lnPvElu := (100 / v_pv_kaart.kulum);
		raise notice 'lnPvElu %',lnPvElu;
		lnPvElu := lnPvElu - (year(tdkpv) - year(v_pv_kaart.soetkpv));
		lnKulum := 100 / lnPvElu;
		raise notice 'lnPvElu %',lnPvElu;
		raise notice 'lnKulum %',lnKulum;

		lcString = 'update pv_kaart set kulum = ' + lnKulum::varchar; 

	else
		select sum(summa*ifnull(dokvaluuta1.kuurs,1)) into lnUmberhindatudSumma 
			from pv_oper left outer join dokvaluuta1 on (dokvaluuta1.dokid = pv_oper.id and dokvaluuta1.dokliik = 13)
			where pv_oper.parentId = tnparentid and liik = 5;

		lnUmberhindatudSumma := ifnull(lnUmberhindatudSumma,0);
		if lnUmberhindatudSumma > 0 then
			select kpv into ldKpv from pv_oper where liik = 5 and parentId = tnParentId order by kpv desc limit 1;
		else
			lnUmberhindatudSumma := v_pv_kaart.soetmaks;
		end if;
	end if;



	select sum(summa*ifnull(dokvaluuta1.kuurs,1)) into lnSoetSumma 
		from pv_oper left outer join dokvaluuta1 on (dokvaluuta1.dokid = pv_oper.id and dokvaluuta1.dokliik = 13)
		where parentId = tnparentid and liik = 1;

	lnSoetSumma  = ifnull(lnSoetSumma ,v_pv_kaart.soetmaks);

	select sum(summa*ifnull(dokvaluuta1.kuurs,1)) into lnParandatudSumma 
		from pv_oper left outer join dokvaluuta1 on (dokvaluuta1.dokid = pv_oper.id and dokvaluuta1.dokliik = 13)
		where parentId = tnparentid and liik = 3 and kpv > ldKpv;


	select sum(summa*ifnull(dokvaluuta1.kuurs,1)) into lnKulum 
		from pv_oper left outer join dokvaluuta1 on (dokvaluuta1.dokid = pv_oper.id and dokvaluuta1.dokliik = 13)
		where parentId = tnparentid and liik = 2;

	lnParandatudSumma := ifnull(lnParandatudSumma,0) + ifnull(lnUmberhindatudSumma,v_pv_kaart.soetmaks);
		raise notice 'lnParandatudSumma %',lnParandatudSumma;

	-- otsime dok.valuuta
	Select id into lnId from pv_kaart where parentid = tnParentId;
	
	select kuurs into lnDokKuurs from dokvaluuta1 where dokid = lnId and dokliik = 18;
	lnDokKuurs = ifnull(lnDokKuurs,1);
		
	lnParandatudSumma = lnParandatudSumma / lnDokKuurs;
		raise notice 'lnParandatudSumma dokvaluutas %',lnParandatudSumma;

--	if v_pv_kaart.parhind <> lnParandatudSumma then

	lnKulum = (ifnull(lnKulum,0) + v_pv_kaart.algkulum * v_pv_kaart.kuurs) / lnDokKuurs;

	update pv_kaart set parhind = lnParandatudSumma, jaak = lnParandatudSumma - lnKulum where parentId = tnparentid;
*/
	perform sp_update_pv_jaak(tnParentId);


         return  lnpv_operId;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_pv_oper(integer, integer, integer, integer, integer, date, numeric, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, character varying, character varying, character varying, numeric) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_pv_oper(integer, integer, integer, integer, integer, date, numeric, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, character varying, character varying, character varying, numeric) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_pv_oper(integer, integer, integer, integer, integer, date, numeric, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, character varying, character varying, character varying, numeric) TO dbpeakasutaja;



CREATE OR REPLACE FUNCTION sp_update_pv_jaak(integer)
  RETURNS numeric AS
$BODY$

declare
	tnid alias for $1;
	lnpv_operId int;
	lnId int; 
	lnSumma numeric(12,2);
	v_pv_kaart record;
	lrCurRec record;
	lnPvElu numeric(6,2);
	lnKulum numeric(12,2);

	lnSoetSumma numeric (12,4);
	lnParandatudSumma numeric (12,4);
	lnUmberhindatudSumma numeric (12,4);
	
	lnDokKuurs numeric(14,4);
	lcString varchar;
	v_dokvaluuta record;
	ldKpv date;
	lnJaak numeric (14,2);


begin


	select soetmaks, parhind, algkulum, kulum, soetkpv, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs into v_pv_kaart 
		from pv_kaart left outer join dokvaluuta1 on (dokvaluuta1.dokid = pv_kaart.id and dokliik = 18) 
		where pv_kaart.parentId = tnid;

	lnKulum := v_pv_kaart.kulum;
	ldKpv := v_pv_kaart.soetkpv;

	-- PARANDAME PARANDATUD SUMMA.

--	lnSumma = get_pv_summa(tnparentid);

		select sum(summa*ifnull(dokvaluuta1.kuurs,1)) into lnUmberhindatudSumma 
			from pv_oper left outer join dokvaluuta1 on (dokvaluuta1.dokid = pv_oper.id and dokvaluuta1.dokliik = 13)
			where pv_oper.parentId = tnid and liik = 5;

		lnUmberhindatudSumma := ifnull(lnUmberhindatudSumma,0);

		raise notice 'hind: %',lnUmberhindatudSumma;
		if lnUmberhindatudSumma > 0 then
			select kpv into ldKpv from pv_oper where liik = 5 and parentId = tnId order by kpv desc limit 1;
		else
			lnUmberhindatudSumma := v_pv_kaart.soetmaks;
		end if;

		raise notice 'kpv: %',ldKpv;


	select sum(summa*ifnull(dokvaluuta1.kuurs,1)) into lnSoetSumma 
		from pv_oper left outer join dokvaluuta1 on (dokvaluuta1.dokid = pv_oper.id and dokvaluuta1.dokliik = 13)
		where parentId = tnid and liik = 1;

	lnSoetSumma  = ifnull(lnSoetSumma ,v_pv_kaart.soetmaks);

	select sum(summa*ifnull(dokvaluuta1.kuurs,1)) into lnParandatudSumma 
		from pv_oper left outer join dokvaluuta1 on (dokvaluuta1.dokid = pv_oper.id and dokvaluuta1.dokliik = 13)
		where parentId = tnid and liik = 3 and kpv > ldKpv;

		raise notice 'lnParandatudSumma: %',lnParandatudSumma;


	select sum(summa*ifnull(dokvaluuta1.kuurs,1)) into lnKulum 
		from pv_oper left outer join dokvaluuta1 on (dokvaluuta1.dokid = pv_oper.id and dokvaluuta1.dokliik = 13)
		where parentId = tnid and liik = 2 and kpv > ldKpv;

	lnParandatudSumma := ifnull(lnParandatudSumma,0) + ifnull(lnUmberhindatudSumma,v_pv_kaart.soetmaks);
		raise notice 'lnParandatudSumma %',lnParandatudSumma;

	-- otsime dok.valuuta
	Select id into lnId from pv_kaart where parentid = tnId;
	
		
	lnParandatudSumma = lnParandatudSumma;
		raise notice 'lnParandatudSumma dokvaluutas %',lnParandatudSumma;

	if lnUmberhindatudSumma > 0 and lnUmberhindatudSumma <> lnSoetSumma then
		lnKulum = ifnull(lnKulum,0);
	else
		lnKulum = (ifnull(lnKulum,0) + v_pv_kaart.algkulum ) ;
	end if;


	update pv_kaart set parhind = lnParandatudSumma, jaak = lnParandatudSumma - lnKulum where parentId = tnid;

	lnJaak = lnParandatudSumma - lnKulum;

         return  lnJaak;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_update_pv_jaak(integer) OWNER TO vlad;

GRANT EXECUTE ON FUNCTION sp_update_pv_jaak(integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_update_pv_jaak(integer) TO dbpeakasutaja;

-- Function: sp_salvesta_pv_kaart(integer, integer, date, numeric, numeric, integer, character varying, integer, text, text, character varying, character varying, integer)

-- DROP FUNCTION sp_salvesta_pv_kaart(integer, integer, date, numeric, numeric, integer, character varying, integer, text, text, character varying, character varying, integer);

CREATE OR REPLACE FUNCTION sp_salvesta_pv_kaart(integer, integer, date, numeric, numeric, integer, character varying, integer, text, text, character varying, character varying, integer)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnvastisikid alias for $2;
	tdsoetkpv alias for $3;
	tnkulum alias for $4;
	tnalgkulum alias for $5;
	tngruppid alias for $6;
	tckonto alias for $7;
	tntunnus alias for $8;
	ttselg alias for $9;
	ttrentnik alias for $10;
	tcKood alias for $11;
	tcNimetus alias for $12;
	tnRekvId alias for $13;
	lnpv_kaartId int;
	lnId int; 
	lnParentId int;
	lrCurRec record;
begin

raise notice 'vats %',tnVastisikId;
if tnId = 0 then
	-- uus kiri

	lnParentId = sp_salvesta_library(tnId, tnRekvId, tcKood, tcNimetus, 'POHIVARA', ttSelg, 0, 1, 0, 0, 0);

	if lnParentId = 0 then
		raise notice 'Viga, ei saa salvesta dokument';
		return 0;
	end if;
	
	insert into pv_kaart (parentid,vastisikid,soetkpv,kulum,algkulum,gruppid,konto,tunnus,muud) 
		values (lnparentid,tnvastisikid,tdsoetkpv,tnkulum,tnalgkulum,tngruppid,tckonto,tntunnus,ttRentnik);

	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
		lnpv_kaartId:= cast(CURRVAL('public.pv_kaart_id_seq') as int4);
	else
		lnpv_kaartId = 0;
	end if;

	if lnpv_kaartId = 0 then
		raise exception ':%','Ei saa lisada kiri';
	end if;

else
	-- muuda 

--	select parentid into lnParentId from pv_kaart where id = tnId;
	lnParentId = sp_salvesta_library(tnId, tnRekvId, tcKood, tcNimetus, 'POHIVARA', ttSelg, 0, 0, 0, 0, 0);

	if lnParentId = 0 then
		raise notice 'Viga, ei saa salvesta dokument';
		return 0;
	end if;


	update pv_kaart set 
			vastisikid = tnvastisikid,
			soetkpv = tdsoetkpv,
			kulum = tnkulum,
			algkulum = tnalgkulum,
			gruppid = tngruppid,
			konto = tckonto,
			muud = ttRentnik
		where parentid = tnId;

	lnpv_kaartId := tnId;

	perform sp_update_pv_jaak(tnId);
end if;

         return  lnParentId;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_pv_kaart(integer, integer, date, numeric, numeric, integer, character varying, integer, text, text, character varying, character varying, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_pv_kaart(integer, integer, date, numeric, numeric, integer, character varying, integer, text, text, character varying, character varying, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_pv_kaart(integer, integer, date, numeric, numeric, integer, character varying, integer, text, text, character varying, character varying, integer) TO dbpeakasutaja;

-- Function: sp_saldoandmik_report(integer, date, integer, integer, integer)

-- DROP FUNCTION sp_saldoandmik_report(integer, date, integer, integer, integer);

CREATE OR REPLACE FUNCTION sp_saldoandmik_report(integer, date, integer, integer, integer)
  RETURNS character varying AS
$BODY$
DECLARE tnrekvid alias for $1;
	tdKpv alias for $2;
	tnTyyp alias for $3;
	tnSvod alias for $4;
	tnVar alias for $5;
	lcReturn varchar;
	lcString varchar;
	lcPnimi varchar;

	lnreturn int;
	LNcOUNT int;
	lnTun int;

	lnDeebet numeric(12,2);
	lnKreedit numeric(12,2);
	lcTp varchar(20);
	lcAllikas varchar(20);
	lcTegev varchar(20);
	lcRahavoog varchar(20);
	lcEelarve varchar(20);
	lcKonto varchar(20);
	lcKontoNimi varchar(254);

	lcKulumKontoString varchar(254);
	v_saldo record;
	v_library record;
	lcReturn1 varchar;
	
	
	lnTase int;

	lcMeetmekood varchar(20);
begin

lnreturn = 0;


if (select count(*) from pg_stat_all_tables where UPPER(relname) = 'TMP_SALDOANDMIK')  < 1 then
	
	create table tmp_saldoandmik (id serial NOT NULL, nimetus varchar(254) not null default space(1), db numeric(12,2) not null default 0, kr numeric(12,2) not null default 0, konto varchar(20) not null default space(1), 		
		tegev varchar(20) not null default space(1), tp varchar(20) not null default space(1), allikas varchar(20) not null default space(1), 			
		rahavoo varchar(20) not null default space(1), 
		timestamp varchar(20) not null , kpv date default date(), rekvid int, tyyp int default 0 not null )  ;
		
		GRANT ALL ON TABLE tmp_saldoandmik TO GROUP public;
		GRANT ALL ON TABLE tmp_saldoandmik_id_seq TO public;

else
	delete from tmp_saldoandmik where kpv < date() and rekvid = tnrekvId;
end if;

lcreturn := ltrim(rtrim(str(tnrekvId)))+to_char(now(), 'YYYYMMDDMISSSS');

/*
if (select count(*) from pg_stat_all_tables where UPPER(relname) = 'TMPREKV')  > 0 then
	delete from tmpRekv;
--	truncate TABLE tmpRekv;
	insert into tmpRekv
		SELECT id, parentid, fnc_get_asutuse_staatus(rekv.id, tnrekvid)::int as tase FROM rekv where parentid <> 9999;
else
	CREATE TABLE tmpRekv AS
		SELECT id, parentid, fnc_get_asutuse_staatus(rekv.id, tnrekvid)::int as tase FROM rekv where parentid <> 9999;
		GRANT ALL ON TABLE tmpRekv TO GROUP public;

END IF;

if tnSvod = 1 then
	delete from tmpRekv where tase < 3;

else
	delete from tmpRekv where tase in (0,1,2,4);
end if;
*/

if tnSvod = 1 then
	lnTase = 3;

else
	lnTase = 9;
end if;

lcKonto = '';

for v_saldo in 
	SELECT  journal1.deebet AS konto, journal1.lisa_d as tp, 
		journal1.kood2 as allikas, journal1.kood1 as tegev, journal1.kood3 as rahavoo, journal1.kood5 as eelarve,
		sum(journal1.summa * ifnull(dokvaluuta1.kuurs,1)) AS dB, 0::numeric(12,4) AS kr 
		FROM journal inner join journal1 on journal.id = journal1.parentid 
		left outer join dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 1)
		where year(Journal.kpv) < year(tdKpv) 
		and journal1.summa <> 0
		and (journal.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  journal.rekvid = tnRekvId)
		group by journal1.deebet, journal1.lisa_d, journal1.kood1, journal1.kood2, journal1.kood3, journal1.kood5
	UNION ALL 
		SELECT  journal1.kreedit AS konto, journal1.lisa_k as tp,
		journal1.kood2 as allikas,journal1.kood1 as tegev, journal1.kood3 as rahavoo, journal1.kood5 as eelarve,
		0::numeric(12,4) as dB, sum(journal1.summa * ifnull(dokvaluuta1.kuurs,1)) AS kr
		FROM journal inner join journal1 on journal.id = journal1.parentid 
		left outer join dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 1)
		where year(Journal.kpv) < year(tdKpv)
		and journal1.summa <> 0
		and (journal.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  journal.rekvid = tnRekvId)
		group by journal1.kreedit, journal1.lisa_k,journal1.kood1, journal1.kood2, journal1.kood3, journal1.kood5

loop

	lnDeebet = 0;
	lnKreedit = 0;
/*
	if lcKonto <> '' then
		if ltrim(rtrim(v_saldo.konto)) <> lcKonto then
			lcKonto = ltrim(rtrim(v_library.kood));
		end if;
	end if;
*/

			select * into v_library from library where ltrim(rtrim(kood)) = ltrim(rtrim(v_saldo.konto)) and ltrim(rtrim(library)) = 'KONTOD' order by id desc limit 1; 


	-- tp
	if empty (v_library.tun1) then 
		v_saldo.tp = '';
	end if;
	if ((left(ltrim(rtrim(v_saldo.konto)),3) = '154' or left(ltrim(rtrim(v_saldo.konto)),3) = '155' or left(ltrim(rtrim(v_saldo.konto)),3) = '156'))  then 
		v_saldo.tp = '';
	end if;

	--tegev
	if empty (v_library.tun2) or ((left(v_saldo.konto,3) = '154' or left(v_saldo.konto,3) = '155' or left(v_saldo.konto,3) = '156') and v_saldo.rahavoo <> '01') then 
		v_saldo.tegev = '';
	end if;
	-- allikas
	if empty (v_library.tun3) or isdigit(v_saldo.allikas) = 0 then 
		v_saldo.allikas = '';
	end if;
	-- rahavoo
	if empty (v_library.tun4) then 
		v_saldo.rahavoo = '';
	else
		v_saldo.rahavoo = '00';
	end if;
	if v_library.tun5 = 1 or v_library.tun5 = 3 then
		lnDeebet = v_saldo.db - v_saldo.kr;
	else
		lnKreedit = v_saldo.kr - v_saldo.db;
	end if;
	lnDeebet = ifnull(lnDeebet,0);
	lnKreedit = ifnull(lnKreedit,0);
/*
	if alltrim(v_saldo.konto) = '201000' and v_saldo.tp = '014601' then
		raise notice ' lnDeebet %',lnDeebet;
		raise notice ' lnKreedit %',lnKreedit;
	end if;
*/
	INSERT INTO tmp_saldoandmik ( konto, tp, tegev, allikas, rahavoo, db, kr, rekvid, timestamp, nimetus, tyyp) values 
		( alltrim(v_saldo.konto), alltrim(v_saldo.tp), alltrim(v_saldo.tegev), alltrim(v_saldo.allikas), alltrim(v_saldo.rahavoo), lnDeebet, lnKreedit,
		tnRekvId, lcReturn, alltrim(v_library.nimetus), 20 );
end loop;


/*
if (select count(*) from tmp_saldoandmik where konto like '103000' and tp = '185101' and timestamp = lcReturn) > 0 then
	raise notice '1 found';
end if; 
*/
-- update pv konto

update tmp_saldoandmik set tp = '' where not empty (tp) and ltrim(rtrim(rahavoo)) = '00' and left(ltrim(rtrim(konto)),3) in ('154','155','156') and ltrim(rtrim(timestamp)) = lcreturn and rekvid = tnRekvId;


-- pohi osa (kaibed)

for v_saldo in 
	SELECT library.tun1,library.tun2, library.tun3, library.tun4,library.tun5, konto,  tp, tegev, allikas, rahavoo, 
			case when (library.tun5=1 or library.tun5 = 3) then
			(sum(deebet) - sum (kreedit) ) else 0 end as db, 
		case when (library.tun5=2 or library.tun5 = 4) then 
			(sum (kreedit) - sum(deebet)) else 0 end as kr, 
		tnRekvId as rekvid, lcReturn as timestamp, library.nimetus, 5 as tyyp
	from 
	(
	SELECT journal1.deebet As konto, journal1.lisa_d As tp, journal1.kood1 As tegev, journal1.kood2 As allikas, journal1.kood3 As rahavoo, 
		sum(journal1.Summa) As deebet, 0 As kreedit  
		FROM Journal inner join journal1 on journal.id = journal1.parentid
		where journal.kpv <= tdKpv
		and year(kpv) = year(tdKpv)
		and journal1.summa <> 0
		and (journal.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  journal.rekvid = tnRekvId)
		group by journal1.deebet, journal1.lisa_d, journal1.kood1, journal1.kood2, journal1.kood3 
		
	) qrySaldoaruanne inner join library on (ltrim(rtrim(library.kood)) =  ltrim(rtrim(qrySaldoaruanne.konto)) and ltrim(rtrim(library.library)) = 'KONTOD') 
	group BY konto, tp, tegev, allikas, rahavoo, library.tun1, library.tun2, library.tun3, library.tun4, library.tun5, library.nimetus  
	ORDER BY konto, tp, tegev, allikas, rahavoo

loop
	-- tp
	if empty (v_saldo.tun1) then 
		v_saldo.tp = '';
	end if;
	if ((left(v_saldo.konto,3) = '154' or left(v_saldo.konto,3) = '155' or left(v_saldo.konto,3) = '156') and v_saldo.rahavoo = '16') and v_saldo.rahavoo <> '01' then 
		v_saldo.tp = '';
	end if;

	--tegev
	if empty (v_saldo.tun2) or ((left(v_saldo.konto,3) = '154' or left(v_saldo.konto,3) = '155' or left(v_saldo.konto,3) = '156') and v_saldo.rahavoo <> '01') then 
		v_saldo.tegev = '';
	end if;
	-- allikas
	if empty (v_saldo.tun3) or isdigit(v_saldo.allikas) = 0 then 
		v_saldo.allikas = '';
	end if;
	-- rahavoo
	if empty (v_saldo.tun4) then 
		v_saldo.rahavoo = '';
	end if;
	/*
	if alltrim(v_saldo.konto) = '201000' and v_saldo.tp = '014601' then
		raise notice 'v_saldo.db %',v_saldo.db;
		raise notice ' v_saldo.kr %',v_saldo.kr;
	end if;
*/


	INSERT INTO tmp_saldoandmik (konto, tp, tegev, allikas, rahavoo, db, kr, rekvid, timestamp, nimetus, tyyp) values 
		(alltrim(v_saldo.konto), alltrim(v_saldo.tp), alltrim(v_saldo.tegev), alltrim(v_saldo.allikas), alltrim(v_saldo.rahavoo), v_saldo.db, v_saldo.kr, v_saldo.rekvid, v_saldo.timestamp, alltrim(v_saldo.nimetus), v_saldo.tyyp );
	
end loop;
/*
if (select count(*) from tmp_saldoandmik where konto = '103000' and tp = '185101' and timestamp = lcReturn) > 0 then
	raise notice '2 found';
end if; 

*/
for v_saldo in
SELECT konto, library.tun1, library.tun2, library.tun3, library.tun4, library.tun5,tp, tegev, allikas, rahavoo, 
	case when (library.tun5=1 or library.tun5 = 3) then
			(sum(deebet) - sum (kreedit) ) else 0 end as db, 
	case when (library.tun5=2 or library.tun5 = 4) then 
			(sum (kreedit) - sum(deebet)) else 0 end as kr, 
	tnRekvId as rekvid , lcReturn as timestamp, library.nimetus, 5 as tyyp
from 
(
	SELECT journal1.kreedit As konto, journal1.lisa_k As tp, journal1.kood1 As tegev, journal1.kood2 As allikas, journal1.kood3 As rahavoo, 
		0 As deebet, sum(journal1.Summa) As kreedit  
		FROM Journal inner join journal1 on journal.id = journal1.parentid
		where journal.kpv <= tdKpv 
		and year(kpv) = year(tdKpv)
		and journal1.summa <> 0
		and (journal.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  journal.rekvid = tnRekvId)
		group by journal1.kreedit, journal1.lisa_k, journal1.kood1, journal1.kood2, journal1.kood3 

) qrySaldoaruanne inner join library on (ltrim(rtrim(library.kood)) =  ltrim(rtrim(qrySaldoaruanne.konto)) and ltrim(rtrim(library.library)) = 'KONTOD') 
group BY konto, tp, tegev, allikas, rahavoo, library.tun1, library.tun2, library.tun3, library.tun4, library.tun5, library.nimetus  
ORDER BY konto, tp, tegev, allikas, rahavoo

loop
	-- tp
	if empty (v_saldo.tun1) then 
		v_saldo.tp = '';
	end if;
	if ((left(v_saldo.konto,3) = '154' or left(v_saldo.konto,3) = '155' or left(v_saldo.konto,3) = '156') and v_saldo.rahavoo = '16') then 
		v_saldo.tp = '';
	end if;

	--tegev
	if empty (v_saldo.tun2) or ((left(v_saldo.konto,3) = '154' or left(v_saldo.konto,3) = '155' or left(v_saldo.konto,3) = '156') and v_saldo.rahavoo <> '01') then 
		v_saldo.tegev = '';
	end if;
	-- allikas
	if empty (v_saldo.tun3) or isdigit(v_saldo.allikas) = 0 then 
		v_saldo.allikas = '';
	end if;
	-- rahavoo
	if empty (v_saldo.tun4) then 
		v_saldo.rahavoo = '';
	end if;


	INSERT INTO tmp_saldoandmik (konto, tp, tegev, allikas, rahavoo, db, kr, rekvid, timestamp, nimetus, tyyp) values 
		(alltrim(v_saldo.konto), alltrim(v_saldo.tp), alltrim(v_saldo.tegev), alltrim(v_saldo.allikas), alltrim(v_saldo.rahavoo), v_saldo.db, v_saldo.kr, v_saldo.rekvid, v_saldo.timestamp, alltrim(v_saldo.nimetus), v_saldo.tyyp );
	
end loop;
/*
if (select count(*) from tmp_saldoandmik where konto = '103000' and tp = '185101' and timestamp = lcReturn) > 0 then
	raise notice '3 found';
end if; 
*/
/*
INSERT INTO tmp_saldoandmik (konto, tp, tegev, allikas, rahavoo, db, kr, rekvid, timestamp, nimetus, tyyp) 
SELECT konto, ltrim(rtrim(tp)), ltrim(rtrim(tegev)), ltrim(rtrim(allikas)), ltrim(rtrim(rahavoo)), db, kr, rekvid, lcreturn, nimetus, 6
from tmp_saldoandmik
where timestamp = lcReturn;
*/

INSERT INTO tmp_saldoandmik (konto, tp, tegev, allikas, rahavoo, db, kr, rekvid, timestamp, nimetus, tyyp) 
SELECT left(konto,6) as konto, tp, tegev, allikas, rahavoo, db, kr, rekvid, timestamp, nimetus, 70
from tmp_saldoandmik
where ltrim(rtrim(timestamp)) = lcReturn
order by timestamp, REKVID, left(konto,6), tp, tegev, allikas, rahavoo, nimetus;


INSERT INTO tmp_saldoandmik (konto, tp, tegev, allikas, rahavoo, db, kr, rekvid, timestamp, nimetus, tyyp) 
SELECT konto, tp, tegev, allikas, rahavoo, sum(db), sum(kr), rekvid, timestamp, nimetus, 7
from tmp_saldoandmik
where ltrim(rtrim(timestamp)) = lcReturn
and tyyp = 70
group by timestamp, REKVID, konto, tp, tegev, allikas, rahavoo, nimetus
order by timestamp, REKVID, konto, tp, tegev, allikas, rahavoo, nimetus;


--and tyyp = 6

raise notice 'kaibed 5  lopp';

DELETE FROM tmp_saldoandmik WHERE timestamp = lcReturn and rekvid = tnRekvId and tyyp <> 7;

DELETE FROM tmp_saldoandmik WHERE  (ltrim(rtrim(konto)) in ('999999','000000','888888') or (db = 0 and kr= 0)) and rekvid = tnRekvId;


return LCRETURN;
end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_saldoandmik_report(integer, date, integer, integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_saldoandmik_report(integer, date, integer, integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_saldoandmik_report(integer, date, integer, integer, integer) TO dbpeakasutaja;
