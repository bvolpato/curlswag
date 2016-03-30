#!/bin/bash
# Curl + Swagger
# - depends on bash-completion

complete -o bashdefault -o default -o "nospace" -F _curlswag curlswag;
alias curlswag="curl"

## autocompletion function
function _curlswag() {
  local cur
  local LC_ALL='C'

  _get_comp_words_by_ref -n : cur

  # do not attempt completion if we're specifying an option
  [[ "$cur" == -* ]] && return 0

  IFS=' ' read -r -a POSITIONS <<< "$COMP_LINE"

  urlNoFile=`echo $cur | perl -n -e 'm{(https?://[^/]+)(/[^?]+)};print $1'`

  if [ "$urlNoFile" != "" ]; then
    ENDPOINTS=$(curl -ks $urlNoFile/swagger.json | jsontag paths | jsonkeys | tr '\n' ' ')

    IFS=' ' read -r -a ENDPOINTS_ARRAY <<< "$ENDPOINTS"
    EXPANDED=("${ENDPOINTS_ARRAY[@]/#/$urlNoFile}")

    #  COMPREPLY=( $(compgen -W "${EXPANDED[@]}" "$cur") )
    COMPREPLY=( $(filter_arr "^$cur" "${EXPANDED[@]}") )

    __ltrim_colon_completions "$cur"

  fi

  return 0;
}




# Removes elements from an array based on a given regex pattern.
# Usage: filter_arr pattern array
# Usage: filter_arr pattern element1 element2 ...
# https://stackoverflow.com/questions/3578584/bash-how-to-delete-elements-from-an-array-based-on-a-pattern
if ! hash filter_arr 2>/dev/null; then
  function filter_arr() {
    arr=($@)
    arr=(${arr[@]:1})
    dirs=($(for i in ${arr[@]}
      do echo $i
    done | grep $1))
    echo ${dirs[@]}
  }
fi


if ! hash jsonkeys 2>/dev/null; then
  # Read JSON Keys
  function jsonkeys() {
    python -c $'
import json,sys;
obj=json.load(sys.stdin);

for each in obj.keys():
    print "%s" % (each)
';
  }

fi


if ! hash jsontag 2>/dev/null; then
  # Read JSON Tag
  function jsontag() {
    python -c $'
import json,sys;
obj=json.load(sys.stdin);
result=obj["'"$1"'"];

if isinstance(result, unicode):
  print result;
else:
  print json.dumps(result, indent=4);
  ';
  }
fi
