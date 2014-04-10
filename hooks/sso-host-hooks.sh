#!/bin/bash

set -e # If any command fails, stop execution of the hook with that error

LOGCMD=$(which juju-log || echo echo)
REL_SET=$(which relation-set   || echo echo "relation-set ")
REL_GET=$(which relation-get   || echo echo "relation-get ")
REL_LIST=$(which relation-list || echo echo "relation-list " )

REL_ACTIONS="joined changed departed broken"


# Relation
[[ $(basename "$0") =~ ^([a-z]|[a-z][a-z-]*[a-z]) ]] && REL_NAME=${BASH_REMATCH[1]}
[[ "$REL_NAME" =~ ^(.*)-relation-[a-z]+$ ]] && REL_NAME=${BASH_REMATCH[1]}

# Command
if [[ $(basename "$0") =~ ^([a-z0-9-]*)-relation-([^-]*)$ ]] ; then
    COMMAND=${BASH_REMATCH[2]}
else
    COMMAND="$1"
fi


# hook implementations

do_joined() {
    # This action should be idempotent.
    $LOGCMD "Relation $REL_NAME: $JUJU_REMOTE_UNIT joined"
    echo unitName=$JUJU_REMOTE_UNIT > hostInformation.properties
}

do_changed() {
    # This action should be idempotent.
    $LOGCMD "Relation $REL_NAME: $JUJU_REMOTE_UNIT modified its settings"
    $LOGCMD Relation settings:
    $LOGCMD $($REL_GET)
    $LOGCMD Relation members:
    $LOGCMD $($REL_LIST)
    
}

do_departed() {
    # This action should be idempotent.
    $LOGCMD "Relation $REL_NAME: $JUJU_REMOTE_UNIT departed"
}

do_broken() {
    # This action runs when the full relation is removed (not just a single member)
    $LOGCMD "Relation $REL_NAME broken"
}


do_create_symlinks() {
    THIS=$(basename "$0")
    for cmd in $REL_ACTIONS; do 
	ln -v -s "$THIS" ${REL_NAME}-relation-${cmd}
    done
}

docommand() {
    case "$COMMAND" in

	'joined')
	    do_joined
	    ;;

	'changed')
	    do_changed
	    ;;
	
	'departed')
	    do_departed
	    ;;

	'broken')
	    do_broken
	    ;;

	'create-symlinks')
	    do_create_symlinks
	    ;;

	'help')
	    echo -n "Known commands: "
	    for i in $REL_ACTIONS; do echo -n "$i "; done
	    echo "create-symlinks"
	    ;;

	*)
	    echo Unkown relation command: "'$COMMAND'" in relation $REL_NAME
	    exit 1
	    ;;
    esac
}

docommand "$@"

exit 0
