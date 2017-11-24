-- DROP FUNCTION trigiu_palk_lib_after();

CREATE OR REPLACE FUNCTION trigiu_palk_lib_after_1()
  RETURNS "trigger" AS
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
begin
	raise notice 'START';

	select * into v_library from library where id = new.parentid;
	raise notice 'v_library.rekvid %',v_library.rekvid;

	if v_library.rekvid = 119 then
		select * into v_klassiflib from klassiflib where libid = v_library.id;
		-- def tegev. alla
		raise notice 'v_klassiflib.kood1 %',v_klassiflib.kood1;
		for v_rekv in 
			select id, nimetus from rekv where parentid = 119 and nimetus like ltrim(rtrim(v_klassiflib.kood1))+'%' 
		loop
			raise notice 'v_rekv.nimetus %',v_rekv.nimetus;
			-- kopeerime library
			select id INTO lnId from library where kood = v_library.kood and library = 'PALK' and rekvid = v_rekv.id order by id desc limit 1;
			lnId = ifnull(lnId,0);

			lnLibId = sp_salvesta_library(lnId, v_rekv.id, v_library.kood, v_library.nimetus,v_library.library, v_library.muud, v_library.tun1, v_library.tun2, v_library.tun3, v_library.tun4, v_library.tun5);

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
					(lnlibid, v_klassiflib.tyyp, v_klassiflib.tunnusid, v_klassiflib.kood1, v_klassiflib.kood2,v_klassiflib.kood3, v_klassiflib.kood4, v_klassiflib.kood5, v_klassiflib.konto, v_klassiflib.proj);

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
  LANGUAGE 'plpgsql' VOLATILE;

/*
select * from palk_lib where parentid in (select id from library where library = 'PALK' AND REKVID = 119 and id in (select libid from klassiflib where kood1 = '09220'))

UPDATE PALK_LIB SET LAUSENDID = 0 WHERE ID = 70571

select * from klassiflib where libid in (select id from library where library = 'PALK' AND REKVID = 119)

*/

