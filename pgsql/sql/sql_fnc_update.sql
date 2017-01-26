
CREATE OR REPLACE FUNCTION asd(character varying, integer, integer, date)
  RETURNS numeric AS
$BODY$DECLARE tcKontogrupp alias for $1;
	tnAsutusid alias for $2;
	tnrekvid alias for $3;
	tdKpv alias for $4;
	lnAlg numeric (12,4);
	lnDb numeric (12,4);
	lnKr numeric (12,4);
begin	-- arv algsaldo
/*
	select sum(algsaldo) into lnAlg from library l inner join subkonto s on l.id = s.kontoId 
		where s.rekvId = tnRekvId 
		and s.asutusId = tnAsutusId
		and l.kood like ltrim(rtrim(tcKontogrupp))+'%';
*/
	-- arv. deebet kaibed
	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnDb from journal1 left outer join dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 1)
		where deebet like ltrim(rtrim(tcKontogrupp))+'%'
		and parentid in (select id from journal where rekvId = tnRekvId and kpv <= tdKpv and asutusid = tnAsutusid);

	-- arv. kreedit kaibed
	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnKr from journal1 left outer join dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 1)
		where kreedit like ltrim(rtrim(tcKontogrupp))+'%'
		and parentid in (select id from journal where rekvId = tnRekvId and kpv <= tdKpv and asutusid = tnAsutusid);
	return ifnull(lnAlg,0) + ifnull(lnDb,0) - ifnull(lnKr,0);
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION asd(character varying, integer, integer, date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION asd(character varying, integer, integer, date) TO vlad;
GRANT EXECUTE ON FUNCTION asd(character varying, integer, integer, date) TO public;
GRANT EXECUTE ON FUNCTION asd(character varying, integer, integer, date) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION asd(character varying, integer, integer, date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION asd(character varying, integer, integer, date) TO dbadmin;
GRANT EXECUTE ON FUNCTION asd(character varying, integer, integer, date) TO dbvaatleja;



CREATE OR REPLACE FUNCTION dateasint(date)
  RETURNS integer AS
$BODY$

DECLARE 
	tdKpv alias for $1;
	lnDate int;
	lcKuu varchar(2);
	lcPaev varchar(2);
begin
	lnDate = 0;
	if month(tdKpv) < 10 then
		lcKuu = '0'+str(month(tdKpv),1); 
	else
		lcKuu = str(month(tdKpv),2); 
	end if;
	if day(tdKpv) < 10 then
		lcPaev = '0'+str(day(tdKpv),1);
	else
		lcPaev = str(day(tdKpv),2);
	end if;
	if not empty(tdKpv) then
		lnDate = val(str(year(tdKpv),4)+lcKuu+lcPaev);
	end if;

	
	return lnDate;
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION dateasint(date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION dateasint(date) TO public;


CREATE OR REPLACE FUNCTION dk(character varying, integer, date, date)
  RETURNS numeric AS
$BODY$

DECLARE tcKontogrupp alias for $1;
	tnrekvid alias for $2;
	tdKpv1 alias for $3;
	tdKpv2 alias for $4;
	lnDb numeric (12,4);
begin	

	-- arv. deebet kaibed
	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnDb from journal1 left outer join dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 1)
		where deebet like ltrim(rtrim(tcKontogrupp))+'%'
		and parentid in (select id from journal where rekvId = tnRekvId and kpv >= tdKpv1 and kpv <= tdKpv2);

/*
	-- arv. kreedit kaibed
	select sum(summa) into lnKr from journal1 
		where kreedit like ltrim(rtrim(tcKontogrupp))+'%'
		and parentid in (select id from journal where rekvId = tnRekvId and kpv >= tdKpv1 and kpv <= tdKpv2);
*/

	return ifnull(lnDb,0);
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION dk(character varying, integer, date, date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION dk(character varying, integer, date, date) TO vlad;
GRANT EXECUTE ON FUNCTION dk(character varying, integer, date, date) TO public;
GRANT EXECUTE ON FUNCTION dk(character varying, integer, date, date) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION dk(character varying, integer, date, date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION dk(character varying, integer, date, date) TO dbadmin;
GRANT EXECUTE ON FUNCTION dk(character varying, integer, date, date) TO dbvaatleja;



CREATE OR REPLACE FUNCTION empty(date)
  RETURNS boolean AS
$BODY$

begin

	if $1 is null or year($1) <  year (now()::date)-100 then

		return true;

	else

		return false;

	end if;

end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION empty(date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION empty(date) TO vlad;
GRANT EXECUTE ON FUNCTION empty(date) TO public;
GRANT EXECUTE ON FUNCTION empty(date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION empty(date) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION empty(date) TO dbadmin;
GRANT EXECUTE ON FUNCTION empty(date) TO dbvaatleja;


CREATE OR REPLACE FUNCTION fnc_aasta_kontrol(integer, date)
  RETURNS integer AS
$BODY$

declare 

	tnRekvid alias for $1;

	tdKpv alias for $2;
	
	lnresult int;	

begin

	lnresult = 1;

	if (select count(id) from aasta where kuu = month(tdkpv) and aasta = year(tdkpv) and rekvid = tnrekvId and kinni = 1) = 1 or year(tdKpv) < 2008 then
		raise notice 'Ei tohi selles periodis töötada';
		lnresult = 0;
	end if;

         return  lnresult;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION fnc_aasta_kontrol(integer, date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION fnc_aasta_kontrol(integer, date) TO vlad;
GRANT EXECUTE ON FUNCTION fnc_aasta_kontrol(integer, date) TO public;



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
BEGIN

select id into lnId from avans2 where parentid = tnId order by id limit 1;
raise notice 'LnId %',lnId;

select dokvaluuta1.kuurs into lnDokValuuta from dokvaluuta1 where dokid = lnId and dokliik = 5;
lnDokValuuta = ifnull(lnDokValuuta,1);
raise notice 'lnDokValuuta %',lnDokValuuta;

-- summa, korkonto
select ifnull(dokprop.konto,space(20)) as konto,avans1.asutusId, avans1.rekvId, avans1.number into v_avans
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
GRANT EXECUTE ON FUNCTION fnc_avansijaak(integer) TO public;
GRANT EXECUTE ON FUNCTION fnc_avansijaak(integer) TO vlad;
GRANT EXECUTE ON FUNCTION fnc_avansijaak(integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION fnc_avansijaak(integer) TO dbpeakasutaja;


CREATE OR REPLACE FUNCTION fnc_currentkuurs(date)
  RETURNS numeric AS
$BODY$

DECLARE 
	tdKpv alias for $1;
	lnKuurs numeric(14,4);
	lnPohiKuurs numeric(14,4);
	inId int;
begin
	-- pohi tingimused
	
	if year(tdKpv) < 2011 then
		lnKuurs = 1;
	else
		lnKuurs = 15.6466;
	end if;
	-- otsime pohivaluuta

	select valuuta1.kuurs into lnPohiKuurs 
		from library inner join valuuta1 on library.id = valuuta1.parentid
		where valuuta1.alates <= tdKpv and valuuta1.kuni >= tdKpv and 
		library.kood = fnc_currentvaluuta(tdKpv);

	lnKuurs = ifnull(lnPohiKuurs,lnKuurs);
	
	return lnKuurs;
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION fnc_currentkuurs(date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION fnc_currentkuurs(date) TO public;
GRANT EXECUTE ON FUNCTION fnc_currentkuurs(date) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION fnc_currentkuurs(date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION fnc_currentkuurs(date) TO dbvaatleja;



CREATE OR REPLACE FUNCTION fnc_currentvaluuta(date)
  RETURNS character varying AS
$BODY$

DECLARE 
	tdKpv alias for $1;
	lcValuuta varchar(20);
	lcPohiValuuta varchar(20);
begin
	-- pohi tingimused
	
	if year(tdKpv) < 2011 then
		lcValuuta = 'EEK';
	else
		lcValuuta = 'EUR';
	end if;
	-- otsime pohivaluuta
	select kood into lcPohiValuuta from library where library = 'VALUUTA' and tun1 = 1 
		and (tun4 <= dateasint(tdKpv) or empty(tun4)) 
		and (tun5 >= dateasint(tdKpv) or empty(tun5));

	lcValuuta = ifnull(lcPohiValuuta,lcValuuta);
	
	return lcValuuta;
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION fnc_currentvaluuta(date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION fnc_currentvaluuta(date) TO public;
GRANT EXECUTE ON FUNCTION fnc_currentvaluuta(date) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION fnc_currentvaluuta(date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION fnc_currentvaluuta(date) TO dbvaatleja;


CREATE OR REPLACE FUNCTION fnc_get_asutuse_staatus(integer, integer)
  RETURNS integer AS
$BODY$

DECLARE tnRekvid alias for $1;
	tnOmaRekv alias for $2;

	lnReturn integer;
	lnParentId integer;
	lnParentIdSub integer;


begin	


lnReturn = 999; -- tase
lnParentId = 0;


select parentId into lnParentId from rekv where id = tnOmaRekv;
select parentId into lnParentIdSub from rekv where id = tnRekvId;

--raise notice 'tnRekvId rekvid %',tnRekvId;
--raise notice 'tnOmaRekv rekvid %',tnOmaRekv;
--raise notice 'lnParentId %',lnParentId;
--raise notice 'lnParentIdSub %',lnParentIdSub;


if lnParentIdSub = 0 then
	-- eelarve pidaja
	lnReturn = 0;
--	raise notice 'eelarve pidaja %',lnReturn;
end if;

if tnRekvId = tnOmaRekv then
	-- omaasutus
	lnReturn = 3;
--	raise notice 'omaasutus %',lnReturn;
end if;


if lnreturn = 999 and (tnRekvId = lnparentId or tnRekvId = tnOmaRekv) then
	-- meie ülemasutus
	lnReturn = 1; 
--	raise notice 'meie ülemasutus %',lnReturn;

end if;
if lnreturn = 999 and lnParentIdSub = tnOmaRekv  then
	--meie madala asutus
	lnReturn = 4;
--	raise notice 'meie madala asutus %',lnReturn;
end if;

if lnParentIdSub <> tnOmaRekv then
--		raise notice 'lnParentIdSub <> tnRekvId';
	if (select parentid from rekv where id = lnParentIdSub) = tnOmaRekv then
--		raise notice 'sub alasutus';
		lnReturn = 4;				
	end if;
end if;


if lnreturn = 999 then 
--	if (select count(id) from rekv where parentid = tnrekvId) > 0 and 

--	raise notice 'muud';
	lnReturn = 2;
end if;

RETURN lnReturn;

end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION fnc_get_asutuse_staatus(integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION fnc_get_asutuse_staatus(integer, integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION fnc_get_asutuse_staatus(integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION fnc_get_asutuse_staatus(integer, integer) TO dbvaatleja;


CREATE OR REPLACE FUNCTION fnc_getomatp(integer, integer)
  RETURNS character AS
$BODY$
DECLARE 
	tnrekvid alias for $1;
	tnAasta alias for $2;
	lcOmaTp character(20);
begin
lcOmaTp = '185101';

		SELECT TP INTO lcOmaTp FROM Aa WHERE Aa.parentid = tnrekvid  AND Aa.kassa = 2 ORDER BY ID DESC LIMIT 1;
		lcOmaTp = ifnull(lcOmaTp,'');
	return lcOmaTp;
end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION fnc_getomatp(integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION fnc_getomatp(integer, integer) TO public;
GRANT EXECUTE ON FUNCTION fnc_getomatp(integer, integer) TO vlad;
GRANT EXECUTE ON FUNCTION fnc_getomatp(integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION fnc_getomatp(integer, integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION fnc_getomatp(integer, integer) TO dbvaatleja;


CREATE OR REPLACE FUNCTION fnc_valkehtivus(varchar, date)
  RETURNS numeric AS
$BODY$

DECLARE 
	tcValuuta alias for $1;
	tdKpv alias for $2;
	lnreturn int;
	inId int;
begin
	-- pohi tingimused
	lnReturn = 0;
	
	if year(tdKpv) < 2011 and tcValuuta = 'EEK' then
		lnReturn = 1;
	else
		-- otsime valuuta
		if (select count(id) from library where library = 'VALUUTA' and kood = tcValuuta 
			and (empty(library.tun4) or library.tun4 <= dateasint(tdKpv)) 
			and  (empty(library.tun5) or library.tun5 >= dateasint(tdKpv))) > 0 then
			lnReturn = 1;
		end if;
	end if;	
	return lnReturn;
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION fnc_valkehtivus(varchar, date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION fnc_valkehtivus(varchar, date) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION fnc_valkehtivus(varchar, date) TO dbkasutaja;



CREATE OR REPLACE FUNCTION gen_lausend_arv(integer)
  RETURNS integer AS
$BODY$
declare 
	tnId alias for $1;

	lnJournalNumber int4;
	lcDbKonto varchar(20);
	lcKrKonto varchar(20);
	lcDbTp varchar(20);
	lcKrTp varchar(20);
	lcKood5 varchar(20);
	lnAsutusId int4;
	lnJournal int4;
	lcKbmTp varchar(20);
	lcDbKbmTp varchar(20);
	v_arv arv%rowtype;
	v_dokprop dokprop%rowtype;
	v_aa aa%rowtype;
	v_arv1 record;
	v_asutus asutus%rowtype;
	lnUserId int;
	lnKontrol int;
	lcAllikas varchar(20);
	lcviga varchar;
	lnJournal1 int;
	lcOmaTP varchar(20);
	lcValuuta varchar(20);
	lnKuurs numeric (14,4);
begin


	select * into v_arv from arv where id = tnId;
	If v_arv.doklausid = 0 then
		Return 0;
	End if;

	select recalc into lnKontrol from rekv where id = v_arv.rekvid;
	lcAllikas = 'LE-P';
--	raise notice 'lnKontrol: %',lnKontrol;

	select * into v_dokprop from dokprop where id = v_arv.doklausid limit 1;
	If not Found or v_dokprop.registr = 0 then
		Return 0;
	End if;

	If v_arv.journalid > 0 then
		update arv set journalId = 0 where id = v_arv.id;
		select number into lnJournalNumber from journalId where journalId = v_arv.journalId;
		if ifnull(lnJournalNumber,0) > 0 then
			if sp_del_journal(v_arv.journalid,1) = 0 then
				Return 0;
			End if;
		end if;
	End if;
	select * into v_aa from aa where parentid = v_arv.rekvId limit 1;	
	select id into lnUserId from userid where userid.rekvid = v_arv.rekvid and userid.kasutaja = CURRENT_USER::varchar;

	lnJournal:= sp_salvesta_journal(0, v_arv.rekvId, v_arv.UserId, v_arv.kpv, v_arv.asutusId, ltrim(rtrim(v_dokprop.selg))+' '+ltrim(rtrim(v_arv.lisa)), 
		v_arv.number,space(1),v_arv.id) ;

--	lisatud 01/02/2005
	Select tp into lcDbKbmTp from asutus where id = v_arv.Asutusid;
	lcDbKbmTp:= ifnull(lcDbKbmTp,'800599');
	lcKrTp:=ifnull(lcDbKbmTp,'800599');
	for v_arv1 in 
		select arv1.*, ifnull(dokvaluuta1.valuuta,'EEK')::varchar as valuuta, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs 
			from arv1 left outer join dokvaluuta1 on (arv1.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 2) 
			where arv1.parentid = v_arv.Id
	loop
	--	lisatud 18/03/2005
		if not empty(v_arv1.tp) then 
			lcDbKbmTp:= v_arv1.tp;
		end if;
		if not empty(v_arv1.kood2) then
				lcAllikas = v_arv1.kood2;
		end if;
		lcKood5 = v_arv1.kood5;

		If v_arv.liik = 0 then
			if v_arv.objektId = 0 then

				if lnKontrol = 1 then
					raise notice 'Kontrol: ';

					lcOmaTp = ltrim(rtrim(fnc_getomatp(v_arv.rekvId,year(v_arv.Kpv))));		

					if ifnull(lnKontrol,0) = 1 then
						lcViga = sp_lausendikontrol(v_dokprop.konto, v_arv1.konto,  lcDbKbmTp, lcDbKbmTp, v_arv1.kood1, v_arv1.Kood2, 
							v_arv1.kood5, v_arv1.kood3, 
							lcOmaTP, v_arv.Kpv);
						if left(ltrim(rtrim(lcViga)),4) = 'Viga' then
							raise exception ':%',lcViga;
						end if;
					end if;
				end if;
				if left(ltrim(rtrim(v_dokprop.konto)),6) = '103701' then
					lcDbKbmTp:= '014003';
				end if;

				lnJournal1 = sp_salvesta_journal1(0,lnJournal,v_arv1.kbmta,''::varchar,''::text,
					v_arv1.kood1,v_arv1.kood2,v_arv1.kood3,v_arv1.kood4,v_arv1.kood5,
					v_dokprop.konto,lcDbKbmTp,v_arv1.konto,lcDbKbmTp,v_arv1.valuuta,v_arv1.kuurs,v_arv1.kbmta*v_arv1.kuurs,
					v_arv1.tunnus,v_arv1.proj);

/*
				
				Insert Into journal1 (parentId, Summa, deebet, kreedit, lisa_d, lisa_k, kood1, kood2, 
					kood3, kood4, kood5, tunnus, proj) Values 
					(lnJournal, v_arv1.kbmta, v_dokprop.konto, v_arv1.konto, lcDbKbmTp, lcDbKbmTp, v_arv1.kood1,
					lcAllikas, v_arv1.kood3, v_arv1.kood4, lckood5, v_arv1.tunnus, v_arv1.proj );
*/
				-- kbm
				If v_arv1.kbm <> 0 then
					lnJournal1 = sp_salvesta_journal1(0,lnJournal,v_arv1.kbm,''::varchar,''::text,
						v_arv1.kood1,lcAllikas,v_arv1.kood3,v_arv1.kood4,lckood5,
						v_dokprop.konto,lcDbKbmTp,v_dokprop.kbmkonto,'014003',v_arv1.valuuta,v_arv1.kuurs,v_arv1.kbm*v_arv1.kuurs,
						v_arv1.tunnus,v_arv1.proj);
				END IF;
/*

				If v_arv1.kbm <> 0 then
					Insert Into journal1 (parentId, Summa, deebet, kreedit, lisa_d, lisa_k, kood1, kood2, 
						kood3, kood4, kood5, tunnus, proj) Values 
						(lnJournal, v_arv1.kbm, v_dokprop.konto, v_dokprop.kbmkonto, lcDbKbmTp, '014003', v_arv1.kood1,
						lcAllikas, v_arv1.kood3, v_arv1.kood4, lckood5, v_arv1.tunnus, V_arv1.proj );
				end if;
*/

			else
				--	lisatud 30/12/2004 (mahakandmine)				

				if lnKontrol = 1 then
						lcViga = sp_lausendikontrol(v_arv1.konto, v_dokprop.konto,  ifnull(v_asutus.tp,'800599'), ifnull(v_asutus.tp,'800599'), 
							v_arv1.kood1, lcAllikas, lckood5, v_arv1.kood3, 
							lcOmaTP, v_arv.Kpv);
					if left(ltrim(rtrim(lcViga)),4) = 'Viga' then
						raise exception ':%',lcViga;
					end if;
				end if;
				if left(ltrim(rtrim(v_arv1.konto)),6) = '103701' then
					lcDbKbmTp:= '014003';
				end if;

				lnJournal1 = sp_salvesta_journal1(0,lnJournal,v_arv1.kbmta,''::varchar,''::text,
					v_arv1.kood1,lcAllikas,v_arv1.kood3,v_arv1.kood4,lckood5,
					v_arv1.konto,ifnull(v_asutus.tp,'800599'),v_dokprop.konto,ifnull(v_asutus.tp,'800599'),v_arv1.valuuta,v_arv1.kuurs,v_arv1.kbmta*v_arv1.kuurs,
					v_arv1.tunnus,v_arv1.proj);

/*
				Insert Into journal1 (parentId, Summa, deebet, kreedit, lisa_d, lisa_k, kood1, kood2, 
					kood3, kood4, kood5, tunnus, proj) Values 
					(lnJournal, v_arv1.kbmta, v_arv1.konto,  v_dokprop.konto, ifnull(v_asutus.tp,'800599'), ifnull(v_asutus.tp,'800599'), v_arv1.kood1,
					lcAllikas, v_arv1.kood3, v_arv1.kood4, lcKood5, v_arv1.tunnus, v_arv1.proj );
*/
				-- kbm
				If v_arv1.kbm <> 0 then

					lnJournal1 = sp_salvesta_journal1(0,lnJournal,v_arv1.kbm,''::varchar,''::text,
						v_arv1.kood1,lcAllikas,v_arv1.kood3,v_arv1.kood4,lckood5,
						v_dokprop.kbmkonto,'014003',v_dokprop.konto,ifnull(v_asutus.tp,'800599'),v_arv1.valuuta,v_arv1.kuurs,v_arv1.kbm*v_arv1.kuurs,
						v_arv1.tunnus,v_arv1.proj);

/*
					Insert Into journal1 (parentId, Summa, deebet, kreedit, lisa_d, lisa_k, kood1, kood2, 
						kood3, kood4, kood5, tunnus, proj) Values 
						(lnJournal, v_arv1.kbmta, v_dokprop.kbmkonto,  v_dokprop.konto, '014003', ifnull(v_asutus.tp,'800599'), v_arv1.kood1,
						lcAllikas, v_arv1.kood3, v_arv1.kood4, lcKood5, v_arv1.tunnus, v_arv1.proj );
*/
				end if;
			end if;

		
		Else
			if v_arv1.konto = '601000' or v_arv1.konto = '203000' then
				lcDbKbmTp := '014003';
			end if;
			if left(ltrim(rtrim(v_arv1.konto)),6) = '103701' then
				lcDbKbmTp:= '014003';
			end if;
			

			if lnKontrol = 1 then

				lcViga = sp_lausendikontrol(v_arv1.konto, v_dokprop.konto,  lcDbKbmTp, lcKrTp,v_arv1.kood1, lcAllikas, lckood5, v_arv1.kood3, 
							lcOmaTP, v_arv.Kpv);
				if left(ltrim(rtrim(lcViga)),4) = 'Viga' then
					raise exception ':%',lcViga;
				end if;
			end if;	

			lnJournal1 = sp_salvesta_journal1(0,lnJournal,v_arv1.kbmta,''::varchar,''::text,
					v_arv1.kood1,lcAllikas,v_arv1.kood3,v_arv1.kood4,lckood5,
					v_arv1.konto,lcDbKbmTp,v_dokprop.konto,lcKrTp,v_arv1.valuuta,v_arv1.kuurs,v_arv1.kbmta*v_arv1.kuurs,
					v_arv1.tunnus,v_arv1.proj);

/*
			Insert Into journal1 (parentId, Summa, deebet, kreedit, lisa_d, lisa_k, kood1, kood2, 
				kood3, kood4, kood5, tunnus, proj) Values 
				(lnJournal, v_arv1.kbmta, v_arv1.konto,  v_dokprop.konto, lcDbKbmTp, lcKrTp, v_arv1.kood1,
				lcAllikas, v_arv1.kood3, v_arv1.kood4, lckood5, v_arv1.tunnus, v_arv1.proj );
*/
			-- kbm
			If v_arv1.kbm <> 0 then

				lnJournal1 = sp_salvesta_journal1(0,lnJournal,v_arv1.kbm,''::varchar,''::text,
						v_arv1.kood1,lcAllikas,v_arv1.kood3,v_arv1.kood4,lckood5,
						v_dokprop.kbmkonto,'014003',v_dokprop.konto, lcKrTp,v_arv1.valuuta,v_arv1.kuurs,v_arv1.kbm*v_arv1.kuurs,
						v_arv1.tunnus,v_arv1.proj);

/*
				Insert Into journal1 (parentId, Summa, deebet, kreedit, lisa_d, lisa_k, kood1, kood2, 
					kood3, kood4, kood5, tunnus, proj) Values 
					(lnJournal, v_arv1.kbm, v_dokprop.kbmkonto,  v_dokprop.konto, '014003', lcKrTp, v_arv1.kood1,
					lcAllikas, v_arv1.kood3, v_arv1.kood4, lckood5, v_arv1.tunnus, v_arv1.proj );
*/
			end if;
		End if;
	End loop;

	update arv set journalId = lnJournal where id = v_arv.id;
	If v_arv.journalid > 0 and ifnull(lnJournalNumber,0) > 0 then
		update journalid set number = lnJournalNumber where journalid = lnJournal;
	end if;
--	commit;
	return lnJournal;
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION gen_lausend_arv(integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION gen_lausend_arv(integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION gen_lausend_arv(integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION gen_lausend_arv(integer) TO dbadmin;
GRANT EXECUTE ON FUNCTION gen_lausend_arv(integer) TO dbvaatleja;

CREATE OR REPLACE FUNCTION gen_lausend_avans(integer)
  RETURNS integer AS
$BODY$
declare 
	tnId alias for $1;

	lnJournalNumber int4;
	lcDbKonto varchar(20);
	lcKrKonto varchar(20);
	lcDbTp varchar(20);
	lcKrTp varchar(20);
	lnAsutusId int4;
	lnJournalId int4;
	lnJournal1Id int4;

	lcKbmTp varchar(20);
	v_avans1 avans1%rowtype;
	v_avans2 record;
	v_dokprop dokprop%rowtype;
	v_asutus asutus%rowtype;
	lnUserId int;
	lnRecCount int;

	lcViga varchar(254);
	lnKontrol int;

begin


	select * into v_avans1 from avans1 where id = tnId;

	select * into v_asutus from asutus where id = v_avans1.asutusId;

--	select recalc into lnKontrol from rekv where id = v_avans1.rekvid;


	If v_avans1.dokpropid = 0 then


		Return 0;


	End if;


	select * into v_dokprop from dokprop where id = v_avans1.dokpropid limit 1;


	If not Found Or v_dokprop.registr = 0 then


		Return 0;


	End if;



	If v_avans1.journalid > 0 then
		update avans1 set journalId = 0 where id = v_avans1.id;

		select number into lnJournalNumber from journalId where journalId = v_avans1.journalId;
		if sp_del_journal(v_avans1.journalid,1) = 0 then
			Return 0;
		End if;
	End if;


	select id into lnUserId from userid where userid.rekvid = v_avans1.rekvid and userid.kasutaja = CURRENT_USER::varchar;

	lnJournalId:= sp_salvesta_journal(0, v_avans1.rekvId, lnUserId, v_avans1.kpv, v_avans1.AsutusId, 
		ltrim(rtrim(v_dokprop.selg)), v_avans1.number,'AUTOMATSELT LAUSEND (GEN_LAUSEND_AVANS)',v_avans1.id) ;


	if lnJournalId = 0 then
		return 0;
	end if;
	
	for v_avans2 in select avans2.*, ifnull(dokvaluuta1.valuuta,'EEK')::varchar as valuuta, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs 
		from avans2 left outer join dokvaluuta1 on (dokvaluuta1.dokid = avans2.id and dokvaluuta1.dokliik = 5) 
		where parentid = v_avans1.Id
	loop
		lcDbTp := v_asutus.tp;
		lcKrTp := v_asutus.tp;

		if left(ltrim(rtrim(v_avans2.konto)),3) = '601' then
			lcDbTp := '014003';
		end if;

		lnJournal1Id = sp_salvesta_journal1(0,lnJournalId,v_avans2.summa,''::varchar,''::text,
				v_avans2.kood1,v_avans2.kood2,v_avans2.kood3,v_avans2.kood4,v_avans2.kood5,
					v_avans2.konto,lcDbTp,v_dokprop.konto,lcKrTp,v_avans2.valuuta,v_avans2.kuurs,v_avans2.summa*v_avans2.kuurs,
					v_avans2.tunnus,v_avans2.proj);


		
	End loop;

	update avans1 set journalId = lnJournalId where id = v_avans1.id;


	return lnJournalId;
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION gen_lausend_avans(integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION gen_lausend_avans(integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION gen_lausend_avans(integer) TO dbpeakasutaja;



CREATE OR REPLACE FUNCTION gen_lausend_korder(integer)
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
		lcKbmTp varchar(20);	
		v_korder1 korder1%rowtype;	
		v_dokprop dokprop%rowtype;	
		v_aa aa%rowtype;	
		v_korder2 record;

		lnKontrol int;
		lcAllikas varchar(20);
		lcviga varchar;
		lcOmaTp varchar;

begin


	select * into v_korder1 from korder1 where id = tnId;
	If v_korder1.doklausid = 0 then
		Return 0;
	End if;

	select recalc into lnKontrol from rekv where id = v_korder1.rekvid;
	lcAllikas = 'LE-P';


	select * into v_dokprop from dokprop where id = v_korder1.doklausid;
	If not Found Or v_dokprop.registr = 0 then
		Return 0;
	End if;
	If v_korder1.journalid > 0 then
		update korder1 set journalId = 0 where id = v_korder1.id;		
		select number into lnJournalNumber from journalId where journalId = v_korder1.journalId;		
		v_korder1.journalid:= sp_del_journal(v_korder1.journalid,1) ;	
	End if;	
	select * into v_aa from aa where id = v_korder1.kassaId;	

	lnJournalId:= sp_salvesta_journal(0, v_korder1.rekvId, v_korder1.UserId, v_korder1.kpv, v_korder1.AsutusId, 
		ltrim(rtrim(v_dokprop.selg)), v_korder1.number,'AUTOMATSELT LAUSEND (GEN_LAUSEND_KORDER)',v_korder1.id) ;

	for v_korder2 in 
		select korder2.*,ifnull(dokvaluuta1.valuuta,'EEK')::varchar as valuuta, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs 
			from korder2 left outer join dokvaluuta1 on (korder2.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 11)  where parentid = v_korder1.Id
	loop
		If v_korder1.tyyp = 1 then
			-- sisetulik
			raise notice 'Sise';
			if not empty(v_korder2.kood2) then
				lcAllikas = v_korder2.kood2;
			end if;
			raise notice 'kontorol TPK %',v_korder2.tp;
			raise notice 'lnKontrol %',lnKontrol;
/*
			if ifnull(lnKontrol,0) = 1 then
				raise notice 'kontorol TPK %',v_korder2.tp;

				lcOmaTp = ltrim(rtrim(fnc_getomatp(v_korder1.rekvId,year(v_korder1.Kpv))));		

				lcViga = sp_lausendikontrol( v_aa.konto, v_korder2.konto, v_aa.tp, v_korder2.tp, v_korder2.kood1, lcAllikas::varchar, v_korder2.kood5, v_korder2.kood3, lcOmaTp, v_korder1.kpv);
				if left(ltrim(rtrim(lcViga)),4) = 'Viga' then
					raise exception ':%',lcViga;
				end if;
			end if;
*/
			lnJournal1Id = sp_salvesta_journal1(0,lnJournalId,v_korder2.Summa,''::varchar,''::text,
				v_korder2.kood1,v_korder2.kood2,v_korder2.kood3,v_korder2.kood4,v_korder2.kood5,
					v_aa.konto,v_aa.tp,v_korder2.konto,v_korder2.tp,v_korder2.valuuta,v_korder2.kuurs,v_korder2.summa*v_korder2.kuurs,
					v_korder2.tunnus,v_korder2.proj);
		
		Else
			-- valjamineku order
			raise notice 'Valja';

			lnJournal1Id = sp_salvesta_journal1(0,lnJournalId,v_korder2.Summa,''::varchar,''::text,
				v_korder2.kood1,v_korder2.kood2,v_korder2.kood3,v_korder2.kood4,v_korder2.kood5,
				v_korder2.konto,v_korder2.tp,v_aa.konto, v_aa.tp,v_korder2.valuuta,v_korder2.kuurs,v_korder2.summa*v_korder2.kuurs,
				v_korder2.tunnus,v_korder2.proj);


		End if;
	End loop;

	update korder1 set journalId = lnJournalId where id = v_korder1.id;	

	If v_korder1.journalid > 0 and ifnull(lnJournalNumber,0) > 0 then		
		update journalid set number = lnJournalNumber where journalid = lnJournalId;	
	end if;

	return lnJournalId;end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION gen_lausend_korder(integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION gen_lausend_korder(integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION gen_lausend_korder(integer) TO dbpeakasutaja;



CREATE OR REPLACE FUNCTION gen_lausend_kulum(integer)
  RETURNS integer AS
$BODY$


declare 
	tnId alias for $1;
	lnJournalNumber int4;
	lcDbKonto varchar(20);
	lcKrKonto varchar(20);
	lcDbTp varchar(20);
	lcKrTp varchar(20);
	lnAsutusId int4;
	lnJournalId int4;	
	lnJournal1Id int4;
	v_pv_oper record;
	v_pv_kaart record;
	v_dokprop dokprop%rowtype;
	v_aa aa%rowtype;
	lcDok varchar(100);

	lnKontrol int;
	lcAllikas varchar(20);
	lcviga varchar;
	lnUsrID int;

begin

	select pv_oper.*, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs, ifnull(dokvaluuta1.valuuta,'EEK')::varchar as valuuta into v_pv_oper 
		from pv_oper left outer join dokvaluuta1 on (pv_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 13)
		where pv_oper.id = tnId;
	
	If v_pv_oper.doklausid = 0 then
		raise notice 'Konteerimine ei ole vajalik, dok tyyp ei ole defineeritud';
		Return 0;

	End if;

	select * into v_dokprop from dokprop where dokprop.id = v_pv_oper.doklausid;

	If not Found Or v_dokprop.registr = 0 then
		raise notice 'Konteerimine ei ole vajalik';

		Return 0;

	End if;

	select library.rekvid, library.kood,pv_kaart.* into v_pv_kaart 
		from library inner join pv_kaart on pv_kaart.parentid = library.id 
		where pv_kaart.parentid = v_pv_oper.parentId;

	lcDok := 'Inv.number '+IFNULL(v_pv_kaart.kood,SPACE(1));	

	select recalc into lnKontrol from rekv where  rekv.id = v_pv_kaart.rekvid;
	lcAllikas = 'LE-P';


	If v_pv_oper.journalid > 0 then
		raise notice 'kustutan vana lausend';

		select number into lnJournalNumber from journalId where journalId = v_pv_oper.journalId;
		update pv_oper set journalid = 0 where pv_oper.id = v_pv_oper.id;

		perform sp_del_journal(v_pv_oper.journalid,1); 
	End if;


	select * into v_aa from aa where parentid = v_pv_kaart.rekvId;	
	select kood into lcKrKonto from library where id in (
	select tun2 from library where id = v_pv_kaart.gruppId);

	lcKrKonto := ifnull(lcKrKonto,space(1));
	lcDbKonto := v_pv_oper.konto;
	lcDbTp := space(1);
	lckrTp := space(1);
	lnAsutusId = v_pv_oper.Asutusid;

	SELECT id INTO lnUsrID from userid WHERE kasutaja = CURRENT_USER::VARCHAR;

	lnJournalId:= sp_salvesta_journal(0, v_pv_kaart.rekvId, lnUsrID, v_pv_oper.kpv, lnAsutusId, 
		ltrim(rtrim(v_dokprop.selg)), lcDok,'AUTOMATSELT LAUSEND (GEN_LAUSEND_AVANS)',v_pv_oper.id) ;

	if lnJournalId = 0 then
		return 0;
	end if; 	

	raise notice 'Lausend koostatud';


		if not empty(v_pv_oper.kood2) then
				lcAllikas = v_pv_oper.kood2;
		end if;
/*
		if ifnull(lnKontrol,0) = 1 then
			lcViga = sp_lausendikontrol(lcDbKonto, lcKrKonto, lcDbTp,lcKrTp, v_pv_oper.kood1, lcAllikas, v_pv_oper.kood5, '11',v_pv_oper.kpv);
			if left(ltrim(rtrim(lcViga)),4) = 'Viga' then
				raise exception ':%',lcViga;
			end if;
			raise notice 'Kontrol lõppetatud';
		end if;
*/
		lnJournal1Id = sp_salvesta_journal1(0,lnJournalId,v_pv_oper.Summa,''::varchar,''::text,
				v_pv_oper.kood1,v_pv_oper.kood2,'11',v_pv_oper.kood4,v_pv_oper.kood5,
				lcDbKonto,lcDbTp,lcKrKonto,lcKrTp,v_pv_oper.valuuta,v_pv_oper.kuurs,v_pv_oper.summa*v_pv_oper.kuurs,
				v_pv_oper.tunnus,v_pv_oper.proj);

	if v_pv_oper.journalid > 0 and ifnull(lnJournalNumber,0) > 0 then
		update journalid set number = lnJournalNumber where journalid = lnJournalId;
	end if;

	update pv_oper set journalId = lnJournalId where id = v_pv_oper.id;

	raise notice 'Koonteerimine lõpp';

	return lnJournalId;
end; 


$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION gen_lausend_kulum(integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION gen_lausend_kulum(integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION gen_lausend_kulum(integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION gen_lausend_kulum(integer) TO dbadmin;


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

		if ifnull(lnKontrol,0) = 1 then
			lcViga = sp_lausendikontrol(lcDbKonto, lcKrKonto, lcDbTp,lcKrTp, v_pv_oper.kood1, lcAllikas, v_pv_oper.kood5, v_pv_oper.kood3, v_pv_oper.kpv);
			if left(ltrim(rtrim(lcViga)),4) = 'Viga' then
				raise exception ':%',lcViga;
			end if;
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

		select id into lnUserId from userid where userid.rekvid = v_mk.rekvid and userid.kasutaja = CURRENT_USER::varchar;

		lnJournalId:= sp_salvesta_journal(0, v_mk.rekvId, lnUserId, v_mk.kpv, v_mk1.AsutusId, 
			ltrim(rtrim(v_dokprop.selg)), v_mk.number,'AUTOMATSELT LAUSEND (GEN_LAUSEND_MK)',v_mk.id) ;


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



CREATE OR REPLACE FUNCTION gen_lausend_paigutus(integer)
  RETURNS integer AS
$BODY$



declare 
	tnId alias for $1;
	lnJournalNumber int4;
	lcDbKonto varchar(20);
	lcKrKonto varchar(20);
	lcDbTp varchar(20);
	lcKrTp varchar(20);
	lnAsutusId int4;
	lnJournalId int4;
	lnJournal1Id int4;
	v_pv_oper record;
	v_dokprop dokprop%rowtype;
	v_aa aa%rowtype;
	lnKontrol int;
	lcAllikas varchar(20);
	v_pv_kaart record;
	lcDok varchar(20);
	lnUsrId int;
	lcViga varchar;
	
begin

	select pv_oper.*, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs, ifnull(dokvaluuta1.valuuta,'EEK')::varchar as valuuta into v_pv_oper 
		from pv_oper left outer join dokvaluuta1 on (pv_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 13)
		where pv_oper.id = tnId;


	If v_pv_oper.doklausid = 0 then
		raise notice 'Konteerimine ei ole vajalik, dok tyyp ei ole defineeritud';
		Return 0;

	End if;

--	select * into v_pv_kaart from curpohivara where id = v_pv_oper.parentId;

	select * into v_dokprop from dokprop where id = v_pv_oper.doklausid;
	If not Found Or v_dokprop.registr = 0 then
		raise notice 'Konteerimine ei ole vajalik';
		Return 0;

	End if;

	select library.rekvid, library.kood,pv_kaart.* into v_pv_kaart 
		from library inner join pv_kaart on pv_kaart.parentid = library.id 
		where pv_kaart.parentid = v_pv_oper.parentId;

	lcDok := 'Inv.number '+IFNULL(v_pv_kaart.kood,SPACE(1));	

--	select recalc into lnKontrol from rekv where  rekv.id = v_pv_kaart.rekvid;

	If v_pv_oper.journalid > 0 then
		select number into lnJournalNumber from journalId where journalId = v_pv_oper.journalId;

		update pv_oper set journalId = 0 where id = v_pv_oper.id;
		perform sp_del_journal(v_pv_oper.journalid,1);
	End if;


	select * into v_aa from aa where parentid = v_pv_kaart.rekvId;	


	lcDbKonto := v_pv_kaart.konto;
	lcKrKonto := v_pv_oper.konto;
	lcDbTp := v_aa.tp;
	lckrTp := v_pv_oper.tp;
	lnAsutusId = v_pv_oper.Asutusid;
	lcAllikas = 'LE-P';


	SELECT id INTO lnUsrID from userid WHERE kasutaja = CURRENT_USER::VARCHAR;

	lnJournalId:= sp_salvesta_journal(0, v_pv_kaart.rekvId, lnUsrID, v_pv_oper.kpv, lnAsutusId, 
		ltrim(rtrim(v_dokprop.selg)), lcDok,'AUTOMATSELT LAUSEND (GEN_LAUSEND_PAIGUTUS)',v_pv_oper.id) ;

	if lnJournalId = 0 then
		return 0;
	end if; 	


	if not empty(v_pv_oper.kood2) then
		lcAllikas = v_pv_oper.kood2;
	end if;
/*	
	if ifnull(lnKontrol,0) = 1 then
		lcViga = sp_lausendikontrol(lcDbKonto, lcKrKonto, lcDbTp,lcKrTp, v_pv_oper.kood1, lcAllikas, v_pv_oper.kood5, v_pv_oper.kood3,v_pv_oper.kpv);
		if left(ltrim(rtrim(lcViga)),4) = 'Viga' then
			raise exception ':%',lcViga;
		end if;
		raise notice 'Kontrol lõppetatud';
	end if;
*/
	lnJournal1Id = sp_salvesta_journal1(0,lnJournalId,v_pv_oper.Summa,''::varchar,''::text,
				v_pv_oper.kood1,v_pv_oper.kood2,v_pv_oper.kood3,v_pv_oper.kood4,v_pv_oper.kood5,
				lcDbKonto,lcDbTp,lcKrKonto,lcKrTp,v_pv_oper.valuuta,v_pv_oper.kuurs,v_pv_oper.summa*v_pv_oper.kuurs,
				v_pv_oper.tunnus,v_pv_oper.proj);

	update pv_oper set journalId = lnJournalId where id = v_pv_oper.id;


	if v_pv_oper.journalid > 0 then
		update journalid set number = lnJournalNumber where journalid = lnJournalId;
	end if;


	return lnJournalId;
end; 



$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION gen_lausend_paigutus(integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION gen_lausend_paigutus(integer) TO vlad;
GRANT EXECUTE ON FUNCTION gen_lausend_paigutus(integer) TO public;
GRANT EXECUTE ON FUNCTION gen_lausend_paigutus(integer) TO dbkasutaja;


CREATE OR REPLACE FUNCTION gen_lausend_palk(integer)
  RETURNS integer AS
$BODY$
declare 	
	tnId alias for $1;	
	lnJournalNumber int4;	
	lcDbKonto varchar(20);	
	lcKrKonto varchar(20);	
	lcDbTp varchar(20);	
	lcKrTp varchar(20);	
	lnAsutusId int4;	
	lnJournalId int4;	
	lnJournal1Id int4;	
	v_palk_oper record;	
	v_dokprop dokprop%rowtype;	
	v_aa record;	
	v_palk_lib palk_lib%rowtype;	
	v_tooleping tooleping%rowtype;	
	v_asutus asutus%rowtype;

	lnUsrId int;
	lcAllikas varchar(20);
	lcviga varchar;


begin	
	lcDbTp := '800699';
	lcKrTp := '800699';

	select palk_oper.*, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs, ifnull(dokvaluuta1.valuuta,'EEK')::varchar as valuuta into v_palk_oper 
		from palk_oper left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
		where palk_oper.id = tnId;

	If v_palk_oper.doklausid = 0 then		
		raise notice 'Konteerimine ei ole vajalik, dok tyyp ei ole defineeritud';
		Return 0;	
	End if;	

	select * into v_dokprop from dokprop where id = v_palk_oper.doklausid;	
	If not Found Or v_dokprop.registr = 0 then		
		raise notice 'Konteerimine ei ole vajalik';
		Return 0;	
	End if;

--	select recalc into lnKontrol from rekv where id =  v_palk_oper.rekvid;
--	lcAllikas = 'LE-P';
	lcAllikas = ' ';



	If v_palk_oper.journalid > 0 then		
		select number into lnJournalNumber from journalId where journalId = v_palk_oper.journalId;
		update palk_oper set journalId = 0 where id = v_palk_oper.id;		
		v_palk_oper.journalid:= sp_del_journal(v_palk_oper.journalid,1);	
	End if;	
	select * into v_tooleping from tooleping where id = v_palk_oper.LepingId;	
	select * into v_palk_lib from palk_lib where parentid = v_palk_oper.libId;	
	select * into v_asutus from asutus where id = v_tooleping.parentId;	
	lnAsutusId:= v_asutus.id;
	select * into v_aa from aa where parentid = v_palk_oper.rekvId and kassa = 1 order by default_ desc limit 1;		
	if  v_palk_lib.liik = 1  then		 
		--arv		
		lcDbKonto := v_palk_oper.konto;		
		lcKrKonto := v_dokprop.konto;		
		lcDbTp := v_asutus.tp;		
		lcKrTp := v_asutus.tp;		
		lnAsutusId := v_asutus.Id;	
	end if;
	if v_palk_lib.liik = 2 then 		
		-- kinni		
		lcKrKonto := v_palk_oper.konto;		
		lcDbKonto := v_dokprop.konto;		
		lcKrTp := '800699';		
		lcDbTp := v_palk_oper.tp;		
		lnAsutusId := v_asutus.Id;	
	end if;
	if  v_palk_lib.liik = 4 then	
		-- tulumaks		
		Select * into v_asutus from asutus where id = v_dokprop.asutusId;		
		lcKrKonto := v_palk_oper.konto;		
		lcDbKonto := v_dokprop.konto;		
		lcKrTp := v_asutus.tp;		
		lcDbTp := '800699';	
	end if;
	if v_palk_lib.liik = 5 then 	
		-- sotsmaks		
--		if v_dokprop.asutusId > 0 then
--			Select * into v_asutus from asutus where id = v_dokprop.asutusId;		
---		end if;
		lcKrKonto := v_palk_lib.konto;		
		lcDbKonto := v_palk_oper.konto;		
		lcKrTp := v_asutus.tp;		
		lcDbTp := '800699';		
		if ifnull(v_asutus.Id,0) > 0 then
			lnAsutusId := v_asutus.Id;	
		end if;
	end if;
	if v_palk_lib.liik = 6 then
	-- tasu		
		lcKrKonto := v_palk_oper.konto;		
		lcDbKonto := v_dokprop.konto;		
		lcKrTp := v_aa.tp;		
		lcDbTp := v_palk_oper.tp;		
		lnAsutusId := v_asutus.Id;
		-- lisatud 01/02/2005
		if left(lcKrKonto,6) = '100000' then
			lcKrTp := space(1);
		end if;
	end if;
	if v_palk_lib.liik = 7 And v_palk_lib.asutusest = 1 then 
		--tookindl asutus	
--		if v_dokprop.asutusId > 0 then
--			Select * into v_asutus from asutus where id = v_dokprop.asutusId;		
--		end if;
		lcKrKonto := v_palk_lib.konto;		
		lcDbKonto := v_palk_oper.konto;		
		lcKrTp := v_asutus.tp;	
		if ifnull(v_asutus.Id,0) = 0 then
			lcKrTp := '800699';	
		end if;
	
		lcDbTp := '800699';		
		if ifnull(v_asutus.Id,0) > 0 then
			lnAsutusId := v_asutus.Id;	
		end if;
	end if;
	if v_palk_lib.liik = 7 And v_palk_lib.asutusest = 0  then	
		-- tookindl isik		
		lcKrKonto := v_palk_oper.konto;		
		lcDbKonto := v_dokprop.konto;		
		lcKrTp := v_palk_oper.tp;		
		lcDbTp := v_asutus.tp;		
		if ifnull(v_asutus.Id,0) > 0 then
			lnAsutusId := v_asutus.Id;	
		end if;
		if ifnull(v_asutus.Id,0) = 0 then
			lcKrTp := '800699';	
		end if;
	
		lcDbTp := '800699';		

	end if;
	if v_palk_lib.liik = 8 then
		-- pensmaks		
--		if v_dokprop.asutusId > 0 then			
--			Select * into v_asutus from asutus where id = v_dokprop.asutusId;		
--		end if;
		lcKrKonto := v_palk_oper.konto;		
		lcDbKonto := v_dokprop.konto;		
		lcKrTp := v_asutus.tp;		
		lcDbTp := '800699';	
		if ifnull(v_asutus.Id,0) > 0 then
			lnAsutusId := v_asutus.Id;	
		end if;
	End if;	
	if left(lcKrKonto,3) = '203' and lcKrKonto <> '203690' then
		lcKrTp := '014003';
	end if;
	if lcKrKonto = '203690' then
		lcKrTp := '800399';
	end if;
	if lcKrKonto = '203640' then
		lcKrTp := '800699';
	end if;
	if lcKrKonto = '202000' then
		lcKrTp := '800699';
	end if;
	if lcDbKonto = '103560' then
		lcDbTp := '016003';
	end if;
	if lcKrKonto = '202090' then
		lcKrTp := '800699';
	end if;
	if lcKrKonto = '202002' then
		lcKrTp := '800699';
	end if;
	if lcKrKonto = '202003' then
		lcKrTp := '800699';
	end if;
	if lcKrKonto = '202004' then
		lcKrTp := '800699';
	end if;

	SELECT id INTO lnUsrID from userid WHERE rekvid = v_palk_oper.rekvId and  kasutaja = CURRENT_USER::VARCHAR order by id desc limit 1;

	lnJournalId:= sp_salvesta_journal(0, v_palk_oper.rekvId, lnUsrID, v_palk_oper.kpv, lnAsutusId, 
		ltrim(rtrim(v_dokprop.selg)), '','AUTOMATSELT LAUSEND (GEN_LAUSEND_PALK)',v_palk_oper.id) ;

	if lnJournalId = 0 then
		return 0;
	end if; 	

	v_palk_oper.kood1 := ifnull(v_palk_oper.kood1,space(1));
	v_palk_oper.kood2 := ifnull(ltrim(rtrim(v_palk_oper.kood2)),' ');
	v_palk_oper.kood3 := ifnull(v_palk_oper.kood3,space(1));
	v_palk_oper.kood4 := ifnull(v_palk_oper.kood4,space(1));
	v_palk_oper.kood5 := ifnull(v_palk_oper.kood5,space(1));

	if empty(ltrim(rtrim(v_palk_oper.kood2))) then
		v_palk_oper.kood2 := 'LE-P';
	end if;

	lnJournal1Id = sp_salvesta_journal1(0,lnJournalId,v_palk_oper.Summa,''::varchar,''::text,
				v_palk_oper.kood1,v_palk_oper.kood2,v_palk_oper.kood3,v_palk_oper.kood4,v_palk_oper.kood5,
				lcDbKonto,lcDbTp,lcKrKonto,lcKrTp,v_palk_oper.valuuta,v_palk_oper.kuurs,v_palk_oper.summa*v_palk_oper.kuurs,
				v_palk_oper.tunnus,v_palk_oper.proj);

	update palk_oper set journalId = lnJournalId where id = v_palk_oper.id;

	if v_palk_oper.journalId > 0 and ifnull(lnJournalNumber,0) > 0 then		
		update journalid set number = lnJournalNumber where journalid = lnJournalId;	
	end if;
	return lnJournalId;
end; 
	
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION gen_lausend_palk(integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION gen_lausend_palk(integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION gen_lausend_palk(integer) TO dbpeakasutaja;


CREATE OR REPLACE FUNCTION gen_lausend_parandus(integer)
  RETURNS integer AS
$BODY$



declare 
	tnId alias for $1;
	lnJournalNumber int4;
	lcDbKonto varchar(20);
	lcKrKonto varchar(20);
	lcDbTp varchar(20);
	lcKrTp varchar(20);
	lnAsutusId int4;
	lnUsrId int;
	lnJournalId int4;
	lnJournal1Id int4;
	v_pv_oper record;
	v_pv_kaart record;
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

	select * into v_dokprop from dokprop where id = v_pv_oper.doklausid;

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
		perform sp_del_journal(v_pv_oper.journalid::int4,1::int4);
	End if;

	select * into v_aa from aa where parentid = v_pv_kaart.rekvId;	
	lcDbKonto := v_pv_kaart.konto;
	lcKrKonto := v_pv_oper.konto;
	lcDbTp := ifnull(v_aa.tp,space(1));
	lckrTp := v_pv_oper.tp;
	lnAsutusId = v_pv_oper.Asutusid;


	SELECT id INTO lnUsrID from userid WHERE kasutaja = CURRENT_USER::VARCHAR;

	lnJournalId:= sp_salvesta_journal(0, v_pv_kaart.rekvId, lnUsrID, v_pv_oper.kpv, lnAsutusId, 
		ltrim(rtrim(v_dokprop.selg)), lcDok,'AUTOMATSELT LAUSEND (GEN_LAUSEND_PARANDUS)',v_pv_oper.id) ;

	if lnJournalId = 0 then
		return 0;
	end if; 	

	if not empty(v_pv_oper.kood2) then
		lcAllikas = v_pv_oper.kood2;
	end if;

		if ifnull(lnKontrol,0) = 1 then
			lcViga = sp_lausendikontrol(lcDbKonto, lcKrKonto, lcDbTp,lcKrTp, v_pv_oper.kood1, lcAllikas, v_pv_oper.kood5, v_pv_oper.kood3, v_pv_oper.kpv);
			if left(ltrim(rtrim(lcViga)),4) = 'Viga' then
				raise exception ':%',lcViga;
			end if;
		end if;

	lnJournal1Id = sp_salvesta_journal1(0,lnJournalId,v_pv_oper.Summa,''::varchar,''::text,
				v_pv_oper.kood1,v_pv_oper.kood2,v_pv_oper.kood3,v_pv_oper.kood4,v_pv_oper.kood5,
				lcDbKonto,lcDbTp,lcKrKonto,lcKrTp,v_pv_oper.valuuta,v_pv_oper.kuurs,v_pv_oper.summa*v_pv_oper.kuurs,
				v_pv_oper.tunnus,v_pv_oper.proj);

	update pv_oper set journalId = lnJournalId where id = v_pv_oper.id;


	if v_pv_oper.journalid > 0 and ifnull(lnJournalNumber,0) > 0 then
		update journalid set number = lnJournalNumber where journalid = lnJournalId;
	end if;


	return lnJournalId;
end; 



$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION gen_lausend_parandus(integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION gen_lausend_parandus(integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION gen_lausend_parandus(integer) TO dbpeakasutaja;


CREATE OR REPLACE FUNCTION gen_palkoper(integer, integer, integer, date, integer)
  RETURNS integer AS
$BODY$
declare
	tnLepingId alias for $1;
	tnLibId alias for $2;
	tnDokLausId alias for $3;
	tdKpv alias for $4;
	tnAvans alias for $5;

	lnLiik int;
	qrypalklib record;
	v_klassiflib record;
	v_palk_kaart record;
	v_dokprop record;
	lnAsutusest int;
	lnSumma numeric(12,4);
	lcTunnus varchar;
	lnPalkOperId int;
	lnJournalId int;
	lcTp varchar;
	v_valuuta record;
begin
	raise notice 'start';

	SELECT Library.kood, ifnull((select valuuta1.kuurs from valuuta1 
		where parentid = library.id order by id desc limit 1),0) as kuurs into v_valuuta
		FROM Library WHERE  library = 'VALUUTA' and library.tun1 = 1;

	lcTp := '800699';
	lcTunnus := space(1);
	lnSumma := 0;
	select * into v_klassiflib from klassiflib where libId = tnLibId;
	select * into v_palk_kaart from palk_kaart where libId = tnLibId and lepingId = tnLepingId;
	select palk_lib.*, library.rekvId into qrypalklib from palk_lib inner join library on library.id = palk_lib.parentid 
		where parentid = tnLibId;
	select * into v_dokprop from dokprop where id = tnDokLausId;

	if qryPalkLib.liik = 1 then
		raise notice 'palk_lib %',qryPalkLib.liik;
		lnSumma := sp_calc_arv(tnLepingId, tnLibId, tdKpv);
		raise notice 'summa %',lnSumma;
	end if;		
	if qryPalkLib.liik = 2 then
		raise notice 'palk_lib %',qryPalkLib.liik;
		lnSumma := sp_calc_kinni(tnLepingId, tnLibId, tdKpv);
	end if;		
	if qryPalkLib.liik = 3 then
		raise notice 'palk_lib %',qryPalkLib.liik;
		lnSumma := sp_calc_muuda(tnLepingId, tnLibId, tdKpv);
	end if;		
	if qryPalkLib.liik = 4 then
		raise notice 'palk_lib %',qryPalkLib.liik;
		lnSumma := sp_calc_tulumaks(tnLepingId, tnLibId, tdKpv);
		lcTp := '014003';
		if v_dokprop.asutusid > 0 then
			select tp into lcTp from asutus where id = v_dokprop.asutusId;
		end if;
	end if;		
	if qryPalkLib.liik = 5 then
		raise notice 'palk_lib %',qryPalkLib.liik;
		lnSumma := sp_calc_sots(tnLepingId, tnLibId, tdKpv);
		lcTp := '014003';
		if v_dokprop.asutusid > 0 then
			select tp into lcTp from asutus where id = v_dokprop.asutusId;
		end if;

	end if;		
	if qryPalkLib.liik = 6 then
		raise notice 'palk_lib %',qryPalkLib.liik;
		lnSumma := sp_calc_tasu(tnLepingId, tnLibId, tdKpv);
	end if;		
	if qryPalkLib.liik = 7 then
		raise notice 'palk_lib %',qryPalkLib.liik;
		if lnAsutusest < 1 then
			lnSumma := sp_calc_kinni(tnLepingId, tnLibId, tdKpv);
		else
			lnSumma := sp_calc_muuda(tnLepingId, tnLibId, tdKpv);
		end if;
		lcTp := '014003';
		if v_dokprop.asutusid > 0 then
			select tp into lcTp from asutus where id = v_dokprop.asutusId;
		end if;
	end if;		
	if qryPalkLib.liik = 8 then
		raise notice 'palk_lib %',qryPalkLib.liik;
		lnSumma := sp_calc_kinni(tnLepingId, tnLibId, tdKpv);
	end if;	
	raise notice 'lnSumma> %',lnSumma;
	
	if lnSumma > 0 then
		if v_klassiflib.tunnusid > 0 then
			select kood into lcTunnus from library where id = v_klassiflib.tunnusId;
		end if;
		if v_palk_kaart.tunnusid > 0 then
			select kood into lcTunnus from library where id = v_palk_kaart.tunnusId;
		end if;

		lcTunnus = ifnull(lcTunnus,space(1));	

		-- pohivaluuta
		lnSumma = lnSumma / fnc_currentkuurs(tdKpv);

		lnPalkOperId = sp_salvesta_palk_oper(0, qryPalkLib.rekvid, tnLibId, tnlepingid, tdKpv, lnSumma, tnDoklausid, '', 
			ifnull(v_klassiflib.kood1,space(1)),ifnull(v_klassiflib.kood2,'LE-P'), ifnull(v_klassiflib.kood3,space(1)), 
			ifnull(v_klassiflib.kood4,space(1)), ifnull(v_klassiflib.kood5,space(1)), ifnull(v_klassiflib.konto,space(1)), 
			 lcTp, lcTunnus,v_valuuta.kood, v_valuuta.kuurs,v_klassiflib.proj );


--		lisatud 31/12/2004
		IF tnAvans > 0 AND qryPalkLib.liik = 6 then 	
			perform sp_calc_avansimaksed(lnpalkOperId);
		END IF;

	end if;
	Return lnpalkOperId;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION gen_palkoper(integer, integer, integer, date, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION gen_palkoper(integer, integer, integer, date, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION gen_palkoper(integer, integer, integer, date, integer) TO dbpeakasutaja;


CREATE OR REPLACE FUNCTION isdigit(character varying)
  RETURNS integer AS
$BODY$
DECLARE tcChar alias for $1;
	lnresult int;
	lnCount int;
begin
	lnresult = 0;
	lnCount = 0;
	loop
		if lnCount::varchar(1) = left(ltrim(rtrim(tcChar)),1)::varchar(1) then
--			raise notice 'digit';
			lnresult = 1;
		end if;
		if lnCount = 9 or lnresult = 1 then
			exit;
		end if;
		
		lnCount = lnCount + 1;
	end loop;

         return  lnResult;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION isdigit(character varying) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION isdigit(character varying) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION isdigit(character varying) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION isdigit(character varying) TO dbadmin;
GRANT EXECUTE ON FUNCTION isdigit(character varying) TO dbvaatleja;



CREATE OR REPLACE FUNCTION kk(character varying, integer, date, date)
  RETURNS numeric AS
$BODY$

DECLARE tcKontogrupp alias for $1;
	tnrekvid alias for $2;
	tdKpv1 alias for $3;
	tdKpv2 alias for $4;
	lnKr numeric (12,4);
begin	

	-- arv. kreedit kaibed
	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnKr from journal1 left outer join dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 1)
		where kreedit like ltrim(rtrim(tcKontogrupp))+'%'
		and parentid in (select id from journal where rekvId = tnRekvId and kpv >= tdKpv1 and kpv <= tdKpv2);

	return ifnull(lnKr,0);
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION kk(character varying, integer, date, date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION kk(character varying, integer, date, date) TO vlad;
GRANT EXECUTE ON FUNCTION kk(character varying, integer, date, date) TO public;
GRANT EXECUTE ON FUNCTION kk(character varying, integer, date, date) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION kk(character varying, integer, date, date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION kk(character varying, integer, date, date) TO dbadmin;
GRANT EXECUTE ON FUNCTION kk(character varying, integer, date, date) TO dbvaatleja;



CREATE OR REPLACE FUNCTION recalc_palk_saldo(integer, smallint)
  RETURNS integer AS
$BODY$
declare 
	tnLepingId alias for $1;

	tnMonth alias for $2;

	lKpv1	date;

	lKpv2	date;

	lnrekvid int;

begin

	If ifnull(tnMonth,0) = 0 then

		lKpv1 := date (year (), month (),1);

		lKpv2 := DATE(YEAR(),12,31);

	ELSE

		lKpv1 = DATE(YEAR(),tnMonth,1);

		--muudetud 03/01/2005
		lKpv2 = gomonth(lKpv1,1)  - 1; 

	end if;

	select palk_asutus.rekvid into lnRekvid from palk_asutus 

	inner join tooleping on (tooleping.ametid = palk_asutus.ametid and tooleping.Osakondid = palk_asutus.osakondid)

	where tooleping.id = tnLepingId;



	return sp_update_palk_jaak(lKpv1,lKpv2, lnRekvId, tnlepingId);

end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION recalc_palk_saldo(integer, smallint) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION recalc_palk_saldo(integer, smallint) TO vlad;
GRANT EXECUTE ON FUNCTION recalc_palk_saldo(integer, smallint) TO public;
GRANT EXECUTE ON FUNCTION recalc_palk_saldo(integer, smallint) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION recalc_palk_saldo(integer, smallint) TO dbpeakasutaja;



CREATE OR REPLACE FUNCTION sd(character varying, integer, date)
  RETURNS numeric AS
$BODY$
DECLARE tcKontogrupp alias for $1;
	tnrekvid alias for $2;
	tdKpv alias for $3;
	lnAlg numeric (12,2);
	lnDb numeric (12,2);
	lnKr numeric (12,2);
begin
	-- arv algsaldo
--	select sum(algsaldo) into lnAlg from library l inner join kontoinf k on l.id = k.parentId 
--		where k.rekvId = tnRekvId and l.kood = ltrim(rtrim(tcKontogrupp));

	-- arv. deebet kaibed
	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnDb from journal1 left outer join dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 1)
		where ltrim(rtrim(deebet)) = ltrim(rtrim(tcKontogrupp))
		and parentid in (select id from journal where rekvId = tnRekvId and kpv <= tdKpv);

	-- arv. kreedit kaibed
	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnKr from journal1 left outer join dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and  dokvaluuta1.dokliik = 1)
		where ltrim(rtrim(kreedit)) = ltrim(rtrim(tcKontogrupp))
		and parentid in (select id from journal where rekvId = tnRekvId and kpv <= tdKpv);
	return ifnull(lnAlg,0) + ifnull(lnDb,0) - ifnull(lnKr,0);
end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sd(character varying, integer, date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sd(character varying, integer, date) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION sd(character varying, integer, date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sd(character varying, integer, date) TO dbadmin;
GRANT EXECUTE ON FUNCTION sd(character varying, integer, date) TO dbvaatleja;


CREATE OR REPLACE FUNCTION sp_calc_arv(integer, integer, date)
  RETURNS numeric AS
$BODY$

declare

	tnLepingid alias for $1;

	tnLibId alias for $2;

	tdKpv alias for $3;

	lnSumma numeric (12,4);

	v_palk_kaart record;

	qrytooleping record;

	qryPalkLib   record;

	qryTaabel1 record;

	npalk	numeric(12,4);

	nHours NUMERIC(12,4);

	lnRate numeric (12,4);

	nSumma numeric (12,4);

	lnBaas numeric (12,4);

begin

nHours :=0;

lnSumma := 0;

nPalk:=0;

lnBaas :=0;

select palk_kaart.*, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs  into v_palk_kaart 
	from palk_kaart left outer join dokvaluuta1 on (palk_kaart.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 20) 
	where lepingid = tnLepingid and libId = tnLibId;

select * INTO qryPalkLib from palk_lib where parentId = tnLibId;

--raise notice 'Percent %',v_palk_kaart.percent_;

If v_palk_kaart.percent_ = 1 then

	-- calc based on taabel 

	raise notice 'calc based on taabel';

	If v_palk_kaart.alimentid = 0 then

		--raise notice 'alimentid = 0';

		

		select tooleping.*, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs into qryTooleping 
			from tooleping left outer join dokvaluuta1 on (tooleping.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 19) 
			where id = tnLepingId; 

		select * into qryTaabel1 from palk_taabel1 where toolepingId = tnlepingId 

			and kuu = month(tdKpv) and aasta = year (tdKpv);

		if not found then

			--raise notice 'TAABEL1 NOT FOUND';

			return lnSumma;

		end if;





	SELECT tund into nHours FROM Toograf WHERE lepingid = tnLepingId AND kuu = month(tdKpv) AND aasta = year(tdKpv);




	IF ifnull(nHours,0) = 0 then

		nHours := (sp_workdays(1, month(tdKpv), year(tdKpv), 31,v_palk_kaart.lepingId)::numeric(6,4) * qryTooleping.toopaev )::INT4;
		nHours := nHours - sp_calc_tahtpaevad(qryTooleping.rekvId, month(tdKpv));

	END IF;

		--raise notice 'hOUR %',nHours;
		if qryTooleping.tasuliik = 1 then
			lnRate := (qryTooleping.palk * qryTooleping.kuurs)/ nHours * 0.01 * qryTooleping.koormus ;

			--raise notice 'Rate %',lnrate;

		end if;

		if qryTooleping.tasuliik = 2 then

			lnSumma := f_round((qryTooleping.palk * qryTooleping.kuurs) * qryTaabel1.kokku,qryPalkLib.round);
			lnRate := qryTooleping.palk * qryTooleping.kuurs;
			
			-- muudetud 01/02/2005
			if qryPalkLib.tund = 5 then
				lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.tahtpaev,qryPalkLib.round);
			end if;
			If  qryPalkLib.tund = 6 then
				lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.puhapaev,qryPalkLib.round);
			End if;
			If  qryPalkLib.tund = 7 then
				lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.uleajatoo,qryPalkLib.round);
			End if;
			if qryPalkLib.tund =3 then
				lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.ohtu,qryPalkLib.round);
			end if;
			if qryPalkLib.tund =4 then
				lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.oo,qryPalkLib.round);
			end if;
			if qryPalkLib.tund =2 then
				lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.paev,qryPalkLib.round);
			end if;

			return lnSumma;

		end if;

		If  qryPalkLib.tund = 5 then

			lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.tahtpaev,qryPalkLib.round);

			lnBaas := qryTaabel1.tahtpaev;

		End if;

		If  qryPalkLib.tund = 6 then

			lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.puhapaev,qryPalkLib.round);

			lnBaas := qryTaabel1.puhapaev;

		End if;

		If  qryPalkLib.tund = 7 then

			lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.uleajatoo,qryPalkLib.round);

			lnBaas := qryTaabel1.uleajatoo;

		End if;

		If  qryPalkLib.tund < 5 then			

			if qryPalkLib.tund =3 then

				nSumma := lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.ohtu;

			end if;

			if qryPalkLib.tund =4 then

				nSumma := lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.oo;

			end if;

			if qryPalkLib.tund =2 then

				nSumma := lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.paev;

			end if;

			if qryPalkLib.tund =1 then

				nSumma := lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.kokku;

			end if;

--			raise notice 'nSumma %',nSumma;


--			raise notice 'lnSumma %',lnSumma;


			lnSumma := lnSumma + f_round( nSumma, qryPalkLib.round);


--			raise notice 'LnSumma %',lnSumma;


--			raise notice '	qryPalklib.round %',qrypalklib.round;

			lnBaas := lnBaas + case when qryPalkLib.tund =3 then qryTaabel1.ohtu else 

				case when qryPalkLib.tund =4 then qryTaabel1.oo else qryTaabel1.paev end end; 

		End if;

	Else

--		lnBaas := calc_alimentid ();

--		lnPalk = f_round( lnBaas * v_palk_kaart.Summa * 0.01)

	End if;



Else

	lnSumma := f_round(v_palk_kaart.Summa * v_palk_kaart.kuurs,qryPalkLib.round);

	lnBaas := 0;

End if;



Return lnSumma;

end; 

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_calc_arv(integer, integer, date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_calc_arv(integer, integer, date) TO vlad;
GRANT EXECUTE ON FUNCTION sp_calc_arv(integer, integer, date) TO public;
GRANT EXECUTE ON FUNCTION sp_calc_arv(integer, integer, date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_calc_arv(integer, integer, date) TO dbpeakasutaja;

CREATE OR REPLACE FUNCTION sp_calc_avansimaksed(integer)
  RETURNS integer AS
$BODY$
declare 
	tnId alias for $1;
	lnLepingId int4;
	lnPalkSumma numeric;
	lnTMSumma numeric;
	lnPMSumma numeric;
	lnTKMSumma numeric;
	lnSots numeric;
	lnJournalId int4;
	lnLiik int;
	lnAsutusId int4;
	lnPalkOperId int4;
	lnSumma numeric;
	lcTunnus varchar;
	lnPM numeric;
	lnTKM numeric;
	lnTM numeric;
	v_palk_oper record;
	tmpPalkKaart record;
	v_klassiflib record;
begin

lnPalkSumma := 0;
lnTMSumma := 0;
lnPMSumma := 0;
lnTKMSumma := 0;
lcTunnus := space(1);

-- otsime palgakaart

Select palk_oper.*, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs into v_palk_oper 
	From palk_oper left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1 and dokvaluuta1.dokliik = 12)
	Where Id = tnId ;

for tmpPalkKaart in
Select palk_lib.round, palk_lib.liik, palk_lib.asutusest, palk_kaart.* , ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs
	From palk_kaart 
	INNER Join palk_lib On palk_kaart.libId = palk_lib.parentid
	left outer join dokvaluuta1 on (palk_kaart.id = dokvaluuta1 and dokvaluuta1.dokliik = 20)	
	WHERE lepingId = v_palk_oper.lepingId And Status = 1 Order By liik  
loop
	lnSumma := 0;

--	if  tmpPalkKaart.liik = 1 then
	--	arvestused
	--	kas on 2%
		select  sum(Summa ) inTo lnPM From palk_kaart INNER Join palk_lib On palk_kaart.libId = palk_lib.parentid
			WHERE lepingId = v_palk_oper.lepingId And Status = 1 and liik = 8 And percent_ = 1 And tulumaks = 1 ;
		lnPm := ifnull(lnPm,0);
	--	kas on 1%
		-- muudetud 02/02/2004
		select sum(Summa) inTo lnTKM From palk_kaart INNER Join palk_lib On palk_kaart.libId = palk_lib.parentid
			WHERE lepingId = v_palk_oper.lepingId And Status = 1 and liik = 7 And asutusest = 0 And percent_ = 1 And tulumaks = 1;
		lnTKM := ifnull(lnTKM,0);
	--	kas on tulumaks%
		select sum(Summa) inTo lnTM From palk_kaart INNER Join palk_lib On palk_kaart.libId = palk_lib.parentid
			WHERE lepingId = v_palk_oper.lepingId And Status = 1 and liik = 4 And percent_ = 1 ;

		lnTM := ifnull(lnTM,0);

		select sum(Summa) inTo lnSots From palk_kaart INNER Join palk_lib On palk_kaart.libId = palk_lib.parentid
			WHERE lepingId = v_palk_oper.lepingId And Status = 1 AND liik = 5 And percent_ = 1 ;

		lnSots := ifnull(lnSots,0);

		If lnPM = 100 then
			lnPM := 2;
		End if;
		If lnTKM = 100 then
			lnTKM := 1;
		End if;
		If lnTM = 100 then
			lnTM := 24;
		End if;

		lnPalkSumma := (v_palk_oper.Summa * v_palk_oper.kuurs) / (0.01*(100 - lnPM)) / (0.01*(100-lnTKM)) / (0.01*(100 - lnTM));
		lnPMSumma := lnPalkSumma * 0.01 * lnPM;
		lnTKMSumma := lnPalkSumma * 0.01 * lnTKM;

		if tmpPalkKaart.liik = 4 then
			lnSumma := (lnPalkSumma - lnPMSumma - lnTKMSumma) * 0.01 * tmpPalkKaart.Summa;
		end if;

		if tmpPalkKaart.liik = 7 AND tmpPalkKaart.asutusest = 0 then
			lnSumma := lnPalkSumma  * 0.01 * tmpPalkKaart.Summa;
		end if;
		if tmpPalkKaart.liik = 8 then
			lnSumma := lnPalkSumma  * 0.01 * tmpPalkKaart.Summa;
		END if;
	
		lnSumma := f_round(lnSumma,tmpPalkKaart.round);
		
		-- muudetud 2/2/2005
		If lnSumma > 0 then
			Select * Into v_klassiflib From klassiflib Where libId = tmpPalkKaart.libId LIMIT 1;
			If v_klassiflib.tunnusid > 0 then
				Select kood into lcTunnus from Library where id = v_klassiflib.tunnusid;
			End if;

			lcTunnus := ifnull(lcTunnus,Space(1));

			lnpalkOperId = sp_salvesta_palk_oper(0,v_palk_oper.rekvid,tmpPalkKaart.LibId,tmpPalkKaart.lepingid,V_PALK_OPER.Kpv,lnSumma,v_palk_oper.Doklausid ,
				'AVANS', ifnull(v_klassiflib.kood1,space(1)),ifnull(v_klassiflib.kood2,space(1)),  ifnull(v_klassiflib.kood3,space(1)), 
				ifnull(v_klassiflib.kood4,space(1)), ifnull(v_klassiflib.kood5,space(1)),  ifnull(v_klassiflib.konto,space(1)),
				v_palk_oper.Tp, lcTunnus, fnc_currentvaluuta(V_PALK_OPER.Kpv), fnc_currentkuurs(V_PALK_OPER.Kpv),tcProj);
		end if;

End loop;

Return 1;

end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_calc_avansimaksed(integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_calc_avansimaksed(integer) TO vlad;
GRANT EXECUTE ON FUNCTION sp_calc_avansimaksed(integer) TO public;
GRANT EXECUTE ON FUNCTION sp_calc_avansimaksed(integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_calc_avansimaksed(integer) TO dbpeakasutaja;


CREATE OR REPLACE FUNCTION sp_calc_kinni(integer, integer, date)
  RETURNS numeric AS
$BODY$
declare
	tnLepingid alias for $1;
	tnLibId alias for $2;
	tdKpv alias for $3;
	lnSumma numeric (12,4);
	v_palk_kaart record;
	qrytooleping record;
	qryPalkLib   record;
	qryTaabel1 record;
	npalk	numeric(12,4);
	nHours int;
	lnRate numeric (12,4);
	nSumma numeric (12,4);
	lnBaas numeric (12,4);
	lnkulumaks	numeric(12,4);
begin
nHours :=0;
lnSumma := 0;
nPalk:=0;
lnBaas :=0;
select palk_kaart.*, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs into v_palk_kaart 
	from palk_kaart left outer join dokvaluuta1 on (palk_kaart.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 20)
	where lepingid = tnLepingid and libId = tnLibId;
	
select * INTO qryPalkLib from palk_lib where parentId = tnLibId;
select tooleping.*, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs into qryTooleping 
	from tooleping left outer join dokvaluuta1 on (tooleping.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 19)
	where tooleping.id = tnlepingId;

nHours := (sp_workdays(1,month(tdKpv), year(tdKpv), 31,v_palk_kaart.lepingId) * qryTooleping.koormus * 0.01 * qryTooleping.toopaev)::int4;
select * into qryTaabel1 from palk_taabel1 where toolepingId = tnlepingId and kuu = month(tdKpv) and aasta = year (tdKpv);

if qryPalkLib.palgafond = 0 then
		lnSumma := qryTooleping.palk * qryTooleping.kuurs  * 0.01 * qryTooleping.tooPAEV * (qryTaabel1.kokku / nHours);
end if;

nPalk = 0;

if qryPalkLib.palgafond = 1 then
	IF qryPalkLib.LIIK = 7  THEN
		SELECT sum(Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)) INTO npalk 
			FROM palk_oper inner join Palk_lib on palk_lib.parentid = palk_oper.libid  
			left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
			WHERE  Palk_oper.kpv = tdKpv      
			AND Palk_lib.liik = 1 
			and palk_oper.lepingId = tnLepingId 
			and palk_lib.tululiik <> '13'
			and palk_lib.sots = 1 ;

	END IF;
	IF qryPalkLib.LIIK = 8  THEN
--		raise notice '8';
		SELECT sum(Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)) INTO npalk 
			FROM palk_oper inner join Palk_lib on palk_lib.parentid = palk_oper.libid  
			left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
			WHERE  Palk_oper.kpv = tdKpv      
			AND Palk_lib.liik = 1 and palk_oper.lepingId = tnLepingId and palk_lib.sots = 1;

	END IF;
	IF nPalk = 0 and qryPalkLib.LIIK <> 7  and qryPalkLib.LIIK <> 8  THEN
			SELECT sum(Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)) INTO npalk 
			FROM palk_oper inner join Palk_lib on palk_lib.parentid = palk_oper.libid  
			left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
			WHERE Palk_oper.kpv = tdKpv
			AND Palk_lib.liik = 1 and palk_oper.lepingId = tnLepingId;
	end if;
	
End if;

If qryPalkLib.maks = 1 then
	SELECT sum (Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)) INTO lnkulumaks 
		FROM palk_oper inner join Palk_lib on palk_oper.libid = palk_lib.parentid 
		left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
		WHERE Palk_lib.liik = 4    AND Palk_oper.kpv = tdKpv   
		AND palk_oper.lepingId = tnLepingId;
Else
	lnkulumaks := 0;
End if;

--raise notice ' npalk: %',npalk;

nPalk := nPalk - lnkulumaks;

If v_palk_kaart.percent_ > 0 then
	lnSumma := f_round(nPalk * (0.01 * v_palk_kaart.summa),qryPalkLib.round);
Else
	lnSumma := f_round(v_palk_kaart.summa * v_palk_kaart.kuurs ,qryPalkLib.round);
End if;

-- muudetud 23/02/2005
IF lnSumma > 0 then
		-- kontrol kas on tulumaks avansimaksetest

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) inTO lnkulumaks 
		from palk_oper 
		left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
		where palk_oper.lepingId = tnLepingId 
		AND YEAR(palk_oper.kpv) = YEAR(tdKpv) 
		and MONTH(palk_oper.kpv) = MONTH(tdKpv)  
		AND palk_oper.libId = tnLibId 
		AND palk_oper.MUUD = 'AVANS';

		IF lnkulumaks > 0 then 
			lnSumma := lnSumma - lnkulumaks;
		END IF;
	END IF;

Return lnSumma;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_calc_kinni(integer, integer, date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_calc_kinni(integer, integer, date) TO vlad;
GRANT EXECUTE ON FUNCTION sp_calc_kinni(integer, integer, date) TO public;
GRANT EXECUTE ON FUNCTION sp_calc_kinni(integer, integer, date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_calc_kinni(integer, integer, date) TO dbpeakasutaja;



CREATE OR REPLACE FUNCTION sp_calc_kulum(integer)
  RETURNS numeric AS
$BODY$
declare 
	tnId	ALIAS FOR $1;
	lnSumma numeric(12,4);

	v_pv_kaart record;

	lnSummaParandus numeric(12,4);
	lnSummaUmberHind numeric(12,4);
	lnKpvUmberHind date;

	lnSummaKulum numeric(12,4);

	lnJaak numeric(12,4);
	v_jaak record;

BEGIN
lnSumma := 0;

select pv_kaart.*, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs into v_pv_kaart 
	FROM pv_kaart left outer join dokvaluuta1 on (dokvaluuta1.dokid = pv_kaart.id and dokliik = 18) where parentId = tnId;


SELECT (Pv_oper.summa*ifnull(dokvaluuta1.kuurs,1)::numeric), kpv into lnSummaUmberHind, lnKpvUmberHind 
	FROM Pv_oper left outer join dokvaluuta1 on (dokvaluuta1.dokid = pv_oper.id and dokvaluuta1.dokliik = 13) 
	WHERE Pv_oper.parentid = tnId AND Pv_oper.liik = 5 order by kpv desc limit 1;

if not found then
	lnKpvUmberHind := v_pv_kaart.soetkpv;
	lnSummaUmberHind := (v_pv_kaart.soetmaks*v_pv_kaart.kuurs) ;
end if;

raise notice 'lnSummaUmberHind %',lnSummaUmberHind;
raise notice 'lnKpvUmberHind %',lnKpvUmberHind;


SELECT sum (Pv_oper.summa *ifnull(dokvaluuta1.kuurs,1)::numeric) into lnSummaParandus 
	FROM Pv_oper left outer join dokvaluuta1 on (dokvaluuta1.dokid = pv_oper.id and dokvaluuta1.dokliik = 13) 
	WHERE Pv_oper.parentid = tnId 
	AND Pv_oper.liik = 3 
	and kpv >= lnKpvUmberHind;

SELECT sum (Pv_oper.summa *ifnull(dokvaluuta1.kuurs,1)::numeric) into lnSummaKulum 
	FROM Pv_oper left outer join dokvaluuta1 on (dokvaluuta1.dokid = pv_oper.id and dokvaluuta1.dokliik = 13) 
	WHERE Pv_oper.parentid = tnId  
	AND Pv_oper.liik = 2 
	and kpv >= lnKpvUmberHind;


raise notice 'lnSummaParandus %',lnSummaParandus;
raise notice 'lnSummaKulum %',lnSummaKulum;


if v_pv_kaart.Jaak > 0 then

	lnSumma := round(v_pv_kaart.kulum * 0.01 * (lnSummaUmberHind + ifnull(lnSummaParandus,0)) / 12,0);  

	if lnSumma > (v_pv_kaart.Jaak * v_pv_kaart.kuurs) then

		lnSumma := v_pv_kaart.Jaak * v_pv_kaart.kuurs;

	END IF;

end if;

RETURN lnSumma;

end;


$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_calc_kulum(integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_calc_kulum(integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_calc_kulum(integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION sp_calc_kulum(integer) TO dbadmin;
GRANT EXECUTE ON FUNCTION sp_calc_kulum(integer) TO dbvaatleja;


CREATE OR REPLACE FUNCTION sp_calc_muuda(integer, integer, date)
  RETURNS numeric AS
$BODY$
declare
	tnLepingid alias for $1;
	tnLibId alias for $2;
	tdKpv alias for $3;
	lnSumma numeric (14,4);
	v_palk_kaart record;
	qrytooleping record;
	qryPalkLib   record;
	v_palk_config record;
	qryTaabel1 record;
	nSumma numeric(14,4);
	nHours int4;
	lnBaas numeric(14,4);
	lnrekv int4;
	lnKulud numeric(14,4);
begin

lnSumma :=0;

select palk_kaart .*, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs into v_palk_kaart 
	from palk_kaart left outer join dokvaluuta1 on (palk_kaart.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 20)	
	where lepingid = tnLepingid and libId = tnLibId;
	
select * INTO qryPalkLib from palk_lib where parentId = tnLibId;

select tooleping.*, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs into qryTooleping 
	from tooleping left outer join dokvaluuta1 on (tooleping.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 19)
	where tooleping.id = tnlepingId;

select * into v_palk_config from palk_config where rekvid = qryTooleping.rekvid;
--select rekvId into lnrekv from library where id = qryPalkLib.parentId;
select * into qryTaabel1 from palk_taabel1 where toolepingId = tnlepingId; 


nHours := (sp_workdays(1, month(tdKpv), year(tdKpv), 31,v_palk_kaart.lepingId) / (qryTooleping.koormus * 0.01) * qryTooleping.toopaev)::INT4;
If v_palk_kaart.percent_ = 1 then
	if  qryPalkLib.palgafond = 0 then
		lnSumma := qryTooleping.palk * 0.01 * qryTooleping.toopaev * (qryTaabel1.kokku / nHours);
	end if;
	if qryPalkLib.palgafond = 1 then
		if qryPalkLib.liik = 7  then
			raise notice '7';
			SELECT sum(Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)) INTO lnSumma 
			FROM palk_oper inner join Palk_lib on palk_lib.parentid = palk_oper.libid  
			left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
			WHERE  Palk_oper.kpv = tdKpv      
			AND Palk_lib.liik = 1 and palk_oper.lepingId = tnLepingId and palk_lib.sots = 1 
			and palk_lib.tululiik <> '13';
		end if;	
		if  qryPalkLib.liik = 8 then
			raise notice '8';
			SELECT sum(Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)) INTO lnSumma 
			FROM palk_oper inner join Palk_lib on palk_lib.parentid = palk_oper.libid  
			left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
			WHERE  Palk_oper.kpv = tdKpv      
			AND Palk_lib.liik = 1 and palk_oper.lepingId = tnLepingId and palk_lib.sots = 1;
		end if;	
		if  qryPalkLib.liik <> 7 and qryPalkLib.liik <> 8 then
			raise notice 'muud';
			-- tulud
			SELECT sum(Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)) INTO lnSumma 
			FROM palk_oper inner join Palk_lib on palk_lib.parentid = palk_oper.libid  
			left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
			WHERE  Palk_oper.kpv = tdKpv      
			AND Palk_lib.liik = 1 and palk_oper.lepingId = tnLepingId;
		end if;
	end if;
	if qryPalkLib.maks = 1 then
		-- Tulud - Kulud
		-- Arvestame kulud

		SELECT sum(palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)) into lnKulud
		FROM palk_kaart inner join palk_oper on 
		(palk_kaart.lepingid = palk_oper.lepingid and palk_kaart.libid = palk_oper.libid)  
		left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
		where palk_kaart.lepingId = tnLepingId
		AND Palk_oper.kpv = tdKpv  
		and palk_kaart.libid in (select library.id from library inner join palk_lib on palk_lib.parentid = library.id where Palk_lib.liik in (2,4,7,8 ));
		lnSumma = lnSumma - ifnull(lnKulud,0);
		if lnSumma < 0 then
			lnSumma = 0;
		end if;		
	end if;

	
	lnSumma := f_round(v_palk_kaart.summa * 0.01 * lnSumma, qryPalkLib.round);
Else
	lnSumma := f_round(v_palk_kaart.Summa * v_palk_kaart.kuurs, qryPalkLib.round);
End if;

Return lnSumma;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_calc_muuda(integer, integer, date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_calc_muuda(integer, integer, date) TO vlad;
GRANT EXECUTE ON FUNCTION sp_calc_muuda(integer, integer, date) TO public;
GRANT EXECUTE ON FUNCTION sp_calc_muuda(integer, integer, date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_calc_muuda(integer, integer, date) TO dbpeakasutaja;



CREATE OR REPLACE FUNCTION sp_calc_sots(integer, integer, date)
  RETURNS numeric AS
$BODY$
declare
	tnLepingid alias for $1;
	tnLibId alias for $2;
	tdKpv alias for $3;
	lnSumma numeric (12,4);
	v_palk_kaart record;
	qrytooleping record;
	qryPalkLib   record;
	v_palk_config record;
	nSumma numeric (12,4);
	lnBaas numeric (12,4);
	lnrekv int;
	lnMinPalk numeric (12,4);
begin
lnBaas :=0;
lnsUMMA :=0;


select palk_kaart.summa, palk_kaart.percent_, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs into v_palk_kaart 
	from palk_kaart left outer join dokvaluuta1 on (dokvaluuta1.dokid = palk_kaart.id and dokvaluuta1.dokliik = 20)
	where lepingid = tnLepingid and libId = tnLibId;
	
select parentid, round INTO qryPalkLib from palk_lib where parentId = tnLibId;

If v_palk_kaart.percent_ = 1 then

	select pohikoht into qryTooleping from tooleping where id = tnlepingId;
	select rekvId into lnrekv from library where id = qryPalkLib.parentId;
	select minpalk into v_palk_config from palk_config where rekvid = lnrekv;

	SELECT sum(Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)) INTO lnBaas 
	FROM palk_oper inner join Palk_lib on palk_lib.parentid = palk_oper.libid 
	left outer join dokvaluuta1 on (dokvaluuta1.dokid = palk_oper.id and dokvaluuta1.dokliik = 12) 
	WHERE  Palk_oper.kpv = tdKpv      
	AND Palk_lib.liik = 1 and palk_oper.lepingId = tnLepingId and palk_lib.sots = 1;

	lnMinPalk := case when qryTooleping.pohikoht > 0 then v_palk_config.minpalk else 0 end;
	lnSumma := f_round(v_palk_kaart.summa * 0.01 * lnBaas,qryPalkLib.round);
else
	lnSumma := f_round(v_palk_kaart.Summa * v_palk_kaart.kuurs, qryPalkLib.round);
end if;

Return lnSumma;

end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_calc_sots(integer, integer, date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_calc_sots(integer, integer, date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_calc_sots(integer, integer, date) TO dbpeakasutaja;


CREATE OR REPLACE FUNCTION sp_calc_tasu(integer, integer, date)
  RETURNS numeric AS
$BODY$
declare
	tnLepingid alias for $1;
	tnLibId alias for $2;
	tdKpv alias for $3;
	lnSumma numeric (12,4);
	v_palk_kaart record;
	qrytooleping record;
	qryPalkLib   record;
	v_palk_config record;
	v_palk_jaak record;
	nSumma numeric (12,4);
begin

lnsUMMA :=0;

select palk_kaart.*, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs into v_palk_kaart 
	from palk_kaart left outer join dokvaluuta1 on (palk_kaart.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 20)
	where lepingid = tnLepingid and libId = tnLibId;
	
select * INTO qryPalkLib from palk_lib where parentId = tnLibId;


if v_palk_kaart.percent_ = 1 then
	SELECT Palk_jaak.lepingId, Palk_jaak.id, Palk_jaak.kuu, Palk_jaak.aasta,  Palk_jaak.jaak, Palk_jaak.arvestatud, Palk_jaak.kinni,  
	Palk_jaak.TKA, Palk_jaak.tki, Palk_jaak.pm, Palk_jaak.tulumaks, Palk_jaak.sotsmaks, Palk_jaak.muud 
	into v_palk_jaak
	FROM  Palk_jaak WHERE Palk_jaak.lepingId = tnLepingId   AND Palk_jaak.kuu = month(tdKpv)   
	AND Palk_jaak.aasta = year(tdKpv)  
	ORDER by kuu desc, aasta desc 
	limit 1;

	lnSumma := f_round(v_palk_kaart.summa * 0.01 * v_palk_jaak.jaak, qryPalkLib.round);


else

	lnSumma := f_round(v_palk_kaart.summa * v_palk_kaart.kuurs, qryPalkLib.round);

end if;


Return lnSumma;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_calc_tasu(integer, integer, date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_calc_tasu(integer, integer, date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_calc_tasu(integer, integer, date) TO dbpeakasutaja;



CREATE OR REPLACE FUNCTION sp_calc_tulumaks(integer, integer, date)
  RETURNS numeric AS
$BODY$
declare
	tnLepingid alias for $1;
	tnLibId alias for $2;
	tdKpv alias for $3;
	lnSumma numeric (12,4);
	v_palk_kaart record;
	qrytooleping record;
	qryPalkLib   record;
	v_palk_config record;
	qryTulumaks record;
	nSumma numeric (12,4);
	lnBaas numeric (12,4);
	lnrekv int;
	lnMinPalk numeric (12,4);
	lnTulud numeric (12,4);
	lnKulud numeric (12,4);
	lnTulubaas numeric(12,4);	
	lnG31 numeric(12,4);
	lnG31_2004 numeric(12,4);
	lnG31_2005 numeric(12,4);

	nG31 numeric(12,4);
	lnCount	int;
	lnCount_2004	int;
	lnCount_2005	int;
	lnArvJaak numeric (12,4);
begin
lnBaas :=0;
lnsUMMA :=0;


select  palk_kaart.*, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs into v_palk_kaart 
	from palk_kaart left outer join dokvaluuta1 on (palk_kaart.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 20) 
	where lepingid = tnLepingid and libId = tnLibId;
	
select * into qryTooleping from tooleping where id = tnlepingId;

--muudetud 25/01/2005
IF v_palk_kaart.tulumaar = 0 AND qryTooleping.pohikoht = 0 then
	RETURN 0;
END IF;


select * INTO qryPalkLib from palk_lib where parentId = tnLibId;
select rekvId into lnrekv from library where id = qryPalkLib.parentId;
select * into v_palk_config from palk_config where rekvid = lnrekv;



--muudetud 03/01/2005

if qryTooleping.pohikoht > 0  then
/*
	if year(date()) = 2004 then
		lnTulubaas := 1400;
	else
		lnTulubaas := 1700;
	end if;
*/
	lnTulubaas = V_palk_config.tulubaas;
else
	lnTulubaas :=0;	
end if;
raise notice 'lnTulubaas %',lnTulubaas;
--lnTulubaas := case when qryTooleping.pohikoht > 0 then case when year(tdKpv) = 2004 then 1400 else 1700 end V_palk_config.tulubaas else 0 end;
if v_palk_kaart.percent_ = 0 then
	-- summa 
	lnSumma := v_palk_kaart.summa * v_palk_kaart.kuurs;

else
--	raise notice 'alg';


	--muudetud 25/01/2005
	If qryTooleping.pohikoht = 1 then

		Select  Sum(Palk_oper.Summa * ifnull(dokvaluuta1.kuurs,1)) into lnTulud		
		FROM  Palk_oper inner Join palk_lib On palk_lib.parentId = Palk_oper.libId 	
		inner Join palk_kaart  On (palk_kaart.libId = Palk_oper.libId 
		And Palk_oper.lepingid = palk_kaart.lepingid)
		left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12) 	
		WHERE palk_lib.liik = 1   And palk_kaart.tulumaks = 1   And Palk_oper.kpv = tdKpv 	
		and Palk_oper.kpv = tdKpv  And Palk_oper.rekvid = lnrekv 
		And palk_kaart.lepingid In 
		(SELECT id FROM tooleping WHERE parentid = qryTooleping.parentId AND (tooleping.id = tnlepingId  
		OR tooleping.id in (select DISTINCT lepingId FROM palk_kaart WHERE tulumaar = 0)));


	raise notice 'lnTulud %',lnTulud;

		Select Sum(Palk_oper.Summa * ifnull(dokvaluuta1.kuurs,1)) into lnKulud 	
		FROM palk_kaart inner Join Palk_oper On 	
		(palk_kaart.lepingid = Palk_oper.lepingid And palk_kaart.libId = Palk_oper.libId)
		left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12) 	
		WHERE Palk_oper.kpv = tdKpv
		AND Palk_oper.rekvid = lnrekv And palk_kaart.tulumaks = 1 
		and palk_kaart.libId In (Select Library.Id From Library inner Join palk_lib On palk_lib.parentId = Library.Id 	
		where palk_lib.liik = 2 Or palk_lib.liik = 7 Or palk_lib.liik = 8 )
		And palk_kaart.lepingid In (SELECT id FROM tooleping WHERE parentid = qryTooleping.parentId AND (id = tnlepingId  
		OR id in (select DISTINCT lepingId FROM palk_kaart WHERE tulumaar = 0)));

raise notice 'lnKulud %',lnKulud;
	else

		SELECT  sum(Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)) into lnTulud
		FROM  Palk_oper inner join Palk_lib on palk_lib.parentid = palk_oper.libid 
		inner join Palk_kaart  on (palk_kaart.libid = palk_oper.libid and palk_oper.lepingId = palk_kaart.lepingid) 
		left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12) 	
		WHERE Palk_lib.liik = 1   AND Palk_kaart.tulumaks = 1   
		AND Palk_oper.kpv = tdkpv 
		and palk_oper.kpv = tdKpv  
		AND Palk_oper.rekvId = lnrekv and palk_oper.lepingId = tnLepingid;


--		and val(ltrim(rtrim(palk_Lib.algoritm))) = v_palk_kaart.summa ;

raise notice 'lnTulud %',lnTulud;


		SELECT sum(Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)) into lnKuluD  
		FROM palk_kaart inner join palk_oper on 
		(palk_kaart.lepingid = palk_oper.lepingid and palk_kaart.libid = palk_oper.libid)  
		left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12) 	
		where palk_kaart.lepingId = tnLepingid 
		AND Palk_oper.kpv = tdKpv
		AND Palk_oper.kpv = tdKpv
		AND Palk_oper.rekvId = lnRekv and palk_kaart.tulumaks = 1 
		and palk_kaart.libid in (select library.id from library inner join palk_lib on palk_lib.parentid = library.id 
		where Palk_lib.liik = 2 OR PALK_LIB.LIIK = 7 OR PALK_LIB.LIIK = 8 );
 

--	and tulumaar = v_palk_kaart.summa

	end if;
raise notice 'lnKulud %',lnKulud;
	if lnTulubaas > 0 and qryTooleping.pohikoht > 0 then  
--		raise notice 'lnTulubaas %',lnTulubaas;
		select sum(palk_jaak.g31) into lng31_2005 from palk_jaak 
			where lepingId = tnlepingId 
			and aasta = year(tdKpv) 
			and kuu < month(tdKpv);

		lng31 := lng31_2005;

		raise notice 'lng31 %',lng31;
		select count(*) into lnCount_2005 from palk_jaak 
			where lepingId = tnlepingId 
			and aasta = year(tdKpv) 
			and kuu < month(tdKpv)
			and date(aasta,kuu,1) >= qryTooleping.algab;


		raise notice 'lnCount %',lnCount;

		-- should be 1400 * periods
		ng31 := V_palk_config.tulubaas * lnCount_2005 ;
		raise notice 'ng31 %',ng31;

		lnArvJaak := lnTulud - lnKulud;
		if lnArvJaak < lnTulubaas then
			lnTulubaas := lnArvJaak;
			raise notice 'less then vaja %',lnTulubaas;
		else

			if ng31 > lng31_2005 and lnCount_2005 > 0 then
				-- on reserv
				lnTulubaas := lnTulubaas + (ng31 - lng31_2005);
				raise notice 'with reserv  %',lnTulubaas;
			end if;
			raise notice 'with reserv after %',lnTulubaas;
			raise notice 'limited lnArvJaak%',lnArvJaak;
			if lnTulubaas > lnArvJaak then
				lnTulubaas := lnArvJaak;
			end if;
		end if;

	end if;

	lnSumma := f_round(v_palk_kaart.summa * 0.01 * (ifnull(lnTuluD,0) - ifnull(lnTulubaas,0) - ifnull(lnkuluD,0)),qryPalkLib.Round);
	lnSumma := case when lnSumma < 0 then 0 else lnSumma end;

-- muudetud 04/01/2005
	IF lnSumma > 0 then
		-- kontrol kas on tulumaks avansimaksetest

		select sum(summa * ifnull(dokvaluuta1.kuurs,1)) inTO lnTulubaas 
			from palk_oper left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
			where lepingId = tnLepingId AND YEAR(kpv) = YEAR(tdKpv) and MONTH(kpv) = MONTH(tdKpv)  AND libId = tnLibId 
			AND palk_oper.MUUD = 'AVANS';
		IF lnTulubaas > 0 then 
			lnSumma := lnSumma - lnTulubaas;
		END IF;
	END IF;


	raise notice 'lnSumma %',lnSumma;
end if;
Return lnSumma;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_calc_tulumaks(integer, integer, date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_calc_tulumaks(integer, integer, date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_calc_tulumaks(integer, integer, date) TO dbpeakasutaja;


CREATE OR REPLACE FUNCTION sp_eelarve_aruanne1(integer, date, date, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, integer)
  RETURNS character varying AS
$BODY$
DECLARE 
	tnrekvid alias for $1;
	tdKpv1 alias for $2;
	tdKpv2 alias for $3;
	tnRekvidSub alias for $4;
	tcTunnus alias for $5;
	tcKonto alias for $6;
	tcAllikas alias for $7;
	tcTegev alias for $8;
	tcEelarve alias for $9;
	tcProjekt alias for $10;
	tcTp alias for $11;
	tnLiik alias for $12;
	tnSvod alias for $13;

	lcReturn varchar;
	lcString varchar;

	lnrekvid1 int;
	lnrekvid2 int;

	LNcOUNT int;
	lnSumma numeric(12,4);

	v_eelaruanne record;

begin


	select count(*) into lnCount from pg_stat_all_tables where UPPER(relname) = 'TMP_EELARVE_ARUANNE1';



	if ifnull(lnCount,0) < 1 then



	raise notice ' lisamine  ';

	

		create table tmp_eelarve_aruanne1 ( id int, konto varchar(20), 
			RekvIdSub int not null default 0, AllAsutus varchar(254) not null default space(1),
			db numeric(14,2) not null default 0, tp_db varchar(20) not null default space(20), 
			kr numeric(14,2) not null default 0, tp_kr varchar(20) not null default space(20),
			tunnus varchar(20) not null default space(20),
			allikas varchar(20) not null default space(20),
			tegev varchar(20) not null default space(20),
			eelarve varchar(20) not null default space(20),
			rahavoo varchar(20) not null default space(20),
			projekt varchar(20) not null default space(20),
			timestamp varchar(20) not null , kpv date not null default date(), rekvid int not null  )  ;

		

		GRANT ALL ON TABLE tmp_eelarve_aruanne1 TO GROUP public;



	else
		delete from tmp_eelarve_aruanne1 where kpv < date() and rekvid = tnrekvId;

	end if;


	select count(*) into lnCount from pg_stat_all_tables where UPPER(relname) = 'TMP_EELPROJ_ARUANNE1';


	if ifnull(lnCount,0) < 1 then

		raise notice ' lisamine  ';


		create table tmp_eelproj_aruanne1 ( id int, konto varchar(20), 
			RekvIdSub int not null default 0, AllAsutus varchar(254) not null default space(1),
			summa1 numeric(14,2) not null default 0, 
			summa2 numeric(14,2) not null default 0, 
			summa3 numeric(14,2) not null default 0, 
			summa4 numeric(14,2) not null default 0, 
			summa5 numeric(14,2) not null default 0, 
			summa6 numeric(14,2) not null default 0, 
			summa7 numeric(14,2) not null default 0, 
			summa8 numeric(14,2) not null default 0, 
			tunnus varchar(20) not null default space(20),
			allikas varchar(20) not null default space(20),
			tegev varchar(20) not null default space(20),
			eelarve varchar(20) not null default space(20),
			rahavoo varchar(20) not null default space(20),
			projekt varchar(20) not null default space(20),
			objekt varchar(20) not null default space(20),
			nimetus varchar(254) null,
			timestamp varchar(20) not null , kpv date not null default date(), rekvid int not null  )  ;

		

		GRANT ALL ON TABLE tmp_eelproj_aruanne1 TO GROUP public;



	else
		delete from tmp_eelproj_aruanne1 where kpv < date() and rekvid = tnrekvId;

	end if;




if (select count(*) from pg_stat_all_tables where UPPER(relname) = 'TMPREKV')  > 0 then
	delete from tmpRekv;
--	truncate TABLE tmpRekv;
	insert into tmpRekv
		SELECT id, parentid, fnc_get_asutuse_staatus(rekv.id, tnrekvid)::int as tase FROM rekv;
else
	CREATE TABLE tmpRekv AS
		SELECT id, parentid, fnc_get_asutuse_staatus(rekv.id, tnrekvid)::int as tase FROM rekv;
		GRANT ALL ON TABLE tmpRekv TO GROUP public;

END IF;

if tnSvod = 1 then
	delete from tmpRekv where tase < 3;

else
	delete from tmpRekv where tase in (0,1,2,4);
end if;


	lcreturn := to_char(now(), 'YYYYMMDDMISSSS');
	raise notice 'tnLiik %',tnLiik;
	raise notice 'tcEelarve %',tcEelarve;





	if tnLiik = 101 or tnLiik = 102 or tnLiik = 111 or tnLiik = 112 then
		-- 1.	Eelarve tulude jaotus allikate lõikes    
		
		if tnRekvIdSub = 0 then
			lnRekvid1 = 0;
			lnrekvid2 = 999999;
		else
			lnRekvid1 = tnRekvIdSub;
			lnrekvid2 = tnRekvIdSub;
		end if;

		raise notice 'eelarve tulud kinnitatud';

		insert into tmp_eelproj_aruanne1 (  RekvIdSub, SUMMA1, eelarve, rekvid, timestamp, tunnus)	
			SELECT  eelarve.rekvid,  (eelarve.summa*ifnull(dokvaluuta1.kuurs,1))::numeric as summa, eelarve.kood4, tnRekvid, lcreturn, ifnull(library.kood,space(20))::character varying
				FROM eelarve 
				left outer join dokvaluuta1 on (eelarve.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 8)
				left outer join library on library.id = eelarve.tunnusId
				inner join tmprekv on eelarve.rekvId = tmprekv.id
				WHERE Eelarve.aasta = year(tdKpv2)   
				and eelarve.tunnus = 0
				and left(eelarve.kood4,1) in ('3')  
				AND eelarve.kood1 LIKE tcTegev+'%'   
				AND eelarve.kood2 LIKE tcAllikas+'%'   
				AND eelarve.kood4 LIKE tcEelarve+'%'; 

		if tnLiik = 102 or tnLiik = 112 then
		-- eelarve Tapsastatud:

		insert into tmp_eelproj_aruanne1 (tunnus, RekvIdSub, SUMMA2, eelarve, rekvid, timestamp)	
			SELECT ifnull(t.kood, space(20))::character varying, eelarve.rekvid,  (eelarve.summa*ifnull(dokvaluuta1.kuurs,1))::numeric as summa, eelarve.kood4,tnRekvId, lcReturn
				FROM eelarve 
				left outer join dokvaluuta1 on (eelarve.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 8)
				inner join tmprekv on eelarve.rekvId = tmprekv.id
				LEFT JOIN library t ON t.id = eelarve.tunnusid
				WHERE Eelarve.aasta = year(tdKpv2)   
				AND kood1 LIKE tcTegev   
				AND kood2 LIKE tcAllikas
				and eelarve.tunnus = 1 
				and eelarve.kpv <= tdKpv2 
				and left(kood4,1) in ('3')   
				AND kood4 LIKE tcEelarve; 
		end if;

		-- eelarve Taitmine:
		
		if tnLiik = 101 or tnLiik = 102 then
			-- kassa


			insert into tmp_eelproj_aruanne1 (tunnus, RekvIdSub, SUMMA3, eelarve, rekvid, timestamp)	
			SELECT  journal1.tunnus, journal.rekvid, (journal1.summa*ifnull(dokvaluuta1.kuurs,1))::numeric as summa, journal1.kood5, tnRekvId, lcreturn   
				FROM journal inner join journal1 on journal.id = journal1.parentid
				left outer join dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 1)
				inner join tmprekv on journal.rekvId = tmprekv.id
				JOIN kassatulud ON ltrim(rtrim(journal1.kreedit::text)) ~~ ltrim(rtrim(kassatulud.kood::text))
				JOIN kassakontod ON ltrim(rtrim(journal1.deebet::text)) ~~ ltrim(rtrim(kassakontod.kood::text))
				WHERE journal.kpv >= tdKpv1 and journal.kpv <= tdKpv2  
				AND journal1.kood1 LIKE tcTegev +'%'  
				AND journal1.kood2 LIKE tcAllikas +'%'  
				AND journal1.kood5 LIKE tcEelarve +'%'; 
		end if;
	

		if tnLiik = 111 or tnLiik = 112 then
			-- fakt

			insert into tmp_eelproj_aruanne1 (tunnus, RekvIdSub, SUMMA3, eelarve, rekvid, timestamp)	
			SELECT  journal1.tunnus, journal.rekvid, (journal1.summa*ifnull(dokvaluuta1.kuurs,1))::numeric as summa, journal1.kood5, tnRekvId, lcreturn  
				FROM journal inner join journal1 on journal.id = journal1.parentid
				left outer join dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 1)
				inner join tmprekv on journal.rekvId = tmprekv.id
				JOIN fakttulud ON ltrim(rtrim(journal1.kreedit::text)) ~~ ltrim(rtrim(fakttulud.kood::text))
				WHERE journal.kpv >= tdKpv1 and journal.kpv <= tdKpv2    
				AND journal1.kood1 LIKE tcTegev +'%'  
				AND journal1.kood2 LIKE tcAllikas +'%'  
				AND journal1.kood5 LIKE tcEelarve +'%'; 

		end if;

		-- kokkuvõtte

		insert into tmp_eelproj_aruanne1 (RekvIdSub, summa1, summa2, summa3, eelarve, rekvid, timestamp)	
			select RekvIdSub, sum(summa1) , sum(summa2), sum(summa3), eelarve, tnRekvId, lcReturn+'LOPP'
				from tmp_eelproj_aruanne1
				where rekvid = tnRekvId
				and tmp_eelproj_aruanne1.tunnus like tcTunnus+'%'
				and timestamp = lcReturn
				group by RekvIdSub, eelarve
				order by RekvIdSub, eelarve;

		delete from tmp_eelproj_aruanne1 where timestamp = lcReturn and rekvid = tnRekvId;

		lcReturn = lcReturn + 'LOPP';
	end if;


	if tnLiik > 200  and tnLiik <= 612 then
		-- 1.	Eelarve kulud   
		
		if tnRekvIdSub = 0 then
			lnRekvid1 = 0;
			lnrekvid2 = 999999;
		else
			lnRekvid1 = tnRekvIdSub;
			lnrekvid2 = tnRekvIdSub;
		end if;

		-- eelarve kulud kinnitatud
		raise notice 'eelarve kulud kinnitatud, ilma LE-LA';

		insert into tmp_eelproj_aruanne1 (  RekvIdSub, SUMMA1, allikas, tegev, eelarve, rekvid, timestamp, tunnus)	
			SELECT  eelarve.rekvid,  (eelarve.summa*ifnull(dokvaluuta1.kuurs,1))::numeric as summa, eelarve.kood2, eelarve.kood1, eelarve.kood4, tnRekvid, lcreturn, 
				ifnull(library.kood,space(20))::character varying
				FROM eelarve 
				left outer join dokvaluuta1 on (eelarve.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 8)
				left outer join library on library.id = eelarve.tunnusId
				inner join tmprekv on eelarve.rekvId = tmprekv.id
				WHERE Eelarve.aasta = year(tdKpv2)   
				and eelarve.tunnus = 0
				and eelarve.kood2 not in ('LE-LA')
				and (left(eelarve.kood4,1) in ('4','5','6','2')  or left(eelarve.kood4,2) = '15')
				AND eelarve.kood1 LIKE tcTegev+'%'   
				AND eelarve.kood2 LIKE tcAllikas+'%'   
				AND eelarve.kood4 LIKE tcEelarve+'%'; 

		raise notice 'eelarve kulud kinnitatud, koos LE-LA';


		insert into tmp_eelproj_aruanne1 (  RekvIdSub, SUMMA4, allikas, tegev, eelarve, rekvid, timestamp, tunnus)	
			SELECT  eelarve.rekvid,  (eelarve.summa*ifnull(dokvaluuta1.kuurs,1))::numeric as summa, eelarve.kood2, eelarve.kood1, eelarve.kood4, tnRekvid, lcreturn, 
				ifnull(library.kood,space(20))::character varying
				FROM eelarve 
				left outer join dokvaluuta1 on (eelarve.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 8)
				left outer join library on library.id = eelarve.tunnusId
				inner join tmprekv on eelarve.rekvId = tmprekv.id
				WHERE Eelarve.aasta = year(tdKpv2)   
				and eelarve.tunnus = 0
				and eelarve.kood2 in ('LE-LA')
				and (left(eelarve.kood4,1) in ('4','5','6','2')  or left(eelarve.kood4,2) = '15')
				AND eelarve.kood1 LIKE tcTegev+'%'   
				AND eelarve.kood2 LIKE tcAllikas+'%'   
				AND eelarve.kood4 LIKE tcEelarve+'%'; 

		if tnLiik = 202 or tnLiik = 212 or tnLiik = 302 or tnLiik = 312 or tnLiik = 402 or tnLiik = 412 or tnLiik = 502 or tnLiik = 512 
			or tnLiik = 602 or tnLiik = 612 then
		-- eelarve Tapsastatud, ilma LE-LA:

			raise notice 'tapsestatud ';

			insert into tmp_eelproj_aruanne1 (tunnus, RekvIdSub, SUMMA2, allikas, tegev, eelarve, rekvid, timestamp)	
				SELECT ifnull(t.kood, space(20))::character varying, eelarve.rekvid,  (eelarve.summa*ifnull(dokvaluuta1.kuurs,1))::numeric as summa, 
				eelarve.kood2, eelarve.kood1, eelarve.kood4,tnRekvId, lcReturn
				FROM eelarve 
				left outer join dokvaluuta1 on (eelarve.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 8)
				inner join tmprekv on eelarve.rekvId = tmprekv.id
				LEFT JOIN library t ON t.id = eelarve.tunnusid
				WHERE Eelarve.aasta = year(tdKpv2)  
				and eelarve.kood2 not in ('LE-LA') 
				AND kood1 LIKE tcTegev +'%' 
				AND kood2 LIKE tcAllikas +'%'
				and eelarve.tunnus = 1 
				and eelarve.kpv <= tdKpv2 
				and (left(kood4,1) in ('4','5','6','2')  or left(kood4,2) = '15')  
				AND kood4 LIKE tcEelarve +'%'; 

			-- eelarve Tapsastatud, koos LE-LA:

			insert into tmp_eelproj_aruanne1 (tunnus, RekvIdSub, SUMMA5, allikas, tegev, eelarve, rekvid, timestamp)	
				SELECT ifnull(t.kood, space(20))::character varying, eelarve.rekvid,  (eelarve.summa*ifnull(dokvaluuta1.kuurs,1))::numeric as summa, 
				eelarve.kood2, eelarve.kood1, eelarve.kood4,tnRekvId, lcReturn
				FROM eelarve 
				left outer join dokvaluuta1 on (eelarve.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 8)
				inner join tmprekv on eelarve.rekvId = tmprekv.id
				LEFT JOIN library t ON t.id = eelarve.tunnusid
				WHERE Eelarve.aasta = year(tdKpv2)  
				and eelarve.kood2  in ('LE-LA') 
				AND kood1 LIKE tcTegev +'%'  
				AND kood2 LIKE tcAllikas +'%'
				and eelarve.tunnus = 1 
				and eelarve.kpv <= tdKpv2 
				and (left(kood4,1) in ('4','5','6','2')  or left(kood4,2) = '15')  
				AND kood4 LIKE tcEelarve +'%'; 
		end if;



		-- eelarve Taitmine:
		
		if tnLiik = 201 or tnLiik = 202 or tnLiik = 301 or tnLiik = 302  or tnLiik = 401 or tnLiik = 402 or tnLiik = 501 or
			tnLiik = 601 or tnLiik = 602 then
			-- kassa


			insert into tmp_eelproj_aruanne1 (tunnus, RekvIdSub, SUMMA3, allikas, tegev, eelarve, rekvid, timestamp)	
				SELECT  journal1.tunnus, journal.rekvid, (journal1.summa*ifnull(dokvaluuta1.kuurs,1))::numeric as summa, 
				journal1.kood2, journal1.kood1, journal1.kood5, tnRekvId, lcreturn   
				FROM journal inner join journal1 on journal.id = journal1.parentid
				left outer join dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 1)
				inner join tmprekv on journal.rekvId = tmprekv.id
				JOIN kassakulud ON ltrim(rtrim(journal1.deebet::text)) ~~ ltrim(rtrim(kassakulud.kood::text))
				JOIN kassakontod ON ltrim(rtrim(journal1.kreedit::text)) ~~ ltrim(rtrim(kassakontod.kood::text))
				WHERE journal.kpv >= tdKpv1 and journal.kpv <= tdKpv2  
				AND journal1.kood1 LIKE tcTegev +'%'  
				AND journal1.kood2 LIKE tcAllikas +'%'  
				AND journal1.kood5 LIKE tcEelarve +'%'; 
		end if;
	

		if tnLiik = 211 or tnLiik = 212 or tnLiik = 311 or tnLiik = 312 or tnLiik = 411 or tnLiik = 412 or tnLiik = 511 or tnLiik = 512  then
			-- fakt

			insert into tmp_eelproj_aruanne1 (tunnus, RekvIdSub, SUMMA3, allikas, tegev, eelarve, rekvid, timestamp)	
			SELECT  journal1.tunnus, journal.rekvid, (journal1.summa*inull(dokvaluuta1.kuurs,1))::numeric as summa, 
				journal1.kood2, journal1.kood1, journal1.kood5, tnRekvId, lcreturn  
				FROM journal inner join journal1 on journal.id = journal1.parentid
				left outer join dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 1)
				inner join tmprekv on journal.rekvId = tmprekv.id
				JOIN faktkulud ON ltrim(rtrim(journal1.deebet::text)) ~~ ltrim(rtrim(faktkulud.kood::text))
				WHERE journal.kpv >= tdKpv1 and journal.kpv <= tdKpv2    
				AND journal1.kood1 LIKE tcTegev +'%'  
				AND journal1.kood2 LIKE tcAllikas +'%'  
				AND journal1.kood5 LIKE tcEelarve +'%'; 

		end if;

		if tnLiik > 600 and tnLiik <= 612 then
			-- fakt

			insert into tmp_eelproj_aruanne1 (tunnus, RekvIdSub, SUMMA6, allikas, tegev, eelarve, rekvid, timestamp)	
			SELECT  journal1.tunnus, journal.rekvid, (journal1.summa*ifnull(dokvaluuta1.kuurs,1))::numeric as summa, 
				journal1.kood2, journal1.kood1, journal1.kood5, tnRekvId, lcreturn  
				FROM journal inner join journal1 on journal.id = journal1.parentid
				left outer join dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 1)
				inner join tmprekv on journal.rekvId = tmprekv.id
				JOIN faktkulud ON ltrim(rtrim(journal1.deebet::text)) ~~ ltrim(rtrim(faktkulud.kood::text))
				WHERE journal.kpv >= tdKpv1 and journal.kpv <= tdKpv2    
				AND journal1.kood1 LIKE tcTegev +'%'  
				AND journal1.kood2 LIKE tcAllikas +'%'  
				AND journal1.kood5 LIKE tcEelarve +'%'; 

		end if;
 

		-- kokkuvõtte
		if tnLiik >= 201 and tnLiik <= 212 then
			-- majandus
			insert into tmp_eelproj_aruanne1 (RekvIdSub, summa1, summa2, summa3, eelarve, rekvid, timestamp)	
				select RekvIdSub, sum(summa1)+sum(summa4) , sum(summa2)+sum(summa5), sum(summa3), eelarve, tnRekvId, lcReturn+'LOPP'
				from tmp_eelproj_aruanne1
				where rekvid = tnRekvId
				and tmp_eelproj_aruanne1.tunnus like tcTunnus+'%'
				and timestamp = lcReturn
				group by RekvIdSub, eelarve
				order by RekvIdSub, eelarve;

		end if;
		if tnLiik >= 301 and tnLiik <= 312 then
			-- tegev
			insert into tmp_eelproj_aruanne1 (RekvIdSub, summa1, summa2, summa3, tegev, rekvid, timestamp)	
				select RekvIdSub, sum(summa1)+sum(summa4) , sum(summa2)+sum(summa5), sum(summa3), tegev, tnRekvId, lcReturn+'LOPP'
				from tmp_eelproj_aruanne1
				where rekvid = tnRekvId
				and tmp_eelproj_aruanne1.tunnus like tcTunnus+'%'
				and timestamp = lcReturn
				group by RekvIdSub, tegev
				order by RekvIdSub, tegev;

		end if;
		if tnLiik >= 401 and tnLiik <= 412 then
			-- allikas, tegev, eelarve, LE-LA eraldi
			insert into tmp_eelproj_aruanne1 (RekvIdSub, summa1, summa2, summa3,summa4, summa5, allikas,  tegev, eelarve, rekvid, timestamp)	
				select RekvIdSub, sum(summa1), sum(summa2),  sum(summa3),sum(summa4), sum(summa5), allikas, tegev, eelarve, tnRekvId, lcReturn+'LOPP'
				from tmp_eelproj_aruanne1
				where rekvid = tnRekvId
				and tmp_eelproj_aruanne1.tunnus like tcTunnus+'%'
				and timestamp = lcReturn
				group by RekvIdSub, allikas, tegev, eelarve
				order by RekvIdSub, allikas, tegev, eelarve;

		end if;
		if tnLiik >= 501 and tnLiik <= 512 then
			-- tunnus, eelarve
			insert into tmp_eelproj_aruanne1 (RekvIdSub, summa1, summa2, summa3,tunnus, eelarve, rekvid, timestamp)	
				select RekvIdSub, sum(summa1)+sum(summa4) , sum(summa2)+sum(summa5), sum(summa3), tunnus, eelarve, tnRekvId, lcReturn+'LOPP'
				from tmp_eelproj_aruanne1
				where rekvid = tnRekvId
				and tmp_eelproj_aruanne1.tunnus like tcTunnus+'%'
				and timestamp = lcReturn
				group by RekvIdSub, tunnus, eelarve
				order by RekvIdSub, tunnus, eelarve;

		end if;
		if tnLiik >= 601 and tnLiik <= 612 then
			-- tegev, eelarve, kassa ja tegelik
			insert into tmp_eelproj_aruanne1 (RekvIdSub, summa1, summa2, summa3, summa6, tegev, eelarve, rekvid, timestamp)	
				select RekvIdSub, sum(summa1)+sum(summa4) , sum(summa2)+sum(summa5), sum(summa3), sum(summa6), tegev, eelarve, tnRekvId, lcReturn+'LOPP'
				from tmp_eelproj_aruanne1
				where rekvid = tnRekvId
				and tmp_eelproj_aruanne1.tunnus like tcTunnus+'%'
				and timestamp = lcReturn
				group by RekvIdSub, tegev, eelarve
				order by RekvIdSub, tegev, eelarve;

		end if;

		delete from tmp_eelproj_aruanne1 where timestamp = lcReturn and rekvid = tnRekvId;

		lcReturn = lcReturn + 'LOPP';


	end if;


	if tnLiik = 1 then
		-- 1.	KONTODE KÄIBED PARTNERI KOODIDE LÕIKES
		
		if tnRekvIdSub = 0 then
			lnRekvid1 = 0;
			lnrekvid2 = 999999;
		else
			lnRekvid1 = tnRekvIdSub;
			lnrekvid2 = tnRekvIdSub;
		end if;

		-- db

		insert into tmp_eelarve_aruanne1 (konto, RekvIdSub, AllAsutus, db, tp_db, tunnus, tegev,eelarve, projekt, rekvid, timestamp)
			select journal1.deebet, journal.rekvid, rekv.nimetus, sum(journal1.summa*ifnull(dokvaluuta1.kuurs,1)), 
				journal1.lisa_d, journal1.tunnus, journal1.kood1,journal1.kood5,
				journal1.proj, tnrekvid, lcreturn
			from journal inner join journal1 on journal.id = journal1.parentid
				inner join rekv on journal.rekvid = rekv.id
				inner join tmprekv on journal.rekvId = tmprekv.id
				left outer join dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 1)

			where journal.kpv >= tdKpv1 and journal.kpv <= tdKpv2
				and journal1.deebet like ltrim(rtrim(tcKonto))+'%'
				and journal1.lisa_d like ltrim(rtrim(tcTp))+'%'
				and journal.rekvId >= lnrekvid1 and journal.rekvid <= lnrekvid2
				and journal1.tunnus like ltrim(rtrim(tcTunnus))+'%'
				and journal1.kood1 like ltrim(rtrim(tcTegev))+'%'
				and journal1.kood2 like ltrim(rtrim(tcAllikas))+'%'
				and journal1.kood5 like ltrim(rtrim(tcEelarve))+'%'
				and journal1.proj like ltrim(rtrim(tcProjekt))+'%'
				and journal.rekvid in (select distinct id from tmprekv)

			group by journal1.deebet, journal.rekvid, rekv.nimetus, journal1.lisa_d, journal1.tunnus, journal1.kood1,journal1.kood5,journal1.proj ;


		-- kr

		insert into tmp_eelarve_aruanne1 (konto, RekvIdSub, AllAsutus, kr, tp_kr, tunnus, tegev,eelarve, projekt, rekvid, timestamp)
			select journal1.kreedit, journal.rekvid, rekv.nimetus, sum(journal1.summa*ifnull(dokvaluuta1.kuur,1)), journal1.lisa_k, journal1.tunnus, journal1.kood1,journal1.kood5,
				journal1.proj, tnrekvid, lcreturn 
			from journal inner join journal1 on journal.id = journal1.parentid
				inner join rekv on journal.rekvid = rekv.id
				inner join tmprekv on journal.rekvId = tmprekv.id
				left outer join dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 1)

			where journal.kpv >= tdKpv1 and journal.kpv <= tdKpv2
				and journal1.kreedit like ltrim(rtrim(tcKonto))+'%'
				and journal1.lisa_k like ltrim(rtrim(tcTp))+'%'
				and journal.rekvId >= lnrekvid1 and journal.rekvid <= lnrekvid2
				and journal1.tunnus like ltrim(rtrim(tcTunnus))+'%'
				and journal1.kood1 like ltrim(rtrim(tcTegev))+'%'
				and journal1.kood2 like ltrim(rtrim(tcAllikas))+'%'
				and journal1.kood5 like ltrim(rtrim(tcEelarve))+'%'
				and journal1.proj like ltrim(rtrim(tcProjekt))+'%'
				and journal.rekvid in (select distinct id from tmprekv)
			group by journal1.kreedit, journal.rekvid, rekv.nimetus, journal1.lisa_k, journal1.tunnus, journal1.kood1,journal1.kood5,journal1.proj ;



	end if;



	return LCRETURN;

end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_eelarve_aruanne1(integer, date, date, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_eelarve_aruanne1(integer, date, date, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, integer) TO public;
GRANT EXECUTE ON FUNCTION sp_eelarve_aruanne1(integer, date, date, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, integer) TO vlad;
GRANT EXECUTE ON FUNCTION sp_eelarve_aruanne1(integer, date, date, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_eelarve_aruanne1(integer, date, date, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, integer) TO dbpeakasutaja;

CREATE OR REPLACE FUNCTION sp_kaibeandmik_report(character varying, integer, date, date, character varying, integer, integer)
  RETURNS character varying AS
$BODY$
DECLARE tcKonto alias for $1;
	tnrekvid alias for $2;
	tdKpv1 alias for $3;
	tdKpv2 alias for $4;
	tcTunnus alias for $5;
	tnOpt alias for $6;
	tnSvod alias for $7;
	lcReturn varchar;
	lnDb numeric (14,2);
	lnKr numeric (14,2);
	lnAlg numeric (14,2);
	lnLopp numeric (14,2);
	v_kaibed record;
	v_saldo record;
	v_account record;
	v_tunnus record;
	lnCount int;


begin


	select count(*) into lnCount from pg_stat_all_tables where UPPER(relname) = 'TMP_KAIBEANDMIK_REPORT';
	if ifnull(lnCount,0) < 1 then

		create table tmp_kaibeandmik_report (asutusId int default 0, Asutus varchar(254) default space(1), regkood varchar(20) default space(1), 
			aadress text default space(1), konto varchar(20) default space(1), korkonto varchar(20) default space(1),
			tunnus varchar(20) default space(1), dokkpv date default date(),
			algdb numeric (14,2) default 0, algkr numeric (14,2) default 0, db numeric(14,2) default 0, kr numeric(14,2) default 0, 
			loppdb numeric(14,2) default 0, loppkr numeric(14,2) default 0,
			kood1 varchar(20) default space(1), kood2 varchar(20) default space(1), kood3 varchar(20) default space(1),
			kood4 varchar(20) default space(1), kood5 varchar(20) default space(1), dok varchar(120) default space(1),
			lausend int default 0, 
			timestamp varchar(20) , kpv date default date(), rekvid int )  ;


		GRANT ALL ON TABLE tmp_kaibeandmik_report TO GROUP public;
	else
		delete from tmp_kaibeandmik_report where kpv < date() ;

	end if;

	lcreturn := ltrim(rtrim(str(tnrekvId)))+to_char(now(), 'YYYYMMDDMISS');

-- lisatud 27/08/2008 kondaruanne koostamine

if (select count(*) from pg_stat_all_tables where UPPER(relname) = 'TMPREKV')  > 0 then
	delete from tmpRekv;
--	truncate TABLE tmpRekv;
	insert into tmpRekv
		SELECT id, parentid, fnc_get_asutuse_staatus(rekv.id, tnrekvid)::int as tase FROM rekv;
else
	CREATE TABLE tmpRekv AS
		SELECT id, parentid, fnc_get_asutuse_staatus(rekv.id, tnrekvid)::int as tase FROM rekv;
		GRANT ALL ON TABLE tmpRekv TO GROUP public;

END IF;
delete from tmpRekv where parentid = 9999;
if tnSvod = 1 then
	delete from tmpRekv where tase < 3;

else
	delete from tmpRekv where tase in (0,1,2,4);
end if;


	if tnOpt = 1 then
		-- kaibeandmik 
		raise notice 'kaibeandmik';

		-- algjaak db
		insert into tmp_kaibeandmik_report (konto, algdb, timestamp, rekvid )  
		select ltrim(rtrim(journal1.deebet)), sum(journal1.summa * ifnull(dokvaluuta1.kuurs,1)),lcReturn, tnRekvId 
		from journal1 inner join journal on journal.id = journal1.parentid	
		left outer join dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokliik = 1)
		inner join tmprekv on journal.rekvId = tmprekv.id
		where journal1.deebet like tcKonto and journal.kpv < tdKpv1
		and journal1.tunnus like tcTunnus
		group by ltrim(rtrim(journal1.deebet));


		-- algjaak kr
		insert into tmp_kaibeandmik_report (konto, algkr, timestamp, rekvid )  
		select ltrim(rtrim(journal1.kreedit)), sum(journal1.summa * ifnull(dokvaluuta1.kuurs,1)),
		lcReturn, tnRekvId 
		from journal1 inner join journal on journal.id = journal1.parentid	
		left outer join dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokliik = 1)
		inner join tmprekv on journal.rekvId = tmprekv.id
		where journal1.kreedit like tcKonto and journal.kpv < tdKpv1 
		and journal1.tunnus like tcTunnus
		group by ltrim(rtrim(journal1.kreedit));

		raise notice 'algjaak tehtud';
		

		-- kaibed db
		insert into tmp_kaibeandmik_report (konto, db, timestamp, rekvid )  
		select ltrim(rtrim(journal1.deebet)), sum(journal1.summa * ifnull(dokvaluuta1.kuurs,1)),
		lcReturn, tnRekvId 
		from journal1 inner join journal on journal.id = journal1.parentid	
		left outer join dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokliik = 1)
		inner join tmprekv on journal.rekvId = tmprekv.id
		where journal1.deebet like tcKonto and journal.kpv >= tdKpv1 and journal.kpv <= tdKpv2 
		and journal1.tunnus like tcTunnus
		group by ltrim(rtrim(journal1.deebet));

		-- kaibed kr
		insert into tmp_kaibeandmik_report (konto, kr, timestamp, rekvid )  
		select ltrim(rtrim(journal1.kreedit)), sum(journal1.summa*ifnull(dokvaluuta1.kuurs,1)),
		lcReturn, tnRekvId 
		from journal1 inner join journal on journal.id = journal1.parentid	
		left outer join dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokliik = 1)
		inner join tmprekv on journal.rekvId = tmprekv.id
		where journal1.kreedit like tcKonto and journal.kpv >= tdKpv1 and journal.kpv <= tdKpv2 
		and journal1.tunnus like tcTunnus
		group by ltrim(rtrim(journal1.kreedit));

		raise notice 'kaibed tehtud';

		-- lopp

		insert into tmp_kaibeandmik_report (konto, algdb, algkr, db, kr, timestamp, rekvid )  
		select ltrim(rtrim(konto)), sum(algdb) as algdb, sum(algkr) as algkr, sum(db) as db, sum(kr) as kr, 
		lcReturn+'L', tnRekvId 
		from tmp_kaibeandmik_report
		where timestamp = lcReturn and rekvid = tnrekvid 
		group by ltrim(rtrim(konto));

		raise notice 'lopp';


		delete from tmp_kaibeandmik_report where timestamp = lcreturn and rekvid = tnRekvId and algdb=0 and algkr = 0 and db = 0 and kr = 0;


	end if;
	lcreturn = lcReturn + 'L';

	return LCRETURN;

end;


$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_kaibeandmik_report(character varying, integer, date, date, character varying, integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_kaibeandmik_report(character varying, integer, date, date, character varying, integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_kaibeandmik_report(character varying, integer, date, date, character varying, integer, integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION sp_kaibeandmik_report(character varying, integer, date, date, character varying, integer, integer) TO dbvaatleja;


CREATE OR REPLACE FUNCTION sp_lausendikontrol(character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, date, character varying)
  RETURNS character varying AS
$BODY$

DECLARE tcDb alias for $1;
	tcKr alias for $2;
	tcTPD alias for $3;
	tcTPK alias for $4;
	tcTT alias for $5;
	tcAllikas alias for $6;
	tcEelarve alias for $7;
	tcRahavoog alias for $8;
	tcOmaTP alias for $9;
	tdKpv alias for $10;
	tcValuuta alias for $11;
	lnTPD int;
	lnTPK int;
	lnTT int;
	lnEelarve int;
	lnAllikas int;
	lnRahavoog int;
	lcMsg text;
	lcMsg1 text;
	lcKr varchar(20);
	lcDb varchar(20);
	lcOmaTp varchar(20);

	ldKpv date;
	v_konto record;
begin	

	raise notice 'tcTPK %',tcTPK;
	lnTPD = 0;
	lnTPK = 0;
	lnTT = 0;
	lnEelarve = 0;
	lnAllikas = 0;
	lnRahavoog = 0;
	lcMsg = '';
	lcMsg1 = '';

-- kontrollin valuuta kehtivus 
	if fnc_valkehtivus(tcValuuta, tdKpv) = 0 then
		lcMsg = ' Valuuta ei kehti';
	end if;

-- kontrollin oma TP
	if not empty (tcOmaTP) and (tcTPD = tcOmaTP or tcTPK = tcOmaTp)  then	
		lcMsg1 =  ' TP kood on vale, ei saa kasutada tehingus oma TP kood ';			
	end if;

	raise notice 'lcmsg1 %',lcMsg1;
	if (left(tcOmaTP,6) = '185101' or tcOmaTP = '185130') and (left(tcDb,1) = '7' or left(tckr,1) = '7')  then
		lcMsg1 = '';
	end if;

	if not empty(lcMsg1) then
		lcMsg = lcMsg + lcMsg1;			
	end if;

	raise notice 'lcmsg %',lcMsg;

	-- Tp kontoll

	if left(ltrim(rtrim(tcTPD)),4) = '1851' and len(ltrim(rtrim(tcTPD))) = 6 then
		lcMsg1 = 'TP-D Ei saa kasuta vana kohalik TP koodid';
	end if;
	if not empty(lcMsg1) then
		lcMsg = lcMsg + lcMsg1;			
	end if;

	if left(ltrim(rtrim(tcTPK)),4) = '1851' and len(ltrim(rtrim(tcTPK))) = 6 then
		lcMsg1 = 'TP-K Ei saa kasuta vana kohalik TP koodid';
	end if;
	if not empty(lcMsg1) then
		lcMsg = lcMsg + lcMsg1;			
	end if;

	select tun4,tun5 into lnTpD,lnTPK from library where kood = tcTPD and library = 'TP' order by tun4, tun5 desc limit 1;
	raise notice 'tp date %',lnTpD;
	if ifnull(lnTPD,0) > 0 then
		ldKpv = date(val(left(lnTPD::varchar(8),4)),val(substr(lnTPD::varchar(8),5,2)),val(substr(lnTPD::varchar(8),7,2)));
		if tdKpv < ldKpv then
			lcMsg1 = 'TP-D, Ei saa kasuta, sest TP kood ei ole kehtiv';
		end if; 
	end if; 
	if not empty(lcMsg1) then
		lcMsg = lcMsg + lcMsg1;			
	end if;
	
	if ifnull(lnTPK,0) > 0 then
		ldKpv = date(val(left(lnTPK::varchar(8),4)),val(substr(lnTPK::varchar(8),5,2)),val(substr(lnTPK::varchar(8),7,2)));
		if tdKpv > ldKpv then
			lcMsg1 = 'TP-D,Ei saa kasuta, sest TP kood ei ole kehtiv';
		end if; 
	end if; 
	if not empty(lcMsg1) then
		lcMsg = lcMsg + lcMsg1;			
	end if;

	select tun4,tun5 into lnTpD,lnTPK from library where kood = tcTPK and library = 'TP' order by tun4, tun5 limit 1;
	if ifnull(lnTPD,0) > 0 then
		ldKpv = date(val(left(lnTPD::varchar(8),4)),val(substr(lnTPD::varchar(8),5,2)),val(substr(lnTPD::varchar(8),7,2)));
		if tdKpv < ldKpv then
			lcMsg1 = 'TP-K, Ei saa kasuta, sest TP kood ei ole kehtiv';
		end if; 
	end if; 
	
	if ifnull(lnTPK,0) > 0 then
		ldKpv = date(val(left(lnTPK::varchar(8),4)),val(substr(lnTPK::varchar(8),5,2)),val(substr(lnTPK::varchar(8),7,2)));
		if tdKpv > ldKpv then
			lcMsg1 = 'TP-K,Ei saa kasuta, sest TP kood ei ole kehtiv';
		end if; 
	end if; 
	
	-- deebet

	select * into v_konto from library where kood = tcDb and library = 'KONTOD' order by id desc limit 1;
	if ifnull(v_konto.kood,'PUUDUB') = 'PUUDUB' or empty(tcDb) or len(tcDb) < 6 then
		lcMsg = lcMsg + 'Viga: Deebet konto: puudub või vale konto ';	
		return lcMsg;	 
	end if;
	lcDb = v_konto.kood;
	if v_konto.tun1 = 1 and empty(tcTPD) then
		lnTPD = 1;
	end if;
	if v_konto.tun2 = 1 and (empty(tcTT) or empty(tcEelarve)) then
		if not empty(tcTT) then		
			lnTT = 0;
		end if;
		lnEelarve = 1;
		if (left(tcDb,1) = '9' or LEFT(tcDb,2) = '61' )  then
			lnEelarve = 0;
		end if;
	end if;
	if v_konto.tun3 = 1 and (empty(tcAllikas) or isdigit(tcAllikas) = 0) then
		lnAllikas = 1;
/*

select to_NUMBER('LE-P', '999')
*/
	

	end if;
	if v_konto.tun4 = 1 and empty(tcRahavoog) then
		lnRahavoog = 1;
	end if;

-- kontrollin kontogrupp '7'
	if left(tcDb,1) = '7' then
		if (left(tcTPD,3) = '800' or left(tcTPD,3) = '900')   then
			lcMsg = lcMsg + ' Ei saa kasutada see TP kood ';
		end if;

		if not empty (tcOmaTP) and left(tcTPD,4) <> left(tcOmaTP,4) then 
			lcMsg = lcMsg + ' Ei saa kasutada see TP kood: saab siirdeid kajastada ainult nende TP koodidega, mille esimesed 4 numbrit on samad ';
		end if;

	end if;


	if not empty(v_konto.muud) and v_konto.muud = '*' then
		RAISE NOTICE 'Eri konto %',v_konto.muud;
		if tcRahavoog <> '01' then
			lnTPD = 0;
			lnTPK = 0;
			lnTT = 0;
			lnEelarve = 0;
			lnAllikas = 0;
		end if;
	end if;

-- maksud
/*
	if (left(tcDb,4) = '2030' or left(tcDb,4) = '1037') and tcTPD <> '014003'  then	
		lcMsg = lcMsg + ' Ei saa kasutada see TP kood: maksude kontodel TP kood alati 014003 ';
	end if;
--parandetud J.tsekanina
*/
	if (left(tcDb,5) = '20200') then
--		raise notice 'Kontrollin 20200';
		if tcTPD <> '800699' and left(tcTPD,4) <> '9006'  then	
--			raise notice 'kontoll %',tcTPD;
			
			lcMsg = lcMsg + ' Ei saa kasutada see TP kood: alati 800699 ';
		end if;
	end if;
	if left(tcDb,5) = '10393' and tcTPD <> '800699'  then	
		lcMsg = lcMsg + ' Ei saa kasutada see TP kood: alati 800699 ';
	end if;
/*
	if (left(tcDb,3) = '102'  ) and tcTPD <> '014003'  then	
		lcMsg = lcMsg + ' Ei saa kasutada see TP kood: maksude kontodel TP kood alati 014003 ';
	end if;
*/
	if (left(tcDb,5) = '60100' or left(tcDb,5) = '60101' or left(tcDb,5) = '60102' or tcDb = '601095' ) and tcTPD <> '014003'  then	
		lcMsg = lcMsg + ' Ei saa kasutada see TP kood: maksude kontodel TP kood alati 014003 ';
	end if;

-- Sots.toetused
/*
	if (left(tcDb,3) = '413' ) and tcTPD <> '800699'  then	
		lcMsg = lcMsg + ' Ei saa kasutada see TP kood: uldjuhul 800699 ';
	end if;
*/

-- pank
	if (left(tcDb,4) = '1001' or tcDb = '550012' or  tcDb = '655000') and left(tcTPD,4) <> '8004'  then	
		lcMsg = lcMsg + 'Deebet, ei saa kasutada see TP kood: alati 8004** ';
	end if;
	
--palk
	if left(tcDb,3) = '500' then
		if tcTPD <> '800699' and left(tcTPD,4) <> '9006'  then	
			lcMsg = lcMsg + ' Ei saa kasutada see TP kood: alati 800699 ';
		end if;
	end if;
--omakapital
	if left(tcDb,3) = '298' and (tcRahavoog <> '00' and tcRahavoog <> '05' and tcRahavoog <> '18' and tcRahavoog <> '38' and tcRahavoog <> '21' and tcRahavoog <> '41' and tcRahavoog <> '43') then	
		lcMsg = lcMsg + ' Ei saa kasutada see RV kood ';
	end if;

--eraldised
	if (left(tcDb,3) = '206' or left(tcDb,3) = '256') and (tcRahavoog <> '00' and tcRahavoog <> '06' and tcRahavoog <> '41' and tcRahavoog <> '42') then	
		lcMsg = lcMsg + ' Ei saa kasutada see RV kood ';
	end if;

--laenud
 	if v_konto.tun4 = 1 then

		if (left(tcDb,3) = '208' or left(tcDb,3) = '258') and (tcRahavoog <> '05' and tcRahavoog <> '06' and tcRahavoog <> '41' and tcRahavoog <> '42' and tcRahavoog <> '43') then	
			lcMsg = lcMsg + ' Ei saa kasutada see RV kood ';
		end if;

		if (left(tcDb,4) = '1032' or left(tcDb,4) = '1532') and not empty (tcRahavoog) and (tcRahavoog <> '01' and tcRahavoog <> '02' and tcRahavoog <> '23' and tcRahavoog <> '02' and tcRahavoog <> '21') then	
			lcMsg = lcMsg + ' Ei saa kasutada see RV kood ';
		end if;
	end if;


	-- Kreedit

	raise notice 'Kreedit, tctpk %',tcTPK;
	select * into v_konto from library where kood = tcKr and library = 'KONTOD' order by id desc limit 1;

	if ifnull(v_konto.kood,'PUUDUB') = 'PUUDUB' or empty(tcKr) or len(tcKr) < 6 then
		lcMsg = lcMsg + 'Viga: Kreedit konto: puudub või vale konto ';	
		return lcMsg;	 
	end if;
	lcKr = v_konto.kood;

	if v_konto.tun1 = 1 and empty(tcTPK) then
		raise notice 'v_konto.tun1 = 1 and empty(tcTPK) %',tcTPK ;
		lnTPK = 1;
--		lcMsgK  =' TP-K ';
	end if;
	if v_konto.tun2 = 1 and (empty(tcTT) or empty(tcEelarve)) and lnTT = 0 then
		if not empty(tcTT) then		
			lnTT = 0;
		end if;
		lnEelarve = 1;
		if (left(tcKr,1) = '9' or left(tcKr,3) = '155' or tcKr = '350000') then
			lnEelarve = 0;
		end if;
	end if;
	if v_konto.tun3 = 1 and empty(tcAllikas) and lnAllikas = 0 then
		lnAllikas = 1;
	end if;
	if v_konto.tun4 = 1 and empty(tcRahavoog) and lnRahavoog = 0 then
		lnRahavoog = 1;
	end if;

	if left(tcKr,1) = '7' then
		if (left(tcTPK,3) = '800' or left(tcTPK,3) = '900')   then
			lcMsg = lcMsg + ' Ei saa kasutada see TP kood ';
		end if;

		if not empty (tcOmaTP) and left(tcTPK,4) <> left(tcOmaTP,4) then 
			lcMsg = lcMsg + ' Ei saa kasutada see TP kood: saab siirdeid kajastada ainult nende TP koodidega, mille esimesed 4 numbrit on samad ';
		end if;

	end if;
	


	if not empty(v_konto.muud) and v_konto.muud = '*' then
		RAISE NOTICE 'Eri konto %',v_konto.muud;
		if tcRahavoog <> '01' then
			lnTPD = 0;
			lnTPK = 0;
			lnTT = 0;
			lnEelarve = 0;
			lnAllikas = 0;
		end if;
	end if;

--maksud
/*
	if (left(tcKr,4) = '2030' or left(tcKr,4) = '1037') and tcTPK <> '014003'  then	
		lcMsg = lcMsg + ' Ei saa kasutada see TP kood: maksude kontodel TP kood alati 014003 ';
	end if;
*/
	if (left(tcKR,5) = '20200') then 
		if tcTPK <> '800699' and left(tcTPK,4) <> '9006' then	
			lcMsg = lcMsg + ' Ei saa kasutada see TP kood: TP kood alati 800699 ';
		end if;
	end if;
	if (left(tcKR,5) = '10393') and tcTPK <> '800699'  then	
		lcMsg = lcMsg + ' Ei saa kasutada see TP kood: TP kood alati 800699 ';
	end if;
/*
	if (left(tcKr,3) = '102') and tcTPK <> '014003'  then	
		lcMsg = lcMsg + ' Ei saa kasutada see TP kood: maksude kontodel TP kood alati 014003  ';
	end if;
*/
	if (left(tcKr,5) = '60100' or left(tcKr,5) = '60101' or left(tcKr,5) = '60102' or tcKr = '601095' ) and tcTPK <> '014003'  then	
		lcMsg = lcMsg + ' Ei saa kasutada see TP kood: maksude kontodel TP kood alati 014003 ';
	end if;

-- Sots.toetused
/*
	if (left(tcKr,3) = '413' ) and tcTPK <> '800699'  then	
		lcMsg = lcMsg + ' Ei saa kasutada see TP kood: uldjuhul kasutatakse 800699 ';
	end if;
*/
-- pank
	if (left(tcKr,4) = '1001' or tcKr = '550012' or tcKr = '655000') and left(tcTPK,4) <> '8004'  then	
		lcMsg = lcMsg + 'Kreedit, ei saa kasutada see TP kood: alati 8004** ';
	end if;
--palk
	if left(tcKr,3) = '500' then 
		if tcTPK <> '800699' and left(tcTPK,4) <> '9006'  then	
			lcMsg = lcMsg + ' Ei saa kasutada see TP kood: alati 800699 ';
		end if;
	end if;

--omakapital
  	if v_konto.tun4 = 1 then

		if left(tcKr,3) = '298' and (tcRahavoog <> '00' and tcRahavoog <> '05' and tcRahavoog <> '18' and tcRahavoog <> '38' and tcRahavoog <> '21' and tcRahavoog <> '41' and tcRahavoog <> '43') then	
			lcMsg = lcMsg + ' Ei saa kasutada see RV kood ';
		end if;
	end if;
--eraldised
 	if v_konto.tun4 = 1 then

		if (left(tcKr,3) = '206' or left(tcKr,3) = '256') and (tcRahavoog <> '00' and tcRahavoog <> '06' and tcRahavoog <> '41' and tcRahavoog <> '42') then	
			lcMsg = lcMsg + ' Ei saa kasutada see RV kood ';
		end if;
	end if;
--laenud
 	if v_konto.tun4 = 1 then

		if (left(tcKr,3) = '208' or left(tcKr,3) = '258') and (tcRahavoog <> '05' and tcRahavoog <> '06' and tcRahavoog <> '41' and tcRahavoog <> '42' and tcRahavoog <> '43') then	
			lcMsg = lcMsg + ' Ei saa kasutada see RV kood ';
		end if;

		if (left(tcKr,4) = '1032' or left(tcKr,4) = '1532') and (tcRahavoog <> '01' and tcRahavoog <> '02' and tcRahavoog <> '23' and tcRahavoog <> '02' and tcRahavoog <> '21') then	
			lcMsg = lcMsg + ' Ei saa kasutada see RV kood ';
		end if;
	end if;


-- kontrollin RV 01 + TP
	if tcKr = '253800' then
		if tcRahavoog = '01' and empty(tcTPK) then
			lnTPK = 1;
		else
			lnTPK = 0;
		end if;
	end if;

	raise notice 'lcmsg %',lcMsg;
	
	if lnTPD = 1 then
		lcMsg = lcMsg + 'TP-D ';
	end if;
	if lnTPK = 1 then
		lcMsg = lcMsg + ' TP-K';
	end if;
	if lnTt = 1 then
		lcMsg = lcMsg + ' Tegevusalla ';
	end if;
	if lnEelarve = 1 then
		lcMsg = lcmsg + ' Eelarve ';
	end if;
	if lnAllikas = 1 then
		lcmsg = lcmsg + ' Allikas ';
	end if;
	if lnRahavoog = 1 then
		lcmsg = lcmsg + 'Rahavoog ';
	end if;

-- kontrollin grupp 506
	if left(tcDb,3) = '506' then 
		if tcTPD <> '800699' and left(tcTPD,4) <> '9006' then
			lcMsg = lcMsg + ' TP-D kood on vale, peaks olla 800699 ';
		end if;
	end if;

-- kontrollin kontogrupp '9'
	if (left(tcDb,1) = '9' or left(tcKr,1) = '9') and (tcDb <> '999999' and tcKr <> '999999') and left(tcRahavoog,1) <> '9' and lnRahavoog = 1 then
		lcMsg = lcMsg + ' RV kood on vale, peaks olla 90-99 ';
	end if;



	if (tcRahavoog = '11' or tcRahavoog = '12') and left(tcDb,3) <> left(tcKr,3)  then
		if left(tcDb,2) <> '61' then
			lcMsg = lcMsg + ' DB konto on vale, see peab olema vordne kontodega 61xxx  ';			
		end if;
	end if;
	raise notice 'lcmsg %',lcMsg;

	if not empty (ltrim(rtrim(lcmsg))) then
		lcMsg = 'Viga Db:'+ LTRIM(RTRIM(lcdb))+' '+'Kr:'+ LTRIM(RTRIM(lcKr))+ ' puudub eelarve koodid: '+lcMsg; 
	END IF;
	raise notice 'lcmsg %',lcMsg;

	return lcMsg;
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_lausendikontrol(character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, date, character varying) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_lausendikontrol(character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, date, character varying) TO public;
GRANT EXECUTE ON FUNCTION sp_lausendikontrol(character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, date, character varying) TO vlad;
GRANT EXECUTE ON FUNCTION sp_lausendikontrol(character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, date, character varying) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_lausendikontrol(character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, date, character varying) TO dbpeakasutaja;





CREATE OR REPLACE FUNCTION sp_saldoandmik_aruanned(integer, date, integer, integer, integer,integer)
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
	if tnrekvId = 63 then 
		lnRekvId = 0;
	end if;

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

	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1','Aruandeperioodi tegevustulem',ifnull(sum(kr),0) - ifnull(sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and val(left(ltrim(rtrim(saldoandmik.konto)),1)) >= 3 and val(left(ltrim(rtrim(saldoandmik.konto)),2)) <= 64;

--Jooksva per Saldoandmikust (Sum: Kontod 61* deebet) - (Sum: Kontod 61* Kreedit)

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '2','  Põhivara amortisatsioon ja ümberhindlus',ifnull(sum(db),0) - ifnull(sum(kr),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and val(left(ltrim(rtrim(saldoandmik.konto)),2)) = 61;

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '2','  Saadud sihtfinantseerimine põhivara soetuseks',ifnull(sum(db),0) - ifnull(sum(kr),0),tdKpv, tnRekvId,lcReturn, 0 
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
			('40','Põhitegevusega seotud käibevarade netomuutus',0,tdKpv, tnRekvId,lcReturn, 0 );


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
			('4','  Maksu-, lõivu- ja trahvinõuete muutus',lnKreedit - lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
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
			('4','  Muutus nõuetes ostjate vastu',lnKreedit - lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
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

			
			
			select (ifnull(lnDb31,0) - sum(db)) - (ifnull(lnKr31,0) -sum(kr)) into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),6)) in ('103500','103540','103556','103557');		

			select sum(db), sum(kr)into lnDb7,lnKr7  
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4)) = '1035';		

			select (ifnull(lnDb7,0) - sum(db)) - (ifnull(lnKr7,0) -sum(kr)) into lnKreedit  
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),6)) in ('103500','103540','103556','103557');		

			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('4','  Muutus nõuetes toetuste ja siirete eest',lnKreedit - lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
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
			('4','  Muutus muudes nõuetes',lnKreedit - lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 

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
			('4','  Muutus maksude, lõivude, trahvide ettemaksetes',lnKreedit - lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
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
			('50','Põhitegevusega seotud kohustuste netomuutus',0,tdKpv, tnRekvId,lcReturn, 0 );
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
			('5','  Muutus saadud maksude, lõivude, trahvide ettemaksetes',lnDeebet-lnKreedit,tdKpv, tnRekvId,lcReturn, 0); 
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
			('5','  Muutus võlgades hankjatele',lnDeebet-lnKreedit,tdKpv, tnRekvId,lcReturn, 0); 
--(Jooksva per saldoandmikust (sum: konto 202* kreedit) - (sum konto 202* deebet)) - (Eelmise per saldoandmikust (sum kontod 202* kreedit) - (sum kontod 202* deebet))

			select ifnull(sum(kr) - sum(db),0) into lnDeebet 
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),3)) = '202';		
			
			select ifnull(sum(kr) - sum(db),0) into lnKreedit
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),3)) = '202';		
			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('5','  Muutus võlgades töövõtjatele',lnDeebet-lnKreedit,tdKpv, tnRekvId,lcReturn, 0); 

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
			('5','  Muutus maksu-, lõivu- ja trahvikohustustes',lnDeebet-lnKreedit,tdKpv, tnRekvId,lcReturn, 0); 
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
			('5','  Muutus viitvõlgades',lnDeebet-lnKreedit,tdKpv, tnRekvId,lcReturn, 0); 
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
		


--= korrigeeritud tegevustulem (3) + käibevarade muutus (4) + kohustuste muutus (5)

	select sum(summa01) into lnDeebet from tmp_sk_aruanned where ltrim(rtrim(timestamp)) = lcReturn and ltrim(rtrim(konto)) = '3';
	lnKreedit = ifnull(lnDeebet,0);
	select sum(summa01) into lnDeebet from tmp_sk_aruanned where ltrim(rtrim(timestamp)) = lcReturn and ltrim(rtrim(konto)) = '4';
	lnKreedit = lnKreedit + ifnull(lnDeebet,0);
	select sum(summa01) into lnDeebet from tmp_sk_aruanned where ltrim(rtrim(timestamp)) = lcReturn and ltrim(rtrim(konto)) = '5';
	lnKreedit = lnKreedit + ifnull(lnDeebet,0);

	raise notice 'lnKreedit %',lnKreedit;
	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('60','Rahavood põhitegevusest kokku',lnKreedit,tdKpv, tnRekvId,lcReturn, 0); 

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('7','Rahavood investeerimistegevusest',0,tdKpv, tnRekvId,lcReturn, 0); 

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('710',' Tasutud põhivara eest (v.a. finantsinvesteeringud ja osalused)',0,tdKpv, tnRekvId,lcReturn, 0); 

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

			select sum(kr) - sum(db) into lnKreedit  
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (
			(ltrim(rtrim(rahavoo)) = '01' and (left(ltrim(rtrim(saldoandmik.konto)),3) in ('155','257') or left(ltrim(rtrim(konto)),6) in ('350200','350220','350240'))) 
			or (ltrim(rtrim(rahavoo)) in ('01','05') and left(ltrim(rtrim(konto)),4) in ('2082','2582'))
			);		

			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('71','  Materiaalse põhivara soetus',lnDeebet-lnKreedit,tdKpv, tnRekvId,lcReturn, 0); 
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

			select sum(kr) - sum(db) into lnKreedit  
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and ltrim(rtrim(rahavoo)) = '01' and left(ltrim(rtrim(saldoandmik.konto)),3) in ('156'); 

			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('71','  Immateriaalse põhivara soetus',lnDeebet-lnKreedit,tdKpv, tnRekvId,lcReturn, 0); 
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
			('71','  Korrigeerimine muutusega võlgades hankijatele',lnDeebet-lnKreedit,tdKpv, tnRekvId,lcReturn, 0); 


	select sum(summa01) into lnDeebet from tmp_sk_aruanned  where ltrim(rtrim(timestamp)) = lcReturn and ltrim(rtrim(konto)) = '71';

	update tmp_sk_aruanned set summa01 = ifnull(lnDeebet,0) where ltrim(rtrim(timestamp)) = lcReturn and ltrim(rtrim(konto)) = '710';


	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('720',' Laekunud põhivara müügist (v.a. finantsinvesteeringud ja osalused)',0,tdKpv, tnRekvId,lcReturn, 0); 
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
			('72','  Müügist saadud tulu',lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
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
			('72','  Korrigeerimine laekumata nõuete muutusega',lnKreedit-lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
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
			('72','  Korrigeerimine järelmaksunõuete muutusega',lnKreedit-lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
--Jooksva per Saldoandmikust (Sum: Konto 605020 kreedit) - (Sum: Konto 605020 deebet)

			select sum(kr)  - sum(db)   into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = ('605020');

			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('72','  Korrigeerimine ebatõenäoliselt laekuvaks arvatud järelmaksunõuetega',lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
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
			('72','  Korrigeerimine kustutatud EVP-de jäägi muutusega',lnKreedit-lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 

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
			('7',' Laekunud finantsinvesteeringute müügist',lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
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
			('7',' Laekunud osaluste müügist',lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
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
			('8',' Laekunud võlakirjade emiteerimisest',lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
--Jooksva per saldoandmikust (Sum konto 2080* kreedit (RV 06) - konto 2080* deebet (RV 06) + sum konto 2580* kreedit (RV 06) - konto 2580* deebet (RV 06) 

			select sum(kr) - sum(db) into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) in ('2080','2580') and ltrim(rtrim(rahavoo)) = '06';

			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('8',' Lunastatud võlakirjad',lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
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
			('8',' Laekunud sihtfinanteerimine põhivara soetuseks',lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
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
			('8',' Tasutud väljamaksed omakapitalist',ifnull(lnDeebet,0),tdKpv, tnRekvId,lcReturn, 0); 
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

--= rahavood põhitegevusest + rahavood inv tegevusest + rahavood fin tegevusest

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
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (
			left(ltrim(rtrim(saldoandmik.konto)),3) = ('100') or left(ltrim(rtrim(saldoandmik.konto)),6) = ('101100')
			);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('91','Raha ja selle ekvivalendid perioodi alguses',ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0); 
--Jooksva per saldoandmikust (sum konto 100* deebet - konto 100* kreedit) + (sum konto 101100 deebet - konto 101100 kreedit)

			select sum(db)-sum(kr)  into lnDeebet 
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (
			left(ltrim(rtrim(saldoandmik.konto)),3) = ('100') or left(ltrim(rtrim(saldoandmik.konto)),6) = ('101100')
			);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('92','Raha ja selle ekvivalendid perioodi lõpus',ifnull(lnDeebet,0),tdKpv, tnRekvId,lcReturn, 0); 
--= jooksva per summa (eelmine rida) - eelmise per summa (üleeelmine rida)
			
	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('93','Raha ja selle ekvivalentide muutus',ifnull(lnDeebet,0)-ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0); 

	delete from tmp_sk_aruanned where ltrm(rtrim(timestamp)) = lcReturn and summa01 = 0;

--rahavoog lõpp

end if;

if tnLiik = 4 then
-- Kond pikk tulem

	raise notice 'Pikk tulem';
	raise notice 'Arvestan..';

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
			select '3000', 'Füüsilise isiku tulumaks',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
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
			select '3025', 'Töötuskindlustusmaksed',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and left(ltrim(rtrim(konto)),4) = '3025';
	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3025', 'Töötuskindlustusmaksed',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
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
			select '30422', 'Kütuseaktsiis',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '30422';
	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3043', 'Hasartmängumaks',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3043';
	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '305', 'Maksud väliskaubanduselt ja tehingutelt',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '305';
	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '32', 'Kaupade ja teenuste müük',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),2) = '32';
	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '320', 'Riigilõivud ',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
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
			select '323', 'Tulud majandustegevusest (järg)',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
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
			select '3233', 'Üür ja rent',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3233';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3237', 'Õiguste müük',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3237';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3238', 'Muu toodete ja teenuste müük',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
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
			select '3502', 'Saadud sihtfinantseerimine põhivara soetuseks',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3502';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '351', 'Põhivara soetamiseks saadud sihtfinantseerimise amortisatsioon',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
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
			select '381', 'Kasum/kahjum põhivara ja varude müügist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '381';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3810', 'Kasum/kahjum kinnisvarainvesteeringute müügist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3810';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3811', 'Kasum/kahjum materiaalse põhivara müügist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3811';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '38110', 'Kasum/kahjum maa müügist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '38110';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '38111', 'Kasum/kahjum hoonete müügist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '38111';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '38112', 'Kasum/kahjum rajatiste müügist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '38112';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '38113', 'Kasum/kahjum kaitseotstarbelise põhivara müügist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '38113';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '38114', 'Kasum/kahjum masinate ja seadmete müügist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '38114';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '38115', 'Kasum/kahjum info- ja kommunikatsioonitehnoloogia seadmete müügist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '38115';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '38116', 'Kasum/kahjum muu amortiseeruva materiaalse põhivara müügist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '38116';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '38117', 'Kasum/kahjum mitteamortiseeruvate põhivarade müügist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '38117';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '38118', 'Kasum/kahjum lõpetamata ehituse müügist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '38118';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3813', 'Kasum/kahjum immateriaalse põhivara müügist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3813';


		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '38130', 'Kasum/kahjum tarkvara müügist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '38130';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '38132', 'Kasum/kahjum õiguste ja litsentside müügist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '38132';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '38136', 'Kasum/kahjum muu immateriaalse põhivara müügist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '38136';


		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3814', 'Kasum/kahjum bioloogiliste varade müügist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3814';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3818', 'Kasum/kahjum varude müügist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
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
			select '3823', 'Võlalt arvestatud intressitulu',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
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
			select '3882', 'Saastetasud ja keskkonnale tekitatud kahju hüvitis',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
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
			select '4108', 'Töötuskindlustustoetused ',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '4108';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '413', 'Sotsiaalabitoetused ja muud toetused füüsilistele isikutele',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
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
			select '4132', 'Toetused töötutele',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
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
			select '4134', 'Õppetoetused',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
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
			select '414', 'Sotsiaaltoetused avaliku sektori töövõtjatele ',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
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
			select '4502', 'Antud sihtfinantseerimine põhivara soetuseks',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
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
			select '50', 'Tööjõukulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),2) = '50';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '500', 'Töötasu',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
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
			select '5001', 'Avaliku teenistuse ametnikud (va kaitseväelased, piirivalve-, politseiametnikud)',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '5001';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '50010', 'Kõrgemad ametnikud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
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
			select '5002', 'Töötajate töötasu',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '5002';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '50020', 'Nõukogude ja juhatuste liikmed',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
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
			select '50026', 'Õpetajad',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '50026';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '50028', 'Töölised ja abiteenistujad',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '50028';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '5008', 'Muud koosseisuvälised töötasud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
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
			select '507', 'Tööjõukulude kapitaliseerimine',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
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
			select '5503', 'Lähetuskulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '5503';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '55030', 'Lühiajalised lähetused',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '55030';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '55031', 'Pikaajalised lähetused',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
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
			select '55113', 'Üürile ja rendile antud kinnistute, hoonete, ruumide majandamiskulud (va kinnisvarainvesteeringud)',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
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
			select '5513', 'Sõidukite majandamiskulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '5513';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '55130', 'Maismaasõidukid',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '55130';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '55131', 'Õhusõidukid',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '55131';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '55132', 'Veesõidukid',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
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
			select '5516', 'Töömasinate ja seadmete majandamiskulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
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
			select '5522', 'Meditsiinikulud ja hügieenikulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
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
			select '5524', 'Õppevahendite ja koolituse kulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
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
			select '601', 'Maksu-, lõivu- ja trahvikulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '601';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '6010', 'Maksud, lõivud, trahvid ',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '6010';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '6012', 'Ebatõenäoliselt laekuvad maksu-, lõivu- ja trahvinõuded',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '6012';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '6015', 'Edasiantud maksud, lõivud, trahvid',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '6015';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '605', 'Ebatõenäoliselt laekuvad nõuded',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
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
			select '61', 'Põhivara amortisatsioon ja ümberhindlus',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),2) = '61';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '611', 'Materiaalse põhivara amortisatsioon',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
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
			select '613', 'Immateriaalse põhivara amortisatsioon',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '613';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '614', 'Kasum/kahjum bioloogiliste varade ümberhindamisest',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
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
			select '655', 'Tulu hoiustelt ja väärtpaberitelt',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
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
			select '6552', 'Kasum/kahjum finantsinvesteeringute müügist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '6552';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '6554', 'Kasum/kahjum finantsinvesteeringute ümberhindamisest',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
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
			select '9', 'Täiendav informatsioon aruande koostamiseks',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),1) = '9';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '900', 'Töötajate arv',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
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

--koostame järjekord
		update 	tmp_sk_aruanned set tegev = konto where timestamp = lcReturn and not empty(konto) and empty (tegev);	


--	tulemiaruanne lõpp

end if;



if tnLiik = 3 then
-- Kond pikk bilanss

	raise notice 'Pikk bilanss';
	raise notice 'Arvestan..';

	insert into  tmp_sk_aruanned (konto, summa03, summa04, kpv, rekvid, timestamp, tyyp) 
			select saldoandmik.konto, sum(db), sum(kr),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto and library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and val(left(ltrim(rtrim(konto)),1)) < 3
			group by saldoandmik.konto
			order by saldoandmik.konto;

	select summa03 into lnDeebet from tmp_sk_aruanned where timestamp = lcReturn ;

	raise notice 'lnDeebet %',lnDeebet;

	raise notice 'Lisan nimetused..';


	
	for v_saldo in 
		select id, konto from tmp_sk_aruanned where ltrim(rtrim(timestamp)) = lcreturn
	loop
		select nimetus,tun5 into lcString,lnDb31 from library where kood = v_saldo.konto and library = 'KONTOD';
		if lnDb31 = 1 or lnDb31 = 3 then			
			UPDATE tmp_sk_aruanned set nimetus = ifnull(lcString,space(1)),
				summa01 = summa03 - summa04	
			where id = v_saldo.id;
		else
			UPDATE tmp_sk_aruanned set nimetus = ifnull(lcString,space(1)),
				summa01 = summa04 - summa03	
			where id = v_saldo.id;
		end if;
	end loop;

	raise notice 'arvestan kondid';

	select sum(db),sum(kr) into lnDeebet, lnKreedit from saldoandmik 
	where aasta = year(tdKpv) and kuu = month(tdKpv) 
	and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  saldoandmik.rekvid = tnRekvId)
	and konto = '103500';

	raise notice 'D 103500 %',lnDeebet;
	raise notice 'K 103500 %',lnKreedit;

	update tmp_sk_aruanned set summa01 = lnKreedit - lnDeebet where timestamp = lcReturn and ltrim(rtrim(konto)) = '103500';
	
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '10', 'Käibevara' ,sum(db) - sum(kr) - ifnull(lnDeebet,0) + ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,2) = '10'; 

	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '103', 'Muud nouded ja ettemaksed' ,ifnull(sum(db) - sum(kr),0)-ifnull(lnDeebet,0)+ifnull(lnKreedit,0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '103';
			

	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '100', 'Raha ja pangakontod' ,sum(db) - sum(kr), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '100'; 
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '101', 'Finantsinvesteeringud' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '101';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1011', 'Kauplemisportfelli väärtpaberid' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1011';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1012', 'Tähtajani hoitavad väärtpaberid' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1012';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1019', 'Muud finantsinvesteeringud' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1019';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '102', 'Maksu-, lõivu- ja trahvinõuded' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '102';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1020', 'Maksu-, lõivu ja trahvinõuded (bruto)' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1020';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1021', 'Ebatõenäoliselt laekuvad maksu-, lõivu ja trahvinõuded' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
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
			select '1032', 'Laenu- ja liisingnõuded' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1032';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1035', 'Nõuded toetuste ja siirete eest' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1035';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1036', 'Muud nõuded' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1036';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1037', 'Maksude, lõivude, trahvide ettemaksed ' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
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
			select '1089', 'Üle andmata varud ja ettemaksed varude eest' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1089';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '109', 'Müügiootel põhivara' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '109';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '15', 'Põhivara' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,2) = '15';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '150', 'Osalused avaliku sektori ja sidusüksustes' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '150';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1502', 'Osalused tütar- ja sidusettevõtjates' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1502';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '151', 'Finantsinvesteeringud' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '151';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1511', 'Investeerimisportfelli väärtpaberid' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1511';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1512', 'Tähtajani hoitavad võlakirjad ' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1512';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1519', 'Muud finantsinvesteeringud' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1519';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '152', 'Maksu-, lõivu- ja trahvinõuded' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '152';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1520', 'Maksu-, lõivu ja trahvinõuded (bruto)' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1520';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1521', 'Ebatõenäoliselt laekuvad maksu-, lõivu ja trahvinõuded ' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1521';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '153', 'Muud nõuded ja ettemaksed' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '153';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1530', 'Nõuded ostjate vastu' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1530';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1532', 'Laenu- ja liisingnõuded' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1532';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1535', 'Nõuded toetuste eest' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1535';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1536', 'Muud pikaajalised nõuded' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
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
			select '155', 'Materiaalne põhivara ' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
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
			select '1553', 'Kaitseotstarbeline põhivara ' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
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
			select '1556', 'Muu amortiseeruv materiaalne põhivara' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1556';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1559', 'Kasutusele võtmata varad ja ettemaksed' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1559';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '156', 'Immateriaalne põhivara' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '156';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1560', 'Tarkvara' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1560';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1562', 'Õigused ja litsentsid' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1562';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1564', 'Arenguväljaminekud ' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1564';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1565', 'Firmaväärtus ' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1565';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1566', 'Muu immateriaalne põhivara  ' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1566';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1569', 'Kasutusele võtmata varad ja ettemaksed ' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1569';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '157', 'Bioloogilised varad' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '157';


--Saldoandmikust (Sum: Kontod 2* Kreedit) - (Sum: Kontod 7* Deebet) + konto 103500 kreedit - konto 130500 deebet

			select sum(db) into lnDb7  from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(konto)),1) = '7';

raise notice 'db 7 %',lnDb7;

			select sum(kr) into lnKr2  from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(konto)),1) = '2';

raise notice 'kr 2 %',lnKr2;
raise notice 'deebet 103500 %',lnDeebet;
raise notice 'kr 103500 %',lnKreedit;

/*
			select sum(db) into lnDb31  from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(konto)),6) = '103500';
*/

	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) values
			('2', 'Kohustused ja netovara' ,ifnull(lnKr2,0) -ifnull(lnDb7,0) + ifnull(lnKreedit,0) - ifnull(lnDeebet,0), tdKpv, tnRekvId,lcReturn, 0);

	select sum(db),sum(kr) into lnDb2035,lnKr2035 from saldoandmik 
	where aasta = year(tdKpv) and kuu = month(tdKpv) 
	and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  saldoandmik.rekvid = tnRekvId)
	and konto = '203500';

	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '20', 'Luhiajalised kohustused' ,ifnull(sum(kr) - sum(db),0)-lnKr2035 + lnDb2035, tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,2) = '20';

	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '200', 'Saadud maksude, lõivude ja trahvide ettemaksed' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '200';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '201', 'Võlad tarnijatele' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '201';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '202', 'Võlad töötajatele' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '202';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '203', 'Muud kohustused ja saadud ettemaksed' ,ifnull(sum(kr) - sum(db),0) - LnKr2035+lnDb2035, tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '203';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '2030', 'Maksu-, lõivu- ja trahvikohustused' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '2030';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '2032', 'Viitvõlad' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
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
			select '2080', 'Emiteeritud võlakirjad' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
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
			select '250', 'Võlad tarnijatele' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '250';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '253', 'Muud kohustusd ja saadud ettemaksed' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '253';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '2530', 'Maksu-, lõivu- ja trahvikohustused' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
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
			select '2580', 'Emiteeritud võlakirjad' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '2580';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '2581', 'Laenud' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '2581';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp, tegev) values
			( '*', 'Eelarvesse kuuluv netovara' ,lnKreedit - lnDeebet+lnKr2035-lnDb2035, tdKpv, tnRekvId,lcReturn, 0, '2582');

			select sum(kr) into lnKr3 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and val(left(konto,2)) >= 29 and val(left(konto,1)) <= 7;

			select sum(db) into lnDb3 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,2) = '29' ;

			select sum(db) into lnDb31 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and val(left(konto,2)) > 29 and val(left(konto,1)) <= 7;

	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) values
			( '29', 'Netovara' ,lnKr3 - lnDb3 - lnDb31, tdKpv, tnRekvId,lcReturn, 0 ) ;
				
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '290', 'Reservid' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '290';

	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '291', 'Aktsia- või osakapital ja ülekurss' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '291';

	select sum(db),sum(kr) into lnDeebet,lnKreedit from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,1) in ('3','4','5','6','7') ;

	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) values
			( '299000', 'Aruandeperioodi tulem' ,lnKreedit - lnDeebet, tdKpv, tnRekvId,lcReturn, 0 ) ;

--Saldoandmikust (Sum: Kontod 1* Deebet) - (Sum: Kontod 1* Kreedit) - konto 103500 deebet + konto 103500 kreedit

	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1', 'Varad' ,sum(db) - sum(kr) ,tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,1) = '1' and ltrim(rtrim(konto)) <> '103500'; 



	delete from tmp_sk_aruanned where  timestamp = lcReturn and summa01 = 0;


--koostame järjekord
	update 	tmp_sk_aruanned set tegev = konto where timestamp = lcReturn and not empty(konto);	
	update 	tmp_sk_aruanned set tegev = '298001' where timestamp = lcReturn and konto = '*';	
	update 	tmp_sk_aruanned set tegev = '298002' where timestamp = lcReturn and konto = '103500';	
	update 	tmp_sk_aruanned set tegev = '298003' where timestamp = lcReturn and konto = '203500';	

--Saldoandmikust (Sum: Kontod 3*kuni 7* Kreedit) - (Sum: Kontod 3* kuni 7* Deebet)
-- bilanss kõik

end if;

if tnLiik = 2 then
-- Kond saldoaruanne
	delete from tmp_saldoandmik where rekvid = tnrekvId;

	if tnSvod = 1 and tnRekvId = 63 and (select count(*) from saldoandmik where rekvid = 0 and aasta = year(tdKpv) and kuu = month(tdKpv)) > 0 then
		-- tellitud kond aruanne, teeme select ja tagastame 
			
		INSERT INTO tmp_saldoandmik (nimetus, db , kr, konto , tegev , tp , allikas, rahavoo, timestamp, kpv, rekvid) 
		SELECT nimetus, db , kr, konto , tegev , tp , allikas, rahavoo, lcReturn, date(), tnrekvId
		from  saldoandmik
		where aasta = year(tdKpv) and kuu = month(tdKpv)
		and rekvid = 0;

	else

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



				-- (võrreldava saldoandmik (kõik kontod algusega 4 kuni 6, mille esitaja kood on TP kood on aruande koostaja kood (deebet miinus kreedit, 
				--	välja arvatud kontod 601000 ja 601001, mida ei võeta üldse arvesse olenemata TP koodist)))
				INSERT INTO tmp_saldoandmik (nimetus, db , kr, konto , tegev , tp , allikas, rahavoo, timestamp, kpv, rekvid) 
					SELECT nimetus, kr , db, konto , tegev , tp , allikas, rahavoo, lcReturn, date(), tnrekvId
					from  saldoandmik
					where aasta = year(tdKpv) and kuu = month(tdKpv) 
					and ltrim(rtrim(omatp)) = ltrim(rtrim(v_omatp.OmaTp))
					and ltrim(rtrim(tp)) = ltrim(rtrim(v_tp.tp))
					and left(konto,1) in ('4','5','6') and konto not in ('601000','601001');

				--(esitaja saldoandmik sum (kõik kontod algusega 3, mille TP kood on võrreldava kood (kreedit miinus deebet)))

				INSERT INTO tmp_saldoandmik (nimetus, db , kr, konto , tegev , tp , allikas, rahavoo, timestamp, kpv, rekvid) 
					SELECT nimetus, kr , db, konto , tegev , tp , allikas, rahavoo, lcReturn, date(), tnrekvId
						from  saldoandmik
						where aasta = year(tdKpv) and kuu = month(tdKpv) 
						and ltrim(rtrim(omatp)) = ltrim(rtrim(v_tp.tp))
						and left(omatp,4) = left(lcOmatp,4)
						and ltrim(rtrim(tp)) = ltrim(rtrim(v_omatp.omatp))
						and left(konto,1) = '3';
						

				--(esitaja saldoandmik sum (kõik kontod algusega 7, mille TP kood on võrreldava kood (deebet miinus kreedit)))
				INSERT INTO tmp_saldoandmik (nimetus, db , kr, konto , tegev , tp , allikas, rahavoo, timestamp, kpv, rekvid) 
					SELECT nimetus, kr , db, konto , tegev , tp , allikas, rahavoo, lcReturn, date(), tnrekvId
					from  saldoandmik
					where aasta = year(tdKpv) and kuu = month(tdKpv) 
					and ltrim(rtrim(omatp)) = ltrim(rtrim(v_omatp.OmaTp))
					and ltrim(rtrim(tp)) = ltrim(rtrim(v_tp.tp))
					and left(konto,2) = '70';

					
				--(võrreldava saldoandmik (kõik kontod algusega 7, mille TP kood on aruande koostaja kood (kreedit miinus deebet)))
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
				select nimetus, db,kr, konto, tegev, tp, allikas,rahavoo ,tdkpv, year(tdKpv), month(tdKpv), 0,lcOmatp,0 
				from tmp_saldoandmik
				where timestamp = lcreturn and rekvid = tnRekvId;

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
		-- (esitaja saldoandmik sum (kõik kontod algusega 1, mille TP kood on võrreldava kood (deebet miinus kreedit)))
		insert into tmp_sk_aruanned (omaTp, tp, summa01, kpv, rekvid, timestamp, tyyp) 
			select ltrim(rtrim(lcomatp)), ltrim(rtrim(v_tp.tp)), db - kr, tdKpv, tnRekvId, lcreturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and ltrim(rtrim(saldoandmik.omatp)) = ltrim(rtrim(lcomatp))
			and ltrim(rtrim(saldoandmik.tp)) = ltrim(rtrim(v_tp.tp))
			and left(ltrim(rtrim(saldoandmik.konto)),1) = '1';


		-- (võrreldava saldoandmik (kõik kontod algusega 2, mille TP kood on aruande koostaja kood (kreedit miinus deebet)))

		insert into tmp_sk_aruanned (omaTp, tp, summa02,  kpv, rekvid, timestamp, tyyp) 
			select ltrim(rtrim(lcomatp)), ltrim(rtrim(v_tp.tp)), kr - db, tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and ltrim(rtrim(omatp)) = ltrim(rtrim(v_tp.tp)) 
			and ltrim(rtrim(tp)) = ltrim(rtrim(lcomatp))
			and left(ltrim(rtrim(konto)),1) = '2';

	
		-- (võrreldava saldoandmik (kõik kontod algusega 1, mille TP kood on aruande koostaja kood (deebet miinus kreedit)))

		insert into tmp_sk_aruanned (omaTp, tp, summa03,  kpv, rekvid, timestamp, tyyp) 
			select ltrim(rtrim(lcomatp)), ltrim(rtrim(v_tp.tp)), db - kr, tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and ltrim(rtrim(omatp)) = ltrim(rtrim(v_tp.tp))
			and ltrim(rtrim(tp)) = lcomatp
			and left(ltrim(rtrim(konto)),1) = '1';




		-- (esitaja saldoandmik sum (kõik kontod algusega 2, mille TP kood on võrreldava kood (kreedit miinus deebet)))

		insert into tmp_sk_aruanned (omaTp, tp, summa04, kpv, rekvid, timestamp, tyyp) 
			select ltrim(rtrim(lcomatp)), ltrim(rtrim(v_tp.tp)), kr - db, tdKpv, tnRekvId, lcreturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and ltrim(rtrim(omatp)) = ltrim(rtrim(lcomatp))
			and ltrim(rtrim(tp)) = ltrim(rtrim(v_tp.tp))
			and left(ltrim(rtrim(konto)),1) = '2';




		-- (võrreldava saldoandmik (kõik kontod algusega 4 kuni 6, mille esitaja kood on TP kood on aruande koostaja kood (deebet miinus kreedit, 
		--	välja arvatud kontod 601000 ja 601001, mida ei võeta üldse arvesse olenemata TP koodist)))
		insert into tmp_sk_aruanned (omaTp, tp, summa05,  kpv, rekvid, timestamp, tyyp) 
			select ltrim(rtrim(lcomatp)), ltrim(rtrim(v_tp.tp)), db - kr, tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and ltrim(rtrim(omatp)) = ltrim(rtrim(v_tp.tp)) 
			and ltrim(rtrim(tp)) = ltrim(rtrim(lcomatp))
			and left(ltrim(rtrim(konto)),1) in ('4','5','6') and ltrim(rtrim(konto)) not in ('601000','601001');

		--(esitaja saldoandmik sum (kõik kontod algusega 3, mille TP kood on võrreldava kood (kreedit miinus deebet)))

		insert into tmp_sk_aruanned (omaTp, tp, summa06, kpv, rekvid, timestamp, tyyp) 
			select ltrim(rtrim(lcomatp)), ltrim(rtrim(v_tp.tp)), kr - db, tdKpv, tnRekvId, lcreturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and ltrim(rtrim(omatp)) = ltrim(rtrim(lcomatp))
			and ltrim(rtrim(tp)) = ltrim(rtrim(v_tp.tp))
			and left(ltrim(rtrim(konto)),1) = '3';

		--(esitaja saldoandmik sum (kõik kontod algusega 4-6, mille TP kood on võrreldava kood (deebet miinus kreedit), 
		--välja arvatud kontod 601000 ja 601001, mida ei võeta üldse arvesse, olenemata TP koodist))

		insert into tmp_sk_aruanned (omaTp, tp, summa07, kpv, rekvid, timestamp, tyyp) 
			select ltrim(rtrim(lcomatp)), ltrim(rtrim(v_tp.tp)), db-kr, tdKpv, tnRekvId, lcreturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and ltrim(rtrim(omatp)) = ltrim(rtrim(lcomatp))
			and ltrim(rtrim(tp)) = ltrim(rtrim(v_tp.tp))
			and left(ltrim(rtrim(konto)),1) in ('4','5','6') and ltrim(rtrim(konto)) not in ('601000','601001');

		--(võrreldava saldoandmik (kõik kontod algusega 3, mille mille TP kood on aruande koostaja kood (kreedit miinus deebet)))
		insert into tmp_sk_aruanned (omaTp, tp, summa08,  kpv, rekvid, timestamp, tyyp) 
			select ltrim(rtrim(lcomatp)), ltrim(rtrim(v_tp.tp)), kr-db, tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and ltrim(rtrim(omatp)) = ltrim(rtrim(v_tp.tp)) 
			and ltrim(rtrim(tp)) = ltrim(rtrim(lcomatp))
			and left(ltrim(rtrim(konto)),1) = '3';
		--(esitaja saldoandmik sum (kõik kontod algusega 7, mille TP kood on võrreldava kood (deebet miinus kreedit)))
		insert into tmp_sk_aruanned (omaTp, tp, summa09, kpv, rekvid, timestamp, tyyp) 
			select ltrim(rtrim(lcomatp)), ltrim(rtrim(v_tp.tp)), db-kr, tdKpv, tnRekvId, lcreturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and ltrim(rtrim(omatp)) = ltrim(rtrim(lcomatp))
			and ltrim(rtrim(tp)) = ltrim(rtrim(v_tp.tp))
			and left(ltrim(rtrim(konto)),1) = '7';
		--(võrreldava saldoandmik (kõik kontod algusega 7, mille TP kood on aruande koostaja kood (kreedit miinus deebet)))
		insert into tmp_sk_aruanned (omaTp, tp, summa10,  kpv, rekvid, timestamp, tyyp) 
			select ltrim(rtrim(lcomatp)), ltrim(rtrim(v_tp.tp)), kr-db, tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and ltrim(rtrim(omatp)) = ltrim(rtrim(v_tp.tp)) 
			and ltrim(rtrim(tp)) = ltrim(rtrim(lcomatp))
			and left(ltrim(rtrim(konto)),1) = '7';

		--(esitaja saldoandmik sum (kõik kontod algusega 1 kuni 7, mille TP kood on võrreldava kood (deebet miinus kreedit) 
		-- välja arvatud kontod 601000 ja 601001, mida ei võeta üldse arvesse olenemata TP koodist))

		insert into tmp_sk_aruanned (omaTp, tp, summa11, kpv, rekvid, timestamp, tyyp) 
			select ltrim(rtrim(lcomatp)), ltrim(rtrim(v_tp.tp)), db-kr, tdKpv, tnRekvId, lcreturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and ltrim(rtrim(omatp)) = ltrim(rtrim(lcomatp))
			and ltrim(rtrim(tp)) = ltrim(rtrim(v_tp.tp))
			and left(ltrim(rtrim(konto)),1) in ('1','2','3','4','5','6','7') and ltrim(rtrim(konto)) not in ('601000','601001');
		--(võrreldava saldoandmik (kõik kontod algusega 1-7, mille TP kood on aruande koostaja kood (kreedit miinus deebet) 
		--välja arvatud kontod 601000 ja 601001, mida ei võeta üldse arvesse olenemata TP koodist))
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
ALTER FUNCTION sp_saldoandmik_aruanned(integer, date, integer, integer, integer,integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_saldoandmik_aruanned(integer, date, integer, integer, integer,integer) TO public;
GRANT EXECUTE ON FUNCTION sp_saldoandmik_aruanned(integer, date, integer, integer, integer,integer) TO vlad;
GRANT EXECUTE ON FUNCTION sp_saldoandmik_aruanned(integer, date, integer, integer, integer,integer) TO saldoandmikkoostaja;


CREATE OR REPLACE FUNCTION sp_salvesta_aasta(integer, integer, integer, integer, integer, integer)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnrekvid alias for $2;
	tnaasta alias for $3;
	tnkuu alias for $4;
	tnkinni alias for $5;
	tndefault_ alias for $6;
	lnaastaId int;
	lnId int; 
	lrCurRec record;
begin

if tnId = 0 then
	-- uus kiri
	insert into aasta (rekvid,aasta,kuu,kinni,default_) 
		values (tnrekvid,tnaasta,tnkuu,tnkinni,tndefault_);

	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
		raise notice 'lnId %',lnId;
		lnaastaId:= cast(CURRVAL('public.aasta_id_seq') as int4);
		raise notice 'lnaastaId %',lnaastaId;
	else
		lnAastaId = 0;
	end if;
else
	-- muuda 
	select * into lrCurRec from aasta where id = tnId;
	if lrCurRec.rekvid <> tnrekvid or lrCurRec.aasta <> tnaasta or lrCurRec.kuu <> tnkuu or lrCurRec.kinni <> tnkinni or lrCurRec.default_ <> tndefault_ then 
	update aasta set 
		rekvid = tnrekvid,
		aasta = tnaasta,
		kuu = tnkuu,
		kinni = tnkinni,
		default_ = tndefault_
	where id = tnId;
	end if;
	lnaastaId := tnId;
end if;

         return  lnaastaId;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_aasta(integer, integer, integer, integer, integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_aasta(integer, integer, integer, integer, integer, integer) TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_aasta(integer, integer, integer, integer, integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_aasta(integer, integer, integer, integer, integer, integer) TO dbpeakasutaja;

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


         return  lnarv1Id;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_arv1(integer, integer, integer, numeric, numeric, integer, numeric, integer, numeric, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, integer, character varying, character varying,numeric,character varying) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_arv1(integer, integer, integer, numeric, numeric, integer, numeric, integer, numeric, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, integer, character varying, character varying,numeric,character varying) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_arv1(integer, integer, integer, numeric, numeric, integer, numeric, integer, numeric, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, integer, character varying, character varying,numeric,character varying) TO dbpeakasutaja;



CREATE OR REPLACE FUNCTION sp_salvesta_avans1(integer, integer, integer, integer, date, character varying, text, integer, text)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnrekvid alias for $2;
	tnuserid alias for $3;
	tnasutusid alias for $4;
	tdkpv alias for $5;
	tcnumber alias for $6;
	ttselg alias for $7;
	tndokpropid alias for $8;
	ttmuud alias for $9;
	lnavans1Id int;
	lnId int; 
	lrCurRec record;
begin

if (fnc_aasta_kontrol(tnrekvid, tdkpv)= 0) then
	raise exception 'Perion on kinnitatud';
	return 0;
end if;


if tnId = 0 then
	-- uus kiri
	insert into avans1 (rekvid,userid,asutusid,kpv,number,selg,dokpropid,muud,jaak) 
		values (tnrekvid,tnuserid,tnasutusid,tdkpv,tcnumber,ttselg,tndokpropid,ttmuud,0);

	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
	--	raise notice 'lnId %',lnId;
		lnavans1Id:= cast(CURRVAL('public.avans1_id_seq') as int4);
	--	raise notice 'lnaastaId %',lnaastaId;
	else
		lnavans1Id = 0;
	end if;

	if lnavans1Id = 0 then
		raise exception ':%','Ei saa lisada kiri';
	end if;




else
	-- muuda 
	select * into lrCurRec from avans1 where id = tnId;
	if lrCurRec.rekvid <> tnrekvid or lrCurRec.userid <> tnuserid or lrCurRec.asutusid <> tnasutusid or lrCurRec.kpv <> tdkpv or
		lrCurRec.number <> tcnumber or lrCurRec.selg <> ttselg  or lrCurRec.dokpropid <> tndokpropid or ifnull(lrCurRec.muud,space(1)) <> ifnull(ttmuud,space(1)) then 
	update avans1 set 
		rekvid = tnrekvid,
		userid = tnuserid,
		asutusid = tnasutusid,
		kpv = tdkpv,
		number = tcnumber,
		selg = ttselg,
		dokpropid = tndokpropid,
		muud = ttmuud
	where id = tnId;
	end if;
	lnavans1Id := tnId;
end if;
if lnavans1Id > 0 then
	perform fnc_avansijaak(lnavans1Id);
end if;
         return  lnavans1Id;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_avans1(integer, integer, integer, integer, date, character varying, text,  integer, text) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_avans1(integer, integer, integer, integer, date, character varying, text, integer, text) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_avans1(integer, integer, integer, integer, date, character varying, text, integer, text) TO dbpeakasutaja;



CREATE OR REPLACE FUNCTION sp_salvesta_avans2(integer, integer, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, numeric, numeric, text,character varying,numeric,character varying, integer)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnparentid alias for $2;
	tnnomid alias for $3;
	tckonto alias for $4;
	tckood1 alias for $5;
	tckood2 alias for $6;
	tckood3 alias for $7;
	tckood4 alias for $8;
	tckood5 alias for $9;
	tctunnus alias for $10;
	tnsumma alias for $11;
	tnkbm alias for $12;
	tnkokku alias for $13;
	ttmuud alias for $14;
	tcValuuta alias for $15;
	tnKuurs alias for $16;
	tcProj alias for $17;
	tnOpt alias for $18;
	lnavans2Id int;
	lnId int; 
	lrCurRec record;
	v_dokvaluuta record;
begin

if tnId = 0 then
	-- uus kiri
	insert into avans2 (parentid,nomid,konto,kood1,kood2,kood3,kood4,kood5,tunnus,summa,kbm,kokku,muud,proj) 
		values (tnparentid,tnnomid,tckonto,tckood1,tckood2,tckood3,tckood4,tckood5,tctunnus,tnsumma,tnkbm,tnkokku,ttmuud,tcProj);

	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
	--	raise notice 'lnId %',lnId;
		lnavans2Id:= cast(CURRVAL('public.avans2_id_seq') as int4);
	--	raise notice 'lnaastaId %',lnaastaId;
	else
		lnavans2Id = 0;
	end if;

	if lnavans2Id = 0 then
		raise exception ':%','Ei saa lisada kiri';
	end if;

	-- valuuta

	insert into dokvaluuta1 (dokliik,dokid, valuuta, kuurs) 
		values (5, lnavans2Id,tcValuuta, tnKuurs);



else
	-- muuda 
	select * into lrCurRec from avans2 where id = tnId;
	if lrCurRec.parentid <> tnparentid or lrCurRec.nomid <> tnnomid or lrCurRec.konto <> tckonto or lrCurRec.kood1 <> tckood1 or
		lrCurRec.kood2 <> tckood2 or lrCurRec.kood3 <> tckood3 or lrCurRec.kood4 <> tckood4 or lrCurRec.kood5 <> tckood5 or 
		lrCurRec.tunnus <> tctunnus or lrCurRec.summa <> tnsumma or lrCurRec.proj <> tcProj or
		lrCurRec.kbm <> tnkbm or lrCurRec.kokku <> tnkokku or ifnull(lrCurRec.muud,space(1)) <> ifnull(ttmuud,space(1)) then 
	update avans2 set 
		parentid = tnparentid,
		nomid = tnnomid,
		konto = tckonto,
		kood1 = tckood1,
		kood2 = tckood2,
		kood3 = tckood3,
		kood4 = tckood4,
		kood5 = tckood5,
		tunnus = tctunnus,
		proj = tcProj,
		summa = tnsumma,
		kbm = tnkbm,
		kokku = tnkokku,
		muud = ttmuud
	where id = tnId;
	end if;
	lnavans2Id := tnId;

	-- valuuta
	if (select count(id) from dokvaluuta1 where dokliik = 5 and dokid = lnavans2Id) = 0 then

		insert into dokvaluuta1 (dokliik, dokid, valuuta, kuurs) 
			values (5, lnavans2Id,tcValuuta, tnKuurs);
	else
		select * into v_dokvaluuta from dokvaluuta1 where dokliik = 5 and dokid = lnavans2Id ;

		if tcValuuta <> v_dokvaluuta.valuuta or tnKuurs <> v_dokvaluuta.kuurs then

			update dokvaluuta1 set valuuta = tcValuuta, kuurs = tnKuurs where id = v_dokvaluuta.id;
			
		end if;
	
	end if;
			

	
end if;
if tnOpt = 1 then
	-- lisa operatsioonid
	perform fnc_avansijaak(tnParentId);
	perform gen_lausend_avans(tnParentId);
end if;

         return  lnavans2Id;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_avans2(integer, integer, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, numeric, numeric, text,character varying,numeric, character varying, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_avans2(integer, integer, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, numeric, numeric, text,character varying,numeric, character varying, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_avans2(integer, integer, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, numeric, numeric, text,character varying,numeric, character varying, integer) TO dbpeakasutaja;


CREATE OR REPLACE FUNCTION sp_salvesta_eelarve(integer, integer, integer, integer, numeric, text, integer, integer, character varying, character varying, character varying, character varying, character varying, integer, date, character varying, numeric)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnrekvid alias for $2;
	tnallikasid alias for $3;
	tnaasta alias for $4;
	tnsumma alias for $5;
	ttmuud alias for $6;
	tntunnus alias for $7;
	tntunnusid alias for $8;
	tckood1 alias for $9;
	tckood2 alias for $10;
	tckood3 alias for $11;
	tckood4 alias for $12;
	tckood5 alias for $13;
	tnkuu alias for $14;
	tdkpv alias for $15;
	tcValuuta alias for $16;
	tnKuurs alias for $17;
	lneelarveId int;
	lnId int; 
	lrCurRec record;
	v_dokvaluuta record;
	
begin

if tnId = 0 then
	-- uus kiri
	insert into eelarve (rekvid,allikasid,aasta,summa,muud,tunnus,tunnusid,kood1,kood2,kood3,kood4,kood5,kuu,kpv) 
		values (tnrekvid,tnallikasid,tnaasta,tnsumma,ttmuud,tntunnus,tntunnusid,tckood1,tckood2,tckood3,tckood4,tckood5,tnkuu,tdkpv);

	GET DIAGNOSTICS lnId = ROW_COUNT;


	if lnId > 0 then
	--	raise notice 'lnId %',lnId;
		lneelarveId:= cast(CURRVAL('public.eelarve_id_seq') as int4);
	--	raise notice 'lnaastaId %',lnaastaId;
	else
		lneelarveId = 0;
	end if;

	if lneelarveId = 0 then
		raise exception ':%','Ei saa lisada kiri';
	end if;

		-- valuuta

	insert into dokvaluuta1 (dokid, dokliik, valuuta, kuurs) 
		values (lneelarveId,11,tcValuuta, tnKuurs);




else
	-- muuda 
	select * into lrCurRec from eelarve where id = tnId;
	if lrCurRec.rekvid <> tnrekvid or lrCurRec.allikasid <> tnallikasid or lrCurRec.aasta <> tnaasta or lrCurRec.summa <> tnsumma or ifnull(lrCurRec.muud,space(1)) <> ifnull(ttmuud,space(1)) or lrCurRec.tunnus <> tntunnus or lrCurRec.tunnusid <> tntunnusid or lrCurRec.kood1 <> tckood1 or lrCurRec.kood2 <> tckood2 or lrCurRec.kood3 <> tckood3 or lrCurRec.kood4 <> tckood4 or lrCurRec.kood5 <> tckood5 or ifnull(lrCurRec.kuu,0) <> ifnull(tnkuu,0) or ifnull(lrCurRec.kpv,date(1900,01,01)) <> ifnull(tdkpv,date(1900,01,01)) then 
	update eelarve set 
		rekvid = tnrekvid,
		allikasid = tnallikasid,
		aasta = tnaasta,
		summa = tnsumma,
		muud = ttmuud,
		tunnus = tntunnus,
		tunnusid = tntunnusid,
		kood1 = tckood1,
		kood2 = tckood2,
		kood3 = tckood3,
		kood4 = tckood4,
		kood5 = tckood5,
		kuu = tnkuu,
		kpv = tdkpv
	where id = tnId;
	end if;
	lneelarveId := tnId;


	-- valuuta
	if (select count(id) from dokvaluuta1 where dokliik = 8 and dokid = lneelarveId) = 0 then

		insert into dokvaluuta1 (dokliik, dokid, valuuta, kuurs) 
			values (8, lneelarveId,tcValuuta, tnKuurs);
	else
		select * into v_dokvaluuta from dokvaluuta1 where dokliik = 8 and dokid = lneelarveId ;

		if tcValuuta <> v_dokvaluuta.valuuta or tnKuurs <> v_dokvaluuta.kuurs then

			update dokvaluuta1 set valuuta = tcValuuta, kuurs = tnKuurs where id = v_dokvaluuta.id;

						
		end if;
	
	end if;



end if;




         return  lneelarveId;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_eelarve(integer, integer, integer, integer, numeric, text, integer, integer, character varying, character varying, character varying, character varying, character varying, integer, date, character varying, numeric) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_eelarve(integer, integer, integer, integer, numeric, text, integer, integer, character varying, character varying, character varying, character varying, character varying, integer, date, character varying, numeric) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_eelarve(integer, integer, integer, integer, numeric, text, integer, integer, character varying, character varying, character varying, character varying, character varying, integer, date, character varying, numeric) TO dbpeakasutaja;

CREATE OR REPLACE FUNCTION sp_salvesta_journal(integer, integer, integer, date, integer, text, character, text, integer)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnrekvid alias for $2;
	tnuserid alias for $3;
	tdkpv alias for $4;
	tnasutusid alias for $5;
	ttselg alias for $6;
	tcdok alias for $7;
	ttmuud alias for $8;
	tndokid alias for $9;
	lnjournalId int;
	lnId int; 
	lrCurRec record;
begin

if (fnc_aasta_kontrol(tnrekvid, tdkpv)= 0) then
	raise exception 'Perion on kinnitatud';
	return 0;
end if;


if tnId = 0 then
	-- uus kiri
	insert into journal (rekvid,userid,kpv,asutusid,selg,dok,muud,dokid) 
		values (tnrekvid,tnuserid,tdkpv,tnasutusid,ttselg+' ',tcdok,ttmuud,tndokid);


	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
	--	raise notice 'lnId %',lnId;
		lnjournalId:= cast(CURRVAL('public.journal_id_seq') as int4);
	--	raise notice 'lnaastaId %',lnaastaId;
	else
		lnjournalId = 0;
	end if;

	if lnjournalId = 0 then
		raise exception ':%','Ei saa lisada kiri';
	end if;


--	lnjournalId:= cast(CURRVAL('public.journal_id_seq') as int4);

else
	-- muuda 
	select * into lrCurRec from journal where id = tnId;
	if lrCurRec.rekvid <> tnrekvid or lrCurRec.userid <> tnuserid or lrCurRec.kpv <> tdkpv or lrCurRec.asutusid <> tnasutusid or lrCurRec.selg <> ttselg or lrCurRec.dok <> tcdok or ifnull(lrCurRec.muud,space(1)) <> ifnull(ttmuud,space(1)) or lrCurRec.dokid <> tndokid then 
	update journal set 
		rekvid = tnrekvid,
		userid = tnuserid,
		kpv = tdkpv,
		asutusid = tnasutusid,
		selg = ttselg,
		dok = tcdok,
		muud = ttmuud,
		dokid = tndokid
	where id = tnId;
	end if;
	lnjournalId := tnId;
end if;



         return  lnjournalId;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_journal(integer, integer, integer, date, integer, text, character, text, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_journal(integer, integer, integer, date, integer, text, character, text, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_journal(integer, integer, integer, date, integer, text, character, text, integer) TO dbpeakasutaja;


CREATE OR REPLACE FUNCTION sp_salvesta_journal1(integer, integer, numeric, character, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, numeric, character varying, character varying)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnparentid alias for $2;
	tnsumma alias for $3;
	tcdokument alias for $4;
	ttmuud alias for $5;
	tckood1 alias for $6;
	tckood2 alias for $7;
	tckood3 alias for $8;
	tckood4 alias for $9;
	tckood5 alias for $10;
	tcdeebet alias for $11;
	tclisa_d alias for $12;
	tckreedit alias for $13;
	tclisa_k alias for $14;
	tcvaluuta alias for $15;
	tnkuurs alias for $16;
	tnvalsumma alias for $17;
	tctunnus alias for $18;
	tcProj alias for $19;
	lnjournal1Id int;
	lnId int; 
	lrCurRec record;

	tmpJournal record;
	lnKontrol int;
	lnrekvid int;
	lcViga varchar;
	lcOmaTp varchar;
	ldKpv date;

	v_dokvaluuta record;
begin

select rekvid, kpv into lnrekvId, ldKpv from journal where id = tnparentid;
select recalc into lnKontrol from rekv where id = lnrekvid;

lcOmaTp = ltrim(rtrim(fnc_getomatp(lnrekvId,year(ldKpv))));		

		if ifnull(lnKontrol,0) = 1 then
			lcViga = sp_lausendikontrol(tcdeebet, tcKreedit,  tclisa_d, tclisa_k, tckood1, tcKood2, tckood5, tckood3, lcOmaTP, ldKpv, tcvaluuta);
			if left(ltrim(rtrim(lcViga)),4) = 'Viga' then
				raise notice ':%',lcViga;
				return 0;
			end if;
		end if;


if tnId = 0 then
	-- uus kiri
	insert into journal1 (parentid,summa,dokument,muud,kood1,kood2,kood3,kood4,kood5,deebet,lisa_k,kreedit,lisa_d,valuuta,kuurs,valsumma,tunnus, proj) 
		values (tnparentid,tnsumma,tcdokument,ttmuud,tckood1,tckood2,tckood3,tckood4,tckood5,tcdeebet,tclisa_k,tckreedit,tclisa_d,tcvaluuta,tnkuurs,tnvalsumma,tctunnus, tcProj);

	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
	--	raise notice 'lnId %',lnId;
		lnjournal1Id:= cast(CURRVAL('public.journal1_id_seq') as int4);
	--	raise notice 'lnaastaId %',lnaastaId;
	else
		lnjournal1Id = 0;
	end if;

	if lnjournal1Id = 0 then
		raise exception ':%','Ei saa lisada kiri';
	end if;

	-- valuuta

	insert into dokvaluuta1 (dokliik,dokid, valuuta, kuurs) 
		values (1, lnjournal1Id,tcValuuta, tnKuurs);

else
	-- muuda 
	select * into lrCurRec from journal1 where id = tnId;
	if lrCurRec.parentid <> tnparentid or lrCurRec.summa <> tnsumma or ifnull(lrCurRec.dokument,space(1)) <> ifnull(tcdokument,space(1)) or ifnull(lrCurRec.muud,space(1)) <> ifnull(ttmuud,space(1)) or lrCurRec.kood1 <> tckood1 or lrCurRec.kood2 <> tckood2 or lrCurRec.kood3 <> tckood3 or lrCurRec.kood4 <> tckood4 or lrCurRec.kood5 <> tckood5 or lrCurRec.deebet <> tcdeebet or lrCurRec.lisa_k <> tclisa_k or lrCurRec.kreedit <> tckreedit or lrCurRec.lisa_d <> tclisa_d or lrCurRec.valuuta <> tcvaluuta or 
		lrCurRec.kuurs <> tnkuurs or lrCurRec.valsumma <> tnvalsumma or lrCurRec.tunnus <> tctunnus or lrCurRec.proj <> tcProj then 
	update journal1 set 
		parentid = tnparentid,
		summa = tnsumma,
		dokument = tcdokument,
		muud = ttmuud,
		kood1 = tckood1,
		kood2 = tckood2,
		kood3 = tckood3,
		kood4 = tckood4,
		kood5 = tckood5,
		deebet = tcdeebet,
		lisa_k = tclisa_k,
		kreedit = tckreedit,
		lisa_d = tclisa_d,
		valuuta = tcvaluuta,
		kuurs = tnkuurs,
		valsumma = tnvalsumma,
		tunnus = tctunnus,
		proj = tcproj
	where id = tnId;
	end if;
	lnjournal1Id := tnId;


	-- valuuta
	if (select count(id) from dokvaluuta1 where dokliik = 1 and dokid = lnjournal1Id) = 0 then

		insert into dokvaluuta1 (dokliik, dokid, valuuta, kuurs) 
			values (1, lnjournal1Id,tcValuuta, tnKuurs);
	else
		select * into v_dokvaluuta from dokvaluuta1 where dokliik = 1 and dokid = lnjournal1Id ;

		if tcValuuta <> v_dokvaluuta.valuuta or tnKuurs <> v_dokvaluuta.kuurs then

			update dokvaluuta1 set valuuta = tcValuuta, kuurs = tnKuurs where id = v_dokvaluuta.id;
			
		end if;
	
	end if;
			
	
end if;

select id, rekvid, kpv, asutusId, dok into tmpJournal from journal where id = tnparentId;


--avans
select avans1.id into lnId from avans1 inner join dokprop on dokprop.id = avans1.dokpropid
	where ltrim(rtrim(number)) = ltrim(rtrim(tmpJournal.dok)) 
	and rekvid = tmpJournal.rekvid 
	and avans1.asutusId = tmpJournal.asutusId
	and ltrim(rtrim(dokprop.konto)) = ltrim(rtrim(tcDeebet))
	order by avans1.kpv desc limit 1;

	if ifnull(lnId,0) > 0 then
		perform fnc_avansijaak(lnId);
	end if;

-- reklmaks


if (select count(id) from luba where number = tmpJournal.dok and rekvid = tmpJournal.rekvid and luba.parentid = tmpJournal.asutusId) > 0 then
	perform sp_tasu_dekl(tmpJournal.id);
end if;

         return  lnjournal1Id;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_journal1(integer, integer, numeric, character, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, numeric, character varying, character varying) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_journal1(integer, integer, numeric, character, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, numeric, character varying, character varying) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_journal1(integer, integer, numeric, character, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, numeric, character varying, character varying) TO dbpeakasutaja;

CREATE OR REPLACE FUNCTION sp_salvesta_korder1(integer, integer, integer, integer, integer, integer, integer, character, date, integer, text, text, text, text, numeric, text, integer, integer, integer)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnrekvid alias for $2;
	tnuserid alias for $3;
	tnjournalid alias for $4;
	tnkassaid alias for $5;
	tntyyp alias for $6;
	tndoklausid alias for $7;
	tcnumber alias for $8;
	tdkpv alias for $9;
	tnasutusid alias for $10;
	ttnimi alias for $11;
	ttaadress alias for $12;
	ttdokument alias for $13;
	ttalus alias for $14;
	tnsumma alias for $15;
	ttmuud alias for $16;
	tnarvid alias for $17;
	tndoktyyp alias for $18;
	tndokid alias for $19;
	lnkorder1Id int;
	lnId int; 
	lrCurRec record;
begin

if tnId = 0 then
	-- uus kiri
	insert into korder1 (rekvid,userid,journalid,kassaid,tyyp,doklausid,number,kpv,asutusid,nimi,aadress,dokument,alus,summa,muud,arvid,doktyyp,dokid) 
		values (tnrekvid,tnuserid,tnjournalid,tnkassaid,tntyyp,tndoklausid,tcnumber,tdkpv,tnasutusid,ttnimi,ttaadress,ttdokument,ttalus,tnsumma,ttmuud,tnarvid,tndoktyyp,tndokid);

	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
	--	raise notice 'lnId %',lnId;
		lnkorder1Id:= cast(CURRVAL('public.korder1_id_seq') as int4);
	else
		lnkorder1Id = 0;
	end if;

	if lnkorder1Id = 0 then
		raise exception ':%','Ei saa lisada kiri';
	end if;

else
	-- muuda 
	select * into lrCurRec from korder1 where id = tnId;
	if lrCurRec.rekvid <> tnrekvid or lrCurRec.userid <> tnuserid or lrCurRec.journalid <> tnjournalid or lrCurRec.kassaid <> tnkassaid or lrCurRec.tyyp <> tntyyp or lrCurRec.doklausid <> tndoklausid or lrCurRec.number <> tcnumber or lrCurRec.kpv <> tdkpv or lrCurRec.asutusid <> tnasutusid or lrCurRec.nimi <> ttnimi or lrCurRec.aadress <> ttaadress or lrCurRec.dokument <> ttdokument or lrCurRec.alus <> ttalus or lrCurRec.summa <> tnsumma or ifnull(lrCurRec.muud,space(1)) <> ifnull(ttmuud,space(1)) or lrCurRec.arvid <> tnarvid or lrCurRec.doktyyp <> tndoktyyp or lrCurRec.dokid <> tndokid then 
	update korder1 set 
		rekvid = tnrekvid,
		userid = tnuserid,
		journalid = tnjournalid,
		kassaid = tnkassaid,
		tyyp = tntyyp,
		doklausid = tndoklausid,
		number = tcnumber,
		kpv = tdkpv,
		asutusid = tnasutusid,
		nimi = ttnimi,
		aadress = ttaadress,
		dokument = ttdokument,
		alus = ttalus,
		summa = tnsumma,
		muud = ttmuud,
		arvid = tnarvid,
		doktyyp = tndoktyyp,
		dokid = tndokid
	where id = tnId;
	end if;
	lnkorder1Id := tnId;
end if;

         return  lnkorder1Id;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_korder1(integer, integer, integer, integer, integer, integer, integer, character, date, integer, text, text, text, text, numeric, text, integer, integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_korder1(integer, integer, integer, integer, integer, integer, integer, character, date, integer, text, text, text, text, numeric, text, integer, integer, integer) TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_korder1(integer, integer, integer, integer, integer, integer, integer, character, date, integer, text, text, text, text, numeric, text, integer, integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_korder1(integer, integer, integer, integer, integer, integer, integer, character, date, integer, text, text, text, text, numeric, text, integer, integer, integer) TO dbpeakasutaja;



CREATE OR REPLACE FUNCTION sp_salvesta_korder2(integer, integer, integer, character, numeric, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying,character varying,numeric,character varying )
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnparentid alias for $2;
	tnnomid alias for $3;
	tcnimetus alias for $4;
	tnsumma alias for $5;
	tckonto alias for $6;
	tckood1 alias for $7;
	tckood2 alias for $8;
	tckood3 alias for $9;
	tckood4 alias for $10;
	tckood5 alias for $11;
	tctp alias for $12;
	tctunnus alias for $13;
	tcValuuta alias for $14;
	tnKuurs alias for $15;
	tcProj alias for $16;
	lnkorder2Id int;
	lnId int; 
	lrCurRec record;
	v_dokvaluuta record;
begin

if tnId = 0 then
	-- uus kiri
	insert into korder2 (parentid,nomid,nimetus,summa,konto,kood1,kood2,kood3,kood4,kood5,tp,tunnus,proj) 
		values (tnparentid,tnnomid,tcnimetus,tnsumma,tckonto,tckood1,tckood2,tckood3,tckood4,tckood5,tctp,tctunnus,tcProj);

	GET DIAGNOSTICS lnId = ROW_COUNT;


	if lnId > 0 then
	--	raise notice 'lnId %',lnId;
		lnkorder2Id:= cast(CURRVAL('public.korder2_id_seq') as int4);
	--	raise notice 'lnaastaId %',lnaastaId;
	else
		lnkorder2Id = 0;
	end if;

	if lnkorder2Id = 0 then
		raise exception ':%','Ei saa lisada kiri';
	end if;

	-- valuuta

	insert into dokvaluuta1 (dokid, dokliik, valuuta, kuurs) 
		values (lnkorder2Id,11,tcValuuta, tnKuurs);


else
	-- muuda 
	select * into lrCurRec from korder2 where id = tnId;
	if lrCurRec.parentid <> tnparentid or lrCurRec.nomid <> tnnomid or lrCurRec.nimetus <> tcnimetus or lrCurRec.summa <> tnsumma or lrCurRec.konto <> tckonto or lrCurRec.kood1 <> tckood1 or lrCurRec.kood2 <> tckood2 or lrCurRec.kood3 <> tckood3 
		or lrCurRec.kood4 <> tckood4 or lrCurRec.kood5 <> tckood5 or lrCurRec.tp <> tctp or lrCurRec.tunnus <> tctunnus or lrCurRec.proj <> tcProj then 
	update korder2 set 
		parentid = tnparentid,
		nomid = tnnomid,
		nimetus = tcnimetus,
		summa = tnsumma,
		konto = tckonto,
		kood1 = tckood1,
		kood2 = tckood2,
		kood3 = tckood3,
		kood4 = tckood4,
		kood5 = tckood5,
		tp = tctp,
		proj = tcProj,
		tunnus = tctunnus
	where id = tnId;
	end if;
	lnkorder2Id := tnId;


	-- valuuta
	if (select count(id) from dokvaluuta1 where dokliik = 11 and dokid = lnkorder2Id) = 0 then

		insert into dokvaluuta1 (dokliik, dokid, valuuta, kuurs) 
			values (11, lnkorder2Id,tcValuuta, tnKuurs);
	else
		select * into v_dokvaluuta from dokvaluuta1 where dokliik = 11 and dokid = lnkorder2Id ;

		if tcValuuta <> v_dokvaluuta.valuuta or tnKuurs <> v_dokvaluuta.kuurs then

			update dokvaluuta1 set valuuta = tcValuuta, kuurs = tnKuurs where id = v_dokvaluuta.id;

						
		end if;
	
	end if;


end if;


	-- kontrollin valuuta arv taabelis

	if (select count(id) from dokvaluuta1 where dokliik = 10 and dokid = tnParentId) = 0 then
	
		insert into dokvaluuta1 (dokid, dokliik, valuuta, kuurs) 
			values (tnParentId,10,tcValuuta, tnKuurs);
	else
	
			update dokvaluuta1 set valuuta = tcValuuta, kuurs = tnKuurs where dokid = tnParentId and dokliik = 10;

	end if;



         return  lnkorder2Id;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_korder2(integer, integer, integer, character, numeric, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying,character varying,numeric,character varying ) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_korder2(integer, integer, integer, character, numeric, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying,character varying,numeric,character varying ) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_korder2(integer, integer, integer, character, numeric, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying,character varying,numeric,character varying ) TO dbpeakasutaja;


CREATE OR REPLACE FUNCTION sp_salvesta_library(integer, integer, character varying, character varying, character varying, text, integer, integer, integer, integer, integer)
  RETURNS integer AS
$BODY$
declare
	tnid alias for $1;
	tnrekvid alias for $2;
	tcKood alias for $3;
	tcNimetus alias for $4;
	tcLibrary alias for $5;
	ttMuud alias for $6;
	tnTun1 alias for $7;
	tnTun2 alias for $8;
	tntun3 alias for $9;
	tntun4 alias for $10;
	tnTun5 alias for $11;
	lnId int; 
	lnLibraryId int;
	lnSumma numeric(12,2);
	v_library record;
	v_rekv	record;
	lcString varchar;

	ldKpv date;


begin

if tnId = 0 then
	-- uus kiri
	insert into library (rekvid, kood, nimetus, library, muud, tun1, tun2, tun3, tun4, tun5) 
		values (tnrekvid, tckood, tcnimetus, tclibrary, ttmuud, tntun1, tntun2, tntun3, tntun4, tntun5);


	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
		lnLibraryId:= cast(CURRVAL('public.library_id_seq') as int4);
	else
		lnLibraryId = 0;
	end if;

	if lnLibraryId = 0 then
		raise exception ':%','Ei saa lisada kiri';
	end if;


else
	-- muuda 

	update library set 
		rekvid = tnrekvid,
		kood = tcKood,
		nimetus = tcNimetus,
		library = tcLibrary,
		muud = ttMuud,
		tun1 = tnTun1,
		tun2 = tnTun2,
		tun3 = tnTun3,
		tun4 = tnTun4,
		tun5 = tnTun5
	where id = tnId;

	lnLibraryId := tnId;
end if;

if (tclibrary = 'PROJ' or tclibrary = 'URITUS' or tclibrary = 'DOK' or tclibrary = 'KAIBEMAKS' or LEFT(tclibrary,3) = 'KBM' 
	or LEFT(tclibrary,7) = 'PASSIVA' ) and tnrekvid = 119 then
	if tnId = 0 then
		insert into library (rekvid, kood, nimetus, library, muud, tun1, tun2, tun3, tun4, tun5)
			select rekv.id, tckood, tcnimetus, tclibrary, ttmuud, tntun1, tntun2, tntun3, tntun4, tntun5 from rekv
				where parentid = 119;
	else

		update library set 
			kood = tckood,
			nimetus = tcnimetus,
			muud = ttmuud,
			tun1 = tntun1,
			tun2 = tntun2,
			tun3 = tntun3,
			tun4 = tntun4,
			tun5 = tntun5
			where rekvid in (select id from rekv where parentid = 119)
			and library.library = tclibrary 
			and library.kood = tckood;
		for v_rekv in
			select id from rekv where parentid = 119 
		loop
			if (select count(id) from library where kood = tcKood and rekvid = v_rekv.id and library = tclibrary) = 0 then
				insert into library (rekvid, kood, nimetus, library, muud, tun1, tun2, tun3, tun4, tun5) values
					(v_rekv.id, tckood, tcnimetus, tclibrary, ttmuud, tntun1, tntun2, tntun3, tntun4, tntun5); 
			end if;

		end loop;


	end if;
end if;

         return  lnLibraryId;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_library(integer, integer, character varying, character varying, character varying, text, integer, integer, integer, integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_library(integer, integer, character varying, character varying, character varying, text, integer, integer, integer, integer, integer) TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_library(integer, integer, character varying, character varying, character varying, text, integer, integer, integer, integer, integer) TO public;
GRANT EXECUTE ON FUNCTION sp_salvesta_library(integer, integer, character varying, character varying, character varying, text, integer, integer, integer, integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_library(integer, integer, character varying, character varying, character varying, text, integer, integer, integer, integer, integer) TO dbpeakasutaja;


CREATE OR REPLACE FUNCTION sp_salvesta_mk(integer, integer, integer, integer, date, date, character varying, text, character varying, integer, text, integer, integer, integer)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnrekvid alias for $2;
	tnaaid alias for $3;
	tndoklausid alias for $4;
	tdkpv alias for $5;
	tdmaksepaev alias for $6;
	tcnumber alias for $7;
	ttselg alias for $8;
	tcviitenr alias for $9;
	tnopt alias for $10;
	ttmuud alias for $11;
	tnarvid alias for $12;
	tndoktyyp alias for $13;
	tndokid alias for $14;
	lnmkId int;
	lnId int; 
	lrCurRec record;
begin

if tnId = 0 then
	-- uus kiri
	insert into mk (rekvid,aaid,doklausid,kpv,maksepaev,number,selg,viitenr,opt,muud,arvid,doktyyp,dokid) 
		values (tnrekvid,tnaaid,tndoklausid,tdkpv,tdmaksepaev,tcnumber,ttselg,tcviitenr,tnopt,ttmuud,tnarvid,tndoktyyp,tndokid);

	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
	--	raise notice 'lnId %',lnId;
		lnmkId:= cast(CURRVAL('public.mk_id_seq') as int4);
	--	raise notice 'lnaastaId %',lnaastaId;
	else
		lnmkId = 0;
	end if;

	if lnmkId = 0 then
		raise exception 'Viga:%','Ei saa lisada kiri';
	end if;



else
	-- muuda 
	select * into lrCurRec from mk where id = tnId;
	if lrCurRec.rekvid <> tnrekvid or  lrCurRec.aaid <> tnaaid or lrCurRec.doklausid <> tndoklausid or lrCurRec.kpv <> tdkpv or lrCurRec.maksepaev <> tdmaksepaev or lrCurRec.number <> tcnumber or lrCurRec.selg <> ttselg or lrCurRec.viitenr <> tcviitenr or lrCurRec.opt <> tnopt or ifnull(lrCurRec.muud,space(1)) <> ifnull(ttmuud,space(1)) or lrCurRec.arvid <> tnarvid or lrCurRec.doktyyp <> tndoktyyp or lrCurRec.dokid <> tndokid then 
	update mk set 
		rekvid = tnrekvid,
		aaid = tnaaid,
		doklausid = tndoklausid,
		kpv = tdkpv,
		maksepaev = tdmaksepaev,
		number = tcnumber,
		selg = ttselg,
		viitenr = tcviitenr,
		opt = tnopt,
		muud = ttmuud,
		arvid = tnarvid,
		doktyyp = tndoktyyp,
		dokid = tndokid
	where id = tnId;
	end if;
	lnmkId := tnId;
end if;

         return  lnmkId;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_mk(integer, integer, integer, integer, date, date, character varying, text, character varying, integer, text, integer, integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_mk(integer, integer, integer, integer, date, date, character varying, text, character varying, integer, text, integer, integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_mk(integer, integer, integer, integer, date, date, character varying, text, character varying, integer, text, integer, integer, integer) TO dbpeakasutaja;


CREATE OR REPLACE FUNCTION sp_salvesta_mk1(integer, integer, integer, integer, numeric, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying,numeric,integer)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnparentid alias for $2;
	tnasutusid alias for $3;
	tnnomid alias for $4;
	tnsumma alias for $5;
	tcaa alias for $6;
	tcpank alias for $7;
	tckood1 alias for $8;
	tckood2 alias for $9;
	tckood3 alias for $10;
	tckood4 alias for $11;
	tckood5 alias for $12;
	tckonto alias for $13;
	tctp alias for $14;
	tctunnus alias for $15;
	tcValuuta alias for $16;
	tnKuurs alias for $17;
	tnOpt alias for $18;
	lnmk1Id int;
	lnId int; 
	lrCurRec record;
	v_dokvaluuta record;
begin

if tnId = 0 then
	-- uus kiri
	insert into mk1 (parentid,asutusid,nomid,summa,aa,pank,kood1,kood2,kood3,kood4,kood5,konto,tp,tunnus) 
		values (tnparentid,tnasutusid,tnnomid,tnsumma,tcaa,tcpank,tckood1,tckood2,tckood3,tckood4,tckood5,tckonto,tctp,tctunnus);


	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
		lnmk1Id:= cast(CURRVAL('public.mk1_id_seq') as int4);
	else
		lnmk1Id = 0;
	end if;

	if lnmk1Id = 0 then
		raise exception 'Viga:%','Ei saa lisada kiri';
	end if;

	-- valuuta

	insert into dokvaluuta1 (dokliik,dokid, valuuta, kuurs) 
		values (4, lnmk1Id,tcValuuta, tnKuurs);


else
	-- muuda 
	select * into lrCurRec from mk1 where id = tnId;
	if  lrCurRec.asutusid <> tnasutusid or lrCurRec.nomid <> tnnomid or lrCurRec.summa <> tnsumma or lrCurRec.aa <> tcaa or lrCurRec.pank <> tcpank 
		or lrCurRec.kood1 <> tckood1 or lrCurRec.kood2 <> tckood2 or lrCurRec.kood3 <> tckood3 or lrCurRec.kood4 <> tckood4 
		or lrCurRec.kood5 <> tckood5 or lrCurRec.konto <> tckonto or lrCurRec.tp <> tctp or lrCurRec.tunnus <> tctunnus then 
	update mk1 set 
		asutusid = tnasutusid,
		nomid = tnnomid,
		summa = tnsumma,
		aa = tcaa,
		pank = tcpank,
		kood1 = tckood1,
		kood2 = tckood2,
		kood3 = tckood3,
		kood4 = tckood4,
		kood5 = tckood5,
		konto = tckonto,
		tp = tctp,
		tunnus = tctunnus
	where id = tnId;
	end if;
	lnmk1Id := tnId;

	-- valuuta
	if (select count(id) from dokvaluuta1 where dokliik = 4 and dokid = lnmk1Id) = 0 then

		insert into dokvaluuta1 (dokliik, dokid, valuuta, kuurs) 
			values (4, lnmk1Id,tcValuuta, tnKuurs);
	else
		select * into v_dokvaluuta from dokvaluuta1 where dokliik = 4 and dokid = lnmk1Id ;

		if tcValuuta <> v_dokvaluuta.valuuta or tnKuurs <> v_dokvaluuta.kuurs then

			update dokvaluuta1 set valuuta = tcValuuta, kuurs = tnKuurs where id = v_dokvaluuta.id;
			
		end if;
	
	end if;

	
end if;
if tnOpt = 1 then
	-- lisa operatsioonid
	perform gen_lausend_mk(tnParentId);
end if;


         return  lnmk1Id;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_mk1(integer, integer, integer, integer, numeric, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying,numeric,integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_mk1(integer, integer, integer, integer, numeric, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying,numeric,integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_mk1(integer, integer, integer, integer, numeric, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying,numeric,integer) TO dbpeakasutaja;


CREATE OR REPLACE FUNCTION sp_salvesta_nomenklatuur(integer, integer, integer, character, character, character, character, numeric, text, numeric, numeric, text, character, numeric)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnrekvid alias for $2;
	tndoklausid alias for $3;
	tcdok alias for $4;
	tckood alias for $5;
	tcnimetus alias for $6;
	tcuhik alias for $7;
	tnhind alias for $8;
	ttmuud alias for $9;
	tnulehind alias for $10;
	tnkogus alias for $11;
	ttformula alias for $12;
	tcValuuta alias for $13;
	tnKuurs alias for $14;
	lnnomenklatuurId int;
	v_dokvaluuta record;
	lnId int; 
	lrCurRec record;
begin

if tnId = 0 then
	-- uus kiri
	insert into nomenklatuur (rekvid,doklausid,dok,kood,nimetus,uhik,hind,muud,ulehind,kogus,formula) 
		values (tnrekvid,tndoklausid,tcdok,tckood,tcnimetus,tcuhik,tnhind,ttmuud,tnulehind,tnkogus,ttformula);

	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
	--	raise notice 'lnId %',lnId;
		lnnomenklatuurId:= cast(CURRVAL('public.nomenklatuur_id_seq') as int4);
	--	raise notice 'lnaastaId %',lnaastaId;
	else
		lnnomenklatuurId = 0;
	end if;

	if lnnomenklatuurId = 0 then
		raise exception ':%','Ei saa lisada kiri';
	end if;

	-- valuuta

	insert into dokvaluuta1 (dokliik,dokid, valuuta, kuurs) 
		values (17, lnnomenklatuurId,tcValuuta, tnKuurs);



else
	-- muuda 
	select * into lrCurRec from nomenklatuur where id = tnId;
	if lrCurRec.rekvid <> tnrekvid or lrCurRec.doklausid <> tndoklausid or lrCurRec.dok <> tcdok or lrCurRec.kood <> tckood or lrCurRec.nimetus <> tcnimetus or lrCurRec.uhik <> tcuhik or lrCurRec.hind <> tnhind or ifnull(lrCurRec.muud,space(1)) <> ifnull(ttmuud,space(1)) or lrCurRec.ulehind <> tnulehind or lrCurRec.kogus <> tnkogus or lrCurRec.formula <> ttformula then 
	update nomenklatuur set 
		rekvid = tnrekvid,
		doklausid = tndoklausid,
		dok = tcdok,
		kood = tckood,
		nimetus = tcnimetus,
		uhik = tcuhik,
		hind = tnhind,
		muud = ttmuud,
		ulehind = tnulehind,
		kogus = tnkogus,
		formula = ttformula
	where id = tnId;
	end if;
	lnnomenklatuurId := tnId;

	-- valuuta
	if (select count(id) from dokvaluuta1 where dokliik = 17 and dokid = lnnomenklatuurId) = 0 then

		insert into dokvaluuta1 (dokliik, dokid, valuuta, kuurs) 
			values (17, lnnomenklatuurId,tcValuuta, tnKuurs);
	else
		select * into v_dokvaluuta from dokvaluuta1 where dokliik = 17 and dokid = lnnomenklatuurId ;

		if tcValuuta <> v_dokvaluuta.valuuta or tnKuurs <> v_dokvaluuta.kuurs then

			update dokvaluuta1 set valuuta = tcValuuta, kuurs = tnKuurs where id = v_dokvaluuta.id;
			
		end if;
	
	end if;
			

	
end if;

         return  lnnomenklatuurId;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_nomenklatuur(integer, integer, integer, character, character, character, character, numeric, text, numeric, numeric, text, character, numeric) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_nomenklatuur(integer, integer, integer, character, character, character, character, numeric, text, numeric, numeric, text,character, numeric) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_nomenklatuur(integer, integer, integer, character, character, character, character, numeric, text, numeric, numeric, text,character, numeric) TO dbpeakasutaja;



CREATE OR REPLACE FUNCTION sp_salvesta_palk_kaart(integer, integer, integer, integer, numeric, integer, integer, integer, integer, text, integer, integer, character varying, numeric)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnparentid alias for $2;
	tnlepingid alias for $3;
	tnlibid alias for $4;
	tnsumma alias for $5;
	tnpercent_ alias for $6;
	tntulumaks alias for $7;
	tntulumaar alias for $8;
	tnstatus alias for $9;
	ttmuud alias for $10;
	tnalimentid alias for $11;
	tntunnusid alias for $12;
	tcValuuta alias for $13;
	tnKuurs alias for $14;
	lnpalk_kaartId int;
	lnId int; 
	lrCurRec record;
	v_dokvaluuta record;
begin

if tnId = 0 then
	-- uus kiri
	insert into palk_kaart (parentid,lepingid,libid,summa,percent_,tulumaks,tulumaar,status,muud,alimentid,tunnusid) 
		values (tnparentid,tnlepingid,tnlibid,tnsumma,tnpercent_,tntulumaks,tntulumaar,tnstatus,ttmuud,tnalimentid,tntunnusid);


	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
		lnpalk_kaartId:= cast(CURRVAL('public.palk_kaart_id_seq') as int4);
	else
		lnpalk_kaartId = 0;
	end if;

	if lnpalk_kaartId = 0 then
		raise exception ':%','Ei saa lisada kiri';
	end if;

	-- valuuta

	if tnKuurs <> 0  then
		insert into dokvaluuta1 (dokid, dokliik, valuuta, kuurs) 
			values (lnpalk_kaartId,20,tcValuuta, tnKuurs);
	end if;


else
	-- muuda 
	select * into lrCurRec from palk_kaart where id = tnId;
	if lrCurRec.parentid <> tnparentid or lrCurRec.lepingid <> tnlepingid or lrCurRec.libid <> tnlibid or lrCurRec.summa <> tnsumma 
		or lrCurRec.percent_ <> tnpercent_ or lrCurRec.tulumaks <> tntulumaks or lrCurRec.tulumaar <> tntulumaar or lrCurRec.status <> tnstatus 
		or ifnull(lrCurRec.muud,space(1)) <> ifnull(ttmuud,space(1)) or lrCurRec.alimentid <> tnalimentid or lrCurRec.tunnusid <> tntunnusid then 
	update palk_kaart set 
		parentid = tnparentid,
		lepingid = tnlepingid,
		libid = tnlibid,
		summa = tnsumma,
		percent_ = tnpercent_,
		tulumaks = tntulumaks,
		tulumaar = tntulumaar,
		status = tnstatus,
		muud = ttmuud,
		alimentid = tnalimentid,
		tunnusid = tntunnusid
	where id = tnId;
	end if;
	lnpalk_kaartId := tnId;


	-- valuuta
	
	if tnKuurs <> 0 and  (select count(id) from dokvaluuta1 where dokliik = 20 and dokid = lnpalk_kaartId) = 0 then

		insert into dokvaluuta1 (dokliik, dokid, valuuta, kuurs) 
			values (20, lnpalk_kaartId,tcValuuta, tnKuurs);
	else
		select * into v_dokvaluuta from dokvaluuta1 where dokliik = 20 and dokid = lnpalk_kaartId ;

		if tcValuuta <> v_dokvaluuta.valuuta or tnKuurs <> v_dokvaluuta.kuurs then

			update dokvaluuta1 set valuuta = tcValuuta, kuurs = tnKuurs where id = v_dokvaluuta.id;
						
		end if;
	
	end if;

end if;

         return  lnpalk_kaartId;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_palk_kaart(integer, integer, integer, integer, numeric, integer, integer, integer, integer, text, integer, integer,character varying, numeric) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_palk_kaart(integer, integer, integer, integer, numeric, integer, integer, integer, integer, text, integer, integer,character varying, numeric) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_palk_kaart(integer, integer, integer, integer, numeric, integer, integer, integer, integer, text, integer, integer,character varying, numeric) TO dbpeakasutaja;


CREATE OR REPLACE FUNCTION sp_salvesta_palk_oper(integer, integer, integer, integer, date, numeric, integer, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying,character varying, numeric,character varying )
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnrekvid alias for $2;
	tnlibid alias for $3;
	tnlepingid alias for $4;
	tdkpv alias for $5;
	tnsumma alias for $6;
	tndoklausid alias for $7;
	ttmuud alias for $8;
	tckood1 alias for $9;
	tckood2 alias for $10;
	tckood3 alias for $11;
	tckood4 alias for $12;
	tckood5 alias for $13;
	tckonto alias for $14;
	tctp alias for $15;
	tctunnus alias for $16;
	tcValuuta alias for $17;
	tnKuurs alias for $18;
	tcProj alias for $19;
	lnpalk_operId int;
	lnId int; 
	lrCurRec record;
	v_dokvaluuta record;
begin

if tnId = 0 then
	-- uus kiri
	insert into palk_oper (rekvid,libid,lepingid,kpv,summa,doklausid,muud,kood1,kood2,kood3,kood4,kood5,konto,tp,tunnus, proj) 
		values (tnrekvid,tnlibid,tnlepingid,tdkpv,tnsumma,tndoklausid,ttmuud,tckood1,tckood2,tckood3,tckood4,tckood5,tckonto,tctp,tctunnus,tcProj);


	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
		lnpalk_operId:= cast(CURRVAL('public.palk_oper_id_seq') as int4);
	else
		lnpalk_operId = 0;
	end if;

	if lnpalk_operId = 0 then
		raise exception ':%','Ei saa lisada kiri';
	end if;

			-- valuuta

	insert into dokvaluuta1 (dokid, dokliik, valuuta, kuurs) 
		values (lnpalk_operId,12,tcValuuta, tnKuurs);




else
	-- muuda 
	select * into lrCurRec from palk_oper where id = tnId;
	if  lrCurRec.libid <> tnlibid or lrCurRec.lepingid <> tnlepingid or lrCurRec.kpv <> tdkpv or lrCurRec.summa <> tnsumma or 
		lrCurRec.doklausid <> tndoklausid or ifnull(lrCurRec.muud,space(1)) <> ifnull(ttmuud,space(1)) or lrCurRec.kood1 <> tckood1 or 
		lrCurRec.kood2 <> tckood2 or lrCurRec.kood3 <> tckood3 or lrCurRec.kood4 <> tckood4 or lrCurRec.kood5 <> tckood5 or 
		lrCurRec.konto <> tckonto or lrCurRec.tp <> tctp or lrCurRec.tunnus <> tctunnus or ifnull(lrCurRec.proj,'tuhi') <> tcProj then 

	update palk_oper set 
		libid = tnlibid,
		lepingid = tnlepingid,
		kpv = tdkpv,
		summa = tnsumma,
		doklausid = tndoklausid,
		muud = ttmuud,
		kood1 = tckood1,
		kood2 = tckood2,
		kood3 = tckood3,
		kood4 = tckood4,
		kood5 = tckood5,
		konto = tckonto,
		tp = tctp,
		proj = tcProj,
		tunnus = tctunnus
	where id = tnId;
	end if;
	lnpalk_operId := tnId;


	-- valuuta
	if (select count(id) from dokvaluuta1 where dokliik = 12 and dokid =lnpalk_operId ) = 0 then

		insert into dokvaluuta1 (dokliik, dokid, valuuta, kuurs) 
			values (12, lnpalk_operId ,tcValuuta, tnKuurs);
	else
		select * into v_dokvaluuta from dokvaluuta1 where dokliik = 12 and dokid = lnpalk_operId  ;

		if tcValuuta <> v_dokvaluuta.valuuta or tnKuurs <> v_dokvaluuta.kuurs then

			update dokvaluuta1 set valuuta = tcValuuta, kuurs = tnKuurs where id = v_dokvaluuta.id;

						
		end if;
	
	end if;


end if;

	if lnPalk_operId > 0 then
		perform gen_lausend_palk(lnpalk_operId);
	end if;
         return  lnpalk_operId;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;

ALTER FUNCTION sp_salvesta_palk_oper(integer, integer, integer, integer, date, numeric, integer, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying,character varying, numeric,character varying ) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_palk_oper(integer, integer, integer, integer, date, numeric, integer, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying,character varying, numeric,character varying ) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_palk_oper(integer, integer, integer, integer, date, numeric, integer, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying,character varying, numeric,character varying ) TO dbpeakasutaja;


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


	lnParentId = sp_salvesta_library(tnId, tnRekvId, tcKood, tcNimetus, 'POHIVARA', ttSelg, 0, 0, 0, 0, 0);

	if lnParentId = 0 then
		raise notice 'Viga, ei saa salvesta dokument';
		return 0;
	end if;


	select * into lrCurRec from pv_kaart where id = tnId;
	if  lrCurRec.vastisikid <> tnvastisikid or lrCurRec.soetkpv <> tdsoetkpv or lrCurRec.kulum <> tnkulum 
		or lrCurRec.algkulum <> tnalgkulum or lrCurRec.gruppid <> tngruppid or lrCurRec.konto <> tckonto or lrCurRec.tunnus <> tntunnus 
		or ifnull(lrCurRec.muud,space(1)) <> ifnull(ttRentnik,space(1))  then 

		update pv_kaart set 
			vastisikid = tnvastisikid,
			soetkpv = tdsoetkpv,
			kulum = tnkulum,
			algkulum = tnalgkulum,
			gruppid = tngruppid,
			konto = tckonto,
			tunnus = tntunnus,
			muud = ttRentnik
		where id = tnId;
	end if;
	lnpv_kaartId := tnId;
end if;

         return  lnParentId;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_pv_kaart(integer, integer, date, numeric, numeric, integer, character varying, integer, text, text,character varying,character varying, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_pv_kaart(integer, integer, date, numeric, numeric, integer, character varying, integer, text, text,character varying,character varying, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_pv_kaart(integer, integer, date, numeric, numeric, integer, character varying, integer, text, text,character varying,character varying, integer) TO dbpeakasutaja;



CREATE OR REPLACE FUNCTION sp_salvesta_pv_oper(integer, integer, integer, integer, integer, date, numeric, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, character varying, character varying,character varying,numeric)
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

         return  lnpv_operId;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_pv_oper(integer, integer, integer, integer, integer, date, numeric, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, character varying, character varying,character varying,numeric) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_pv_oper(integer, integer, integer, integer, integer, date, numeric, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, character varying, character varying,character varying,numeric) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_pv_oper(integer, integer, integer, integer, integer, date, numeric, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, character varying, character varying,character varying,numeric) TO dbpeakasutaja;



CREATE OR REPLACE FUNCTION sp_salvesta_tooleping(integer, integer, integer, integer, date, date, integer, numeric, integer, integer, integer, integer, integer, integer, character varying, text, integer, integer, character varying, date, character varying, numeric)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnparentid alias for $2;
	tnosakondid alias for $3;
	tnametid alias for $4;
	tdalgab alias for $5;
	tdlopp alias for $6;
	tntoopaev alias for $7;
	tnpalk alias for $8;
	tnpalgamaar alias for $9;
	tnpohikoht alias for $10;
	tnkoormus alias for $11;
	tnametnik alias for $12;
	tntasuliik alias for $13;
	tnpank alias for $14;
	tcaa alias for $15;
	ttmuud alias for $16;
	tnrekvid alias for $17;
	tnresident alias for $18;
	tcriik alias for $19;
	tdtoend alias for $20;
	tcValuuta alias for $21;
	tnKuurs alias for $22;
	lntoolepingId int;
	lnId int; 
	lrCurRec record;
	v_dokvaluuta record;
begin

if tnId = 0 then
	-- uus kiri
	insert into tooleping (parentid,osakondid,ametid,algab,lopp,toopaev,palk,palgamaar,pohikoht,koormus,ametnik,tasuliik,pank,aa,muud,rekvid,resident,riik,toend) 
		values (tnparentid,tnosakondid,tnametid,tdalgab,tdlopp,tntoopaev,tnpalk,tnpalgamaar,tnpohikoht,tnkoormus,tnametnik,tntasuliik,tnpank,tcaa,ttmuud,tnrekvid,tnresident,tcriik,tdtoend);

	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
	--	raise notice 'lnId %',lnId;
		lntoolepingId:= cast(CURRVAL('public.tooleping_id_seq') as int4);
	--	raise notice 'lnaastaId %',lnaastaId;
	else
		lntoolepingId = 0;
	end if;

	if lntoolepingId = 0 then
		raise exception ':%','Ei saa lisada kiri';
	end if;

	-- valuuta

	insert into dokvaluuta1 (dokid, dokliik, valuuta, kuurs) 
		values (lntoolepingId,19,tcValuuta, tnKuurs);


else
	-- muuda 
	select * into lrCurRec from tooleping where id = tnId;
	if lrCurRec.parentid <> tnparentid or lrCurRec.osakondid <> tnosakondid or lrCurRec.ametid <> tnametid or lrCurRec.algab <> tdalgab 
		or ifnull(lrCurRec.lopp,date(1900,01,01)) <> ifnull(tdlopp,date(1900,01,01)) or lrCurRec.toopaev <> tntoopaev or lrCurRec.palk <> tnpalk 
		or lrCurRec.palgamaar <> tnpalgamaar or lrCurRec.pohikoht <> tnpohikoht or lrCurRec.koormus <> tnkoormus or lrCurRec.ametnik <> tnametnik 
		or lrCurRec.tasuliik <> tntasuliik or lrCurRec.pank <> tnpank or lrCurRec.aa <> tcaa or ifnull(lrCurRec.muud,space(1)) <> ifnull(ttmuud,space(1)) 
		or lrCurRec.rekvid <> tnrekvid or lrCurRec.resident <> tnresident or lrCurRec.riik <> tcriik 
		or ifnull(lrCurRec.toend,date(1900,01,01)) <> ifnull(tdtoend,date(1900,01,01)) then 

	update tooleping set 
		parentid = tnparentid,
		osakondid = tnosakondid,
		ametid = tnametid,
		algab = tdalgab,
		lopp = tdlopp,
		toopaev = tntoopaev,
		palk = tnpalk,
		palgamaar = tnpalgamaar,
		pohikoht = tnpohikoht,
		koormus = tnkoormus,
		ametnik = tnametnik,
		tasuliik = tntasuliik,
		pank = tnpank,
		aa = tcaa,
		muud = ttmuud,
		rekvid = tnrekvid,
		resident = tnresident,
		riik = tcriik,
		toend = tdtoend		
	where id = tnId;
	end if;
	lntoolepingId := tnId;

	-- valuuta
	if (select count(id) from dokvaluuta1 where dokliik = 19 and dokid = lntoolepingId) = 0 then

		insert into dokvaluuta1 (dokliik, dokid, valuuta, kuurs) 
			values (19, lntoolepingId,tcValuuta, tnKuurs);
	else
		select * into v_dokvaluuta from dokvaluuta1 where dokliik = 19 and dokid = lntoolepingId ;

		if tcValuuta <> v_dokvaluuta.valuuta or tnKuurs <> v_dokvaluuta.kuurs then

			update dokvaluuta1 set valuuta = tcValuuta, kuurs = tnKuurs where id = v_dokvaluuta.id;
						
		end if;
	
	end if;


	
end if;

         return  lntoolepingId;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_tooleping(integer, integer, integer, integer, date, date, integer, numeric, integer, integer, integer, integer, integer, integer, character varying, text, integer, integer, character varying, date, character varying, numeric) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_tooleping(integer, integer, integer, integer, date, date, integer, numeric, integer, integer, integer, integer, integer, integer, character varying, text, integer, integer, character varying, date, character varying, numeric) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_tooleping(integer, integer, integer, integer, date, date, integer, numeric, integer, integer, integer, integer, integer, integer, character varying, text, integer, integer, character varying, date, character varying, numeric) TO dbpeakasutaja;


CREATE OR REPLACE FUNCTION sp_salvesta_valuuta1(integer, integer, numeric, date, date, text)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnParentId alias for $2;
	tnKuurs alias for $3;
	tdAlates alias for $4;
	tdKuni alias for $5;
	ttMuud alias for $6;

	lnId int; 
	lrCurRec record;
begin
/*

CREATE TABLE valuuta1
(
  id serial NOT NULL,
  parentid integer NOT NULL,
  kuurs numeric(14,4) DEFAULT 1,
  alates date NOT NULL,
  kuni date NOT NULL,
  muud text,
  CONSTRAINT valuuta1_pkey PRIMARY KEY (id)
)
WIT
*/


if tnId = 0 then
	-- uus kiri
	insert into valuuta1 (parentid, kuurs, alates, kuni, muud) 
		values (tnParentId,tnKuurs,ifnull(tdAlates,date()-3600),ifnull(tdKuni,date()+3600),ttMuud);

	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
		raise notice 'lnId %',lnId;
		lnId:= cast(CURRVAL('public.valuuta1_id_seq') as int4);
		raise notice 'lnId %',lnId;
	else
		lnId = 0;
	end if;
else
	-- muuda 
	select * into lrCurRec from valuuta1 where id = tnId;
	if lrCurRec.parentid <> tnParentid or lrCurRec.kuurs <> tnkuurs or lrCurRec.alates <> tdAlates or lrCurRec.kuni <> tdKuni or ifnull(lrCurRec.muud,'null') <> ifnull(ttMuud,'null') then 
	update valuuta1 set 
		parentid = tnParentId,
		kuurs = tnKuurs,
		alates = tdAlates,
		kuni = tdKuni,
		muud = ttMuud
	where id = tnId;
	end if;
	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
		raise notice 'lnId %',lnId;
		lnId = tnid;
	else
		lnId = 0;
	end if;
end if;

         return  lnId;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE;
  
ALTER FUNCTION sp_salvesta_valuuta1(integer, integer, numeric, date, date, text) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_valuuta1(integer, integer, numeric, date, date, text) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_valuuta1(integer, integer, numeric, date, date, text) TO dbpeakasutaja;



CREATE OR REPLACE FUNCTION sp_subkontod_report(character varying, integer, date, date, integer, character varying, integer, integer)
  RETURNS character varying AS
$BODY$
DECLARE tcKonto alias for $1;
	tnrekvid alias for $2;
	tdKpv1 alias for $3;
	tdKpv2 alias for $4;
	tnAsutus alias for $5;
	tcTunnus alias for $6;
	tnOpt alias for $7;
	tnSvod alias for $8;
	lcReturn varchar;
	lnId int;
	lnDb numeric (14,2);
	lnKr numeric (14,2);
	lnAlg numeric (14,2);
	lnLopp numeric (14,2);
	lnAsutusId1 int;
	lnAsutusId2 int;
	v_kaibed record;
	v_saldo record;
	v_account record;
	v_tunnus record;
	lnCount int;


begin


	if tnAsutus > 0 then
		lnAsutusId1 := tnAsutus;
		lnAsutusId2 := tnAsutus;
	else
		lnAsutusId1 := 0;
		lnAsutusId2 := 99999999;
	end if;

	select count(*) into lnCount from pg_stat_all_tables where UPPER(relname) = 'TMP_SUBKONTOD_REPORT';
	if ifnull(lnCount,0) < 1 then

		create table tmp_subkontod_report (id serial, asutusId int default 0, Asutus varchar(254) default space(1), regkood varchar(20) default space(1), 
			aadress text default space(1), konto varchar(20) default space(1), korkonto varchar(20) default space(1),
			tunnus varchar(20) default space(1), dokkpv date default date(),
			algjaak numeric (14,2) default 0, db numeric(14,2) default 0, kr numeric(14,2) default 0, loppjaak numeric(14,2) default 0,
			kood1 varchar(20) default space(1), kood2 varchar(20) default space(1), kood3 varchar(20) default space(1),
			kood4 varchar(20) default space(1), kood5 varchar(20) default space(1), dok varchar(120) default space(1),
			lausend int default 0, 
			timestamp varchar(20) , kpv date default date(), rekvid int )  ;


		GRANT ALL ON TABLE tmp_subkontod_report TO GROUP public;
	else
		delete from tmp_subkontod_report where kpv < date() ;

	end if;

	lcreturn := to_char(now(), 'YYYYMMDDMISS');

-- lisatud 27/08/2008 kondaruanne koostamine

if (select count(*) from pg_stat_all_tables where UPPER(relname) = 'TMPREKV')  > 0 then
	delete from tmpRekv;
--	truncate TABLE tmpRekv;
	insert into tmpRekv
		SELECT id, parentid, fnc_get_asutuse_staatus(rekv.id, tnrekvid)::int as tase FROM rekv;
else
	CREATE TABLE tmpRekv AS
		SELECT id, parentid, fnc_get_asutuse_staatus(rekv.id, tnrekvid)::int as tase FROM rekv;
		GRANT ALL ON TABLE tmpRekv TO GROUP public;

END IF;

if tnSvod = 1 then
	delete from tmpRekv where tase < 3;

else
	delete from tmpRekv where tase in (0,1,2,4);
end if;




	-- matrix of subkontod

	if tnOpt < 5 then

		insert into tmp_subkontod_report (konto, asutusId,  regkood , Asutus, Aadress, algjaak, timestamp, rekvid )  
		select kontod.kood, asutus.id, asutus.regkood, asutus.nimetus as asutus, asutus.aadress, sum(subkonto.algsaldo) ,
		lcReturn, tnRekvId 
		from library kontod inner join subkonto  on (subkonto.kontoid = kontod.id and kontod.library = 'KONTOD') 
		inner join asutus on asutus.id = subkonto.asutusId
		where kontod.kood like tcKonto 
		and subkonto.rekvid in (select id from tmprekv)
		and subkonto.asutusId >= lnAsutusId1 and subkonto.asutusId <= lnAsutusid2 
		group by   kontod.kood,asutus.id, asutus.regkood, asutus.nimetus, asutus.aadress;

	else

		insert into tmp_subkontod_report (konto, asutusId,  regkood , Asutus, Aadress, algjaak, timestamp, rekvid, subrekvid )  
		select kontod.kood, asutus.id, asutus.regkood, asutus.nimetus as asutus, asutus.aadress, sum(subkonto.algsaldo) ,
		lcReturn, tnRekvId,subkonto.rekvid from library kontod inner join subkonto  on (subkonto.kontoid = kontod.id and kontod.library = 'KONTOD') 
		inner join asutus on asutus.id = subkonto.asutusId
		inner join tmprekv on subkonto.rekvId = tmprekv.id
		where (kontod.kood like '102%' or kontod.kood like '103%' or kontod.kood like '201%' or kontod.kood like '202%' or kontod.kood like '203%') 
		and subkonto.rekvid in (select id from tmprekv)
		and subkonto.asutusId >= lnAsutusId1 and subkonto.asutusId <= lnAsutusid2 
		group by  kontod.kood, subkonto.rekvid, asutus.id, asutus.regkood, asutus.nimetus, asutus.aadress;


	end if;


	if tnOpt = 1 then
		-- kaibeasutus andmik
		for v_account in 
			select konto, asutusId from tmp_subkontod_report where timestamp = lcreturn and rekvid = tnRekvId
		loop

		-- kaibed
			select sum(case when ltrim(rtrim(deebet)) = ltrim(rtrim(v_account.konto)) then (summa*ifnull(dokvaluuta1.kuurs,1)) else 0::numeric(14,2) end) as db, 
				sum(case when ltrim(rtrim(kreedit)) = ltrim(rtrim(v_account.konto)) then (summa*inull(dokvaluuta1.kuurs,1)) else 0::numeric(14,2) end) as kr into v_kaibed 
				from journal1 left outer join dokvaluuta1 on (dokvaluuta1.dokid = journal1.id and dokvaluuta1.dokliik = 1)
				where (ltrim(rtrim(deebet)) = ltrim(rtrim(v_account.konto)) or ltrim(rtrim(kreedit)) = ltrim(rtrim(v_account.konto)))
				and tunnus like tcTunnus
				and parentId in (select journal.id from journal inner join tmprekv on journal.rekvId = tmprekv.id
				where kpv >= tdKpv1 and kpv <= tdKpv2  and asutusId = v_account.asutusid);

			-- algkaibed

			select sum(case when ltrim(rtrim(deebet)) = ltrim(rtrim(v_account.konto)) then (summa*ifnull(dokvaluuta1.kuurs,1)) else 0::numeric(14,2)  end) as db, 
				sum(case when ltrim(rtrim(kreedit)) = ltrim(rtrim(v_account.konto)) then (summa*ifnull(dokvaluuta1.kuurs,1)) else 0::numeric(14,2) end ) as kr into v_saldo
				from journal1  left outer join dokvaluuta1 on (dokvaluuta1.dokid = journal1.id and dokvaluuta1.dokliik = 1)
				where (ltrim(rtrim(deebet)) = ltrim(rtrim(v_account.konto)) or ltrim(rtrim(kreedit)) = ltrim(rtrim(v_account.konto)))
				and tunnus like tcTunnus
				and parentId in (select journal.id from journal	inner join tmprekv on journal.rekvId = tmprekv.id 
				where journal.kpv < tdKpv1  
				 and JOURNAL.asutusId = v_account.asutusid);


			select algJaak into lnAlg from tmp_subkontod_report 
				where timestamp = lcreturn 
				and rekvid = tnRekvId
				and ltrim(rtrim(konto)) = ltrim(rtrim(v_account.konto)) and asutusId = v_account.asutusId;

			lnAlg := ifnull(lnAlg,0) + ifnull(v_saldo.db,0) - ifnull(v_saldo.kr,0);
			lnLopp := lnAlg + ifnull(v_kaibed.db,0) - ifnull(v_kaibed.kr,0);
	

			update 	tmp_subkontod_report set db = ifnull(v_kaibed.db,0),
				kr = ifnull(v_kaibed.kr,0),
				algjaak = lnAlg,
				loppjaak = lnLopp
				where timestamp = lcreturn 
				and rekvid = tnRekvId
				and ltrim(rtrim(konto)) = ltrim(rtrim(v_account.konto)) and asutusId = v_account.asutusId;

		end loop;
		delete from tmp_subkontod_report where algjaak = 0 and db = 0 and kr = 0 and timestamp = lcreturn and rekvid = tnRekvId;

	end if;


	if tnOpt = 2 then
		-- konto andmik
		for v_account in 
			select konto, asutusId from tmp_subkontod_report where timestamp = lcreturn and rekvid = tnRekvId
		loop

-- kanded deebet
-- muudetud 16/02/2005
	insert into tmp_subkontod_report (dokkpv,konto, asutusId,  regkood , Asutus, Aadress, db, kr, korkonto, dok, kood1, kood2, kood3, kood4, 
	kood5, lausend, timestamp, rekvid, subrekvid, subrekvnimi )  
	select journal.kpv, v_account.konto, asutus.id, asutus.regkood, asutus.nimetus as asutus, asutus.aadress, 
		(journal1.summa*ifnull(dokvaluuta1.kuurs,1)), 0,
		journal1.kreedit, journal.dok, journal1.kood1, journal1.kood2, journal1.kood3, journal1.kood4, journal1.kood5,
		journalid.number, lcReturn, tnrekvid, rekv.Id, rekv.nimetus 
		from journal inner join journal1 on journal.id = journal1.parentid
		left outer join dokvaluuta1 on (dokvaluuta1.dokid = journal1.id and dokvaluuta1.dokliik = 1)
		inner join journalId on journal.id = journalId.journalId
		inner join asutus on asutus.id = journal.asutusId
		inner join tmprekv on journal.rekvId = tmprekv.id
		inner join rekv on journal.rekvid = rekv.id 
		where ltrim(rtrim(journal1.deebet)) = ltrim(rtrim(v_account.konto))
		and journal.asutusId = v_account.asutusId 
		and journal.kpv >= tdKpv1 and journal.kpv <= tdKpv2;

-- kanded kreedit
-- muudetud 16/02/2005
	insert into tmp_subkontod_report (dokkpv, konto, asutusId,  regkood , Asutus, Aadress, db, kr, korkonto, dok, kood1, kood2, kood3, kood4, 
	kood5, lausend, timestamp, rekvid, subrekvid, subrekvnimi )  
	select journal.kpv, v_account.konto, asutus.id, asutus.regkood, asutus.nimetus as asutus, asutus.aadress,
		0, (journal1.summa*ifnull(dokvaluuta1.kuurs,1)), 
		journal1.deebet, journal.dok, journal1.kood1, journal1.kood2, journal1.kood3, journal1.kood4, journal1.kood5,
		journalid.number, lcReturn, tnrekvId, rekv.id, rekv.nimetus 
		from journal inner join journal1 on journal.id = journal1.parentid
		left outer join dokvaluuta1 on (dokvaluuta1.dokid = journal1.id and dokvaluuta1.dokliik = 1)
		 inner join journalId on journal.id = journalId.journalId
		inner join asutus on asutus.id = journal.asutusId
		inner join tmprekv on journal.rekvId = tmprekv.id
		inner join rekv on journal.rekvid = rekv.id
		where ltrim(rtrim(journal1.kreedit)) = ltrim(rtrim(v_account.konto))
		and journal.asutusId = v_account.asutusid
		and journal.kpv >= tdKpv1 and journal.kpv <= tdKpv2;

-- algjaak
	select sum(case when ltrim(rtrim(deebet)) = ltrim(rtrim(v_account.konto)) then (summa*ifnull(dokvaluuta1.kuurs,1)) else 0::numeric(14,2)  end) as db, 
		sum(case when ltrim(rtrim(kreedit)) = ltrim(rtrim(v_account.konto)) then (summa*ifnull(dokvaluuta1.kuurs,1)) else 0::numeric(14,2) end ) as kr into v_saldo
		from journal1 left outer join dokvaluuta1 on (dokvaluuta1.dokid = journal1.id and dokvaluuta1.dokliik = 1)
		where (ltrim(rtrim(deebet)) = ltrim(rtrim(v_account.konto)) or ltrim(rtrim(kreedit)) = ltrim(rtrim(v_account.konto)))
		and tunnus like tcTunnus
		and parentId in (select journal.id from journal inner join tmprekv on journal.rekvId = tmprekv.id where kpv < tdKpv1  
		and asutusId = v_account.asutusid);

-- algjaak
	select sum(db) as db, sum(kr) as kr into v_kaibed from tmp_subkontod_report 
		where timestamp = lcreturn 
		and rekvid = tnRekvId
		and ltrim(rtrim(konto)) = ltrim(rtrim(v_account.konto)) and asutusId = v_account.asutusId;

	select algJaak into lnAlg from tmp_subkontod_report 
		where timestamp = lcreturn 
		and rekvid = tnRekvId
		and ltrim(rtrim(konto)) = ltrim(rtrim(v_account.konto)) and asutusId = v_account.asutusId;

	lnAlg := ifnull(lnAlg,0) + ifnull(v_saldo.db,0) - ifnull(v_saldo.kr,0);
	lnLopp := lnAlg + ifnull(v_kaibed.db,0) - ifnull(v_kaibed.kr,0);

	update 	tmp_subkontod_report set algjaak = lnAlg,
		loppjaak = lnLopp
		where timestamp = lcreturn 
		and rekvid = tnRekvId
		and ltrim(rtrim(konto)) = ltrim(rtrim(v_account.konto)) and asutusId = v_account.asutusId;
	end loop;

	delete from tmp_subkontod_report where algjaak = 0 and db = 0 and kr = 0 and timestamp = lcreturn and rekvid = tnRekvId;

	end if;

	if tnOpt = 3 then
		-- saldo andmik

		for v_account in 
			select konto, asutusId from tmp_subkontod_report where timestamp = lcreturn and rekvid = tnRekvId and konto like tcKonto

		loop
			select sum(case when ltrim(rtrim(deebet)) = ltrim(rtrim(v_account.konto)) then (summa*ifnull(dokvaluuta1.kuurs,1)) else 0::numeric(14,2)  end) as db, 
				sum(case when ltrim(rtrim(kreedit)) = ltrim(rtrim(v_account.konto)) then (summa*ifnull(dokvaluuta1.kuurs,1)) else 0::numeric(14,2) end ) as kr into v_saldo
				from journal1 left outer join dokvaluuta1 on (dokvaluuta1.dokid = journal1.id and dokvaluuta1.dokliik = 1)
				where (ltrim(rtrim(deebet)) = ltrim(rtrim(v_account.konto)) or ltrim(rtrim(kreedit)) = ltrim(rtrim(v_account.konto)))
				and tunnus like tcTunnus
				and parentId in (select journal.id from journal inner join tmprekv on journal.rekvId = tmprekv.id  
				where kpv <= tdKpv2 and asutusId = v_account.asutusid);

			select algJaak into lnAlg from tmp_subkontod_report 
				where timestamp = lcreturn 
				and rekvid = tnRekvId
				and ltrim(rtrim(konto)) = ltrim(rtrim(v_account.konto)) and asutusId = v_account.asutusId;

			lnAlg := ifnull(lnAlg,0) + ifnull(v_saldo.db,0) - ifnull(v_saldo.kr,0);



			update 	tmp_subkontod_report set algjaak = lnAlg
				where timestamp = lcreturn 
				and rekvid = tnRekvId
				and ltrim(rtrim(konto)) = ltrim(rtrim(v_account.konto)) and asutusId = v_account.asutusId;


		end loop;
		delete from tmp_subkontod_report where algjaak = 0  and timestamp = lcreturn and rekvid = tnRekvId;

	end if;


	if tnOpt = 4 then


		-- kaibeasutus andmik tunnuse järgi

		for v_account in 
			select konto, asutusId, asutus, regkood, aadress, algjaak from tmp_subkontod_report where timestamp = lcreturn and rekvid = tnRekvId

		loop

			-- kaibed

		for v_tunnus in 

			select sum(case when ltrim(rtrim(deebet)) = ltrim(rtrim(v_account.konto)) then (summa*ifnull(dokvaluuta1.kuurs,1)) else 0::numeric(14,2) end) as db, 
			sum(case when ltrim(rtrim(kreedit)) = ltrim(rtrim(v_account.konto)) then (summa*ifnull(dokvaluuta1.kuurs,1)) else 0::numeric(14,2) end) as kr,
			 ltrim(rtrim(tunnus)) as tunnus 
			from journal1 left outer join dokvaluuta1 on (dokvaluuta1.dokid = journal1.id and dokvaluuta1.dokliik = 1)
			where (ltrim(rtrim(deebet)) = ltrim(rtrim(v_account.konto)) or ltrim(rtrim(kreedit)) = ltrim(rtrim(v_account.konto)))
			and tunnus like tcTunnus
			and parentId in (select journal.id from journal inner join tmprekv on journal.rekvId = tmprekv.id 
			where kpv >= tdKpv1 and kpv <= tdKpv2 and asutusId = v_account.asutusid)
			group by ltrim(rtrim(tunnus))

		loop

			-- algkaibed
			select sum(case when ltrim(rtrim(deebet)) = ltrim(rtrim(v_account.konto)) then (summa*ifnull(dokvaluuta1.kuurs,1)) else 0::numeric(14,2)  end) as db, 
				sum(case when ltrim(rtrim(kreedit)) = ltrim(rtrim(v_account.konto)) then (summa*ifnull(dokvaluuta1.kuurs,1)) else 0::numeric(14,2) end ) as kr into v_saldo
				from journal1 left outer join dokvaluuta1 on (dokvaluuta1.dokid = journal1.id and dokvaluuta1.dokliik = 1)
				where (ltrim(rtrim(deebet)) = ltrim(rtrim(v_account.konto)) or ltrim(rtrim(kreedit)) = ltrim(rtrim(v_account.konto)))
				and tunnus =  v_tunnus.tunnus 
				and parentId in (select journal.id from journal inner join tmprekv on journal.rekvId = tmprekv.id where kpv < tdKpv1  
				and asutusId = v_account.asutusid);


			insert into tmp_subkontod_report (konto, tunnus, asutusId, regkood , Asutus, Aadress, db, kr, algjaak, loppjaak, timestamp, rekvid)
			values (v_account.konto,v_tunnus.tunnus, v_account.asutusId, v_account.regkood, v_account.asutus, v_account.aadress,
			ifnull(v_tunnus.db,0), ifnull(v_tunnus.kr,0), 
			v_account.algjaak + ifnull(v_saldo.db,0) - ifnull(v_saldo.kr,0),
			v_account.algjaak + ifnull(v_saldo.db,0) - ifnull(v_saldo.kr,0) + ifnull(v_tunnus.db,0) - ifnull(v_tunnus.kr,0),
			lcreturn , tnRekvId);

		end loop;

		end loop;

--		delete from tmp_subkontod_report where algjaak = 0 and db = 0 and kr = 0 and timestamp = lcreturn and rekvid = tnRekvId;


	end if;


	if tnOpt = 5 then
		-- saldokinnitus
		for v_account in 
			select distinct konto, asutusId from tmp_subkontod_report where timestamp = lcreturn and rekvid = tnRekvId and konto not in ('103701','103950')

		loop
			select sum(case when ltrim(rtrim(deebet)) = ltrim(rtrim(v_account.konto)) then (summa*ifnull(dokvaluuta1.kuurs,1)) else 0::numeric(14,2)  end) as db, 
				sum(case when ltrim(rtrim(kreedit)) = ltrim(rtrim(v_account.konto)) then (summa*ifnull(dokvaluuta1.kuurs,1)) else 0::numeric(14,2) end ) as kr into v_saldo
				from journal1 left outer join dokvaluuta1 on (dokvaluuta1.dokid = journal1.id and dokvaluuta1.dokliik = 1)
				where (ltrim(rtrim(deebet)) = ltrim(rtrim(v_account.konto)) or ltrim(rtrim(kreedit)) = ltrim(rtrim(v_account.konto)))
				and tunnus like tcTunnus
				and parentId in (select journal.id from journal inner join tmprekv on journal.rekvId = tmprekv.id  
				where kpv <= tdKpv2 and asutusId = v_account.asutusid);

			select algJaak into lnAlg from tmp_subkontod_report 
				where timestamp = lcreturn 
				and rekvid = tnRekvId
				and ltrim(rtrim(konto)) = ltrim(rtrim(v_account.konto)) and asutusId = v_account.asutusId;

			lnAlg := ifnull(lnAlg,0) + ifnull(v_saldo.db,0) - ifnull(v_saldo.kr,0);



			update 	tmp_subkontod_report set algjaak = lnAlg, db = v_saldo.db, kr = v_saldo.kr
				where timestamp = lcreturn 
				and rekvid = tnRekvId
				and ltrim(rtrim(konto)) = ltrim(rtrim(v_account.konto)) and asutusId = v_account.asutusId;


		end loop;

		if (select count(*) from tmp_subkontod_report where  timestamp = lcreturn and rekvid = tnRekvId and db = 0 and kr = 0 and algjaak <> 0) > 0 then
			-- meil on vaja ainult 1 kiri tesed kustutame
			select id into lnId from tmp_subkontod_report where  timestamp = lcreturn and rekvid = tnRekvId and db = 0 and kr = 0 and algjaak <> 0;
			delete from  tmp_subkontod_report where  timestamp = lcreturn and rekvid = tnRekvId and db = 0 and kr = 0 and algjaak <> 0 and id <> lnId;
		end if; 

		delete from tmp_subkontod_report where ifnull(algjaak,0) = 0 and ifnull(db,0) = 0 and ifnull(kr,0) = 0 and timestamp = lcreturn and rekvid = tnRekvId;

	end if;


	return LCRETURN;

end;



$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_subkontod_report(character varying, integer, date, date, integer, character varying, integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_subkontod_report(character varying, integer, date, date, integer, character varying, integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_subkontod_report(character varying, integer, date, date, integer, character varying, integer, integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION sp_subkontod_report(character varying, integer, date, date, integer, character varying, integer, integer) TO dbvaatleja;


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
				where journal1.parentid = tnDokId and kreedit = qryArv.konto;
			else
				select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnTasuSumma 
				from journal1 left outer join dokvaluuta1 on (dokvaluuta1.dokid = journal1.id and dokvaluuta1.dokliik = 1) 
				where journal1.parentid = tnDokId and deebet = qryArv.konto;
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



CREATE OR REPLACE FUNCTION sp_update_palk_jaak(date, date, integer, integer)
  RETURNS integer AS
$BODY$
declare
	tdKpv1 alias for $1;
	tdKpv2	alias for $2;
	tnRekvId alias for $3;
	tnlepingId alias for $4;
	v_palk_jaak palk_jaak%rowtype;
	v_tooleping record;
	lnKuu1 int4;
	lnKuu2	int4;
	lnAasta1 int4;
	lnAasta2 int4;	
	lnElatis numeric (12,4);
	lnTulubaas numeric(12,4);
	lnTookoht int;
	lnArv numeric (12,4);
	lnCount int;
	lnCount_2004 int;
	lnCount_2005 int;
	ng31 numeric (12,4);
	lng31 numeric (12,4);
	lng31_2004 numeric (12,4);
	lng31_2005 numeric (12,4);
	lnTuluArv numeric(12,4);
	lnArvJaak numeric(12,4);
	lnTulumaar int;

begin

	lnkuu1 := month(tdKpv1); 
	lnkuu2 := month(tdKpv2);  
	lnAasta1 := year(tdKpv1);  
	lnAasta2 := year(tdKpv2);
	lnTookoht := 1; 

	select * into v_tooleping from tooleping where id = tnLepingId;
	
	lnTookoht := v_tooleping.pohikoht;
--	select pohikoht into lnTookoht from tooleping where id = tnLepingId;
	select Tulubaas into lnTulubaas from palk_config where rekvid = tnRekvId;
	lnTulubaas = ifnull(lnTulubaas,2250);	

	if lnTookoht = 0 then
		lnTulubaas := 0;
	end if;

	SELECT sum( Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric) into v_palk_jaak.arvestatud 
	FROM Library inner join Palk_lib on library.id = palk_lib.parentid 
	inner join Palk_oper on library.id = palk_oper.libid 
	left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
	WHERE Palk_lib.liik = 1    
	AND Palk_oper.kpv >= tdKpv1   
	AND Palk_oper.kpv <= tdKpv2
	AND Palk_oper.rekvId = tnRekvId
	AND palk_oper.lepingId	= tnLepingId;

	v_palk_jaak.arvestatud  := ifnull (v_palk_jaak.arvestatud ,0);

	raise notice 'v_palk_jaak.arvestatud: %',v_palk_jaak.arvestatud;

	SELECT sum( Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric) into v_palk_jaak.kinni 
	FROM Library inner join Palk_lib on library.id = palk_lib.parentid 
	inner join Palk_oper on library.id = palk_oper.libid 
	left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
	WHERE (Palk_lib.liik = 2    or palk_lib.liik = 8 or palk_lib.liik = 6 or (palk_lib.liik = 7 and palk_lib.asutusest = 0))
	AND Palk_oper.kpv >= tdKpv1   
	AND Palk_oper.kpv <= tdKpv2
	AND Palk_oper.rekvId = tnRekvId
	AND palk_oper.lepingId	= tnLepingId;

	v_palk_jaak.kinni := ifnull (v_palk_jaak.kinni,0);

	SELECT sum( Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric ) into v_palk_jaak.tki
	FROM Library inner join Palk_lib on library.id = palk_lib.parentid 
	inner join Palk_oper on library.id = palk_oper.libid 
	left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
	WHERE palk_lib.liik = 7 and palk_lib.asutusest = 0
	AND Palk_oper.kpv >= tdKpv1   
	AND Palk_oper.kpv <= tdKpv2
	AND Palk_oper.rekvId = tnRekvId
	AND palk_oper.lepingId	= tnLepingId;

	v_palk_jaak.tki := ifnull (v_palk_jaak.tki,0);

	SELECT sum( Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric ) into v_palk_jaak.tka
	FROM Library inner join Palk_lib on library.id = palk_lib.parentid 
	inner join Palk_oper on library.id = palk_oper.libid 
	left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
	WHERE palk_lib.liik = 7 and palk_lib.asutusest = 1
	AND Palk_oper.kpv >= tdKpv1   
	AND Palk_oper.kpv <= tdKpv2
	AND Palk_oper.rekvId = tnRekvId
	AND palk_oper.lepingId	= tnLepingId;

	v_palk_jaak.tka := ifnull (v_palk_jaak.tka,0);

	SELECT  sum( Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric) into v_palk_jaak.pm
	FROM Library inner join Palk_lib on library.id = palk_lib.parentid 
	inner join Palk_oper on library.id = palk_oper.libid 
	left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
	WHERE  palk_lib.liik = 8
	AND Palk_oper.kpv >= tdKpv1   
	AND Palk_oper.kpv <= tdKpv2
	AND Palk_oper.rekvId = tnRekvId
	AND palk_oper.lepingId	= tnLepingId;

	v_palk_jaak.pm := ifnull (v_palk_jaak.pm,0);

	SELECT  sum( Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric) into v_palk_jaak.tulumaks
	FROM Library inner join Palk_lib on library.id = palk_lib.parentid 
	inner join Palk_oper on library.id = palk_oper.libid 
	left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
	WHERE Palk_lib.liik = 4    
	AND Palk_oper.kpv >= tdKpv1   
	AND Palk_oper.kpv <= tdKpv2
	AND Palk_oper.rekvId = tnRekvId
	AND palk_oper.lepingId	= tnLepingId;

	v_palk_jaak.tulumaks := ifnull (v_palk_jaak.Tulumaks,0);

	SELECT  sum( Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric) into v_palk_jaak.sotsmaks
	FROM Library inner join Palk_lib on library.id = palk_lib.parentid 
	inner join Palk_oper on library.id = palk_oper.libid 
	left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
	WHERE Palk_lib.liik = 5
	AND Palk_oper.kpv >= tdKpv1   
	AND Palk_oper.kpv <= tdKpv2
	AND Palk_oper.rekvId = tnRekvId
	AND palk_oper.lepingId	= tnLepingId;

	v_palk_jaak.Sotsmaks := ifnull (v_palk_jaak.Sotsmaks,0);

	select id into v_palk_jaak.id from palk_jaak 
	where lepingId = tnlepingId 
	and kuu = lnkuu1
	and aasta = lnaasta1;

	v_palk_jaak.id := ifnull(v_palk_jaak.id,0);


	if not found then
		v_palk_jaak.id := 0;
	end if;
	        select sum(palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric) into lnElatis 
			from palk_oper 
			left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
			where libId in 
			(select l.id from library l inner join palk_lib p on l.id = p.parentid where p.elatis = 1 AND p.liik = 2) 
			AND Palk_oper.kpv >= tdKpv1   
			AND Palk_oper.kpv <= tdKpv2
			AND Palk_oper.rekvId = tnRekvId
			AND palk_oper.lepingId	= tnLepingId;

        select sum(o.summa * ifnull(dokvaluuta1.kuurs,1)::numeric) into lnArv 
		from palk_oper o inner join palk_kaart  k on o.lepingid = k.lepingid and k.libId = o.libId
		left outer join dokvaluuta1 on (o.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
		where o.libId in 
		(select l.id from library l inner join palk_lib p on l.id = p.parentid where p.liik = 1) 
		and k.tulumaks = 1
		AND o.kpv >= tdKpv1   
		AND o.kpv <= tdKpv2
		AND o.rekvId = tnRekvId
		AND o.lepingId	= tnLepingId;

	v_palk_jaak.g31 := lnArv - v_palk_jaak.tki - v_palk_jaak.pm;

-- muudetud 03/01/2005

	if v_palk_jaak.g31 > lnTulubaas then
		v_palk_jaak.g31 := lnTulubaas;
	end if;
	
	if v_tooleping.pohikoht > 0 then

		select sum(palk_jaak.g31) into lng31_2005 from palk_jaak 
			where lepingId = tnlepingId 
			and aasta = lnAasta1 
			and kuu < lnKuu1;

	raise notice 'lng31 %',lng31_2005;

	select count(*) into lnCount_2005 from palk_jaak 
			where lepingId = tnlepingId 
			and aasta = lnAasta1 
			and kuu < lnKuu1
			and date(aasta,kuu,1) >= v_tooleping.algab;

		raise notice 'lnCount %',lnCount_2005;

		-- should be 1400 * periods
		ng31 :=  lnTulubaas * lnCount_2005 ;
		raise notice 'lnKuu1 %',lnKuu1;
		raise notice 'ng31 %',ng31;
		raise notice 'v_palk_jaak.arvestatud %',v_palk_jaak.arvestatud;
		raise notice 'lnTulubaas %',lnTulubaas;

		lnArvJaak := v_palk_jaak.arvestatud - v_palk_jaak.pm - v_palk_jaak.tki;
		raise notice 'lnArvJaak %',lnArvJaak;

		if lnArvJaak < lnTulubaas  then
			-- muudetud 25/01/2005
			-- kontrollime teised lepingud
			select count(*) into lnTulumaar from palk_kaart 
				where lepingId in (select id from tooleping where parentid = v_tooleping.parentId 
				and pohikoht = 0)
				and tulumaar = 0 
				and libId in (select parentid from palk_lib where liik = 4);
			if ifnull(lnTulumaar,0) > 0 then
				-- > 2 lepingud ja vahemalkt uks ei arvesta
				select sum(arvestatud) - sum(pm) - sum(tki) into lnArvJaak from palk_jaak 
					where aasta = lnAasta1 
					and kuu = lnKuu1
					and date(aasta,kuu,1) >= v_tooleping.algab
					and (lepingId = v_tooleping.id or lepingId in 
					(select distinct palk_kaart.lepingid from palk_kaart inner join tooleping on palk_kaart.lepingId = tooleping.id 
						where tooleping.parentid = v_tooleping.parentId and pohikoht = 0
						and tulumaar = 0 		
						and libId in (select parentid from palk_lib where liik = 4)));
			end if;
		end if;	
		raise notice 'parast lnArvJaak %',lnArvJaak;

		if lnArvJaak < lnTulubaas  then

			lnTulubaas := lnArvJaak;
			raise notice 'less then vaja %',lnTulubaas;
		else

			if ng31 > lng31_2005 and lnCount_2005 > 0 then
				-- on reserv
				lnTulubaas := lnTulubaas + (ng31 - lng31_2005);
				raise notice 'with reserv  %',lnTulubaas;
			end if;
			raise notice 'with reserv after %',lnTulubaas;
			raise notice 'limited lnArvJaak%',lnArvJaak;
			if lnTulubaas > lnArvJaak then
				lnTulubaas := lnArvJaak;
		
			end if;

		end if;
	else
		lnTulubaas:= 0;
	end if;

raise notice 'lnTulubaas %',lnTulubaas;		

if v_palk_jaak.id = 0 then

	insert into palk_jaak ( lepingId, kuu, aasta, arvestatud, kinni, tulumaks, sotsmaks, tka, tki, pm, g31)
		values (tnlepingId, lnkuu1, lnaasta1, v_palk_jaak.arvestatud, v_palk_jaak.kinni, 
		v_palk_jaak.tulumaks, v_palk_jaak.sotsmaks, v_palk_jaak.tka, v_palk_jaak.tki, v_palk_jaak.pm, ifnull(lnTulubaas,0));
else
--raise notice 'v_palk_jaak.id %',v_palk_jaak.id;
	update palk_jaak set 
		arvestatud = v_palk_jaak.arvestatud,
		kinni = v_palk_jaak.kinni,
		tka = v_palk_jaak.tka,
		tki = v_palk_jaak.tki,
		pm = v_palk_jaak.pm,
		tulumaks = v_palk_jaak.tulumaks,
		sotsmaks = v_palk_jaak.sotsmaks,
		g31 = ifnull(lnTulubaas,0)
		where id = v_palk_jaak.id;
end if;

 return sp_calc_palk_jaak (lnKuu1, lnaasta1, tnlepingId);

end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_update_palk_jaak(date, date, integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_update_palk_jaak(date, date, integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_update_palk_jaak(date, date, integer, integer) TO dbpeakasutaja;



CREATE OR REPLACE FUNCTION sp_updatearvjaak(integer, date)
  RETURNS numeric AS
$BODY$
declare tnArvId alias for 	$1; 	
	tdKpv alias for 	$2; 	
	lnArvSumma numeric (12,4);
	lnTasuSumma numeric (12,4);
	lnJaak numeric (12,4);
	ldKpv date;
begin
/*	lnArvSumma := 0;
	lnTasuSumma := 0;
	lnJaak := 0;
*/
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

CREATE OR REPLACE FUNCTION tsd(character varying, integer, integer, date)
  RETURNS numeric AS
$BODY$
DECLARE tcKontogrupp alias for $1;
	tnTunnusid alias for $2;
	tnrekvid alias for $3;
	tdKpv alias for $4;
	lnAlg numeric (12,4);
	lnDb numeric (14,4);
	lnKr numeric (14,4);
	lcTunnus varchar;
begin
	select kood into lcTunnus from library where id = tnTunnusId;

	lnDb :=0;
	lnKr :=0;

	-- arv algsaldo
	/*
	select sum(algsaldo) into lnAlg from library l inner join tunnusinf k on l.id = k.kontoId 
		where k.rekvId = tnRekvId and l.kood like ltrim(rtrim(tcKontogrupp)) and k.tunnusid = tnTunnusId;
*/
	-- arv. deebet kaibed


	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnDb from journal1 left outer join dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 1)
		where deebet like ltrim(rtrim(tcKontogrupp))::varchar+'%'
		and parentid in (select id from journal where rekvId = tnRekvId and kpv <= tdKpv)
		and ltrim(rtrim(tunnus)) = ltrim(rtrim(lcTunnus));


	-- arv. kreedit kaibed
	select sum(summa * ifnull(dokvaluuta1.kuurs,1) ) into lnKr from journal1  left outer join dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 1)
		where kreedit like ltrim(rtrim(tcKontogrupp))+'%'
		and parentid in (select id from journal where rekvId = tnRekvId and kpv <= tdKpv)
		and ltrim(rtrim(tunnus)) = ltrim(rtrim(lcTunnus));

	return ifnull(lnAlg,0) + ifnull(lnDb,0) - ifnull(lnKr,0);
end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION tsd(character varying, integer, integer, date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION tsd(character varying, integer, integer, date) TO vlad;
GRANT EXECUTE ON FUNCTION tsd(character varying, integer, integer, date) TO public;
GRANT EXECUTE ON FUNCTION tsd(character varying, integer, integer, date) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION tsd(character varying, integer, integer, date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION tsd(character varying, integer, integer, date) TO dbadmin;
GRANT EXECUTE ON FUNCTION tsd(character varying, integer, integer, date) TO dbvaatleja;


CREATE OR REPLACE FUNCTION sp_subkontod_report(character varying, integer, date, date, integer, character varying, integer, integer)
  RETURNS character varying AS
$BODY$
DECLARE tcKonto alias for $1;
	tnrekvid alias for $2;
	tdKpv1 alias for $3;
	tdKpv2 alias for $4;
	tnAsutus alias for $5;
	tcTunnus alias for $6;
	tnOpt alias for $7;
	tnSvod alias for $8;
	lcReturn varchar;
	lnId int;
	lnDb numeric (14,2);
	lnKr numeric (14,2);
	lnAlg numeric (14,2);
	lnLopp numeric (14,2);
	lnAsutusId1 int;
	lnAsutusId2 int;
	v_kaibed record;
	v_saldo record;
	v_account record;
	v_tunnus record;
	lnCount int;


begin


	if tnAsutus > 0 then
		lnAsutusId1 := tnAsutus;
		lnAsutusId2 := tnAsutus;
	else
		lnAsutusId1 := 0;
		lnAsutusId2 := 99999999;
	end if;

	select count(*) into lnCount from pg_stat_all_tables where UPPER(relname) = 'TMP_SUBKONTOD_REPORT';
	if ifnull(lnCount,0) < 1 then

		create table tmp_subkontod_report (id serial, asutusId int default 0, Asutus varchar(254) default space(1), regkood varchar(20) default space(1), 
			aadress text default space(1), konto varchar(20) default space(1), korkonto varchar(20) default space(1),
			tunnus varchar(20) default space(1), dokkpv date default date(),
			algjaak numeric (14,2) default 0, db numeric(14,2) default 0, kr numeric(14,2) default 0, loppjaak numeric(14,2) default 0,
			kood1 varchar(20) default space(1), kood2 varchar(20) default space(1), kood3 varchar(20) default space(1),
			kood4 varchar(20) default space(1), kood5 varchar(20) default space(1), dok varchar(120) default space(1),
			lausend int default 0, 
			timestamp varchar(20) , kpv date default date(), rekvid int )  ;


		GRANT ALL ON TABLE tmp_subkontod_report TO GROUP public;
	else
		delete from tmp_subkontod_report where kpv < date() ;

	end if;

	lcreturn := to_char(now(), 'YYYYMMDDMISS');

-- lisatud 27/08/2008 kondaruanne koostamine

if (select count(*) from pg_stat_all_tables where UPPER(relname) = 'TMPREKV')  > 0 then
	delete from tmpRekv;
--	truncate TABLE tmpRekv;
	insert into tmpRekv
		SELECT id, parentid, fnc_get_asutuse_staatus(rekv.id, tnrekvid)::int as tase FROM rekv;
else
	CREATE TABLE tmpRekv AS
		SELECT id, parentid, fnc_get_asutuse_staatus(rekv.id, tnrekvid)::int as tase FROM rekv;
		GRANT ALL ON TABLE tmpRekv TO GROUP public;

END IF;

if tnSvod = 1 then
	delete from tmpRekv where tase < 3;

else
	delete from tmpRekv where tase in (0,1,2,4);
end if;




	-- matrix of subkontod

	if tnOpt < 5 then

		insert into tmp_subkontod_report (konto, asutusId,  regkood , Asutus, Aadress, algjaak, timestamp, rekvid )  
		select kontod.kood, asutus.id, asutus.regkood, asutus.nimetus as asutus, asutus.aadress, sum(subkonto.algsaldo) ,
		lcReturn, tnRekvId 
		from library kontod inner join subkonto  on (subkonto.kontoid = kontod.id and kontod.library = 'KONTOD') 
		inner join asutus on asutus.id = subkonto.asutusId
		where kontod.kood like tcKonto 
		and subkonto.rekvid in (select id from tmprekv)
		and subkonto.asutusId >= lnAsutusId1 and subkonto.asutusId <= lnAsutusid2 
		group by   kontod.kood,asutus.id, asutus.regkood, asutus.nimetus, asutus.aadress;

	else

		insert into tmp_subkontod_report (konto, asutusId,  regkood , Asutus, Aadress, algjaak, timestamp, rekvid, subrekvid )  
		select kontod.kood, asutus.id, asutus.regkood, asutus.nimetus as asutus, asutus.aadress, sum(subkonto.algsaldo) ,
		lcReturn, tnRekvId,subkonto.rekvid from library kontod inner join subkonto  on (subkonto.kontoid = kontod.id and kontod.library = 'KONTOD') 
		inner join asutus on asutus.id = subkonto.asutusId
		inner join tmprekv on subkonto.rekvId = tmprekv.id
		where (kontod.kood like '102%' or kontod.kood like '103%' or kontod.kood like '201%' or kontod.kood like '202%' or kontod.kood like '203%') 
		and subkonto.rekvid in (select id from tmprekv)
		and subkonto.asutusId >= lnAsutusId1 and subkonto.asutusId <= lnAsutusid2 
		group by  kontod.kood, subkonto.rekvid, asutus.id, asutus.regkood, asutus.nimetus, asutus.aadress;


	end if;


	if tnOpt = 1 then
		-- kaibeasutus andmik
		for v_account in 
			select konto, asutusId from tmp_subkontod_report where timestamp = lcreturn and rekvid = tnRekvId
		loop

		-- kaibed
			select sum(case when ltrim(rtrim(deebet)) = ltrim(rtrim(v_account.konto)) then (summa*ifnull(dokvaluuta1.kuurs,1)) else 0::numeric(14,2) end) as db, 
				sum(case when ltrim(rtrim(kreedit)) = ltrim(rtrim(v_account.konto)) then (summa*ifnull(dokvaluuta1.kuurs,1)) else 0::numeric(14,2) end) as kr into v_kaibed 
				from journal1 left outer join dokvaluuta1 on (dokvaluuta1.dokid = journal1.id and dokvaluuta1.dokliik = 1)
				where (ltrim(rtrim(deebet)) = ltrim(rtrim(v_account.konto)) or ltrim(rtrim(kreedit)) = ltrim(rtrim(v_account.konto)))
				and tunnus like tcTunnus
				and parentId in (select journal.id from journal inner join tmprekv on journal.rekvId = tmprekv.id
				where kpv >= tdKpv1 and kpv <= tdKpv2  and asutusId = v_account.asutusid);

			-- algkaibed

			select sum(case when ltrim(rtrim(deebet)) = ltrim(rtrim(v_account.konto)) then (summa*ifnull(dokvaluuta1.kuurs,1)) else 0::numeric(14,2)  end) as db, 
				sum(case when ltrim(rtrim(kreedit)) = ltrim(rtrim(v_account.konto)) then (summa*ifnull(dokvaluuta1.kuurs,1)) else 0::numeric(14,2) end ) as kr into v_saldo
				from journal1  left outer join dokvaluuta1 on (dokvaluuta1.dokid = journal1.id and dokvaluuta1.dokliik = 1)
				where (ltrim(rtrim(deebet)) = ltrim(rtrim(v_account.konto)) or ltrim(rtrim(kreedit)) = ltrim(rtrim(v_account.konto)))
				and tunnus like tcTunnus
				and parentId in (select journal.id from journal	inner join tmprekv on journal.rekvId = tmprekv.id 
				where journal.kpv < tdKpv1  
				 and JOURNAL.asutusId = v_account.asutusid);


			select algJaak into lnAlg from tmp_subkontod_report 
				where timestamp = lcreturn 
				and rekvid = tnRekvId
				and ltrim(rtrim(konto)) = ltrim(rtrim(v_account.konto)) and asutusId = v_account.asutusId;

			lnAlg := ifnull(lnAlg,0) + ifnull(v_saldo.db,0) - ifnull(v_saldo.kr,0);
			lnLopp := lnAlg + ifnull(v_kaibed.db,0) - ifnull(v_kaibed.kr,0);
	

			update 	tmp_subkontod_report set db = ifnull(v_kaibed.db,0),
				kr = ifnull(v_kaibed.kr,0),
				algjaak = lnAlg,
				loppjaak = lnLopp
				where timestamp = lcreturn 
				and rekvid = tnRekvId
				and ltrim(rtrim(konto)) = ltrim(rtrim(v_account.konto)) and asutusId = v_account.asutusId;

		end loop;
		delete from tmp_subkontod_report where algjaak = 0 and db = 0 and kr = 0 and timestamp = lcreturn and rekvid = tnRekvId;

	end if;


	if tnOpt = 2 then
		-- konto andmik
		for v_account in 
			select konto, asutusId from tmp_subkontod_report where timestamp = lcreturn and rekvid = tnRekvId
		loop

-- kanded deebet
-- muudetud 16/02/2005
	insert into tmp_subkontod_report (dokkpv,konto, asutusId,  regkood , Asutus, Aadress, db, kr, korkonto, dok, kood1, kood2, kood3, kood4, 
	kood5, lausend, timestamp, rekvid, subrekvid, subrekvnimi )  
	select journal.kpv, v_account.konto, asutus.id, asutus.regkood, asutus.nimetus as asutus, asutus.aadress, 
		(journal1.summa*ifnull(dokvaluuta1.kuurs,1)), 0,
		journal1.kreedit, journal.dok, journal1.kood1, journal1.kood2, journal1.kood3, journal1.kood4, journal1.kood5,
		journalid.number, lcReturn, tnrekvid, rekv.Id, rekv.nimetus 
		from journal inner join journal1 on journal.id = journal1.parentid
		left outer join dokvaluuta1 on (dokvaluuta1.dokid = journal1.id and dokvaluuta1.dokliik = 1)
		inner join journalId on journal.id = journalId.journalId
		inner join asutus on asutus.id = journal.asutusId
		inner join tmprekv on journal.rekvId = tmprekv.id
		inner join rekv on journal.rekvid = rekv.id 
		where ltrim(rtrim(journal1.deebet)) = ltrim(rtrim(v_account.konto))
		and journal.asutusId = v_account.asutusId 
		and journal.kpv >= tdKpv1 and journal.kpv <= tdKpv2;

-- kanded kreedit
-- muudetud 16/02/2005
	insert into tmp_subkontod_report (dokkpv, konto, asutusId,  regkood , Asutus, Aadress, db, kr, korkonto, dok, kood1, kood2, kood3, kood4, 
	kood5, lausend, timestamp, rekvid, subrekvid, subrekvnimi )  
	select journal.kpv, v_account.konto, asutus.id, asutus.regkood, asutus.nimetus as asutus, asutus.aadress,
		0, (journal1.summa*ifnull(dokvaluuta1.kuurs,1)), 
		journal1.deebet, journal.dok, journal1.kood1, journal1.kood2, journal1.kood3, journal1.kood4, journal1.kood5,
		journalid.number, lcReturn, tnrekvId, rekv.id, rekv.nimetus 
		from journal inner join journal1 on journal.id = journal1.parentid
		left outer join dokvaluuta1 on (dokvaluuta1.dokid = journal1.id and dokvaluuta1.dokliik = 1)
		 inner join journalId on journal.id = journalId.journalId
		inner join asutus on asutus.id = journal.asutusId
		inner join tmprekv on journal.rekvId = tmprekv.id
		inner join rekv on journal.rekvid = rekv.id
		where ltrim(rtrim(journal1.kreedit)) = ltrim(rtrim(v_account.konto))
		and journal.asutusId = v_account.asutusid
		and journal.kpv >= tdKpv1 and journal.kpv <= tdKpv2;

-- algjaak
	select sum(case when ltrim(rtrim(deebet)) = ltrim(rtrim(v_account.konto)) then (summa*ifnull(dokvaluuta1.kuurs,1)) else 0::numeric(14,2)  end) as db, 
		sum(case when ltrim(rtrim(kreedit)) = ltrim(rtrim(v_account.konto)) then (summa*ifnull(dokvaluuta1.kuurs,1)) else 0::numeric(14,2) end ) as kr into v_saldo
		from journal1 left outer join dokvaluuta1 on (dokvaluuta1.dokid = journal1.id and dokvaluuta1.dokliik = 1)
		where (ltrim(rtrim(deebet)) = ltrim(rtrim(v_account.konto)) or ltrim(rtrim(kreedit)) = ltrim(rtrim(v_account.konto)))
		and tunnus like tcTunnus
		and parentId in (select journal.id from journal inner join tmprekv on journal.rekvId = tmprekv.id where kpv < tdKpv1  
		and asutusId = v_account.asutusid);

-- algjaak
	select sum(db) as db, sum(kr) as kr into v_kaibed from tmp_subkontod_report 
		where timestamp = lcreturn 
		and rekvid = tnRekvId
		and ltrim(rtrim(konto)) = ltrim(rtrim(v_account.konto)) and asutusId = v_account.asutusId;

	select algJaak into lnAlg from tmp_subkontod_report 
		where timestamp = lcreturn 
		and rekvid = tnRekvId
		and ltrim(rtrim(konto)) = ltrim(rtrim(v_account.konto)) and asutusId = v_account.asutusId;

	lnAlg := ifnull(lnAlg,0) + ifnull(v_saldo.db,0) - ifnull(v_saldo.kr,0);
	lnLopp := lnAlg + ifnull(v_kaibed.db,0) - ifnull(v_kaibed.kr,0);

	update 	tmp_subkontod_report set algjaak = lnAlg,
		loppjaak = lnLopp
		where timestamp = lcreturn 
		and rekvid = tnRekvId
		and ltrim(rtrim(konto)) = ltrim(rtrim(v_account.konto)) and asutusId = v_account.asutusId;
	end loop;

	delete from tmp_subkontod_report where algjaak = 0 and db = 0 and kr = 0 and timestamp = lcreturn and rekvid = tnRekvId;

	end if;

	if tnOpt = 3 then
		-- saldo andmik

		for v_account in 
			select konto, asutusId from tmp_subkontod_report where timestamp = lcreturn and rekvid = tnRekvId and konto like tcKonto

		loop
			select sum(case when ltrim(rtrim(deebet)) = ltrim(rtrim(v_account.konto)) then (summa*ifnull(dokvaluuta1.kuurs,1)) else 0::numeric(14,2)  end) as db, 
				sum(case when ltrim(rtrim(kreedit)) = ltrim(rtrim(v_account.konto)) then (summa*ifnull(dokvaluuta1.kuurs,1)) else 0::numeric(14,2) end ) as kr into v_saldo
				from journal1 left outer join dokvaluuta1 on (dokvaluuta1.dokid = journal1.id and dokvaluuta1.dokliik = 1)
				where (ltrim(rtrim(deebet)) = ltrim(rtrim(v_account.konto)) or ltrim(rtrim(kreedit)) = ltrim(rtrim(v_account.konto)))
				and tunnus like tcTunnus
				and parentId in (select journal.id from journal inner join tmprekv on journal.rekvId = tmprekv.id  
				where kpv <= tdKpv2 and asutusId = v_account.asutusid);

			select algJaak into lnAlg from tmp_subkontod_report 
				where timestamp = lcreturn 
				and rekvid = tnRekvId
				and ltrim(rtrim(konto)) = ltrim(rtrim(v_account.konto)) and asutusId = v_account.asutusId;

			lnAlg := ifnull(lnAlg,0) + ifnull(v_saldo.db,0) - ifnull(v_saldo.kr,0);



			update 	tmp_subkontod_report set algjaak = lnAlg
				where timestamp = lcreturn 
				and rekvid = tnRekvId
				and ltrim(rtrim(konto)) = ltrim(rtrim(v_account.konto)) and asutusId = v_account.asutusId;


		end loop;
		delete from tmp_subkontod_report where algjaak = 0  and timestamp = lcreturn and rekvid = tnRekvId;

	end if;


	if tnOpt = 4 then


		-- kaibeasutus andmik tunnuse järgi

		for v_account in 
			select konto, asutusId, asutus, regkood, aadress, algjaak from tmp_subkontod_report where timestamp = lcreturn and rekvid = tnRekvId

		loop

			-- kaibed

		for v_tunnus in 

			select sum(case when ltrim(rtrim(deebet)) = ltrim(rtrim(v_account.konto)) then (summa*ifnull(dokvaluuta1.kuurs,1)) else 0::numeric(14,2) end) as db, 
			sum(case when ltrim(rtrim(kreedit)) = ltrim(rtrim(v_account.konto)) then (summa*ifnull(dokvaluuta1.kuurs,1)) else 0::numeric(14,2) end) as kr,
			 ltrim(rtrim(tunnus)) as tunnus 
			from journal1 left outer join dokvaluuta1 on (dokvaluuta1.dokid = journal1.id and dokvaluuta1.dokliik = 1)
			where (ltrim(rtrim(deebet)) = ltrim(rtrim(v_account.konto)) or ltrim(rtrim(kreedit)) = ltrim(rtrim(v_account.konto)))
			and tunnus like tcTunnus
			and parentId in (select journal.id from journal inner join tmprekv on journal.rekvId = tmprekv.id 
			where kpv >= tdKpv1 and kpv <= tdKpv2 and asutusId = v_account.asutusid)
			group by ltrim(rtrim(tunnus))

		loop

			-- algkaibed
			select sum(case when ltrim(rtrim(deebet)) = ltrim(rtrim(v_account.konto)) then (summa*ifnull(dokvaluuta1.kuurs,1)) else 0::numeric(14,2)  end) as db, 
				sum(case when ltrim(rtrim(kreedit)) = ltrim(rtrim(v_account.konto)) then (summa*ifnull(dokvaluuta1.kuurs,1)) else 0::numeric(14,2) end ) as kr into v_saldo
				from journal1 left outer join dokvaluuta1 on (dokvaluuta1.dokid = journal1.id and dokvaluuta1.dokliik = 1)
				where (ltrim(rtrim(deebet)) = ltrim(rtrim(v_account.konto)) or ltrim(rtrim(kreedit)) = ltrim(rtrim(v_account.konto)))
				and tunnus =  v_tunnus.tunnus 
				and parentId in (select journal.id from journal inner join tmprekv on journal.rekvId = tmprekv.id where kpv < tdKpv1  
				and asutusId = v_account.asutusid);


			insert into tmp_subkontod_report (konto, tunnus, asutusId, regkood , Asutus, Aadress, db, kr, algjaak, loppjaak, timestamp, rekvid)
			values (v_account.konto,v_tunnus.tunnus, v_account.asutusId, v_account.regkood, v_account.asutus, v_account.aadress,
			ifnull(v_tunnus.db,0), ifnull(v_tunnus.kr,0), 
			v_account.algjaak + ifnull(v_saldo.db,0) - ifnull(v_saldo.kr,0),
			v_account.algjaak + ifnull(v_saldo.db,0) - ifnull(v_saldo.kr,0) + ifnull(v_tunnus.db,0) - ifnull(v_tunnus.kr,0),
			lcreturn , tnRekvId);

		end loop;

		end loop;

--		delete from tmp_subkontod_report where algjaak = 0 and db = 0 and kr = 0 and timestamp = lcreturn and rekvid = tnRekvId;


	end if;


	if tnOpt = 5 then
		-- saldokinnitus
		for v_account in 
			select distinct konto, asutusId from tmp_subkontod_report where timestamp = lcreturn and rekvid = tnRekvId and konto not in ('103701','103950')

		loop
			select sum(case when ltrim(rtrim(deebet)) = ltrim(rtrim(v_account.konto)) then (summa*ifnull(dokvaluuta1.kuurs,1)) else 0::numeric(14,2)  end) as db, 
				sum(case when ltrim(rtrim(kreedit)) = ltrim(rtrim(v_account.konto)) then (summa*ifnull(dokvaluuta1.kuurs,1)) else 0::numeric(14,2) end ) as kr into v_saldo
				from journal1 left outer join dokvaluuta1 on (dokvaluuta1.dokid = journal1.id and dokvaluuta1.dokliik = 1)
				where (ltrim(rtrim(deebet)) = ltrim(rtrim(v_account.konto)) or ltrim(rtrim(kreedit)) = ltrim(rtrim(v_account.konto)))
				and tunnus like tcTunnus
				and parentId in (select journal.id from journal inner join tmprekv on journal.rekvId = tmprekv.id  
				where kpv <= tdKpv2 and asutusId = v_account.asutusid);

			select algJaak into lnAlg from tmp_subkontod_report 
				where timestamp = lcreturn 
				and rekvid = tnRekvId
				and ltrim(rtrim(konto)) = ltrim(rtrim(v_account.konto)) and asutusId = v_account.asutusId;

			lnAlg := ifnull(lnAlg,0) + ifnull(v_saldo.db,0) - ifnull(v_saldo.kr,0);



			update 	tmp_subkontod_report set algjaak = lnAlg, db = v_saldo.db, kr = v_saldo.kr
				where timestamp = lcreturn 
				and rekvid = tnRekvId
				and ltrim(rtrim(konto)) = ltrim(rtrim(v_account.konto)) and asutusId = v_account.asutusId;


		end loop;

		if (select count(*) from tmp_subkontod_report where  timestamp = lcreturn and rekvid = tnRekvId and db = 0 and kr = 0 and algjaak <> 0) > 0 then
			-- meil on vaja ainult 1 kiri tesed kustutame
			select id into lnId from tmp_subkontod_report where  timestamp = lcreturn and rekvid = tnRekvId and db = 0 and kr = 0 and algjaak <> 0;
			delete from  tmp_subkontod_report where  timestamp = lcreturn and rekvid = tnRekvId and db = 0 and kr = 0 and algjaak <> 0 and id <> lnId;
		end if; 

		delete from tmp_subkontod_report where ifnull(algjaak,0) = 0 and ifnull(db,0) = 0 and ifnull(kr,0) = 0 and timestamp = lcreturn and rekvid = tnRekvId;

	end if;


	return LCRETURN;

end;



$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_subkontod_report(character varying, integer, date, date, integer, character varying, integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_subkontod_report(character varying, integer, date, date, integer, character varying, integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_subkontod_report(character varying, integer, date, date, integer, character varying, integer, integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION sp_subkontod_report(character varying, integer, date, date, integer, character varying, integer, integer) TO dbvaatleja;

CREATE OR REPLACE FUNCTION sp_calc_arv(integer, integer, date)
  RETURNS numeric AS
$BODY$

declare

	tnLepingid alias for $1;

	tnLibId alias for $2;

	tdKpv alias for $3;

	lnSumma numeric (12,4);

	v_palk_kaart record;

	qrytooleping record;

	qryPalkLib   record;

	qryTaabel1 record;

	npalk	numeric(12,4);

	nHours NUMERIC(12,4);

	lnRate numeric (12,4);

	nSumma numeric (12,4);

	lnBaas numeric (12,4);

begin

nHours :=0;

lnSumma := 0;

nPalk:=0;

lnBaas :=0;

select palk_kaart.*, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs  into v_palk_kaart 
	from palk_kaart left outer join dokvaluuta1 on (palk_kaart.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 20) 
	where lepingid = tnLepingid and libId = tnLibId;

select * INTO qryPalkLib from palk_lib where parentId = tnLibId;

--raise notice 'Percent %',v_palk_kaart.percent_;

If v_palk_kaart.percent_ = 1 then

	-- calc based on taabel 

	raise notice 'calc based on taabel';

	If v_palk_kaart.alimentid = 0 then

		--raise notice 'alimentid = 0';

		

		select tooleping.*, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs into qryTooleping 
			from tooleping left outer join dokvaluuta1 on (tooleping.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 19) 
			where tooleping.id = tnLepingId; 

		select * into qryTaabel1 from palk_taabel1 where toolepingId = tnlepingId 

			and kuu = month(tdKpv) and aasta = year (tdKpv);

		if not found then

			--raise notice 'TAABEL1 NOT FOUND';

			return lnSumma;

		end if;





	SELECT tund into nHours FROM Toograf WHERE lepingid = tnLepingId AND kuu = month(tdKpv) AND aasta = year(tdKpv);




	IF ifnull(nHours,0) = 0 then

		nHours := (sp_workdays(1, month(tdKpv), year(tdKpv), 31,v_palk_kaart.lepingId)::numeric(6,4) * qryTooleping.toopaev )::INT4;
		nHours := nHours - sp_calc_tahtpaevad(qryTooleping.rekvId, month(tdKpv));

	END IF;

		--raise notice 'hOUR %',nHours;
		if qryTooleping.tasuliik = 1 then
			lnRate := (qryTooleping.palk * qryTooleping.kuurs)/ nHours * 0.01 * qryTooleping.koormus ;

			--raise notice 'Rate %',lnrate;

		end if;

		if qryTooleping.tasuliik = 2 then

			lnSumma := f_round((qryTooleping.palk * qryTooleping.kuurs) * qryTaabel1.kokku,qryPalkLib.round);
			lnRate := qryTooleping.palk * qryTooleping.kuurs;
			
			-- muudetud 01/02/2005
			if qryPalkLib.tund = 5 then
				lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.tahtpaev,qryPalkLib.round);
			end if;
			If  qryPalkLib.tund = 6 then
				lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.puhapaev,qryPalkLib.round);
			End if;
			If  qryPalkLib.tund = 7 then
				lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.uleajatoo,qryPalkLib.round);
			End if;
			if qryPalkLib.tund =3 then
				lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.ohtu,qryPalkLib.round);
			end if;
			if qryPalkLib.tund =4 then
				lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.oo,qryPalkLib.round);
			end if;
			if qryPalkLib.tund =2 then
				lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.paev,qryPalkLib.round);
			end if;

			return lnSumma;

		end if;

		If  qryPalkLib.tund = 5 then

			lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.tahtpaev,qryPalkLib.round);

			lnBaas := qryTaabel1.tahtpaev;

		End if;

		If  qryPalkLib.tund = 6 then

			lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.puhapaev,qryPalkLib.round);

			lnBaas := qryTaabel1.puhapaev;

		End if;

		If  qryPalkLib.tund = 7 then

			lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.uleajatoo,qryPalkLib.round);

			lnBaas := qryTaabel1.uleajatoo;

		End if;

		If  qryPalkLib.tund < 5 then			

			if qryPalkLib.tund =3 then

				nSumma := lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.ohtu;

			end if;

			if qryPalkLib.tund =4 then

				nSumma := lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.oo;

			end if;

			if qryPalkLib.tund =2 then

				nSumma := lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.paev;

			end if;

			if qryPalkLib.tund =1 then

				nSumma := lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.kokku;

			end if;

--			raise notice 'nSumma %',nSumma;


--			raise notice 'lnSumma %',lnSumma;


			lnSumma := lnSumma + f_round( nSumma, qryPalkLib.round);


--			raise notice 'LnSumma %',lnSumma;


--			raise notice '	qryPalklib.round %',qrypalklib.round;

			lnBaas := lnBaas + case when qryPalkLib.tund =3 then qryTaabel1.ohtu else 

				case when qryPalkLib.tund =4 then qryTaabel1.oo else qryTaabel1.paev end end; 

		End if;

	Else

--		lnBaas := calc_alimentid ();

--		lnPalk = f_round( lnBaas * v_palk_kaart.Summa * 0.01)

	End if;



Else

	lnSumma := f_round(v_palk_kaart.Summa * v_palk_kaart.kuurs,qryPalkLib.round);

	lnBaas := 0;

End if;



Return lnSumma;

end; 

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_calc_arv(integer, integer, date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_calc_arv(integer, integer, date) TO vlad;
GRANT EXECUTE ON FUNCTION sp_calc_arv(integer, integer, date) TO public;
GRANT EXECUTE ON FUNCTION sp_calc_arv(integer, integer, date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_calc_arv(integer, integer, date) TO dbpeakasutaja;

CREATE OR REPLACE FUNCTION gen_palkoper(integer, integer, integer, date, integer)
  RETURNS integer AS
$BODY$
declare
	tnLepingId alias for $1;
	tnLibId alias for $2;
	tnDokLausId alias for $3;
	tdKpv alias for $4;
	tnAvans alias for $5;

	lnLiik int;
	qrypalklib record;
	v_klassiflib record;
	v_palk_kaart record;
	v_dokprop record;
	lnAsutusest int;
	lnSumma numeric(12,4);
	lcTunnus varchar;
	lnPalkOperId int;
	lnJournalId int;
	lcTp varchar;
	v_valuuta record;
begin
	raise notice 'start';

	SELECT Library.kood, ifnull((select valuuta1.kuurs from valuuta1 
		where parentid = library.id order by Library.id desc limit 1),0) as kuurs into v_valuuta
		FROM Library WHERE  library = 'VALUUTA' and library.tun1 = 1;

	lcTp := '800699';
	lcTunnus := space(1);
	lnSumma := 0;
	select * into v_klassiflib from klassiflib where libId = tnLibId;
	select * into v_palk_kaart from palk_kaart where libId = tnLibId and lepingId = tnLepingId;
	select palk_lib.*, library.rekvId into qrypalklib from palk_lib inner join library on library.id = palk_lib.parentid 
		where palk_lib.parentid = tnLibId;
	select * into v_dokprop from dokprop where id = tnDokLausId;

	if qryPalkLib.liik = 1 then
		raise notice 'palk_lib %',qryPalkLib.liik;
		lnSumma := sp_calc_arv(tnLepingId, tnLibId, tdKpv);
		raise notice 'summa %',lnSumma;
	end if;		
	if qryPalkLib.liik = 2 then
		raise notice 'palk_lib %',qryPalkLib.liik;
		lnSumma := sp_calc_kinni(tnLepingId, tnLibId, tdKpv);
	end if;		
	if qryPalkLib.liik = 3 then
		raise notice 'palk_lib %',qryPalkLib.liik;
		lnSumma := sp_calc_muuda(tnLepingId, tnLibId, tdKpv);
	end if;		
	if qryPalkLib.liik = 4 then
		raise notice 'palk_lib %',qryPalkLib.liik;
		lnSumma := sp_calc_tulumaks(tnLepingId, tnLibId, tdKpv);
		lcTp := '014003';
		if v_dokprop.asutusid > 0 then
			select tp into lcTp from asutus where id = v_dokprop.asutusId;
		end if;
	end if;		
	if qryPalkLib.liik = 5 then
		raise notice 'palk_lib %',qryPalkLib.liik;
		lnSumma := sp_calc_sots(tnLepingId, tnLibId, tdKpv);
		lcTp := '014003';
		if v_dokprop.asutusid > 0 then
			select tp into lcTp from asutus where id = v_dokprop.asutusId;
		end if;

	end if;		
	if qryPalkLib.liik = 6 then
		raise notice 'palk_lib %',qryPalkLib.liik;
		lnSumma := sp_calc_tasu(tnLepingId, tnLibId, tdKpv);
	end if;		
	if qryPalkLib.liik = 7 then
		raise notice 'palk_lib %',qryPalkLib.liik;
		if lnAsutusest < 1 then
			lnSumma := sp_calc_kinni(tnLepingId, tnLibId, tdKpv);
		else
			lnSumma := sp_calc_muuda(tnLepingId, tnLibId, tdKpv);
		end if;
		lcTp := '014003';
		if v_dokprop.asutusid > 0 then
			select tp into lcTp from asutus where id = v_dokprop.asutusId;
		end if;
	end if;		
	if qryPalkLib.liik = 8 then
		raise notice 'palk_lib %',qryPalkLib.liik;
		lnSumma := sp_calc_kinni(tnLepingId, tnLibId, tdKpv);
	end if;	
	raise notice 'lnSumma> %',lnSumma;
	
	if lnSumma > 0 then
		if v_klassiflib.tunnusid > 0 then
			select kood into lcTunnus from library where id = v_klassiflib.tunnusId;
		end if;
		if v_palk_kaart.tunnusid > 0 then
			select kood into lcTunnus from library where id = v_palk_kaart.tunnusId;
		end if;

		lcTunnus = ifnull(lcTunnus,space(1));	

		-- pohivaluuta
		lnSumma = lnSumma / fnc_currentkuurs(tdKpv);

		lnPalkOperId = sp_salvesta_palk_oper(0, qryPalkLib.rekvid, tnLibId, tnlepingid, tdKpv, lnSumma, tnDoklausid, '', 
			ifnull(v_klassiflib.kood1,space(1)),ifnull(v_klassiflib.kood2,'LE-P'), ifnull(v_klassiflib.kood3,space(1)), 
			ifnull(v_klassiflib.kood4,space(1)), ifnull(v_klassiflib.kood5,space(1)), ifnull(v_klassiflib.konto,space(1)), 
			 lcTp, lcTunnus,v_valuuta.kood, v_valuuta.kuurs,v_klassiflib.proj );


--		lisatud 31/12/2004
		IF tnAvans > 0 AND qryPalkLib.liik = 6 then 	
			perform sp_calc_avansimaksed(lnpalkOperId);
		END IF;

	end if;
	Return lnpalkOperId;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION gen_palkoper(integer, integer, integer, date, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION gen_palkoper(integer, integer, integer, date, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION gen_palkoper(integer, integer, integer, date, integer) TO dbpeakasutaja;


CREATE OR REPLACE FUNCTION sp_salvesta_journal1(integer, integer, numeric, character, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, numeric, character varying, character varying)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnparentid alias for $2;
	tnsumma alias for $3;
	tcdokument alias for $4;
	ttmuud alias for $5;
	tckood1 alias for $6;
	tckood2 alias for $7;
	tckood3 alias for $8;
	tckood4 alias for $9;
	tckood5 alias for $10;
	tcdeebet alias for $11;
	tclisa_d alias for $12;
	tckreedit alias for $13;
	tclisa_k alias for $14;
	tcvaluuta alias for $15;
	tnkuurs alias for $16;
	tnvalsumma alias for $17;
	tctunnus alias for $18;
	tcProj alias for $19;
	lnjournal1Id int;
	lnId int; 
	lrCurRec record;

	tmpJournal record;
	lnKontrol int;
	lnrekvid int;
	lcViga varchar;
	lcOmaTp varchar;
	ldKpv date;

	v_dokvaluuta record;
begin

select rekvid, kpv into lnrekvId, ldKpv from journal where id = tnparentid;
select recalc into lnKontrol from rekv where id = lnrekvid;

lcOmaTp = ltrim(rtrim(fnc_getomatp(lnrekvId,year(ldKpv))));		

		if ifnull(lnKontrol,0) = 1 then
			lcViga = sp_lausendikontrol(tcdeebet, tcKreedit,  tclisa_d, tclisa_k, tckood1, tcKood2, tckood5, tckood3, lcOmaTP, ldKpv, tcvaluuta);
			if left(ltrim(rtrim(lcViga)),4) = 'Viga' then
				raise exception ':%',lcViga;
				return 0;
			end if;
		end if;


if tnId = 0 then
	-- uus kiri
	insert into journal1 (parentid,summa,dokument,muud,kood1,kood2,kood3,kood4,kood5,deebet,lisa_d,kreedit,lisa_k,valuuta,kuurs,valsumma,tunnus, proj) 
		values (tnparentid,tnsumma,tcdokument,ttmuud,tckood1,tckood2,tckood3,tckood4,tckood5,tcdeebet,tclisa_d,tckreedit,tclisa_k,tcvaluuta,tnkuurs,tnvalsumma,tctunnus, tcProj);

	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
	--	raise notice 'lnId %',lnId;
		lnjournal1Id:= cast(CURRVAL('public.journal1_id_seq') as int4);
	--	raise notice 'lnaastaId %',lnaastaId;
	else
		lnjournal1Id = 0;
	end if;

	if lnjournal1Id = 0 then
		raise exception ':%','Ei saa lisada kiri';
	end if;

	-- valuuta

	insert into dokvaluuta1 (dokliik,dokid, valuuta, kuurs) 
		values (1, lnjournal1Id,tcValuuta, tnKuurs);

else
	-- muuda 
	select * into lrCurRec from journal1 where id = tnId;
	if lrCurRec.parentid <> tnparentid or lrCurRec.summa <> tnsumma or ifnull(lrCurRec.dokument,space(1)) <> ifnull(tcdokument,space(1)) or ifnull(lrCurRec.muud,space(1)) <> ifnull(ttmuud,space(1)) or lrCurRec.kood1 <> tckood1 or lrCurRec.kood2 <> tckood2 or lrCurRec.kood3 <> tckood3 or lrCurRec.kood4 <> tckood4 or lrCurRec.kood5 <> tckood5 or lrCurRec.deebet <> tcdeebet or lrCurRec.lisa_k <> tclisa_k or lrCurRec.kreedit <> tckreedit or lrCurRec.lisa_d <> tclisa_d or lrCurRec.valuuta <> tcvaluuta or 
		lrCurRec.kuurs <> tnkuurs or lrCurRec.valsumma <> tnvalsumma or lrCurRec.tunnus <> tctunnus or lrCurRec.proj <> tcProj then 
	update journal1 set 
		parentid = tnparentid,
		summa = tnsumma,
		dokument = tcdokument,
		muud = ttmuud,
		kood1 = tckood1,
		kood2 = tckood2,
		kood3 = tckood3,
		kood4 = tckood4,
		kood5 = tckood5,
		deebet = tcdeebet,
		lisa_k = tclisa_k,
		kreedit = tckreedit,
		lisa_d = tclisa_d,
		valuuta = tcvaluuta,
		kuurs = tnkuurs,
		valsumma = tnvalsumma,
		tunnus = tctunnus,
		proj = tcproj
	where id = tnId;
	end if;
	lnjournal1Id := tnId;


	-- valuuta
	if (select count(id) from dokvaluuta1 where dokliik = 1 and dokid = lnjournal1Id) = 0 then

		insert into dokvaluuta1 (dokliik, dokid, valuuta, kuurs) 
			values (1, lnjournal1Id,tcValuuta, tnKuurs);
	else
		select * into v_dokvaluuta from dokvaluuta1 where dokliik = 1 and dokid = lnjournal1Id ;

		if tcValuuta <> v_dokvaluuta.valuuta or tnKuurs <> v_dokvaluuta.kuurs then

			update dokvaluuta1 set valuuta = tcValuuta, kuurs = tnKuurs where id = v_dokvaluuta.id;
			
		end if;
	
	end if;
			
	
end if;

select id, rekvid, kpv, asutusId, dok into tmpJournal from journal where id = tnparentId;


--avans
select avans1.id into lnId from avans1 inner join dokprop on dokprop.id = avans1.dokpropid
	where ltrim(rtrim(number)) = ltrim(rtrim(tmpJournal.dok)) 
	and rekvid = tmpJournal.rekvid 
	and avans1.asutusId = tmpJournal.asutusId
	and ltrim(rtrim(dokprop.konto)) = ltrim(rtrim(tcDeebet))
	order by avans1.kpv desc limit 1;

	if ifnull(lnId,0) > 0 then
		perform fnc_avansijaak(lnId);
	end if;

-- reklmaks
/*

if (select count(id) from luba where number = tmpJournal.dok and rekvid = tmpJournal.rekvid and luba.parentid = tmpJournal.asutusId) > 0 then
	perform sp_tasu_dekl(tmpJournal.id);
end if;
*/

         return  lnjournal1Id;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_journal1(integer, integer, numeric, character, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, numeric, character varying, character varying) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_journal1(integer, integer, numeric, character, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, numeric, character varying, character varying) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_journal1(integer, integer, numeric, character, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, numeric, character varying, character varying) TO dbpeakasutaja;


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

		select id into lnUserId from userid where userid.rekvid = v_mk.rekvid and userid.kasutaja = CURRENT_USER::varchar;

		lnJournalId:= sp_salvesta_journal(0, v_mk.rekvId, lnUserId, v_mk.kpv, v_mk1.AsutusId, 
			ltrim(rtrim(v_dokprop.selg))+space(1)+ltrim(rtrim(v_mk.selg)), v_mk.number,'AUTOMATSELT LAUSEND (GEN_LAUSEND_MK)',v_mk.id) ;


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




