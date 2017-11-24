*!*	Test

CLEAR ALL
gnHandle = SQLConnect('narvalv_koopia')
docId = 0
tnIsikId = 2894
gRekv = 119
gcDatabase = 'narvalv_koopia'

SET PROCEDURE TO proc/err

If gnHandle < 0
	Messagebox('connection error')
	Set Step On
	Return
ENDIF
gVersia = 'PG'
Set classlib to classes\classlib
oDb = createobject('db')

IF vartype(oDb) <> 'O'
	Messagebox('oDb error')
	Set Step On
	Return

ENDIF


Set Console On

l_success = test_table_structure()

IF l_success 
	l_success = test_save_proc()
ENDIF

IF l_success 
	l_success = test_select_data()
ENDIF

IF l_success 
	l_success = test_V_TAOTLUS_mvt_data()
ENDIF

IF l_success 
	l_success = test_calc_MVT()
ENDIF

IF l_success 
	l_success = test_delete_proc()
ENDIF


Set Console Off
IF gnHandle > 0 
	=SQLDISCONNECT(gnHandle)
ENDIF

Function test_sp_calc_arv
Local l_success, test_name, result
test_name = 'test for calc_mvt'
result = ' passed'
l_success = .t.

? test_name

TEXT TO lcString
	select pronargs::integer from pg_proc where proname = 'calc_mvt'
ENDTEXT

lnError = SQLEXEC(gnHandle, lcString, 'qry')

If lnError < 0
	Messagebox('error in query')
	Set Step On
	Return
ENDIF

If USED('qry') AND RECCOUNT('qry') > 0 AND qry.pronargs = 3
	l_success = .T.
Else
	l_success = .F.
	result = ' failed'
Endif

lnTulu = 1200
lnMVT = 500
ldDate = DATE(2018,01,31)


TEXT TO lcString
	select calc_mvt(?lnTulu::numeric,?lnMVT::numeric, ?ldDate::date)::numeric as mvt
ENDTEXT

lnError = SQLEXEC(gnHandle, lcString, 'qry')

If lnError < 0
	Messagebox('error in query')
	Set Step On
	Return
ENDIF

If USED('qry') AND RECCOUNT('qry') > 0 AND qry.mvt = 500
	l_success = .T.
Else
	l_success = .F.
	result = ' failed'
Endif

? test_name  + result
Wait Window test_name + result Timeout 2

Return l_success
ENDFUNC




Function test_calc_MVT
Local l_success, test_name, result
test_name = 'test for calc_mvt'
result = ' passed'
l_success = .t.

? test_name

TEXT TO lcString
	select pronargs::integer from pg_proc where proname = 'calc_mvt'
ENDTEXT

lnError = SQLEXEC(gnHandle, lcString, 'qry')

If lnError < 0
	Messagebox('error in query')
	Set Step On
	Return
ENDIF

If USED('qry') AND RECCOUNT('qry') > 0 AND qry.pronargs = 3
	l_success = .T.
Else
	l_success = .F.
	result = ' failed'
Endif

lnTulu = 1200
lnMVT = 500
ldDate = DATE(2018,01,31)


TEXT TO lcString
	select calc_mvt(?lnTulu::numeric,?lnMVT::numeric, ?ldDate::date)::numeric as mvt
ENDTEXT

lnError = SQLEXEC(gnHandle, lcString, 'qry')

If lnError < 0
	Messagebox('error in query')
	Set Step On
	Return
ENDIF

If USED('qry') AND RECCOUNT('qry') > 0 AND qry.mvt = 500
	l_success = .T.
Else
	l_success = .F.
	result = ' failed'
Endif

? test_name  + result
Wait Window test_name + result Timeout 2

Return l_success
ENDFUNC




Function test_table_structure
Local l_success, test_name, result
test_name = 'test for table taotlus_mvt'
result = ' passed'
? test_name

TEXT TO lcString
	SELECT count(*)::integer as count_tbl FROM pg_class where relname = 'taotlus_mvt'
ENDTEXT
lnError = SQLEXEC(gnHandle, lcString, 'qry')

If lnError < 0
	Messagebox('error in query')
	Set Step On
	Return
Endif

If USED('qry') AND RECCOUNT('qry') > 0 AND qry.count_tbl > 0
	l_success = .T.
Else
	l_success = .F.
	result = ' failed'
Endif

? test_name  + result
Wait Window test_name + result Timeout 2

RETURN l_success

endfunc


Function test_save_proc
Local l_success, test_name, result
test_name = 'test for save data into taotlus_mvt'
result = ' passed'
l_success = .t.

? test_name

TEXT TO lcString
	select pronargs::integer from pg_proc where proname = 'sp_salvesta_taotlus_mvt'
ENDTEXT

lnError = SQLEXEC(gnHandle, lcString, 'qry')

If lnError < 0
	Messagebox('error in query')
	Set Step On
	Return
ENDIF

