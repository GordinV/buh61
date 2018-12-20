Parameter cWhere
tnId = cWhere
oDb.use ('v_library','qryPalkLib')
tcKood = ltrim(rtrim(qrypalklib.kood))+'%'
tcNimetus = ltrim(rtrim(qryPalklib.nimetus))+'%'
tnStatus = qryPalkLib.tun5
tcTululiik = '%'

use in qryPalkLib
oDb.use('curPalklib','Palklib_report1')
select palklib_report1
