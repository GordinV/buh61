
/*
select sp_salvesta_hooleping(        0,        1,      586,        7,'003','Narva-Joesuu',DATE(2012,12,01),DATE(2013,12,31),          100.00,         85.0000,'test')

select * from asutus
 select hl.id, hl.rekvid, hl.isikid, hl.hooldekoduid, hk.nimetus as hooldekodu, hl.number, kov.nimetus as omavalitsus,  hl.algkpv, ifnull(hl.loppkpv,DATE(2099,12,31))::DATE AS LOPPKPV, hl.jaak , hl.summa,  hl.muud::varchar(254) as selg, hl.muud   from hooleping hl inner join asutus hk on hk.id = hl.hooldekoduid  inner join asutus kov on hl.omavalitsusId = kov.id  where hl.isikId =          3
select sp_salvesta_hooleping(        3,        1,        3,        8,'002','       42',date(2013, 1, 1),date(2099,12,31),          100.00,           85.00,'TEST2')
*/

CREATE OR REPLACE FUNCTION sp_salvesta_hooleping(integer, integer, integer, integer, character varying, integer, date, date, numeric, numeric, text)
  RETURNS integer AS
$BODY$
declare
	tnid alias for $1;
	tnrekvid alias for $2;
	tnIsikId alias for $3;
	tnhooldekoduid alias for $4;
	tcNumber alias for $5;
	tnOmavalitsusId alias for $6;
	tdAlgkpv alias for $7;
	tdLoppkpv alias for $8;
	tnSumma alias for $9;
	tnOsa alias for $10;
	ttmuud alias for $11;

	lnId int; 
	lrCurRec record;

begin
raise notice 'tdAlgkpv %',tdAlgkpv;
if tnId = 0 then
	-- uus kiri
	insert into hooleping( rekvid,isikid, hooldekoduid,number, omavalitsus, omavalitsusId, algkpv,loppkpv, muud,summa,osa) 
		values (tnrekvid,tnisikid, tnhooldekoduid,tcnumber,space(1), tnomavalitsusId, tdalgkpv,tdloppkpv, ttmuud,tnsumma,tnosa);

	lnId:= cast(CURRVAL('public.hooleping_id_seq') as int4);

else
	-- muuda 
	update hooleping set 
		isikid = tnIsikId, 
		hooldekoduid = tnhooldekoduid,
		number = tcNumber, 
		omavalitsusid = tnomavalitsusId, 
		algkpv = tdalgkpv,
		loppkpv = tdloppkpv, 
		muud = ttMuud,
		summa = tnSumma,
		osa = tnOsa
	where id = tnId;

	lnId := tnId;

end if;
return  lnId;

end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_hooleping(integer, integer, integer, integer, character varying, integer, date, date, numeric, numeric, text) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_hooleping(integer, integer, integer, integer, character varying, integer, date, date, numeric, numeric, text) TO soametnik;
GRANT EXECUTE ON FUNCTION sp_salvesta_hooleping(integer, integer, integer, integer, character varying, integer, date, date, numeric, numeric, text) TO hkametnik;
