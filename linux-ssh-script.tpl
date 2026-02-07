cat <<EOF >> ~/.ssh/config

Host ${hostname}
    HostName ${hostname}
    User ${adminUsername}
    IdentityFile $(IdentityFile)
EOF
    