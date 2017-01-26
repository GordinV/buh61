-- Function: sp_salvesta_aasta(integer, integer, integer, integer, integer, integer)

/*

select sp_salvesta_aasta(0, 2, 2998, 1, 0, 0);

select * from aasta order by id desc limit 10
*/

-- DROP FUNCTION sp_salvesta_aasta(integer, integer, integer, integer, integer, integer);

CREATE OR REPLACE FUNCTION sp_salvesta_valuuta1(integer, integer, numeric, date, date, text)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnParentId alias for $2;
	tnKuurs alias for $3;
	tdAlates alias for $4;
	tdKuni alias for $5;
	ttMuud alias for $6;

	lnId int; 
	lrCurRec record;
begin
/*

CREATE TABLE valuuta1
(
  id serial NOT NULL,
  parentid integer NOT NULL,
  kuurs numeric(14,4) DEFAULT 1,
  alates date NOT NULL,
  kuni date NOT NULL,
  muud text,
  CONSTRAINT valuuta1_pkey PRIMARY KEY (id)
)
WIT
*/


if tnId = 0 then
	-- uus kiri
	insert into valuuta1 (parentid, kuurs, alates, kuni, muud) 
		values (tnParentId,tnKuurs,ifnull(tdAlates,date()-3600),ifnull(tdKuni,date()+3600),ttMuud);

	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
		raise notice 'lnId %',lnId;
		lnId:= cast(CURRVAL('public.valuuta1_id_seq') as int4);
		raise notice 'lnId %',lnId;
	else
		lnId = 0;
	end if;
else
	-- muuda 
	select * into lrCurRec from valuuta1 where id = tnId;
	if lrCurRec.parentid <> tnParentid or lrCurRec.kuurs <> tnkuurs or lrCurRec.alates <> tdAlates or lrCurRec.kuni <> tdKuni or ifnull(lrCurRec.muud,'null') <> ifnull(ttMuud,'null') then 
	update valuuta1 set 
		parentid = tnParentId,
		kuurs = tnKuurs,
		alates = tdAlates,
		kuni = tdKuni,
		muud = ttMuud
	where id = tnId;
	end if;
	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
		raise notice 'lnId %',lnId;
		lnId = tnid;
	else
		lnId = 0;
	end if;
end if;

         return  lnId;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE;
  
ALTER FUNCTION sp_salvesta_valuuta1(integer, integer, numeric, date, date, text) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_valuuta1(integer, integer, numeric, date, date, text) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_valuuta1(integer, integer, numeric, date, date, text) TO dbpeakasutaja;
