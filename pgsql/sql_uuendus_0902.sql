-- Function: gen_lausend_koolitus(integer)

-- DROP FUNCTION gen_lausend_koolitus(integer);

CREATE OR REPLACE FUNCTION gen_lausend_koolitus(integer)
  RETURNS integer AS
$BODY$
declare 
	tnId alias for $1;
	lnJournalNumber int4;
	lcDbKonto varchar(20);
	lcKrKonto varchar(20);
	lcTpDb varchar(20);
	lcKrTp varchar(20);
	lnAsutusId int4;
	lnJournalId int4;
	lnJournal1Id int4;	
	lcKbmTp varchar(20);
	v_vanemtasu3 record;
	v_dokprop dokprop%rowtype;
	v_vanemtasu4 record;
	v_asutus asutus%rowtype;
	lnUserId int;
	v_aa record;

	lcValuuta varchar(20);
	lnKuurs numeric(12,4);


begin

	select * into v_vanemtasu3 from vanemtasu3 where id = tnId;
	If v_vanemtasu3.dokpropid = 0 then
		Return 0;
	End if;

	select * into v_dokprop from dokprop where id = v_vanemtasu3.dokpropid limit 1;

	If not Found Or v_dokprop.registr = 0 then
		Return 0;
	End if;

	If v_vanemtasu3.journalid > 0 then
		select number into lnJournalNumber from journalId where journalId = v_vanemtasu3.journalId;
		if sp_del_journal(v_vanemtasu3.journalid,1) = 0 then
			Return 0;
		End if;
	End if;
	select * into v_aa from aa where parentid = v_vanemtasu3.rekvId limit 1;	
	select * into v_asutus from asutus where id = v_dokprop.asutusId;

	lnJournalId:= sp_salvesta_journal(0,v_vanemtasu3.rekvId, v_vanemtasu3.UserId, v_vanemtasu3.kpv, 0, 
		ltrim(rtrim(v_dokprop.selg)), '','AUTOMATSELT LAUSEND (GEN_LAUSEND_KOOLITUS)',v_vanemtasu3.id) ;

	select valuuta, kuurs into lcValuuta, lnKuurs from dokvaluuta1 where dokid in (select id from vanemtasu4 where parentid = tnId order by id limit 1) and dokliik = 16;

	lcValuuta = ifnull(lcValuuta,'EEK');
	lnKuurs = ifnull(lnKuurs,1);

/*
	
		Insert Into journal (rekvid, Userid, kpv, Asutusid, selg, muud) Values 
		(v_vanemtasu3.rekvId, v_vanemtasu3.UserId, v_vanemtasu3.kpv, 0, v_dokprop.selg, 'AUTOMATSELT LAUSEND (GEN_LAUSEND_KOOLITUS)' );

	lnJournalId:= cast(CURRVAL('public.journal_id_seq') as int4);
*/	
	for v_vanemtasu4 in select sum(summa) as summa, konto, kood1, kood2, kood3, kood4, kood5  
		from vanemtasu4 
		where parentid = v_vanemtasu3.Id
		group by konto, kood1, kood2, kood3, kood4, kood5
	loop
		if v_vanemtasu3.opt = 1 then
			-- kassa
			if left(v_vanemtasu3.konto,6) = '100100' then
				-- pank
				lcTpDb = ifnull(v_asutus.tp,v_aa.tp);
			end if;
			if left(v_vanemtasu3.konto,6) = '100000' then
				-- kassa
				lcTpDb = space(1);
			end if;
/*			
			Insert Into journal1 (parentId, Summa, deebet, kreedit, lisa_d, lisa_k, kood1, kood2, 
				kood3, kood4, kood5, tunnus) Values 
				(lnJournalId, v_vanemtasu4.summa, v_vanemtasu3.konto, v_vanemtasu4.konto, lctpDb, '800699', v_vanemtasu4.kood1,
				v_vanemtasu4.kood2, v_vanemtasu4.kood3, v_vanemtasu4.kood4, v_vanemtasu4.kood5, v_vanemtasu3.tunnus );


			if ifnull(lnKontrol,0) = 1 then
				lcViga = sp_lausendikontrol( v_aa.konto, v_korder2.konto, v_aa.tp, v_korder2.tp, v_korder2.kood1, lcAllikas, v_korder2.kood5, v_korder2.kood3);
				if left(ltrim(rtrim(lcViga)),4) = 'Viga' then
					raise exception ':%',lcViga;
				end if;
			end if;
*/
		lnJournal1Id = sp_salvesta_journal1(0,lnJournalId,v_vanemtasu4.summa,''::varchar,''::text,
				v_vanemtasu4.kood1,v_vanemtasu4.kood2,v_vanemtasu4.kood3,v_vanemtasu4.kood4,v_vanemtasu4.kood5,
					v_vanemtasu3.konto,'800699',v_vanemtasu4.konto,'800699',lcvaluuta,lnkuurs,v_vanemtasu4.summa*lnkuurs,
					v_vanemtasu3.tunnus,v_vanemtasu4.proj);
	

	else

			-- fakt

		lnJournal1Id = sp_salvesta_journal1(0,lnJournalId,v_vanemtasu4.summa,''::varchar,''::text,
				v_vanemtasu4.kood1,v_vanemtasu4.kood2,v_vanemtasu4.kood3,v_vanemtasu4.kood4,v_vanemtasu4.kood5,
					v_vanemtasu3.konto,'800699',v_vanemtasu4.konto,'800699',lcvaluuta,lnkuurs,v_vanemtasu4.summa*lnkuurs,
					v_vanemtasu3.tunnus,v_vanemtasu4.proj);
/*
			Insert Into journal1 (parentId, Summa, deebet, kreedit, lisa_d, lisa_k, kood1, kood2, 
				kood3, kood4, kood5, tunnus) Values 
				(lnJournalId, v_vanemtasu4.summa, v_vanemtasu3.konto, v_vanemtasu4.konto,'800699' , '800699', v_vanemtasu4.kood1,
				v_vanemtasu4.kood2, v_vanemtasu4.kood3, v_vanemtasu4.kood4, v_vanemtasu4.kood5, v_vanemtasu3.tunnus );
*/
	end if;

	End loop;
	If v_vanemtasu3.journalid > 0 then
		update journalid set number = lnJournalNumber where journalid = lnJournalId;
	end if;
	return lnJournalId;
end;





