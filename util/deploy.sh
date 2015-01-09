#!/bin/sh

#set -x

. util/deploy.sh.rc

TARGET=${1:-origin/master}
DATE=`date '+%Y-%m-%dT%H%M%S'`
STAGING_DIR="/tmp/deploy-$DATE"

ssh -t $HOST "
    git clone '$CLONE_PATH' '$STAGING_DIR' &&
    cd '$STAGING_DIR' &&
    git checkout --force $TARGET &&
    git submodule update --init &&
    cp -ar '$DIR/local' . &&
    carton install &&
    carton exec -- prove -Ilib -It/lib -r t
" || exit 1

ssh -t $HOST "
    cd $DIR &&
    sudo supervisorctl stop $SUPERVISORD_SERVICES
    rsync -avz --delete '$STAGING_DIR/local/' local/ &&
    git fetch --all &&
    git checkout --force $TARGET &&
    git submodule update --init &&
    carton install &&
    cp '$DB_FILE' '$DB_FILE.${DATE}.bak' &&
    carton exec -- mimi migrate --dsn 'dbi:SQLite:$DB_FILE' --schema schema --verbose &&
    sudo supervisorctl start $SUPERVISORD_SERVICES

    rm -rf '$STAGING_DIR'
" || exit 1
