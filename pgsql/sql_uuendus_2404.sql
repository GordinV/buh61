-- Function: sp_update_pv_jaak(integer)

-- DROP FUNCTION sp_update_pv_jaak(integer);
/*
select sp_update_pv_jaak(curPohivara.id) from curPohivara where year(soetkpv) = 2011

select sp_update_pv_jaak(library.id) from pv_kaart  inner join library on library.id = pv_kaart.parentid 
where pv_kaart.tunnus = 1 and pv_kaart.jaak <= 0 

select sp_update_pv_jaak(35851)

select pv_kaart.parentid from pv_kaart  inner join library on library.id = pv_kaart.parentid 
where kood = 'T155106-219' and rekvid = 6

select * from pv_oper where parentid = 582959

select * from dokvaluuta1 where dokid = 257343
select * from curpohivara where kood = 'T155106-219'

	select sum(summa*ifnull(dokvaluuta1.kuurs,1))  
		from pv_oper left outer join dokvaluuta1 on (dokvaluuta1.dokid = pv_oper.id and dokvaluuta1.dokliik = 13)
		where parentId = 582959 and liik = 1;

*/


CREATE OR REPLACE FUNCTION sp_update_pv_jaak(integer)
  RETURNS numeric AS
$BODY$

declare
	tnid alias for $1;
	lnpv_operId int;
	lnId int; 
	lnSumma numeric(18,6);
	v_pv_kaart record;
	lrCurRec record;
	lnPvElu numeric(6,2);
	lnKulum numeric(12,2);

	lnSoetSumma numeric (18,6);
	lnParandatudSumma numeric (18,6);
	lnUmberhindatudSumma numeric (18,6);
	
	lnDokKuurs numeric(14,4);
	lcString varchar;
	v_dokvaluuta record;
	ldKpv date;
	lnJaak numeric (18,6);


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
			lnUmberhindatudSumma := lnSoetSumma;
		end if;

		raise notice 'kpv: %',ldKpv;


	select sum(summa*ifnull(dokvaluuta1.kuurs,1)) into lnSoetSumma 
		from pv_oper left outer join dokvaluuta1 on (dokvaluuta1.dokid = pv_oper.id and dokvaluuta1.dokliik = 13)
		where parentId = tnid and liik = 1;

	lnSoetSumma  = ifnull(lnSoetSumma ,v_pv_kaart.soetmaks);

	raise notice 'lnSoetSumma %',lnSoetSumma;


	select sum(summa*ifnull(dokvaluuta1.kuurs,1)) into lnParandatudSumma 
		from pv_oper left outer join dokvaluuta1 on (dokvaluuta1.dokid = pv_oper.id and dokvaluuta1.dokliik = 13)
		where parentId = tnid and liik = 3 and kpv > ldKpv;

		raise notice 'lnParandatudSumma 1: %',lnParandatudSumma;

	lnParandatudSumma = ifnull(lnParandatudSumma,0);

	select sum(summa*ifnull(dokvaluuta1.kuurs,1)) into lnKulum 
		from pv_oper left outer join dokvaluuta1 on (dokvaluuta1.dokid = pv_oper.id and dokvaluuta1.dokliik = 13)
		where parentId = tnid and liik = 2 and kpv > ldKpv;

--	lnParandatudSumma := ifnull(lnParandatudSumma,0) + ifnull(lnUmberhindatudSumma,v_pv_kaart.soetmaks);
	lnKulum = ifnull(lnKulum,0);

	lnParandatudSumma := lnSoetSumma + ifnull(lnParandatudSumma,0) + ifnull(lnUmberhindatudSumma,0);
		raise notice 'lnParandatudSumma 2: %',lnParandatudSumma;



	-- otsime dok.valuuta
	Select id into lnId from pv_kaart where parentid = tnId;
	
		
	lnParandatudSumma = lnParandatudSumma;
		raise notice 'lnParandatudSumma dokvaluutas %',lnParandatudSumma;

	raise notice 'kulum  %',lnKulum;
	raise notice 'v_pv_kaart.algkulum %',v_pv_kaart.algkulum;


	if lnUmberhindatudSumma > 0 and lnUmberhindatudSumma <> lnSoetSumma then
		raise notice 'Umber kulum = 0 %',lnKulum;
		raise notice 'lnSoetSumma %',lnSoetSumma;
		raise notice 'lnUmberhindatudSumma %',lnUmberhindatudSumma;
	end if;
