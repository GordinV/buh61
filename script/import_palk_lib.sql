-- Function: trigiu_palk_lib_after_1()

-- DROP FUNCTION trigiu_palk_lib_after_1();

CREATE OR REPLACE FUNCTION import_palk_lib()
  RETURNS integer AS
$BODY$
declare 
	v_userid record;
	lresult int;
	lcNotice varchar;
	v_library record;
	v_klassiflib record;
	v_palk_lib record;
	lnid int;
	lnLibId int;
	lcRekvNimetus varchar;

	lcTunnus varchar;

begin
	for v_library in 
		select *  
			from library 
			where rekvid = 63 and library = 'PALK'
	loop	

		select * into v_klassiflib from klassiflib where libid = v_library.id;

		select * into v_palk_lib from palk_lib where parentid = v_library.id;
		lcTunnus = '';

		-- kopeerime library
		select id INTO lnId from library where kood = v_library.kood and library = 'PALK' and rekvid = 3 order by id desc limit 1;
		lnId = ifnull(lnId,0);

		lnLibId = sp_salvesta_library(lnId, 3, v_library.kood, v_library.nimetus,v_library.library, v_library.muud, v_library.tun1, v_library.tun2, v_library.tun3, v_library.tun4, v_library.tun5);
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
				(lnLibId,v_palk_lib.liik, v_palk_lib.tund,v_palk_lib.maks, v_palk_lib.palgafond, v_palk_lib.asutusest,v_palk_lib.lausendid,
					v_palk_lib.algoritm, v_palk_lib.muud, v_palk_lib.round, v_palk_lib.sots, v_palk_lib.konto, v_palk_lib.elatis, v_palk_lib.tululiik);
		else
			update palk_lib set
				liik = v_palk_lib.liik, 
				tund = v_palk_lib.tund,
				maks = v_palk_lib.maks, 
				palgafond = v_palk_lib.palgafond, 
				asutusest = v_palk_lib.asutusest,
				lausendid = v_palk_lib.lausendid,
				algoritm = v_palk_lib.algoritm, 
				muud = v_palk_lib.muud, 
				round = v_palk_lib.round, 
				sots = v_palk_lib.sots, 
				konto = v_palk_lib.konto, 
				elatis = v_palk_lib.elatis, 
				tululiik = v_palk_lib.tululiik
				where parentid = lnLibId;
		end if;

	end loop;
	return 1;

end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;



/*
select import_palk_lib()



*/