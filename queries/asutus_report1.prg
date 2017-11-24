Parameter cWhere
LOCAL lcString
lcString = ''
IF !USED('v_filter')
	CREATE cursor v_filter (filtr m)
	APPEND blank
ENDIF

lcString = lcString + IIF(!EMPTY(fltrAsutused.regkood), ' reg.kood = '+upper(ltrim(rtrim(fltrAsutused.regkood))),'')
lcString = lcString + IIF(!EMPTY(fltrAsutused.omvorm), ' om.vorm = '+upper(ltrim(rtrim(fltrAsutused.omvorm))),'')
lcString = lcString + IIF(!EMPTY(fltrAsutused.nimetus), ' nimetus = '+upper(ltrim(rtrim(fltrAsutused.nimetus))),'')
lcString = lcString + IIF(!EMPTY(fltrAsutused.tp), ' tp = '+upper(ltrim(rtrim(fltrAsutused.tp))),'')

replace v_filter.filtr WITH lcString IN v_filter

cregKood = '%'+upper(ltrim(rtrim(fltrAsutused.regkood)))+'%'
cOmVorm = '%'+upper(ltrim(rtrim(fltrAsutused.omvorm)))+'%'
cNimetus = '%'+upper(ltrim(rtrim(fltrAsutused.nimetus)))+'%'
tcTp = ltrim(rtrim(fltrAsutused.tp))+'%'
tdkehtivus = fltrAsutused.kehtivus
tcMark = '%'+ALLTRIM(fltrAsutused.mark)+'%'
tcEmail = '%'+ALLTRIM(UPPER(fltrAsutused.email))+'%'

oDb.use('curAsutused','Asutus_report1')
select Asutus_report1

index on left(upper(nimetus),40) tag nimetus
set order to nimetus
IF RECCOUNT('Asutus_report1') < 1
	APPEND blank
ENDIF
