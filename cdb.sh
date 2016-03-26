#!/bin/bash
# CheapDB - Should not be used by anyone tbh

# usage:
# ./cdb.sh get host/server1/ip
# ./cdb.sh set host/server2/description
# ./cdb.sh del host/server1
# ./cdb.sh list host

cdb_action="$1"
cdb_elementname="$2"
[[ -z "$cdb_db" ]] && cdb_db="$(pwd)/c_db" #set default db if not specified

cdb_element="$cdb_db/$cdb_elementname"

cdb_elementvalue="$3"

dver(){
	[[ -d "$1" ]]
}

fver(){
	[[ -f "$1" ]]
}

# verify db dir
! dver "$cdb_db" && echo "cdb: db $cdb_db not found" && exit 1

cdb() {
  case "$cdb_action" in
    get)
      fver "$cdb_element" && cat "$cdb_element" && exit 0 || \
      { echo "cdb: element $cdb_elementname in $cdb_db not found"; exit 1; }
    ;;

    set)
      mkdir -p "$(dirname $cdb_element)" || \
      { echo "cdb: failed to create path $(dirname $cdb_element)"; exit 1; }

      echo "$cdb_elementvalue" > "$cdb_element" || \
      { echo "cdb: failed to write element $cdb_element"; exit 1; }

      [[ "$cdb_elementvalue" == "$(cat "$cdb_element")" ]] || \
      { echo "cdb: failed to verify element value for $cdb_element"; exit 1; }
    ;;

    del)
      rm -rf "$cdb_element"

      dver "$cdb_element" || fver "$cdb_element" && \
      { echo "cdb: failed to delete element $cdb_element"; exit 1; }
    ;;

    list)
      shopt -s nullglob
      dver "$cdb_element" && \
      for element in "$cdb_element"/*; do echo "$(basename "$element")"; done || \
      { echo "cdb: element $cdb_element is not a directory"; exit 1; }
    ;;

    *)
      exit 1
    ;;
  esac
}

cdb "$cdb_action"