If USED('qry') AND RECCOUNT('qry') > 0 AND qry.pronargs = 9
	l_success = .T.
Else
	l_success = .F.
	result = ' failed'
Endif

lnId = 0
lnRekvId = gRekv
lnUserId  = tnIsikId

ldKpv = DATE()
ldAlgKpv = DATE(2017,01,01)
ldLoppKpv = DATE(2017,12,31)
lnLepingId  = 131844
ttMuud = 'Test'
lnSumma = 500


TEXT TO lcString
	select sp_salvesta_taotlus_mvt(?lnId::integer, ?lnRekvId::integer, ?lnUserId::integer, ?ldKpv::date, ?ldAlgKpv::date, ?ldLoppKpv::date, ?lnLepingId::integer, ?lnSumma::numeric, ?ttMuud::text)::integer as id
ENDTEXT

lnError = SQLEXEC(gnHandle, lcString, 'qry')

If lnError < 0
	Messagebox('error in query')
	Set Step On
	Return
ENDIF

If USED('qry') AND RECCOUNT('qry') > 0 AND qry.id > 0
	docId = qry.id
	l_success = .T.
Else
	l_success = .F.
	result = ' failed'
Endif

? test_name  + result
Wait Window test_name + result Timeout 2

Return l_success
ENDFUNC

Function test_delete_proc
Local l_success, test_name, result
test_name = 'test for delete data from taotlus_mvt'
result = ' passed'
l_success = .t.

? test_name

TEXT TO lcString
	select pronargs::integer from pg_proc where proname = 'sp_del_taotlus_mvt'
ENDTEXT

lnError = SQLEXEC(gnHandle, lcString, 'qry')

If lnError < 0
	Messagebox('error in query')
	Set Step On
	Return
ENDIF

If USED('qry') AND RECCOUNT('qry') > 0 AND qry.pronargs = 2
	l_success = .T.
Else
	l_success = .F.
	result = ' failed'
Endif

TEXT TO lcString
	select sp_del_taotlus_mvt(?docId::integer, 1::integer)::integer as deleted
ENDTEXT

lnError = SQLEXEC(gnHandle, lcString, 'qry')

If lnError < 0
	Messagebox('error in query')
	Set Step On
	Return
ENDIF

If USED('qry') AND RECCOUNT('qry') > 0 AND qry.deleted > 0
	l_success = .T.
Else
	l_success = .F.
	result = ' failed'
ENDIF

USE IN qry 
? test_name  + result
Wait Window test_name + result Timeout 2

Return l_success
ENDFUNC


Function test_select_data
Local l_success, test_name, result
test_name = 'test for select data from taotlus_mvt'
result = ' passed'
l_success = .t.

? test_name

oDb.use('CURTAOTLUSED_MVT')
SELECT CURTAOTLUSED_MVT

IF !USED('CURTAOTLUSED_MVT')
	l_success = .F.
	result = ' failed, CURTAOTLUSED_MVT not in use'
	? test_name  + result
	Wait Window test_name + result Timeout 2
	RETURN l_success
ENDIF

IF reccount('CURTAOTLUSED_MVT') = 0
	l_success = .F.
	result = ' failed, no records'
	? test_name  + result
	Wait Window test_name + result Timeout 2
	RETURN l_success
ENDIF


oDb.use('CURPALKJAAK_MVT')

SELECT CURPALKJAAK_MVT

IF !USED('CURPALKJAAK_MVT')
	l_success = .F.
	result = ' failed, CURPALKJAAK_MVT not in use'
	? test_name  + result
	Wait Window test_name + result Timeout 2
	RETURN l_success
ENDIF

IF reccount('CURPALKJAAK_MVT') = 0
	l_success = .F.
	result = ' CURPALKJAAK_MVT failed, no records'
	? test_name  + result
	Wait Window test_name + result Timeout 2
	RETURN l_success
ENDIF

USE IN CURPALKJAAK_MVT
USE IN CURTAOTLUSED_MVT
? test_name  + result
Wait Window test_name + result Timeout 2

Return l_success
ENDFUNC



Function test_V_TAOTLUS_mvt_data
Local l_success, test_name, result
test_name = 'test for select dok V_TAOTLUS_mvt'
result = ' passed'
l_success = .t.
? test_name

tnId = docId
oDb.use('V_TAOTLUS_MVT')

IF !USED('V_TAOTLUS_MVT')
	l_success = .F.
	result = ' failed, V_TAOTLUS_MVT not in use'
	? test_name  + result
	Wait Window test_name + result Timeout 2
	RETURN l_success
ENDIF

IF reccount('V_TAOTLUS_MVT') = 0
	l_success = .F.
	result = ' failed, no records'
	? test_name  + result
	Wait Window test_name + result Timeout 2
	RETURN l_success
ENDIF

USE IN V_TAOTLUS_MVT

? test_name  + result
Wait Window test_name + result Timeout 2

Return l_success
Endfunc

