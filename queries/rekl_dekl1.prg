Parameter cWhere

Create Cursor print_dekl (regkood c(20), asutus c(254), aadress m, tel c(120), faks c(120), email c(120),;
	kood c(20), nimetus c(254), maksumaar N(12,2), soodus N(12,2), kogus N(12,4), Summa N(12,2), muud m)
tnid = 0
If Isdigit(Alltrim(cWhere))
	tnid = Val(Alltrim(cWhere))
Else
	If Used('curReklDekl')
		tnid = curReklDekl.Id
	Endif
Endif

With oDb
	tnid = cWhere
	.Use('V_toiming','tmpToiming')
	tnid = tmpToiming.lubaid
	.Use('V_LUBA','tmpLuba')
	.Use('V_LUBA1','tmpLuba1')
	tnid = tmpLuba.parentId
	.use('v_asutus','tmpAsutus')
Endwith


Select print_dekl
INSERT INTO print_dekl (regkood , asutus , aadress , tel, email , faks,;
	kood , nimetus , maksumaar, soodus, kogus , Summa , muud) VALUES;
	(tmpAsutus.regkood, tmpAsutus.nimetus, tmpAsutus.aadress, tmpAsutus.tel, tmpAsutus.email, tmpAsutus.faks,;
	tmpLuba1.kood, tmpLuba1.nimetus, tmpLuba1.maksumaar, tmpLuba1.soodus, tmpToiming.summa, tmpLuba1.muud)

IF USED('tmpToiming')
	USE IN tmpToiming
ENDIF
IF USED('tmpLuba')
	USE IN tmpLuba
ENDIF
IF USED('tmpLuba1')
	USE IN tmpLuba1
ENDIF
IF USED('tmpAsutus')
	USE IN tmpAsutus
ENDIF

Select print_dekl
If Reccount('print_dekl') < 1
	Append Blank
Endif
