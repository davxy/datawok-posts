+++
title = "Btrfs Snapshots"
date = "2021-03-29"
tags = ["system","btrfs"]
toc = true
+++

Btrfs snapshots allow you to create efficient backups of your filesystem.

We'll explore some of the basics of Btrfs snapshots and their practical
applications.

Snapshot feature of Btrfs uses the Copy-on-Write (CoW) strategy. So it doesn't
take much disk space and snapshots of subvolumes are instantaneous.

Two snapshot types:
- read-write: the snapshot file and directories may be modified. This is the
  default type.
- read-only: the snapshot files and directories can not be modified.

## Friendly subvolumes layout

It may be a good idea to heave separated subvolumes for `/home` and `/.snapshots`
folders.

Mount the btrfs root subvolume:

```bash
    $ mount -t btrfs -o subvolid=5 /dev/sda2 /mnt/btrfs
```

Create the required subvolumes at the same level of the root subvolume:

```bash
    $ sudo btrfs subvolume create /mnt/btrfs/@home
    $ sudo btrfs subvolume create /mnt/btrfs/@snapshots
```
This is the layout we're going to get

```
    subvolid=5
      +--- @rootfs
      +--- @home
      +--- @snapshots
```

Modify the `fstab` file in order to automatically mount the subvolumes.

```
    UUID=<disk-uid>   /           btrfs  defaults,subvol=@rootfs    0  0
    UUID=<disk-uid>   /home       btrfs  defaults,subvol=@home      0  0
    UUID=<disk-uid>   /.snapshots btrfs  defaults,subvol=@snapshots 0  0
```
  
Mount the `@home` subvolume to a temporary folder and move the content of your
`/home` directory into it. Reboot

## Snapshots

Take a read-only snapshot of the home filesystem.

```bash
    $ btrfs subvolume snapshot -r /home /.snapshots/home-snap
```

Snapshots will not take recursive snapshots of themselves. If you create a
snapshot of a subvolume, every subvolume or snapshot that the subvolume contains
is mapped to an empty directory of the same name inside the snapshot.

To view snapshot subvolume details:

```bash
    $ btrfs subvolume show /.shapshots/home-snap
```

## Recovery

To restore an old snapshot is sufficient to manually restore it.

There are different solutions, for example we can use mv, rsync or btrfs tool.

Mount the destination subvolume to a temporary folder:

```bash
    $ mount -t btrfs -o subvolid=<ID> /dev/<device> /mnt
```

Align to the snapshot:

```bash
    $ rsync -arv --progress --delete /.snapshots/<snap> /mnt/
```

It is important to exclude the snapshots folder from the synch procedure.


## Send and Receive

Is possible to transfer a snapshot to another btrfs volume (e.g. on an
external hard drive).

```bash
    $ btrfs send /.snapshots/snap1 | btrfs receive /mnt/data/dest
```

This is called initial bootstrapping, and it corresponds to a full backup.
This task will take some time, depending on the size of the snapshot directory.

Subsequent incremental sends will take a shorter time.

### Incremental

Take another snapshot.

```bash
    $ btrfs subvolume snapshot -r /home /.snapshots/snap2
```

Send only the differences

```bash
    $ btrfs send -p /.snapshots/snap1 /.snapshots/snap2 | \
      btrfs receive /mnt/data/dest
```

## Snapper

Snapper is a tool that helps manage snapshots of btrfs subvolumes.

It can create and compare snapshots, revert between snapshots, and support
automatic snapshots' timelines.

### Configuration

Before creating a configuration for a subvolume, the subvolume must already
exist.

To create a new configuration named `myconfig` for the btrfs subvolume at
`/path/to/subvol`, run:

```bash
    $ snapper -c myconfig create-config /path/to/subvol
```

The command creates:
- a configuration file at `/etc/snapper/configs/myconfig` using the default
  template and creates a subvolume at
- a subvolume at `/path/to/subvol/.snapshots` where future snapshots for this
  configuration will be stored.

For example

```bash
    $ snapper -c root create-config /
```

### Custom snapshot subvolume

During configuration `snapper` creates a subvolume to store all the snapshots
as a child of the `@rootfs` subvolume.

```
    subvolid=5 (btrfs root)
      +--- @rootfs
              +--- .snapshots
```
    
To simplify revert operations we prefer to use the `@snapshots` subvolume
created as a child of btrfs root (`subvolid=5`)

Remove the volume created by `snapper`:

    sudo btrfs subvolume delete /.snapshots

Mount our `@snapshots` subvolume in the `/.snapshots` folder

    sudo mount -o subvol=@snapshots /dev/<device> /.snapshots

### Restore snapshot

Restoring a snapshot involves copying things around from an old snapshot
to the current state.

To simplify the process we are going to use
[`snapper-rollback`](https://github.com/jrabinow/snapper-rollback), a simple
python script to rollback systems using
[Arch wiki suggested subvolume layout](https://wiki.archlinux.org/index.php/Snapper#Suggested_filesystem_layout).

A Debian package for script can be found [here](https://github.com/davxy/snapper-rollback).

Once installed the configuration in `/etc/snapper-rollback.conf` should be
adjusted to reflect your system and snapper configuration. Mine:

    [root]
    subvol_main = @rootfs
    subvol_snapshots = @snapshots
    mountpoint = /mnt/btrfs
    dev = /dev/nvme0n1p2

### Debian apt hook

Debian installation comes with the `/etc/apt/apt.conf.d/80snapper` hook for apt.

This hook invokes snapper before and after apt modifications to create
a `pre` and `post` subvolume snapshot.

The hook will use the configuration referenced by `/etc/default/snapper`.
