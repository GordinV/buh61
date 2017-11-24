-- Function: sp_salvesta_library(integer, integer, character varying, character varying, character varying, text, integer, integer, integer, integer, integer)

-- DROP FUNCTION sp_salvesta_library(integer, integer, character varying, character varying, character varying, text, integer, integer, integer, integer, integer);

CREATE OR REPLACE FUNCTION sp_salvesta_library(integer, integer, character varying, character varying, character varying, text, integer, integer, integer, integer, integer)
  RETURNS integer AS
$BODY$
declare
	tnid alias for $1;
	tnrekvid alias for $2;
	tcKood alias for $3;
	tcNimetus alias for $4;
	tcLibrary alias for $5;
	ttMuud alias for $6;
	tnTun1 alias for $7;
	tnTun2 alias for $8;
	tntun3 alias for $9;
	tntun4 alias for $10;
	tnTun5 alias for $11;
	lnId int; 
	lnLibraryId int;
	lnSumma numeric(12,2);
	v_library record;
	v_rekv	record;
	lcString varchar;

	ldKpv date;


begin

if tnId = 0 then
	-- uus kiri
	insert into library (rekvid, kood, nimetus, library, muud, tun1, tun2, tun3, tun4, tun5) 
		values (tnrekvid, tckood, tcnimetus, tclibrary, ttmuud, tntun1, tntun2, tntun3, tntun4, tntun5);


	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
		lnLibraryId:= cast(CURRVAL('public.library_id_seq') as int4);
	else
		lnLibraryId = 0;
	end if;

	if lnLibraryId = 0 then
		raise exception ':%','Ei saa lisada kiri';
	end if;


else
	-- muuda 

	update library set 
		rekvid = tnrekvid,
		kood = tcKood,
		nimetus = tcNimetus,
		library = tcLibrary,
		muud = ttMuud,
		tun1 = tnTun1,
		tun2 = tnTun2,
		tun3 = tnTun3,
		tun4 = tnTun4,
		tun5 = tnTun5
	where id = tnId;

	lnLibraryId := tnId;
end if;

if (tclibrary = 'PROJ' or tclibrary = 'URITUS' or tclibrary = 'DOK' or tclibrary = 'KAIBEMAKS' or LEFT(tclibrary,3) = 'KBM' 
	or LEFT(tclibrary,7) = 'PASSIVA' ) and tnrekvid = 119 then
	if tnId = 0 then
		insert into library (rekvid, kood, nimetus, library, muud, tun1, tun2, tun3, tun4, tun5)
			select rekv.id, tckood, tcnimetus, tclibrary, ttmuud, tntun1, tntun2, tntun3, tntun4, tntun5 from rekv
				where parentid = 119;
	else

		update library set 
			kood = tckood,
			nimetus = tcnimetus,
			muud = ttmuud,
			tun1 = tntun1,
			tun2 = tntun2,
			tun3 = tntun3,
			tun4 = tntun4,
			tun5 = tntun5
			where rekvid in (select id from rekv where parentid = 119)
			and library.library = tclibrary 
			and library.kood = tckood;
		for v_rekv in
			select id from rekv where parentid = 119 
		loop
			if (select count(id) from library where kood = tcKood and rekvid = v_rekv.id and library = tclibrary) = 0 then
				insert into library (rekvid, kood, nimetus, library, muud, tun1, tun2, tun3, tun4, tun5) values
					(v_rekv.id, tckood, tcnimetus, tclibrary, ttmuud, tntun1, tntun2, tntun3, tntun4, tntun5); 
			end if;

		end loop;


	end if;
end if;

         return  lnLibraryId;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_library(integer, integer, character varying, character varying, character varying, text, integer, integer, integer, integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_library(integer, integer, character varying, character varying, character varying, text, integer, integer, integer, integer, integer) TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_library(integer, integer, character varying, character varying, character varying, text, integer, integer, integer, integer, integer) TO public;
GRANT EXECUTE ON FUNCTION sp_salvesta_library(integer, integer, character varying, character varying, character varying, text, integer, integer, integer, integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_library(integer, integer, character varying, character varying, character varying, text, integer, integer, integer, integer, integer) TO dbpeakasutaja;
