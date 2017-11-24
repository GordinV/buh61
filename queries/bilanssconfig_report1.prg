Parameter cWhere
if !used ('v_bilanss')
	odb.use ('v_bilanss')
endif
if !used ('v_passiva')
	odb.use ('v_passiva')
endif
select v_bilanss.*,v_passiva.kood as passiv  from v_bilanss,v_passiva  into cursor bilanssconfig_report1
select bilanssconfig_report1

