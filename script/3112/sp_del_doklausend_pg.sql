-- Function: public.sp_del_arved(int4, int4)

-- DROP FUNCTION public.sp_del_arved(int4, int4);

CREATE OR REPLACE FUNCTION sp_del_doklausend(int4, int4)
  RETURNS int2 AS
'
declare 
begin
	DELETE FROM doklausend WHERE parentid = tnId;
	DELETE FROM doklausheader WHERE id = tnId;
	Return 1;
end; 
'
  LANGUAGE 'plpgsql' VOLATILE;