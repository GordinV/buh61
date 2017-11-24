-- Function: public.sp_del_journal(int4, int4)

-- DROP FUNCTION public.sp_del_journal(int4, int4);

CREATE OR REPLACE FUNCTION public.sp_del_artikkel(int4, int4)
  RETURNS int2 AS
'
declare 
	tnId alias for $1;
	lnreturn int2;
begin
	select sp_del_library(tnId) into lnReturn;
	Return lnreturn;
end; 
'
  LANGUAGE 'plpgsql' VOLATILE;
