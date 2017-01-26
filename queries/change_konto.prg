parameter tcOldKonto, tcUusKonto
if empty (tcOldKonto) OR EMPTY (tcUusKonto)
	Return .T.
endif
lError = odb.exec ("sp_change_konto ","'"+tcOldKonto+"','"+tcUusKonto+"'")
return lError