$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION gen_lausend_koolitus(integer) OWNER TO vladislav;
GRANT EXECUTE ON FUNCTION gen_lausend_koolitus(integer) TO vladislav;
GRANT EXECUTE ON FUNCTION gen_lausend_koolitus(integer) TO public;
GRANT EXECUTE ON FUNCTION gen_lausend_koolitus(integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION gen_lausend_koolitus(integer) TO dbpeakasutaja;
-- Database: avpsoft

-- Function: sp_vanemtasu_aruanne1(integer, character varying, date, date, character, character)
/*
select sp_vanemtasu_aruanne1(1, '%', date(2011,02,01), date(2011,02,28), '%', '%')

delete from TMP_VANEMTASU1

select * from TMP_VANEMTASU1

SELECT * FROM  tmp_vanemtasu1  where timestamp = '201102095679017' Order By  TUNNUS, GRUPP, nimi, ISIKKOOD
*/


-- DROP FUNCTION sp_vanemtasu_aruanne1(integer, character varying, date, date, character, character);

CREATE OR REPLACE FUNCTION sp_vanemtasu_aruanne1(integer, character varying, date, date, character, character)
  RETURNS character varying AS
$BODY$
DECLARE tnrekvid alias for $1;
	tcTunnus alias for $2;
	tdKpv1 alias for $3;
	tdKpv2 alias for $4;
	tcgrupp alias for $5;
	tcKonto alias for $6;
	lcReturn varchar;
	lcString varchar;
	lcPnimi varchar;
	lnAlg numeric(14,2);
	lnLopp numeric (14,2);
	LNcOUNT int;
	v_isikud record;
begin



	select count(*) into lnCount from pg_stat_all_tables where UPPER(relname) = 'TMP_VANEMTASU1';
	if ifnull(lnCount,0) < 1 then
	
		create table tmp_vanemtasu1 (isikid int, isikkood varchar(20), nimi varchar(254), tunnus varchar(20), grupp varchar(40),
			nimetus varchar(254), kood varchar(20), kpv1 date, kpv2 date, algsaldo numeric (14,2) default 0, arv numeric (14,2) default 0, 
			tasu numeric (14,2) default 0, jaak numeric (14,2) default 0, timestamp varchar(20), kpv date default date(), rekvid int)  ;
		
		GRANT ALL ON TABLE tmp_vanemtasu1 TO GROUP public;

	else
		delete from tmp_vanemtasu1 where kpv < date() and rekvid = tnrekvId;

	end if;

	lcreturn := to_char(now(), 'YYYYMMDDMISSSS');

	-- laste list

	insert into tmp_vanemtasu1 (isikid, isikkood, nimi , tunnus , grupp, kpv1 , kpv2, timestamp, rekvid  )
	select vanemtasu1.id, vanemtasu1.isikkood, vanemtasu1.nimi, vanemtasu2.tunnus, vanemtasu2.grupp, tdKpv1, 
	tdKpv2, lcreturn, tnrekvid from vanemtasu1 inner join vanemtasu2 on vanemtasu1.id = vanemtasu2.isikid 
	where vanemtasu2.rekvid = tnrekvid and upper(vanemtasu2.tunnus) like upper(tcTunnus) and loppkpv >= tdKpv1 and upper(vanemtasu2.grupp) like upper(tcGrupp);


	-- algsaldo

	for v_isikud  in 

		SELECT   sum( CASE WHEN vanemtasu3.opt = 1 THEN (vanemtasu4.summa * ifnull(dokvaluuta1.kuurs,1)) ELSE 0::numeric END) AS kassa, 
		 sum( CASE WHEN vanemtasu3.opt = 2 THEN (vanemtasu4.summa * ifnull(dokvaluuta1.kuurs,1)) ELSE 0::numeric END) AS fakt, 
		vanemtasu3.tunnus, vanemtasu4.isikId
		FROM vanemtasu3 INNER JOIN vanemtasu4 ON vanemtasu3.id = vanemtasu4.parentid
		left outer join dokvaluuta1 on (vanemtasu4.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 16)
		WHERE vanemtasu3.rekvId = tnrekvId
		and upper(vanemtasu3.tunnus) like upper(tcTunnus)
		and vanemtasu4.konto like tcKonto
		and vanemtasu3.kpv < tdKpv1
		and vanemtasu4.isikid in (select distinct isikId from vanemtasu2 where rekvid = tnRekvId and upper(grupp) like upper(tcGrupp))
		GROUP BY vanemtasu3.tunnus, vanemtasu4.isikId

	loop

		UPDATE tmp_vanemtasu1 SET algsaldo = v_isikud.fakt - v_isikud.kassa 
			WHERE isikId = v_isikud.isikId AND tunnus = v_isikud.tunnus;


	END loop;

	-- arv

	for v_isikud  in 

		SELECT   sum( vanemtasu4.summa * ifnull(dokvaluuta1.kuurs,1) ) AS fakt, 
		vanemtasu3.tunnus, vanemtasu4.isikId
		FROM vanemtasu3 INNER JOIN vanemtasu4 ON vanemtasu3.id = vanemtasu4.parentid
		left outer join dokvaluuta1 on (vanemtasu4.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 16)
		WHERE vanemtasu3.rekvId = tnrekvId
		and upper(vanemtasu3.tunnus) like upper(tcTunnus)
		and vanemtasu3.kpv >= tdKpv1
		and vanemtasu3.kpv <= tdKpv2
		and vanemtasu4.konto like tcKonto
		and vanemtasu3.opt = 2
		and vanemtasu4.isikId in (select distinct isikId from vanemtasu2 where rekvid = tnRekvId and upper(grupp) like upper(tcGrupp))
		GROUP BY vanemtasu3.tunnus, vanemtasu4.isikId

	loop

		UPDATE tmp_vanemtasu1 SET arv = v_isikud.fakt  
			WHERE isikId = v_isikud.isikId AND tunnus = v_isikud.tunnus;


	END loop;

	-- tasu

	for v_isikud  in 

		SELECT   sum( vanemtasu4.summa * ifnull(dokvaluuta1.kuurs,1)) AS kassa, 
		vanemtasu3.tunnus, vanemtasu4.isikId
		FROM vanemtasu3 INNER JOIN vanemtasu4 ON vanemtasu3.id = vanemtasu4.parentid
		left outer join dokvaluuta1 on (vanemtasu4.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 16)
		WHERE vanemtasu3.rekvId = tnrekvId
		and upper(vanemtasu3.tunnus) like upper(tcTunnus)
		and vanemtasu3.kpv >= tdKpv1
		and vanemtasu3.kpv <= tdKpv2
		and vanemtasu4.konto like tcKonto
		and vanemtasu4.isikId in (select distinct isikId from vanemtasu2 where rekvid = tnRekvId and upper(grupp) like upper(tcGrupp))
		and vanemtasu3.opt = 1
		
		GROUP BY vanemtasu3.tunnus, vanemtasu4.isikId

	loop

		UPDATE tmp_vanemtasu1 SET tasu = v_isikud.kassa  
			WHERE isikId = v_isikud.isikId AND tunnus = v_isikud.tunnus;


	END loop;

	delete from tmp_vanemtasu1 where algsaldo = 0 and arv = 0 and tasu = 0 and timestamp = LCRETURN;

	return LCRETURN;
end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_vanemtasu_aruanne1(integer, character varying, date, date, character, character) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_vanemtasu_aruanne1(integer, character varying, date, date, character, character) TO vlad;
GRANT EXECUTE ON FUNCTION sp_vanemtasu_aruanne1(integer, character varying, date, date, character, character) TO public;
GRANT EXECUTE ON FUNCTION sp_vanemtasu_aruanne1(integer, character varying, date, date, character, character) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_vanemtasu_aruanne1(integer, character varying, date, date, character, character) TO dbpeakasutaja;

-- Function: sp_vanemtasu_aruanne2(integer, character varying, character varying, character varying, date, date, character varying)

-- DROP FUNCTION sp_vanemtasu_aruanne2(integer, character varying, character varying, character varying, date, date, character varying);

CREATE OR REPLACE FUNCTION sp_vanemtasu_aruanne2(integer, character varying, character varying, character varying, date, date, character varying)
  RETURNS character varying AS
$BODY$DECLARE tnrekvid alias for $1;

	tcTunnus alias for $2;

	tcIsikkood alias for $3;

	tcIsiknimi alias for $4;

	tdKpv1 alias for $5;

	tdKpv2 alias for $6;

	tcGrupp alias for $7;

	lcReturn varchar;

	lcString varchar;

	lcPnimi varchar;

	lnAlg numeric(14,2);

	lnLopp numeric (14,2);

	LNcOUNT int;

	v_isikud record;

	v_arved record;

	v_vanemsaldo record;

	v_tasud record;

begin

	select count(*) into lnCount from pg_stat_all_tables where UPPER(relname) = 'TMP_VANEMTASU2';
	if ifnull(lnCount,0) < 1 then
	raise notice ' lisamine  ';

		create table tmp_vanemtasu2 (number varchar(20), dokkpv date, isikid int, isikkood varchar(20), nimi varchar(254), vanemkood varchar(20), vanemnimi varchar(254),
			aadress text, tunnus varchar(20), grupp varchar(40),
			nimetus varchar(254), kood varchar(20), hind numeric (14,2) default 0, kogus numeric (14,4) default 0, 
			summa numeric (14,2) default 0, 
			opt int default 1, algjaak numeric (14,2), tasud numeric (14,2) default 0,
			timestamp varchar(20), kpv date default date(), rekvid int)  ;

		GRANT ALL ON TABLE tmp_vanemtasu2 TO GROUP public;
	else
		delete from tmp_vanemtasu2 where kpv < date() and rekvid = tnrekvId;
	end if;
	lcreturn := to_char(now(), 'YYYYMMDDMISSSS');

	-- arved list


	raise notice ' list  ';

	insert into tmp_vanemtasu2 (number, dokkpv, isikid, isikkood, nimi, vanemkood, vanemnimi,
			aadress, tunnus, grupp,	nimetus, kood, hind, kogus, summa, opt, timestamp, rekvid  )
	select vanemtasu4.number, vanemtasu3.kpv, vanemtasu1.id, vanemtasu1.isikkood, vanemtasu1.nimi, 
		vanemtasu1.vanemkood, vanemtasu1.vanemnimi,
		vanemtasu1.aadress, vanemtasu2.tunnus, vanemtasu2.grupp, 
		nomenklatuur.nimetus, nomenklatuur.kood, (vanemtasu4.hind*ifnull(dokvaluuta1.kuurs,1))::numeric, vanemtasu4.kogus, 
		(vanemtasu4.summa * ifnull(dokvaluuta1.kuurs,1))::numeric, 1,
		 lcreturn, tnrekvid 
	from vanemtasu1 inner join vanemtasu2 on vanemtasu1.id = vanemtasu2.isikid 
		inner join vanemtasu4 on vanemtasu4.isikId = vanemtasu1.id
		inner join vanemtasu3 on (vanemtasu3.Id = vanemtasu4.parentid and vanemtasu3.tunnus = vanemtasu2.tunnus)
		inner join nomenklatuur on vanemtasu4.nomId = nomenklatuur.id
		left outer join dokvaluuta1 on (vanemtasu4.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 16)
	where upper(vanemtasu2.tunnus) like upper(tcTunnus) 
		and vanemtasu3.kpv >= tdKpv1
		and vanemtasu3.kpv <= tdKpv2
		and upper(vanemtasu1.isikkood) like upper(tcisikkood)
		and upper(vanemtasu1.nimi) like upper(tcisiknimi)
		and vanemtasu2.rekvid = tnrekvid
		and upper(vanemtasu2.grupp) like upper(tcgrupp)
		and vanemtasu3.opt = 2;

	raise notice ' list ready ';

	-- algsaldo
	for v_arved in 
		select distinct dokkpv, isikId, number, tunnus from tmp_vanemtasu2 where timestamp = lcreturn
	loop
		SELECT   sum( CASE WHEN vanemtasu3.opt = 1 THEN (vanemtasu4.summa * ifnull(dokvaluuta1.kuurs,1)) ELSE 0::numeric END) AS kassa, 
		 sum( CASE WHEN vanemtasu3.opt = 2 THEN (vanemtasu4.summa * ifnull(dokvaluuta1.kuurs,1)) ELSE 0::numeric END) AS fakt 
		into v_vanemsaldo
		FROM vanemtasu3 INNER JOIN vanemtasu4 ON vanemtasu3.id = vanemtasu4.parentid
		left outer join dokvaluuta1 on (vanemtasu4.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 16) 
		WHERE vanemtasu3.rekvId = tnrekvId
		and vanemtasu3.kpv < v_arved.dokkpv
		and vanemtasu4.isikId = v_arved.isikId;


	raise notice ' jaak fakt%',v_vanemsaldo.fakt ;
	raise notice ' jaak kassa%',v_vanemsaldo.kassa ;

	v_vanemsaldo.fakt:= ifnull(v_vanemsaldo.fakt,0);
	v_vanemsaldo.kassa:= ifnull(v_vanemsaldo.kassa,0) ;

		update tmp_vanemtasu2 set algjaak = v_vanemsaldo.fakt - v_vanemsaldo.kassa 
			where number = v_arved.number 
			and isikId = v_arved.isikId
			and timestamp = lcreturn;

	--	tasu

		SELECT   sum(vanemtasu4.summa * ifnull(dokvaluuta1.kuurs,1)) as summa into v_tasud
		FROM vanemtasu3 INNER JOIN vanemtasu4 ON vanemtasu3.id = vanemtasu4.parentid
		left outer join dokvaluuta1 on (vanemtasu4.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 16)
		WHERE vanemtasu3.rekvId = tnrekvId
		and vanemtasu3.tunnus = v_arved.tunnus
		and vanemtasu4.isikId = v_arved.isikid
		and month(vanemtasu3.kpv) = month(v_arved.dokkpv) - 1
		and vanemtasu3.opt = 1;

		UPDATE tmp_vanemtasu2 SET tasud = ifnull(v_tasud.summa ,0) 
			WHERE isikId = v_arved.isikId 
			AND tunnus = v_arved.tunnus 
			and number = v_arved.number 
			and dokkpv = v_arved.dokkpv
			and timestamp = lcreturn;


	end loop;
	raise notice ' lopp';
	return LCRETURN;

end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_vanemtasu_aruanne2(integer, character varying, character varying, character varying, date, date, character varying) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_vanemtasu_aruanne2(integer, character varying, character varying, character varying, date, date, character varying) TO vlad;
GRANT EXECUTE ON FUNCTION sp_vanemtasu_aruanne2(integer, character varying, character varying, character varying, date, date, character varying) TO public;
GRANT EXECUTE ON FUNCTION sp_vanemtasu_aruanne2(integer, character varying, character varying, character varying, date, date, character varying) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_vanemtasu_aruanne2(integer, character varying, character varying, character varying, date, date, character varying) TO dbpeakasutaja;

-- Function: sp_vanemtasu_aruanne3(integer, character varying, character varying, character varying, character varying, character varying, date, date, integer, character varying, character varying)

-- DROP FUNCTION sp_vanemtasu_aruanne3(integer, character varying, character varying, character varying, character varying, character varying, date, date, integer, character varying, character varying);

CREATE OR REPLACE FUNCTION sp_vanemtasu_aruanne3(integer, character varying, character varying, character varying, character varying, character varying, date, date, integer, character varying, character varying)
  RETURNS character varying AS
$BODY$DECLARE tnrekvid alias for $1;
	tcTunnus alias for $2;
	tcIsikkood alias for $3;
	tcIsiknimi alias for $4;
	tcVanemkood alias for $5;
	tcVanemnimi alias for $6;
	tdKpv1 alias for $7;
	tdKpv2 alias for $8;
	tnOpt alias for $9;
	tcGrupp alias for $10;
	tcKonto alias for $11;
	lcReturn varchar;
	lcString varchar;
	LNcOUNT int;
begin



	select count(*) into lnCount from pg_stat_all_tables where UPPER(relname) = 'TMP_VANEMTASU3';

	if ifnull(lnCount,0) < 1 then

	raise notice ' lisamine  ';
	
		create table tmp_vanemtasu3 (number varchar(20), dokkpv date, isikid int, isikkood varchar(20), nimi varchar(254), vanemkood varchar(20), vanemnimi varchar(254),
			aadress text, tunnus varchar(20), grupp varchar(40),
			nimetus varchar(254) default space(254), kood varchar(20) default space(20) , hind numeric (14,2) default 0, kogus numeric (14,4) default 0, 
			deebet numeric (14,2) default 0, kreedit numeric (14,2) default 0 , lausend int default 0,
			opt int default 1, algjaak numeric (14,2) default 0, tasud numeric (14,2) default 0, korkonto varchar(20) default space(20),
			konto varchar(20) default space(20), kood1 varchar(20) default space(20), kood2 varchar(20) default space(20),
			kood3 varchar(20) default space(20), kood4 varchar(20) default space(20), kood5 varchar(20) default space(20),
			timestamp varchar(20), kpv date default date(), rekvid int)  ;
		
		GRANT ALL ON TABLE tmp_vanemtasu3 TO GROUP public;

	else
		delete from tmp_vanemtasu3 where kpv < date() and rekvid = tnrekvId;

	end if;

	lcreturn := ltrim(rtrim(str(tnRekvid)))+to_char(now(), 'YYYYMMDDMISSSS');

	-- arved list

	raise notice ' list  ';

	insert into tmp_vanemtasu3 (number, dokkpv, isikid, isikkood, nimi, vanemkood, vanemnimi,
			aadress, tunnus, grupp,	nimetus, hind, kogus, deebet, kreedit, opt, timestamp, rekvid, 
			korkonto, konto, kood1, kood2, kood3, kood4, kood5, lausend )

	select vanemtasu4.number, vanemtasu3.kpv, vanemtasu1.id, vanemtasu1.isikkood, vanemtasu1.nimi, 
		vanemtasu4.maksjakood, vanemtasu4.maksjanimi,
		vanemtasu1.aadress, vanemtasu2.tunnus, vanemtasu2.grupp,
		case when vanemtasu3.opt = 1 then 'tasu' else nomenklatuur.nimetus end, 
		vanemtasu4.hind, vanemtasu4.kogus, 
		case when vanemtasu3.opt = 1 then (vanemtasu4.summa * ifnull(dokvaluuta1.kuurs,1)) else 0:: numeric(12,4) end, 
		case when vanemtasu3.opt = 2 then (vanemtasu4.summa * ifnull(dokvaluuta1.kuurs,1)) else 0:: numeric(12,4) end, 
		tnOpt, 	 lcreturn, tnrekvid ,
		vanemtasu3.konto, vanemtasu4.konto, vanemtasu4.kood1, vanemtasu4.kood2, vanemtasu4.kood3, vanemtasu4.kood4, 
		vanemtasu4.kood5, ifnull(journalid.number,0) 
	from vanemtasu1 inner join vanemtasu2 on vanemtasu1.id = vanemtasu2.isikid 
		inner join vanemtasu4 on vanemtasu4.isikId = vanemtasu1.id
		inner join vanemtasu3 on (vanemtasu3.Id = vanemtasu4.parentid and vanemtasu3.tunnus = vanemtasu2.tunnus)
		left outer join nomenklatuur on (vanemtasu4.nomId = nomenklatuur.id and nomenklatuur.rekvid = tnRekvId)
		left outer join journalid on vanemtasu3.journalid = journalid.journalid
		left outer join dokvaluuta1 on (vanemtasu4.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 16)
	where upper(vanemtasu2.tunnus) like upper(tcTunnus) 
		and vanemtasu3.kpv >= tdKpv1
		and vanemtasu3.kpv <= tdKpv2
		and vanemtasu4.konto like tcKonto
		and upper(vanemtasu1.isikkood) like upper(tcisikkood)
		and upper(vanemtasu1.nimi) like upper(tcisiknimi)
		and upper(vanemtasu4.maksjakood) like upper(tcVanemkood)
		and upper(vanemtasu4.maksjanimi) like upper(tcVanemnimi)
		and upper(vanemtasu2.grupp) like upper(tcGrupp)
		and vanemtasu3.rekvid = tnrekvid;



	raise notice ' list ready ';


	raise notice ' lopp';

	return LCRETURN;
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_vanemtasu_aruanne3(integer, character varying, character varying, character varying, character varying, character varying, date, date, integer, character varying, character varying) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_vanemtasu_aruanne3(integer, character varying, character varying, character varying, character varying, character varying, date, date, integer, character varying, character varying) TO vlad;
GRANT EXECUTE ON FUNCTION sp_vanemtasu_aruanne3(integer, character varying, character varying, character varying, character varying, character varying, date, date, integer, character varying, character varying) TO public;
GRANT EXECUTE ON FUNCTION sp_vanemtasu_aruanne3(integer, character varying, character varying, character varying, character varying, character varying, date, date, integer, character varying, character varying) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_vanemtasu_aruanne3(integer, character varying, character varying, character varying, character varying, character varying, date, date, integer, character varying, character varying) TO dbpeakasutaja;

-- Function: sp_vanemtasu_aruanne4(integer, character varying, character varying, date, date)

-- DROP FUNCTION sp_vanemtasu_aruanne4(integer, character varying, character varying, date, date);

CREATE OR REPLACE FUNCTION sp_vanemtasu_aruanne4(integer, character varying, character varying, date, date)
  RETURNS character varying AS
$BODY$DECLARE tnrekvid alias for $1;
	tcTunnus alias for $2;
	tcgrupp alias for $3;
	tdKpv1 alias for $4;
	tdKpv2 alias for $5;
	lcReturn varchar;
	lcString varchar;
	LNcOUNT int;
begin



	select count(*) into lnCount from pg_stat_all_tables where UPPER(relname) = 'TMP_VANEMTASU4';

	if ifnull(lnCount,0) < 1 then

	raise notice ' lisamine  ';
	
		create table tmp_vanemtasu4 (tunnus varchar(20), grupp varchar(40),
			nimetus varchar(254) default space(254), kood varchar(20) default space(20) , 
			hind numeric (14,2) default 0, kogus numeric (14,4) default 0, 
			deebet numeric (14,2) default 0, kreedit numeric (14,2) default 0 ,  
			tasud numeric (14,2) default 0, korkonto varchar(20) default space(20),
			konto varchar(20) default space(20), kood1 varchar(20) default space(20), kood2 varchar(20) default space(20),
			kood3 varchar(20) default space(20), kood4 varchar(20) default space(20), kood5 varchar(20) default space(20),
			timestamp varchar(20), kpv date default date(), rekvid int)  ;
		
		GRANT ALL ON TABLE tmp_vanemtasu4 TO GROUP public;

	else
		delete from tmp_vanemtasu4 where kpv < date() and rekvid = tnrekvId;

	end if;

	lcreturn := ltrim(rtrim(str(tnRekvid)))+to_char(now(), 'YYYYMMDDMISSSS');

	-- arved list

	raise notice ' Asutuste nimekirje ja gruppid iga toodele   ';

	insert into tmp_vanemtasu4 (tunnus, grupp, nimetus, kogus, deebet, kreedit, timestamp, rekvid)

select tunnus, grupp, nimetus, sum(kogus) as kogus,sum(deebet), sum(kreedit), lcreturn, tnrekvid
from ( 
	select  vanemtasu2.tunnus, vanemtasu2.grupp,
		case when vanemtasu3.opt = 1 then 'tasu' else nomenklatuur.nimetus end, 
		 vanemtasu4.kogus, 
		case when vanemtasu3.opt = 1 then (vanemtasu4.summa * ifnull(dokvaluuta1.kuurs,1)) else 0:: numeric(12,4) end as deebet, 
		case when vanemtasu3.opt = 2 then (vanemtasu4.summa * ifnull(dokvaluuta1.kuurs,1)) else 0:: numeric(12,4) end as kreedit
		
	from vanemtasu1 inner join vanemtasu2 on vanemtasu1.id = vanemtasu2.isikid 
		inner join vanemtasu4 on vanemtasu4.isikId = vanemtasu1.id
		inner join vanemtasu3 on (vanemtasu3.Id = vanemtasu4.parentid and vanemtasu3.tunnus = vanemtasu2.tunnus)
		left outer join nomenklatuur on (vanemtasu4.nomId = nomenklatuur.id and nomenklatuur.rekvid = tnrekvid)
		left outer join journalid on vanemtasu3.journalid = journalid.journalid
		left outer join dokvaluuta1 on (vanemtasu4.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 16)
	where upper(vanemtasu2.tunnus) like upper(tcTunnus) 
		and upper(vanemtasu2.grupp) like upper(tcGrupp) 
		and vanemtasu3.kpv >= tdKpv1
		and vanemtasu3.kpv <= tdKpv2
		and vanemtasu3.rekvid = tnrekvid
) vkaibed group by tunnus, grupp, nimetus;



	return LCRETURN;
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_vanemtasu_aruanne4(integer, character varying, character varying, date, date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_vanemtasu_aruanne4(integer, character varying, character varying, date, date) TO vlad;
GRANT EXECUTE ON FUNCTION sp_vanemtasu_aruanne4(integer, character varying, character varying, date, date) TO public;
GRANT EXECUTE ON FUNCTION sp_vanemtasu_aruanne4(integer, character varying, character varying, date, date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_vanemtasu_aruanne4(integer, character varying, character varying, date, date) TO dbpeakasutaja;

-- Function: sp_saldoandmik_aruanned(integer, date, integer, integer, integer, integer)
/*
select sp_saldoandmik_aruanned(10, date(2010,12,31), 2010, 3, 0, 0)

*/
-- DROP FUNCTION sp_saldoandmik_aruanned(integer, date, integer, integer, integer, integer);

CREATE OR REPLACE FUNCTION sp_saldoandmik_aruanned(integer, date, integer, integer, integer, integer)
  RETURNS character varying AS
$BODY$
DECLARE tnRekvId alias for $1;
	tdKpv alias for $2;
	tnAasta alias for $3;
	tnLiik alias for $4; 
	tnTyyp alias for $5;
	tnSvod alias for $6;

	lnTase integer;
	lcReturn varchar;
	lcString varchar;
	lcOmaTp varchar;
	cOmaTp varchar;
	v_rekv record;
	v_tp record;
	v_omatp record;
	v_saldo record;
	lnRekvId integer;
	lnDeebet numeric(14,2);
	lnKreedit numeric(14,2);

	lnDb2 numeric(14,2);
	lnDb3 numeric(14,2);
	lnDb31 numeric(14,2);
	lnDb7 numeric(14,2);
	lnDb2035 numeric(14,2);
	lnKr2 numeric(14,2);
	lnKr3 numeric(14,2);
	lnKr31 numeric(14,2);
	lnKr7 numeric(14,2);
	lnKr2035 numeric(14,2);

	lnTulemus integer;


begin


lnTulemus = 0;
--tnSvod = 1;

if (select count(*) from pg_stat_all_tables where UPPER(relname) = 'TMP_SK_ARUANNED')  < 1 then
	
	CREATE TABLE tmp_sk_aruanned
	(
	id serial NOT NULL,
	nimetus character varying(254) NOT NULL DEFAULT space(1),
	summa01 numeric(14,2) NOT NULL DEFAULT 0,
	summa02 numeric(14,2) NOT NULL DEFAULT 0,
	summa03 numeric(14,2) NOT NULL DEFAULT 0,
	summa04 numeric(14,2) NOT NULL DEFAULT 0,
	summa05 numeric(14,2) NOT NULL DEFAULT 0,
	summa06 numeric(14,2) NOT NULL DEFAULT 0,
	summa07 numeric(14,2) NOT NULL DEFAULT 0,
	summa08 numeric(14,2) NOT NULL DEFAULT 0,
	summa09 numeric(14,2) NOT NULL DEFAULT 0,
	summa10 numeric(14,2) NOT NULL DEFAULT 0,
	summa11 numeric(14,2) NOT NULL DEFAULT 0,
	summa12 numeric(14,2) NOT NULL DEFAULT 0,
	summa13 numeric(14,2) NOT NULL DEFAULT 0,
	summa14 numeric(14,2) NOT NULL DEFAULT 0,
	summa15 numeric(14,2) NOT NULL DEFAULT 0,
	konto character varying(20) NOT NULL DEFAULT space(1),
	tegev character varying(20) NOT NULL DEFAULT space(1),
	tp character varying(20) NOT NULL DEFAULT space(1),
	allikas character varying(20) NOT NULL DEFAULT space(1),
	rahavoo character varying(20) NOT NULL DEFAULT space(1),
	kpv date DEFAULT date(),
	rekvid integer,
	timestamp varchar(20) not null,
	omatp character varying(20) NOT NULL DEFAULT space(1),
	tyyp integer DEFAULT 0
	) ;

	ALTER TABLE tmp_sk_aruanned OWNER TO vlad;

	GRANT ALL ON TABLE tmp_sk_aruanned TO GROUP public;
	GRANT ALL ON TABLE tmp_sk_aruanned_id_seq TO public;
		

end if;

delete from tmp_sk_aruanned where kpv < date() and rekvid = tnrekvId;

lnRekvId = tnRekvId;

if tnSvod = 1 then
	lnTase = 3;

--	if tnrekvId = 63 then 
		lnRekvId = 0;
--	end if;

else
	lnTase = 9;
end if;


-- otsime oma TP kood

/*
SELECT TP INTO lcOmaTp FROM Aa WHERE Aa.parentid = tnRekvId   AND Aa.kassa = 2 ORDER BY ID DESC LIMIT 1;
lcOmaTp = ifnull(lcOmaTp,'');
*/
lcOmaTp = ltrim(rtrim(fnc_getomatp(tnrekvid,tnAasta)));		
raise notice 'Oma tp: %',lcOmaTp;

-- kpv kontroll

if tnTyyp = 1 or (select count(*) from saldoandmik where aasta = year(tdKpv) and kuu = month(tdKpv) and rekvid = tnrekvId and kpv = tdKpv) = 0 then
	-- re-arvesta saldoandmik
	raise notice 'Arvestame saldoandmik.. ';
	lnTulemus =  sp_koosta_saldoandmik(tnrekvId, tdKpv, 1, 1);

	if tnSvod = 1 and tnRekvId = 63 then
		perform sp_saldoandmik_aruanned(tnRekvid, tdKpv, year(tdKpv), 2, 0, 1);
	end if;
	raise notice 'Arvestame saldoandmik, tulemus: %',lnTulemus;
end if;

lcreturn := ltrim(rtrim(str(tnrekvId)))+to_char(now(), 'YYYYMMDDMISSSS');

if tnLiik = 5 then
-- Kond rahavoog

	raise notice 'Rahavoog';
	raise notice 'Arvestan..';

	lnDb3 = 12;
	lnDb2 = year(tdKpv) - 1;

	raise notice 'Eelmine aasta..%',lnDb2;
	if tnrekvId = 63 and tnSvod = 1 then
		lnRekvId = 999;
	end if;

	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1','Aruandeperioodi tegevustulem',ifnull(sum(kr),0) - ifnull(sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and val(left(ltrim(rtrim(saldoandmik.konto)),1)) >= 3 and val(left(ltrim(rtrim(saldoandmik.konto)),2)) <= 64;

--Jooksva per Saldoandmikust (Sum: Kontod 61* deebet) - (Sum: Kontod 61* Kreedit)

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '2','  Pхhivara amortisatsioon ja ьmberhindlus',ifnull(sum(db),0) - ifnull(sum(kr),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and val(left(ltrim(rtrim(saldoandmik.konto)),2)) = 61;

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '2','  Saadud sihtfinantseerimine pхhivara soetuseks',ifnull(sum(db),0) - ifnull(sum(kr),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) in ('350200','350220','350240');

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '2','  Saadud sihtfinantseerimise amortisatsioon ',ifnull(sum(db),0) - ifnull(sum(kr),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and val(left(ltrim(rtrim(saldoandmik.konto)),3)) = 351;

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '2','  Saadud liitumistasude amortisatsioon ',ifnull(sum(db),0) - ifnull(sum(kr),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and val(left(ltrim(rtrim(saldoandmik.konto)),6)) = 323880;

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '2','  Kasum/kahjum pohivara muugist ',ifnull(sum(db),0) - ifnull(sum(kr),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and val(left(ltrim(rtrim(saldoandmik.konto)),4)) in (3810,3811,3813,3814);
			
	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '2','  Ule antud mitterahaline sihtfinantseerimine ',ifnull(sum(kr),0) - ifnull(sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and val(left(ltrim(rtrim(saldoandmik.konto)),1)) = 1
			and rahavoo = '24';

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '2','  Ebatoenaoliselt laekuvate laenude muutus',ifnull(sum(db),0) - ifnull(sum(kr),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and val(left(ltrim(rtrim(saldoandmik.konto)),6)) in (605000,605010,605020);

--= aruandeper tegevustulem + korrigeerimised

	select sum(summa01) into lnDeebet from tmp_sk_aruanned where timestamp = lcReturn and ltrim(rtrim(konto)) = '1';
	lnDeebet = ifnull(lnDeebet,0);

	select sum(summa01) into lnKreedit from tmp_sk_aruanned where timestamp = lcReturn and ltrim(rtrim(konto)) = '2';
	lnKreedit = ifnull(lnKreedit,0);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
		('3','Korrigeeritud tegevustulem',lnDeebet + lnKreedit,tdKpv, tnRekvId,lcReturn, 0) ;

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('40','Pхhitegevusega seotud kдibevarade netomuutus',0,tdKpv, tnRekvId,lcReturn, 0 );


--(Eelmise aruandeper saldoandmikust (sum: kontod 102* deebet + kontod 152* deebet) - (sum kontod 102* kreedit+ kontod 152* kreedit)) - (Jooksva per saldoandmikust (sum kontod 102* deebet+ kontod 152* deebet) - (sum kontod 102* kreedit + kontod 152* kreedit))

			select ifnull(sum(db),0) - ifnull(sum(kr),0) into lnDeebet 
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),3)) in ('102','152');		
			
			select ifnull(sum(db),0) - ifnull(sum(kr),0) into lnKreedit
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),3) in ('102','152');

			lnKreedit = ifnull(lnKreedit,0);
			raise notice 'lnKreedit %',lnKreedit;
			lnDeebet = ifnull(lnDeebet,0);
			raise notice 'lnDeebet %',lnDeebet;

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('4','  Maksu-, lхivu- ja trahvinхuete muutus',lnKreedit - lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
--(Eelmise aruandeper saldoandmikust (sum: kontod 10300* deebet + kontod 15300* deebet) - (sum kontod 10300* kreedit + kontod 15300* kreedit)) - (Jooksva per saldoandmikust (sum kontod 10300* deebet + kontod 15300* deebet) - (sum kontod 10300* kreedit + kontod 15300* kreedit))
			select ifnull(sum(db) - sum(kr),0) into lnDeebet 
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),5)) in ('10300','15300');		
			
			select ifnull(sum(db) - sum(kr),0) into lnKreedit
			from saldoandmik
			where  aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),5)) in ('10300','15300');		

			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('4','  Muutus nхuetes ostjate vastu',lnKreedit - lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
--(Eelmise aruandeper saldoandmikust (sum: kontod 103190 deebet) - (sum kontod 103190 kreedit)) - (Jooksva per saldoandmikust (sum kontod 103190 deebet) - (sum kontod 103190 kreedit))

			select ifnull(sum(db) - sum(kr),0) into lnDeebet 
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),6)) = '103190';		
			
			select ifnull(sum(db) - sum(kr),0) into lnKreedit
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),6)) = '103190';		

			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);


	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('4','  Muutus viitlaekumistes',lnKreedit - lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
--(Eelmise aruandeper saldoandmikust (sum: kontod 1035* deebet - konto 103500 deebet - konto 103540 deebet - konto 103556 deebet - konto 103557 deebet) - 
--(sum kontod 1035* kreedit - konto 103500 kreedit - konto 103540 kreedit - konto 103556 kreedit - konto 103557 kreedit)) - 
--(Jooksva per saldoandmikust (sum: kontod 1035* deebet - konto 103500 deebet - konto 103540 deebet - konto 103556 deebet - konto 103557 deebet) - (sum kontod 1035* kreedit - konto 103500 kreedit - konto 103540 kreedit - konto 103556 kreedit - konto 103557 kreedit))

			select sum(db), sum(kr) into lnDb31, lnKr31  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4)) = '1035';		

			
			
			select  sum(db),sum(kr) into lnDeebet, lnKreedit  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),6)) in ('103500','103540','103556','103557');		
			
			lnDeebet = (ifnull(lnDb31,0) - ifnull(lnDeebet,0)) - (ifnull(lnKr31,0) - ifnull(lnKreedit,0));

			select sum(db), sum(kr)into lnDb7,lnKr7  
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4)) = '1035';		

			select sum(db) ,sum(kr) into lnDb31, lnKr31  
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),6)) in ('103500','103540','103556','103557');		

			lnKreedit = (ifnull(lnDb7,0)-ifnull(lnDb31,0))-(ifnull(lnKr31,0)-ifnull(lnKr7,0));

			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('4','  Muutus nхuetes toetuste ja siirete eest',lnKreedit - lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
--(Eelmise aruandeper saldoandmikust (sum: kontod 1036* deebet + sum kontod 1536* deebet) - (sum kontod 1036* kreedit + sum kontod 1536* kreedit)) - (Jooksva per saldoandmikust (sum kontod 1036* deebet + sum ontod 1536* deebet) - (sum kontod 1036* kreedit + sum kontod 1536* kreedit))

			select ifnull(sum(db) - sum(kr),0) into lnDeebet 
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4)) in ('1036','1536');		
			
			select ifnull(sum(db) - sum(kr),0) into lnKreedit
			from saldoandmik
			where  aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4)) in ('1036','1536');		

			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('4','  Muutus muudes nхuetes',lnKreedit - lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 

--(Eelmise aruandeper saldoandmikust (sum: kontod 1037* deebet) - (sum kontod 1037* kreedit)) - (Jooksva per saldoandmikust (sum kontod 1037* deebet) - (sum kontod 1037* kreedit))

			select ifnull(sum(db) - sum(kr),0) into lnDeebet 
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4)) = '1037';		
			
			select ifnull(sum(db) - sum(kr),0) into lnKreedit
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4)) = '1037';		

			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('4','  Muutus maksude, lхivude, trahvide ettemaksetes',lnKreedit - lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
--(Eelmise aruandeper saldoandmikust (sum: kontod 1038* deebet + kontod 1537* deebet) - (sum kontod 1038* kreedit + kontod 1537* kreedit)) - (Jooksva per saldoandmikust (sum kontod 1038* deebet + kontod 1537* deebet) - (sum kontod 1038* kreedit + kontod 1537* kreedit))


			select ifnull(sum(db) - sum(kr),0) into lnDeebet 
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4)) in ('1038','1537');		
			
			select ifnull(sum(db) - sum(kr),0) into lnKreedit
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4)) in ('1038','1537');		

			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('4','  Muutus toetuste ettemaksetes',lnKreedit - lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
--(Eelmise aruandeper saldoandmikust (sum: kontod 1039* deebet + konto 153990 deebet) - (sum kontod 1039* kreedit + konto 153990 kreedit)) - 
--(Jooksva per saldoandmikust (sum kontod 1039* deebet + konto 153990 deebet) - (sum kontod 1039* kreedit + konto 153990 kredit))


			select sum(db) - sum(kr) into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and 
			(
			(left(ltrim(rtrim(saldoandmik.konto)),4)) = '1039' or
			(left(ltrim(rtrim(saldoandmik.konto)),6)) = '153990'
			);		
			
			select sum(db) - sum(kr)into lnKreedit  
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (			
			(left(ltrim(rtrim(saldoandmik.konto)),4)) = '1039' or
			(left(ltrim(rtrim(saldoandmik.konto)),6)) = '153990'
			);		

			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('4','  Muutus muudes ettemaksetes',lnKreedit - lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
--(Eelmise aruandeper saldoandmikust (sum: kontod 108* deebet) - (sum kontod 108* kreedit)) - (Jooksva per saldoandmikust (sum kontod 108* deebet) - (sum kontod 108* kreedit))

			select ifnull(sum(db) - sum(kr),0) into lnDeebet 
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),3)) = '108';		
			
			select ifnull(sum(db) - sum(kr),0) into lnKreedit
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),3)) = '108';		

			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);
	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('4','  Muutus varudes',lnKreedit - lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 

	select sum(summa01) into lnDeebet from tmp_sk_aruanned where ltrim(rtrim(konto)) = '4' and ltrim(rtrim(timestamp)) = lcReturn;

	update tmp_sk_aruanned set summa01 = ifnull(lnDeebet,0) where ltrim(rtrim(konto)) = '40' and ltrim(rtrim(timestamp)) = lcReturn;


	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('50','Pхhitegevusega seotud kohustuste netomuutus',0,tdKpv, tnRekvId,lcReturn, 0 );
--(Jooksva per saldoandmikust (sum: kontod 200* kreedit) - (sum kontod 200* deebet)) - (Eelmise per saldoandmikust (sum kontod 200* kreedit) - (sum kontod 200* deebet))

			select ifnull(sum(kr) - sum(db),0) into lnDeebet 
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),3)) = '200';		
			
			select ifnull(sum(kr) - sum(db),0) into lnKreedit
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),3)) = '200';		
			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('5','  Muutus saadud maksude, lхivude, trahvide ettemaksetes',lnDeebet-lnKreedit,tdKpv, tnRekvId,lcReturn, 0); 
