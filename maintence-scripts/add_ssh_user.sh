#!/bin/bash          
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/includes.sh"

# We add a user to ssh capabilities. This is mostly used for AWS, pretty Ubuntu specific.
echoc "\n-------------------------------------------------------------------------------------------------------------\n" $LIGHT_BLUE
echoc "Adding a new user to Ubuntu" $GREEN
echoc "\n-------------------------------------------------------------------------------------------------------------\n" $LIGHT_BLUE

add_user()
{
  echo "adding user"
  echo "$(sudo adduser $_arg_user --gecos "" --disabled-password)"
  echo "$(su $_arg_user -c 'mkdir ~/.ssh')"
  echo "$(su $_arg_user -c 'chmod 700 ~/.ssh')"
  echo "$(su $_arg_user -c 'touch ~/.ssh/authorized_keys')"
  echo "$(su $_arg_user -c 'chmod 600 ~/.ssh/authorized_keys')"
  #echo "$(su $_arg_user -c 'cat ~/.ssh/authorized_keys << $_arg_key')"
  return;
}

#
# This is a positional arguments-only example of Argbash potential
#
# ARG_HELP([The general script's help msg])
# ARG_POSITIONAL_SINGLE([user],[The name of the user to add to this service.])
# ARG_POSITIONAL_SINGLE([key],[The ssh public key of the user to add to this service.])
# ARGBASH_GO()
# needed because of Argbash --> m4_ignore([
### START OF CODE GENERATED BY Argbash v2.6.1 one line above ###
# Argbash is a bash code generator used to get arguments parsing right.
# Argbash is FREE SOFTWARE, see https://argbash.io for more info
# Generated online by https://argbash.io/generate

# When called, the process ends.
# Args:
#   $1: The exit message (print to stderr)
#   $2: The exit code (default is 1)
# if env var _PRINT_HELP is set to 'yes', the usage is print to stderr (prior to )
# Example:
#   test -f "$_arg_infile" || _PRINT_HELP=yes die "Can't continue, have to supply file as an argument, got '$_arg_infile'" 4
die()
{
  local _ret=$2
  test -n "$_ret" || _ret=1
  test "$_PRINT_HELP" = yes && print_help >&2
  echo "$1" >&2
  exit ${_ret}
}

# Function that evaluates whether a value passed to it begins by a character
# that is a short option of an argument the script knows about.
# This is required in order to support getopts-like short options grouping.
begins_with_short_option()
{
  local first_option all_short_options
  all_short_options='h'
  first_option="${1:0:1}"
  test "$all_short_options" = "${all_short_options/$first_option/}" && return 1 || return 0
}



# THE DEFAULTS INITIALIZATION - POSITIONALS
# The positional args array has to be reset before the parsing, because it may already be defined
# - for example if this script is sourced by an argbash-powered script.
_positionals=()
# THE DEFAULTS INITIALIZATION - OPTIONALS

# Function that prints general usage of the script.
# This is useful if users asks for it, or if there is an argument parsing error (unexpected / spurious arguments)
# and it makes sense to remind the user how the script is supposed to be called.
print_help ()
{
  printf '%s\n' "The general script's help msg"
  printf 'Usage: %s [-h|--help] <user> <key>\n' "$0"
  printf '\t%s\n' "<user>: The name of the user to add to this service."
  printf '\t%s\n' "<key>: The ssh public key of the user to add to this service."
  printf '\t%s\n' "-h,--help: Prints help"
}

# The parsing of the command-line
parse_commandline ()
{
  while test $# -gt 0
  do
    _key="$1"
    case "$_key" in
      # The help argurment doesn't accept a value,
      # we expect the --help or -h, so we watch for them.
      -h|--help)
        print_help
        exit 0
        ;;
      # We support getopts-style short arguments clustering,
      # so as -h doesn't accept value, other short options may be appended to it, so we watch for -h*.
      # After stripping the leading -h from the argument, we have to make sure
      # that the first character that follows coresponds to a short option.
      -h*)
        print_help
        exit 0
        ;;
      *)
        _positionals+=("$1")
        ;;
    esac
    shift
  done
}


# Check that we receive expected amount positional arguments.
# Return 0 if everything is OK, 1 if we have too little arguments
# and 2 if we have too much arguments
handle_passed_args_count ()
{
  _required_args_string="'user' and 'key'"
  test ${#_positionals[@]} -ge 2 || _PRINT_HELP=yes die "FATAL ERROR: Not enough positional arguments - we require exactly 2 (namely: $_required_args_string), but got only ${#_positionals[@]}." 1
  test ${#_positionals[@]} -le 2 || _PRINT_HELP=yes die "FATAL ERROR: There were spurious positional arguments --- we expect exactly 2 (namely: $_required_args_string), but got ${#_positionals[@]} (the last one was: '${_positionals[*]: -1}')." 1
}

# Take arguments that we have received, and save them in variables of given names.
# The 'eval' command is needed as the name of target variable is saved into another variable.
assign_positional_args ()
{
  # We have an array of variables to which we want to save positional args values.
  # This array is able to hold array elements as targets.
  _positional_names=('_arg_user' '_arg_key' )

  for (( ii = 0; ii < ${#_positionals[@]}; ii++))
  do
    eval "${_positional_names[ii]}=\${_positionals[ii]}" || die "Error during argument parsing, possibly an Argbash bug." 1
  done
}

# Now call all the functions defined above that are needed to get the job done
parse_commandline "$@"
handle_passed_args_count
assign_positional_args

# OTHER STUFF GENERATED BY Argbash

### END OF CODE GENERATED BY Argbash (sortof) ### ])
# [ <-- needed because of Argbash

echo "User name: $_arg_user"
echo "key name: $_arg_key"

add_user
exit 1


# ] <-- needed because of Argbash