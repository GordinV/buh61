DROP FUNCTION if exists sp_salvesta_taotlus_mvt(integer, integer, integer, date, date, date, integer, numeric(14,4),  text);

CREATE OR REPLACE FUNCTION sp_salvesta_taotlus_mvt(tn_id integer, tn_rekvid integer, tn_userid integer, td_kpv date, td_alg_kpv date, td_lopp_kpv date, tn_lepingid integer, tn_summa numeric(14,4),  tt_muud text)
  RETURNS integer AS
$BODY$

declare
	lnId int = 0; 
begin

if tn_id = 0 then
	-- uus kiri
	insert into taotlus_mvt (rekvid, userid, kpv, alg_kpv, lopp_kpv, lepingid, summa, muud) 
		values (tn_rekvid, tn_userid, td_kpv, td_alg_kpv, td_lopp_kpv, tn_lepingid, tn_summa, tt_muud)
		returning id into lnId;

else
	-- muuda 
	update taotlus_mvt set 
		kpv = td_kpv,
		alg_kpv = td_alg_kpv , 
		lopp_kpv = td_lopp_kpv, 
		lepingid = tn_lepingid, 
		summa = tn_summa, 
		muud = tt_muud
	where id = tn_id
	returning id into lnId;
	
end if;

         return  lnId;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;

GRANT EXECUTE ON FUNCTION sp_salvesta_taotlus_mvt(integer, integer, integer, date, date, date, integer, numeric(14,4),  text) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_taotlus_mvt(integer, integer, integer, date, date, date, integer, numeric(14,4),  text) TO dbpeakasutaja;
