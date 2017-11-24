--DROP TRIGGER trigI_AASTA_after ON AASTA CASCADE

--CREATE TRIGGER trigIU_library_before BEFORE INSERT OR UPDATE ON library
--FOR EACH ROW EXECUTE PROCEDURE trigIU_library_before()

--DROP FUNCTION trigi_aasta_after() cascade

CREATE OR REPLACE FUNCTION trigIU_library_before()  RETURNS trigger AS'
declare 
	v_userid record;
	lresult int;
	lcNotice varchar;
begin
	lresult := 1;
	select * into v_userid from userid where new.rekvid = userid.rekvid and userid.kasutaja = CURRENT_USER::varchar;
	raise notice ''v_userid %'',v_userid.peakasutaja_;
	raise notice ''library %'',new.library;
	raise notice ''user %'',v_userid.kasutaja;

	if (new.library = ''KONTOD'' or new.library = ''ALLIKAS'' OR new.library = ''TEGEV'' OR new.library = ''KONTOD''
		OR new.library = ''TP'' OR new.library = ''TULUDEALLIKAS'' OR new.library = ''RAHA'') and v_userid.peakasutaja_ < 1 then
		lresult := 0;
		lcNotice := ''Ei ole oigused''+space(1)+CURRENT_USER::varchar;
		raise notice ''kontrol library %'',new.library;

	end if;
	if lResult = 1 then
		if empty (new.kood) or empty (new.nimetus) or empty (new.library) then
			lresult := 0;
			lcNotice := ''Puudub vajalikud andmed''+space(1)+CURRENT_USER::varchar;
		end if;
	end if;
	if lResult = 0 then
		raise exception ''Viga: %'',lcNotice;
		return null;
	else
		return new;
	end if;
end; 
'  LANGUAGE 'plpgsql' VOLATILE;
