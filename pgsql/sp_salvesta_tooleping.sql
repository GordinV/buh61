-- Function: sp_salvesta_tooleping(integer, integer, integer, integer, date, date, integer, numeric, integer, integer, integer, integer, integer, integer, character varying, text, integer, integer, character varying, date, character varying, numeric)

-- DROP FUNCTION sp_salvesta_tooleping(integer, integer, integer, integer, date, date, integer, numeric, integer, integer, integer, integer, integer, integer, character varying, text, integer, integer, character varying, date, character varying, numeric);

/*
1	2	   3		4	5  6	7	 8	   9        10       11	
integer, integer, integer, integer, date, date, integer, numeric, integer, integer, integer, integer, integer, integer, character varying, text, integer, integer, character varying, date, character varying, numeric)

*/

CREATE OR REPLACE FUNCTION sp_salvesta_tooleping(integer, integer, integer, integer, date, date, numeric, numeric, integer, integer, numeric, integer, integer, integer, character varying, text, integer, integer, character varying, date, character varying, numeric)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnparentid alias for $2;
	tnosakondid alias for $3;
	tnametid alias for $4;
	tdalgab alias for $5;
	tdlopp alias for $6;
	tntoopaev alias for $7;
	tnpalk alias for $8;
	tnpalgamaar alias for $9;
	tnpohikoht alias for $10;
	tnkoormus alias for $11;
	tnametnik alias for $12;
	tntasuliik alias for $13;
	tnpank alias for $14;
	tcaa alias for $15;
	ttmuud alias for $16;
	tnrekvid alias for $17;
	tnresident alias for $18;
	tcriik alias for $19;
	tdtoend alias for $20;
	tcValuuta alias for $21;
	tnKuurs alias for $22;
	lntoolepingId int;
	lnId int; 
	lrCurRec record;
	v_dokvaluuta record;
begin

if tnId = 0 then
	-- uus kiri
	insert into tooleping (parentid,osakondid,ametid,algab,lopp,toopaev,palk,palgamaar,pohikoht,koormus,ametnik,tasuliik,pank,aa,muud,rekvid,resident,riik,toend) 
		values (tnparentid,tnosakondid,tnametid,tdalgab,tdlopp,tntoopaev,tnpalk,tnpalgamaar,tnpohikoht,tnkoormus,tnametnik,tntasuliik,tnpank,tcaa,ttmuud,tnrekvid,tnresident,tcriik,tdtoend);

	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
	--	raise notice 'lnId %',lnId;
		lntoolepingId:= cast(CURRVAL('public.tooleping_id_seq') as int4);
	--	raise notice 'lnaastaId %',lnaastaId;
	else
		lntoolepingId = 0;
	end if;

	if lntoolepingId = 0 then
		raise exception ':%','Ei saa lisada kiri';
	end if;

	-- valuuta

	insert into dokvaluuta1 (dokid, dokliik, valuuta, kuurs) 
		values (lntoolepingId,19,tcValuuta, tnKuurs);


else
	-- muuda 
	select * into lrCurRec from tooleping where id = tnId;
	if lrCurRec.parentid <> tnparentid or lrCurRec.osakondid <> tnosakondid or lrCurRec.ametid <> tnametid or lrCurRec.algab <> tdalgab 
		or ifnull(lrCurRec.lopp,date(1900,01,01)) <> ifnull(tdlopp,date(1900,01,01)) or lrCurRec.toopaev <> tntoopaev or lrCurRec.palk <> tnpalk 
		or lrCurRec.palgamaar <> tnpalgamaar or lrCurRec.pohikoht <> tnpohikoht or lrCurRec.koormus <> tnkoormus or lrCurRec.ametnik <> tnametnik 
		or lrCurRec.tasuliik <> tntasuliik or lrCurRec.pank <> tnpank or lrCurRec.aa <> tcaa or ifnull(lrCurRec.muud,space(1)) <> ifnull(ttmuud,space(1)) 
		or lrCurRec.rekvid <> tnrekvid or lrCurRec.resident <> tnresident or lrCurRec.riik <> tcriik 
		or ifnull(lrCurRec.toend,date(1900,01,01)) <> ifnull(tdtoend,date(1900,01,01)) then 

	update tooleping set 
		parentid = tnparentid,
		osakondid = tnosakondid,
		ametid = tnametid,
		algab = tdalgab,
		lopp = tdlopp,
		toopaev = tntoopaev,
		palk = tnpalk,
		palgamaar = tnpalgamaar,
		pohikoht = tnpohikoht,
		koormus = tnkoormus,
		ametnik = tnametnik,
		tasuliik = tntasuliik,
		pank = tnpank,
		aa = tcaa,
		muud = ttmuud,
		rekvid = tnrekvid,
		resident = tnresident,
		riik = tcriik,
		toend = tdtoend		
	where id = tnId;
	end if;
	lntoolepingId := tnId;

	-- valuuta
	if (select count(id) from dokvaluuta1 where dokliik = 19 and dokid = lntoolepingId) = 0 then

		insert into dokvaluuta1 (dokliik, dokid, valuuta, kuurs) 
			values (19, lntoolepingId,tcValuuta, tnKuurs);
	else
		select * into v_dokvaluuta from dokvaluuta1 where dokliik = 19 and dokid = lntoolepingId ;

		if tcValuuta <> v_dokvaluuta.valuuta or tnKuurs <> v_dokvaluuta.kuurs then

			update dokvaluuta1 set valuuta = tcValuuta, kuurs = tnKuurs where id = v_dokvaluuta.id;
						
		end if;
	
	end if;


	
end if;

         return  lntoolepingId;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_tooleping(integer, integer, integer, integer, date, date, numeric, numeric, integer, integer, numeric, integer, integer, integer, character varying, text, integer, integer, character varying, date, character varying, numeric) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_tooleping(integer, integer, integer, integer, date, date, numeric, numeric, integer, integer, numeric, integer, integer, integer, character varying, text, integer, integer, character varying, date, character varying, numeric) TO public;
GRANT EXECUTE ON FUNCTION sp_salvesta_tooleping(integer, integer, integer, integer, date, date, numeric, numeric, integer, integer, numeric, integer, integer, integer, character varying, text, integer, integer, character varying, date, character varying, numeric) TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_tooleping(integer, integer, integer, integer, date, date, numeric, numeric, integer, integer, numeric, integer, integer, integer, character varying, text, integer, integer, character varying, date, character varying, numeric) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_tooleping(integer, integer, integer, integer, date, date, numeric, numeric, integer, integer, numeric, integer, integer, integer, character varying, text, integer, integer, character varying, date, character varying, numeric) TO dbpeakasutaja;
