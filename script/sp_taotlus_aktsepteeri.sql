CREATE OR REPLACE FUNCTION sp_taotlus_aktsepteeri(integer, integer)
  RETURNS integer AS
$BODY$

DECLARE tnId alias for $1;
	tnAmetnikId alias for $2;

	lnresult integer;
	lnTunnus integer;
	lnEelProjId integer;
	lnTunnusId integer;

	lnId integer;

	tmpEelProj record; 
	tmptaotlus record;
	tmptaotlus1 record;
begin	

lnTunnusId = 0;
lnEelProjId = 0;
lnTunnus = 0;
lnresult = 0;

SELECT * INTO tmpTaotlus  from taotlus WHERE id = tnid;
IF  tmptaotlus.staatus = 2 then
	UPDATE taotlus SET staatus = 3, AktseptID = tnAmetnikId WHERE id = tnid;
	lnresult = 1;	
ELSE
	lnresult = 0;
END IF;

IF lnresult = 1 then

--* eelarve projektide side
	SELECT id, staatus INTO tmpEelProj FROM eelproj WHERE aasta = tmptaotlus.aasta AND eelproj.staatus > 0 ORDER BY staatus DESC limit 1; 
	IF ifnull(tmpEelProj.id,0)> 0 then		
		lnEelProjId = tmpEelProj.id;
	ELSE
--		* puudub eelarve variant
		lnresult = -1;
	END IF;
	IF lnEelProjId > 0 then
		UPDATE taotlus1 SET eelprojid = lnEelProjId WHERE parentid = tmpTaotlus.id;		
	END IF;
--* eelarve side	
	IF tmpEelProj.staatus = 2 then
--		* eelarve mitte projekt
		
		lnTunnus = 1;
--		* eelarve juba kinnitatud siis see on parandamine
		for  tmptaotlus1 in 
		SELECT * from taotlus1 WHERE parentid = tmpTaotlus.id AND eelarveid = 0
		loop		
			lnTunnusId = 0;
			IF ifnull(tmptaotlus1.tunnus,0) > 0 then
				SELECT id into lnTunnusid FROM library WHERE kood = tmptaotlus1.tunnus AND library = 'TUNNUS' AND rekvid = tmptaotlus.rekvid;
				lnTunnusid = ifnull(lnTunnusid,0);
			END IF;
				
			INSERT INTO eelarve (rekvid, allikasid, aasta, kuu, summa, muud, tunnus, tunnusid, variantid, kood1, kood2, kood3, kood4, kood5, kpv)
			values (tmptaotlus.rekvid,0,tmptaotlus.aasta, tmptaotlus.kuu, taotlus1.summa, taotlus1.muud, lnTunnus,lnTunnusId, lnEelProjId,
			tmptaotlus1.kood1, tmptaotlus1.kood2, tmptaotlus1.kood3, tmptaotlus1.kood4, tmptaotlus1.kood5, tmpTaotlus.kpv);
			

			lnId:= cast(CURRVAL('public.eelarve_id_seq') as int4);

			
			UPDATE taotlus1 SET eelarveId = lnId WHERE id = tmptaotlus1.id;
			
		END loop;		
	END IF;
		
END IF;

RETURN lnresult;

end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE;
ALTER FUNCTION sp_taotlus_aktsepteeri(integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_taotlus_aktsepteeri(integer, integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION sp_taotlus_aktsepteeri(integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_taotlus_aktsepteeri(integer, integer) TO dbvaatleja;



-- sp_taotlus_aktsepteeri(1, 1) 
