#!/bin/bash

CONNECTION=""
PORT=""

for arg in "$@"; do
    case $arg in
        --connection=tcp)
        CONNECTION="tcp"
        ;;
        --connection=serial)
        CONNECTION="serial"
        ;;
        --port=*)
        PORT="${arg#*=}"
        ;;
        *)
        echo "Error: Invalid argument $arg"
        exit 1
        ;;
    esac
done

if [[ -z "$CONNECTION" ]]; then
    echo "Error: Missing --connection flag. Use:"
    echo "  --connection=tcp    for TCP connection"
    echo "  --connection=serial for Serial connection"
    exit 1
fi

if [[ "$CONNECTION" == "tcp" ]]; then
    sh socat-mux.sh -V -d -d TCP4-L:1234,reuseaddr,fork TCP:localhost:5000 &
    sleep 1

    socat -d -d pty,link=/dev/socatpty2,raw,echo=0,group-late=dialout,mode=660 TCP4:localhost:1234 &
    socat -d -d pty,link=/dev/socatpty3,raw,echo=0,group-late=dialout,mode=660 TCP4:localhost:1234 &
    wait

elif [[ "$CONNECTION" == "serial" ]]; then
    if [[ -n "$PORT" ]]; then
        SERIAL_PORT="$PORT"
        socat -d -d TCP-LISTEN:12345,reuseaddr,fork "$SERIAL_PORT",raw,echo=0,group-late=dialout,mode=660 &
    else
        SERIAL_PORT="/dev/socatpty1"
        socat -d -d TCP-LISTEN:12345,reuseaddr,fork pty,link="$SERIAL_PORT",raw,echo=0,group-late=dialout,mode=660 &
    fi

    echo "Using serial port: $SERIAL_PORT"

    socat -d -d TCP-LISTEN:12345,reuseaddr,fork "$SERIAL_PORT",raw,echo=0,group-late=dialout,mode=660 &

    sh socat-mux.sh -V -d -d TCP4-L:1234,reuseaddr,fork TCP:localhost:12345 &
    sleep 1

    socat -d -d pty,link=/dev/socatpty2,raw,echo=0,group-late=dialout,mode=660 TCP4:localhost:1234 &
    socat -d -d pty,link=/dev/socatpty3,raw,echo=0,group-late=dialout,mode=660 TCP4:localhost:1234 &
    wait

else
    echo "Error: Invalid --connection value. Use:"
    echo "  --connection=tcp    for TCP connection"
    echo "  --connection=serial for Serial connection"
    exit 1
fi
