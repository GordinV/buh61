﻿-- Function: sp_salvesta_vanemtasu4(integer, integer, integer, character varying, character varying, integer, numeric, numeric, numeric, character varying, character varying, character varying, character varying, character varying, character varying, character varying, text)

-- DROP FUNCTION sp_salvesta_vanemtasu4(integer, integer, integer, character varying, character varying, integer, numeric, numeric, numeric, character varying, character varying, character varying, character varying, character varying, character varying, character varying, text);

CREATE OR REPLACE FUNCTION sp_salvesta_vanemtasu4(integer, integer, integer, character varying, character varying, integer, numeric, numeric, numeric, character varying, character varying, character varying, character varying, character varying, character varying, character varying, text,character varying,numeric)
  RETURNS integer AS
$BODY$
declare
	tnKuurs alias for $19;

	lnvanemtasu4Id int;
	lnId int; 
	lrCurRec record;

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
	-- muuda 
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