-- Function: sp_salvesta_palk_oper(integer, integer, integer, integer, date, numeric, integer, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, character varying)

-- DROP FUNCTION sp_salvesta_palk_oper(integer, integer, integer, integer, date, numeric, integer, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, character varying);

CREATE OR REPLACE FUNCTION sp_salvesta_palk_oper(integer, integer, integer, integer, date, numeric, integer, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, character varying)
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
		values (tnrekvid,tnlibid,tnlepingid,tdkpv,tnsumma,tndoklausid,ttmuud,tckood1,tckood2,tckood3,tckood4,tckood5,tckonto,tctp,tctunnus,ifnull(tcProj,space(1)));


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
ALTER FUNCTION sp_salvesta_palk_oper(integer, integer, integer, integer, date, numeric, integer, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, character varying) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_palk_oper(integer, integer, integer, integer, date, numeric, integer, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, character varying) TO public;
GRANT EXECUTE ON FUNCTION sp_salvesta_palk_oper(integer, integer, integer, integer, date, numeric, integer, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, character varying) TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_palk_oper(integer, integer, integer, integer, date, numeric, integer, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, character varying) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_palk_oper(integer, integer, integer, integer, date, numeric, integer, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, character varying) TO dbpeakasutaja;
