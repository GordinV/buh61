CREATE OR REPLACE FUNCTION sp_taotlus_allkiri(integer, integer)
  RETURNS integer AS
$BODY$

DECLARE tnId alias for $1;
	tnAmetnikId alias for $2;

	lnresult integer;
	tmpTaotlus record;
	
begin	

lnresult = 0;


SELECT * INTO tmpTaotlus from taotlus WHERE id = tnid; 
IF  tmptaotlus.allkiri = 0 then
	UPDATE taotlus SET staatus = 1, allkiri = 1, KoostajaID = tnAmetnikId WHERE id = tnid;
	lnresult = 1;	
ELSE
	lnresult = 0;
END IF;

RETURN lnresult;

end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE;
ALTER FUNCTION sp_taotlus_allkiri(integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_taotlus_allkiri(integer, integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION sp_taotlus_allkiri(integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_taotlus_allkiri(integer, integer) TO dbvaatleja;



--select fnc_get_asutuse_staatus(id, 2) from rekv
