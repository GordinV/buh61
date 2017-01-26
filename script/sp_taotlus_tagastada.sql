CREATE OR REPLACE FUNCTION sp_taotlus_tagastada(integer, integer)
  RETURNS integer AS
$BODY$

DECLARE tnId alias for $1;
	tnAmetnikId alias for $2;

	lnresult integer;
	tmpEelProj record; 
begin	

lnresult = 0;

SELECT * INTO tmpEelProj from eelproj WHERE id = tnid;
 
IF  tmpEelProj.staatus = 2 then

	UPDATE taotlus SET staatus = 4, AktseptID = tnAmetnikId WHERE id = tnid;
	lnresult = 1;	
ELSE
	lnresult = 0;
END IF;

RETURN lnresult;

end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE;
ALTER FUNCTION sp_taotlus_tagastada(integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_taotlus_tagastada(integer, integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION sp_taotlus_tagastada(integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_taotlus_tagastada(integer, integer) TO dbvaatleja;



select sp_taotlus_tagastada(1, 1) 
