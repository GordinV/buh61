-- Function: fnc_avansijaak(integer)

-- DROP FUNCTION fnc_avansijaak(integer);
/*
select *from avans1 where number = '1' and rekvid = 63 and year(kpv) = 2011
select * from avans3 where parentid = 15573

select * from curJournal where id in (3748079, 3258864)

select fnc_avansijaak(avans1.id) from avans1 where year(kpv) = 2011
*/

CREATE OR REPLACE FUNCTION fnc_avansijaak(integer)
  RETURNS numeric AS
$BODY$


declare 
	tnId	ALIAS FOR $1;
	lnTasuSumma numeric(14,2);
	lnSumma numeric(14,2);
	v_avans record;
	lnDokValuuta numeric(14,2);
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

-- tasumine via päevaraamat

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


select sum(summa) into lnSumma from avans2 where parentid = tnId;

update avans1 set jaak = ifnull(lnSumma,0) - ifnull(lnTasuSumma,0)/lnDokValuuta where id = tnId;

RETURN (ifnull(lnSumma,0) - ifnull(lnTasuSumma,0)/lnDokValuuta);


end;




$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION fnc_avansijaak(integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION fnc_avansijaak(integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION fnc_avansijaak(integer) TO dbpeakasutaja;

-- View: curjournal
/*

 SELECT sum(curjournal.summa * curjournal.kuurs) 
   FROM curjournal
   JOIN kassatulud ON ltrim(rtrim(curjournal.kreedit::text)) ~~ ltrim(rtrim(kassatulud.kood::text))
   JOIN kassakontod ON ltrim(rtrim(curjournal.deebet::text)) ~~ ltrim(rtrim(kassakontod.kood::text))
   JOIN rekv ON curjournal.rekvid = rekv.id
where rekvid = 63 and curjournal.kood5 like '352%'
   ;
   
 SELECT sum(curjournal.summa * curjournal.kuurs) 
   FROM curjournal 
where rekvid = 63 and curjournal.kood5 like '352%'
   ;


*/
-- DROP VIEW curjournal;

CREATE OR REPLACE VIEW curjournal AS 
 SELECT journal.id, journal.rekvid, journal.kpv, journal.asutusid, month(journal.kpv) AS kuu, year(journal.kpv) AS aasta, 
 journal.selg::character varying(254) AS selg, journal.dok, journal1.summa, journal1.valsumma, 
 ifnull(dokvaluuta1.valuuta,'EEK')::character varying(20) as valuuta, ifnull(dokvaluuta1.kuurs,1)::numeric(12,6) as kuurs, 
 journal1.kood1, journal1.kood2, journal1.kood3, journal1.kood4, journal1.kood5, journal1.proj, journal1.deebet, journal1.kreedit, 
 journal1.lisa_d, journal1.lisa_k, ifnull(ltrim(rtrim(asutus.nimetus::text))::bpchar + space(1) + ltrim(rtrim(asutus.omvorm::text))::bpchar, space(120)) AS asutus, 
 journal1.tunnus, journalid.number
   FROM journal
   JOIN journal1 ON journal.id = journal1.parentid
   JOIN journalid ON journal.id = journalid.journalid
   LEFT JOIN asutus ON journal.asutusid = asutus.id
   left outer join dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 1);

ALTER TABLE curjournal OWNER TO vlad;
GRANT SELECT ON TABLE curjournal TO dbkasutaja;
GRANT SELECT ON TABLE curjournal TO dbpeakasutaja;
GRANT SELECT ON TABLE curjournal TO dbvaatleja;

-- Function: sp_salvesta_mk1(integer, integer, integer, integer, numeric, character varying, character varying, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying)

/*
select * from palk_config

select sp_salvesta_palk_config(0, 110, 278::numeric, 144::numeric, 0::integer, 0::integer, 1::integer, 0::integer, 
	'EUR':: character varying, 15.6466::numeric) 

	from palk_config 

select * from rekv where id not in (select rekvid from palk_config)

*/
CREATE OR REPLACE FUNCTION sp_salvesta_palk_config(integer, integer, numeric, numeric, integer, integer, integer, integer, character varying, numeric)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnrekvid alias for $2;
	tnMinpalk alias for $3;
	tntulubaas alias for $4;
	tnround alias for $5;
	tnjaak alias for $6;
	tngenlausend alias for $7;
	tnsuurasu alias for $8;
	tcvaluuta alias for $9;
	tnKuurs alias for $10;

	lnId int; 
	lrCurRec record;
	v_dokvaluuta record;
begin

if tnId = 0 then
	-- uus kiri
	insert into palk_config (  rekvid, minpalk, tulubaas, round, jaak, genlausend, suurasu) 
		values (tnrekvid, tnminpalk, tntulubaas, tnround, tnjaak, tngenlausend, tnsuurasu);


	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
		lnId:= cast(CURRVAL('public.palk_config_id_seq') as int4);
	else
		lnId = 0;
	end if;

	if lnId = 0 then
		raise exception 'Viga:%','Ei saa lisada kiri';
	end if;

	-- valuuta

	insert into dokvaluuta1 (dokliik,dokid, valuuta, kuurs) 
		values (26, lnId,tcValuuta, tnKuurs);


else
	-- muuda 
	update palk_config set 
		 rekvid = tnRekvId, 
		 minpalk = tnMinPalk, 
		 tulubaas = tnTulubaas, 
		 round = tnRound, 
		 jaak = tnJaak, 
		 genlausend = tnGenLausend, 
		 suurasu = tnSuurasu
		where id = tnId;

	lnId := tnId;

	-- valuuta
	if (select count(id) from dokvaluuta1 where dokliik = 26 and dokid = lnId) = 0 then

		insert into dokvaluuta1 (dokliik, dokid, valuuta, kuurs) 
			values (26, tnId,tcValuuta, tnKuurs);
	else
		select * into v_dokvaluuta from dokvaluuta1 where dokliik = 26 and dokid = tnId ;

		if tcValuuta <> v_dokvaluuta.valuuta or tnKuurs <> v_dokvaluuta.kuurs then

			update dokvaluuta1 set valuuta = tcValuuta, kuurs = tnKuurs where id = v_dokvaluuta.id;
			
		end if;
	
	end if;

	
end if;


         return  lnId;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_palk_config(integer, integer, numeric, numeric, integer, integer, integer, integer, character varying, numeric) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_palk_config(integer, integer, numeric, numeric, integer, integer, integer, integer, character varying, numeric) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_palk_config(integer, integer, numeric, numeric, integer, integer, integer, integer, character varying, numeric) TO dbpeakasutaja;

-- View: qrykassatulutaitm

 DROP VIEW qrykassatulutaitm;

CREATE OR REPLACE VIEW qrykassatulutaitm AS 
 SELECT curjournal.kpv, curjournal.rekvid, rekv.nimetus, curjournal.tunnus AS tun,  curjournal.summa * curjournal.kuurs::numeric as summa, curjournal.kood5 AS kood, space(1) AS eelarve, curjournal.kood1 AS tegev
   FROM curjournal
   JOIN kassatulud ON ltrim(rtrim(curjournal.kreedit::text)) ~~ ltrim(rtrim(kassatulud.kood::text))
   JOIN kassakontod ON ltrim(rtrim(curjournal.deebet::text)) ~~ ltrim(rtrim(kassakontod.kood::text))
   JOIN rekv ON curjournal.rekvid = rekv.id;

ALTER TABLE qrykassatulutaitm OWNER TO vlad;
GRANT SELECT ON TABLE qrykassatulutaitm TO dbpeakasutaja;
GRANT SELECT ON TABLE qrykassatulutaitm TO dbkasutaja;
GRANT SELECT ON TABLE qrykassatulutaitm TO dbadmin;
GRANT SELECT ON TABLE qrykassatulutaitm TO dbvaatleja;





