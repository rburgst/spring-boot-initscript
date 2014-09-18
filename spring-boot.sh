#!/bin/bash
#
# Startup script for a spring boot project
#
# chkconfig: - 84 16
# description: spring boot project

# Source function library.
[ -f "/etc/rc.d/init.d/functions" ] && . /etc/rc.d/init.d/functions
[ -z "$JAVA_HOME" -a -x /etc/profile.d/java.sh ] && . /etc/profile.d/java.sh


# the name of the project, will also be used for the war file, log file, ...
PROJECT_NAME=springboot
# the user which should run the service
SERVICE_USER=root
# base directory for the spring boot jar
SPRINGBOOTAPP_HOME=/usr/local/$PROJECT_NAME
export SPRINGBOOTAPP_HOME

# the spring boot war-file
SPRINGBOOTAPP_WAR="$SPRINGBOOTAPP_HOME/$PROJECT_NAME.war"

# java executable for spring boot app, change if you have multiple jdks installed
SPRINGBOOTAPP_JAVA=$JAVA_HOME/bin/java

# spring boot log-file
LOG="/var/log/$PROJECT_NAME/$PROJECT_NAME.log"

LOCK="/var/lock/subsys/$PROJECT_NAME"

RETVAL=0

pid_of_spring_boot() {
    pgrep -f "java.*$PROJECT_NAME"
}

start() {
    [ -e "$LOG" ] && cnt=`wc -l "$LOG" | awk '{ print $1 }'` || cnt=1

    echo -n $"Starting $PROJECT_NAME: "

    cd "$SPRINGBOOTAPP_HOME"
    su $SERVICE_USER -c "nohup $SPRINGBOOTAPP_JAVA -jar \"$SPRINGBOOTAPP_WAR\"  >> \"$LOG\" 2>&1 &"

    while { pid_of_spring_boot > /dev/null ; } &&
        ! { tail --lines=+$cnt "$LOG" | grep -q ' Started \S+ in' ; } ; do
        sleep 1
    done

    pid_of_spring_boot > /dev/null
    RETVAL=$?
    [ $RETVAL = 0 ] && success $"$STRING" || failure $"$STRING"
    echo

    [ $RETVAL = 0 ] && touch "$LOCK"
}

stop() {
    echo -n "Stopping $PROJECT_NAME: "

    pid=`pid_of_spring_boot`
    [ -n "$pid" ] && kill $pid
    RETVAL=$?
    cnt=10
    while [ $RETVAL = 0 -a $cnt -gt 0 ] &&
        { pid_of_spring_boot > /dev/null ; } ; do
            sleep 1
            ((cnt--))
    done

    [ $RETVAL = 0 ] && rm -f "$LOCK"
    [ $RETVAL = 0 ] && success $"$STRING" || failure $"$STRING"
    echo
}

status() {
    pid=`pid_of_spring_boot`
    if [ -n "$pid" ]; then
        echo "$PROJECT_NAME (pid $pid) is running..."
        return 0
    fi
    if [ -f "$LOCK" ]; then
        echo $"${base} dead but subsys locked"
        return 2
    fi
    echo "$PROJECT_NAME is stopped"
    return 3
}

# See how we were called.
case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    status)
        status
        ;;
    restart)
        stop
        start
        ;;
    *)
        echo $"Usage: $0 {start|stop|restart|status}"
        exit 1
esac

exit $RETVAL
