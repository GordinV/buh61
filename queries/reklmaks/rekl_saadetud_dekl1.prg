Parameter cWhere

*!*	DO FORM period


*!*	With oDb
*!*		tnid = 0
*!*		.use('TMPSAADETUDDEKL')
*!*	Endwith

SELECT * from curSaadetud ORDER BY NIMETUS INTO CURSOR tmpSaadetudDekl

SELECT TMPSAADETUDDEKL
