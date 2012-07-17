import "classes/clocksource.pp"
import "classes/drbd.pp"
import "classes/ganeti.pp"
import "classes/hooks.pp"
import "classes/kvm.pp"
import "classes/ntp.pp"
import "classes/xenbridge.pp"
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
    include ganeti::drbd
    include ganeti::xenbridge
}

mport "classes/xen.pp"

# vim: set ts=4 sw=4 et:
