if [[ -z "$PATH" || "$PATH" == "/usr/local/sbin:/usr/local/bin:/usr/bin" || $PATH == /bin* ]]; then
    emulate sh -c 'source /etc/profile'
fi