--(Jooksva per saldoandmikust (sum: konto 201000 kreedit + konto 25000* kreedit) - (sum konto 201000 deebet + konto 25000* deebet)) - 
--(Eelmise per saldoandmikust (sum kontod 201000 kreedit + konto 25000* kreedit) - (sum kontod 201000 deebet + konto 25000* deebet))
			select sum(kr) - sum(db)  into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (
			(left(ltrim(rtrim(saldoandmik.konto)),5)) = '25000' or (left(ltrim(rtrim(saldoandmik.konto)),6)) = '201000'
			);		
			
			select sum(kr) - sum(db) into lnKreedit  
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and ( 
			(left(ltrim(rtrim(saldoandmik.konto)),5)) = '25000' or (left(ltrim(rtrim(saldoandmik.konto)),6)) = '201000'
			);		

			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('5','  Muutus vхlgades hankjatele',lnDeebet-lnKreedit,tdKpv, tnRekvId,lcReturn, 0); 
--(Jooksva per saldoandmikust (sum: konto 202* kreedit) - (sum konto 202* deebet)) - (Eelmise per saldoandmikust (sum kontod 202* kreedit) - (sum kontod 202* deebet))

			select ifnull(sum(kr) - sum(db),0) into lnDeebet 
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),3)) = '202';	
			
			raise notice 'Muutus volgades toovotjatele lnDeebet %',lnDeebet;	
			
			select ifnull(sum(kr) - sum(db),0) into lnKreedit
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),3)) = '202';		
			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

			raise notice 'Muutus volgades toovotjatele lnKr %',lnKreedit;	
			raise notice 'Muutus volgades toovotjatele aasta %',lnDb2;	
			raise notice 'Muutus volgades toovotjatele kuu %',lnDb3;	
			raise notice 'Muutus volgades toovotjatele lnRekvId %',lnRekvId;	
			raise notice 'Muutus volgades toovotjatele lnTase %',lnTase;	

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('5','  Muutus vхlgades tццvхtjatele',lnDeebet-lnKreedit,tdKpv, tnRekvId,lcReturn, 0); 

--(Jooksva per saldoandmikust (sum: konto 2030* kreedit + konto 2530* kreedit) - (sum konto 2030* deebet + konto 2530* deebet)) - (Eelmise per saldoandmikust (sum kontod 2030* kreedit + konto 2530* kreedit) - (sum kontod 2030* deebet + konto 2530* deebet))

			select ifnull(sum(kr) - sum(db),0) into lnDeebet 
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4)) = '2030';		
			
			select ifnull(sum(kr) - sum(db),0) into lnKreedit
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4)) = '2030';		
			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('5','  Muutus maksu-, lхivu- ja trahvikohustustes',lnDeebet-lnKreedit,tdKpv, tnRekvId,lcReturn, 0); 
--(Jooksva per saldoandmikust (sum: konto 203290 kreedit) - (sum konto 203290 deebet)) - (Eelmise per saldoandmikust (sum kontod 203290 kreedit) - (sum kontod 203290 deebet))

			select ifnull(sum(kr) - sum(db),0) into lnDeebet 
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),6)) = '203290';		
			
			select ifnull(sum(kr) - sum(db),0) into lnKreedit
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),6)) = '203290';		
			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('5','  Muutus viitvхlgades',lnDeebet-lnKreedit,tdKpv, tnRekvId,lcReturn, 0); 
--(Jooksva per saldoandmikust (sum: konto 2035* kreedit - konto 203500 kreedit - konto 203540 kreedit + 2535* kreedit) - (sum konto 2035* deebet - konto 203500 deebet - konto 203540 deebet + 2535* deebet)) - 
--(Eelmise per saldoandmikust (sum kontod 2035* kreedit - konto 203500 kreedit - konto 203540 kreedit + 2535* kreedit) - (sum kontod 2035* deebet - konto 203500 deebet - konto 203540 deebet + 2535* deebet))

			select sum(db), sum(kr) into lnDb31, lnKr31  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4)) in ('2035','2535');		

			lnDb31 = ifnull(lnDb31,0);
			lnKr31 = ifnull(lnKr31,0);
			
			select (lnKr31 - sum(kr)) - (lnDb31-sum(db)) into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),6)) in ('203500','203540');		

			select sum(db), sum(kr)into lnDb7,lnKr7  
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4)) in ('2035','2535');		

			lnDb7 = ifnull(lnDb7,0);
			lnKr7 = ifnull(lnKr7,0);

			select (lnKr7 - sum(kr)) - (lnDb7-sum(db)) into lnKreedit  
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),6)) in ('203500','203540');		
			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('5','  Muutus toetuste ja siirete kohustustes',lnDeebet-lnKreedit,tdKpv, tnRekvId,lcReturn, 0); 
--(Jooksva per saldoandmikust (sum: konto 2036* kreedit + konto 2536* kreedit) - (sum konto 2036* deebet + 2536* deebet)) - (Eelmise per saldoandmikust (sum kontod 2036* kreedit + 2536* kreedit) - (sum kontod 2036* deebet + 2536* deebet))
			select ifnull(sum(kr) - sum(db),0) into lnDeebet 
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4)) in ('2036','2536');		
			
			select ifnull(sum(kr) - sum(db),0) into lnKreedit
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4)) in ('2036','2536');		

			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);
	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('5','  Muutus muudes kohustustes',lnDeebet-lnKreedit,tdKpv, tnRekvId,lcReturn, 0); 
--(Jooksva per saldoandmikust (sum: konto 2038* kreedit - konto 203856 kreedit- konto 203857 kreedit) - 
--(sum konto 2038* deebet - konto 203856 deebet - konto 203857 deebet)) - 
--(Eelmise per saldoandmikust (sum: konto 2038* kreedit - konto 203856 kreedit- konto 203857 kreedit) - 
--(sum konto 2038* deebet - konto 203856 deebet - konto 203857 deebet))

			select sum(db),sum(kr)  into lnDb31 ,lnKr31  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) = '2038';		

			select sum(db), sum(kr) into lnDb7,lnKr7  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) in ('203856','203857');		

			lnDeebet = ifnull(lnKr31,0) - ifnull(lnKr7,0) - ifnull(lnDb31,0) - ifnull(lnDb7,0);
			

			select sum(db), sum(kr) into lnDb31,lnKr31  
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) = '2038';		

			select sum(db),sum(kr) into lnDb7,lnKr7  
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),6)) in ('203856','203857');		

			lnKreedit = ifnull(lnKr31,0) - ifnull(lnKr7,0) - ifnull(lnDb31,0) - ifnull(lnDb7,0);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('5','  Muutus saadud toetuste ettemaksetes',lnDeebet-lnKreedit,tdKpv, tnRekvId,lcReturn, 0); 
