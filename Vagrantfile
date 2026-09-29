# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # Names the machine "codavm" instead of the default "default" (affects
  # `vagrant ssh-config` Host entry, libvirt domain name, log prefixes, etc).
  config.vm.define "codavm"

  # Ubuntu 24.04 (kernel 6.8+) has native ID-mapped mount support, which
  # Sysbox needs and which avoids having to build/install the shiftfs module.
  config.vm.box = "bento/ubuntu-24.04"

  config.vm.hostname = "codavm"

  VBOX_IP = "192.168.56.10"
  LIBVIRT_IP = "172.28.128.100"

  # VirtualBox
  config.vm.provider :virtualbox do |vb, override|
    vb.memory = 8192
    vb.cpus = 4
    override.vm.disk :disk, size: "60GB", primary: true
    override.vm.network "private_network", ip: VBOX_IP
  end

  # libvirt
  config.vm.provider :libvirt do |lv, override|
    lv.memory = 8192
    lv.cpus = 4
    lv.machine_virtual_size = 60
    override.vm.network "private_network", ip: LIBVIRT_IP

    # Works around a vagrant-libvirt bug where the auto-detected custom CPU
    # model ends up with a vendor but no model in the generated domain XML,
    # causing "CPU vendor specified without CPU model" on redefine.
    lv.cpu_mode = "host-passthrough"
  end

  # Expand the file-system to the disk size
  config.vm.provision "shell", inline: <<-SHELL
    lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv
    resize2fs /dev/ubuntu-vg/ubuntu-lv
  SHELL

  # Required for VS Code Remote-SSH / Dev Containers to work smoothly.
  config.ssh.forward_agent = true

  # Carry the host's git identity into the VM, if present.
  host_git_config = File.expand_path("~/.config/git/config")
  if File.exist?(host_git_config)
    # Remove any prior copy first: SCP preserves the source file's mode, and
    # a read-only source produces a guest file that a later re-provision
    # can't overwrite.
    config.vm.provision "shell", inline: "mkdir -p ~/.config/git && rm -f ~/.config/git/config", privileged: false
    config.vm.provision "file", source: host_git_config, destination: ".config/git/config"
  end

  # Carry the host's SSH keypair into the VM, if present (e.g. for git over SSH).
  # Preference order matches ssh(1)'s default identity file search. Declared
  # before provision.sh's registration below so it runs before provision.sh,
  # which relies on the key already being in place.
  key_basename = ["id_ed25519", "id_ecdsa", "id_rsa"].find do |name|
    File.exist?(File.expand_path("~/.ssh/#{name}"))
  end
  if key_basename
    host_ssh_key = File.expand_path("~/.ssh/#{key_basename}")
    config.vm.provision "shell", inline: "mkdir -p ~/.ssh && chmod 700 ~/.ssh && rm -f ~/.ssh/#{key_basename} ~/.ssh/#{key_basename}.pub", privileged: false
    config.vm.provision "file", source: host_ssh_key, destination: ".ssh/#{key_basename}"
    config.vm.provision "file", source: "#{host_ssh_key}.pub", destination: ".ssh/#{key_basename}.pub"
    config.vm.provision "shell", inline: "chmod 600 ~/.ssh/#{key_basename} && chmod 644 ~/.ssh/#{key_basename}.pub", privileged: false
  end

  # Run the core provisioning script. Declared after the git-config/SSH-key
  # provisioners above so it runs after them (it relies on the key already
  # being in place).
  config.vm.provider :virtualbox do |vb, override|
    override.vm.provision "shell", path: "provision.sh", env: { "EXT_IP_ADDR" => VBOX_IP }
  end

  config.vm.provider :libvirt do |lv, override|
    override.vm.provision "shell", path: "provision.sh", env: { "EXT_IP_ADDR" => LIBVIRT_IP }
  end

  # Save the ssh-config to a local file after the VM is brought up.
  # This can then be included in your SSH client configuration for easy access to the VM.
  # e.g. with 'Include <path_to_this_directory>/ssh-config'
  config.trigger.after :up do |trigger|
    trigger.info = "Updating ./ssh-config"
    trigger.run = {
      inline: "bash -c 'vagrant ssh-config > ssh-config'"
    }
  end
end
