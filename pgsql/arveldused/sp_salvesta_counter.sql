/*
select sp_salvesta_counter(0::int,451::int,date(2010,11,20),0.0000::numeric,100.0000::numeric,''::text)
*/

CREATE OR REPLACE  FUNCTION sp_salvesta_counter(integer, integer,date,numeric,numeric,text, integer)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnparentid alias for $2;
	tdKpv alias for $3;
	tnAlgkogus alias for $4;
	tnLoppKogus alias for $5;
	ttMuud alias for $6;
	tnPaevad alias for $7;
	lnLastNait numeric(14,4);


	lnId int; 
--	lrCurRec record;
begin

	if tnId = 0 then
			-- lisame uus kiri
		insert into counter (parentid, kpv, algkogus, loppkogus, muud, paevad)
			values (tnparentid, tdkpv, tnalgkogus, tnloppkogus, ttmuud, ifnull(tnpaevad,0));
	else
		update counter set
			kpv = tdKpv,
			algkogus = tnAlgKogus,
			loppkogus = tnLoppKogus,
			paevad = ifnull(tnPaevad,0),
			muud = ttMuud
		where id = tnId;

	end if;
	
	select loppkogus into lnLastNait from counter where parentid = tnParentid order by kpv desc limit 1;

	lnLastNait = ifnull(lnLastNait,tnLoppKogus);
	
	update library set tun5 = lnLastNait where id = tnParentId;


         return  tnId;
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_counter(integer, integer,date,numeric,numeric,text, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_counter(integer, integer,date,numeric,numeric,text, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_counter(integer, integer,date,numeric,numeric,text, integer) TO dbpeakasutaja;
