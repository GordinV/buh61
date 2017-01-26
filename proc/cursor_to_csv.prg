LPARAMETERS tcDelimeter, tcChar
LOCAL lcString, lnFields
CREATE CURSOR tmpCursorCsv (csv m)
APPEND blank


lcString = ''
IF EMPTY(tcDelimeter)
	tcDelimeter = ';'
ENDIF
IF EMPTY(tcChar) 
	tcChar = '"'
ENDIF


SET STEP ON 
CREATE CURSOR tmp (field1 c(20), field2 n(14,2))
INSERT INTO tmp (field1, field2) VALUES ('11',11.11)
BROWSE
* structure
lnFields = afields (aObjekt)
FOR i = 1 TO lnFields
	lcString = lcString + IIF(LEN(lcString) > 0 ,tcDelimeter,'') + IIF(aObjekt(i,2) = 'C',tcChar,'') +  aObjekt(i,1) + IIF(aObjekt(i,2) = 'C',tcChar,'')
ENDFOR

lcString = lcString + CHR(13)


replace tmpCursorCsv.csv with lcString
MODIFY MEMO tmpCursorCsv.csv 

