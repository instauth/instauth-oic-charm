#!/bin/bash

LOGCMD=$(which juju-log || echo echo)
RELSET=$(which relation-set || echo echo)
RELGET=$(which relation-get || echo echo)

# Application
APP_NAME="oic-stub"
APP_LONG_NAME="OpenID-Connect Stub Charm"

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

COMMAND=$(basename "$0")

do_start() {
    $LOGCMD "Starting $APP_NAME"
}

do_stop() {
    $LOGCMD "Stopping $APP_NAME"
}

do_upgrade_charm() {
    $LOGCMD "Upgrade $APP_NAME"
}

do_Auth_relation() {
    ACTION="$1"
    $LOGCMD Relation Auth: $ACTION
    $LOGCMD issuer_url: $($RELGET issuer_url)

    case "$ACTION" in
	'changed')
	    ;;
	'departed')
	    ;;
    esac
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
	'Auth-relation-broken')
	    do_Auth_relation "broken"
	    ;;

	'Auth-relation-changed')
	    do_Auth_relation "changed"
	    ;;
	
	'Auth-relation-departed')
	    do_Auth_relation "departed"
	    ;;

	'Auth-relation-joined')
	    do_Auth_relation "joined"
	    ;;
	

    esac
}

docommand "$@"

exit 0
