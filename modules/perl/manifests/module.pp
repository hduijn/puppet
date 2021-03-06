# Define: perl::module
#
# Installs the defined perl module
#
# Variables:
# [*use_package*]
#   (default=true) - Tries to install perl module with the relevant OS package
#   If set to "no" it installs the module via a cpanm command
#
# Usage:
# perl::module { packagename: }
# Example:
# perl::module { 'Net::SSLeay': }
#
define perl::module (
  $use_package         = false,
  $package_name        = '',
  $package_prefix      = $perl::package_prefix,

  $url                 = '',
  $exec_path           = '/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin:/usr/local/sbin',
  $exec_environment    = [],
  $exec_timeout        = '600',

  $ensure              = 'present'
  ) {

  require perl
  require perl::cpanminus

  $pkg_name = regsubst($name,'::','-')
  $real_package_name = $package_name ? {
    ''      => "${package_prefix}${pkg_name}",
    default => $package_name,
  }

  $bool_use_package = any2bool($use_package)

  $install_name = $url ? {
    ''      => $name,
    default => $url,
  }

  $cpan_command = $ensure ? {
    present => "cpanm ${install_name}",
    absent  => "pm-uninstall -f ${name}",
  }

  $cpan_command_check = $ensure ? {
    present => "perldoc -l ${name}",
    absent  => "perldoc -l ${name} || true",
  }

  case $bool_use_package {
    true: {
      package { "perl-${name}":
        ensure  => $ensure,
        name    => $real_package_name,
      }
    }
    default: {
      exec { "cpan-${name}-${ensure}":
        command     => $cpan_command,
        unless      => $cpan_command_check,
        path        => $exec_path,
        environment => $exec_environment,
        timeout     => $exec_timeout,
      }
    }
  }

}
