if [[ -z "$PATH" || "$PATH" == "/usr/bin" ]]; then
    emulate sh -c 'source /etc/profile'
fi
