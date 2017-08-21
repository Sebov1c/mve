module PageUtils
  def active_page?(path='')
    request.path_info == '/' + path
  end
end

module VmUtils
  def templatexml(vm_name, vm_uuid, vm_disk)
    xml = <<EOF
      <domain type='kvm'>
        <name>#{vm_name}</name>
        <uuid>#{vm_uuid}</uuid>
        <memory unit='KiB'>2097152</memory>
        <currentMemory unit='KiB'>2097152</currentMemory>
        <vcpu placement='static'>1</vcpu>
        <os>
          <type arch='x86_64' machine='pc-i440fx-xenial'>hvm</type>
          <boot dev='hd'/>
        </os>
        <features>
          <acpi/>
          <apic/>
        </features>
        <cpu mode='custom' match='exact'>
          <model fallback='allow'>Opteron_G4</model>
        </cpu>
        <clock offset='utc'>
          <timer name='rtc' tickpolicy='catchup'/>
          <timer name='pit' tickpolicy='delay'/>
          <timer name='hpet' present='no'/>
        </clock>
        <on_poweroff>destroy</on_poweroff>
        <on_reboot>restart</on_reboot>
        <on_crash>restart</on_crash>
        <pm>
          <suspend-to-mem enabled='no'/>
          <suspend-to-disk enabled='no'/>
        </pm>
        <devices>
          <emulator>/usr/bin/kvm-spice</emulator>
          <disk type='file' device='disk'>
            <driver name='qemu' type='qcow2'/>
            <source file='#{vm_disk}'/>
            <target dev='vda' bus='virtio'/>
            <address type='pci' domain='0x0000' bus='0x00' slot='0x07' function='0x0'/>
          </disk>
          <disk type='file' device='cdrom'>
            <driver name='qemu' type='raw'/>
            <target dev='hda' bus='ide'/>
            <readonly/>
            <address type='drive' controller='0' bus='0' target='0' unit='0'/>
          </disk>
          <controller type='pci' index='0' model='pci-root'/>
          <controller type='ide' index='0'>
            <address type='pci' domain='0x0000' bus='0x00' slot='0x01' function='0x1'/>
          </controller>
          <controller type='virtio-serial' index='0'>
            <address type='pci' domain='0x0000' bus='0x00' slot='0x05' function='0x0'/>
          </controller>
          <interface type='bridge'>
            <source bridge='br0'/>
            <model type='virtio'/>
            <address type='pci' domain='0x0000' bus='0x00' slot='0x03' function='0x0'/>
          </interface>
          <console type='pty'>
            <target type='serial' port='0'/>
          </console>
          <channel type='unix'>
            <source mode='bind'/>
            <target type='virtio' name='org.qemu.guest_agent.0'/>
            <address type='virtio-serial' controller='0' bus='0' port='1'/>
          </channel>
          <channel type='spicevmc'>
            <target type='virtio' name='com.redhat.spice.0'/>
            <address type='virtio-serial' controller='0' bus='0' port='2'/>
          </channel>
          <input type='mouse' bus='ps2'/>
          <input type='keyboard' bus='ps2'/>
          <graphics type='spice' autoport='yes'>
            <image compression='off'/>
          </graphics>
          <video>
            <model type='qxl' ram='65536' vram='65536' vgamem='16384' heads='1'/>
            <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x0'/>
          </video>
          <redirdev bus='usb' type='spicevmc'>
          </redirdev>
          <memballoon model='virtio'>
            <address type='pci' domain='0x0000' bus='0x00' slot='0x08' function='0x0'/>
          </memballoon>
        </devices>
      </domain>
EOF

  end
end
