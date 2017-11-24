CREATE OR REPLACE FUNCTION fnc_get_asutuse_staatus(integer, integer)
  RETURNS integer AS
$BODY$

DECLARE tnRekvid alias for $1;
	tnOmaRekv alias for $2;

	lnReturn integer;
	lnParentId integer;
	lnParentIdSub integer;

begin	

lnReturn = 0;
lnParentId = 0;

IF tnrekvid = tnOmaRekv then
	lnReturn = 1;
END IF;


IF lnReturn > 0 then
	RETURN lnReturn;
END IF;

-- sub asutus, see tahendab et parentid = grekv
SELECT parentid into lnParentId FROM rekv WHERE id = tnRekvId ;
IF ifnull(lnParentId,0) > 0 then
	IF lnParentId = tnOmaRekv then
		lnReturn = 2;
	else	
	-- sub sub asutus
		SELECT parentid into lnParentIdSub FROM rekv WHERE id = lnParentId; 
		IF ifnull(lnParentIdSub,0) = tnOmaRekv then
			lnReturn = 3;
		END IF;
	END IF;
END IF;

RETURN lnReturn;

end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE;
ALTER FUNCTION fnc_get_asutuse_staatus(integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION fnc_get_asutuse_staatus(integer, integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION fnc_get_asutuse_staatus(integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION fnc_get_asutuse_staatus(integer, integer) TO dbvaatleja;



select fnc_get_asutuse_staatus(id, 2) from rekv
