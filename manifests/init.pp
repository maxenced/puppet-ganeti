class ganeti {
    package { 'ganeti2': ensure => installed, }

    $hostline = inline_template('<%= ipaddress %>	<%= fqdn %> <%= hostname %>')

    exec { "/usr/bin/perl -pi -e 's/^$ipaddress.*/$hostline/' /etc/hosts":
        unless => "/bin/grep -q '$hostline' /etc/hosts",
    }

    file { '/etc/hostname':
        content => "$fqdn\n",
        notify  => Service['hostname'],
    }

    file { '/etc/lvm/lvm.conf':
        source  => 'puppet:///ganeti/lvm/lvm.conf',
    }

    service { 'hostname': }

    case $hypervisor {
        "xen" : {
            include ganeti::xen
        }
        "kvm" : {
            include ganeti::kvm
        }
    }
    line { "host_${clustername}":
        file => "/etc/hosts",
        line => "${clustername_ip} ${clustername}"
    }
    include ganeti::drbd
    include ganeti::xenbridge
    include ganeti::hosts
}

class ganeti::master {
    include ganeti
    exec { "gnt-cluster init --vg-name=${gnt_vgname} ${clustername}":
        unless => "gnt-cluster getmaster",
        require => [Line["host_${clustername}"], Exec["modprobe drbd"], Exec["echo modules"]],
        alias => "create cluster",
        notify => [Exec["enable vnc"], Exec["enable kvm"],Exec["fullvirt"]]
    }
    exec { "gnt-cluster modify -H kvm:vnc_bind_address=127.0.0.1":
        refreshonly => true,
        alias => "enable vnc"
    }
    exec { "gnt-cluster modify --enabled-hypervisors=kvm":
        refreshonly => true,
        alias => "enable kvm"
    }
    exec { "gnt-cluster modify -H kvm:kernel_path=":
        refreshonly => true,
        alias => "fullvirt"
    }
}

# vim: set ts=4 sw=4 et:
