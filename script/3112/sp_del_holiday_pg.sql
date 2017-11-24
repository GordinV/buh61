-- Function: public.sp_del_ametid(int4, int4)

-- DROP FUNCTION public.sp_del_ametid(int4, int4);

CREATE OR REPLACE FUNCTION public.sp_del_holiday(int4, int4)
  RETURNS int2 AS
'
declare 	
	tnId alias for $1;
	lnError int2;
begin
	DELETE FROM holiday WHERE id = tnId;
	if found then
		return 1;
	else
		return 0;
	end if;
end; 
'
  LANGUAGE 'plpgsql' VOLATILE;
