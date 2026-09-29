# provision.d/

Optional, user-specific customizations layered on top of the reusable core
provisioning in [`provision.sh`](../provision.sh).

`provision.sh` sources every `*.sh` file here in name-sorted order, after all
core provisioning has completed. The directory can be absent or empty — core
provisioning works standalone either way. Use a numeric prefix (e.g. `10-`,
`20-`) on filenames to control run order.

Each hook is sourced (not executed as a subprocess), so it shares the same
shell as `provision.sh` and can use its variables and functions, e.g.:

- `SSH_USER` — the guest user provisioning runs as
- `has_ssh_key` — true if the host's SSH keypair was carried into the VM
- `clone_repo <url>` — clones a repo with the same guard/retry behavior as
  the core repos
- `REPOS` — the array of repos core cloned (for hooks that need to know
  which repos/directories already exist)
