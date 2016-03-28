#!/bin/bash
# CheapDB - Should not be used by anyone tbh

# usage:
# ./cdb.sh mkdb myservers
# ./cdb.sh get host/server1/ip
# ./cdb.sh set host/server2/description
# ./cdb.sh del host/server1
# ./cdb.sh rmdb myservers
# ./cdb.sh debug-test-db

[[ -z "$cdb_db" ]] && cdb_db="$(pwd)/cdb__default" || cdb_db="cdb__$cdb_db"

dver(){
	[[ -d "$1" ]]
}

fver(){
	[[ -f "$1" ]]
}

mexit(){ # message n' exit = mexit
  [[ -z "$1" ]] && \
  echo "no errormsg specified" || \
  echo -e "$(tput setaf 1)cdb:$(tput sgr0) $1"
  exit 1
}

dbver(){
  if ! [[ "$cdb_action" == *db ]]; then
  ! dver "$cdb_db" && mexit "db $cdb_db not found" # verify db dir
  fi
}

tester(){
  echo "$(tput setaf 3)cdb-tester:$(tput sgr0) $1"
  echo -n "$(tput setaf 6)$2"
  testoutput=$(eval "$2") && \
  echo -e " $(tput setaf 2)OK!$(tput sgr0)\n" || \
  { echo; mexit "test failed: $2 (output: $testoutput)"; }
}


cdb() {
  cdb_action="$1"
  cdb_elementname="$2"
  cdb_element="$cdb_db/$cdb_elementname"
  cdb_elementvalue="$3"
  dbver

  case "$1" in

    get)
      fver "$cdb_element" && cat "$cdb_element" && exit 0 || \
      mexit "element $cdb_elementname in $cdb_db not found"
    ;;

    set)
      mkdir -p "$(dirname $cdb_element)" || \
      mexit "failed to create path $(dirname $cdb_element)"

      echo "$cdb_elementvalue" > "$cdb_element" || \
      mexit "failed to write element $cdb_element"

      [[ "$cdb_elementvalue" == "$(cat "$cdb_element")" ]] || \
      mexit "failed to verify element value for $cdb_element"
    ;;

    del)
      rm -rf "$cdb_element"

      ! dver "$cdb_element" && ! fver "$cdb_element" || \
      mexit "failed to delete element $cdb_element"
    ;;

    list)
      shopt -s nullglob
      dver "$cdb_element" && \
      for element in "$cdb_element"/*; \
      do echo "$(basename "$element")"; \
      done || \
      mexit "element $cdb_element isn't a directory(can't contain sub-elements)"
    ;;

    mkdb)
      dver "cdb__$cdb_elementname" && mexit "db already exists?"
      fver "cdb__$cdb_elementname" && mexit "dbname conflict with existing file"

      [[ "$cdb_elementname" == "" ]] && mexit "missing db name"
      mkdir -p "cdb__$cdb_elementname" || \
      mexit "failed to create db $cdb_elementname"

      dver "cdb__$cdb_elementname" || \
      mexit "failed to verify db $cdb_elementname"

    ;;

    rmdb)
      [[ "$cdb_elementname" == "" ]] && mexit "missing db name"
      ! dver "cdb__$cdb_elementname" && mexit "can't find db $cdb_elementname"
      rm -rf "cdb__$cdb_elementname" || \
      mexit "failed to delete db $cdb_elementname"
      ! dver "cdb__$cdb_elementname" || \
      mexit "failed to verify db $cdb_elementname delete"
    ;;

    debug-test-db)
      cdb_debug_name="debug-$(date +"%s")"
      tester "Creating db $cdb_debug_name" \
      'cdb mkdb $cdb_debug_name'

      cdb_db="cdb__$cdb_debug_name"
      tester "Creating structure and setting value" \
      'cdb set top_element/sub_element "verify_me"'

      tester "Listing top_element" \
      '[[ $(cdb list top_element) == "sub_element" ]]'

      tester "Reading subelement value" \
      '[[ $(cdb get top_element/sub_element) == "verify_me" ]]'

      tester "Deleting structure" \
      'cdb del top_element'

      tester "Deleting db" \
      'cdb rmdb $cdb_debug_name'
      echo "cdb: All tests complete!"
    ;;

    *)
      mexit "bad command"
    ;;
  esac
}

cdb "$1" "$2" "$3"