--(Jooksva per saldoandmikust (sum: konto 203900 kreedit + konto 203990 kreedit + konto 253890 kreedit) - (sum konto 203900 deebet + konto 203990 deebet + konto 253890 deebet)) - (Eelmise per saldoandmikust (sum kontod 203900 kreedit + konto 203990 kreedit + konto 253890 kreedit) - (sum kontod 203900 deebet + konto 203990 deebet + konto 253890 deebet))

			select ifnull(sum(kr) - sum(db),0) into lnDeebet 
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),6)) in ('203900','203990','253890');		
			
			select ifnull(sum(kr) - sum(db),0) into lnKreedit
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),6)) in ('203900','203990','253890');		
			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('5','  Muutus muudes saadud ettemaksetes',lnDeebet-lnKreedit,tdKpv, tnRekvId,lcReturn, 0); 
--Jooksva per saldoandmikust (sum: ((konto 206* kreedit RV 41, 49, 05, 06) - (konto 206030 kreedit RV 41, 49, 05, 06))+ (konto 256* kreedit RV 41, 49, 05, 06) - 
--((sum konto 206* deebet RV 41, 49, 05, 06) - (konto 206030 deebet RV 41, 49, 05, 06)) - (konto 256* deebet RV 41, 49, 06, 05))

			select sum(db), sum(kr) into lnDb31, lnKr31  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and ltrim(rtrim(rahavoo)) in ('41','49','05','06')
			and (left(ltrim(rtrim(saldoandmik.konto)),3)) IN ('206','256');		
		
			lnDb31 = ifnull(lnDb31,0);
			lnKr31 = ifnull(lnKr31,0);	
			
			select sum(db),sum(kr) into lnDb7, lnKr7  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and ltrim(rtrim(rahavoo)) in ('41','49','05','06')
			and (left(ltrim(rtrim(saldoandmik.konto)),6)) = ('206030');		

			lnDeebet = lnKr31 - ifnull(lnKr7,0)-lnDb31-ifnull(lnDb7,0);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('5','  Muutus eraldistes',lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
		-- arvestame kokku
	select sum(summa01) into lnDeebet from tmp_sk_aruanned where ltrim(rtrim(timestamp)) = lcReturn and ltrim(rtrim(konto)) = '5';
	update tmp_sk_aruanned set summa01 = ifnull(lnDeebet,0) where ltrim(rtrim(timestamp)) = lcReturn and ltrim(rtrim(konto)) = '50';
		


--= korrigeeritud tegevustulem (3) + kдibevarade muutus (4) + kohustuste muutus (5)

	select sum(summa01) into lnDeebet from tmp_sk_aruanned where ltrim(rtrim(timestamp)) = lcReturn and ltrim(rtrim(konto)) = '3';
	lnKreedit = ifnull(lnDeebet,0);
	select sum(summa01) into lnDeebet from tmp_sk_aruanned where ltrim(rtrim(timestamp)) = lcReturn and ltrim(rtrim(konto)) = '4';
	lnKreedit = lnKreedit + ifnull(lnDeebet,0);
	select sum(summa01) into lnDeebet from tmp_sk_aruanned where ltrim(rtrim(timestamp)) = lcReturn and ltrim(rtrim(konto)) = '5';
	lnKreedit = lnKreedit + ifnull(lnDeebet,0);

	raise notice 'lnKreedit %',lnKreedit;
	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('60','Rahavood pхhitegevusest kokku',lnKreedit,tdKpv, tnRekvId,lcReturn, 0); 

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('7','Rahavood investeerimistegevusest',0,tdKpv, tnRekvId,lcReturn, 0); 

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('710',' Tasutud pхhivara eest (v.a. finantsinvesteeringud ja osalused)',0,tdKpv, tnRekvId,lcReturn, 0); 

--Jooksva per saldoandmikust (Sum: Konto 155* kreedit (RV 01)) - (Sum: Konto 155* deebet (RV 01)) + 
--(sum: konto 2082* kreedit (RV 01; RV 05)) - (sum: konto 2082* deebet (RV 01; RV 05)) + 
--(sum: konto 2582* kreedit (RV 01; RV 05)) - (sum: konto 2582* deebet (RV 01; RV 05)) + 
--(sum: konto 350200 kreedit (RV 01)) - (sum: konto 350200 deebet (RV 01)) + 
--(sum: konto 350220 kreedit (RV 01)) - (sum: konto 350220 deebet (RV 01)) + 
--(sum: konto 350240 kreedit (RV 01)) - (sum: konto 350240 deebet RV 01)) + 
--(sum 257* kreedit (RV 01)) - (sum 257* kreedit RV 01))
			
			select sum(kr) - sum(db) into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (
			(ltrim(rtrim(rahavoo)) = '01' and (left(ltrim(rtrim(saldoandmik.konto)),3) in ('155','257') or left(ltrim(rtrim(konto)),6) in ('350200','350220','350240'))) 
			or (ltrim(rtrim(rahavoo)) in ('01','05') and left(ltrim(rtrim(konto)),4) in ('2082','2582'))
			);		

			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('71','  Materiaalse pхhivara soetus',lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
--Jooksva per saldoandmikust (Sum: Konto 154* kreedit (RV 01)) - (Sum: Konto 154* deebet (RV 01))

			select sum(kr) - sum(db) into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and ltrim(rtrim(rahavoo)) = '01' and left(ltrim(rtrim(saldoandmik.konto)),3) in ('154'); 

			select sum(kr) - sum(db) into lnKreedit  
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and ltrim(rtrim(rahavoo)) = '01' and left(ltrim(rtrim(saldoandmik.konto)),3) in ('154'); 

			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('71','  Kinnisvarainvesteeringute soetus',lnDeebet-lnKreedit,tdKpv, tnRekvId,lcReturn, 0); 
--Jooksva per saldoandmikust (Sum: Konto 156* kreedit (RV 01)) - (Sum: Konto 156* deebet (RV 01))

			select sum(kr) - sum(db) into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and ltrim(rtrim(rahavoo)) = '01' and left(ltrim(rtrim(saldoandmik.konto)),3) in ('156'); 

			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('71','  Immateriaalse pхhivara soetus',lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
--Jooksva per saldoandmikust (Sum: Konto 157* kreedit (RV 01)) - (Sum: Konto 157* deebet (RV 01))

			select sum(kr) - sum(db) into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and ltrim(rtrim(rahavoo)) = '01' and left(ltrim(rtrim(saldoandmik.konto)),3) in ('157'); 

			select sum(kr) - sum(db) into lnKreedit  
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and ltrim(rtrim(rahavoo)) = '01' and left(ltrim(rtrim(saldoandmik.konto)),3) in ('157'); 

			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('71','  Bioloogiliste varade soetus',lnDeebet-lnKreedit,tdKpv, tnRekvId,lcReturn, 0); 
--(Jooksva per saldoandmikust (sum: konto 201010 kreedit + konto 25001* kreedit) - 
--(sum konto 201010 deebet + konto 25001* deebet)) - (Eelmise per saldoandmikust (sum kontod 201010 kreedit + konto 25001* kreedit) - (sum kontod 201010 deebet + konto 25001* deebet))

			select sum(kr) - sum(db) into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),6) = ('201010') or left(ltrim(rtrim(saldoandmik.konto)),5) = ('25001')); 

			select sum(kr) - sum(db) into lnKreedit  
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),6) = ('201010') or left(ltrim(rtrim(saldoandmik.konto)),5) = ('25001')); 

			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('71','  Korrigeerimine muutusega vхlgades hankijatele',lnDeebet-lnKreedit,tdKpv, tnRekvId,lcReturn, 0); 


	select sum(summa01) into lnDeebet from tmp_sk_aruanned  where ltrim(rtrim(timestamp)) = lcReturn and ltrim(rtrim(konto)) = '71';

	update tmp_sk_aruanned set summa01 = ifnull(lnDeebet,0) where ltrim(rtrim(timestamp)) = lcReturn and ltrim(rtrim(konto)) = '710';


	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('720',' Laekunud pхhivara mььgist (v.a. finantsinvesteeringud ja osalused)',0,tdKpv, tnRekvId,lcReturn, 0); 
--Jooksva per Saldoandmikust (Sum: Kontod 381000+381001+381100+381101+381110+381111+381115+381116+381120+381121+381125+381126+381130+381131+381140+381141+381145+381146+
--381150+381151+381160+381161+381170+381171+381180+381181+381300+381301+381320+381321+381360+381361+381400+381401+381410+381411+381420+381421 kreedit) 
-- - (Sum: 381000+381001+381100+381101+381110+381111+381115+381116+381120+381121+381125+381126+381130+381131+381140+381141+381145+381146+381150+381151+381160+
--381161+381170+381171+381180+381181+381300+381301+381320+381321+381360+381361+381400+381401+381410+381411+381420+381421 deebet)
			
			select sum(kr) - sum(db) into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) in ('381000','381001','381100','381101','381110','381111','381115','381116','381120','381121','381125',
				'381126','381130','381131','381140','381141','381145','381146','381150','381151','381160','381161','381170','381171','381180','381181',
				'381300','381301','381320','381321','381360','381361','381400','381401','381410','381411','381420','381421'); 
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('72','  Mььgist saadud tulu',lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
--(Eelmise aruandeper saldoandmikust (sum: kontod 10301* deebet + konto 15301* deebet) - (sum kontod 10301* kreedit + konto 15301* kreedit)) - 
--(Jooksva per saldoandmikust (sum: kontod 10301* deebet + konto 15301* deebet) - (sum kontod 10301* kreedit + konto 15301* kreedit))

			select sum(db) - sum(kr)  into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),5) in ('10301','15301');

			select sum(db) - sum(kr)   into lnKreedit  
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),5) in ('10301','15301');

			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('72','  Korrigeerimine laekumata nхuete muutusega',lnKreedit-lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
--(Jooksva per saldoandmikust (sum: konto 203910 kreedit) - (sum konto 203910 deebet)) - (Eelmise per saldoandmikust (sum kontod 203910 kreedit) - (sum kontod 203910 deebet))

			select sum(kr) - sum(db)  into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = ('203910');

			select sum(kr)  - sum(db) into lnKreedit  
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = ('203910');

			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('72','  Korrigeerimine laekunud ettemaksete muutusega',lnDeebet-lnKreedit,tdKpv, tnRekvId,lcReturn, 0); 
--(Eelmise aruandeper saldoandmikust (sum: kontod 10325* deebet + konto 15325* deebet) - (sum kontod 10325* kreedit + konto 15325* kreedit)) - (Jooksva per saldoandmikust (sum: kontod 10325* deebet + konto 15325* deebet) - (sum kontod 10325* kreedit + konto 15325* kreedit))

			select sum(db) - sum(kr)   into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),5) in ('10325','15325');

			select sum(db) - sum(kr)  into lnKreedit  
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),5) in ('10325','15325');

			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('72','  Korrigeerimine jдrelmaksunхuete muutusega',lnKreedit-lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
--Jooksva per Saldoandmikust (Sum: Konto 605020 kreedit) - (Sum: Konto 605020 deebet)

			select sum(kr)  - sum(db)   into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = ('605020');

			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('72','  Korrigeerimine ebatхenдoliselt laekuvaks arvatud jдrelmaksunхuetega',lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
--(Jooksva per saldoandmikust (sum: konto 206030 kreedit) - (sum konto 206030 deebet)) - (Eelmise per saldoandmikust (sum kontod 206030 kreedit) - (sum kontod 206030 deebet)) + (jooksva per saldoandmikust (konto 700030 kreedit + konto 710030 kreedit - konto 700030 deebet - konto 710030 deebet)

			select sum(kr) - sum(db) into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = ('206030');

			select sum(kr) - sum(db)   into lnKreedit  
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = ('206030');

			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('72','  Korrigeerimine kustutatud EVP-de jддgi muutusega',lnKreedit-lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 

		select sum(summa01) into lnDeebet from tmp_sk_aruanned where ltrim(rtrim(timestamp)) = lcReturn and ltrim(rtrim(konto)) = '72';

		update tmp_sk_aruanned set summa01 = ifnull(lnDeebet,0) where ltrim(rtrim(timestamp)) = lcReturn and ltrim(rtrim(konto)) = '720';


			
--Jooksva per saldoandmikust (Sum: Konto 1032* kreedit (RV 01) + sum konto 1532* kreedit (RV 01)) - (Sum: Konto 1032* deebet (RV 01)+ sum konto 1532* deebet (RV 01))

			select sum(kr) - sum(db) into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) in ('1032','1532') and ltrim(rtrim(rahavoo)) = '01';

			select sum(kr) - sum(db)   into lnKreedit  
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) in ('1032','1532') and ltrim(rtrim(rahavoo)) = '01';

			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('7',' Antud laenud',lnDeebet-lnKreedit,tdKpv, tnRekvId,lcReturn, 0); 
--Jooksva per saldoandmikust (Sum: Konto 1032* kreedit (RV 02) + sum konto 1532* kreedit (RV 02)) - (Sum: Konto 1032* deebet (RV 02)+ sum konto 1532* deebet (RV 02))

			select sum(kr) - sum(db) into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) in ('1032','1532') and ltrim(rtrim(rahavoo)) = '02';

			select sum(kr) - sum(db)   into lnKreedit  
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) in ('1032','1532') and ltrim(rtrim(rahavoo)) = '02';

			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('7',' Tagasi makstud laenud',lnDeebet-lnKreedit,tdKpv, tnRekvId,lcReturn, 0); 

--(Eelmise per saldoandmikust (Sum konto 103540 deebet) - (sum konto 103540 kreedit) - (sum konto 203540 kreedit) + (sum konto 203540 deebet)) - (sum konto 257800 kreedit) +
-- (sum konto 257800 deebet)) - 
--(Jooksva per saldoandmikust (Sum: Konto 103540 deebet) - (sum konto 103540 kreedit) - 
--(konto 203540 kreedt) + (konto 203540 deebet) - 
--(konto 257800 kreedit) + (konto 257800 deebet))

			select sum(db),sum(kr) into lnDb31,lnKr31  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = ('103540');
			
			lnDeebet = ifnull(lnDb31,0) - ifnull(lnKr31,0);

			select sum(db),sum(kr) into lnDb31,lnKr31  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) in ('203540');

			lnDeebet = lnDeebet  - ifnull(lnKr31,0) + ifnull(lnDb31,0) ;

			select sum(db),sum(kr) into lnDb31,lnKr31  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) in ('257800');

			lnDeebet = lnDeebet  - ifnull(lnKr31,0) + ifnull(lnDb31,0) ;
			
			select sum(db),sum(kr)    into lnDb31,lnKr31 
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = ('103540');
			
			lnKreedit = ifnull(lnDb31,0) - ifnull(lnKr31,0);

			select sum(db),sum(kr) into lnDb31,lnKr31  
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) in ('203540');

			lnKreedit = lnKreedit  - ifnull(lnKr31,0) + ifnull(lnDb31,0) ;

			select sum(db),sum(kr) into lnDb31,lnKr31  
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) in ('257800');

			lnKreedit = lnKreedit  - ifnull(lnKr31,0) + ifnull(lnDb31,0) ;

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('7',' Korrigeerimine laenutegevuseks saadud sihtfinantseerimise muutusega',lnKreedit-lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
--Jooksva per saldoandmikust (Sum: Konto 101* kreedit (RV 01) + sum konto 151* kreedit (RV 01)) - (Sum: Konto 101* deebet (RV 01)+ sum konto 151* deebet (RV 01))

			select sum(kr) - sum(db) into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),3) in ('101','151') and ltrim(rtrim(rahavoo)) = '01';
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('7',' Tasutud finantsinvesteeringute soetamisel',lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
--Jooksva per saldoandmikust (Sum: Konto 101* kreedit (RV 02) + sum konto 151* kreedit (RV 02)) - (Sum: Konto 101* deebet (RV 02)+ sum konto 151* deebet (RV 02))

			select sum(kr) - sum(db) into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),3) in ('101','151') and ltrim(rtrim(rahavoo)) = '02';
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('7',' Laekunud finantsinvesteeringute mььgist',lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
--Jooksva per saldoandmikust (Sum: Konto 150* kreedit (RV 01)) - (Sum: Konto 150* deebet (RV 01))

			select sum(kr) - sum(db) into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),3) = '150' and ltrim(rtrim(rahavoo)) = '01';
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('7',' Tasutud osaluste soetamisel',lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
--Jooksva per saldoandmikust (Sum: Konto 150* kreedit (RV 02)) - (Sum: Konto 150* deebet (RV 02))

			select sum(kr) - sum(db) into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),3) = '150' and ltrim(rtrim(rahavoo)) = '02';
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('7',' Laekunud osaluste mььgist',lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
--(Jooksva per saldoandmikust (Sum: Konto 655500 kreedit+ konto 652010 kreedit) - (sum konto 655500  deebet + konto 652010 deebet) + 
--(sum 103110 kreedit RV 02 - Sum Konto 10311 0 deebet RV 02))

			select sum(kr) - sum(db) into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (
			left(ltrim(rtrim(saldoandmik.konto)),6) in ('655500','652010') 
			or (left(ltrim(rtrim(saldoandmik.konto)),6) = '103110' and ltrim(rtrim(rahavoo)) = '02')
			);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('7',' Laekunud dividendid',lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
--(Eelmise per saldoandmikust (Sum konto 10310* deebet) - (sum konto 10310* kreedit)) + 
--(Jooksva per saldoandmikust (Sum: Konto 6580* kreedit) - (sum konto 6580* deebet) + 
--(konto 658910 kreedit) - (konto 658910 deebet) - 
--(sum 10310* deebet - Sum Konto 10310* kreedit )) + (Sum: Konto 655* kreedit - konto 655* deebet) - 
--((sum 101* deebet RV 21, 29, 22) - (sum 101* kreedit RV 21, 29, 22)) - 
--((Sum: Konto 151* deebet RV 21, 29, 22) - (konto 151* kreedit RV 21, 29, 22)) - 
--(konto 655500 kreedit miinus konto 655500 deebet) -
--((sum 1032* deebet RV 22 - sum 1032* kreedit RV 22 + sum 1532* deebet RV 22 - sum 1532* kreedit RV 22)) + 
--((konto 101900 deebet RV 21 - konto 101900 kreedit RV 21)) 


			select sum(db) - sum(kr)    into lnKreedit  
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),5) = '10310'; 

			select sum(db),sum(kr) into lnDb31,lnKr31  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) = '6580';
			
			lnDeebet = ifnull(lnKr31,0) - ifnull(lnDb31,0);

			select sum(db),sum(kr) into lnDb31,lnKr31  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = '658910';
			
			lnDeebet = lnDeebet + ifnull(lnKr31,0) - ifnull(lnDb31,0);

			select sum(db),sum(kr) into lnDb31,lnKr31  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),5) = '10310';
			
			lnDeebet = lnDeebet - ifnull(lnDb31,0) - ifnull(lnKr31,0) ;

			select sum(db),sum(kr) into lnDb31,lnKr31  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),3) = '655';
			lnDeebet = lnDeebet + ifnull(lnKr31,0) - ifnull(lnDb31,0)   ;
