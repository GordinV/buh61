-- Table: ettemaksud

-- DROP TABLE ettemaksud;

CREATE TABLE ettemaksud
(
  id serial NOT NULL,
  rekvid integer NOT NULL,
  kpv date NOT NULL,
  summa numeric(18,6) NOT NULL DEFAULT 0,
  "number" integer NOT NULL DEFAULT 0,
  asutusid integer NOT NULL,
  dokid integer NOT NULL,
  doktyyp integer NOT NULL DEFAULT 1,
  selg text,
  muud text,
  staatus integer NOT NULL DEFAULT 1,
  journalid integer NOT NULL DEFAULT 0
)
WITH (
  OIDS=FALSE
);
ALTER TABLE ettemaksud OWNER TO postgres;
GRANT ALL ON TABLE ettemaksud TO postgres;
GRANT ALL ON TABLE ettemaksud TO dbkasutaja;
GRANT ALL ON TABLE ettemaksud TO dbpeakasutaja;
GRANT SELECT, REFERENCES, TRIGGER ON TABLE ettemaksud TO dbvaatleja;


-- Sequence: ettemaksud_id_seq

-- DROP SEQUENCE ettemaksud_id_seq;

GRANT ALL ON TABLE ettemaksud_id_seq TO postgres;
GRANT SELECT, USAGE ON TABLE ettemaksud_id_seq TO public;
GRANT ALL ON TABLE ettemaksud_id_seq TO dbkasutaja;
GRANT ALL ON TABLE ettemaksud_id_seq TO dbpeakasutaja;

-- Function: sp_salvesta_journal1(integer, integer, numeric, character, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, numeric, character varying, character varying)

-- DROP FUNCTION sp_salvesta_journal1(integer, integer, numeric, character, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, numeric, character varying, character varying);

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
raise notice 'ldKpv %',ldKpv;
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
--select id, rekvid, kpv, asutusId, dok into tmpJournal from journal where id = tnparentId;
if tckreedit = '200060' then
	perform sp_koosta_ettemaks(tnParentId, 1);
end if;
/*

if (select count(id) from luba where number = tmpJournal.dok and rekvid = tmpJournal.rekvid and luba.parentid = tmpJournal.asutusId) > 0 then
	perform sp_tasu_dekl(tmpJournal.id);
end if;



if (select count(toiming.id) from luba inner join toiming on luba.id = toiming.lubaid 
	where ltrim(rtrim(luba.number))+'-'+ltrim(rtrim(toiming.number::varchar)) like ltrim(rtrim(tmpJournal.dok))+'%' 
		and rekvid = tmpJournal.rekvid and luba.parentid = tmpJournal.asutusId) > 0 then
	if left(ltrim(rtrim(tcdeebet)),6) = '100100' or left(ltrim(rtrim(tckreedit)),6) = '100100' then 	
	--	raise notice 'see on dekl.tasu %',new.deebet;
--		perform sp_tasu_dekl(tmpJournal.id);
	end if;


	
end if;
*/




         return  lnjournal1Id;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_journal1(integer, integer, numeric, character, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, numeric, character varying, character varying) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_journal1(integer, integer, numeric, character, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, numeric, character varying, character varying) TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_journal1(integer, integer, numeric, character, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, numeric, character varying, character varying) TO public;
GRANT EXECUTE ON FUNCTION sp_salvesta_journal1(integer, integer, numeric, character, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, numeric, character varying, character varying) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_journal1(integer, integer, numeric, character, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, numeric, character varying, character varying) TO dbpeakasutaja;

-- Function: sp_salvesta_aa(integer, integer, character, character, numeric, integer, integer, integer, character, text, character varying)
/*select * from curJournal order by id desc limit 10
select * from journal order by id desc limit 10
select sp_koosta_ettemaks(1516, 1)
select * from ettemaksud

*/
-- DROP FUNCTION sp_salvesta_aa(integer, integer, character, character, numeric, integer, integer, integer, character, text, character varying);

CREATE OR REPLACE FUNCTION sp_koosta_ettemaks(integer, integer)
  RETURNS integer AS
$BODY$
declare
	tnid alias for $1;
	tnLiik alias for $2;
	lnId int; 
	v_journal record;
begin
lnId = 0;
if tnLiik = 1 then
-- journal
	for v_journal in 
		SELECT journal.id, journal1.id as journal1Id, journal.rekvid, journal.kpv, journal.asutusid, journal.selg, journal1.summa, journalid.number
			FROM journal
			JOIN journal1 ON journal.id = journal1.parentid
			JOIN journalid ON journal.id = journalid.journalid
			where journal.id = tnId
	loop 
-- kontrollime kas ettemaks juba koostatud
		select id into lnId from ettemaksud where journalid = v_journal.journal1Id;
		lnId = ifnull(lnId,0);
			
		lnId = sp_salvesta_ettemaksud(lnId, v_journal.rekvid, v_journal.asutusId, v_journal.id, 1, v_journal.kpv, v_journal.summa, v_journal.number, v_journal.selg, '', v_journal.journal1Id);
		if lnId > 0 then
			update journal set dokid = lnId where id = tnId;
		end if;		
	end loop;

