PARAMETERS tnOpt
IF EMPTY(tnOpt)
	tnOpt = 0
ENDIF


Create Cursor startreport (rep m)
Append Blank
If gversia = 'VFP'
	Set Data To buhdata5
	lnViews = Adbobject (laView,'VIEW')
	For i = 1 To lnViews
		lError = DBSetProp(laView(i),'View','FetchAsNeeded',.T.)
	Endfor
Endif

*!*	= OpenView('comaaRemote')
*!*	Index On Id Tag Id
*!*	Set Order To Id

IF tnOpt = 0

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

=OpenView('comallikadremote')
Select comallikadremote
Index On Id Tag Id
Index On koOd Tag koOd Additive
Set Order To Id


=OpenView('comRaharemote')
Select comRaharemote
Index On Id Tag Id
Index On koOd Tag koOd Additive
Set Order To Id

=OpenView('comrekvRemote')
Index On Id Tag Id
Set Order To Id

=OpenView('comtegevremote')
Select comtegevremote
Index On Id Tag Id
Index On koOd Tag koOd Additive
Set Order To Id


ENDIF


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
Index on id tag id
Index on kood tag kood additive
Set order to id

= OpenView('comUritusremote')
Select comUritusremote
Index on id tag id
Index on kood tag kood additive
Set order to id


=OpenView('comaaRemote')
Index On Id Tag Id
Set Order To Id


=OpenView('comasutusRemote')
Select comasutusRemote
Index On Id Tag Id
Index On regkood Tag regkood Additive
Index On Left(Upper(nimetus),40) Tag nimetus Additive
Set Order To Id

=OpenView('comdokRemote')
Select comdokRemote
Index On Id Tag Id
Index On koOd Tag koOd Additive
Set Order To Id
=OpenView('comdoklausremote')
Index On Id Tag Id
Set Order To Id

=OpenView('comkassaRemote')
Index On Id Tag Id
Set Order To Id

=OpenView('comomatpRemote')
Index On Id Tag Id
Set Order To Id


=OpenView('comkontodRemote')
Select comkontodRemote
Index On Id Tag Id
Index On koOd Tag koOd Additive
Set Order To Id
*!*	=openView('comlausendRemote')
*!*	Select comlausendRemote
*!*	Index on id tag id
=OpenView('comlausheadremote')
Index On Id Tag Id
Set Order To Id

=OpenView('comnomRemote')
Select comnomRemote
Index On Id Tag Id
Index On koOd Tag koOd Additive
Set Order To Id
*!*	=openView('comobjektRemote')
*!*	Select comobjektRemote
*!*	Index on id tag id
*!*	Index on kood tag kood additive
*!*	Set order to kood

=OpenView('comtunnusRemote')
Index On koOd Tag koOd
Index On Id Tag Id
Set Order To Id

=OpenView('comArvRemote')
Select comArvRemote
Index On ID Tag ID
Index On Number Tag Number
Set Order To Number

Select koOd, Id, nimetus From comkontodRemote Where Len(Ltrim(Rtrim(koOd))) = 4 Into Cursor comKlassifRemote

Copy Memo startreport.rep To openlibrep.prn


Return

Procedure OpenView
	Lparameter tcView, tlopt, tcCursor
	If Vartype(oLogo) = 'O'
		With oLogo.lblLib
			.Caption = Iif(config.keel = 2,'Laadimine:','��������:')+tcView
			.Visible = .T.
			.Refresh
		Endwith

	Endif
	If Empty(tcCursor)
		tcCursor = tcView
	Endif
	lnAlgaeg = Val(Sys(2))
	With odB
		If  .Not. Used(tcView)
			.Use(tcView,tcCursor,Iif (tlopt = .F.,.F.,.T.),gnHandle)
		Else

			If tlopt = .F.
				.dbReq(tcCursor,gnHandle,tcView)
			Endif
		Endif
	Endwith
	lnLoppaeg = Val(Sys(2))
	lnAeg = lnLoppaeg - lnAlgaeg
	Replace startreport.rep With 'Cursor :'+tcView+Chr(13)+;
		'Kokku aeg:'+Str(lnAeg)+Chr(13)+;
		'Kokku records:'+Str(Reccount(tcCursor)) Additive

Endproc