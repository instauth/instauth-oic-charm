#!/bin/bash

source "$(dirname "$0")/config.sh"

CHARM_HOOKS="install start config-changed stop upgrade-charm"
KNOWN_COMMANDS="$CHARM_HOOKS create-symlinks"
KNOWN_RELATIONS=auth

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

if [[ -L "$0" || -z "$1" ]]; then
    COMMAND=$(basename "$0")
else
    COMMAND="$1"
fi

do_install() {
    # Here do anything needed to install the service
    # i.e. apt-get install -y foo  or  bzr branch http://myserver/mycode /srv/webroot
    # Make sure this hook exits cleanly and is idempotent, common problems here are
    # failing to account for a debconf question on a dependency, or trying to pull
    # from github without installing git first.
    $LOGCMD "Installing $APP_NAME"
}

do_start() {
    # Here put anything that is needed to start the service.
    # Note that currently this is run directly after install
    $LOGCMD "Starting $APP_NAME"
}

do_config_changed() {
    # config-changed occurs everytime a new configuration value is updated (juju set)
    $LOGCMD "Configuration changed for $APP_NAME"
}

do_stop() {
    # This will be run when the service is being torn down, allowing you to disable
    # it in various ways..
    # For example, if your web app uses a text file to signal to the load balancer
    # that it is live... you could remove it and sleep for a bit to allow the load
    # balancer to stop sending traffic.
    $LOGCMD "Stopping $APP_NAME"
}

do_upgrade_charm() {
    # This action is executed each time a charm is upgraded after the new charm
    # contents have been unpacked
    # Best practice suggests you execute the hooks/install and
    # hooks/config-changed to ensure all updates are processed
    $LOGCMD "Upgrade $APP_NAME"
}

do_create_symlinks() {
    THIS=$(basename "$0")
    for cmd in $CHARM_HOOKS; do
	[ "$cmd" != "create-symlinks" ] && ln -v -s "$THIS" $cmd; 
    done
    for rel in $KNOWN_RELATIONS; do 
	./${rel}-hooks.sh create-symlinks
    done
}

docommand() {
    case "$COMMAND" in

        'install')
	    do_install
            ;;
    
        'start')
            do_start
            ;;
	
	'config-changed')
	    do_config_changed
	    ;;
    
        'stop')
            do_stop
             ;;
    
	'upgrade-charm')
	    do_upgrade_charm
	    ;;

	'create-symlinks')
	    do_create_symlinks
	    ;;
	
	'help')
	    echo "Known commands: $KNOWN_COMMANDS"
	    ;;

	*)
	    echo Unknown command: $COMMAND
	    exit 1
	    ;;
    esac
}

docommand "$@"

exit 0