-- privodim k kursu po kotoroj kupleno PO
		lnKulum = ifnull(lnKulum,0);

	lnParandatudSumma = round(lnParandatudSumma / v_pv_kaart.kuurs,2);
	lnKulum = round(lnKulum / v_pv_kaart.kuurs,2);

	update pv_kaart set parhind = lnParandatudSumma , jaak = lnParandatudSumma - lnKulum - ifnull(v_pv_kaart.algkulum,0) where parentId = tnid;

	lnJaak = lnParandatudSumma - lnKulum - ifnull(v_pv_kaart.algkulum,0);

         return  lnJaak;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_update_pv_jaak(integer) OWNER TO vlad;


-- Function: "month"()
/*
select DaysInMonth(date(2011,02,01))
*/
-- DROP FUNCTION "month"();

CREATE OR REPLACE FUNCTION DaysInMonth(date)
  RETURNS integer AS
$BODY$
DECLARE tdKpv alias for $1;
	ldKpv1 date;
	ldKpv2 date;
begin
	ldKpv1 = date(YEAR(tdKpv),month(tdKpv),1);
	ldKpv2 = gomonth(ldKpv1,1);


         return  ldKpv2 - ldKpv1;

end; 

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION DaysInMonth(date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION DaysInMonth(date) TO public;


-- Function: sp_salvesta_tooleping(integer, integer, integer, integer, date, date, numeric, numeric, integer, integer, numeric, integer, integer, integer, character varying, text, integer, integer, character varying, date, character varying, numeric)

-- DROP FUNCTION sp_salvesta_tooleping(integer, integer, integer, integer, date, date, numeric, numeric, integer, integer, numeric, integer, integer, integer, character varying, text, integer, integer, character varying, date, character varying, numeric);

CREATE OR REPLACE FUNCTION sp_salvesta_tooleping(integer, integer, integer, integer, date, date, numeric, numeric, integer, integer, numeric, integer, integer, integer, character varying, text, integer, integer, character varying, date, character varying, numeric)
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
ALTER FUNCTION sp_salvesta_tooleping(integer, integer, integer, integer, date, date, numeric, numeric, integer, integer, numeric, integer, integer, integer, character varying, text, integer, integer, character varying, date, character varying, numeric) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_tooleping(integer, integer, integer, integer, date, date, numeric, numeric, integer, integer, numeric, integer, integer, integer, character varying, text, integer, integer, character varying, date, character varying, numeric) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_tooleping(integer, integer, integer, integer, date, date, numeric, numeric, integer, integer, numeric, integer, integer, integer, character varying, text, integer, integer, character varying, date, character varying, numeric) TO dbpeakasutaja;


-- Function: sp_salvesta_palk_kaart(integer, integer, integer, integer, numeric, integer, integer, integer, integer, text, integer, integer, character varying, numeric)

-- DROP FUNCTION sp_salvesta_palk_kaart(integer, integer, integer, integer, numeric, integer, integer, integer, integer, text, integer, integer, character varying, numeric);

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
ALTER FUNCTION sp_salvesta_palk_kaart(integer, integer, integer, integer, numeric, integer, integer, integer, integer, text, integer, integer, character varying, numeric) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_palk_kaart(integer, integer, integer, integer, numeric, integer, integer, integer, integer, text, integer, integer, character varying, numeric) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_palk_kaart(integer, integer, integer, integer, numeric, integer, integer, integer, integer, text, integer, integer, character varying, numeric) TO dbpeakasutaja;


-- Function: sp_salvesta_palk_oper(integer, integer, integer, integer, date, numeric, integer, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, character varying)

-- DROP FUNCTION sp_salvesta_palk_oper(integer, integer, integer, integer, date, numeric, integer, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, character varying);

CREATE OR REPLACE FUNCTION sp_salvesta_palk_oper(integer, integer, integer, integer, date, numeric, integer, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, character varying, integer)
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
	tnTululiik alias for $20;
	lnpalk_operId int;
	lnId int; 
	lrCurRec record;
	v_dokvaluuta record;
begin

if tnId = 0 then
	-- uus kiri
	insert into palk_oper (rekvid,libid,lepingid,kpv,summa,doklausid,muud,kood1,kood2,kood3,kood4,kood5,konto,tp,tunnus, proj, journal1id) 
		values (tnrekvid,tnlibid,tnlepingid,tdkpv,tnsumma,tndoklausid,ttmuud,tckood1,tckood2,tckood3,tckood4,tckood5,tckonto,tctp,tctunnus,ifnull(tcProj,space(1)), tnTuluLiik);


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
		proj = ifnull(tcProj,space(1)),
		journal1id = tnTululiik,
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
		perform recalc_palk_saldo(tnlepingid,month(tdkpv)::int2);	
		perform gen_lausend_palk(lnpalk_operId);
	end if;
         return  lnpalk_operId;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_palk_oper(integer, integer, integer, integer, date, numeric, integer, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, character varying, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_palk_oper(integer, integer, integer, integer, date, numeric, integer, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, character varying, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_palk_oper(integer, integer, integer, integer, date, numeric, integer, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, character varying, integer) TO dbpeakasutaja;


-- Function: sp_check_twins(date, integer, integer, integer)

-- DROP FUNCTION sp_check_twins(date, integer, integer, integer);

CREATE OR REPLACE FUNCTION sp_check_twins(date, integer, integer, integer)
  RETURNS integer AS
$BODY$

declare


	tdKpv alias for $1;


	tnLibId alias for $2;


	tnlepingId alias for $3;


	tnId alias for $4;


	v_palk_oper record;


	lnError int;


begin





	for v_palk_oper in SELECT Palk_oper.id, palk_oper.libId, palk_lib.liik FROM Palk_oper 


		inner join palk_lib on palk_oper.libId = palk_lib.Parentid


		WHERE Palk_oper.libId = tnLibId   


		AND Palk_oper.kpv = tdKpv


		AND Palk_oper.LepingId = tnLepingId


		and palk_lib.liik not in (6,9) 


		and palk_oper.id <> tnid 
	loop


		lnError := sp_del_palk_oper(v_palk_oper.id,1);


	end loop;


	return lnError;


end; 

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_check_twins(date, integer, integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_check_twins(date, integer, integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_check_twins(date, integer, integer, integer) TO dbpeakasutaja;


-- View: curtsd
/*
DROP VIEW curtsd4;

select * from curtsd4

SELECT sum(Curtsd4.erisood_0100) as eris0100,sum(Curtsd4.erisood_0101) as eris0101,sum(Curtsd4.erisood_0110) as eris0110,sum(Curtsd4.erisood_0111) as eris0111,
 sum(Curtsd4.erisood_0200) as eris0200,  sum(Curtsd4.erisood_0201) as eris0201,  sum(Curtsd4.erisood_0210) as eris0210,  sum(Curtsd4.erisood_0211) as eris0211,  
 sum(Curtsd4.erisood_0300) as eris0300, sum(Curtsd4.erisood_0301) as eris0301, sum(Curtsd4.erisood_0310) as eris0310, sum(Curtsd4.erisood_0311) as eris0311, 
 sum(Curtsd4.erisood_0400) as eris0400, sum(Curtsd4.erisood_0401) as eris0401, sum(Curtsd4.erisood_0410) as eris0410, sum(Curtsd4.erisood_0411) as eris0411, 
  sum(Curtsd4.erisood_0500) as eris0500, sum(Curtsd4.erisood_0501) as eris0501, sum(Curtsd4.erisood_0510) as eris0510, sum(Curtsd4.erisood_0511) as eris0511, 
   sum(Curtsd4.erisood_0600) as eris0600,sum(Curtsd4.erisood_0601) as eris0601, sum(Curtsd4.erisood_0610) as eris0610, sum(Curtsd4.erisood_0611) as eris0611,  
   sum(Curtsd4.erisood_0700) as eris0700, sum(Curtsd4.erisood_0701) as eris0701, sum(Curtsd4.erisood_0710) as eris0710, sum(Curtsd4.erisood_0711) as eris0711, 
 sum(Curtsd4.erisood_0800) as eris0800, sum(Curtsd4.erisood_0801) as eris0801, sum(Curtsd4.erisood_0810) as eris0810, sum(Curtsd4.erisood_0811) as eris0811,  
 sum(Curtsd4.erisood_0900) as eris0900, sum(Curtsd4.erisood_0901) as eris0901, sum(Curtsd4.erisood_0910) as eris0910, sum(Curtsd4.erisood_0911) as eris0911,  
 sum(Curtsd4.erisood_1000) as eris1000,sum(Curtsd4.erisood_1001) as eris1001, sum(Curtsd4.erisood_1010) as eris1010, sum(Curtsd4.erisood_1011) as eris1011,  
 sum(Curtsd4.erisood_1100) as eris1100, sum(Curtsd4.erisood_1101) as eris1101, sum(Curtsd4.erisood_1110) as eris1110, sum(Curtsd4.erisood_1111) as eris1111 
 FROM  curtsd4  
 WHERE  rekvid = ?gRekv  or parentid = ?tnParentRekvId)  AND CAST(osakondId AS INT) >= ?tnOsakondId1   AND CAST(osakondId AS INT) <= ?tnOsakondId2   AND kpv >= ?tdKpv1   AND kpv <= ?tdKpv2
*/
CREATE OR REPLACE VIEW curtsd4 AS 
 SELECT rekv.parentid, palk_oper.id, palk_oper.rekvid, asutus.regkood AS isikukood, asutus.nimetus AS isik, tooleping.pohikoht, tooleping.osakondid, tooleping.resident,
	tooleping.riik, tooleping.toend, palk_lib.liik, palk_lib.asutusest, palk_lib.algoritm, palk_oper.kpv, 
	palk_oper.summa, rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar AS form, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 10 and palk_lib.sots = 0  and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0100, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 10 and palk_lib.sots = 1 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0110, 
       CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 10 and palk_lib.sots = 0  and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0101, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 10 and palk_lib.sots = 1 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0111, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 20 and palk_lib.sots = 0 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0200, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 20 and palk_lib.sots = 1 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0210, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 20 and palk_lib.sots = 0 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0201, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 20 and palk_lib.sots = 1 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0211, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 30 and palk_lib.sots = 0 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0300, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 30 and palk_lib.sots = 1 and palk_kaart.tulumaks = 0  THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0310, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 30 and palk_lib.sots = 0 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0301, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 30 and palk_lib.sots = 1 and palk_kaart.tulumaks = 1  THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0311, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 40 and palk_lib.sots = 0 and palk_kaart.tulumaks = 0   THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0400, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 40 and palk_lib.sots = 1 and palk_kaart.tulumaks = 0  THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0410, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 40 and palk_lib.sots = 0 and palk_kaart.tulumaks = 1   THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0401, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 40 and palk_lib.sots = 1 and palk_kaart.tulumaks = 1  THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0411, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 50 and palk_lib.sots = 0 and palk_kaart.tulumaks = 0  THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0500, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 50 and palk_lib.sots = 1 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0510, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 50 and palk_lib.sots = 0 and palk_kaart.tulumaks = 1  THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0501, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 50 and palk_lib.sots = 1 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0511, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 60 and palk_lib.sots = 0 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0600, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 60 and palk_lib.sots = 1 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0610, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 60 and palk_lib.sots = 0 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0601, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 60 and palk_lib.sots = 1 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0611, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 61 and palk_lib.sots = 0 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_6100, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 61 and palk_lib.sots = 1 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_6110, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 61 and palk_lib.sots = 0 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_6101, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 61 and palk_lib.sots = 1 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_6111, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 62 and palk_lib.sots = 0 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_6200, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 62 and palk_lib.sots = 1 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_6210, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 62 and palk_lib.sots = 0 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_6201, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 62 and palk_lib.sots = 1 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_6211, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 63 and palk_lib.sots = 0 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_6300, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 63 and palk_lib.sots = 1 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_6310, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 63 and palk_lib.sots = 0 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_6301, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 63 and palk_lib.sots = 1 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_6311, 

        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 70 and palk_lib.sots = 0 and palk_kaart.tulumaks = 0  THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0700, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 70 and palk_lib.sots = 1 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0710, 

        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 70 and palk_lib.sots = 0 and palk_kaart.tulumaks = 1  THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0701, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 70 and palk_lib.sots = 1 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0711, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 71 and palk_lib.sots = 0 and palk_kaart.tulumaks = 0  THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_7100, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 71 and palk_lib.sots = 1 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_7110, 

        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 71 and palk_lib.sots = 0 and palk_kaart.tulumaks = 1  THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_7101, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 71 and palk_lib.sots = 1 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_7111, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 72 and palk_lib.sots = 0 and palk_kaart.tulumaks = 0  THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_7200, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 72 and palk_lib.sots = 1 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_7210, 

        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 72 and palk_lib.sots = 0 and palk_kaart.tulumaks = 1  THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_7201, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 72 and palk_lib.sots = 1 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_7211, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 73 and palk_lib.sots = 0 and palk_kaart.tulumaks = 0  THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_7300, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 73 and palk_lib.sots = 1 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_7310, 

        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 73 and palk_lib.sots = 0 and palk_kaart.tulumaks = 1  THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_7301, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 73 and palk_lib.sots = 1 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_7311, 

        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 80 and palk_lib.sots = 0 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0800, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 80 and palk_lib.sots = 1 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0810, 

        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 80 and palk_lib.sots = 0 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0801, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 80 and palk_lib.sots = 1 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0811, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 81 and palk_lib.sots = 0 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_8100, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 81 and palk_lib.sots = 1 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_8110, 

        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 81 and palk_lib.sots = 0 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_8101, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 81 and palk_lib.sots = 1 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_8111, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 82 and palk_lib.sots = 0 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_8200, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 82 and palk_lib.sots = 1 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_8210, 

        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 82 and palk_lib.sots = 0 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_8201, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 82 and palk_lib.sots = 1 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_8211, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 83 and palk_lib.sots = 0 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_8300, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 83 and palk_lib.sots = 1 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_8310, 

        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 83 and palk_lib.sots = 0 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_8301, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 83 and palk_lib.sots = 1 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_8311, 

        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 90 and palk_lib.sots = 0 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0900, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 90 and palk_lib.sots = 1 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0910, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 90 and palk_lib.sots = 0 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0901, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 90 and palk_lib.sots = 1 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_0911, 
 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 100 and palk_lib.sots = 0 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_1000, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 100 and palk_lib.sots = 1 and palk_kaart.tulumaks = 0  THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_1010, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 100 and palk_lib.sots = 0 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_1001, 
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 100 and palk_lib.sots = 1 and palk_kaart.tulumaks = 1  THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_1011, 

        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 110 and palk_lib.sots = 0 and palk_kaart.tulumaks = 0 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_1100,
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 110 and palk_lib.sots = 1 and palk_kaart.tulumaks = 0  THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_1110, 
               CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 110 and palk_lib.sots = 0 and palk_kaart.tulumaks = 1 THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_1101,
        CASE
            WHEN palk_lib.liik = 9 AND palk_oper.journal1id = 110 and palk_lib.sots = 1 and palk_kaart.tulumaks = 1  THEN palk_oper.summa
            ELSE 0::numeric
        END AS erisood_1111

   FROM palk_oper
   JOIN tooleping ON tooleping.id = palk_oper.lepingid
   JOIN asutus ON asutus.id = tooleping.parentid
   JOIN palk_lib ON palk_oper.libid = palk_lib.parentid
   JOIN palk_kaart ON palk_kaart.lepingid = tooleping.id AND palk_kaart.libid = palk_lib.parentid
   Join rekv on palk_oper.rekvid = rekv.id
   where palk_lib.liik = 9;

ALTER TABLE curtsd4 OWNER TO vlad;
GRANT SELECT ON TABLE curtsd4 TO dbpeakasutaja;
GRANT SELECT ON TABLE curtsd4 TO dbkasutaja;
GRANT SELECT ON TABLE curtsd4 TO dbvaatleja;

