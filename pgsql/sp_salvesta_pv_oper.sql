-- Function: sp_salvesta_pv_oper(integer, integer, integer, integer, integer, date, numeric, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, character varying, character varying, character varying, numeric)
/*

select * from curPohivara order by id desc limit 3

select * from dokvaluuta1 where dokliik in (13,18) order by id desc limit 5

*/
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
					values (lnId,18,tcValuuta, tnKuurs);
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

	perform sp_update_pv_jaak(tnParentId);
	
	if tnliik = 1 then
		perform gen_lausend_paigutus(lnpv_operId);
	end if;
	if tnliik = 2 THEN
		perform gen_lausend_kulum(lnpv_operId);
	end if;
	if tnliik = 3 then
		perform gen_lausend_parandus(lnpv_operId);
	end if;
	if tnliik = 4 then
		perform gen_lausend_mahakandmine(lnpv_operId);
	end if;
	if tnliik = 5 then
		perform gen_lausend_umberhindamine(lnpv_operId);
	end if; 
	
         return  lnpv_operId;
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_pv_oper(integer, integer, integer, integer, integer, date, numeric, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, character varying, character varying, character varying, numeric) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_pv_oper(integer, integer, integer, integer, integer, date, numeric, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, character varying, character varying, character varying, numeric) TO public;
GRANT EXECUTE ON FUNCTION sp_salvesta_pv_oper(integer, integer, integer, integer, integer, date, numeric, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, character varying, character varying, character varying, numeric) TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_pv_oper(integer, integer, integer, integer, integer, date, numeric, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, character varying, character varying, character varying, numeric) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_pv_oper(integer, integer, integer, integer, integer, date, numeric, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, character varying, character varying, character varying, numeric) TO dbpeakasutaja;
