zshrc
=====

install local
-------------

1. clone this repository

2. link your .zshrc to the repositories zshrc file

	``` sh
	$ ln -s ~/location/of/the/clone/zshrc ~/.zshrc
	```

install global
--------------

1. clone this repository

2. link your /etc/zsh/zshrc to the repositories zshrc file

	``` sh
	$ ln -s /location/of/the/clone/zshrc /etc/zsh/zshrc
	```

configuration
-------------

1. global configuration

	``` sh
	$ vim /etc/zshrc.config
	```

2. local configuration

	NOTE: the local configuration takes precedence over the global configuration.
	``` sh
	$ vim ~/.zshrc.config
	```

3. configuration flags

When you change the colors it is sane to change only the 'front' color

	``` sh
	PSCOL='%{%F{yellow}%}'	# default ps (prompt) color
	USRCOL='%{%F{yellow}%}' # the color used for the user
	HSTCOL='%{%F{white}%}'	# the color used for the hostname

	SCMENABLED=1            # enable scm integration
	SCMDIRTY=1              # source code management dirty state
	                        # enabled (default) or disabled
	```
