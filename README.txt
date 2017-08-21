# ENV
# Ubuntu server 16.04.3 LTS
# ruby 2.2.2p95

# lxc info
api_status: stable
api_version: "1.0"
environment:
  driver: lxc
  driver_version: 2.0.8
  kernel: Linux
  kernel_architecture: x86_64
  kernel_version: 4.4.0-92-generic
  server: lxd
  server_version: 2.0.10
  
gems:
thin
sinatra
ruby-libvirt
hyperkit
haml
namey
