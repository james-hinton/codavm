# Coda VM

This repository defines a Vagrant VM for running the EOEPCA Localcoda tutorials. Provisioning installs Docker and Sysbox, then clones `localcoda` and `eoepca-killercoda` into the VM's `vagrant` home directory.

## Requirements

- Git and Vagrant installed on the host.
- One Vagrant provider installed and usable by your user:
  - **VirtualBox:** install Oracle VirtualBox.
  - **libvirt:** install and configure libvirt/QEMU for your host, then install the Vagrant provider plugin with `vagrant plugin install vagrant-libvirt`. The plugin may also require host development libraries; follow the `vagrant-libvirt` installation instructions for your distribution.
- The Vagrant Triggers plugin, used to generate the local `ssh-config` file after startup:

  ```sh
  vagrant plugin install vagrant-triggers
  ```

The default VM resources are 4 CPUs, 8 GB RAM, and a 60 GB disk. Make sure the host has enough available resources. These host environment variables configure VM resources, guest addresses, and the tutorial branch:

| Environment variable | Default | Setting |
| --- | ---: | --- |
| `CODAVM_CPUS` | `4` | Virtual CPUs |
| `CODAVM_MEMORY_MB` | `8192` | Memory in MB |
| `CODAVM_DISK_GB` | `60` | Disk size in GB |
| `CODAVM_VBOX_IP` | `192.168.56.10` | VirtualBox guest IP |
| `CODAVM_LIBVIRT_IP` | `172.28.128.100` | libvirt guest IP |
| `CODAVM_KILLERCODA_BRANCH` | `eoepca-2.1` | Tutorial repository branch |

For example, to use fewer resources with libvirt:

```sh
export CODAVM_CPUS=2
export CODAVM_MEMORY_MB=4096
export CODAVM_DISK_GB=40
vagrant up --provider=libvirt
```

Keep the variables set for later Vagrant commands in that shell so its configuration continues to match the VM. Resource values must be positive integers; IP overrides must be IPv4 addresses. Initial startup provisions Ubuntu, installs Docker and Sysbox, and clones the tutorial repositories, so allow time for downloads and ensure the host has internet access.

The provider IP variables are optional. If you override one, choose an unused IPv4 address on that provider's private network; the configured address is also used to derive the tutorial environment's nip.io domain. For example, to change the libvirt guest IP:

```sh
export CODAVM_LIBVIRT_IP=172.28.128.110
vagrant up --provider=libvirt
```

## Start the VM

Clone this repository on the host and enter its directory:

```sh
git clone https://github.com/rconway/codavm.git
cd codavm
```

Start the VM using your chosen provider. Specify the provider explicitly if more than one is installed:

```sh
vagrant up --provider=virtualbox
```

Or, for libvirt:

```sh
vagrant up --provider=libvirt
```

Vagrant downloads the Ubuntu box the first time it is needed. When provisioning finishes, connect to the VM:

```sh
vagrant ssh
```

## Run a tutorial

In the VM, change to the tutorials checkout and run a tutorial by its directory name:

```sh
cd ~/eoepca-killercoda
./run.sh discovery
```

Replace `discovery` with the name of another tutorial directory in `eoepca-killercoda`. Provisioning checks out the `eoepca-2.1` branch by default and configures the tutorial environment to use the neighboring `~/localcoda` checkout. To use a different branch, set the override before starting the VM:

```sh
export CODAVM_KILLERCODA_BRANCH=my-feature-branch
vagrant up --provider=libvirt
```

For an existing VM, set the variable and run `vagrant provision` to switch its checkout to that branch.

## VM lifecycle

Run these commands from the host, in this repository's directory:

```sh
vagrant halt       # stop the VM
vagrant up         # start it again
vagrant destroy    # delete the VM and its virtual disk
```

The generated `ssh-config` file can also be used to connect with a regular SSH client:

```sh
ssh -F ssh-config codavm
```

The VM is disposable: `vagrant destroy` removes its disk, including the cloned repositories and any tutorial data stored in the VM.

## Custom provisioning

The core setup in `provision.sh` is extended by shell hooks in `provision.d/`. During provisioning, every `*.sh` hook in that directory is sourced automatically, in filename order, after the core packages and repositories are set up. Hooks can therefore apply machine- or user-specific configuration without changing the reusable core script. The directory can be empty or absent; numeric filename prefixes such as `10-` and `20-` control the order when multiple hooks are used.

Hooks run in the provisioning script's shell context and can use its variables and helper functions. Treat them as provisioning code: review what they do before running `vagrant up` or `vagrant provision`. See the [provision.d README](provision.d/README.md) for the hook interface, available helpers, and examples.

## Notes

- The Vagrantfile supports VirtualBox and libvirt. The provider selected by `vagrant up` must be installed on the host.
- If a host SSH key is present, Vagrant copies it into the guest during provisioning.
- If provisioning needs to be rerun after a change, use `vagrant provision` from the host repository directory.