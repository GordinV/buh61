Parameter cWhere
if !used ('v_tulem')
	odb.use ('v_tulem')
endif
select *  from v_tulem  into cursor tulemconfig_report1
select tulemconfig_report1

