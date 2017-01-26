Parameters tnOpt
*On Error

gcCurrentValuuta = fnc_currentValuuta('VAL',DATE())

If gvErsia='VFP'
	Set Database To buhdata5
	lnViews = Adbobject (laView,'VIEW')
	For i = 1 To lnViews
		lError = DBSetProp(laView(i),'View','FetchAsNeeded',.T.)
	Endfor
Endif

If Empty(tnOpt)
	= OpenView('comTpremote',Iif ('EELARVE' $ curkey.versia,.F.,.T.))
	Select coMTpremote
	Index On Id Tag Id
	Index On koOd Tag koOd
	Set Order To Id

	= OpenView('comEelarveremote',Iif ('EELARVE' $ curkey.versia,.F.,.T.))
	Select comEelarveremote
	Index On Id Tag Id
	Index On koOd Tag koOd Additive
	Set Order To Id
	= OpenView('comallikadremote',Iif ('EELARVE' $ curkey.versia,.F.,.T.))
	Select coMallikadremote
	Index On Id Tag Id
	Index On koOd Tag koOd
	Set Order To Id
	= OpenView('comRaharemote',Iif ('EELARVE' $ curkey.versia,.F.,.T.))
	Select coMRaharemote
	Index On Id Tag Id
	Index On koOd Tag koOd
	Set Order To Id

	= OpenView('comtegevremote',Iif ('EELARVE' $ curkey.versia,.F.,.T.))
	Select coMtegevremote
	Index On Id Tag Id
	Index On koOd Tag koOd
	Set Order To Id


ENDIF

= OpenView('comObjektRemote')
Select comObjektRemote
Index On Id Tag Id
Index On koOd Tag koOd Additive
Set Order To Id

= OpenView('comaaRemote')
Index On Id Tag Id
Set Order To Id

= OpenView('comgrupp',Iif ('POHIVARA' $ curkey.versia,.F.,.T.),'comGruppRemote')
Select comGruppRemote
Index On Id Tag Id
Index On koOd Tag koOd Additive
Set Order To Id

= OpenView('comPalkLib',Iif ('PALK' $ curkey.versia,.F.,.T.),'comPalkLibRemote')
Select comPalkLibRemote
Index On Id Tag Id
Index On koOd Tag koOd Additive
Set Order To Id

= OpenView('comProjremote')
Select comProjremote
Index On Id Tag Id
Index On koOd Tag koOd Additive
Set Order To Id

= OpenView('comUritusremote')
Select comUritusremote
Index On Id Tag Id
Index On koOd Tag koOd Additive
Set Order To Id

tdKehtivus = DATE() - 365
= OpenView('comasutusRemote')
Select coMasutusremote
Index On Id Tag Id
Index On reGkood Tag reGkood additive
Index On Left(Upper(niMetus), 40) Tag niMetus additive
Set Order To Id
= OpenView('comdokRemote')
SELECT comDokremote
Index On koOd Tag koOd
Index On Id Tag Id
Set Order To Id
= OpenView('comdoklausremote', Iif ('RAAMA' $ curkey.versia ,.F.,.T.))
SELECT comdoklausremote
Index On Id Tag Id
Set Order To Id
= OpenView('comkassaRemote')
SELECT comkassaRemote
Index On Id Tag Id
Set Order To Id
= OpenView('comkontodRemote',Iif ('RAAMA' $ curkey.versia ,.F.,.T.))
Select coMkontodremote
Index On Id Tag Id
Index On koOd Tag koOd additive
Set Order To Id

= OpenView('comPakettRemote')
Select comPakettRemote
Index On Id Tag Id
Index On koOd Tag koOd additive
Set Order To Id

= OpenView('comObjektRemote')
Select comObjektRemote
Index On Id Tag Id
Index On koOd Tag koOd additive
Set Order To Id


*!*	= opEnview('comlausendRemote',iif ('RAAMA' $ curkey.versia ,.f.,.t.))
*!*	Select coMlausendremote
*!*	Index ON id TAG id
= OpenView('comlausheadremote', Iif ('RAAMA' $ curkey.versia ,.F.,.T.))
Select comlausheadremote
Index On Id Tag Id
Set Order To Id
= OpenView('comnomRemote')
Select coMnomremote
Index On Id Tag Id
Index On koOd Tag koOd additive
Set Order To Id
= OpenView('comrekvRemote')
SELECT comrekvRemote
Index On Id Tag Id
Set Order To Id
= OpenView('comtunnusRemote', Iif ('RAAMA' $ curkey.versia ,.F.,.T.))
SELECT comtunnusRemote
Index On Id Tag Id
Index On koOd Tag koOd additive
Set Order To Id
*= OpenView('comAUTO')

IF USED('comArvRemote')
	USE IN comArvRemote
ENDIF

= OpenView('comArvRemote',.T.)
Select coMarvremote
Index On Id Tag Id
Index On Number Tag Number additive
Set Order To Number

= OpenView('comValuutaRemote')
IF USED('comValuutaRemote')
	Select coMValuutaRemote
	Index On Id Tag Id
	Index On kood Tag kood additive
	Set Order To kood
ENDIF
= OpenView('v_palk_config')
= OpenView('v_config_')

IF gcProgNimi = 'HOOLDEKODU.EXE'
		lcString = "select count(id) as kogus from hooettemaksud where staatus = 1"
		lError = SQLEXEC(gnHandle,lcString,'qry')
		IF lError > 0 AND USED('qry') AND VAL(ALLTRIM(qry.kogus)) > 0
			MESSAGEBOX('Leitud klassifitseerimata ettemaksed')
			* leitud klassifitseerimata ettemasud, kaivitame ettemasu register
			oTools.btnEttemaks.click()
		endif
endif


Return
Endproc



*
Procedure OpenView
	Lparameter tcView, tlopt, tcCursor
	If Empty(tcCursor)
		tcCursor = tcView
	Endif
	With odB
		If  .Not. Used(tcView)
			.Use(tcView,tcCursor,Iif (tlopt = .F.,.F.,.T.),gnHandleAsync)
		Else
			If tlopt = .F.
				.dbReq(tcCursor,gnHandle,tcView)
			Endif
		Endif
	Endwith
Endproc
*
