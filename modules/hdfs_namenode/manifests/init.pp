#  Licensed to the Apache Software Foundation (ASF) under one or more
#   contributor license agreements.  See the NOTICE file distributed with
#   this work for additional information regarding copyright ownership.
#   The ASF licenses this file to You under the Apache License, Version 2.0
#   (the "License"); you may not use this file except in compliance with
#   the License.  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

class hdfs_namenode {
  $PATH="/bin:/usr/bin"

  if $security == "true" {
    require kerberos_http
    file { "${hdfs_client::keytab_dir}/nn.keytab":
      ensure => file,
      source => "/vagrant/generated/keytabs/${hostname}/nn.keytab",
      owner => hdfs,
      group => hadoop,
      mode => '400',
    }
    ->
    exec { "kinit -k -t ${hdfs_client::keytab_dir}/nn.keytab nn/${hostname}.${domain}":
      path => $PATH,
      user => hdfs,
    }
    ->
    Package['hadoop-hdfs-namenode']
  }

  package { "hadoop-hdfs-namenode" :
    ensure => installed,
  }
  ->
  file { "/etc/init.d/hadoop-hdfs-namenode":
    ensure => file,
    source => "puppet:///files/init.d/hadoop-hdfs-namenode",
    owner => root,
    group => root,
  }
  ->
  exec {"namenode-format":
    command => "hadoop namenode -format",
    path => "$PATH",
    creates => "${hdfs_client::data_dir}/hdfs/namenode",
    user => "hdfs",
    require => Package['hadoop-hdfs-namenode'],
  }
  ->
  service {"hadoop-hdfs-namenode":
    ensure => running,
    enable => true,
  }
  ->
  exec {"hdfs-tmp":
    command => "hadoop fs -mkdir /tmp",
    unless => "hadoop fs -test -e /tmp",
    path => "$PATH",
    user => "hdfs",
  }
  ->
  exec {"hdfs-tmp-chmod":
    command => "hadoop fs -chmod 1777 /tmp",
    path => "$PATH",
    user => "hdfs",
  }
}
