CREATE OR REPLACE FUNCTION sp_salvesta_eelarve(integer, integer, integer, integer, numeric, numeric, text, integer, integer, character varying, character varying, character varying, character varying, character varying, integer, date, character varying, numeric)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnrekvid alias for $2;
	tnallikasid alias for $3;
	tnaasta alias for $4;
	tnsumma alias for $5;
	tnsumma_k alias for $6;
	ttmuud alias for $7;
	tntunnus alias for $8;
	tntunnusid alias for $9;
	tckood1 alias for $10;
	tckood2 alias for $11;
	tckood3 alias for $12;
	tckood4 alias for $13;
	tckood5 alias for $14;
	tnkuu alias for $15;
	tdkpv alias for $16;
	tcValuuta alias for $17;
	tnKuurs alias for $18;
	lneelarveId int = 0;
	lnId int; 
	lrCurRec record;
	v_dokvaluuta record;
	
begin

if tnId = 0 then
	-- uus kiri
	insert into eelarve (rekvid,allikasid,aasta,summa,summa_k,muud,tunnus,tunnusid,kood1,kood2,kood3,kood4,kood5,kuu,kpv) 
		values (tnrekvid,tnallikasid,tnaasta,tnsumma,tnsumma_k, ttmuud,tntunnus,tntunnusid,tckood1,tckood2,tckood3,tckood4,tckood5,tnkuu,tdkpv) returning id into lneelarveId;

	if lneelarveId > 0 then
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
		summa_k = tnsumma_k,
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

GRANT EXECUTE ON FUNCTION sp_salvesta_eelarve(integer, integer, integer, integer, numeric, numeric,text, integer, integer, character varying, character varying, character varying, character varying, character varying, integer, date, character varying, numeric) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_eelarve(integer, integer, integer, integer, numeric, numeric, text, integer, integer, character varying, character varying, character varying, character varying, character varying, integer, date, character varying, numeric) TO dbpeakasutaja;
