PARAMETER nId
*CREATE CURSOR qryViivis (konto c(20), selg c(254), number c(20), summa y, tahtaeg d, tasud y, volg y, viivis y, paev int)


SELECT qryViivis.* from qryViivis INTO CURSOR qryViivis_report1

SELECT qryViivis_report1
