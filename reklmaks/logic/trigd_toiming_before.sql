-- Function: public.trigiu_library_before()

-- DROP FUNCTION public.trigiu_library_before();

CREATE OR REPLACE FUNCTION public.trigU_library_before()
  RETURNS opaque AS
'
declare 
	v_userid record;
	lresult int;
	lcNotice varchar;
begin
	lresult := 1;
	select * into v_userid from userid where new.rekvid = userid.rekvid and userid.kasutaja = CURRENT_USER::varchar;
	raise notice \'v_userid %\',v_userid.peakasutaja_;
	raise notice \'library %\',new.library;
	raise notice \'user %\',v_userid.kasutaja;

	if (new.library = \'KONTOD\' or new.library = \'ALLIKAS\' OR new.library = \'TEGEV\' OR new.library = \'KONTOD\'
		OR new.library = \'TP\' OR new.library = \'TULUDEALLIKAS\' OR new.library = \'RAHA\') and v_userid.peakasutaja_ < 1 then
		lresult := 0;
		lcNotice := \'Ei ole oigused\'+space(1)+CURRENT_USER::varchar;
		raise notice \'kontrol library %\',new.library;
		return old;

	end if;
	if lResult = 1 then
		if empty (new.kood) or empty (new.library) then
			lresult := 0;
			lcNotice := \'Puudub vajalikud andmed\'+space(1)+CURRENT_USER::varchar;
		end if;
	end if;
	if lResult = 0 then
		raise exception \'Viga: %\',lcNotice;
		return null;
	else
		return new;
	end if;
end; 
'
  LANGUAGE 'plpgsql' VOLATILE;