--((sum 101* deebet RV 21, 29, 22) - (sum 101* kreedit RV 21, 29, 22)) - 
			select sum(db),sum(kr) into lnDb31,lnKr31  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),3) = '101' and ltrim(rtrim(rahavoo)) in ('21','29','22');
			lnDeebet = lnDeebet - ifnull(lnDb31,0) - ifnull(lnKr31,0)    ;
 --((Sum: Konto 151* deebet RV 21, 29, 22) - (konto 151* kreedit RV 21, 29, 22)) - 

			select sum(db),sum(kr) into lnDb31,lnKr31  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),3) = '151' and ltrim(rtrim(rahavoo)) in ('21','29','22');
			lnDeebet = lnDeebet - ifnull(lnDb31,0) - ifnull(lnKr31,0)    ;
---(konto 655500 kreedit miinus konto 655500 deebet) -

			select sum(db),sum(kr) into lnDb31,lnKr31  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = '655500';
			lnDeebet = lnDeebet - ifnull(lnKr31,0) - ifnull(lnDb31,0);
--((sum 1032* deebet RV 22 - sum 1032* kreedit RV 22 + sum 1532* deebet RV 22 - sum 1532* kreedit RV 22)) + 

			select sum(db),sum(kr) into lnDb31,lnKr31  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) = '1032' and ltrim(rtrim(rahavoo)) = '22';

			lnDeebet = lnDeebet - ifnull(lnDb31,0) - ifnull(lnKr31,0) ;
--((konto 101900 deebet RV 21 - konto 101900 kreedit RV 21)) 

			select sum(db),sum(kr) into lnDb31,lnKr31  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = '101900' and ltrim(rtrim(rahavoo)) = '21';

			lnDeebet = lnDeebet + ifnull(lnDb31,0) - ifnull(lnKr31,0) ;

			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('7',' Laekunud intressid ja muu finantstulu',lnKreedit +lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 

-- = grupp kokku 

			select sum(summa01) into lnDeebet  
			from tmp_sk_aruanned
			where ltrim(rtrim(timestamp)) =  lcReturn 
			and ltrim(rtrim(konto)) in ('7','710','720');

			lnDeebet = ifnull(lnDeebet,0);

			raise notice 'lnDeebet %',lnDeebet;

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('70','Rahavood investeerimistegevusest kokku',lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('8','Rahavood finantseerimistegevusest',0,tdKpv, tnRekvId,lcReturn, 0); 
--Jooksva per saldoandmikust (Sum konto 2080* kreedit (RV 05) - konto 2080* deebet (RV 05) + sum konto 2580* kreedit (RV 05) - konto 2580* deebet (RV 05) 

			select sum(kr) - sum(db) into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) in ('2080','2580') and ltrim(rtrim(rahavoo)) = '05';

			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('8',' Laekunud vхlakirjade emiteerimisest',lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
--Jooksva per saldoandmikust (Sum konto 2080* kreedit (RV 06) - konto 2080* deebet (RV 06) + sum konto 2580* kreedit (RV 06) - konto 2580* deebet (RV 06) 

			select sum(kr) - sum(db) into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) in ('2080','2580') and ltrim(rtrim(rahavoo)) = '06';

			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('8',' Lunastatud vхlakirjad',lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
--Jooksva per saldoandmikust (Sum konto 2081* kreedit (RV 05) - konto 2081* deebet (RV 05) + sum konto 2581* kreedit (RV 05) - konto 2581* deebet (RV 05) 

			select sum(kr) - sum(db) into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) in ('2081','2581') and ltrim(rtrim(rahavoo)) = '05';

			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('8',' Laekunud laenud',lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
--Jooksva per saldoandmikust (Sum konto 2081* kreedit (RV 06) - konto 2081* deebet (RV 06) + sum konto 2581* kreedit (RV 06) - konto 2581* deebet (RV 06) 

			select sum(db), sum(kr) into lnDb31, lnKr31  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) in ('2081','2581') and ltrim(rtrim(rahavoo)) = '06';

			lnDeebet = ifnull(lnKr31,0) - ifnull(lnDb31,0);

			raise notice 'Tagasi makstud laenud %',lnDeebet;

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('8',' Tagasi makstud laenud',lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
--(Jooksva per saldoandmikust (Sum konto 208100 kreedit - konto 208100 deebet)) - (eelmise per saldoandmikust (sum konto 208100 kreedit- konto 208100 deebet))

			select sum(kr) - sum(db) into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = ('208100');

			select sum(kr) - sum(db)   into lnKreedit  
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = ('208100');

			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('8',' Arvelduskrediidi muutus',lnDeebet-lnKreedit,tdKpv, tnRekvId,lcReturn, 0); 
--Jooksva per saldoandmikust (Sum konto 2082* kreedit (RV 06) - konto 2082* deebet (RV 06) + sum konto 2582* kreedit (RV 06) - konto 2582* deebet (RV 06) 
			select sum(kr) - sum(db) into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) in ('2082','2582') and ltrim(rtrim(rahavoo)) = '06';

			select sum(kr) - sum(db)   into lnKreedit  
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) in ('2082','2582') and ltrim(rtrim(rahavoo)) = '06';

			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('8',' Tagasi makstud kapitalirendikohustused',lnDeebet-lnKreedit,tdKpv, tnRekvId,lcReturn, 0); 
--Jooksva per saldoandmikust (Sum konto 2083* kreedit (RV 05) - konto 2083* deebet (RV 05) + sum konto 2583* kreedit (RV 05) - konto 2583* deebet (RV 05) 
			select sum(kr) - sum(db) into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) in ('2083','2583') and ltrim(rtrim(rahavoo)) = '05';

			select sum(kr) - sum(db)   into lnKreedit  
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) in ('2083','2583') and ltrim(rtrim(rahavoo)) = '05';

			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('8',' Laekunud faktooringlepingute alusel',lnDeebet-lnKreedit,tdKpv, tnRekvId,lcReturn, 0); 
--Jooksva per saldoandmikust (Sum konto 2083* kreedit (RV 06) - konto 2083* deebet (RV 06) + sum konto 2583* kreedit (RV 06) - konto 2583* deebet (RV 06) 
			
			select sum(kr) - sum(db) into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) in ('2083','2583') and ltrim(rtrim(rahavoo)) = '06';

			select sum(kr) - sum(db)   into lnKreedit  
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) in ('2083','2583') and ltrim(rtrim(rahavoo)) = '06';

			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('8',' Tagasi makstud faktooringlepingute alusel',lnDeebet-lnKreedit,tdKpv, tnRekvId,lcReturn, 0); 

--Jooksva per saldoandmikust (Sum: Konto 257* kreedit (RV 05) + konto 350200 kreedit (RV 05) + konto 350220 kreedit (RV 05) + konto 350240 kreedit (RV 05)) - 
--(Sum: Konto 257* deebet (RV 05)+ konto 350200 deebet (RV 05) + konto 350220 deebet (RV 05) + konto 350240 deebet (RV 05)) + 
--(Jooksva per saldoandmikust (sum: konto 203856 kreedit + konto 203857 kreedit) - (sum konto 203856 deebet + konto 203857 deebet)) - 

--(Eelmise per saldoandmikust (sum kontod 203856 kreedit + konto 203857 kreedit) - (sum kontod 203856 deebet + konto 203857 deebet)) + 
--(Eelmise per saldoandmikust (sum konto 103556 deebet + konto 103557 deebet + 153556 deebet) - (sum konto 103556 kreedit + konto 103557 kreedit + konto 153556 kreedit)) - 
--(Jooksva per saldoandmikust (sum konto 103556 deebet + konto 103557 deebet + konto 153556 deebet) - (sum konto 103556 kreedit + konto 103557 kreedit + konto 153556 kreedit))  

			select sum(db),sum(kr) into lnDb31,lnKr31  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (
			(left(ltrim(rtrim(saldoandmik.konto)),4) = ('257') and ltrim(rtrim(rahavoo)) = '05')
			or (left(ltrim(rtrim(saldoandmik.konto)),6) in ('350200','350220','350240') and ltrim(rtrim(rahavoo)) = '05')
			);

			lnDeebet = ifnull(lnKr31,0) - ifnull(lnDb31,0);
--(Jooksva per saldoandmikust (sum: konto 203856 kreedit + konto 203857 kreedit) - (sum konto 203856 deebet + konto 203857 deebet)) - 
			select sum(db),sum(kr) into lnDb31,lnKr31  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) in ('203856','203857') ;

			lnDeebet = lnDeebet + ifnull(lnKr31,0) - ifnull(lnDb31,0);

--(Eelmise per saldoandmikust (sum kontod 203856 kreedit + konto 203857 kreedit) - (sum kontod 203856 deebet + konto 203857 deebet)) + 
			
			select sum(db) ,sum(kr)   into lnDb31,lnKr31 
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) in ('203856','203857') ;

			lnDeebet = lnDeebet - ifnull(lnKr31,0) - ifnull(lnDb31,0);
--(Eelmise per saldoandmikust (sum konto 103556 deebet + konto 103557 deebet + 153556 deebet) - (sum konto 103556 kreedit + konto 103557 kreedit + konto 153556 kreedit)) - 
			select sum(db) ,sum(kr)   into lnDb31,lnKr31 
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) in ('103556','103557','153556') ;

			lnDeebet = lnDeebet + ifnull(lnDb31,0) - ifnull(lnKr31,0) ;

--(Jooksva per saldoandmikust (sum konto 103556 deebet + konto 103557 deebet + konto 153556 deebet) - (sum konto 103556 kreedit + konto 103557 kreedit + konto 153556 kreedit))  
			select sum(db),sum(kr) into lnDb31,lnKr31  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) in ('103556','103557','153556') ;

			lnDeebet = lnDeebet -  ifnull(lnDb31,0) - ifnull(lnKr31,0) ;

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('8',' Laekunud sihtfinanteerimine pхhivara soetuseks',lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
--(Jooksva per saldoandmikust (sum: konto 253800 kreedit + konto 323880 kreedit) - (sum konto 253800 deebet + konto 323880 deebet)) - 
--(Eelmise per saldoandmikust (sum konto 253800 kreedit) - (sum kontod 253800 deebet))
			select sum(kr)-sum(db) into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) in ('253800','323880') ;

			select sum(kr) - sum(db)  into lnKreedit 
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = ('253800') ;

			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('8',' Laekunud liitumistasud',lnDeebet-lnKreedit,tdKpv, tnRekvId,lcReturn, 0); 

--Jooksva per saldoandmikust (Sum konto 650* kreedit - konto 650* deebet) + jooksva per saldoandmikust (konto 203200 kreedit - konto 203200 deebet) - 
--(eelmise per saldoandmikust (konto 203200 kreedit- konto 203200 deebet)) + (jooksva per saldoandmikust (konto 209000 kreedit - konto 209000 deebet) - 
--(eelmise per saldoandmikust (konto 209000 kreedit - konto 209000 deebet)) + eelmise per saldandmikust (konto 103300 deebet - konto 103300 kreedit)) - 
--jooksva per saldoandmikust (konto 103300 deebet - konto 103300 kreedit) + jooksva per saldoandmikust (konto 256* kreedit RV 42 - konto 256* deebet RV 42) + 
--jooksva per saldoandmikust (konto 208* kreedit (RV 42) - konto 208* deebet (RV 42)) + jooksva per saldoandmikust (konto 258* kreedit (RV 42) - konto 258* deebet (RV 42))

--Jooksva per saldoandmikust (Sum konto 650* kreedit - konto 650* deebet) + jooksva per saldoandmikust (konto 203200 kreedit - konto 203200 deebet) - 

			select sum(kr)-sum(db) into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (
			(left(ltrim(rtrim(saldoandmik.konto)),3) = '650')
			or (left(ltrim(rtrim(saldoandmik.konto)),6) = '203200')  
			);
--(eelmise per saldoandmikust (konto 203200 kreedit- konto 203200 deebet)) + (jooksva per saldoandmikust (konto 209000 kreedit - konto 209000 deebet) - 

			select sum(kr) - sum(db)  into lnKreedit 
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = '203200';  

			select sum(kr)-sum(db) into lnDb31 
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = '209000';

			lnDeebet = ifnull(lnDeebet,0) - ifnull(lnKreedit,0) + ifnull(lnDb31,0);
			
--(eelmise per saldoandmikust (konto 209000 kreedit - konto 209000 deebet)) + eelmise per saldandmikust (konto 103300 deebet - konto 103300 kreedit)) - 

			select sum(kr) - sum(db)  into lnKreedit 
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = '209000';

			lnDeebet = lnDeebet - ifnull(lnKreedit,0);		

			select sum(db)-sum(kr)  into lnKreedit 
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = '103300';
			
			lnDeebet = lnDeebet + ifnull(lnKreedit,0);		
--jooksva per saldoandmikust (konto 103300 deebet - konto 103300 kreedit) + jooksva per saldoandmikust (konto 256* kreedit RV 42 - konto 256* deebet RV 42) + 
			select sum(db) - sum(kr) into lnDb31 
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = '103300';

			lnDeebet = lnDeebet - ifnull(lnDb31,0);		

			select sum(kr) - sum(db) into lnDb31 
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),3) = '256' and ltrim(rtrim(rahavoo)) = '42';

			lnDeebet = lnDeebet + ifnull(lnDb31,0);		
--jooksva per saldoandmikust (konto 208* kreedit (RV 42) - konto 208* deebet (RV 42)) + jooksva per saldoandmikust (konto 258* kreedit (RV 42) - konto 258* deebet (RV 42))
			select sum(kr) - sum(db) into lnDb31 
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),3) in ('208','258') and ltrim(rtrim(rahavoo)) = '42';

			lnDeebet = lnDeebet + ifnull(lnDb31,0);		

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('8',' Makstud intressid',lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 

--(Jooksva per saldoandmikust (Sum konto 6589* kreedit - konto 6589* deebet - 658910 kreedit + 658910 deebet)) + 
--jooksva per saldoandmikust (konto 208* kreedit (RV 41*) - konto 208* deebet (RV 41)) + 
--jooksva per saldoandmikust (konto 258* kreedit (RV 41*) - konto 258* deebet (RV 41*))

--(Jooksva per saldoandmikust (Sum konto 6589* kreedit - konto 6589* deebet - 658910 kreedit + 658910 deebet)) + 
			select sum(kr) - sum(db) into lnDb31 
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) = ('6589');
			
			lnDeebet = ifnull(lnDb31,0);	

			select  sum(db), sum(kr)  into lnDb31, lnKr31 
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = ('658910');

			lnDeebet = lnDeebet  - ifnull(lnKr31,0) + ifnull(lnDb31,0);	
--jooksva per saldoandmikust (konto 208* kreedit (RV 41*) - konto 208* deebet (RV 41)) + 
--jooksva per saldoandmikust (konto 258* kreedit (RV 41*) - konto 258* deebet (RV 41*))
			select sum(kr) - sum(db) into lnDb31 
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),3) in ('208','258') and ltrim(rtrim(rahavoo)) = '41';

			lnDeebet = lnDeebet + ifnull(lnDb31,0);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('8',' Makstud muud finantskulud',lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
--(Jooksva per saldoandmikust (Sum konto 297* kreedit - konto 297* deebet)) - (eelmise per saldoandmikust (Sum konto 297* kreedit - konto 297* deebet))
			select sum(kr) - sum(db) into lnDeebet
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),3) = ('297') ;

			select sum(kr) - sum(db)  into lnKreedit 
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),3) = ('297') ;

			lnDeebet = ifnull(lnDeebet,0) - ifnull(lnKreedit,0); 

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('8',' Riskimaandamise reservi muutus',lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 

--(Jooksva per saldoandmikust (konto 203210 kreedit RV 06 miinus konto 203210 deebet RV 06)
			select sum(kr) - sum(db) into lnDeebet
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = ('203210') and ltrim(rtrim(rahavoo)) = '06' ;

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('8',' Makstud dividendid',ifnull(lnDeebet,0),tdKpv, tnRekvId,lcReturn, 0); 
--Jooksva per saldoandmikust (Sum (konto 29* RV 05 kreedit - konto 29* RV 05 deebet)) + (sum konto 289000 kreedit RV 05 - sum konto 289000 deebet RV 05))
			select sum(kr) - sum(db) into lnDeebet
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (
			(left(ltrim(rtrim(saldoandmik.konto)),2) = ('29') and ltrim(rtrim(rahavoo)) = '05') or 
			(left(ltrim(rtrim(saldoandmik.konto)),6) = ('289000') and ltrim(rtrim(rahavoo)) = '05')
			);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('8',' Laekunud sissemaksed omakapitali',ifnull(lnDeebet,0),tdKpv, tnRekvId,lcReturn, 0); 
--Jooksva per saldoandmikust (Sum (konto 29* RV 06 kreedit - konto 29* RV 06 deebet)) + (sum konto 289000 kreedit RV 06 - sum konto 289000 deebet RV 06))
			select sum(kr) - sum(db) into lnDeebet
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (
			(left(ltrim(rtrim(saldoandmik.konto)),2) = ('29') and ltrim(rtrim(rahavoo)) = '06') or 
			(left(ltrim(rtrim(saldoandmik.konto)),6) = ('289000') and ltrim(rtrim(rahavoo)) = '06')
			);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('8',' Tasutud vдljamaksed omakapitalist',ifnull(lnDeebet,0),tdKpv, tnRekvId,lcReturn, 0); 
