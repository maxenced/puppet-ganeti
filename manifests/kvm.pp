class ganeti::kvm {
        package { "kvm":
            ensure => latest
        }
    }
