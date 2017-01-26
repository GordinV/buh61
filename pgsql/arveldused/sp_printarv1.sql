/*

	select arv.Id, arv.number, arv.asutusId, asutus.regkood, asutus.aadress, objekt.kood, objekt.nimetus, arv.kpv, arv.tahtaeg,
		nom.nimetus, nom.kood, arv1.kogus, arv1.hind, arv1.soodus,  arv1.kbm, arv1.summa, 
		ifnull(dokvaluuta1.valuuta,'EEK'), ifnull(dokvaluuta1.kuurs,1),arv.kbm, arv.summa, 
		arv.jaak,  arv.rekvid
		from arv inner join arv1 on arv.id = arv1.parentid
		inner join asutus on arv.asutusId = asutus.id
		inner join nomenklatuur nom on arv1.nomid = nom.id
		left outer join library objekt on (objekt.kood = arv.objekt and objekt.library = 'OBJEKT')
		left outer join dokvaluuta1 on (arv.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 3)

		select gomonth(date(),11)

select sp_printarv1(489)
		

*/


CREATE OR REPLACE FUNCTION sp_printarv1(integer)
  RETURNS character varying AS
$BODY$
DECLARE tnId alias for $1;
	lcReturn varchar;

	lnAlgSaldo numeric(14,2);
	lntasud numeric (14,2);
	lnViivis numeric (14,2);
	LNcOUNT int;
	v_arv record;
	lcViivis varchar;

	lcKb varchar(20);
	lnSumma numeric(14,2);
	lnPeni numeric(14,2);
	lnkVolg numeric(14,2);
	lnViivisK numeric(14,2);
	ldtasud date;
begin

	select count(*) into lnCount from pg_stat_all_tables where UPPER(relname) = 'TMP_PRINTARV';
	if ifnull(lnCount,0) < 1 then
	
		create table tmp_printarv (arvid integer, number varchar (20), asutusid int, regkood varchar(20), asutus varchar(254), aadress text, 
			objkood varchar(20), objekt varchar(254), arvmuud text, arv1muud text,uhik varchar(20), lisa varchar(254),
			arvkpv date, tahtaeg date, nimetus varchar(254), kood varchar(20), kogus numeric (14,4), hind numeric (14,2), soodus numeric (14,2),
			kb varchar (20), kbm numeric (14,2),summa numeric (14,2),valuuta varchar(20), kuurs numeric(14,4), 
			kbmkokku numeric (14,2), summakokku numeric (14,2), algsaldo numeric (14,2) default 0, 
			tasud numeric (14,2) default 0, vtasud numeric (14,2) default 0,
			jaak numeric (14,2) default 0, viivis numeric (14,2), timestamp varchar(20), kpv date default date(), rekvid int)  ;
		
		GRANT ALL ON TABLE tmp_printarv TO GROUP public;

	else
		delete from tmp_printarv where kpv < date();

	end if;

	lcreturn := to_char(now(), 'YYYYMMDDMISSSS'+ltrim(rtrim(str(tnId))));

	-- arve

	lcKb = '20%';
	lnAlgsaldo = 0;
	lnTasud = 0;
	lnViivis = 0;


	select arv.*, ifnull(dokvaluuta1.valuuta,'EEK')::varchar as valuuta, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs into v_arv 
		from arv left outer join dokvaluuta1 on (arv.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 3)
		where arv.id = tnId;

	-- arvestame algsaldo. See on arvede sum jaak objekti jargi

	select sum(arv.jaak * ifnull(dokvaluuta1.kuurs,1)) into lnAlgsaldo 
		from arv left outer join dokvaluuta1 on (arv.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 3)
		where asutusId = v_arv.asutusId and ifnull(arv.objekt,'null') = ifnull(v_arv.objekt,'null')
		and arv.kpv <= gomonth(v_arv.kpv,-1);

	select sum(arvtasu.summa * ifnull(dokvaluuta1.kuurs,1)) into lnTasud 
		from arvtasu left outer join dokvaluuta1 on (arvtasu.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 21)
		where arvtasu.arvId in (
		select id from arv  where arv.asutusId = v_arv.asutusid and ifnull(arv.objekt,'null') = ifnull(v_arv.objekt,'null')
		 and arv.rekvid = v_arv.rekvId
		)
		and arvtasu.kpv > gomonth(v_arv.kpv,-1) and arvtasu.kpv <= v_arv.kpv;
		
	lnTasud = ifnull(lnTasud,0) / v_arv.kuurs;	
	lnAlgSaldo = ifnull(lnAlgsaldo,0) / v_arv.kuurs;
-- arvestame viivised

--end loop;		
	
		
	lnViivis = ifnull(lnViivis,0) / v_arv.kuurs;	

	insert into tmp_printarv (arvid, number , asutusid , regkood , asutus , aadress, objkood , objekt ,arvkpv , tahtaeg , nimetus, kood ,
			arvmuud, arv1muud, uhik,lisa,
			kogus , hind , soodus ,	kb , kbm ,summa ,valuuta , kuurs , kbmkokku , summakokku , algsaldo , tasud ,jaak , viivis, 
			timestamp , rekvid )

	select arv.Id, arv.number, arv.asutusId, asutus.regkood, asutus.nimetus,  asutus.aadress, objekt.kood, objekt.nimetus, arv.kpv, arv.tahtaeg,
		nom.nimetus, nom.kood, arv.muud, arv1.muud, nom.uhik,arv.lisa,
		arv1.kogus, arv1.hind, arv1.soodus, lcKb, arv1.kbm, arv1.summa, 
		ifnull(dokvaluuta1.valuuta,'EEK'), ifnull(dokvaluuta1.kuurs,1),arv.kbm, arv.summa, lnAlgsaldo, lnTasud,
		arv.jaak, lnViivis, lcReturn, arv.rekvid
		from arv inner join arv1 on arv.id = arv1.parentid
		inner join asutus on arv.asutusId = asutus.id
		inner join nomenklatuur nom on arv1.nomid = nom.id
		left outer join library objekt on (objekt.kood = arv.objekt and objekt.library = 'OBJEKT')
		left outer join dokvaluuta1 on (arv.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 3)
		where arv.id = tnId;
		
	
	return LCRETURN;
end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_printarv1(integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_printarv1(integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_printarv1(integer) TO dbpeakasutaja;
