#!/bin/sh

# Application
APP_NAME="instauth-enhancer"
APP_LONG_NAME="Simple instauth manager charm"

# Support
LOGCMD=$(which juju-log || echo echo)


# This is the interface script that is used to configure the hosting unit.
# It is host-specific and should be resolved when joining the sso-host-relation
HOST_SCR=hooks/host-configurer

