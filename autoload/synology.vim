" Vim plugin for synology
" Last Change:	2015 Oct 28
" Maintainer:	bieichu <bieichu@synology.com>


let s:synology_cscope_loaded_list = []

function! s:IsGitRepository(path)
	let git_dir = a:path . '/.git'

	return isdirectory(git_dir)
endfunction

function! synology#AddCscopeDatabase(path)
	if !has('cscope')
		return
	endif

	" avoid connecting to the same db twice
	if count(s:synology_cscope_loaded_list, a:path) > 0
		"echo 'database "' . a:path . '" has already been added'
		return
	endif

	" add database
	if filereadable(a:path)
		"echo 'add database "' . a:path . '" '
		call add(s:synology_cscope_loaded_list, a:path)
		exe 'cs add ' . a:path . ''
	endif
endfunction

function! synology#AddTagFile(path)
	" avoid connecting to the same tag file twice
	if count(tagfiles(), a:path) > 0
		"echo 'tag file "' . a:path . '" has already been added'
		return
	endif

	" add tag file
	if filereadable(a:path)
		"echo 'add tag file "' . a:path . '" '
		exe 'set tags+=' . a:path . ''
		"echo tagfiles()
	endif
endfunction

" load dependencies of @project_at @top_source
function! synology#LoadDependency(top_source, project_name)
	"echo 'adding dependencies of "' . a:project_name . '" '

	if has_key(g:synology_project_dependency, a:project_name)
		let projects = g:synology_project_dependency[a:project_name]

		for project in projects
			call synology#LoadProject(a:top_source, project)
		endfor
	endif
endfunction

" load @project_name at @top_source
function! synology#LoadProject(top_source, project_name)
	"echo 'loading cscope database of project "' . a:project_name . '" at "' . a:top_source . '"'
	let cscope_db = a:top_source . '/' . a:project_name . '/cscope.out'
	let tag_file = a:top_source . '/' . a:project_name . '/tags'

	call synology#AddCscopeDatabase(cscope_db)
	call synology#AddTagFile(tag_file)

	" load dependent projects
	if g:synology_load_dependency != 0
		call synology#LoadDependency(a:top_source, a:project_name)
	endif
endfunction

" load current project by search parent folders recursively
function! synology#LoadCurrentProject()
	let current = fnamemodify(expand('%'), ':p:h')
	let parent = fnamemodify(current, ':p:h:h')

	" search parent folders for git repository
	while current != parent
		if s:IsGitRepository(current)
			let project_name = fnamemodify(current, ':t')
			let project_path = parent

			call synology#LoadProject(project_path, project_name)
			break
		endif

		let current = parent
		let parent = fnamemodify(current, ':p:h:h')
	endwhile

endfunction



