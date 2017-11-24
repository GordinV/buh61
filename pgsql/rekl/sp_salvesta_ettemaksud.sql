-- Function: sp_salvesta_aa(integer, integer, character, character, numeric, integer, integer, integer, character, text, character varying)

-- DROP FUNCTION sp_salvesta_aa(integer, integer, character, character, numeric, integer, integer, integer, character, text, character varying);

CREATE OR REPLACE FUNCTION sp_salvesta_ettemaksud(integer, integer,integer,integer,integer,date,numeric, integer, text, text, integer)
  RETURNS integer AS
$BODY$
declare
	tnid alias for $1;
	tnRekvId alias for $2;
	tnAsutusId alias for $3;
	tnDokid alias for $4;
	tnDokTyyp alias for $5;
	tdKpv alias for $6;
	tnSumma alias for $7;
	tnNumber alias for $8;
	ttSelg alias for $9;
	ttmuud alias for $10;
	tnJournal1Id alias for $11;
	lnId int; 

begin



if tnId = 0 then

	-- uus kiri

	insert into ettemaksud (rekvid, asutusid, dokid, doktyyp, kpv, summa, number, selg, muud, journalid) 
		values (tnrekvid, tnasutusid, tndokid, tndoktyyp, tdkpv, tnsumma, tnnumber, ttselg, ttmuud, tnJournal1Id);

	lnId:= cast(CURRVAL('public.ettemaksud_id_seq') as int4);

else
	-- muuda 

	update ettemaksud set 
		rekvid = tnRekvid,
		asutusid = tnAsutusId,
		dokid = tnDokid,
		doktyyp = tnDoktyyp,
		kpv = tdKpv,
		Summa = tnSumma,
		number = tnNumber,
		muud = ttmuud,
		selg = ttSelg,
		journalid = tnJournal1id
		where id = tnId;

	lnId := tnId;
end if;

perform fncReklEttemaksStaatus(tnasutusid);

return  lnId;

end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_ettemaksud(integer, integer,integer,integer,integer,date,numeric, integer, text, text, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_ettemaksud(integer, integer,integer,integer,integer,date,numeric, integer, text, text, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_ettemaksud(integer, integer,integer,integer,integer,date,numeric, integer, text, text, integer) TO dbpeakasutaja;
