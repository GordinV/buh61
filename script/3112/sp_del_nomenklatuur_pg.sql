-- Function: public.sp_del_ametid(int4, int4)

-- DROP FUNCTION public.sp_del_ametid(int4, int4);

CREATE OR REPLACE FUNCTION public.sp_del_nomenklatuur(int4, int4)
  RETURNS int2 AS
'
declare 	tnId alias for $1;begin
	DELETE FROM nomenklatuur WHERE id = tnId;
	Return 1;
end; 
'
  LANGUAGE 'plpgsql' VOLATILE;
