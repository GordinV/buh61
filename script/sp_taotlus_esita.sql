CREATE OR REPLACE FUNCTION sp_taotlus_esita(integer, integer)
  RETURNS integer AS
$BODY$

DECLARE tnId alias for $1;
	tnAmetnikId alias for $2;

	lnresult integer;
	lnAllkiri integer;
begin	

lnEelProjId = 0;
lnresult = 0;

SELECT allkiri INTO lnAllkiri from taotlus WHERE id = tnid;
IF  ifnull(tmptaotlus.allkiri,0) = 1 then
	UPDATE taotlus SET staatus = 2, AmetnikID = tnAmetnikId WHERE id = tnid;
	lnresult = 1;	
ELSE
	lnresult = 0;
END IF;


RETURN lnresult;

end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE;
ALTER FUNCTION sp_taotlus_esita(integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_taotlus_esita(integer, integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION sp_taotlus_esita(integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_taotlus_esita(integer, integer) TO dbvaatleja;



select fnc_get_asutuse_staatus(id, 2) from rekv
