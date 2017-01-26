CREATE OR REPLACE FUNCTION public.tmpmenu()  RETURNS int AS'
declare
       lnCount int;
		lnId int;
begin

	
	Select count(id) INTO lncount FROM menupohi Upper(Pad) = ''ARUANNE'' AND bar = ''39'';
	
	IF ifnull(lnCount,0) = 0 then
		Insert Into menupohi (omandus, proc_, level_, Pad, Bar) Values (
			''RUS CAPTION=Декларация INF3
			EST CAPTION=Deklaratsioon INF3'',
			''=nObjekt("do form eelarvearuanne with 39")'', 1,''Aruanne'',''39'');
			
		lnId:= cast(CURRVAL(\'public.menupohi_id_seq\') as int4);
			
		Insert Into menumodul (parentid, Modul) Values (lnId, ''EELARVE'');
		Insert Into menuisik (parentid, gruppid, jah) Values (lnId, ''KASUTAJA'', 1);
		Insert Into menuisik (parentid, gruppid, jah) Values (lnId, ''PEAKASUTAJA'', 1);
		Insert Into menuisik (parentid, gruppid, jah) Values (lnId, ''ADMIN'', 1);
		Insert Into menuisik (parentid, gruppid, jah) Values (lnId, ''VAATLEJA'', 1);

	END IF;

	Select count(id) INTO lncount FROM menupohi Upper(Pad) = ''VANEMTASU'';
	
	If ifnull(lnCount,0) = 0 then
	
		Insert Into menupohi (omandus, proc_, level_, Pad, Bar) Values 
			(''RUS CAPTION=Расходы на обучение
			EST CAPTION=Koolitus kulud'',
			''oVanemtasu = nObjekt("vanemtasu","oVanemtasu",0)'', 1,''File'',''39'');

		lnId:= cast(CURRVAL(\'public.menupohi_id_seq\') as int4);


		Insert Into menumodul (parentid, Modul) Values (lnId, ''EELARVE'');
		Insert Into menuisik (parentid, gruppid, jah) Values (lnId, ''KASUTAJA'', 1);
		Insert Into menuisik (parentid, gruppid, jah) Values (lnId, ''PEAKASUTAJA'', 1);
		Insert Into menuisik (parentid, gruppid, jah) Values (lnId, ''ADMIN'', 1);
		Insert Into menuisik (parentid, gruppid, jah) Values (lnId, ''VAATLEJA'', 1);


		Insert Into menupohi (omandus, level_, Pad ) Values 
			(''RUS CAPTION=Родительская плата
				EST CAPTION=Koolituse tulud'',
			 2,''VANEMTASU'');

		lnId:= cast(CURRVAL(\'public.menupohi_id_seq\') as int4);


		Insert Into menumodul (parentid, Modul) Values (lnId, ''EELARVE'');
		Insert Into menuisik (parentid, gruppid, jah) Values (lnId, ''KASUTAJA'', 1);
		Insert Into menuisik (parentid, gruppid, jah) Values (lnId, ''PEAKASUTAJA'', 1);
		Insert Into menuisik (parentid, gruppid, jah) Values (lnId, ''ADMIN'', 1);
		Insert Into menuisik (parentid, gruppid, jah) Values (lnId, ''VAATLEJA'', 1);


		Insert Into menupohi (omandus, proc_, level_, Pad, Bar) Values ;
			(''RUS CAPTION=Добавить запись
			EST CAPTION=Lisamine
			KeyShortCut=CTRL+A'',;
			''gcWindow.add()'', 2,''VANEMTASU'',''1'')


		lnId:= cast(CURRVAL(\'public.menupohi_id_seq\') as int4);


		Insert Into menumodul (parentid, Modul) Values (lnId, ''EELARVE'');
		Insert Into menuisik (parentid, gruppid, jah) Values (lnId, ''KASUTAJA'', 1);
		Insert Into menuisik (parentid, gruppid, jah) Values (lnId, ''PEAKASUTAJA'', 1);
		Insert Into menuisik (parentid, gruppid, jah) Values (lnId, ''ADMIN'', 1);
		Insert Into menuisik (parentid, gruppid, jah) Values (lnId, ''VAATLEJA'', 1);

		Insert Into menupohi (omandus, proc_, level_, Pad, Bar) Values ;
			(''RUS CAPTION=Внести изменения
			EST CAPTION=Muutmine
			KeyShortCut=CTRL+E'',;
			''gcWindow.edit()'', 2,''VANEMTASU'',''2'')

		lnId:= cast(CURRVAL(\'public.menupohi_id_seq\') as int4);


		Insert Into menumodul (parentid, Modul) Values (lnId, ''EELARVE'');
		Insert Into menuisik (parentid, gruppid, jah) Values (lnId, ''KASUTAJA'', 1);
		Insert Into menuisik (parentid, gruppid, jah) Values (lnId, ''PEAKASUTAJA'', 1);
		Insert Into menuisik (parentid, gruppid, jah) Values (lnId, ''ADMIN'', 1);
		Insert Into menuisik (parentid, gruppid, jah) Values (lnId, ''VAATLEJA'', 1);


		Insert Into menupohi (omandus, proc_, level_, Pad, Bar) Values ;
			(''RUS CAPTION=Удалить запись
			EST CAPTION=Kustutamine
			KeyShortCut=CTRL+DEL'',;
			''gcWindow.delete()'', 2,''VANEMTASU'',''3'')


		lnId:= cast(CURRVAL(\'public.menupohi_id_seq\') as int4);


		Insert Into menumodul (parentid, Modul) Values (lnId, ''EELARVE'');
		Insert Into menuisik (parentid, gruppid, jah) Values (lnId, ''KASUTAJA'', 1);
		Insert Into menuisik (parentid, gruppid, jah) Values (lnId, ''PEAKASUTAJA'', 1);
		Insert Into menuisik (parentid, gruppid, jah) Values (lnId, ''ADMIN'', 1);
		Insert Into menuisik (parentid, gruppid, jah) Values (lnId, ''VAATLEJA'', 1);


		Insert Into menupohi (omandus, proc_, level_, Pad, Bar) Values ;
			(''RUS CAPTION=Печать
			EST CAPTION=Trьkk
			KeyShortCut=CTRL+P'',;
			''gcWindow.print()'', 2,''VANEMTASU'',''4'')


		lnId:= cast(CURRVAL(\'public.menupohi_id_seq\') as int4);


		Insert Into menumodul (parentid, Modul) Values (lnId, ''EELARVE'');
		Insert Into menuisik (parentid, gruppid, jah) Values (lnId, ''KASUTAJA'', 1);
		Insert Into menuisik (parentid, gruppid, jah) Values (lnId, ''PEAKASUTAJA'', 1);
		Insert Into menuisik (parentid, gruppid, jah) Values (lnId, ''ADMIN'', 1);
		Insert Into menuisik (parentid, gruppid, jah) Values (lnId, ''VAATLEJA'', 1);


	Endif








     return 1;
end;
'  LANGUAGE 'plpgsql' VOLATILE;

