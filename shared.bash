####### Start of shared.bash 
. ~/.bashtmp
# export LANG=C.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
if [ -f /etc/os-release ]; then
    # freedesktop.org and systemd
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
elif type lsb_release >/dev/null 2>&1; then
    # linuxbase.org
    OS=$(lsb_release -si)
    VER=$(lsb_release -sr)
elif [ -f /etc/lsb-release ]; then
    # For some versions of Debian/Ubuntu without lsb_release command
    . /etc/lsb-release
    OS=$DISTRIB_ID
    VER=$DISTRIB_RELEASE
elif [ -f /etc/debian_version ]; then
    # Older Debian/Ubuntu/etc.
    OS=Debian
    VER=$(cat /etc/debian_version)
elif [ -f /etc/SuSe-release ]; then
    # Older SuSE/etc.
    ...
elif [ -f /etc/redhat-release ]; then
    # Older Red Hat, CentOS, etc.
    ...
else
    # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
    OS=$(uname -s)
    VER=$(uname -r)
fi
unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     

        ;;
    Darwin*)    
        ;;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    *)          machine="UNKNOWN:${unameOut}"
esac

#   Set default blocksize for ls, df, du
#   from this: http://hints.macworld.com/comment.php?mode=view&cid=24491
#   ------------------------------------------------------------
export BLOCKSIZE=1k

#   Add color to terminal

### Prompt Colors
# Modified version of @gf3’s Sexy Bash Prompt
# (https://github.com/gf3/dotfiles)
if [[ $COLORTERM = gnome-* && $TERM = xterm ]] && infocmp gnome-256color >/dev/null 2>&1; then
	export TERM=gnome-256color
elif infocmp xterm-256color >/dev/null 2>&1; then
	export TERM=xterm-256color
fi

if tput setaf 1 &> /dev/null; then
	tput sgr0
	if [[ $(tput colors) -ge 256 ]] 2>/dev/null; then
		MAGENTA=$(tput setaf 9)
		ORANGE=$(tput setaf 172)
		GREEN=$(tput setaf 190)
		PURPLE=$(tput setaf 141)
	else
		MAGENTA=$(tput setaf 5)
		ORANGE=$(tput setaf 4)
		GREEN=$(tput setaf 2)
		PURPLE=$(tput setaf 1)
	fi
	BOLD=$(tput bold)
	RESET=$(tput sgr0)
else
	MAGENTA="\033[1;31m"
	ORANGE="\033[1;33m"
	GREEN="\033[1;32m"
	PURPLE="\033[1;35m"
	BOLD=""
	RESET="\033[m"
fi

export MAGENTA
export ORANGE
export GREEN
export PURPLE
export BOLD
export RESET

# Color LS
export LSCOLORS=exfxcxdxbxexexabagacad
alias ls="command ls ${colorflag}"
alias l="ls -lF ${colorflag}" # all files, in long format
alias la="ls -laF ${colorflag}" # all files inc dotfiles, in long format
alias lsd='ls -lF ${colorflag} | grep "^d"' # only directories

alias cp='cp -iv'                           # Preferred 'cp' implementation
alias mv='mv -iv'                           # Preferred 'mv' implementation
alias mkdir='mkdir -pv'                     # Preferred 'mkdir' implementation
alias ll='ls -FGlAhp'                       # Preferred 'ls' implementation
alias less='less -FSRXc'                    # Preferred 'less' implementation
alias DT='tee ~/Desktop/terminalOut.txt'    # DT:           Pipe content to file on MacOS Desktop
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'


# Quicker navigation
alias cd..='cd ../'                         # Go back 1 directory level (for fast typers)
alias ..='cd ../'                           # Go back 1 directory level
alias ...='cd ../../'                       # Go back 2 directory levels
alias .3='cd ../../../'                     # Go back 3 directory levels
alias .4='cd ../../../../'                  # Go back 4 directory levels
alias .5='cd ../../../../../'               # Go back 5 directory levels
alias .6='cd ../../../../../../'            # Go back 6 directory levels
alias ~="cd ~"                              # ~:            Go Home
alias c='clear'                             # c:            Clear terminal display
alias mydesktop='cd ~/Desktop'

# Usefull aliases
# export EDITOR=/usr/local/bin/nvim

alias edit='nvim'                           # edit:         Opens any file in sublime editor
export EDITOR=nvim
# Enable aliases to be sudo’ed
alias sudo='sudo '

# Colored up cat!
# You must install Pygments first - "sudo easy_install Pygments"
#alias c='pygmentize -O style=monokai -f console256 -g'
#   -------------------------------
#   3. FILE AND FOLDER MANAGEMENT
#   -------------------------------

alias myextr='find . -type f | sed "s|.*\.||" | sort -u'
alias myext='la | sed "s|.*\.||" | sort -u'

