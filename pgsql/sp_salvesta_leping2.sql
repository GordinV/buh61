-- Function: sp_salvesta_leping2(integer, integer, integer, numeric, numeric, integer, date, date, numeric, integer, text, text, integer)

-- DROP FUNCTION sp_salvesta_leping2(integer, integer, integer, numeric, numeric, integer, date, date, numeric, integer, text, text, integer);

/*
select sp_salvesta_leping2(20::int,20::int,58::int,1.0000::numeric,150.0000::numeric,0.0000::numeric,NULL,NULL,0.0000::numeric,1::int,''::text,''::text,1::int,'EUR'::varchar,15.6500::numeric)
*/

CREATE OR REPLACE FUNCTION sp_salvesta_leping2(integer, integer, integer, numeric, numeric, integer, date, date, numeric, integer, text, text, integer, varchar, numeric)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnparentid alias for $2;
	tnnomid alias for $3;
	tnkogus alias for $4;
	tnhind alias for $5;
	tnsoodus alias for $6;
	tdsoodusalg alias for $7;
	tdsooduslopp alias for $8;
	tnsumma alias for $9;
	tnstatus alias for $10;
	ttmuud alias for $11;
	ttformula alias for $12;
	tnkbm alias for $13;
	tcValuuta alias for $14;
	tnKuurs alias for $15;
	lnleping2Id int;
	lnId int; 
	lrCurRec record;
	v_dokvaluuta record;
begin

if tnId = 0 then
	-- uus kiri
	insert into leping2 (parentid,nomid,kogus,hind,soodus,soodusalg,sooduslopp,summa,status,muud,formula,kbm) 
		values (tnparentid,tnnomid,tnkogus,tnhind,tnsoodus,tdsoodusalg,tdsooduslopp,tnsumma,tnstatus,ttmuud,ttformula,tnkbm);


	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
		lnleping2Id:= cast(CURRVAL('public.leping2_id_seq') as int4);
	else
		lnleping2Id = 0;
	end if;

	if lnleping2Id = 0 then
		raise exception 'Viga:%','Ei saa lisada kiri';
	end if;

	-- valuuta

	insert into dokvaluuta1 (dokliik,dokid, valuuta, kuurs) 
		values (22, lnleping2Id,tcValuuta, tnKuurs);


else
	-- muuda 
	select * into lrCurRec from leping2 where id = tnId;
	if lrCurRec.parentid <> tnparentid or lrCurRec.nomid <> tnnomid or lrCurRec.kogus <> tnkogus or lrCurRec.hind <> tnhind 
		or lrCurRec.soodus <> tnsoodus or ifnull(lrCurRec.soodusalg,date(1900,01,01)) <> ifnull(tdsoodusalg,date(1900,01,01)) 
		or ifnull(lrCurRec.sooduslopp,date(1900,01,01)) <> ifnull(tdsooduslopp,date(1900,01,01)) or lrCurRec.summa <> tnsumma 
		or lrCurRec.status <> tnstatus or ifnull(lrCurRec.muud,space(1)) <> ifnull(ttmuud,space(1)) or lrCurRec.formula <> ttformula 
		or lrCurRec.kbm <> tnkbm then 

	update leping2 set 
		parentid = tnparentid,
		nomid = tnnomid,
		kogus = tnkogus,
		hind = tnhind,
		soodus = tnsoodus,
		soodusalg = tdsoodusalg,
		sooduslopp = tdsooduslopp,
		summa = tnsumma,
		status = tnstatus,
		muud = ttmuud,
		formula = ttformula,
		kbm = tnkbm
	where id = tnId;
	end if;
	lnleping2Id := tnId;


	-- valuuta
	if (select count(id) from dokvaluuta1 where dokliik = 22 and dokid = lnleping2Id) = 0 then

		insert into dokvaluuta1 (dokliik, dokid, valuuta, kuurs) 
			values (22, lnleping2Id,tcValuuta, tnKuurs);
	else
		select * into v_dokvaluuta from dokvaluuta1 where dokliik = 22 and dokid = lnleping2Id ;

		if tcValuuta <> v_dokvaluuta.valuuta or tnKuurs <> v_dokvaluuta.kuurs then

			update dokvaluuta1 set valuuta = tcValuuta, kuurs = tnKuurs where id = v_dokvaluuta.id;
			
		end if;
	
	end if;


end if;

         return  lnleping2Id;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_leping2(integer, integer, integer, numeric, numeric, integer, date, date, numeric, integer, text, text, integer, varchar, numeric) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_leping2(integer, integer, integer, numeric, numeric, integer, date, date, numeric, integer, text, text, integer, varchar, numeric) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_leping2(integer, integer, integer, numeric, numeric, integer, date, date, numeric, integer, text, text, integer, varchar, numeric) TO dbpeakasutaja;
