-- Function: public.trigu_library_before()

-- DROP FUNCTION public.trigu_library_before();

CREATE OR REPLACE FUNCTION public.trigiu_pv_kaart_after()
  RETURNS opaque AS
'
declare 
	v_userid record;
	lresult int;
	lcNotice varchar;
begin
	perform sp_register_oper(0,new.id, TG_RELNAME::VARCHAR, TG_OP::VARCHAR, sp_currentuser(CURRENT_USER::varchar, 0));
	return null;
end; 
'
  LANGUAGE 'plpgsql' VOLATILE;



CREATE TRIGGER trigiu_pv_kaart_after
  AFTER UPDATE OR INSERT
  ON public.pv_kaart
  FOR EACH ROW
  EXECUTE PROCEDURE public.trigiu_pv_kaart_after();

