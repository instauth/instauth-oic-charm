#!/bin/bash

source "$(dirname "$0")/config.sh"

REL_SET=$(which relation-set   || echo echo "relation-set ")
REL_GET=$(which relation-get   || echo echo "relation-get ")
REL_LIST=$(which relation-list || echo echo "relation-list " )

REL_ACTIONS="joined changed departed broken"


# Get the fully qualified path to the script
case $0 in
    /*)
        SCRIPT="$0"
        ;;
    *)
        PWD=`pwd`
        SCRIPT="$PWD/$0"
        ;;
esac

# Resolve the true real path without any sym links.
CHANGED=true
while [ "X$CHANGED" != "X" ]
do
    # Change spaces to ":" so the tokens can be parsed.
    SAFESCRIPT=`echo $SCRIPT | sed -e 's; ;:;g'`
    # Get the real path to this script, resolving any symbolic links
    TOKENS=`echo $SAFESCRIPT | sed -e 's;/; ;g'`
    REALPATH=
    for C in $TOKENS; do
        # Change any ":" in the token back to a space.
        C=`echo $C | sed -e 's;:; ;g'`
        REALPATH="$REALPATH/$C"
        # If REALPATH is a sym link, resolve it.  Loop for nested links.
        while [ -h "$REALPATH" ] ; do
            LS="`ls -ld "$REALPATH"`"
            LINK="`expr "$LS" : '.*-> \(.*\)$'`"
            if expr "$LINK" : '/.*' > /dev/null; then
                # LINK is absolute.
                REALPATH="$LINK"
            else
                # LINK is relative.
                REALPATH="`dirname "$REALPATH"`""/$LINK"
            fi
        done
    done

    if [ "$REALPATH" = "$SCRIPT" ]
    then
        CHANGED=""
    else
        SCRIPT="$REALPATH"
    fi
done


# Relation
SCRIPT_BASENAME=$(basename "$SCRIPT")
REL_NAME=${SCRIPT_BASENAME%-hooks.sh}


# Command
if [ -L "$0" ]; then
    COMMAND=$(basename "$0")
else
    COMMAND="$1"
fi


# hook implementations

do_joined() {
    # This action should be idempotent.
    $LOGCMD "Relation $REL_NAME: $JUJU_REMOTE_UNIT joined"
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
    for cmd in broken changed departed joined; do 
	ln -v -s "$THIS" ${REL_NAME}-relation-${cmd}
    done
}

docommand() {
    case "$COMMAND" in

	"${REL_NAME}-relation-joined")
	    do_joined
	    ;;

	"${REL_NAME}-relation-changed")
	    do_changed
	    ;;
	
	"${REL_NAME}-relation-departed")
	    do_departed
	    ;;

	"${REL_NAME}-relation-broken")
	    do_broken
	    ;;

	'create-symlinks')
	    do_create_symlinks
	    ;;

	'help')
	    echo -n "Known commands: "
	    for i in $REL_ACTIONS; do echo -n "${REL_NAME}-relation-$i "; done
	    echo "create-symlinks"
	    ;;

	*)
	    echo Unkown relation command: "$COMMAND"
	    exit 1
	    ;;
    esac
}

docommand "$@"

exit 0
