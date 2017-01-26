-- Function: public.sp_del_allikad(int4, int4)

-- DROP FUNCTION public.sp_del_allikad(int4, int4);

CREATE OR REPLACE FUNCTION public.sp_del_dok(int4, int4)
  RETURNS int2 AS
'
declare 
	tnId alias for $1;
	tnOpt alias for $2;
begin
	Delete From library Where Id = tnid;
	Return 1;
end; 
'
  LANGUAGE 'plpgsql' VOLATILE;
