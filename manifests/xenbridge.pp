class ganeti::xenbridge {

    service { 'networking':
        hasrestart => true,
        status => '/bin/true',
    }

    file { '/etc/network/interfaces':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => 644,
    }

    exec { '/bin/echo "auto xen-br0" >> /etc/network/interfaces':
        unless => '/bin/grep -q "auto xen-br0" /etc/network/interfaces',
        alias => "echo auto"
    }
    exec { '/bin/echo "iface xen-br0 inet static" >> /etc/network/interfaces':
        unless => '/bin/grep -q "iface xen-br0 inet static" /etc/network/interfaces',
        alias => "inet static",
        require => Exec["echo auto"],
    }
    exec { '/bin/echo "        address 192.168.42.1" >> /etc/network/interfaces':
        unless => '/bin/grep -q "address 192.168.42.1" /etc/network/interfaces',
        notify => Exec["netmask"],
        require => Exec["inet static"],
    }
    exec { '/bin/echo "        netmask 255.255.255.0" >> /etc/network/interfaces':
        refreshonly => true,
        alias => "netmask",
        require => Exec["inet static"],
    }
    exec { '/bin/echo "        pre-up brctl addbr xen-br0" >> /etc/network/interfaces':
        unless => '/bin/grep -q "pre-up brctl addbr xen-br0" /etc/network/interfaces',
        notify => Service['networking'],
        require => Exec["inet static"],
        before => Service['networking'],
    }
    exec { '/bin/echo "        post-down brctl delbr xen-br0" >> /etc/network/interfaces':
        unless => '/bin/grep -q "post-down brctl delbr xen-br0" /etc/network/interfaces',
        notify => Service['networking'],
        require => Exec["inet static"],
        before => Service['networking'],
    }

    exec { '/bin/echo "        bridge_fd 0" >> /etc/network/interfaces':
        unless => '/bin/grep -q "bridge_fd 0" /etc/network/interfaces',
        notify => Service['networking'],
        require => Exec["inet static"],
        before => Service['networking'],
    }

    exec { '/bin/echo "        bridge_stp off" >> /etc/network/interfaces':
        unless => '/bin/grep -q "bridge_stp off" /etc/network/interfaces',
        notify => Service['networking'],
        require => Exec["inet static"],
        before => Service['networking'],
    }
}

# vim: set ts=4 sw=4 et:
