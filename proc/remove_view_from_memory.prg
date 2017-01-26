IF gVersia = 'VFP'
	Set Data To buhdata5
	lnViews = Adbobject (laView,'VIEW')
	For i = 1 To lnViews
		IF USED(laView(i))
			USE IN (laView(i))
		endif
	Endfor

endif