# Git
# You must install Git first
alias gs='git status'
alias ga='git add .'
alias gc='git commit -m' # requires you to type a commit message
alias gp='git push'
alias grm='git rm $(git ls-files --deleted)' # deletes the system deleted files


# Git branch details
# The upcoming fucntions are exported by PS1
function parse_git_dirty() {
	[[ $(git status 2> /dev/null | tail -n1) != *"working directory clean"* ]] && echo "*"
}
function parse_git_branch() {
	git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/\1$(parse_git_dirty)/"
}


function make_latex(){

    USAGE="Usage: make_latex() -n [name] -c [compiler name] "
    RANDOM=()
    NAME="untitled_latex_dir"
    COMPILER="pdflatex"
    
    if [  $# -eq 0 ]
       then
	   echo $USAGE
    else
	#echo "the argument is $1"
	while [[ $# -gt 0 ]]
	do
	    key="$1"
	    case $key in
		-n|--name)
		    NAME="$2"
		    shift # past argument
		    shift # past value
		    ;;
		-c|--compiler)
		    COMPILER="$2"
		    shift # past argument
		    shift # past value
		    ;;
		*)
		    RANDOM+=("$1") # save it in an array for later
		    shift # past argument
		    ;;
	    esac
	done
	
	mkdir $NAME
	cd $NAME
	mkdir out
	mkdir img
	git init
	touch main.tex .gitignore .latexmkrc bib.bib
	echo "out/" >> .gitignore
	echo "\\documentclass{article}" >> main.tex
	echo "\\begin{document}" >> main.tex
	echo "\end{document}" >> main.tex
	echo '$pdflatex = "'$COMPILER' -synctex=1  -halt-on-error %O %S";'>> .latexmkrc
	echo '$sleep_time = 1;'>> .latexmkrc
	echo "\$view = 'none';">> .latexmkrc
	echo '$pdf_mode = 1;'>> .latexmkrc
	echo '$dvi_mode = $postscript_mode = 0;'>> .latexmkrc
	echo "\$out_dir = 'out';">> .latexmkrc
	echo "@default_files = ('main.tex');">> .latexmkrc
    fi
    
}

function get_symbol(){
    local SYMBOLS=( '☠ ' '෴ ' '፨ ' 'ᔱ' 'ൠ' '( ͡° ͜ʖ ͡°)' '☃' '☊' '♾' '⛄' )
    echo "${SYMBOLS[$(( $RANDOM % 10 ))]} "
}

### Misc Commands and aliases

zipf () { zip -r "$1".zip "$1" ; }          # zipf:         To create a ZIP archive of a folder


#   extract:  Extract most know archives with one command
#   ---------------------------------------------------------
    extract () {
        if [ -f $1 ] ; then
          case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)     echo "'$1' cannot be extracted via extract()" ;;
             esac
         else
             echo "'$1' is not a valid file"
         fi
    }

    weatherin(){
        curl http://wttr.in/$1
    }

# Backup


# Only show the current directory's name in the tab
export PROMPT_COMMAND='echo -ne "\033]0;${PWD##*/}\007"'

# init z! (https://github.com/rupa/z)
#. ~/z.sh

#   Change Prompt
export PS1="\[${MAGENTA}\]\u \[$RESET\]in \[$GREEN\]\w\[$RESET\]\$([[ -n \$(git branch 2> /dev/null) ]] && echo \" on \")\[$PURPLE\]\$(parse_git_branch)\[$RESET\]\n$(get_symbol)\[$RESET\]"
export PS2="\[$ORANGE\]→ \[$RESET\]"

