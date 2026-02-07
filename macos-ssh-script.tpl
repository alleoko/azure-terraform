add-content - /Users/m1air/.ssh/config -value @'

Host ${hostname}
    HostName ${hostname}
    User ${adminUsername}
    IdentityFile $(IdentityFile)

    