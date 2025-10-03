#! /bin/bash

calibre-server \
    --auth-mode=basic \
    --ban-after=10 \
    --ban-for=120 \
    --listen-on=127.0.0.1 \
    --port=5777 \
    --num-per-page=100 \
    --disable-use-bonjour \
    --log=${CONFIG_DIR}/calibre-server.log \
    --access-log=${CONFIG_DIR}/calibre-server-access.log \
    ${LIBS_SERVER_DIR}/*/


#    --userdb ${CONF_DIR}/users.sqlite \
#    --enable-auth \
