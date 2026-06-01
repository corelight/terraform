#cloud-config

package_upgrade: false

write_files:
  - encoding: b64
    content: ${fleet_certificate}
    owner: corelight-fleetd:corelight-fleetd
    path: /etc/corelight-fleetd.pem
    permissions: '0600'
  - encoding: b64
    content: ${fleet_sensor_license}
    owner: corelight-fleetd:corelight-fleetd
    path: /etc/corelight-fleet-license.txt
    permissions: '0600'
  - content: |
      #!/bin/bash
      sed -i 's/"community-string": "/\0${community_string}/' /etc/corelight-fleetd.conf
      echo '${fleet_password}' | sudo -u corelight-fleetd /usr/bin/corelight-fleetd -c /etc/corelight-fleetd.conf create-user -a -p ${fleet_username}
      sqlite3 /var/lib/corelight-fleetd/admin "update users set require_password_change=FALSE where username='${fleet_username}';"
    owner: corelight-fleetd:corelight-fleetd
    path: /usr/local/sbin/configure_fleet.sh
    permissions: '0755'
%{ if radius_enable }
  - content: |
      Enable = true
      Address = "${radius_address}"
      SharedSecret = "${radius_shared_secret}"
    owner: corelight-fleetd:corelight-fleetd
    path: /etc/corelight-fleet-radius.toml
    permissions: '0644'
%{ endif }

bootcmd:
  - |
    if [ -f /etc/lsb-release ]; then
      curl -s https://packages.corelight.com/install/repositories/corelight/stable/script.deb.sh | bash
      apt-get update
      apt-get install -y corelight-fleet=${fleet_version}*
    elif [ -f /etc/redhat-release ]; then
      curl -s https://packages.corelight.com/install/repositories/corelight/stable/script.rpm.sh | bash
      dnf install -y corelight-fleet-${fleet_version}
    fi

runcmd:
  - systemctl enable corelight-fleetd
  - systemctl start corelight-fleetd
  - /usr/local/sbin/configure_fleet.sh
