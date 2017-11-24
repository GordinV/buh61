CREATE OR REPLACE FUNCTION sp_eelproj_tuhista(integer, integer)
  RETURNS integer AS
$BODY$

DECLARE tnId alias for $1;
	tnAmetnikId alias for $2;

	lnresult integer;
	tmpEelProj record; 
begin	

lnresult = 0;

SELECT * INTO tmpEelProj from eelproj WHERE id = tnid;
 
IF  tmpEelProj.staatus = 1 then
	--* see tahendab et ainult uks voimalus tuhistada eelrve projekt kui staatus = 1

	UPDATE eelproj SET staatus = 0 WHERE id = tnid;
	lnresult = 1;	
ELSE
	lnresult = 0;
END IF;

RETURN lnresult;

end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE;
ALTER FUNCTION sp_eelproj_tuhista(integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_eelproj_tuhista(integer, integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION sp_eelproj_tuhista(integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_eelproj_tuhista(integer, integer) TO dbvaatleja;



select fnc_get_asutuse_staatus(id, 2) from rekv