--(Jooksva per saldoandmikust (Sum konto 68* kreedit - konto 68* deebet)) 
			select sum(kr) - sum(db) into lnDeebet
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),2) = '68';

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('8',' Dividendidelt makstud tulumaks',ifnull(lnDeebet,0),tdKpv, tnRekvId,lcReturn, 0); 
--(Jooksva per saldoandmikust (sum konto 7* kreedit - 7* deebet - konto 700002 kreedit - konto 710002 kreedit - konto 700030 kreedit - konto 710030 kreedit + 
--konto 700002 deebet + konto 710002 deebet + konto 700030 deebet + konto 710030 deebet) + kontod 1* kreedit (RV 15 + RV 16) - kontod 1* deebet (RV 15 + RV 16) + 
--kontod 2* kreedit (RV 15 + RV 16 + RV 35 + RV 36) - kontod 2* deebet (RV 15 + RV 16 + RV 35 + RV 36)
			select sum(kr) - sum(db) into lnDeebet
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),1) = '7';

			lnDeebet = ifnull(lnDeebet,0);

			select sum(db),sum(kr)  into lnDb31,lnKr31
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) in ('700002','710002','700030','710030 ');

			lnDeebet = lnDeebet  - ifnull(lnKr31,0) + ifnull(lnDb31,0);

			select sum(db),sum(kr)  into lnDb31,lnKr31
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (
			(left(ltrim(rtrim(saldoandmik.konto)),1) = '1' and ltrim(rtrim(rahavoo)) in ('15','16')) or
			(left(ltrim(rtrim(saldoandmik.konto)),1) = '2' and ltrim(rtrim(rahavoo)) in ('15','16','35','36'))
			);

			lnDeebet = lnDeebet  + ifnull(lnKr31,0) - ifnull(lnDb31,0);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('8',' Netofinantseerimine eelavest',lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 

--= grupp kokku 
			select sum(summa01) into lnDeebet from tmp_sk_aruanned where ltrim(rtrim(timestamp)) = lcReturn and ltrim(rtrim(konto)) = '8';

			raise notice 'lnDeebet %',lnDeebet;

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('80','Rahavood finantseerimistegevusest kokku',ifnull(lnDeebet,0),tdKpv, tnRekvId,lcReturn, 0); 

--= rahavood pхhitegevusest + rahavood inv tegevusest + rahavood fin tegevusest

	select sum(summa01) into lnDeebet from tmp_sk_aruanned where ltrim(rtrim(timestamp)) = lcReturn
		and (
		ltrim(rtrim(konto)) in ('60','70','80')
		);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('90','Puhas rahavoog',ifnull(lnDeebet,0),tdKpv, tnRekvId,lcReturn, 0); 
--Eelmise per saldoandmikust (sum konto 100* deebet - konto 100* kreedit) + (sum konto 101100 deebet - konto 101100 kreedit)

			select sum(db)-sum(kr)  into lnKreedit 
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  saldoandmik.rekvid = tnRekvId)
			and (
			left(ltrim(rtrim(saldoandmik.konto)),3) = ('100') or left(ltrim(rtrim(saldoandmik.konto)),6) = ('101100')
			);

			raise notice 'Raha eelmised %',lnKreedit;
			
	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('91','Raha ja selle ekvivalendid perioodi alguses',ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0); 
--Jooksva per saldoandmikust (sum konto 100* deebet - konto 100* kreedit) + (sum konto 101100 deebet - konto 101100 kreedit)

			select sum(db)-sum(kr)  into lnDeebet 
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  saldoandmik.rekvid = tnRekvId)
			and (
			left(ltrim(rtrim(saldoandmik.konto)),3) = ('100') or left(ltrim(rtrim(saldoandmik.konto)),6) = ('101100')
			);
			raise notice 'Raha kaes %',lnDeebet;


	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('92','Raha ja selle ekvivalendid perioodi lхpus',ifnull(lnDeebet,0),tdKpv, tnRekvId,lcReturn, 0); 
--= jooksva per summa (eelmine rida) - eelmise per summa (ьleeelmine rida)
			
	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('93','Raha ja selle ekvivalentide muutus',ifnull(lnDeebet,0)-ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0); 

	delete from tmp_sk_aruanned where ltrim(rtrim(timestamp)) = lcReturn and summa01 = 0;

--rahavoog lхpp

end if;

if tnLiik = 4 then
-- Kond pikk tulem

	raise notice 'Pikk tulem';
	raise notice 'Arvestan..';

	if tnRekvId = 63 and tnSvod = 1 then
		lnrekvId = 999;
	end if; 
	insert into  tmp_sk_aruanned (konto, summa01,  kpv, rekvid, timestamp, tyyp) 
			select saldoandmik.konto, sum(kr) - sum(db),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and val(left(ltrim(rtrim(konto)),1)) >= 3 and val(left(konto,1)) < 9
			group by saldoandmik.konto
			order by saldoandmik.konto;

	insert into  tmp_sk_aruanned (konto, summa01,  kpv, rekvid, timestamp, tyyp) 
			select saldoandmik.konto, sum(kr) + sum(db),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and val(left(ltrim(rtrim(konto)),1)) >= 9 and  val(left(konto,3)) <= 920
			group by saldoandmik.konto
			order by saldoandmik.konto;

	insert into  tmp_sk_aruanned (konto, summa01,  kpv, rekvid, timestamp, tyyp) 
			select saldoandmik.konto, sum(db) - sum(kr),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and val(left(ltrim(rtrim(konto)),3)) > 920 and val(left(konto,2)) < 93
			group by saldoandmik.konto
			order by saldoandmik.konto;

	insert into  tmp_sk_aruanned (konto, summa01,  kpv, rekvid, timestamp, tyyp) 
			select saldoandmik.konto, sum(db) + sum(kr),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and val(left(ltrim(rtrim(konto)),2)) >= 93 
			group by saldoandmik.konto
			order by saldoandmik.konto;


	raise notice 'Lisan nimetused..';
	
	for v_saldo in 
		select id, konto from tmp_sk_aruanned where timestamp = lcreturn
	loop
		select nimetus into lcString from library where kood = v_saldo.konto and library = 'KONTOD';
		UPDATE tmp_sk_aruanned set nimetus = ifnull(lcString,space(1)) where id = v_saldo.id;
	end loop;
	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3', 'Tegevustulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),1) = '3';

	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '30', 'Maksud ja sotsiaalkindlustusmaksed',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),2) = '30';

	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '300', 'Tulumaks',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '300';

	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3000', 'Fььsilise isiku tulumaks',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3000';

	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3001', 'Juriidilise isiku tulumaks',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3001';

	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '302', 'Sotsiaalmaks ja sotsiaalkindlustusmaksed',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '302';
	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3020', 'Sotsiaalmaks',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3020';
	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '30200', 'Sotsiaalmaks pensionikindlustuseks',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '30200';
	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '30201', 'Sotsiaalmaks ravikindlustuseks ',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '30201';
	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3025', 'Tццtuskindlustusmaksed',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and left(ltrim(rtrim(konto)),4) = '3025';
	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3025', 'Tццtuskindlustusmaksed',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and left(ltrim(rtrim(konto)),4) = '3025';
	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3026', 'Kogumispension',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and left(ltrim(rtrim(konto)),4) = '3026';
	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '303', 'Omandimaksud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and left(ltrim(rtrim(konto)),3) = '303';
	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '304', 'Maksud kaupadelt ja teenustelt',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '304';
	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3042', 'Aktsiisimaks',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3042';
	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '30420', 'Alkoholiaktsiis',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '30420';
	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '30422', 'Kьtuseaktsiis',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '30422';
	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3043', 'Hasartmдngumaks',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3043';
	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '305', 'Maksud vдliskaubanduselt ja tehingutelt',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '305';
	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '32', 'Kaupade ja teenuste mььk',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),2) = '32';
	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '320', 'Riigilхivud ',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '320';
	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '322', 'Tulud majandustegevusest',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '322';
	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3220', 'Tulud haridusalasest tegevusest',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3220';
	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3221', 'Tulud kultuuri- ja kunstialasest tegevusest',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3221';
	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3222', 'Tulud sprodi- ja puhkealasest tegevusest',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3222';
	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3223', 'Tulud tervishoiust',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3223';
	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3224', 'Tulud sotsiaalabialasest tegevusest',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3224';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3225', 'Elamu- ja kommunaaltegevuse tulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3225';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3227', 'Tulud korrakaitsest',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3227';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '323', 'Tulud majandustegevusest (jдrg)',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '323';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3230', 'Tulud transpordi- ja sidealasest tegevusest',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3230';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3232', 'Tulud muudelt majandusaladelt',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3232';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3233', 'Ььr ja rent',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3233';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3237', 'Хiguste mььk',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3237';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3238', 'Muu toodete ja teenuste mььk',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3238';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '35', 'Saadud toetused',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),2) = '35';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '350', 'Saadud sihtfinantseerimine ',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '350';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3500', 'Saadud sihtfinantseerimine tegevuskuludeks',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3500';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3502', 'Saadud sihtfinantseerimine pхhivara soetuseks',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3502';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '351', 'Pхhivara soetamiseks saadud sihtfinantseerimise amortisatsioon',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '351';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '352', 'Saadud mittesihtotstarbeline finantseerimine',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '352';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '38', 'Muud tulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),2) = '38';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '381', 'Kasum/kahjum pхhivara ja varude mььgist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '381';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3810', 'Kasum/kahjum kinnisvarainvesteeringute mььgist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3810';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3811', 'Kasum/kahjum materiaalse pхhivara mььgist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3811';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '38110', 'Kasum/kahjum maa mььgist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '38110';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '38111', 'Kasum/kahjum hoonete mььgist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '38111';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '38112', 'Kasum/kahjum rajatiste mььgist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '38112';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '38113', 'Kasum/kahjum kaitseotstarbelise pхhivara mььgist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '38113';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '38114', 'Kasum/kahjum masinate ja seadmete mььgist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '38114';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '38115', 'Kasum/kahjum info- ja kommunikatsioonitehnoloogia seadmete mььgist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '38115';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '38116', 'Kasum/kahjum muu amortiseeruva materiaalse pхhivara mььgist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '38116';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '38117', 'Kasum/kahjum mitteamortiseeruvate pхhivarade mььgist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '38117';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '38118', 'Kasum/kahjum lхpetamata ehituse mььgist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '38118';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3813', 'Kasum/kahjum immateriaalse pхhivara mььgist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3813';


		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '38130', 'Kasum/kahjum tarkvara mььgist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '38130';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '38132', 'Kasum/kahjum хiguste ja litsentside mььgist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '38132';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '38136', 'Kasum/kahjum muu immateriaalse pхhivara mььgist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '38136';


		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3814', 'Kasum/kahjum bioloogiliste varade mььgist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3814';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3818', 'Kasum/kahjum varude mььgist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3818';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '382', 'Muud tulud varadelt',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '382';


		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3823', 'Vхlalt arvestatud intressitulu',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3823';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3825', 'Tulud loodusressursside kasutamisest',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3825';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '388', 'Muud tulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '388';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3880', 'Trahvid',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3880';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3882', 'Saastetasud ja keskkonnale tekitatud kahju hьvitis',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3882';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3888', 'Eespool nimetamata muud tulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3888';

--Saldoandmikust (Sum: Kontod 4*kuni 64* Kreedit) - (Sum: Kontod 4* kuni 64* Deebet)

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp,tegev) 
			select '*', 'Tegevuskulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0,'399999' 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and val(left(ltrim(rtrim(konto)),1)) >= 4 and val(left(ltrim(rtrim(konto)),2)) <= 64;

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '4', 'Antud toetused',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),1) = '4';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '40', 'Subsiidiumid',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),2) = '40';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '41', 'Sotsiaaltoetused ',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),2) = '41';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '410', 'Sotsiaalkindlustustoetused ',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '410';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '4100', 'Pensionikindlustustoetused sotsiaalmaksutuludest ',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '4100';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '4102', 'Pensionikindlustustoetused mitte sotsiaalmaksutuludest ',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '4102';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '4105', 'Ravikindlustustoetused',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '4105';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '4108', 'Tццtuskindlustustoetused ',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '4108';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '413', 'Sotsiaalabitoetused ja muud toetused fььsilistele isikutele',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '413';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '4130', 'Peretoetused ',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '4130';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '4132', 'Toetused tццtutele',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '4132';
			
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '4133', 'Toetused puudega inimestele ja nende hooldajatele',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '4133';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '4134', 'Хppetoetused',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '4134';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '4138', 'Muud sotsiaalabitoetused ',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '4138';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '4139', 'Preemiad ja stipendiumid',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '4139';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '414', 'Sotsiaaltoetused avaliku sektori tццvхtjatele ',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '414';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '45', 'Muud toetused',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),2) = '45';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '450', 'Antud sihtfinantseerimine',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '450';
			
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '4500', 'Antud sihtfinantseerimine tegevuskuludeks',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '4500';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '4502', 'Antud sihtfinantseerimine pхhivara soetuseks',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '4502';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '452', 'Antud mittesihtotstarbeline finantseerimine',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '452';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '5', 'Tegevuskulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),1) = '5';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '50', 'Tццjхukulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),2) = '50';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '500', 'Tццtasu',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '500';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '5000', 'Valitavate ja ametisse nimetatud ametnikud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '5000';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '5001', 'Avaliku teenistuse ametnikud (va kaitsevдelased, piirivalve-, politseiametnikud)',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '5001';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '50010', 'Kхrgemad ametnikud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '50010';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '50014', 'Vanemametnikud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '50014';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '50015', 'Nooremametnikud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '50015';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '5002', 'Tццtajate tццtasu',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '5002';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '50020', 'Nхukogude ja juhatuste liikmed',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '50020';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '50021', 'Juhid',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '50021';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '50024', 'Tippspetsialistid',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '50024';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '50025', 'Keskastme spetsialistid',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '50025';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '50026', 'Хpetajad',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '50026';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '50028', 'Tццlised ja abiteenistujad',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '50028';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '5008', 'Muud koosseisuvдlised tццtasud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '5008';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '505', 'Erisoodustused',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '505';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '506', 'Maksud ja sotsiaalkindlustusmaksed',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '506';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '507', 'Tццjхukulude kapitaliseerimine',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '507';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '55', 'Majandamiskulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),2) = '55';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '5500', 'Administreerimiskulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '5500';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '5503', 'Lдhetuskulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '5503';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '55030', 'Lьhiajalised lдhetused',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '55030';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '55031', 'Pikaajalised lдhetused',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '55031';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '5504', 'Koolituskulud ',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '5504';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '5511', 'Kinnistute, hoonete ja ruumide majandamiskulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '5511';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '55110', 'Kinnistute, hoonete, ruumide majandamiskulud (va kinnisvarainvesteeringud)',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '55110';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '55112', 'Kinnisvarainvesteeringute haldamiskulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '55112';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '55113', 'Ььrile ja rendile antud kinnistute, hoonete, ruumide majandamiskulud (va kinnisvarainvesteeringud)',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '55113';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '5512', 'Rajatiste majandamiskulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '5512';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '5513', 'Sхidukite majandamiskulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '5513';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '55130', 'Maismaasхidukid',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '55130';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '55131', 'Хhusхidukid',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '55131';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '55132', 'Veesхidukid',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '55132';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '5514', 'Info- ja kommunikatsioonitehnoloogia kulud ',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '5514';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '5515', 'Inventari majandamiskulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '5515';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '5516', 'Tццmasinate ja seadmete majandamiskulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '5516';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '5521', 'Toiduained ja toitlustusteenused',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '5521';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '5522', 'Meditsiinikulud ja hьgieenikulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '5522';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '5523', 'Teavikute ja kunstiesemete kulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '5523';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '5524', 'Хppevahendite ja koolituse kulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '5524';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '5525', 'Kommunikatsiooni-, kultuuri- ja vaba aja sisustamise kulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '5525';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '5526', 'Sotsiaalteenused',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '5526';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '5529', 'Tootmiskulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '5529';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '5531', 'Kaitseotstarbeline varustus ja materjalid',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '5531';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '5532', 'Eri- ja vormiriietus (va kaitseotstarbelised kulud)',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '5532';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '5539', 'Muu erivarustus ja materjalid',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '5539';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '5540', 'Mitmesugused majanduskulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '5540';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '6', 'Muud kulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),1) = '6';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '60', 'Muud tegevuskulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),2) = '60';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '600', 'Riigisaladusega seotud kulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '600';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '601', 'Maksu-, lхivu- ja trahvikulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '601';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '6010', 'Maksud, lхivud, trahvid ',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '6010';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '6012', 'Ebatхenдoliselt laekuvad maksu-, lхivu- ja trahvinхuded',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '6012';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '6015', 'Edasiantud maksud, lхivud, trahvid',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '6015';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '605', 'Ebatхenдoliselt laekuvad nхuded',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '605';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '608', 'Muud tegevuskulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '608';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '61', 'Pхhivara amortisatsioon ja ьmberhindlus',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),2) = '61';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '611', 'Materiaalse pхhivara amortisatsioon',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '611';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '6110', 'Hoonete ja rajatiste amortisatsioon',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '6110';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '6114', 'Masinate ja seadmete amortisatsioon',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '6114';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '613', 'Immateriaalse pхhivara amortisatsioon',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '613';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '614', 'Kasum/kahjum bioloogiliste varade ьmberhindamisest',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '614';

--Saldoandmikust (Sum: Kontod 3*kuni 64* Kreedit) - (Sum: Kontod 3* kuni 64* Deebet)
			
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp, tegev) 
			select '*', 'Aruandeperioodi tegevustulem',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0,'614999' 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and val(left(ltrim(rtrim(konto)),1)) >= 3 and val(left(ltrim(rtrim(konto)),2)) <= 64;
			
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '65', 'Finantstulud ja -kulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),2) = '65';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '650', 'Intressikulu',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '650';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '652', 'Tulem osalustelt',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '652';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '655', 'Tulu hoiustelt ja vддrtpaberitelt',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '655';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '6550', 'Intressitulu',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '6550';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '6552', 'Kasum/kahjum finantsinvesteeringute mььgist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '6552';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '6554', 'Kasum/kahjum finantsinvesteeringute ьmberhindamisest',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '6554';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '658', 'Muud finantstulud ja -kulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '658';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '6580', 'Intressitulu',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '6580';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '6589', 'Muu finantstulu ja -kulu',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '6589';
--Saldoandmikust (Sum: Kontod 3*kuni 6* Kreedit) - (Sum: Kontod 3* kuni 6* Deebet)
			
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp, tegev) 
			select '*', 'Aruandeperioodi tulem',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0,'699999' 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and val(left(ltrim(rtrim(konto)),1)) >= 3 and val(left(ltrim(rtrim(konto)),1)) <= 6;

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '7', 'Netofinantseerimine eelarvest',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),1) = '7';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '70', 'Saadud siirded',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),2) = '70';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '71', 'Antud siirded',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),2) = '71';
--Saldoandmikust (Sum: Kontod 3*kuni 7* Kreedit) - (Sum: Kontod 3* kuni 7* Deebet)
			
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp,tegev) 
			select '*', 'Aruandeperioodi tulem ja siirded kokku',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 ,'719999'
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and val(left(ltrim(rtrim(konto)),1)) >= 3 and val(left(ltrim(rtrim(konto)),1)) <= 7;
			
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '9', 'Tдiendav informatsioon aruande koostamiseks',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),1) = '9';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '900', 'Tццtajate arv',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '900';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '9002', 'Avaliku teenistuse ametnikud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '9002';

		delete from tmp_sk_aruanned where summa01 = 0 and timestamp = lcReturn;

