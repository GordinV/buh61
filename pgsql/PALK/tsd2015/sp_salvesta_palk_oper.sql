/*
DROP FUNCTION if exists sp_salvesta_palk_oper(integer, integer, integer, integer, date, numeric, integer, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, character varying, integer);

drop FUNCTION if exists sp_salvesta_palk_oper(integer, integer, integer, integer, date, numeric, integer, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, character varying, integer,
	numeric, numeric, numeric, numeric, numeric);
*/
CREATE OR REPLACE FUNCTION sp_salvesta_palk_oper(integer, integer, integer, integer, date, numeric, integer, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, character varying, integer,
	numeric, numeric, numeric, numeric, numeric, numeric, date)
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
	tnTulumaks alias for $21;
	tnSotsmaks alias for $22;
	tnTootumaks alias for $23;
	tnPensmaks alias for $24;
	tnTulubaas alias for $25;
	tnTKA alias for $26;
	tdPeriod alias for $27;
	lnpalk_operId int;
	lnId int; 
	lrCurRec record;
	v_dokvaluuta record;
begin


raise notice 'start';

if tnId = 0 then
	-- uus kiri
	insert into palk_oper (rekvid,libid,lepingid,kpv,summa,doklausid,muud,kood1,kood2,kood3,kood4,kood5,konto,tp,tunnus, proj, journal1id,
		tulumaks, sotsmaks, tootumaks, pensmaks, tulubaas, tka, period) 
		values (tnrekvid,tnlibid,tnlepingid,tdkpv,tnsumma,tndoklausid,ttmuud,tckood1,tckood2,tckood3,tckood4,tckood5,tckonto,tctp,tctunnus,
			ifnull(tcProj,space(1)), tnTuluLiik, 
			ifnull(tnTulumaks,0), ifnull(tnSotsmaks,0), ifnull(tnTootumaks,0), ifnull(tnPensmaks,0), ifnull(tnTulubaas,0), coalesce(tnTKA,0),tdPeriod);

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
--	select * into lrCurRec from palk_oper where id = tnId;
	/*
	if  lrCurRec.libid <> tnlibid or lrCurRec.lepingid <> tnlepingid or lrCurRec.kpv <> tdkpv or lrCurRec.summa <> tnsumma or 
		lrCurRec.doklausid <> tndoklausid or ifnull(lrCurRec.muud,space(1)) <> ifnull(ttmuud,space(1)) or lrCurRec.kood1 <> tckood1 or 
		lrCurRec.kood2 <> tckood2 or lrCurRec.kood3 <> tckood3 or lrCurRec.kood4 <> tckood4 or lrCurRec.kood5 <> tckood5 or 
		lrCurRec.konto <> tckonto or lrCurRec.tp <> tctp or lrCurRec.tunnus <> tctunnus or ifnull(lrCurRec.proj,'tuhi') <> tcProj then 
*/
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
		tunnus = tctunnus,
		tulumaks = ifnull(tnTulumaks,0),
		Sotsmaks = ifnull(tnSotsmaks,0), 
		Tootumaks = ifnull(tnTootumaks,0), 
		Pensmaks = ifnull(tnPensmaks,0), 
		Tulubaas = ifnull(tnTulubaas,0),
		tka = coalesce(tnTKA,0),
		period = tdPeriod
	where id = tnId;
--	end if;
	lnpalk_operId := tnId;

	raise notice 'updated';
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
--return  lnpalk_operId;
	if lnPalk_operId > 0 then
		perform recalc_palk_saldo(tnlepingid,month(tdkpv)::int2);	
		perform gen_lausend_palk(lnpalk_operId);
	end if;
         return  lnpalk_operId;
end;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

/*
select * from asutus where nimetus ilike '%pereskoka%'

select * from palk_oper po
	inner join tooleping t on po.lepingid = t.id
where parentid = 3557 and kpv = date(2014,12,31)

select sp_salvesta_palk_oper(3725293::int,28::int,615121::int,138203::int,date(2014,12,31),1012.9200::numeric,244::int,'Kokku tunnid kuues:144.0000000000
Kokku tunnid kuues, parandatud:138.0000000000
Tunni hind:7.3400000000
parandamine(nSumma):7.3400000000*100.0000*0.01*138.0000/1.0000
'::text,'01112'::varchar,''::varchar,''::varchar,''::varchar,'5002'::varchar,'50024001'::varchar,'800699'::varchar,''::varchar,'EUR'::varchar,1.0000::numeric,''::varchar,0::int,114.1800::numeric,334.2600::numeric,0.0000::numeric,0.0000::numeric,442.0000::numeric)

sp_salvesta_palk_oper(integer, integer, integer, integer, date, numeric, integer, text, character varying, character varying, character varying, character varying, character varying, character varying, cha; C

sp_salvesta_palk_oper(integer, integer, integer, integer, date, numeric, integer, text, 
character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, 
numeric, character varying, integer,
	numeric default 0, numeric default 0, numeric default 0, numeric default 0, numeric default 0)


		lnPalkOperId = sp_salvesta_palk_oper(
		0, -- 1
		lnRekvid, --2 
		tnLibId, --3
		tnlepingid, 
		tdKpv, 
		lnSumma, 
		tnDoklausid, 
		v_palk_selg.selg, 
		ifnull(v_klassiflib.kood1,space(1)),
		ifnull(v_klassiflib.kood2,'LE-P'), 
		ifnull(v_klassiflib.kood3,space(1)), 
		ifnull(v_klassiflib.kood4,space(1)), 
		ifnull(v_klassiflib.kood5,space(1)), 
		ifnull(v_klassiflib.konto,space(1)), 
		lcTp,
		lcTunnus,
		v_valuuta.kood, 
		v_valuuta.kuurs,v_klassiflib.proj,
			qrypalklib.tululiik, v_palk_selg.tm, v_palk_selg.sm, v_palk_selg.tki, v_palk_selg.pm, v_palk_selg.tulubaas );

*/