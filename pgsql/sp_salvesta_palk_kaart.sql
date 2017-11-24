-- Function: sp_salvesta_palk_kaart(integer, integer, integer, integer, numeric, integer, integer, integer, integer, text, integer, integer, character varying, numeric, integer)

-- DROP FUNCTION sp_salvesta_palk_kaart(integer, integer, integer, integer, numeric, integer, integer, integer, integer, text, integer, integer, character varying, numeric, integer);

CREATE OR REPLACE FUNCTION sp_salvesta_palk_kaart(integer, integer, integer, integer, numeric, integer, integer, integer, integer, text, integer, integer, character varying, numeric, integer)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnparentid alias for $2;
	tnlepingid alias for $3;
	tnlibid alias for $4;
	tnsumma alias for $5;
	tnpercent_ alias for $6;
	tntulumaks alias for $7;
	tntulumaar alias for $8;
	tnstatus alias for $9;
	ttmuud alias for $10;
	tnalimentid alias for $11;
	tntunnusid alias for $12;
	tcValuuta alias for $13;
	tnKuurs alias for $14;
	tnMinSots alias for $15;
	lnpalk_kaartId int;
	lnId int; 
	lrCurRec record;
	v_dokvaluuta record;
begin

if tnId = 0 then
	-- uus kiri
	insert into palk_kaart (parentid,lepingid,libid,summa,percent_,tulumaks,tulumaar,status,muud,alimentid,tunnusid, minsots) 
		values (tnparentid,tnlepingid,tnlibid,tnsumma,tnpercent_,tntulumaks,tntulumaar,tnstatus,ttmuud,tnalimentid,tntunnusid, tnMinSots) returning id into lnpalk_kaartId;



	if lnpalk_kaartId = 0 then
		raise exception ':%','Ei saa lisada kiri';
	end if;

	raise notice 'new palk_kaart id = %', lnpalk_kaartId;

	-- valuuta

	if tnKuurs <> 0  then
		insert into dokvaluuta1 (dokid, dokliik, valuuta, kuurs) 
			values (lnpalk_kaartId,20,tcValuuta, tnKuurs);
	end if;


else
	-- muuda 
	select * into lrCurRec from palk_kaart where id = tnId;
	/*
	if lrCurRec.parentid <> tnparentid or lrCurRec.lepingid <> tnlepingid or lrCurRec.libid <> tnlibid or lrCurRec.summa <> tnsumma 
		or lrCurRec.percent_ <> tnpercent_ or lrCurRec.tulumaks <> tntulumaks or lrCurRec.tulumaar <> tntulumaar or lrCurRec.status <> tnstatus 
		or ifnull(lrCurRec.muud,space(1)) <> ifnull(ttmuud,space(1)) or lrCurRec.alimentid <> tnalimentid or lrCurRec.tunnusid <> tntunnusid then 
	*/	
	update palk_kaart set 
		summa = tnsumma,
		percent_ = tnpercent_,
		tulumaks = tntulumaks,
		tulumaar = tntulumaar,
		status = tnstatus,
		muud = ttmuud,
		alimentid = tnalimentid,
		tunnusid = tntunnusid,
		minsots = tnMinSots
	where id = tnId;
	
	lnpalk_kaartId := tnId;
end if;


--		parentid = tnparentid,
--		lepingid = tnlepingid,
--		libid = tnlibid,

	-- valuuta
	
	if tnKuurs <> 0 and  (select count(id) from dokvaluuta1 where dokliik = 20 and dokid = lnpalk_kaartId) = 0 then

		insert into dokvaluuta1 (dokliik, dokid, valuuta, kuurs) 
			values (20, lnpalk_kaartId,tcValuuta, tnKuurs);
	else
		select * into v_dokvaluuta from dokvaluuta1 where dokliik = 20 and dokid = lnpalk_kaartId ;

		if tcValuuta <> v_dokvaluuta.valuuta or tnKuurs <> v_dokvaluuta.kuurs then

			update dokvaluuta1 set valuuta = tcValuuta, kuurs = tnKuurs where id = v_dokvaluuta.id;
						
		end if;
	
	end if;

--end if;
	raise notice 'palk_kaart saved, returning %', lnpalk_kaartId;
         return  lnpalk_kaartId;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_palk_kaart(integer, integer, integer, integer, numeric, integer, integer, integer, integer, text, integer, integer, character varying, numeric, integer) OWNER TO vlad;
