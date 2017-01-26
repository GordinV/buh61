parameters m_indir
m_indirlist = m_indir+"*.ps"
m_numofiles = adir(m_dirtocheck,m_indirlist)
if m_numofiles = 0
	return 
endif 
for it = 1 to m_numofiles
	m_filetocnv=m_indir+m_dirtocheck[it,1]
	=ps2pdf(m_filetocnv)
endfor 
