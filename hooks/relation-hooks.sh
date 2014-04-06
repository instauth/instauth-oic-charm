#!/bin/bash

LOGCMD=$(which juju-log || echo echo)
RELSET=$(which relation-set || echo echo)
RELGET=$(which relation-get || echo echo)

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


if [ -L "$0" ]; then
    COMMAND=$(basename "$0")
else
    COMMAND="$1"
fi

do_start() {
    $LOGCMD "Starting $APP_NAME"
}

do_stop() {
    $LOGCMD "Stopping $APP_NAME"
}

do_upgrade_charm() {
    $LOGCMD "Upgrade $APP_NAME"
}

do_auth_relation() {
    ACTION="$1"
    $LOGCMD Relation auth: $ACTION
    $LOGCMD issuer_url: $($RELGET issuer_url)

    case "$ACTION" in
	'changed')
	    ;;
	'departed')
	    ;;
    esac
}

do_create_symlinks() {
    THIS=$(basename "$0")
    for cmd in broken changed departed joined; do 
	ln -s "$THIS" ${REL_NAME}-relation-${cmd}
    done
}

docommand() {
    case "$COMMAND" in
        'start')
            do_start
            ;;
    
        'stop')
            do_stop
             ;;
    
        'install')
	    do_install
            ;;
    
	'upgrade-charm')
	    do_upgrade_charm
	    ;;
	'auth-relation-broken')
	    do_auth_relation "broken"
	    ;;

	'auth-relation-changed')
	    do_auth_relation "changed"
	    ;;
	
	'auth-relation-departed')
	    do_auth_relation "departed"
	    ;;

	'auth-relation-joined')
	    do_auth_relation "joined"
	    ;;
	'create-symlinks')
	    do_create_symlinks
	    ;;
	*)
	    echo Unkown relation command: "$COMMAND"
	    exit 1
	    ;;
    esac
}

docommand "$@"

exit 0
