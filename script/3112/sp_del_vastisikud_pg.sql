-- Function: public.sp_del_allikad(int4, int4)

-- DROP FUNCTION public.sp_del_allikad(int4, int4);

CREATE OR REPLACE FUNCTION public.sp_del_vastisikud(int4, int4)
  RETURNS int2 AS
'
declare 
	tnId alias for $1;
	tnOpt alias for $2;
begin
	DELETE FROM vastisikud WHERE id = tnid;
	if found then
		Return 1;
	else
		Return 0;
	end if;
end; 
'
  LANGUAGE 'plpgsql' VOLATILE;
