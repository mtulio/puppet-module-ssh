# Class: ssh::sshd_config
#
# Sample Usage :
#

# == Class: ssh::sshd_config
#
# Class to manage the main sshd_config file.
#
# All parameters default to undef, meaning that the original
# defaults are used.
#
# === Parameters
#
# Class to manage the main sshd_config file.
#
# === Examples
# Sample usage:
#     include '::ssh::sshd_config'
#
# === Authors
#
# Marco Túlio R Braga <git@mtulio.eng.br>
#
                                                                                    

class ssh::sshd_config (

  ### CUSTOM PARAMETERS - CLASS CONFIG ###
  $user_local_enable  = 'no',
  $user_name_ensure   = undef,
  $user_password      = undef,

  ### GLOBAL CONFIG PARAMETERS - sshd_config ###
  $port                            = undef,
  $permitrootlogin                 = undef,
  $pubkeyauthentication            = undef,
  $passwordauthentication          = undef,
  $challengeresponseauthentication = undef,
  $usepam                          = undef,
  $x11forwarding                   = undef,
  $clientaliveinterval             = undef,
  $clientalivecountmax             = undef,
  $usedns                          = undef,
  $bannerpath                      = undef,
  $match                           = undef,
  $internalsftp                    = false,
  $allow_users			   = undef,

  ## SERVICE PARAMETERS ###
  $template_dir                    = $::ssh::params::template_dir,
  $service_name                    = $::ssh::params::service_name,
) inherits ::ssh::params {

  include '::ssh::service'

  # Check local user
  if $user_local_enable == 'yes' {
    if $user_name_ensure == undef or $user_password == undef {
      fail("#> ERROR - You must set vars [user_name_ensure] and [user_password] when [user_local_enable] is enabled.")
    } 
    else { 
      $allow_users_apply = "$user_name_ensure $allow_users"

      # Create user 
      user { $user_name_ensure :
        ensure => present,
        comment          => "User $user_name_ensure - Created by Puppet"
        name             => "$user_name_ensure",
        home             => "/home/$user_name_ensure",
        password         => $user_password,
      }
    }
  }
  else { # Set allow_users
    $allow_users_apply = "$allow_users"
  }


  file { '/etc/ssh/sshd_config':
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => template("${module_name}/${template_dir}/sshd_config.erb"),
    notify  => Service[$service_name],
  }

}