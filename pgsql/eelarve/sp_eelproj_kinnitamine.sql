-- Function: sp_eelproj_kinnitamine(integer)

-- DROP FUNCTION sp_eelproj_kinnitamine(integer);

/*
select * from eelproj where rekvid = 122

select sp_eelproj_kinnitamine(68)

select * from eelarve where rekvid = 122
*/

CREATE OR REPLACE FUNCTION sp_eelproj_kinnitamine(integer)
  RETURNS integer AS
$BODY$

DECLARE tnId alias for $1;

	lnresult integer;
	lnTunnus integer;
	lnTunnusId integer;

	lnId integer;

	tmptaotlus record;
	tmpeelproj record;
	ldKpv date;
begin	

lnTunnusId = 0;
lnTunnus = 0;
lnresult = 0;

select * into tmpEelproj from eelproj where id = tnId;  


for tmptaotlus in
	SELECT taotlus.rekvid, taotlus.aasta, taotlus.kuu, taotlus1.summa, taotlus1.muud, 
		taotlus1.kood1, taotlus1.kood2, taotlus1.kood3, taotlus1.kood5 as kood4, taotlus1.kood5, Taotlus.kpv, taotlus1.tunnus,
		taotlus.id as taotlusId, taotlus1.id as taotlus1id, taotlus1.eelprojid, taotlus.tunnus as tun
	from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid 
	WHERE taotlus1.eelprojid = tnid 
	and taotlus.staatus = 3
	and taotlus1.eelarveid = 0

loop

	raise notice 'tmptaotlus.tunnus %',tmptaotlus.tunnus;

	lnTunnus = 0;
	ldKpv = null;
	if tmpTaotlus.tun = 1 then
		lnTunnus = 1;
		ldKpv = tmpTaotlus.kpv;
	end if;

	lnTunnusId = 0;
	IF not empty(ifnull(tmptaotlus.tunnus,space(1))) then
		SELECT id into lnTunnusid FROM library WHERE kood = tmptaotlus.tunnus AND library = 'TUNNUS' AND rekvid = tmptaotlus.rekvid;
		lnTunnusid = ifnull(lnTunnusid,0);
	END IF;
/*

	INSERT INTO eelarve (rekvid, allikasid, aasta, kuu, summa, muud, tunnus, tunnusid, variantid, kood1, kood2, kood3, kood4, kood5, kpv)
			values (tmptaotlus.rekvid,0,tmptaotlus.aasta, tmptaotlus.kuu, tmptaotlus.summa, tmptaotlus.muud, lnTunnus,lnTunnusId, tnId,
			tmptaotlus.kood1, tmptaotlus.kood2, tmptaotlus.kood3, tmptaotlus.kood5, tmptaotlus.kood5, tmpTaotlus.kpv);
			
	lnId:= cast(CURRVAL('public.eelarve_id_seq') as int4);

*/

	raise notice 'Salvestame eelarve ..';
	lnId =  sp_salvesta_eelarve(0, tmptaotlus.rekvid, 0, tmptaotlus.aasta, tmptaotlus.summa, tmpEelProj.muud, lnTunnus, lnTunnusId, tmptaotlus.kood1, 
		tmptaotlus.kood2, tmptaotlus.kood3, tmptaotlus.kood4, tmptaotlus.kood5, tmptaotlus.kuu, ldkpv, 'EUR', 15.6466::numeric);

	if lnId > 0 then 
		
 		update eelarve set variantid = tnId where id = lnId;
 			
		UPDATE taotlus1 SET eelarveId = lnId WHERE id = tmptaotlus.taotlus1id;			

		lnresult = 1;
	end if;	

	raise notice 'Salvestame eelarve ..tehtud %',lnId;

end loop;


RETURN lnresult;

end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_eelproj_kinnitamine(integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_eelproj_kinnitamine(integer) TO vlad;
GRANT EXECUTE ON FUNCTION sp_eelproj_kinnitamine(integer) TO public;
GRANT EXECUTE ON FUNCTION sp_eelproj_kinnitamine(integer) TO eelaktsepterja;
