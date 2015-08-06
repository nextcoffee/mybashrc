##
# # LOG
# ---------
#

##
# ## logcon
#
# #### SYNOPSIS
#   `logcon [operations] [value]`
#
# #### DESCRIPTION
#   change log tool setting
#
# #### OPERATIONS
# - `level`
#
#     `s`  silent
#
#     `e`  error
#
#     `w`  warning
#
#     `d`  debug
#
#     `v`  verbose
logcon ()
{
	case "$1" in
		level)
			shift
			if [[ "$1" ]]; then
				if [[ ${#1} = 1 ]] && [[ 'sewdv' =~ "$1" ]]; then
					log_level=$1
					return 0
				else
					error "wrong args"
				fi
			else
				echo $log_level
				return 0
			fi
		;;
	esac
	
	_usage
}

# set default level and mode
[[ $log_level ]] || log_level=w

##
# ## logput
#
# #### SYNOPSIS
#   `logput [level] [string...]`
#
# #### DESCRIPTION
#   print out debug messages
#
# #### OPERATIONS
# - `level`
#
#     refer to `logcon`
logput ()
{
	(( $# )) || (_usage && return 0)
	
	local style
	local lvl="$1"
	case "$lvl" in
		e)
			style="31"
		;;
		
		w)
			style="33"
		;;
		
		d | v)
			style="0"
		;;
		
		*)
			warn "invalid level"
			return 1
		;;
	esac	
	
	[[ ! "sewdv" =~ "$log_level".*"$lvl" ]] || return 0
	
	shift
	if [[ "$@" ]]; then
		echo -e "\e[${style}m$@\e[0m"
	else
		echo -e "\r\n"
	fi
}

alias error='logput e >&2'
alias warn='logput w >&2'
alias debug='logput d'
alias verbose='logput v'

##
# # DOC&HELP
# ---------
#

##
# ## gen_doc
#
# #### SYNOPSIS
#   `gen_doc [file]`
#
# #### DESCRIPTION
#   generate markdown docs from source file
gen_doc ()
{
	[[ -f "$1" ]] || return
	sed -n -e '/^##/,/^[^#]/{/^##/n; /^[^#]/{g;p;b}; s/#\s\?//p}' "$1"
}

##
# ## _usage
#
# #### SYNOPSIS
#   `_usage`
#
# #### DESCRIPTION
#   generate help informaton for function
alias _usage='_usage_inner $BASH_SOURCE $FUNCNAME'
_usage_inner()
{
	[[ "$2" ]] || return
	sed -n -e '/^# ## '"$2"'$/,/^[^#]/{/^# ## '"$2"'$/n; /^[^#]/{g;p;b}; s/#\s\?//p}' "$1"
	
	return 0
}
