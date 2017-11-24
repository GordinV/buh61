CREATE OR REPLACE  FUNCTION sp_salvesta_pakett(integer, integer,integer,numeric,numeric,integer,text)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnLibid alias for $2;
	tnNomId alias for $3;
	tnHind alias for $4;
	tnKogus alias for $5;
	tnStatus alias for $6;
	ttFormula alias for $7;


	lnId int; 
	lrCurRec record;
begin

	if tnId = 0 then
			-- lisame uus kiri
		insert into pakett (libid, nomid, hind, kogus,status, formula)
			values (tnLibId, tnNomId, tnHind, tnKogus,tnStatus,ttFormula);
	else
		update pakett set
			nomid = tnNomId,
			libid = tnLibId,
			hind = tnHind,
			kogus = tnKogus,
			status = tnStatus,
			formula = ttFormula
		where id = tnId;

	end if;


         return  tnId;
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_pakett(integer, integer,integer,numeric,numeric,integer,text) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_pakett(integer, integer,integer,numeric,numeric,integer,text) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_pakett(integer, integer,integer,numeric,numeric,integer,text) TO dbpeakasutaja;
