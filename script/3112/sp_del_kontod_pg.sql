-- Function: public.sp_del_ametid(int4, int4)

-- DROP FUNCTION public.sp_del_ametid(int4, int4);

CREATE OR REPLACE FUNCTION public.sp_del_kontod(int4, int4)
  RETURNS int2 AS
'
declare 	
	tnId alias for $1;
	lnError int2;
begin
	lnError = sp_del_library(tnid);
	if lnError > 0 then
		DELETE FROM kontoinf WHERE parentid = tnId
		DELETE FROM subkonto WHERE KontoId = tnId
		return 1;
	else
		return 0;
	end if;
end; 
'
  LANGUAGE 'plpgsql' VOLATILE;
