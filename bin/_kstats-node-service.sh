#!/bin/bash
#
# Launch kstats-node as a service. Log everything into a log file, create a pid file used to start/stop the service.
#
#

COMMAND="$1"
shift 1

while getopts p:l:c: o
do
        case "$o" in
        p)
                PIDFILE="$OPTARG";;
        l)
                LOGFILE="$OPTARG";;
        c)
                CONFIG="$OPTARG";;
        [?])
                echo >&2 "Usage: $0 [start|stop|restart|force-reload] -p pidfile -l logfile -c configfile"
                exit 1;;
        esac
done

if [[ -z "$LOGFILE" || -z "PIDFILE" || -z "$CONFIG" ]]; then
        echo >&2 "Usage: $0 [start|stop|restart|force-reload] -p pidfile -l logfile -c configfile"
        exit 1
fi

case "$COMMAND" in
        start)
                if [[ -e "$PIDFILE" ]]; then
                        echo "'$PIDFILE' already exists. Try to stop running kstats-node first"
                        exit 1
                fi

                echo "Start kstats-node..."
                (kstats-node --config $CONFIG > $LOGFILE 2>&1)&
                echo $! > $PIDFILE
                echo "kstats-node started."
                ;;
        stop)
                echo "Stop kstats-node..."
                if [[ -e "$PIDFILE" ]]; then
                        kill `cat $PIDFILE`
                        rm $PIDFILE
                        echo "kstats-node stopped."
                else
                        echo "Nothing to stop."
                        exit 1
                fi
                ;;
        restart|force-reload)
                echo "Restart kstats-node..."
                if [[ -e "$PIDFILE" ]]; then
                        kill `cat $PIDFILE`
                        rm $PIDFILE
                fi
                (kstats-node --config $CONFIG > $LOGFILE 2>&1)&
                echo $! > $PIDFILE
                echo "kstats-node restarted."
                ;;
        *)
                echo >&2 "Usage: $0 [start|stop|restart|force-reload] -p pidfile -l logfile -c configfile"
                exit 1
                ;;
esac

exit 0
