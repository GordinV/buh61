-- Function: sp_salvesta_mk1(integer, integer, integer, integer, numeric, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, integer)

-- DROP FUNCTION sp_salvesta_mk1(integer, integer, integer, integer, numeric, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, integer);

CREATE OR REPLACE FUNCTION sp_salvesta_mk1(integer, integer, integer, integer, numeric, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, integer, character varying)
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
	tcProj alias for $19;
	lnmk1Id int;
	lnId int; 
	lrCurRec record;
	v_dokvaluuta record;
begin

if tnId = 0 then
	-- uus kiri
	insert into mk1 (parentid,asutusid,nomid,summa,aa,pank,kood1,kood2,kood3,kood4,kood5,konto,tp,tunnus, proj) 
		values (tnparentid,tnasutusid,tnnomid,tnsumma,tcaa,tcpank,tckood1,tckood2,tckood3,tckood4,tckood5,tckonto,tctp,tctunnus, tcProj);


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
		or lrCurRec.kood5 <> tckood5 or lrCurRec.konto <> tckonto or lrCurRec.tp <> tctp or lrCurRec.tunnus <> tctunnus or lrCurRec.proj <> tcProj then 
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
		tunnus = tctunnus,
		proj = tcproj
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
ALTER FUNCTION sp_salvesta_mk1(integer, integer, integer, integer, numeric, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, integer, character varying) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_mk1(integer, integer, integer, integer, numeric, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, integer, character varying) TO public;
GRANT EXECUTE ON FUNCTION sp_salvesta_mk1(integer, integer, integer, integer, numeric, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, integer, character varying) TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_mk1(integer, integer, integer, integer, numeric, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, integer, character varying) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_mk1(integer, integer, integer, integer, numeric, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, integer, character varying) TO dbpeakasutaja;
