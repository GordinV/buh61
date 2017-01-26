-- Function: sp_salvesta_vanemtasu4(integer, integer, integer, character varying, character varying, integer, numeric, numeric, numeric, character varying, character varying, character varying, character varying, character varying, character varying, character varying, text)

-- DROP FUNCTION sp_salvesta_vanemtasu4(integer, integer, integer, character varying, character varying, integer, numeric, numeric, numeric, character varying, character varying, character varying, character varying, character varying, character varying, character varying, text);

CREATE OR REPLACE FUNCTION sp_salvesta_vanemtasu4(integer, integer, integer, character varying, character varying, integer, numeric, numeric, numeric, character varying, character varying, character varying, character varying, character varying, character varying, character varying, text,character varying,numeric)
  RETURNS integer AS
$BODY$
declare	tnid alias for $1;	tnparentid alias for $2;	tnisikid alias for $3;	tcmaksjakood alias for $4;	tcmaksjanimi alias for $5;	tnnomid alias for $6;	tnkogus alias for $7;	tnhind alias for $8;	tnsumma alias for $9;	tckonto alias for $10;	tctp alias for $11;	tckood1 alias for $12;	tckood2 alias for $13;	tckood3 alias for $14;	tckood4 alias for $15;	tckood5 alias for $16;	ttmuud alias for $17;	tcValuuta alias for $18;
	tnKuurs alias for $19;

	lnvanemtasu4Id int;
	lnId int; 
	lrCurRec record;	v_dokvaluuta record;

begin

if tnId = 0 then
	-- uus kiri
	insert into vanemtasu4 (parentid,isikid,maksjakood,maksjanimi,nomid,kogus,hind,summa,konto,tp,kood1,kood2,kood3,kood4,kood5,muud) 
		values (tnparentid,tnisikid,tcmaksjakood,tcmaksjanimi,tnnomid,tnkogus,tnhind,tnsumma,tckonto,tctp,tckood1,tckood2,tckood3,tckood4,tckood5,ttmuud);
	lnvanemtasu4Id:= cast(CURRVAL('public.vanemtasu4_id_seq') as int4);

	
	-- valuuta

	insert into dokvaluuta1 (dokid, dokliik, valuuta, kuurs) 
		values (lnvanemtasu4Id,16,tcValuuta, tnKuurs);



else
	-- muuda 	select * into lrCurRec from vanemtasu4 where id = tnId;	if lrCurRec.parentid <> tnparentid or lrCurRec.isikid <> tnisikid or lrCurRec.maksjakood <> tcmaksjakood or lrCurRec.maksjanimi <> tcmaksjanimi or lrCurRec.nomid <> tnnomid or lrCurRec.kogus <> tnkogus or lrCurRec.hind <> tnhind or lrCurRec.summa <> tnsumma or lrCurRec.konto <> tckonto or lrCurRec.tp <> tctp or lrCurRec.kood1 <> tckood1 or lrCurRec.kood2 <> tckood2 or lrCurRec.kood3 <> tckood3 or lrCurRec.kood4 <> tckood4 or lrCurRec.kood5 <> tckood5 or ifnull(lrCurRec.muud,space(1)) <> ifnull(ttmuud,space(1)) then 	update vanemtasu4 set 		parentid = tnparentid,
		isikid = tnisikid,
		maksjakood = tcmaksjakood,
		maksjanimi = tcmaksjanimi,
		nomid = tnnomid,
		kogus = tnkogus,
		hind = tnhind,
		summa = tnsumma,
		konto = tckonto,
		tp = tctp,
		kood1 = tckood1,
		kood2 = tckood2,
		kood3 = tckood3,
		kood4 = tckood4,
		kood5 = tckood5,
		muud = ttmuud
	where id = tnId;
	end if;
	lnvanemtasu4Id := tnId;


	-- valuuta
	if (select count(id) from dokvaluuta1 where dokliik = 16 and dokid = lnvanemtasu4Id) = 0 then

		insert into dokvaluuta1 (dokliik, dokid, valuuta, kuurs) 
			values (16, lnvanemtasu4Id,tcValuuta, tnKuurs);
	else
		select * into v_dokvaluuta from dokvaluuta1 where dokliik = 16 and dokid = lnvanemtasu4Id ;

		if tcValuuta <> v_dokvaluuta.valuuta or tnKuurs <> v_dokvaluuta.kuurs then
			update dokvaluuta1 set valuuta = tcValuuta, kuurs = tnKuurs where id = v_dokvaluuta.id;						
		end if;
	end if;
end if;

         return  lnvanemtasu4Id;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_vanemtasu4(integer, integer, integer, character varying, character varying, integer, numeric, numeric, numeric, character varying, character varying, character varying, character varying, character varying, character varying, character varying, text,character varying,numeric) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_vanemtasu4(integer, integer, integer, character varying, character varying, integer, numeric, numeric, numeric, character varying, character varying, character varying, character varying, character varying, character varying, character varying, text,character varying,numeric) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_vanemtasu4(integer, integer, integer, character varying, character varying, integer, numeric, numeric, numeric, character varying, character varying, character varying, character varying, character varying, character varying, character varying, text,character varying,numeric) TO dbpeakasutaja;
