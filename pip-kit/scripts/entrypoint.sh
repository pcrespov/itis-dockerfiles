#!/bin/sh
echo "Starting entrypoint ..."
echo "  User    :`id $(whoami)`"
echo "  Workdir :`pwd`"

# These volumes are expected mounted to host
WHO=/check

stat $WHO &> /dev/null || \
    (echo "ERROR: You must mount '$WHO' to deduce user and group ids" && exit 1)

# identifies host user and group ids
USERID=$(stat -c %u $WHO)
GROUPID=$(stat -c %g $WHO)
GROUPNAME=$(getent group ${GROUPID} | cut -d: -f1)


# TODO: if USERID == SC_USER_ID then do nothing
if [[ $USERID -eq 0 ]]
then
    addgroup $SC_USER_NAME root
else
    # take host's credentials in container's $SC_USER_NAME
    if [[ -z "$GROUPNAME" ]]
    then
        GROUPNAME=x$SC_USER_NAME
        addgroup -g $GROUPID $GROUPNAME
    else
        addgroup $SC_USER_NAME $GROUPNAME
    fi

    # creates new user with host id's
    deluser $SC_USER_NAME &> /dev/null
    adduser -u $USERID -G $GROUPNAME -D -s /bin/sh $SC_USER_NAME

    # TODO: install python packages system wide
    #find /home/itis/.local/ -user $SC_USER_ID -exec chown -h $SC_USER_NAME {} \;
fi

echo "Booting ..."
echo "  User    :`id $SC_USER_NAME`"

# TODO: 

# TODO: su-exec $SC_USER_NAME "python -m $@"
exec su-exec $SC_USER_NAME "$@"
