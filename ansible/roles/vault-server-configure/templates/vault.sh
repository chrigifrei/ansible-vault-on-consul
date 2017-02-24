#!/bin/sh
### BEGIN INIT INFO
# Provides:          vault
# Required-Start:    $local_fs $network $named $time $syslog
# Required-Stop:     $local_fs $network $named $time $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Description:       centralized secrets store
### END INIT INFO

SCRIPT="{{ all.bin_dir }}/vault server -config={{ vault.config_dir }}/server-config.hcl"
RUNAS="root"

PIDFILE=/var/run/vault.pid
LOGFILE="{{ vault.log_dir }}/vault.log"

start() {
  if status; then
    return 1
  fi
  echo 'Starting service…' >&2
  local CMD="$SCRIPT &> \"$LOGFILE\" & echo \$!"
  su -c "$CMD" $RUNAS > "$PIDFILE"
  echo 'Service started' >&2
}

stop() {
  if [ ! -f "$PIDFILE" ] || ! kill -0 $(cat "$PIDFILE"); then
    echo 'Service not running' >&2
    return 1
  fi
  echo 'Stopping service…' >&2
  kill -15 $(cat "$PIDFILE") && rm -f "$PIDFILE"
  echo 'Service stopped' >&2
}

status() {
  if [ -f $PIDFILE ] && kill -0 $(cat $PIDFILE); then
    echo 'Running' >&2
    return 0
  else
    echo 'Stopped' >&2
    return 1
  fi
}

case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    stop
    sleep 3
    start
    ;;
  status)
    status
    ;;
  *)
    echo "usage: $0 {start|stop|restart|status}"
esac
