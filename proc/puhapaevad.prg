Parameter tdKpv1, tdKpv2
Local lnPaevad, lError
If  .Not. Used('qryHoliday')
	lError = odB.Use('curHoliday','qryHoliday')
Endif
lnPaevad = 0
If used('qryHoliday') and Reccount('qryHoliday') > 0
	Select Date(Year(tdKpv1), qrYholiday.kuU, qrYholiday.paEv) As kpV1,  ;
		DATE(Year(tdKpv2), qrYholiday.kuU, qrYholiday.paEv) As kpV2 From  ;
		qrYholiday Into Cursor tmpPuhad
	Select tmpPuhad
	Select kpV2 As kpV From tmpPuhad Where kpV2<=tdKpv2 Into Cursor  ;
		tmpPuhad_ Union Select kpV1 As kpV From tmpPuhad Where kpV1>=tdKpv1
	Count For kpV>=tdKpv1 .And. kpV<=tdKpv2 To lnPaevad
	Use In tmpPuhad
	Use In tmpPuhad_
Endif

Return lnPaevad
Endfunc
*
