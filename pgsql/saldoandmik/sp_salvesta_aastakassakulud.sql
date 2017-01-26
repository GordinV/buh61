-- Function: sp_salvesta_aasta(integer, integer, integer, integer, integer, integer)

-- DROP FUNCTION sp_salvesta_aasta(integer, integer, integer, integer, integer, integer);

CREATE OR REPLACE FUNCTION sp_salvesta_aastakassakulud(integer, numeric, character varying, numeric, character varying, character varying,character varying,date, integer, 
	integer, integer)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnsumma alias for $2;
	tcvaluuta alias for $3;
	tnkuurs alias for $4;
	tctegev alias for $5;
	tcallikas alias for $6;
	tcart alias for $7;
	tdkpv alias for $8;
	tnaasta alias for $9;
	tnkuu alias for $10;
	tnrekvid alias for $11;

	lnId int; 
	lrCurRec record;
	lcOmaTp character varying;

begin
--	tcomatp alias for $12,
--	tntyyp alias for $13,

	lcOmaTp = fnc_getomatp(tnRekvId,tnAasta);		


if tnId = 0 then
	-- uus kiri
	insert into aastakassakulud (summa,valuuta,kuurs,tegev,allikas,art,kpv,aasta,kuu,rekvid,omatp,tyyp) 
		values (tnsumma,tcvaluuta,tnkuurs,tctegev,tcallikas,tcart,tdkpv,tnaasta,tnkuu,tnrekvid,lcOmatp,1);

	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
		raise notice 'lnId %',lnId;
		lnId:= cast(CURRVAL('public.aastakassakulud_id_seq') as int4);
		raise notice 'lnId %',lnId;
	else
		lnId = 0;
	end if;

	insert into eeltaitmine (rekvid, aasta, kuu,kood1,kood2,kood4,kood5, proj, objekt, summa) 
		values (tnRekvId, tnAasta, tnKuu, tctegev, tcAllikas,tcArt, tcArt,'', '', tnsumma);
/*
	lnId:= cast(CURRVAL('eeltaitmine_id_seq') as int4);
	insert into dokvaluuta1 (dokid, dokliik, kuurs, valuuta) values (lnId, 9, tnKuurs, tcvaluuta);
*/		
else
	-- muuda 
	select * into lrCurRec from aastakassakulud where id = tnId;
	if 	lrCurRec.summa <> tnsumma or 
		lrCurRec.valuuta <> tcValuuta or 
		lrCurRec.kuurs <> tnKuurs or 
		lrCurRec.tegev <> tcTegev or 
		lrCurRec.allikas <> tcAllikas or 
		lrCurRec.art <> tcArt or 
		lrCurRec.kpv <> tdKpv or 
		lrCurRec.aasta <> tnAasta or 
		lrCurRec.kuu <> tnKuu or 
		lrCurRec.rekvid <> tnrekvid or 
		lrCurRec.omatp <> lcOmaTp 
	then 

		update aastakassakulud set 
			summa = tnSumma,
			valuuta = tcValuuta,
			kuurs = tnKuurs,
			tegev = tcTegev,
			allikas = tcAllikas,
			art = tcArt,
			kpv = tdKpv,
			aasta = tnAasta,
			kuu = tnKuu,
			rekvid = tnRekvId,
			omatp = lcOmaTp
		where id = tnId;
	end if;
	lnId := tnId;
end if;

         return  lnId;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_aastakassakulud(integer, numeric, character varying, numeric, character varying, character varying,character varying,date, integer,integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_aastakassakulud(integer, numeric, character varying, numeric, character varying, character varying,character varying,date, integer,integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_aastakassakulud(integer, numeric, character varying, numeric, character varying, character varying,character varying,date, integer,integer, integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_aastakassakulud(integer, numeric, character varying, numeric, character varying, character varying,character varying,date, integer,integer, integer) TO dbvaatleja;
