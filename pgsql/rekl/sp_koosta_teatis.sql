CREATE OR REPLACE FUNCTION sp_koosta_teatis(integer)
  RETURNS smallint AS
$BODY$

declare 

	tnId alias for $1;
	v_luba record;
	v_dekl record;
	lnresult int;
	lcAlus varchar;

begin
	lnresult = 0;
	select * into v_dekl from toiming where id = tnId;
	select * into v_luba from luba where id = v_dekl.lubaid;

	if v_luba.staatus = 0 then
		raise exception 'Luba anulleritud';
		return 0;
	end if;
	lcAlus = 'Dekl. number:'+ltrim(rtrim(v_luba.number))+space(1)+v_dekl.kpv::varchar;

	lnresult =  sp_salvesta_toiming(0, v_luba.parentid,v_luba.id, date(), lcAlus, ''::character varying, date()+10, 0::numeric, 0::integer, 
		'TEATIS'::character varying, ''::text, 0, 0, (select max(number) from toiming where lubaid = v_dekl.lubaid)+1,'EUR'::character varying,1,null::integer);
		
	Return lnresult;

end; 

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
