-- Function: sp_taotlus_allkiri(integer, integer)

-- DROP FUNCTION sp_taotlus_allkiri(integer, integer);

CREATE OR REPLACE FUNCTION sp_taotlus_allkiri(integer, integer)
  RETURNS integer AS
$BODY$

DECLARE tnId alias for $1;
	tnAmetnikId alias for $2;

	lnresult integer;
	tmpTaotlus record;
	tmpEelProj record;

	lnEelProjId integer;
begin	

lnresult = 0;

SELECT * INTO tmpTaotlus from taotlus WHERE id = tnid; 

--* eelarve projektide side
	SELECT id, staatus INTO tmpEelProj FROM eelproj WHERE aasta = tmptaotlus.aasta AND eelproj.staatus > 0 and rekvid = tmpTaotlus.rekvid ORDER BY staatus DESC limit 1; 
	IF ifnull(tmpEelProj.id,0)> 0 then		
		lnEelProjId = tmpEelProj.id;
	ELSE
--		* puudub eelarve variant
--		lnresult = -1;
		lnEelProjId = sp_salvesta_eelproj(0, tmpTaotlus.rekvid, tmpTaotlus.aasta, tmpTaotlus.kuu, 1,0, '');

	END IF;
	IF lnEelProjId > 0 then
		UPDATE taotlus1 SET eelprojid = lnEelProjId WHERE parentid = tmpTaotlus.id;		
	END IF;


IF  tmptaotlus.allkiri = 0 then
	UPDATE taotlus SET staatus = 1, allkiri = 1, KoostajaID = tnAmetnikId WHERE id = tnid;
	lnresult = 1;	
ELSE
	lnresult = 0;
END IF;

RETURN lnresult;

end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_taotlus_allkiri(integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_taotlus_allkiri(integer, integer) TO vlad;
GRANT EXECUTE ON FUNCTION sp_taotlus_allkiri(integer, integer) TO eelallkirjastaja;
