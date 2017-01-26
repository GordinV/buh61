Parameter cWhere
IF EMPTY(cWhere)
	cWhere = ''
endif
SELECT liik, nimetus, muud FROM curLaduOper INTO CURSOR laduoper_report1
Select laduoper_report1
