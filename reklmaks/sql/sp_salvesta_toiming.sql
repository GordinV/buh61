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
	v_toiming record;

begin
lnparentId = tnparentId;

raise notice 'parentid %, number %',tnparentid, tnNumber;

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
	select * into v_toiming from toiming where id = tnId;
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

	if v_toiming.journalId > 0 and tnStaatus = 0 then
		perform sp_del_journal(v_toiming.journalId, 1);
	end if;
	perform sp_recalc_rekljaak(tnid);

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
-- recalc luba jaak
perform sp_recalc_rekljaak(tnLubaId);

         return  lnId;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_toiming(integer, integer, integer, date, character varying, character varying, date, numeric, integer, character varying, text, integer, integer, integer, character varying, numeric)
  OWNER TO vlad;
