-- Function: sp_salvesta_eelarve(integer, integer, integer, integer, numeric, text, integer, integer, character varying, character varying, character varying, character varying, character varying, integer, date, character varying, numeric)

-- DROP FUNCTION sp_salvesta_eelarve(integer, integer, integer, integer, numeric, text, integer, integer, character varying, character varying, character varying, character varying, character varying, integer, date, character varying, numeric);

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
		raise notice 'lnId %',lnId;
		lneelarveId:= cast(CURRVAL('public.eelarve_id_seq') as int4);
		raise notice 'lneelarveId %',lneelarveId;
	else
		lneelarveId = 0;
	end if;

	if lneelarveId = 0 then
		raise exception ':%','Ei saa lisada kiri';
	end if;

	if (select count(id) from eelarve where id = lneelarveId) > 0 then
		raise notice 'Onnestus';
	else
		raise notice 'Eba onnestus';
	end if; 

		-- valuuta

	insert into dokvaluuta1 (dokid, dokliik, valuuta, kuurs) 
		values (lneelarveId,8,tcValuuta, tnKuurs);


	if (select count(id) from dokvaluuta1 where dokid = lneelarveId and dokliik = 8) > 0 then
		raise notice 'valuuta Onnestus';
	else
		raise notice 'valuuta Eba onnestus';
	end if; 


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
GRANT EXECUTE ON FUNCTION sp_salvesta_eelarve(integer, integer, integer, integer, numeric, text, integer, integer, character varying, character varying, character varying, character varying, character varying, integer, date, character varying, numeric) TO public;
GRANT EXECUTE ON FUNCTION sp_salvesta_eelarve(integer, integer, integer, integer, numeric, text, integer, integer, character varying, character varying, character varying, character varying, character varying, integer, date, character varying, numeric) TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_eelarve(integer, integer, integer, integer, numeric, text, integer, integer, character varying, character varying, character varying, character varying, character varying, integer, date, character varying, numeric) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_eelarve(integer, integer, integer, integer, numeric, text, integer, integer, character varying, character varying, character varying, character varying, character varying, integer, date, character varying, numeric) TO dbpeakasutaja;
