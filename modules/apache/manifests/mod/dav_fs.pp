class apache::mod::dav_fs {
  $dav_lock = $::osfamily ? {
    'debian' => "${APACHE_LOCK_DIR}/DAVLock",
    default  => '/var/lib/dav/lockdb',
  }

  Class['apache::mod::dav'] -> Class['apache::mod::dav_fs']
  apache::mod { 'dav_fs': }

  # Template uses: $dav_lock
  file { 'dav_fs.conf':
    ensure  => file,
    path    => "${apache::mod_dir}/dav_fs.conf",
    content => template('apache/mod/php.conf.erb'),
  }
}
