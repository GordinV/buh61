PARAMETERS tnAsutusId, tdKpv, tnHind
*SET STEP ON 
LOCAL lcSumma, oFormula, lcAlias
lcSumma = 0
lcAlias = ALIAS()
Set Classlib To Classlib
oFormula = Createobj('classlib.formula')
WITH oFormula
	.hind = tnHind
	.asutusId = tnAsutusId
	.kpv = tdKpv
	.Valuuta = fnc_currentvaluuta('VAL',.kpv)
	.Kuurs = fnc_currentvaluuta('KUURS',.kpv)
	lcSumma =.fncViivis(3)
ENDWITH
SELECT (lcAlias)
RETURN lcSumma


