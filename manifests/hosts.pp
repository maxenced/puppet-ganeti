class ganeti::hosts {
    host { "test10" : 
	    ensure => present,
	    ip => "192.168.42.100",
	    name => "test10",
	    target => "/etc/hosts"
    }
}
