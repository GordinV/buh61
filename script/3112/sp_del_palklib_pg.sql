-- Function: public.sp_del_allikad(int4, int4)

-- DROP FUNCTION public.sp_del_allikad(int4, int4);

CREATE OR REPLACE FUNCTION public.sp_del_palklib(int4, int4)
  RETURNS int2 AS
'
declare 
	tnId alias for $1;
	tnOpt alias for $2;
begin
	if sp_del_library(tnId) > 0 then
		DELETE FROM palk_lib WHERE parentid = tnid;
		Return 1;
	else
		Return 0;

	end if;
end; 
'
  LANGUAGE 'plpgsql' VOLATILE;