--koostame jдrjekord
		update 	tmp_sk_aruanned set tegev = konto where timestamp = lcReturn and not empty(konto) and empty (tegev);	


--	tulemiaruanne lхpp

end if;



if tnLiik = 3 then
-- Kond pikk bilanss

	raise notice 'Pikk bilanss';
	raise notice 'Arvestan..';

	if tnRekvId = 63 and tnSvod = 1 then	
		lnRekvId = 999;
	end if;


	insert into  tmp_sk_aruanned (konto, summa03, summa04, kpv, rekvid, timestamp, tyyp) 
			select saldoandmik.konto, sum(db), sum(kr),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik 
			where saldoandmik.aasta = year(tdKpv) and saldoandmik.kuu = month(tdKpv) 
			and val(left(ltrim(rtrim(saldoandmik.konto)),1)) < 3
			and (saldoandmik.rekvid in (SELECT distinct id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) 
				or  saldoandmik.rekvid = lnRekvId)
			group by saldoandmik.konto
			order by saldoandmik.konto;
/*
			select saldoandmik.konto, sum(db), sum(kr),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto and library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and saldoandmik.rekvid in (SELECT distinct id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId
			and val(left(ltrim(rtrim(saldoandmik.konto)),1)) < 3
			group by saldoandmik.konto
			order by saldoandmik.konto;
*/

--	select summa03 into lnDeebet from tmp_sk_aruanned where timestamp = lcReturn ;


	raise notice 'Lisan nimetused..';

	select sum(summa03) into lnDeebet from tmp_sk_aruanned where timestamp = lcReturn and konto = '100100';
	raise notice 'pank 1:%',lnDeebet;
	raise notice 'tdKpv%',tdKpv;


	
	for v_saldo in 
		select id, konto from tmp_sk_aruanned where ltrim(rtrim(timestamp)) = lcreturn
	loop
		select nimetus,tun5 into lcString,lnDb31 from library where kood = v_saldo.konto and library = 'KONTOD';
		if lnDb31 = 1 or lnDb31 = 3 then			
			UPDATE tmp_sk_aruanned set nimetus = ifnull(lcString,space(1)),
				summa01 = ifnull(summa03,0) - ifnull(summa04,0)	
			where id = v_saldo.id;
		else
			UPDATE tmp_sk_aruanned set nimetus = ifnull(lcString,space(1)),
				summa01 = ifnull(summa04,0) - ifnull(summa03,0)	
			where id = v_saldo.id;
		end if;
	end loop;

	select sum(summa03) into lnDeebet from tmp_sk_aruanned where timestamp = lcReturn and konto = '100100';
	raise notice 'lnDeebet %',lnDeebet;

	raise notice 'arvestan kondid';

	select sum(db),sum(kr) into lnDeebet, lnKreedit from saldoandmik 
	where aasta = year(tdKpv) and kuu = month(tdKpv) 
	and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
	and konto = '103500';

--	raise notice 'D 103500 %',lnDeebet;
--	raise notice 'K 103500 %',lnKreedit;

	update tmp_sk_aruanned set summa01 = ifnull(lnKreedit,0) - ifnull(lnDeebet,0) where timestamp = lcReturn and ltrim(rtrim(konto)) = '103500';
	
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '10', 'Kдibevara' ,sum(db) - sum(kr) - ifnull(lnDeebet,0) + ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and konto like '10%'; 

	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '103', 'Muud nouded ja ettemaksed' ,ifnull(sum(db) - sum(kr),0)-ifnull(lnDeebet,0)+ifnull(lnKreedit,0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and konto like '103%';
			

	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '100', 'Raha ja pangakontod' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and konto like '100%'; 
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '101', 'Finantsinvesteeringud' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and konto like  '101%';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1011', 'Kauplemisportfelli vддrtpaberid' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and konto like '1011%';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1012', 'Tдhtajani hoitavad vддrtpaberid' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and konto like '1012%';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1019', 'Muud finantsinvesteeringud' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1019';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '102', 'Maksu-, lхivu- ja trahvinхuded' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '102';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1020', 'Maksu-, lхivu ja trahvinхuded (bruto)' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1020';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1021', 'Ebatхenдoliselt laekuvad maksu-, lхivu ja trahvinхuded' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1021';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1030', 'Nouded ostjate vastu' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1030';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1031', 'Viitlaekumised' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1031';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1032', 'Laenu- ja liisingnхuded' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1032';

--Saldoandmikust (Sum: Kontod 1035* Deebet) - (Sum: Kontod 1035* Kreedit) - konto 103500 deebet + konto 103500 kreedit
			
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1035', 'Nхuded toetuste ja siirete eest' ,ifnull(sum(db) - sum(kr),0) - lnDeebet + lnKreedit, tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1035';
			
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1036', 'Muud nхuded' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1036';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1037', 'Maksude, lхivude, trahvide ettemaksed ' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1037';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1038', 'Ettemakstud toetused' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1038';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1039', 'Ettemakstud tulevaste perioodide kulud' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1039';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '108', 'Varud' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '108';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1080', 'Strateegilised varud' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1080';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1089', 'Ьle andmata varud ja ettemaksed varude eest' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1089';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '109', 'Mььgiootel pхhivara' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '109';
			
			select sum(db),sum(kr) into lnDb31,lnKr31  from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(konto)),2) = '15';

			
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp)  values 
			('15', 'Pohivara' ,ifnull(lndb31,0) - ifnull(lnkr31,0), tdKpv, tnRekvId,lcReturn, 0);
			
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '150', 'Osalused avaliku sektori ja sidusьksustes' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '150';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1502', 'Osalused tьtar- ja sidusettevхtjates' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1502';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '151', 'Finantsinvesteeringud' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '151';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1511', 'Investeerimisportfelli vддrtpaberid' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1511';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1512', 'Tдhtajani hoitavad vхlakirjad ' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1512';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1519', 'Muud finantsinvesteeringud' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1519';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '152', 'Maksu-, lхivu- ja trahvinхuded' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '152';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1520', 'Maksu-, lхivu ja trahvinхuded (bruto)' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1520';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1521', 'Ebatхenдoliselt laekuvad maksu-, lхivu ja trahvinхuded ' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1521';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '153', 'Muud nхuded ja ettemaksed' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '153';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1530', 'Nхuded ostjate vastu' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1530';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1532', 'Laenu- ja liisingnхuded' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1532';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1535', 'Nхuded toetuste eest' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1535';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1536', 'Muud pikaajalised nхuded' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1536';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1537', 'Antud sihtfinantseerimine' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1537';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '154', 'Kinnisvarainvesteeringud ' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '154';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '155', 'Materiaalne pхhivara ' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '155';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1551', 'Hooned ja rajatised ' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1551';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '15510', 'Hooned ja rajatised soetusmaksumuses ' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,5) = '15510';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '15511', 'Hoonete ja rajatiste kogunenud kulum ' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,5) = '15511';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1553', 'Kaitseotstarbeline pхhivara ' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1553';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1554', 'Masinad ja seadmed ' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1554';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '15540', 'Masinad ja seadmed soetusmaksumuses ' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,5) = '15540';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '15541', 'Masinate ja seadmete kogunenud kulum ' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,5) = '15541';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1555', 'Info- ja kommunikatsioonitehnoloogia seadmed ' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1555';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1556', 'Muu amortiseeruv materiaalne pхhivara' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1556';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1559', 'Kasutusele vхtmata varad ja ettemaksed' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1559';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '156', 'Immateriaalne pхhivara' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '156';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1560', 'Tarkvara' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1560';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1562', 'Хigused ja litsentsid' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1562';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1564', 'Arenguvдljaminekud ' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1564';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1565', 'Firmavддrtus ' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1565';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1566', 'Muu immateriaalne pхhivara  ' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1566';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1569', 'Kasutusele vхtmata varad ja ettemaksed ' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1569';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '157', 'Bioloogilised varad' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '157';


--Saldoandmikust (Sum: Kontod 2* Kreedit) - (Sum: Kontod 7* Deebet) + konto 103500 kreedit - konto 130500 deebet
/*
			select sum(db) into lnDb7  from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(konto)),1) = '7';

raise notice 'db 7 %',lnDb7;
*/
			select sum(kr), sum(db) into lnKr2,lnDb2  from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(konto)),1) = '2';

--raise notice 'kr 2 %',lnKr2;-
--raise notice 'db 2 %',lnKr2;
--raise notice 'deebet 103500 %',lnDeebet;
--raise notice 'kr 103500 %',lnKreedit;

--	select sum(summa03) into lnDeebet from tmp_sk_aruanned where timestamp = lcReturn and konto = '100100';
--	raise notice 'pank %',lnDeebet;


/*
			select sum(db) into lnDb31  from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(konto)),6) = '103500';
*/

--Saldoandmikust (Sum: Kontod 2* Kreedit) - (Sum: Kontod 2* Deebet) + konto 103500 kreedit - konto 103500 deebet
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) values
			('2', 'Kohustused ja netovara' ,ifnull(lnKr2,0) - ifnull(lnDb2,0) + ifnull(lnKreedit,0) - ifnull(lnDeebet,0), tdKpv, tnRekvId,lcReturn, 0);

	select sum(db),sum(kr) into lnDb2035,lnKr2035 from saldoandmik 
	where aasta = year(tdKpv) and kuu = month(tdKpv) 
	and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
	and konto = '203500';

	lnKr2035 = ifnull(lnKr2035,0);
	lnDb2035 = ifnull(lnDb2035,0);

	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '20', 'Luhiajalised kohustused' ,ifnull(sum(kr) - sum(db),0)-ifnull(lnKr2035,0) + ifnull(lnDb2035,0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and konto like  '20%';

	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '200', 'Saadud maksude, lхivude ja trahvide ettemaksed' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '200';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '201', 'Vхlad tarnijatele' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '201';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '202', 'Vхlad tццtajatele' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '202';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '203', 'Muud kohustused ja saadud ettemaksed' ,ifnull(sum(kr) - sum(db),0) - ifnull(LnKr2035,0)+ifnull(lnDb2035,0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and konto like '203%';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '2030', 'Maksu-, lхivu- ja trahvikohustused' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '2030';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '2032', 'Viitvхlad' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '2032';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '2035', 'Toetuste ja siirete kohustused' ,ifnull(sum(kr) - sum(db),0)-lnKr2035+lnDb2035, tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '2035';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '2036', 'Muud kohustused' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '2036';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '2038', 'Toetusteks saadud ettemaksed' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '2038';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '2039', 'Muud saadud ettemaksed ja tulevaste perioodide tulud' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '2039';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '206', 'Eraldised' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '206';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '208', 'Laenukohustused' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '208';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '2080', 'Emiteeritud vхlakirjad' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '2080';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '2081', 'Laenud' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '2081';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '2083', 'Faktooringkohustused ' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '2083';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '25', 'Pikaajalised kohustused' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,2) = '25';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '250', 'Vхlad tarnijatele' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '250';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '253', 'Muud kohustusd ja saadud ettemaksed' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '253';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '2530', 'Maksu-, lхivu- ja trahvikohustused' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '2530';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '2535', 'Toetuste andmise kohustused' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '2535';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '2536', 'Muud kohustused' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '2536';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '2538', 'Ettemaksed ja tulevaste perioodide tulud' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '2538';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '256', 'Eraldised' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '256';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '257', 'Sihtfinantseerimine' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '257';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '258', 'Laenukohustused' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '258';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '2580', 'Emiteeritud vхlakirjad' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '2580';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '2581', 'Laenud' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '2581';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp, tegev) values
			( '*', 'Eelarvesse kuuluv netovara' ,ifnull(lnKreedit,0) - ifnull(lnDeebet,0)+ifnull(lnKr2035,0)-ifnull(lnDb2035,0), tdKpv, tnRekvId,lcReturn, 0, '2582');

	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '290', 'Reservid' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '290';

	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '291', 'Aktsia- vхi osakapital ja ьlekurss' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '291';

	select sum(db),sum(kr) into lnDeebet,lnKreedit from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,1) in ('3','4','5','6') ;

--Saldoandmikust (Sum: Kontod 3*kuni 6* Kreedit) - (Sum: Kontod 3* kuni 6* Deebet)


	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) values
			( '299000', 'Aruandeperioodi tulem' ,lnKreedit - lnDeebet, tdKpv, tnRekvId,lcReturn, 0 ) ;


			select sum(summa01) into lnDb3 from tmp_sk_aruanned where timestamp = lcReturn and (konto like '298%' or konto like '299%');

/*
			select sum(db) into lnDb3 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (val(left(konto,3)) = 298 or val(left(konto,3)) = 299) ;

			select sum(db) into lnDb31 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and val(left(konto,2)) > 29 and val(left(konto,1)) <= 7;
*/
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) values
			( '29', 'Netovara' , ifnull(lnDb3,0), tdKpv, tnRekvId,lcReturn, 0 ) ;
				


--Saldoandmikust (Sum: Kontod 1* Deebet) - (Sum: Kontod 1* Kreedit) - konto 103500 deebet + konto 103500 kreedit

	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1', 'Varad' ,sum(db) - sum(kr) ,tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,1) = '1' and ltrim(rtrim(konto)) <> '103500'; 

	select sum(db), sum(kr) into lnDeebet, lnKreedit
		from saldoandmik 
		where aasta = year(tdKpv) and kuu = month(tdKpv) 
		and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
		and left(konto,5) = '29800';
--	raise notice 'pank %',lnDeebet;

--Saldoandmikust (Sum: Konto 29800* Kreedit) - (Sum: Konto 29800* Deebet)
	update 	tmp_sk_aruanned set summa01 = ifnull(lnKreedit,0) - ifnull(lnDeebet,0) where konto = '298000' and timestamp = lcReturn;	

	delete from tmp_sk_aruanned where  timestamp = lcReturn and summa01 = 0;


-- kustutame null tulemused
	update 	tmp_sk_aruanned set summa01 = ifnull(summa01,0) where timestamp = lcReturn and not empty(konto);	

	select sum(summa03) into lnDeebet from tmp_sk_aruanned where timestamp = lcReturn and konto = '100100';
	raise notice 'pank %',lnDeebet;

--koostame jдrjekord


	update 	tmp_sk_aruanned set tegev = konto where timestamp = lcReturn and not empty(konto);	
	update 	tmp_sk_aruanned set tegev = '298001' where timestamp = lcReturn and konto = '*';	
	update 	tmp_sk_aruanned set tegev = '298002' where timestamp = lcReturn and konto = '103500';	
	update 	tmp_sk_aruanned set tegev = '298003' where timestamp = lcReturn and konto = '203500';	


--	select sum(summa03) into lnDeebet from tmp_sk_aruanned where timestamp = lcReturn and konto = '100100';
--	raise notice 'pank %',lnDeebet;

--Saldoandmikust (Sum: Kontod 3*kuni 7* Kreedit) - (Sum: Kontod 3* kuni 7* Deebet)
-- bilanss kхik

end if;

