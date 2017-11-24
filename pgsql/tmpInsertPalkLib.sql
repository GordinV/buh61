/*
-- Function: adk(character varying, integer, integer, date, date)
select tmpInsertPalkLib()
select * from rekv where id = 106
-- DROP FUNCTION adk(character varying, integer, integer, date, date);
select * from library where id = 609710
SELECT * FROM PALK_LIB WHERE PARENTID = 609710

*/

CREATE OR REPLACE FUNCTION tmpInsertPalkLib()
  RETURNS integer AS
$BODY$

DECLARE v_lib record;
	lnCount integer;
	lnLibId integer;
begin	
	lnCount = 0;
	for v_lib in  
		select * from library 
		where rekvid in (107,108,105,121,112,113,114)
		and library = 'PALK'
		and kood like '%OPE%' and ltrim(rtrim(kood)) like '%R'
		and nimetus like '%GUMNAASIUMIDE OPETAJATE%' 
		and nimetus like '%RE-HK%'

	loop
		raise notice 'v_lib.id %',v_lib.id;

		-- kooperimine
		insert into library (rekvid, kood, nimetus,library, muud, tun1, tun2, tun3, tun4, tun5)
			values (v_lib.rekvid,left(ltrim(rtrim(v_lib.kood)),len(ltrim(rtrim(v_lib.kood)))-1)+'G',ltrim(rtrim(v_lib.nimetus))+'G',
				v_lib.library, v_lib.muud, v_lib.tun1, v_lib.tun2, v_lib.tun3, v_lib.tun4, v_lib.tun5);

		select id into lnLibId from library order by id desc limit 1;
		-- vahetame kood

		update library set kood = left(ltrim(rtrim(v_lib.kood)),len(ltrim(rtrim(v_lib.kood)))-1)+'P', nimetus = ltrim(rtrim(nimetus))+'P' where id = v_lib.id;

		-- kooperime palk_lib
			
		lnLibId = ifnull(lnLibId,0);

			if lnLibId > 0 then
				raise notice 'LnLibId %',lnLibId;
				if (select count(id) from palk_lib where parentid = v_lib.id) = 0 then
					insert into palk_lib (parentid, liik,tund, maks, palgafond, asutusest,lausendid,algoritm,muud,round,sots, konto,elatis , tululiik)
					select v_lib.id, liik,tund, maks, palgafond, asutusest,lausendid,algoritm,muud,round,sots, konto,elatis , tululiik from palk_Lib 
					where parentId = lnLibId;
				end if;
				if (select count(id) from  klassiflib where libid = v_lib.id) = 0 then
					insert into klassiflib (libid, tyyp, tunnusid, kood1,kood2, kood3,kood4,kood5,konto,proj)
						select v_lib.id, tyyp, tunnusid, kood1,ltrim(rtrim(kood2))+'G', kood3,kood4,kood5,konto,proj from klassiflib 
						where libid = lnLibId;
				end if;
				lnCount = lnCount + 1;
--				update klassiflib set kood2 = 'RE-HKG' WHERE libId = v_lib.id;
		end if;
		-- uuendame allikas
		update klassiflib set kood2 = 'RE-HKP' WHERE libId = v_lib.id;
	
	end loop;
/*	
	select * from palk_lib where parentid in (

	select id from library where rekvid = 106 and library = 'PALK'
	and kood like '%OPE%' and ltrim(rtrim(kood)) like '%P'
	and nimetus like '%GUMNAASIUMIDE OPETAJATE%' 
	and nimetus like '%RE-HK%'
	)
*/
	return lnCount;
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
