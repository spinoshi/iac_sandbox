
cat <<'EOF' > /etc/netplan/50-vagrant.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s8:
      addresses:
      - 192.168.56.10/24
      routes:
        - to: 10.20.20.1/32
          via: 192.168.56.200
EOF

netplan apply
