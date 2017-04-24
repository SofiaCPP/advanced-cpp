solution 'LinuxSymbols'
	configurations { 'normal', 'symbolic' }
	
	flags 'Symbols'

	warnings 'extra'

	targetdir '%{cfg.buildcfg}'

	project 'static'
		kind 'StaticLib'
		language 'C++'
		files 'static.cxx'
		buildoptions '-fPIC'

	project 'library'
		kind 'SharedLib'
		language 'C++'
		files 'library.cxx'
		files 'hm.cxx'
		links 'static'
		defines 'LIBRARY_IMPL'
		buildoptions '-fvisibility=hidden'
		configuration 'symbolic'
			linkoptions {
				'-Xlinker', '-Bsymbolic',
				'-Wl,--version-script=library.map',
			}
			

	project 'global'
		kind 'ConsoleApp'
		language 'C++'
		files { 'global.cxx' }
		links 'library'

