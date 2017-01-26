-- Function: sp_taotlus_aktsepteeri(integer, integer)
/*
select * from taotlus where number = 3 and tunnus = 1 
order by id desc limit 1

select sp_taotlus_aktsepteeri(434, 1713)

update taotlus set staatus = 2 where id = 427


select * from taotlus1 where parentid = 427

select  * from eelarve where id = 73215
delete from eelarve where id = 73215
update taotlus1 set eelarveid = 0 where parentid = 427
*/
-- DROP FUNCTION sp_taotlus_aktsepteeri(integer, integer);

CREATE OR REPLACE FUNCTION sp_taotlus_aktsepteeri(integer, integer, text)
  RETURNS integer AS
$BODY$

DECLARE tnId alias for $1;
	tnAmetnikId alias for $2;
	ttMuud alias for $3;

	lnresult integer;
	lnTunnus integer;
	lnEelProjId integer;
	lnTunnusId integer;

	lnId integer;

	tmpEelProj record; 
	tmptaotlus record;
	tmptaotlus1 record;

	ldKpv date;
	lcSelg text;
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
	SELECT id, staatus, muud INTO tmpEelProj FROM eelproj WHERE aasta = tmptaotlus.aasta AND eelproj.staatus > 0 and rekvid = tmpTaotlus.rekvid ORDER BY staatus DESC limit 1; 
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

--* eelarve side	
	IF tmpEelProj.staatus = 2 then
--		* eelarve mitte projekt
		
		lnTunnus = 1;
--		* eelarve juba kinnitatud siis see on parandamine
		for  tmptaotlus1 in 
		SELECT * from taotlus1 WHERE parentid = tmpTaotlus.id AND eelarveid = 0
		loop		
			lnTunnusId = 0;
			IF not empty(tmptaotlus1.tunnus)  then
				SELECT id into lnTunnusid FROM library WHERE kood = tmptaotlus1.tunnus AND library = 'TUNNUS' AND rekvid = tmptaotlus.rekvid;
				lnTunnusid = ifnull(lnTunnusid,0);
			END IF;
				
			if tmpTaotlus.tunnus = 1 then
				lnTunnus = 1;
				ldKpv = tmpTaotlus.kpv;
				lcSelg = tmpTaotlus.muud;
				-- parandamine
				if not empty(ttMuud) then
					lcSelg = ttMuud;
				end if;
				
			else
				lnTunnus = 0;
				ldKpv = null;
				lcSelg = tmpEelProj.muud;

			end if;
--			raise notice 'tunnus %',lnTunnus;
--			raise notice 'ldKpv %',ldKpv;

			

			lnId =  sp_salvesta_eelarve(0, tmptaotlus.rekvid, 0, tmptaotlus.aasta, tmptaotlus1.summa, lcSelg, lnTunnus, lnTunnusId, tmptaotlus1.kood1, 
				tmptaotlus1.kood2, tmptaotlus1.kood3, tmptaotlus1.kood5, tmptaotlus1.kood5, tmptaotlus.kuu, ldKpv, 'EUR', 15.6466::numeric);

			if lnId > 0 then 
		
				update eelarve set variantid = lnEelProjId, muud = lcSelg where id = lnId;
				
				UPDATE taotlus1 SET eelarveId = lnId WHERE id = tmptaotlus1.id;			

				lnresult = 1;
			end if;	
/*
			
			INSERT INTO eelarve (rekvid, allikasid, aasta, kuu, summa, muud, tunnus, tunnusid, variantid, kood1, kood2, kood3, kood4, kood5, kpv)
			values (tmptaotlus.rekvid,0,tmptaotlus.aasta, tmptaotlus.kuu, tmptaotlus1.summa, tmptaotlus1.muud, lnTunnus,lnTunnusId, lnEelProjId,
			tmptaotlus1.kood1, tmptaotlus1.kood2, tmptaotlus1.kood3, tmptaotlus1.kood5, tmptaotlus1.kood5, tmpTaotlus.kpv);
			

			lnId:= cast(CURRVAL('public.eelarve_id_seq') as int4);

			
			UPDATE taotlus1 SET eelarveId = lnId WHERE id = tmptaotlus1.id;
*/			
		END loop;		
	END IF;
		
END IF;

RETURN lnresult;

end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_taotlus_aktsepteeri(integer, integer, text) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_taotlus_aktsepteeri(integer, integer, text) TO vlad;
GRANT EXECUTE ON FUNCTION sp_taotlus_aktsepteeri(integer, integer, text) TO eelaktsepterja;