if tnLiik = 2 then
-- Kond saldoaruanne
	delete from tmp_saldoandmik where rekvid = tnrekvId;

	if tnrekvId <> 63 or tnSvod <> 1 then

		raise notice 'Tavaline select ';
		lnRekvId = tnRekvId;
			
		INSERT INTO tmp_saldoandmik (nimetus, db , kr, konto , tegev , tp , allikas, rahavoo, timestamp, kpv, rekvid) 
		SELECT nimetus, sum(db) , sum(kr), konto , tegev , tp , allikas, rahavoo, lcReturn, date(), tnrekvId
		from  saldoandmik
		where aasta = year(tdKpv) and kuu = month(tdKpv)
		and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
		group by nimetus, konto, tegev, tp, allikas, rahavoo
		order by konto, tp, tegev, allikas, rahavoo;


	else


	if tnSvod = 1 and tnRekvId = 63 and (select count(*) from saldoandmik where rekvid = 999 and aasta = year(tdKpv) and kuu = month(tdKpv)) > 0 then
		-- tellitud kond aruanne, teeme select ja tagastame 

		raise notice 'Kond select ';
		lnRekvId = 999;
			
		INSERT INTO tmp_saldoandmik (nimetus, db , kr, konto , tegev , tp , allikas, rahavoo, timestamp, kpv, rekvid) 
		SELECT nimetus, db , kr, konto , tegev , tp , allikas, rahavoo, lcReturn, date(), tnrekvId
		from  saldoandmik
		where aasta = year(tdKpv) and kuu = month(tdKpv)
		and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId);

	else

		raise notice 'Kond puudub, teeme uuesti ';


		for v_omatp in 
				select distinct omatp from saldoandmik 
					where aasta = year(tdKpv) and kuu = month(tdKpv) 
					and left(omatp,4) = left(lcOmatp,4)
		loop	

				raise notice 'omaTP: %',v_omatp.omatp;


				INSERT INTO tmp_saldoandmik (nimetus, db , kr, konto , tegev , tp , allikas, rahavoo, timestamp, kpv, rekvid) 
				SELECT nimetus, SUM(db) , SUM(kr), konto , tegev , tp , allikas, rahavoo, lcReturn, date(), tnrekvId
				from  saldoandmik
				where aasta = year(tdKpv) and kuu = month(tdKpv)
				and ltrim(rtrim(omatp)) = ltrim(rtrim(v_omatp.omatp))	
				group by nimetus, konto , tegev , tp , allikas, rahavoo;


			for v_tp in 
					select distinct tp from saldoandmik 
						where aasta = year(tdKpv) and kuu = month(tdKpv) 
						and ltrim(rtrim(omatp)) = ltrim(rtrim(v_omatp.omatp))
						and ltrim(rtrim(tp)) <> ltrim(rtrim(omatp)) and left(ltrim(rtrim(tp)),4) = left(ltrim(rtrim(lcOmatp)),4)
			loop	

				-- kirjutame miinus summad 
				-- deebet

				raise notice 'arvestan tp.%',v_tp.tp;
				
				INSERT INTO tmp_saldoandmik (nimetus, db , kr, konto , tegev , tp , allikas, rahavoo, timestamp, kpv, rekvid) 
					SELECT nimetus, kr , db, konto , tegev , tp , allikas, rahavoo, lcReturn, date(), tnrekvId
						from  saldoandmik
						where aasta = year(tdKpv) and kuu = month(tdKpv)
						and ltrim(rtrim(omatp)) = ltrim(rtrim(v_omatp.OmaTp))
						and ltrim(rtrim(tp)) = ltrim(rtrim(v_tp.tp))
						and left(konto,1) = '1';

				-- kreedit
				INSERT INTO tmp_saldoandmik (nimetus, db , kr, konto , tegev , tp , allikas, rahavoo, timestamp, kpv, rekvid) 
					SELECT nimetus, kr , db, konto , tegev , tp , allikas, rahavoo, lcReturn, date(), tnrekvId
						from  saldoandmik
						where aasta = year(tdKpv) and kuu = month(tdKpv) 
						and ltrim(rtrim(omatp)) = ltrim(rtrim(v_tp.tp)) 
						and left(omatp,4) = left(lcOmatp,4)
						and ltrim(rtrim(tp)) = ltrim(rtrim(v_omatp.omatp))
						and left(konto,1) = '2';



				-- (vхrreldava saldoandmik (kхik kontod algusega 4 kuni 6, mille esitaja kood on TP kood on aruande koostaja kood (deebet miinus kreedit, 
				--	vдlja arvatud kontod 601000 ja 601001, mida ei vхeta ьldse arvesse olenemata TP koodist)))
				INSERT INTO tmp_saldoandmik (nimetus, db , kr, konto , tegev , tp , allikas, rahavoo, timestamp, kpv, rekvid) 
					SELECT nimetus, kr , db, konto , tegev , tp , allikas, rahavoo, lcReturn, date(), tnrekvId
					from  saldoandmik
					where aasta = year(tdKpv) and kuu = month(tdKpv) 
					and ltrim(rtrim(omatp)) = ltrim(rtrim(v_omatp.OmaTp))
					and ltrim(rtrim(tp)) = ltrim(rtrim(v_tp.tp))
					and left(konto,1) in ('4','5','6') and konto not in ('601000','601001');

				--(esitaja saldoandmik sum (kхik kontod algusega 3, mille TP kood on vхrreldava kood (kreedit miinus deebet)))

				INSERT INTO tmp_saldoandmik (nimetus, db , kr, konto , tegev , tp , allikas, rahavoo, timestamp, kpv, rekvid) 
					SELECT nimetus, kr , db, konto , tegev , tp , allikas, rahavoo, lcReturn, date(), tnrekvId
						from  saldoandmik
						where aasta = year(tdKpv) and kuu = month(tdKpv) 
						and ltrim(rtrim(omatp)) = ltrim(rtrim(v_tp.tp))
						and left(omatp,4) = left(lcOmatp,4)
						and ltrim(rtrim(tp)) = ltrim(rtrim(v_omatp.omatp))
						and left(konto,1) = '3';
						

				--(esitaja saldoandmik sum (kхik kontod algusega 7, mille TP kood on vхrreldava kood (deebet miinus kreedit)))
				INSERT INTO tmp_saldoandmik (nimetus, db , kr, konto , tegev , tp , allikas, rahavoo, timestamp, kpv, rekvid) 
					SELECT nimetus, kr , db, konto , tegev , tp , allikas, rahavoo, lcReturn, date(), tnrekvId
					from  saldoandmik
					where aasta = year(tdKpv) and kuu = month(tdKpv) 
					and ltrim(rtrim(omatp)) = ltrim(rtrim(v_omatp.OmaTp))
					and ltrim(rtrim(tp)) = ltrim(rtrim(v_tp.tp))
					and left(konto,2) = '70';

					
				--(vхrreldava saldoandmik (kхik kontod algusega 7, mille TP kood on aruande koostaja kood (kreedit miinus deebet)))
				INSERT INTO tmp_saldoandmik (nimetus, db , kr, konto , tegev , tp , allikas, rahavoo, timestamp, kpv, rekvid) 
					SELECT nimetus, kr , db, konto , tegev , tp , allikas, rahavoo, lcReturn, date(), tnrekvId
						from  saldoandmik
						where aasta = year(tdKpv) and kuu = month(tdKpv) 
						and left(omatp,4) = left(lcOmatp,4)
						and ltrim(rtrim(omatp)) = ltrim(rtrim(v_tp.tp))
						and ltrim(rtrim(tp)) = ltrim(rtrim(v_omatp.omatp))
						and left(konto,2) = '71';




			end loop;
		end loop;

			select sum(db) into lnDeebet from tmp_saldoandmik 
				where ltrim(rtrim(timestamp)) = ltrim(rtrim(lcreturn)) and tyyp = 0 
				and left(tp,4) = left(lcOmatp,4) and left(konto,1) = '7'; 
			select sum(kr) into lnKreedit from tmp_saldoandmik 
				where ltrim(rtrim(timestamp)) = ltrim(rtrim(lcreturn)) and tyyp = 0 
				and left(tp,4) = left(lcOmatp,4) and left(konto,1) = '7'; 

			if lnDeebet = lnKreedit then
				delete from tmp_saldoandmik where ltrim(rtrim(timestamp)) = ltrim(rtrim(lcreturn)) and left(konto,1) = '7';		
			end if;


			INSERT INTO tmp_saldoandmik (nimetus, db , kr, konto , tegev , tp , allikas, rahavoo, timestamp, kpv, rekvid, tyyp) 
			SELECT nimetus, SUM(db) , SUM(kr), konto , tegev , tp , allikas, rahavoo, lcReturn, date(), tnrekvId,1
				from  tmp_saldoandmik
				where ltrim(rtrim(timestamp)) = ltrim(rtrim(lcreturn)) and tyyp = 0
				group by nimetus, konto , tegev , tp , allikas, rahavoo;

			delete from tmp_saldoandmik where rekvid = tnRekvId and tyyp <> 1 or (db - kr = 0);


		if tnSvod = 1 and tnRekvId = 63 and (select count(*) from saldoandmik where rekvid = 0 and aasta = year(tdKpv) and kuu = month(tdKpv)) = 0 then
			-- salvestame kond saldoandmik
			raise notice 'salvestame kond saldoandmik ';
			
				insert into saldoandmik (nimetus, db,kr,konto,tegev,tp,	allikas,rahavoo ,kpv,aasta,kuu, rekvid,omatp,tyyp)
				select nimetus, db,kr, konto, tegev, tp, allikas,rahavoo ,tdkpv, year(tdKpv), month(tdKpv), 999,lcOmatp,0 
				from tmp_saldoandmik
				where timestamp = lcreturn and rekvid = tnRekvId;

		end if;

	end if;
	end if;
end if;

if tnLiik = 1 then

	-- Saldode vordlemine
	raise notice 'Saldode vordlemine ';
	if tnSvod = 1 then
		cOmaTp = '%';
	else
		cOmaTp = ltrim(rtrim(lcOmatp))+'%';
	end if;

	for v_omatp in 
		select distinct omatp from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and left(omatp,4) = '1851'
			and omatp like cOmaTp	
	loop	

		raise notice 'algus, omaTP: %',v_omatp.omatp;
		lcOmaTp = ltrim(rtrim(v_omatp.omatp));

	raise notice 'algus, omaTP: %',v_omatp.omatp;
	raise notice 'algus, lcomaTP: %',lcOmaTp;

	update tmp_sk_aruanned set tyyp = 2 where tyyp = 1 and timestamp = lcReturn;

	for v_tp in 
		select distinct tp from saldoandmik where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and ltrim(rtrim(saldoandmik.tp)) <> ltrim(rtrim(saldoandmik.omatp)) and left(ltrim(rtrim(saldoandmik.tp)),4) = left(ltrim(rtrim(lcomatp)),4)
	loop	

		raise notice 'V-tp.tp %',v_tp.tp;

		-- tp parnerid
		-- (esitaja saldoandmik sum (kхik kontod algusega 1, mille TP kood on vхrreldava kood (deebet miinus kreedit)))
		insert into tmp_sk_aruanned (omaTp, tp, summa01, kpv, rekvid, timestamp, tyyp) 
			select ltrim(rtrim(lcomatp)), ltrim(rtrim(v_tp.tp)), db - kr, tdKpv, tnRekvId, lcreturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and ltrim(rtrim(saldoandmik.omatp)) = ltrim(rtrim(lcomatp))
			and ltrim(rtrim(saldoandmik.tp)) = ltrim(rtrim(v_tp.tp))
			and left(ltrim(rtrim(saldoandmik.konto)),1) = '1';


		-- (vхrreldava saldoandmik (kхik kontod algusega 2, mille TP kood on aruande koostaja kood (kreedit miinus deebet)))

		insert into tmp_sk_aruanned (omaTp, tp, summa02,  kpv, rekvid, timestamp, tyyp) 
			select ltrim(rtrim(lcomatp)), ltrim(rtrim(v_tp.tp)), kr - db, tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and ltrim(rtrim(omatp)) = ltrim(rtrim(v_tp.tp)) 
			and ltrim(rtrim(tp)) = ltrim(rtrim(lcomatp))
			and left(ltrim(rtrim(konto)),1) = '2';

	
		-- (vхrreldava saldoandmik (kхik kontod algusega 1, mille TP kood on aruande koostaja kood (deebet miinus kreedit)))

		insert into tmp_sk_aruanned (omaTp, tp, summa03,  kpv, rekvid, timestamp, tyyp) 
			select ltrim(rtrim(lcomatp)), ltrim(rtrim(v_tp.tp)), db - kr, tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and ltrim(rtrim(omatp)) = ltrim(rtrim(v_tp.tp))
			and ltrim(rtrim(tp)) = lcomatp
			and left(ltrim(rtrim(konto)),1) = '1';




		-- (esitaja saldoandmik sum (kхik kontod algusega 2, mille TP kood on vхrreldava kood (kreedit miinus deebet)))

		insert into tmp_sk_aruanned (omaTp, tp, summa04, kpv, rekvid, timestamp, tyyp) 
			select ltrim(rtrim(lcomatp)), ltrim(rtrim(v_tp.tp)), kr - db, tdKpv, tnRekvId, lcreturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and ltrim(rtrim(omatp)) = ltrim(rtrim(lcomatp))
			and ltrim(rtrim(tp)) = ltrim(rtrim(v_tp.tp))
			and left(ltrim(rtrim(konto)),1) = '2';




		-- (vхrreldava saldoandmik (kхik kontod algusega 4 kuni 6, mille esitaja kood on TP kood on aruande koostaja kood (deebet miinus kreedit, 
		--	vдlja arvatud kontod 601000 ja 601001, mida ei vхeta ьldse arvesse olenemata TP koodist)))
		insert into tmp_sk_aruanned (omaTp, tp, summa05,  kpv, rekvid, timestamp, tyyp) 
			select ltrim(rtrim(lcomatp)), ltrim(rtrim(v_tp.tp)), db - kr, tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and ltrim(rtrim(omatp)) = ltrim(rtrim(v_tp.tp)) 
			and ltrim(rtrim(tp)) = ltrim(rtrim(lcomatp))
			and left(ltrim(rtrim(konto)),1) in ('4','5','6') and ltrim(rtrim(konto)) not in ('601000','601001');

		--(esitaja saldoandmik sum (kхik kontod algusega 3, mille TP kood on vхrreldava kood (kreedit miinus deebet)))

		insert into tmp_sk_aruanned (omaTp, tp, summa06, kpv, rekvid, timestamp, tyyp) 
			select ltrim(rtrim(lcomatp)), ltrim(rtrim(v_tp.tp)), kr - db, tdKpv, tnRekvId, lcreturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and ltrim(rtrim(omatp)) = ltrim(rtrim(lcomatp))
			and ltrim(rtrim(tp)) = ltrim(rtrim(v_tp.tp))
			and left(ltrim(rtrim(konto)),1) = '3';

		--(esitaja saldoandmik sum (kхik kontod algusega 4-6, mille TP kood on vхrreldava kood (deebet miinus kreedit), 
		--vдlja arvatud kontod 601000 ja 601001, mida ei vхeta ьldse arvesse, olenemata TP koodist))

		insert into tmp_sk_aruanned (omaTp, tp, summa07, kpv, rekvid, timestamp, tyyp) 
			select ltrim(rtrim(lcomatp)), ltrim(rtrim(v_tp.tp)), db-kr, tdKpv, tnRekvId, lcreturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and ltrim(rtrim(omatp)) = ltrim(rtrim(lcomatp))
			and ltrim(rtrim(tp)) = ltrim(rtrim(v_tp.tp))
			and left(ltrim(rtrim(konto)),1) in ('4','5','6') and ltrim(rtrim(konto)) not in ('601000','601001');

		--(vхrreldava saldoandmik (kхik kontod algusega 3, mille mille TP kood on aruande koostaja kood (kreedit miinus deebet)))
		insert into tmp_sk_aruanned (omaTp, tp, summa08,  kpv, rekvid, timestamp, tyyp) 
			select ltrim(rtrim(lcomatp)), ltrim(rtrim(v_tp.tp)), kr-db, tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and ltrim(rtrim(omatp)) = ltrim(rtrim(v_tp.tp)) 
			and ltrim(rtrim(tp)) = ltrim(rtrim(lcomatp))
			and left(ltrim(rtrim(konto)),1) = '3';
		--(esitaja saldoandmik sum (kхik kontod algusega 7, mille TP kood on vхrreldava kood (deebet miinus kreedit)))
		insert into tmp_sk_aruanned (omaTp, tp, summa09, kpv, rekvid, timestamp, tyyp) 
			select ltrim(rtrim(lcomatp)), ltrim(rtrim(v_tp.tp)), db-kr, tdKpv, tnRekvId, lcreturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and ltrim(rtrim(omatp)) = ltrim(rtrim(lcomatp))
			and ltrim(rtrim(tp)) = ltrim(rtrim(v_tp.tp))
			and left(ltrim(rtrim(konto)),1) = '7';
		--(vхrreldava saldoandmik (kхik kontod algusega 7, mille TP kood on aruande koostaja kood (kreedit miinus deebet)))
		insert into tmp_sk_aruanned (omaTp, tp, summa10,  kpv, rekvid, timestamp, tyyp) 
			select ltrim(rtrim(lcomatp)), ltrim(rtrim(v_tp.tp)), kr-db, tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and ltrim(rtrim(omatp)) = ltrim(rtrim(v_tp.tp)) 
			and ltrim(rtrim(tp)) = ltrim(rtrim(lcomatp))
			and left(ltrim(rtrim(konto)),1) = '7';

		--(esitaja saldoandmik sum (kхik kontod algusega 1 kuni 7, mille TP kood on vхrreldava kood (deebet miinus kreedit) 
		-- vдlja arvatud kontod 601000 ja 601001, mida ei vхeta ьldse arvesse olenemata TP koodist))

		insert into tmp_sk_aruanned (omaTp, tp, summa11, kpv, rekvid, timestamp, tyyp) 
			select ltrim(rtrim(lcomatp)), ltrim(rtrim(v_tp.tp)), db-kr, tdKpv, tnRekvId, lcreturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and ltrim(rtrim(omatp)) = ltrim(rtrim(lcomatp))
			and ltrim(rtrim(tp)) = ltrim(rtrim(v_tp.tp))
			and left(ltrim(rtrim(konto)),1) in ('1','2','3','4','5','6','7') and ltrim(rtrim(konto)) not in ('601000','601001');
		--(vхrreldava saldoandmik (kхik kontod algusega 1-7, mille TP kood on aruande koostaja kood (kreedit miinus deebet) 
		--vдlja arvatud kontod 601000 ja 601001, mida ei vхeta ьldse arvesse olenemata TP koodist))
		insert into tmp_sk_aruanned (omaTp, tp, summa12,  kpv, rekvid, timestamp, tyyp) 
			select ltrim(rtrim(lcomatp)), ltrim(rtrim(v_tp.tp)), kr-db, tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and ltrim(rtrim(omatp)) = ltrim(rtrim(v_tp.tp)) 
			and ltrim(rtrim(tp)) = ltrim(rtrim(lcomatp))
			and left(ltrim(rtrim(konto)),1) in ('1','2','3','4','5','6','7') and ltrim(rtrim(konto)) not in ('601000','601001');

	end loop;
	-- Teeme kond

	insert into tmp_sk_aruanned (omaTp, tp, summa01, summa02, summa03,summa04,summa05, summa06, kpv, rekvid, timestamp, tyyp) 
		select omaTp, tp, sum(summa01-summa02), sum(summa03-summa04),sum(summa05-summa06), sum(summa07-summa08),sum(summa09-summa10),sum(summa11-summa12),
			Kpv, RekvId,timestamp,1 from tmp_sk_aruanned 
			where ltrim(rtrim(timestamp)) = ltrim(rtrim(lcReturn))
			and tyyp = 0
			group by omatp, tp, kpv, rekvid, timestamp
			order by omatp, tp, kpv, rekvid;

	delete from tmp_sk_aruanned where ltrim(rtrim(timestamp)) = ltrim(rtrim(lcReturn)) and tyyp = 0;


	end loop;

end if;


RETURN lcReturn;


end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_saldoandmik_aruanned(integer, date, integer, integer, integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_saldoandmik_aruanned(integer, date, integer, integer, integer, integer) TO vlad;
GRANT EXECUTE ON FUNCTION sp_saldoandmik_aruanned(integer, date, integer, integer, integer, integer) TO public;