end if;
return  lnId;

end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_koosta_ettemaks(integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_koosta_ettemaks(integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_koosta_ettemaks(integer, integer) TO dbpeakasutaja;

-- Function: trigd_journal1_after()

-- DROP FUNCTION trigd_journal1_after();

CREATE OR REPLACE FUNCTION trigd_journal1_after()
  RETURNS trigger AS
$BODY$
declare 
	v_journal record;
begin

	select * into v_journal from journal where id = old.parentid;

	delete from dokvaluuta1 where dokid = old.id and dokliik = 1;

	--reklmaks
	delete from ettemaksud where journalid = old.id;
	
	return null;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION trigd_journal1_after() OWNER TO vlad;
GRANT EXECUTE ON FUNCTION trigd_journal1_after() TO vlad;
GRANT EXECUTE ON FUNCTION trigd_journal1_after() TO public;
GRANT EXECUTE ON FUNCTION trigd_journal1_after() TO dbkasutaja;
GRANT EXECUTE ON FUNCTION trigd_journal1_after() TO dbpeakasutaja;

-- Function: gen_lausend_reklmaks(integer)

-- DROP FUNCTION gen_lausend_reklmaks(integer);

CREATE OR REPLACE FUNCTION gen_lausend_rekltasu(integer)
  RETURNS integer AS
$BODY$
declare 	tnId alias for $1;	
		lnJournalNumber int4;	
		lcDbKonto varchar(20);	
		lcKrKonto varchar(20);	
		lcDbTp varchar(20);	
		lcKrTp varchar(20);	
		lcDok varchar(20);	
		lnAsutusId int4;	
		lnJournalId int4;	
		v_luba record;	
		v_dekl record;	
		v_dokprop record;	
		lnSumma numeric;

		lnCount integer;
begin

	select luba.rekvid, luba.number, toiming.*, ifnull(dokvaluuta1.valuuta,'EEK')::varchar as valuuta, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs into v_dekl 
		from toiming inner join luba on toiming.lubaid = luba.id
		left outer join dokvaluuta1 on (toiming.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 24)  where toiming.id = tnId;
/*
	If v_dekl.dokpropid = 0 then	
		raise notice 'ei registreeri';
		Return 0;	
	End if;
	select * into v_dokprop from dokprop where id = v_dekl.dokpropid;	
	
	If not found Or v_dokprop.registr = 0 then		
		raise notice 'puudub dokprop or ei registreeri';
		Return 0;	
	End if;	
*/
	lnJournalId = 0;
	lnSumma = 0;

	lnJournalId:= sp_salvesta_journal(0, v_dekl.rekvId, 0, v_dekl.kpv,v_dekl.parentId, 
				v_dekl.alus, v_dekl.number,'AUTOMATSELT LAUSEND (GEN_LAUSEND_REKLTASU)',v_dekl.id) ;
		
	select tp into lcDbTp from asutus where id = v_dekl.parentid;
	lcKrTp = lcDbTp;
	lcDbKonto := '200060';	
	lcKrKonto := '102060';			
	lnAsutusId := v_dekl.parentid;		
	lnSumma = v_dekl.summa;

	perform sp_salvesta_journal1(0,lnJournalId,lnSumma,''::varchar,''::text,
		'01112','','','','3044',lcDbKonto,lcDbTp,lcKrKonto,lcKrTp,v_dekl.valuuta,v_dekl.kuurs,lnSumma*v_dekl.kuurs,'','');


	return lnJournalId;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION gen_lausend_rekltasu(integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION gen_lausend_rekltasu(integer) TO dbpeakasutaja;

-- Function: sp_salvesta_aa(integer, integer, character, character, numeric, integer, integer, integer, character, text, character varying)

-- DROP FUNCTION sp_salvesta_aa(integer, integer, character, character, numeric, integer, integer, integer, character, text, character varying);

CREATE OR REPLACE FUNCTION sp_salvesta_ettemaksud(integer, integer,integer,integer,integer,date,numeric, integer, text, text, integer)
  RETURNS integer AS
$BODY$
declare
	tnid alias for $1;
	tnRekvId alias for $2;
	tnAsutusId alias for $3;
	tnDokid alias for $4;
	tnDokTyyp alias for $5;
	tdKpv alias for $6;
	tnSumma alias for $7;
	tnNumber alias for $8;
	ttSelg alias for $9;
	ttmuud alias for $10;
	tnJournal1Id alias for $11;
	lnId int; 

begin



if tnId = 0 then

	-- uus kiri

	insert into ettemaksud (rekvid, asutusid, dokid, doktyyp, kpv, summa, number, selg, muud, journalid) 
		values (tnrekvid, tnasutusid, tndokid, tndoktyyp, tdkpv, tnsumma, tnnumber, ttselg, ttmuud, tnJournal1Id);

	lnId:= cast(CURRVAL('public.ettemaksud_id_seq') as int4);

else
	-- muuda 

	update ettemaksud set 
		rekvid = tnRekvid,
		asutusid = tnAsutusId,
		dokid = tnDokid,
		doktyyp = tnDoktyyp,
		kpv = tdKpv,
		Summa = tnSumma,
		number = tnNumber,
		muud = ttmuud,
		selg = ttSelg,
		journalid = tnJournal1id
		where id = tnId;

	lnId := tnId;
end if;

perform fncReklEttemaksStaatus(tnasutusid);

return  lnId;

end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_ettemaksud(integer, integer,integer,integer,integer,date,numeric, integer, text, text, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_ettemaksud(integer, integer,integer,integer,integer,date,numeric, integer, text, text, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_ettemaksud(integer, integer,integer,integer,integer,date,numeric, integer, text, text, integer) TO dbpeakasutaja;


CREATE OR REPLACE FUNCTION fncReklEttemaksStaatus(integer)
  RETURNS integer AS
$BODY$

declare
	tnAsutusId alias for $1;
	lnReturn integer;
	v_ettemaks record;
	lnSumma numeric(18,6);
	
begin
lnReturn = 0;
lnSumma = 0;
for v_ettemaks in
	select id, summa, kpv from ettemaksud where asutusId = tnAsutusId and staatus = 1 order by id
loop
	lnSumma = lnSumma + v_ettemaks.summa;
	if lnSumma = 0 then
		-- balance, koik ettemaksud on suletatud. Vahetame nende staatus 
		update ettemaksud set staatus = 0 where asutusid = tnAsutusid and staatus = 1 and id <= v_ettemaks.id;	
	end if;
	lnReturn = lnReturn + 1;

end loop;

return lnreturn;
end;


$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION fncReklEttemaksStaatus(integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION fncReklEttemaksStaatus(integer) TO dbpeakasutaja;

-- Function: sp_tasu_dekl(integer)

-- DROP FUNCTION sp_tasu_dekl(integer);

CREATE OR REPLACE FUNCTION sp_tasu_dekl1(integer, date, numeric, varchar, varchar, numeric)
  RETURNS integer AS
$BODY$

declare
	tnLubaId alias for $1;
	tdKpv alias for $2;
	tnSumma alias for $3;
	tcAlus alias for $4;	
	tcValuuta alias for $5;	
	tnKuurs alias for $6;	

	lnVolgKpv int;
	lnTasuSumma numeric;
	lnTasuJaak numeric;
	v_journal record;
	v_dekl record;
	v_tasu record;
	v_luba record;
	lnDeklStatus int;
	lnSumma numeric;
	lnid int;
	lnResult int;
	lcalus varchar;
	lnStaatus int;
	lcValuuta varchar;
	lnKuurs numeric(12,4);
	lnJournalId integer;
begin


lnResult := 0;
-- otsime luba

	select luba.*, toiming.number as t_number, toiming.id as deklid into v_luba from luba inner join toiming on luba.id = toiming.lubaid 
			where luba.id = tnLubaId;

	lcAlus = tcAlus;
	lnSumma = tnSumma;

	lnresult =  sp_salvesta_toiming(0::integer,v_luba.parentid::integer,v_luba.id::integer,tdkpv::date,lcAlus::character varying,
		space(1)::character varying,tdkpv::date,lnSumma::numeric,1::integer,'TASU'::character varying, 
		space(1)::text, 0::integer, 0::integer,0::integer,tcValuuta::character varying, tnkuurs::numeric );

	-- konteerimine
	lnJournalId = 0;

	if lnResult > 0 then
		lnJournalId = gen_lausend_rekltasu(lnResult);
		update toiming set journalId = lnJournalId where id = lnresult;				
		select id into lnJournalId from journal1 where parentid = lnJournalId;
	end if;

	if lcAlus = 'Ettemaks' then
		-- ettemaks nullime
		insert into ettemaksud (rekvid, kpv, summa, number, asutusId, dokid, doktyyp, selg, staatus, journalId) values 
			(v_luba.rekvid, tdKpv, -1*lnSumma, 0, v_luba.parentid,  lnresult, 2, lcAlus, 1,lnJournalId);		
	end if;
	

	lnTasuJaak = lnSumma * tnkuurs;
-- kontrollime, kas on tasumata intress (luba.intress > 0)
	if v_luba.intress > 0 then

		for v_dekl in
			select toiming.id, toiming.summa, toiming.kpv, toiming.tahtaeg, toiming.staatus, ifnull(dokvaluuta1.kuurs,1)::numeric, ifnull(dokvaluuta1.valuuta,'EEK')::varchar 
				from toiming left outer join dokvaluuta1 on dokvaluuta1.dokid = toiming.id and dokvaluuta1.dokliik = 15
				where lubaId = v_luba.id
				and tyyp = 'INTRESS' 
				and staatus < 3
				order by kpv
		loop
		-- kui palju paevad oli tahtajatu

			lnVolgKpv := 0;

			if v_dekl.tahtaeg < tdkpv then
				lnVolgKpv = tdkpv - v_dekl.tahtaeg;
			end if;

			-- tasu summa


			if lnTasuJaak <= v_dekl.summa then
				lntasuSumma = lnSumma;
			else
				lnTasuSumma = v_dekl.summa;
			end if;

			if lnTasuSumma > lnTasuJaak then
				lntasuSumma = lnTasuJaak;
				lnTasuJaak = 0;
			else
				lntasuJaak = lnTasuJaak - lnTasuSumma;
			end if;


			insert into dekltasu (parentid, deklId, tasuId, tasuKpv, volgKpv, summa) values
				(v_luba.parentid, v_dekl.id, lnresult, tdkpv, lnVolgKpv, lnTasuSumma);


	-- status	

			select sum(summa) into lnSumma from dekltasu where deklId = v_dekl.id;
			if ifnull(lnSumma,0) >= v_dekl.summa then
				-- tasud
				lnDeklStatus = 3;	
			else
				-- tasud osaline
				lnDeklStatus = 2;	
			end if;

			perform sp_muuda_deklstaatus(v_dekl.Id, lnDeklStatus);

			if lnTasuJaak = 0 then
				lnresult = 1;	
				exit;
			end if;
		
		end loop;
	end if;

-- otsime esimine tasumata deklaratsioon
	
	lnStaatus = 3;
	if (select count(id) from toiming 
			where lubaId = v_luba.id
			and tyyp in ('DEKL', 'ALGSALDO') 
			and staatus < lnStaatus) = 0 then
		lnStaatus = 4;
	end if;


	for v_dekl in
		select id, summa, kpv, tahtaeg, staatus from toiming 
			where lubaId = v_luba.id
			and tyyp in ('DEKL', 'ALGSALDO') 
			and staatus < lnStaatus
			order by kpv

--			and not empty (saadetud) 

	loop
	-- kui palju paevad oli tahtajatu

		lnVolgKpv := 0;

		if v_dekl.tahtaeg < tdkpv then
			lnVolgKpv = tdkpv - v_dekl.tahtaeg;
		end if;

	-- tasu summa


		if lnTasuJaak <= v_dekl.summa then
			lntasuSumma = lnsumma;
		else
			lnTasuSumma = v_dekl.summa;
		end if;

		if lnTasuSumma > lnTasuJaak then
			lntasuSumma = lnTasuJaak;
			lnTasuJaak = 0;
		else
			lntasuJaak = lnTasuJaak - lnTasuSumma;
		end if;


		insert into dekltasu (parentid, deklId, tasuId, tasuKpv, volgKpv, summa) values
			(v_luba.parentid, v_dekl.id, lnresult, tdkpv, lnVolgKpv, lnTasuSumma);

	raise notice 'status';

	-- status	

		select sum(summa) into lnSumma from dekltasu where deklId = v_dekl.id;
		if ifnull(lnSumma,0) >= v_dekl.summa then
			-- tasud
			lnDeklStatus = 3;	
		else
			-- tasud osaline
			lnDeklStatus = 2;	
		end if;

	--	update toiming set staatus = lnDeklStatus where id = v_dekl.id;
		perform sp_muuda_deklstaatus(v_dekl.Id, lnDeklStatus);

		if lnTasuJaak = 0 then
			lnresult = 1;	
			exit;
		end if;

	end loop;

	raise notice 'avans';
	if lntasuJaak > 0 then
		-- avans
		insert into dekltasu (parentid, deklId, tasuId, tasuKpv, volgKpv, summa) values (v_luba.parentid, 0, lnresult, tdkpv, 0, lnTasuJaak);
		lnresult = 2;	
	end if;
	perform sp_recalc_rekljaak(v_luba.id);
	perform fncReklEttemaksStaatus(v_luba.parentid);
return  lnResult;
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION sp_tasu_dekl1(integer, date, numeric, varchar, varchar, numeric) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_tasu_dekl1(integer, date, numeric, varchar, varchar, numeric) TO dbpeakasutaja;

-- Function: sp_calc_deklsumma(integer, date)

-- DROP FUNCTION sp_calc_deklsumma(integer, date);

CREATE OR REPLACE FUNCTION sp_calc_deklsumma(integer, date)
  RETURNS numeric AS
$BODY$

declare 

	tnId alias for $1;
	tdKpv alias for $2;
	v_luba record;

	lnPeriod int;
	lnKord int;
	ldKpv date;
	ldAlgKpv date;
	ldLoppKpv date;
	lnTPkord int;

	lnSumma numeric;
	lnPaevad int;
begin
	lnSumma = 0;
	select luba.*, ifnull(dokvaluuta1.valuuta,'EEK')::varchar as valuuta, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs into v_luba 
		from luba left outer join dokvaluuta1 on (dokvaluuta1.dokid = luba.id and dokvaluuta1.dokliik = 23) where luba.id = tnId;

	if tdKpv >= v_luba.algkpv  and tdKpv <= v_luba.loppkpv   then
		lnSumma = v_luba.summa* v_luba.kuurs;
	else
		raise notice 'Vigane period %',tdKpv; 
	end if;
		raise notice 'Kuu %',v_luba.kord;

	if v_luba.kord = 'PAEV' then
		lnSumma = v_luba.summa * v_luba.kuurs;
		return lnSumma;	
	end if;
	if lnSumma > 0 then
		if v_luba.kord = 'NADAL' then
			raise notice 'nadal';
			-- diff >= 7
			-- OTSIME alg kpv 
			lnpaevad = tdKpv - v_luba.algkpv+1;
			ldAlgKpv = v_luba.algkpv + (floor(lnpaevad / 7)) * 7;
			lnSumma = (lnSumma / 7) * (tdKpv - ldAlgKpv);

		elseif ltrim(rtrim(v_luba.kord)) = 'KUU' then
		-- OTSIME alg kpv 
			raise notice 'Kuu';
			ldAlgKpv = date(year(v_luba.algkpv),month(v_luba.algkpv),1);
			ldLoppKpv = gomonth(ldAlgKpv, 1)-1;

			if v_luba.algkpv > ldAlgKpv and month(tdKpv) = month(v_luba.algkpv) and year(tdKpv) = year(v_luba.algkpv) then
				-- esimine kuu
				lnSumma = (lnSumma / 30) * (v_luba.algkpv - ldAlgKpv );
			elseif month(tdKpv) = month( v_luba.loppkpv) and year(tdKpv) = year(v_luba.loppkpv) then
				-- viimane kuu
				ldAlgKpv = date(year(v_luba.loppkpv),month(v_luba.loppkpv),1);
				lnpaevad = (v_luba.loppkpv - ldAlgKpv );
				raise notice 'ldAlgKpv %',ldAlgKpv;
				raise notice 'lnpaevad %',lnpaevad;
				if lnPaevad > 30 then
					lnPaevad = 30;
				end if;
			
				lnSumma = (lnSumma / 30) * lnPaevad ;
			end if; --alg lopp kpv
--		end if; -- kord
		elseif ltrim(rtrim(v_luba.kord)) = 'KVARTAL' then
		-- OTSIME alg kpv 
			raise notice 'Kvartal';

		-- kvartal number
			if (tdKpv - v_luba.algkpv) < 90 or (v_luba.loppkpv - tdKpv) < 90 then
				raise notice 'MEIE PERIOD';

				if month(tdKpv) < 4 then 
					ldAlgKpv = date(year(tdkpv),1,1);
					ldLoppKpv = date(year(tdkpv),3,31);
				elseif month(tdKpv) > 3 and month(tdKpv) < 7 then
					ldAlgKpv = date(year(tdkpv),4,1);
					ldLoppKpv = date(year(tdkpv),6,30);
				elseif month(tdKpv) > 6 and month(tdKpv) < 10 then
					ldAlgKpv = date(year(tdkpv),7,1);
					ldLoppKpv = date(year(tdkpv),9,30);
				else
					ldAlgKpv = date(year(tdkpv),10,1);
					ldLoppKpv = date(year(tdkpv),12,31);
				end if;
				raise notice 'ldalgkpv  %',ldalgkpv;
				raise notice 'ldLoppkpv  %',ldLoppkpv;
			if v_luba.loppkpv <= ldLoppKpv and  v_luba.algkpv >= ldAlgKpv then
					raise notice 'vaike period';
					lnSumma = (lnSumma / 90) * (v_luba.loppkpv - v_luba.algkpv + 1);
				elseif v_luba.algkpv > ldAlgKpv and ldLoppKpv < v_luba.loppkpv then
					-- esimine kvartal
					raise notice 'esimine';
					lnSumma = (lnSumma / 90) * (ldLoppKpv - v_luba.algkpv +1);
				elseif v_luba.loppkpv < ldLoppKpv and v_luba.algkpv < ldAlgKpv then
					-- viimane kvartal
					raise notice 'viimane';
					lnSumma = (lnSumma / 90) * (v_luba.loppkpv-ldAlgKpv + 1);
				end if; --alg lopp kpv
			end if; -- kvartal
		elseif ltrim(rtrim(v_luba.kord)) = 'AASTA' then
		-- OTSIME alg kpv 
			raise notice 'Aasta';

			ldAlgKpv = date(year(tdkpv),1,1);
			ldLoppKpv = date(year(tdkpv),12,31);
--			if year(v_luba.kpv) = year(tdKpv) and v_luba.loppkpv < tdKpv then
--				ldLoppKpv = v_luba.loppkpv;
--			end if;


			raise notice 'ldalgkpv  %',ldalgkpv;
			raise notice 'ldLoppkpv  %',ldLoppkpv;

			IF ldAlgKpv <> v_luba.algkpv or ldLoppKpv <> v_luba.loppkpv then
				if v_luba.loppkpv <= ldLoppKpv and  v_luba.algkpv >= ldAlgKpv then
					raise notice 'vaike period';
					lnSumma = (lnSumma / 360) * (v_luba.loppkpv - v_luba.algkpv);
				elseif v_luba.algkpv > ldAlgKpv and ldLoppKpv <= v_luba.loppkpv then
					-- esimine aasta
					raise notice 'esimine';
					lnSumma = (lnSumma / 360) * (ldLoppKpv - v_luba.algkpv);
				elseif v_luba.loppkpv < ldLoppKpv and v_luba.algkpv <= ldAlgKpv then
					-- viimane aasta
					raise notice 'viimane';
					lnSumma = (lnSumma / 360) * (v_luba.loppkpv-ldAlgKpv);
				end if; --alg lopp kpv
			end if; --aasta
		end if; -- kord
	end if; -- summa

	Return lnSumma;

end; 

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION sp_calc_deklsumma(integer, date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_calc_deklsumma(integer, date) TO dbpeakasutaja;

-- Function: sp_salvesta_toiming(integer, integer, integer, date, character varying, character varying, date, numeric, integer, character varying, text, integer, integer, integer, character varying, numeric)

-- DROP FUNCTION sp_salvesta_toiming(integer, integer, integer, date, character varying, character varying, date, numeric, integer, character varying, text, integer, integer, integer, character varying, numeric);

CREATE OR REPLACE FUNCTION sp_salvesta_toiming(integer, integer, integer, date, character varying, character varying, date, numeric, integer, character varying, text, integer, integer, integer, character varying, numeric)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnParentid alias for $2;
	tnLubaid alias for $3;
	tdKpv alias for $4;
	tcAlus alias for $5;
	tcEttekirjutus alias for $6;
	tdTahtaeg alias for $7;
	tnSumma alias for $8;
	tnStaatus alias for $9;
	tcTyyp alias for $10;
	ttMuud alias for $11;
	tnFailid alias for $12;
	tnDokPropid alias for $13;
	tnNumber alias for $14;
	tcValuuta alias for $15;
	tnKuurs alias for $16;

	v_avans record;
	lnSumma numeric(12,2);
	lnId int; 
	v_vanadekl record;
	lInsert int;
	lnParentid int;
	lnStaatus int;
	ldSaadetud date;

	v_dokvaluuta record;

begin
lnparentId = tnparentId;

raise notice 'parentid %',tnparentid;

if ifnull(tnParentid,0) = 0 then
	select parentId into lnParentId from luba where id = tnLubaId;
end if;

if tnId = 0 then
	lInsert = 1;
	if tcTyyp = 'DEKL' then

		select id into lnId from toiming where lubaid = tnLubaId and kpv = tdKpv and empty (saadetud) ;
		lnId = ifnull(lnId,0);
		if  lnId > 0 then 
			-- on eelmine deklaratsiooni versioonid, kustame
		
			perform sp_del_toiming(lnId);
		end if;
		-- check for saadetud dekl
		select count(id) into lnid from toiming  
			WHERE  lubaid = tnLubaId and kpv = tdKpv and not empty (saadetud);
		lnid = ifnull(lnId,0);
		if lnId > 0 then
			-- saadetud dekl. on
			lInsert = 0;
		end if;

		lnid = 0;
	end if;
	if linsert = 1 then
	-- uus kiri
		insert into toiming (parentid,lubaid, kpv,alus, ettekirjutus, tahtaeg, summa, staatus, tyyp, muud, failid, dokpropId, number) 
			values (lnparentid,tnlubaid, tdkpv, tcalus, tcettekirjutus, tdtahtaeg, round(tnsumma,2), tnstaatus, tctyyp, ttmuud, tnFailid, tnDokpropId, tnNumber);


	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
		lnId:= cast(CURRVAL('public.toiming_id_seq') as int4);
	else
		lnId = 0;
	end if;

	if lnId = 0 then
		raise exception 'Viga:%','Ei saa lisada kiri';
	end if;

	-- valuuta

	insert into dokvaluuta1 (dokliik,dokid, valuuta, kuurs) 
		values (24, lnId,tcValuuta, tnKuurs);




	end if;
else
	-- muuda 
	update toiming set 
		parentid = lnParentId,
		lubaid = tnLubaId, 
		kpv = tdKpv,
		alus = tcAlus, 
		ettekirjutus = tcettekirjutus, 
		tahtaeg = tdtahtaeg, 
		summa = round(tnSumma,2), 
		staatus = tnStaatus, 
		tyyp = tcTyyp, 
		failid = tnFailid,
		dokpropId = tnDokPropId,
		number = tnNumber,
		muud = ttMuud	
	where id = tnId;

	lnId := tnId;


	if (select count(id) from dokvaluuta1 where dokliik = 24 and dokid = lnId) = 0 then

		insert into dokvaluuta1 (dokliik, dokid, valuuta, kuurs) 
			values (24, lnId,tcValuuta, tnKuurs);
	else
		select * into v_dokvaluuta from dokvaluuta1 where dokliik = 24 and dokid = lnId ;

		if tcValuuta <> v_dokvaluuta.valuuta or tnKuurs <> v_dokvaluuta.kuurs then

			update dokvaluuta1 set valuuta = tcValuuta, kuurs = tnKuurs where id = v_dokvaluuta.id;
			
		end if;
	
	end if;
	




end if;

select staatus into lnStaatus from toiming where id = lnId;


-- recalc luba jaak
perform sp_recalc_rekljaak(tnLubaId);



-- lausend
/*
if tcTyyp = 'DEKL' and ifnull(lnStaatus,0) > 0 then
	perform gen_lausend_reklmaks(lnId);
end if;
*/
if  tcTyyp = 'INTRESS' and ifnull(lnStaatus,0) > 0 then
	perform gen_lausend_reklintress(lnId);
end if;
if  tcTyyp = 'PIKENDUS' and ifnull(lnStaatus,0) > 0 then
	select saadetud into ldSaadetud from toiming where id = lnId;
	update luba set loppkpv = ifnull(ldSaadetud,date()+365) where id = tnLubaId;
	perform sp_muuda_deklstaatus(lnId, 1);
end if;

         return  lnId;
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION sp_salvesta_toiming(integer, integer, integer, date, character varying, character varying, date, numeric, integer, character varying, text, integer, integer, integer, character varying, numeric) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_toiming(integer, integer, integer, date, character varying, character varying, date, numeric, integer, character varying, text, integer, integer, integer, character varying, numeric) TO dbpeakasutaja;

-- Function: sp_muuda_deklstaatus(integer, integer)

-- DROP FUNCTION sp_muuda_deklstaatus(integer, integer);

CREATE OR REPLACE FUNCTION sp_muuda_deklstaatus(integer, integer)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnStaatus alias for $2;
	v_toiming record;
	lndekltasu numeric(12,2);
	lnResult int; 
begin
	lnresult = tnStaatus;
	raise notice 'status: %',tnStaatus;

	select * into v_toiming from toiming where id = tnId;

	if tnStaatus = 3 and empty(v_toiming.saadetud) then
		-- tasud but nor deklared
		lnResult = 1;
	end if;
	if tnStaatus = 1 and not empty(v_toiming.saadetud) then
		-- check for tasu
		select sum(summa) into lndekltasu from dekltasu where deklid = tnId;
		if ifnull(lnDeklTasu,0) > 0 then
			if lnDekltasu < v_toiming.summa then
				-- osamaks
				lnresult = 2;
			end if;
			if lnDekltasu >= v_toiming.summa then
				-- loppmaks
				lnresult = 3;
			end if;
		end if;
 
	end if;
	update toiming set staatus = lnResult where id = tnid;


return  lnResult;
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION sp_muuda_deklstaatus(integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_muuda_deklstaatus(integer, integer) TO dbpeakasutaja;

-- Function: empty(numeric)

-- DROP FUNCTION empty(numeric);
/*
select * from asutus where upper(nimetus) like upper('Datel%')

select  fncReklEttemaksJaak(86)


*/

CREATE OR REPLACE FUNCTION fncReklEttemaksJaak(integer)
  RETURNS numeric AS
$BODY$

declare
	tnAsutusId alias for $1;
	lnSumma numeric(18,6);
	
begin
lnSumma = 0;

select sum(summa) into lnSumma from ettemaksud where asutusId = tnAsutusId ;
lnSumma = ifnull(lnSumma,0);

return lnSumma;
end;


$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION fncReklEttemaksJaak(integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION fncReklEttemaksJaak(integer) TO dbpeakasutaja;

-- Function: sp_calc_dekl(integer)
/*
select gomonth(date(),1)
select * from toiming
*/
-- DROP FUNCTION sp_calc_dekl(integer);

CREATE OR REPLACE FUNCTION sp_calc_dekl(integer)
  RETURNS smallint AS
$BODY$

declare 

	tnId alias for $1;
	v_luba record;

	lnPeriod int;
	lnKord int;
	ldKpv date;
	ldAlgKpv date;
	ldLoppKpv date;
	ldtahtaeg date;
	lnSamm int;
	lnDokProp int;
	lnToimingId int;
	lnLen int;
	lnTPkord int;
	lnSumma numeric;
begin
	select luba.*, ifnull(dokvaluuta1.valuuta,'EEK')::varchar as valuuta, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs into v_luba 
		from luba left outer join dokvaluuta1 on (dokvaluuta1.dokid = luba.id and dokvaluuta1.dokliik = 23) where luba.id = tnId;
	lnKord = 0;
	-- dok liik
	select dokprop.id into lnDokProp from library inner join dokprop on library.id = dokprop.parentid 
		where library.kood = 'DEKL' and library.library = 'DOK' and rekvid = v_luba.rekvid order by id desc limit 1; 
	lnDokProp = ifnull(lnDokProp,0);


	if v_luba.staatus = 0 then
		raise exception 'Luba anulleritud';
		return 0;
	end if;

	-- kustatme vana dekl

	delete from toiming where lubaid = v_luba.id and empty(saadetud) and staatus = 1 and tyyp = 'DEKL'; 

	ldAlgKpv = date(year(v_luba.algkpv), 1,1);
	ldLoppKpv = date(year(v_luba.algkpv), 12,31);
--	ldLoppKpv = date(year(v_luba.loppkpv), 12,31);

	if v_luba.kord = 'PAEV' then
		lnPeriod = ldLoppKpv - ldAlgKpv;
		lnKord = 1 ;
	elseif v_luba.kord = 'NADAL' then
		lnPeriod = ceil((ldLoppKpv - ldAlgKpv ) / 7);
		lnKord = ceil((v_luba.algkpv - ldAlgKpv) / 7) ;
	elseif v_luba.kord = 'KUU' then
		lnPeriod = ceil(month(ldLoppKpv) - month(ldAlgKpv) + 1);
		lnKord = month(v_luba.algkpv) - month(ldAlgKpv) ;
	elseif v_luba.kord = 'KVARTAL' then
		lnPeriod = floor((month(ldLoppKpv) - month(ldAlgKpv) + 1) / 3);
		lnKord = ceil((v_luba.algkpv - ldAlgKpv) / 90) ;
	elseif v_luba.kord = 'AASTA' then
		lnPeriod = 1;
		lnKord = 1;
		if v_luba.loppkpv > ldLoppKpv then
			-- teine aasta
			lnPeriod = year(v_luba.loppkpv) - year(v_luba.algkpv) + 1;
			lnKord = 0;
			ldLoppKpv = v_luba.loppkpv;
		end if;

	else
		lnPeriod = floor((month(ldLoppKpv) - month(ldAlgKpv) + 1) / 3);
		lnKord = ceil((v_luba.algkpv - ldAlgKpv) / 90) ;
	end if;
	if ldLoppKpv < v_luba.loppkpv then
		ldLoppKpv = v_luba.loppkpv;
	end if;
		raise notice 'LnPeriod: %',lnPeriod;
		raise notice 'ldalgkpv: %',ldalgkpv;
		raise notice 'ldloppkpv: %',ldloppkpv;

--	lnKord = 0;
	loop
		if empty(ldKpv) then
			-- esimine
			ldKpv = v_luba.algkpv;	
		end if;

		raise notice 'LnPeriod: %',lnPeriod;
		raise notice 'LnKord: %',lnKord;

		ldtahtaeg = ldKpv;
		if ldKpv > ldloppkpv then
			raise notice 'Exit: %',ldKpv;
			exit;
		end if;
		loop
			if sp_ifworkday(ldtahtaeg,v_luba.rekvid) = 1 then
				raise notice 'Exit sp_ifworkday';
				exit;
			end if;
			ldtahtaeg = ldtahtaeg + 1;
			lnTPkord = lnTPkord + 1;
			if lnTPkord > 5 then
				exit;
			end if;

		end loop;
		lnSumma = sp_calc_deklsumma(v_luba.id, ldKpv);
		if lnSumma = 0 then
			exit;
		end if;
		lnSumma = round(lnSumma / v_luba.kuurs,2);


		-- parandus 
		ldtahtaeg = DATE(YEAR(gomonth(ldKpv,1)),month(gomonth(ldKpv,1)),10);

		
		lnToimingId = sp_salvesta_toiming(0, v_luba.parentid,v_luba.id, ldKpv, space(1),space(1), ldtahtaeg, lnsumma, 1, 'DEKL', space(1), 0, lnDokProp,lnKord, v_luba.valuuta, v_luba.kuurs);

		raise notice 'id: %',lnToimingId; 

		lnKord = lnKord + 1;
		if lnKord >= lnPeriod then
			raise notice 'exit period';
			exit;
		end if;

		lnLen = len(v_luba.kord);

--		raise notice 'v_luba.kord: %',v_luba.kord;
--		raise notice 'lnLen: %',lnlen;



		if v_luba.kord = 'PAEV' then
			raise notice 'PAEV';
			ldKpv = ldKpv + 1;
		end if;
		if v_luba.kord = 'NADAL' then
			raise notice 'NADAL';
			ldKpv = ldKpv + 7;
		end if;
		if v_luba.kord = 'KUU' then
			raise notice 'KUU';
			ldKpv = gomonth(ldKpv,1);
		end if;
		if v_luba.kord = 'KVARTAL' then
			raise notice 'KVARTAL';
			if month(ldKpv) < 4 then
				-- 1 kvartal
				ldKpv = date(year(ldKpv),04,01);
			elseif month(ldKpv) > 3 and month(ldKpv) < 7 then
				-- 2 kvartal
				ldKpv = date(year(ldKpv),07,01);
			elseif month(ldKpv) > 6 and month(ldKpv) < 10 then
				-- 3 kvartal
				ldKpv = date(year(ldKpv),10,01);
			else
				-- 4 kvartal
				ldKpv = date(year(ldKpv)+1,01,01);
			end if;
			-- toopaevi kontrol
			lnTPkord = 0;
			loop
				if sp_ifworkday(ldKpv,v_luba.rekvid) = 1 then
					exit;
				end if;
				ldKpv = ldKpv + 1;
				lnTPkord = lnTPkord + 1;
				if lnTPkord > 5 then
					exit;
				end if;
			end loop;


--			ldKpv = gomonth(ldKpv,3);
		end if;

		if v_luba.kord = 'PAEV' then
			exit;
		end if;
		if v_luba.kord = 'AASTA' then
			raise notice 'AASTA';
			ldKpv = gomonth(ldKpv,12);
			if year(v_luba.loppkpv) = year(ldKpv) and v_luba.loppkpv < ldKpv then
				ldKpv = v_luba.loppkpv;
			end if;

		end if;
		raise notice 'ldKpv: %',ldKpv;
	end loop;
	-- delete dekl where kpv > luba.loppkpv
	delete from toiming where lubaid = v_luba.id and kpv > v_luba.loppkpv and tyyp = 'DEKL';
	Return 1;

end; 

$BODY$
  LANGUAGE 'plpgsql' VOLATILE STRICT
  COST 100;
GRANT EXECUTE ON FUNCTION sp_calc_dekl(integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_calc_dekl(integer) TO dbpeakasutaja;

