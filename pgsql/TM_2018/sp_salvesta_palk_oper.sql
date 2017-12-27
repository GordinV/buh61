
DROP FUNCTION if exists sp_salvesta_palk_oper(integer, integer, integer, integer, date, numeric, integer, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, character varying, integer, numeric, numeric, numeric, numeric, numeric, numeric, date);

CREATE OR REPLACE FUNCTION sp_salvesta_palk_oper(tnid integer, tnrekvid integer, tnlibid integer, tnlepingid integer, tdkpv date, tnsumma numeric, tndoklausid integer, ttmuud text, 
	tckood1 character varying, tckood2 character varying, tckood3 character varying, tckood4 character varying, tckood5 character varying, tckonto character varying, 
	tctp character varying, tctunnus character varying, tcValuuta character varying, tnKuurs numeric, tcProj character varying, tnTululiik integer, tnTulumaks numeric, 
	tnSotsmaks numeric, tnTootumaks numeric, tnPensmaks numeric, tnTulubaas numeric, tnTKA numeric, tdPeriod date)
  RETURNS integer AS
$BODY$

declare
	lnpalk_operId int;
	lnId int; 
	lrCurRec record;
	v_dokvaluuta record;

	ldKpv1 date = DATE(YEAR(tdKpv),month(tdKpv),1);
	ldKpv2 date = gomonth(ldKpv1,1)  - 1; 
begin


raise notice 'start';

	if tnId = 0 then
		-- uus kiri
		insert into palk_oper (rekvid,libid,lepingid,kpv,summa,doklausid,muud,kood1,kood2,kood3,kood4,kood5,konto,tp,tunnus, proj, journal1id,
			tulumaks, sotsmaks, tootumaks, pensmaks, tulubaas, tka, period) 
			values (tnrekvid,tnlibid,tnlepingid,tdkpv,tnsumma,tndoklausid,ttmuud,tckood1,tckood2,tckood3,tckood4,tckood5,tckonto,tctp,tctunnus,
				ifnull(tcProj,space(1)), tnTuluLiik, 
				ifnull(tnTulumaks,0), ifnull(tnSotsmaks,0), ifnull(tnTootumaks,0), ifnull(tnPensmaks,0), ifnull(tnTulubaas,0), coalesce(tnTKA,0),tdPeriod) 
				returning id into lnpalk_operId;


		if lnpalk_operId = 0 then
			raise exception 'Ei saa lisada kiri %', lnId ;
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
		where id = tnId
		returning id into lnpalk_operId;
	--	end if;

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
	
	-- perform sp_update_palk_jaak(ldKpv1::date,ldKpv2::date, lnRekvId::integer, tnlepingId::integer);
	
--	perform recalc_palk_saldo(tnlepingid::integer ,month(tdkpv)::int2);	
	perform gen_lausend_palk(lnpalk_operId);


	
        return  lnpalk_operId;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
  
GRANT EXECUTE ON FUNCTION sp_salvesta_palk_oper(integer, integer, integer, integer, date, numeric, integer, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, character varying, integer, numeric, numeric, numeric, numeric, numeric, numeric, date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_palk_oper(integer, integer, integer, integer, date, numeric, integer, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, character varying, integer, numeric, numeric, numeric, numeric, numeric, numeric, date) TO dbpeakasutaja;

/*
select * from pg_proc where oid = 234718670


select sp_update_palk_jaak(date(2018,01,01)::date,date(2018,01,31)::date, 121::integer, 132274::integer)

*/