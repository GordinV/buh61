Lparameter tnSumma, tnRound
Local lnSumma
If Empty(tnSumma)
	tnSumma = 0
Endif
If Empty(tnRound)
	tnRound = coNfig.Special
Endif
lnSumma = tnSumma
Do Case
	Case tnRound=0.1
		tnSumma = Round(tnSumma, 1)
	Case tnRound=0.01 .Or. tnRound=0
		tnSumma = tnSumma
	Case tnRound=0.05
		If Round(tnSumma, 1)>tnSumma .And. Round(tnSumma, 1)<>tnSumma
			lnDiffer = Round(tnSumma, 1)-Round(tnSumma, 2)
			lcLastdigit = Right(Alltrim(Str(lnDiffer, 4, 2)), 1)
			Do Case
				Case Val(lcLastdigit)>2
					lnSumma = tnSumma-(5-Val(lcLastdigit))*0.01
				Case Val(lcLastdigit)<=2
					lnSumma = tnSumma+Val(lcLastdigit)*0.01
			Endcase
		Endif
		If Round(tnSumma, 1)<tnSumma .And. Round(tnSumma, 1)<>tnSumma
			lnDiffer = Round(tnSumma, 1)-Round(tnSumma, 2)
			lcLastdigit = Right(Alltrim(Str(lnDiffer, 4, 2)), 1)
			If lcLastdigit='5'
				lnSumma = tnSumma
			Else
				Do Case
					Case Val(lcLastdigit)<3
						lnSumma = tnSumma-Val(lcLastdigit)*0.01
					Case Val(lcLastdigit)>=3
						lnSumma = tnSumma+(5-Val(lcLastdigit))*0.01
				Endcase
			Endif
		Endif
		If Round(tnSumma, 1)=tnSumma
			lnSumma = tnSumma
		Endif
	Otherwise
		tnSumma = Round(tnSumma, 0)
Endcase
If tnSumma=0 .And. lnSumma>0
	tnSumma = lnSumma
Endif
Return tnSumma
Endfunc
*