-- Function: sp_luba_annuleri(integer)

-- DROP FUNCTION sp_luba_annuleri(integer);

CREATE OR REPLACE FUNCTION sp_luba_annuleri(integer)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	v_luba record;
	lnResult int; 
	lnDokProp int;
begin
	lnresult = 0;
	lnDokProp = 0;
	select * into v_luba from luba where id = tnId;

	lnResult = sp_salvesta_toiming(0, v_luba.parentid,v_luba.id, date(), '', '', date(), 0, 1, 'ANULLERI', '', 0, lnDokProp,0,fnc_currentvaluuta(date()),fnc_currentkuurs(date()) );
	perform sp_muuda_lubastaatus(tnId, 0);
	

return  lnResult;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION sp_luba_annuleri(integer)
  OWNER TO vlad;
