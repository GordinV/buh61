Parameter tnId, tdKpv1
local lnPaevad, lnSunniaasta
oDb.use ('qryTooleping','tmpleping')
select comAsutusRemote
locate for comAsutusRemote.id = tmpLeping.parentid
if !found () or reccount ('tmpleping') = 0
	return 0
endif
lnSunniaasta = val('19'+substr(comAsutusRemote.regkood,2,2))
lnSunnikuu = val(substr(comAsutusRemote.regkood,4,2))
lnSunnipaev = val (substr(comAsutusRemote.regkood,6,2))
if (lnSunnikuu > 0 and lnSunnikuu <= 12) and;
	(lnSunnipaev > 0 and lnSunnipaev < 31) and;
	 (lnSunniaasta > year (date()) - 85 and lnSunniaasta < year (date()) - 10) 
	lnAasta = (date() -  date (lnSunniaasta,lnSunnikuu,lnSunnipaev)) / 365
else
	lnAasta = 18
endif
do case
	case tmpLeping.ametnik = 1
		lnpaevad = 35
	case tmpLeping.ametnik = 0 and lnAasta >= 18
		lnpaevad = 28		
	case tmpLeping.ametnik = 0 and lnAasta < 18
		lnpaevad = 35
endcase
if used ('tmpleping')
	use in tmpleping
endif
&& ��������� ������� �� ���� ����������
lnPaevad = lnpaevad + puhapaevad(tdKpv1,tdKpv1+lnpaevad)
return lnPaevad