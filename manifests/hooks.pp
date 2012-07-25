class ganeti::hooks {

    # Non-templated files
    file { '/etc/ganeti/instance-debootstrap':
            ensure  => directory,
            owner   => 'root',
            group   => 'root',
            #mode   => 644, # Cannot apply mode, or it will change ALL files
            source  => 'puppet:///ganeti/ganeti/instance-debootstrap',
            recurse => true,
            replace => true,
            force   => true,
            purge   => true,
            ignore  => [ '.git', '.swp', ],
            notify  => [Exec['remover cache ganeti'],Exec['permissions hook']]
    }

    exec { "chmod +x /etc/ganeti/instance-debootstrap/hooks/*":
        alias => "permissions hook",
        refreshonly => true
    }

    # Purge cache files after modify hooks
    exec { '/bin/rm -f /var/cache/ganeti-instance-debootstrap/cache-squeeze-amd64.tar':
        refreshonly => true,
        alias       => 'remover cache ganeti',
    }


    # Templated files
    # Require dnssearch and nameservers
    file { '/etc/ganeti/instance-debootstrap/hooks/03_network':
        ensure  => present,
        content => template('ganeti/03_network.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => 755,
        notify  => Exec['remover cache ganeti'],
    }

}

# vim: set ts=4 sw=4 et:
