-- Function: trigiu_palk_lib_after_1()

-- DROP FUNCTION trigiu_palk_lib_after_1();

CREATE OR REPLACE FUNCTION trigiu_palk_lib_after_1()
  RETURNS trigger AS
$BODY$
declare 
	v_userid record;
	lresult int;
	lcNotice varchar;
	v_library record;
	v_klassiflib record;
	v_rekv record;
	lnid int;
	lnLibId int;
	lcRekvNimetus varchar;

	lcTunnus varchar;

begin

	select * into v_library from library where id = new.parentid;
	select nimetus into lcRekvNimetus from rekv where id = v_library.rekvid;
	select * into v_klassiflib from klassiflib where libid = v_library.id;
	raise notice 'v_klassiflib.kood1 %',v_klassiflib.kood1;
	lcTunnus = '';
--	raise notice 'v_library.rekvid %',v_library.rekvid;

--  kas parentid = 119
/*
	if v_library.rekvId = 66  then
		lcTunnus = '0810101';
	elseif v_library.rekvid = 68 then
		lcTunnus = '0810501';		
	elseif v_library.rekvid = 74 then
		lcTunnus = '0810799';		
	elseif v_library.rekvid = 75 then
		lcTunnus = '0820101';		
	elseif v_library.rekvid = 79 then
		lcTunnus = '0820601';		
	elseif v_library.rekvid = 119 then
		lcTunnus = '0860001';		
	elseif v_library.rekvid = 80 then
		lcTunnus = '0911006';		
	elseif v_library.rekvid = 104 then
		lcTunnus = '0921259';		
	elseif v_library.rekvid = 106 then
		lcTunnus = '0922051';		
	elseif v_library.rekvid = 114 then
		lcTunnus = '0922177';		
	elseif v_library.rekvid = 115 then
		lcTunnus = '0950070';		
	elseif v_library.rekvid = 125 then
		lcTunnus = '0810202';	
		raise notice 'lcTunnus	%',lcTunnus;
	elseif v_library.rekvid = 72 then
		lcTunnus = '0810671';		
	end if;
*/
	raise notice '1 lcRekvNimetus %, lcTunnus %, v_klassiflib.kood1 %',lcRekvNimetus, lcTunnus, v_klassiflib.kood1;
	if (select count(id) from all_asutused where parentId = v_library.rekvid) > 0 then
		raise notice 'parandame';
		-- Paemurru
		-- def tegev. alla
		for v_rekv in 
			select id, nimetus from rekv where id in (select childId from all_asutused where parentid = v_library.rekvid)  and id <> v_library.rekvid 
		loop
			raise notice 'v_rekv.nimetus %',v_rekv.nimetus;
			-- kopeerime library
			select id INTO lnId from library where kood = v_library.kood and library = 'PALK' and rekvid = v_rekv.id order by id desc limit 1;
			lnId = ifnull(lnId,0);
			raise notice 'lnId %',lnId;

			lnLibId = sp_salvesta_library(lnId, v_rekv.id, v_library.kood, v_library.nimetus,v_library.library, v_library.muud, v_library.tun1, v_library.tun2, v_library.tun3, v_library.tun4, v_library.tun5);
			raise notice 'lnLibId %',lnLibId;

			-- kooperime klassiflib
			if (select count(id) from klassiflib where libid = lnLibId) > 0 then
				-- parandame
				update klassiflib set
					tyyp = v_klassiflib.tyyp,
					tunnusid = v_klassiflib.tunnusid,
					kood1 = v_klassiflib.kood1,
					kood2 = v_klassiflib.kood2,
					kood3 = v_klassiflib.kood3,
					kood4 = v_klassiflib.kood4,
					kood5 = v_klassiflib.kood5,
					konto = v_klassiflib.konto,
					proj = v_klassiflib.proj 
					where libId = lnLibId;
			else
				insert into klassiflib (libid, tyyp, tunnusid, kood1, kood2,kood3, kood4, kood5, konto, proj) values 
					(lnlibid, v_klassiflib.tyyp, coalesce(v_klassiflib.tunnusid,0), coalesce(v_klassiflib.kood1,''), coalesce(v_klassiflib.kood2,''),
					coalesce(v_klassiflib.kood3,''), coalesce(v_klassiflib.kood4,''), coalesce(v_klassiflib.kood5,''), coalesce(v_klassiflib.konto,''), 
					coalesce(v_klassiflib.proj,''));

			end if;
			-- kooperimie palk_lib
			if (select count(id) from palk_lib where parentId = lnLibId) = 0 then
				insert into palk_lib (parentid,liik, tund,maks, palgafond, asutusest,lausendid ,algoritm, muud, round, sots, konto, elatis, tululiik) values 
					(lnLibId,new.liik, new.tund,new.maks, new.palgafond, new.asutusest,new.lausendid ,new.algoritm, new.muud, new.round, new.sots, new.konto, new.elatis, new.tululiik);
			else
				update palk_lib set
					liik = new.liik, 
					tund = new.tund,
					maks = new.maks, 
					palgafond = new.palgafond, 
					asutusest = new.asutusest,
					lausendid = new.lausendid,
					algoritm = new.algoritm, 
					muud = new.muud, 
					round = new.round, 
					sots = new.sots, 
					konto = new.konto, 
					elatis = new.elatis, 
					tululiik = new.tululiik
					where parentid = lnLibId;
			end if;

		end loop;


	end if;
--	perform sp_register_oper(0,new.id, TG_RELNAME::VARCHAR, TG_OP::VARCHAR, sp_currentuser(CURRENT_USER::varchar, 0));
	return null;

end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION trigiu_palk_lib_after_1() OWNER TO vlad;
GRANT EXECUTE ON FUNCTION trigiu_palk_lib_after_1() TO public;
GRANT EXECUTE ON FUNCTION trigiu_palk_lib_after_1() TO vlad;
GRANT EXECUTE ON FUNCTION trigiu_palk_lib_after_1() TO dbkasutaja;
GRANT EXECUTE ON FUNCTION trigiu_palk_lib_after_1() TO dbpeakasutaja;