WELCOME=( " 
(\_(\	
(=' :') ~☠ 
(,(')(')
^^^^^^^^" 
"
  _ _/|
 \'o.0'
 =(___)=
    U
"
"
         \\,,,/
         (o o)
-----oOOo-(_)-oOOo-----
"

"
                 _________-----_____
       _____------           __      ----_
___----             ___------              \\
   ----________        ----                 \\
               -----__    |             _____)
                    __-                /     \\
        _______-----    ___--          \    /)\\
  ------_______      ---____            \__/  /
               -----__    \\ --    _          /\\
                      --__--__     \_____/   \_/\\
                              ----|   /          |
                                  |  |___________|
                                  |  | ((_(_)| )_)
                                  |  \\_((_(_)|/(_)
                                  \\             (
                                   \\_____________) 
"
"
            ___           _,.---,---.,_
            |         ,;~\'             \'~;, 
            |       ,;                     ;,      
   Frontal  |      ;                         ; ,--- Supraorbital Foramen
    Bone    |     ,\'                         /\'
            |    ,;                        /\' ;,
            |    ; ;      .           . <-\'  ; |
            |__  | ;   ______       ______   ;<----- Coronal Suture
           ___   |  \'/~\"     ~\" . \"~     \"~\\\\ \'  |
           |     |  ~  ,-~~~^~, | ,~^~~~-,  ~  |
 Maxilla,  |      |   |        }:{        | <------ Orbit
Nasal and  |      |   l       / | \\       !   |
Zygomatic  |      .~  (__,.--\" .^. \"--.,__)  ~. 
  Bones    |      |    ----;\' / | \\ \\';-<--------- Infraorbital Foramen
           |__     \\__.       \\/^\\/       .__/  
              ___   V| \\                 / |V <--- Mastoid Process 
              |      | |T~\\___!___!___/~T| |  
              |      | |\\'IIII_I_I_I_IIII\'| |  
     Mandible |      |  \\,III I I I III,/  | 
              |       \\   \\'~~~~~~~~~~\'    /
              |         \\   .       . <-x---- Mental Foramen
              |__         \\.    ^    ./   
                            ^~~~^~~~^
"

"
                            (
                .            )        )
                         (  (|              .
                     )   )\\/ ( ( (
             *  (   ((  /     ))\\))  (  )    )
           (     \\   )\\(          |  ))( )  (|
           >)     ))/   |          )/  \\((  ) \\
           (     (      .        -.     V )/   )(    (
            \\   /     .   \\            .       \\))   ))
              )(      (  | |   )            .    (  /
             )(    ,'))     \\ /          \\( '.    )
             (\\>  ,'/__      ))            __'.  /
            ( \\   | /  ___   ( \\/     ___   \\ | ( (
             \\.)  |/  /   \\__      __/   \\   \\|  ))
            .  \\. |>  \\      | __ |      /   <|  /
                 )/    \\____/ :..: \\____/     \\ <
          )   \\ (|__  .      / ;: \\          __| )  (
         ((    )\\)  ~--_     --  --      _--~    /  ))
          \\    (    |  ||               ||  |   (  /
                \\.  |  ||_             _||  |  /
                  > :  |  ~V+-I_I_I-+V~  |  : (.
                 (  \\:  T\\   _     _   /T  : ./
                  \\  :    T^T T-+-T T^T    ;<
                   \\..'_       -+-       _'  )
         )            . '--=.._____..=--'. ./         (
        ((     ) (          )             (     ) (   )> 
         > \\/^/) )) (   ( /(.      ))     ))._/(__))./ (_.
        (  _../ ( \\))    )   \\ (  / \\.  ./ ||  ..__:|  _. \\
        |  \\__.  ) |   (/  /: :)) |   \\/   |(  <.._  )|  ) )
       ))  _./   |  )  ))  __  <  | :(     :))   .//( :  : |
       (: <     ):  --:   ^  \\  )(   )\\/:   /   /_/ ) :._) :
        \\..)   (_..  ..  :    :  : .(   \\..:..    ./__.  ./
                   ^    ^      \\^ ^           ^\\/^     ^
"

"
.                                                      .
        .n                   .                 .                  n.
  .   .dP                  dP                   9b                 9b.    .
 4    qXb         .       dX                     Xb       .        dXp     t
dX.    9Xb      .dXb    __                         __    dXb.     dXP     .Xb
9XXb._       _.dXXXXb dXXXXbo.                 .odXXXXb dXXXXb._       _.dXXP
 9XXXXXXXXXXXXXXXXXXXVXXXXXXXXOo.           .oOXXXXXXXXVXXXXXXXXXXXXXXXXXXXP
  '9XXXXXXXXXXXXXXXXXXXXX'~   ~'OOO8b   d8OOO'~   ~'XXXXXXXXXXXXXXXXXXXXXP'
    '9XXXXXXXXXXXP' '9XX'   DIE    '98v8P'  HUMAN   'XXP' '9XXXXXXXXXXXP'
        ~~~~~~~       9X.          .db|db.          .XP       ~~~~~~~
                        )b.  .dbo.dP''v''9b.odb.  .dX(
                      ,dXXXXXXXXXXXb     dXXXXXXXXXXXb.
                     dXXXXXXXXXXXP'   .   '9XXXXXXXXXXXb
                    dXXXXXXXXXXXXb   d|b   dXXXXXXXXXXXXb
                    9XXb'   'XXXXXb.dX|Xb.dXXXXX'   'dXXP
                     ''      9XXXXXX(   )XXXXXXP      ''
                              XXXX X.'v'.X XXXX
                              XP^X''b   d''X^XX
                              X. 9  '   '  P )X
                              'b  '       '  d'
                               '             '

"
)


echo "${WELCOME[$(( $RANDOM % 7 ))]} "




####### End of shared.bash 

