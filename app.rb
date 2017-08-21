#!/usr/bin/env ruby
require 'sinatra'
require 'hyperkit'
require 'libvirt'
require 'namey'         # generate names
require 'securerandom'  # generate uuids

require './helpers'

helpers PageUtils, VmUtils
lxd = Hyperkit::Client.new(api_endpoint: "https://localhost:8443", verify_ssl: false)
kvm = Libvirt::open("qemu:///system")
namey = Namey::Generator.new

get '/' do
  @test = "Wie geht´s?"
  haml :index
end

####### LXC Part

get '/lxc' do
  @running_code = 103
  @containers = []
  lxd.containers.each do |c|
    container  = []
    container << lxd.container(c).name
    container << lxd.container_state(c).status_code
    container << lxd.container(c).profiles[0]
    if lxd.container_state(c).status_code == @running_code
      container << lxd.container_state(c).network.first[1].addresses[0].address
    else
      container << " - "
    end

    img_id = lxd.container(c).config.first[1]
    unless img_id.nil?
      lxd.images.each do |i|
          container << lxd.image(i).aliases[0].name if i == img_id
      end
    else
      container << " - "
    end

    @containers << container
  end
  haml :lxc
end

get '/lxc/create' do
  lxd.create_container(namey.name(:common, false), alias: "ubi16")
  haml :lxc_create
end

get '/lxc/images' do
  @imgs = []
  lxd.images.each do |i|
    img = []
    unless lxd.image(i).aliases[0].nil?
      img << lxd.image(i).aliases[0].name
    else
      img << " - "
    end
    img << lxd.image(i).properties.description
    img << "#{(lxd.image(i).size.to_f / 1024 / 1024).round(2)} MiB"
    img << (lxd.image(i).last_used_at).strftime('%d-%m-%Y')
    @imgs << img
  end
  haml :lxc_images
end

get '/lxc/start/:name' do
  response = lxd.start_container(params['name'])
  redirect '/lxc'
end

get '/lxc/stop/:name' do
  response = lxd.stop_container(params['name'])
  redirect '/lxc'
end

get '/lxc/delete/:name' do
  response = lxd.delete_container(params['name'])
  redirect '/lxc'
end

####### KVM Part

get '/vm' do
  @vms = kvm.list_all_domains
  haml :vm
end

get '/vm/create' do
  vm_name = namey.name(:common, false)
  vm_uuid = "#{SecureRandom.uuid}"
  vm_disk = "/var/lib/libvirt/images/#{vm_name}_00.qcow2"
  vm_xml  = templatexml vm_name, vm_uuid, vm_disk
  `cp /home/basti/iso/template.qcow2 #{vm_disk}` ## centos preinstalled..
  vm = kvm.define_domain_xml(vm_xml)
  vm.create
end
