" Vim plugin for synology
" Last Change:	2015 Oct 28
" Maintainer:	bieichu <bieichu@synology.com>

if !exists('g:synology_load_dependency')
	let g:synology_load_dependency = 1
endif

if !exists('g:synology_project_dependency')
	let g:synology_project_dependency = {
	\	'synosyncfolder': ["libsynocat", "libsynopunch"]
	\}
endif

call synology#LoadCurrentProject()

