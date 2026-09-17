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
      curl -fsSL "https://${corelight_package_repo_token}:@pkgrepos.corelight.cloud/corelight/fleet-stable/gpgkey" | gpg --dearmor | tee /etc/apt/keyrings/corelight_fleet-stable-archive-keyring.gpg > /dev/null
      echo "deb [signed-by=/etc/apt/keyrings/corelight_fleet-stable-archive-keyring.gpg] https://pkgrepos.corelight.cloud/corelight/fleet-stable/any/ any main" > /etc/apt/sources.list.d/corelight_fleet-stable.list
      mkdir -p /etc/apt/auth.conf.d
      echo "machine pkgrepos.corelight.cloud/corelight/fleet-stable/ login ${corelight_package_repo_token} password irrelevant" > /etc/apt/auth.conf.d/corelight_fleet-stable.conf
      apt-get update
      apt-get install -y corelight-fleet=${fleet_version}*
    elif [ -f /etc/redhat-release ]; then
      cat > /etc/yum.repos.d/corelight_fleet-stable.repo << 'REPO'
[corelight_fleet-stable_any]
name=corelight_fleet-stable_any
baseurl=https://${corelight_package_repo_token}:@pkgrepos.corelight.cloud/corelight/fleet-stable/rpm_any/rpm_any/$basearch
repo_gpgcheck=1
gpgcheck=0
enabled=1
gpgkey=https://${corelight_package_repo_token}:@pkgrepos.corelight.cloud/corelight/fleet-stable/gpgkey https://downloads.corelight.cloud/public/signing/corelight-package-signing-key.asc
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300
REPO
      dnf install -y corelight-fleet-${fleet_version}
    fi

runcmd:
  - systemctl enable corelight-fleetd
  - systemctl start corelight-fleetd
  - /usr/local/sbin/configure_fleet.sh
