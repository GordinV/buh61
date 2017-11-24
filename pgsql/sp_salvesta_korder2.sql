-- Function: sp_salvesta_korder2(integer, integer, integer, character, numeric, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying)

--DROP FUNCTION sp_salvesta_korder2(integer, integer, integer, character, numeric, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying);
/*
			select ifnull(PROJ,'NULL'),* from korder2 order by id desc limit 1

update korder2 set proj = '' where id = 17

SELECT Korder2.*, Nomenklatuur.kood, Nomenklatuur.nimetus,  Nomenklatuur.hind, ifnull(dokvaluuta1.valuuta,'EEK')::varchar as valuuta, 
ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs 
FROM Korder2 INNER JOIN Nomenklatuur ON Nomenklatuur.id = Korder2.nomid  
left outer join dokvaluuta1 on (korder2.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 11) 
WHERE   Korder2.parentid = 19

*/



CREATE OR REPLACE FUNCTION sp_salvesta_korder2(integer, integer, integer, character, numeric, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying,character varying,numeric,character varying )
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnparentid alias for $2;
	tnnomid alias for $3;
	tcnimetus alias for $4;
	tnsumma alias for $5;
	tckonto alias for $6;
	tckood1 alias for $7;
	tckood2 alias for $8;
	tckood3 alias for $9;
	tckood4 alias for $10;
	tckood5 alias for $11;
	tctp alias for $12;
	tctunnus alias for $13;
	tcValuuta alias for $14;
	tnKuurs alias for $15;
	tcProj alias for $16;
	lnkorder2Id int;
	lnId int; 
	lrCurRec record;
	v_dokvaluuta record;
begin

if tnId = 0 then
	-- uus kiri
	insert into korder2 (parentid,nomid,nimetus,summa,konto,kood1,kood2,kood3,kood4,kood5,tp,tunnus,proj) 
		values (tnparentid,tnnomid,tcnimetus,tnsumma,tckonto,tckood1,tckood2,tckood3,tckood4,tckood5,tctp,tctunnus,tcProj);

	GET DIAGNOSTICS lnId = ROW_COUNT;


	if lnId > 0 then
	--	raise notice 'lnId %',lnId;
		lnkorder2Id:= cast(CURRVAL('public.korder2_id_seq') as int4);
	--	raise notice 'lnaastaId %',lnaastaId;
	else
		lnkorder2Id = 0;
	end if;

	if lnkorder2Id = 0 then
		raise exception ':%','Ei saa lisada kiri';
	end if;

	-- valuuta

	insert into dokvaluuta1 (dokid, dokliik, valuuta, kuurs) 
		values (lnkorder2Id,11,tcValuuta, tnKuurs);


else
	-- muuda 
	select * into lrCurRec from korder2 where id = tnId;
	if lrCurRec.parentid <> tnparentid or lrCurRec.nomid <> tnnomid or lrCurRec.nimetus <> tcnimetus or lrCurRec.summa <> tnsumma or lrCurRec.konto <> tckonto or lrCurRec.kood1 <> tckood1 or lrCurRec.kood2 <> tckood2 or lrCurRec.kood3 <> tckood3 
		or lrCurRec.kood4 <> tckood4 or lrCurRec.kood5 <> tckood5 or lrCurRec.tp <> tctp or lrCurRec.tunnus <> tctunnus or lrCurRec.proj <> tcProj then 
	update korder2 set 
		parentid = tnparentid,
		nomid = tnnomid,
		nimetus = tcnimetus,
		summa = tnsumma,
		konto = tckonto,
		kood1 = tckood1,
		kood2 = tckood2,
		kood3 = tckood3,
		kood4 = tckood4,
		kood5 = tckood5,
		tp = tctp,
		proj = tcProj,
		tunnus = tctunnus
	where id = tnId;
	end if;
	lnkorder2Id := tnId;


	-- valuuta
	if (select count(id) from dokvaluuta1 where dokliik = 11 and dokid = lnkorder2Id) = 0 then

		insert into dokvaluuta1 (dokliik, dokid, valuuta, kuurs) 
			values (11, lnkorder2Id,tcValuuta, tnKuurs);
	else
		select * into v_dokvaluuta from dokvaluuta1 where dokliik = 11 and dokid = lnkorder2Id ;

		if tcValuuta <> v_dokvaluuta.valuuta or tnKuurs <> v_dokvaluuta.kuurs then

			update dokvaluuta1 set valuuta = tcValuuta, kuurs = tnKuurs where id = v_dokvaluuta.id;

						
		end if;
	
	end if;


end if;


	-- kontrollin valuuta arv taabelis

	if (select count(id) from dokvaluuta1 where dokliik = 10 and dokid = tnParentId) = 0 then
	
		insert into dokvaluuta1 (dokid, dokliik, valuuta, kuurs) 
			values (tnParentId,10,tcValuuta, tnKuurs);
	else
	
			update dokvaluuta1 set valuuta = tcValuuta, kuurs = tnKuurs where dokid = tnParentId and dokliik = 10;

	end if;



         return  lnkorder2Id;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_korder2(integer, integer, integer, character, numeric, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying,character varying,numeric,character varying ) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_korder2(integer, integer, integer, character, numeric, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying,character varying,numeric,character varying ) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_korder2(integer, integer, integer, character, numeric, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying,character varying,numeric,character varying ) TO dbpeakasutaja;
