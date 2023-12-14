+++
title = "Experiments with Btrfs RAID1"
date = "2022-02-02"
tags = ["system","btrfs"]
+++

RAID1 is a data replication technique that stores two copies of data on two
different disks, providing fault tolerance and high availability in case one of
the disks fails.

With btrfs, you can create a RAID1 array by combining two or more devices. The
devices can be physical disks or partitions.

## Loopback devices preparation

To make experimentation more agile, I'll use loopback devices instead of
physical devices.

These steps are not required if working on real devices.

Create a 1 GiB file to act as our physical drive.

    $ dd bs=1G count=1 if=/dev/zero of=hd0

Create the loopback device

    $ losetup /dev/loop0 hd0

To remove the loopback device at the end of experiments

    $ losetup -d /dev/loop0

Repeat the procedure for another disk (`hd1`) and

Check the devices

    $ losetup -a


Creating RAID1 storage
----------------------

Create the btrfs filesystems

    $ mkfs.btrfs -L myraid /dev/loop0
    $ mkfs.btrfs -L myraid /dev/loop1

### Method #1 : incremental

Mount the first drive

    $ mount /dev/loop0 /mnt/raid

    $ btrfs filesystem show /mnt/raid
    Label: myraid  uuid: 7a1b8dc3-4b19-48f7-ba04-a99179ed9d08
            Total devices 1 FS bytes used 2.02MiB
            devid    1 size 1.00GiB used 126.38MiB path /dev/loop0

Copy some files to the mounted hard drive (used to verify synchronization)

Add the second drive, resulting in combined storage capacity spanned across both
drives (i.e. RAID0).

    $ btrfs device add /dev/loop1 /mnt/raid

    $ btrfs filesystem show /mnt/raid
    Label: myraid  uuid: 7a1b8dc3-4b19-48f7-ba04-a99179ed9d08
            Total devices 2 FS bytes used 2.02MiB
            devid    1 size 1.00GiB used 126.38MiB path /dev/loop0
            devid    2 size 1.00GiB used 0.00B path /dev/loop1

    $ btrfs filesystem df /mnt/raid
    Data, single: total=8.00MiB, used=1.41MiB
    System, DUP: total=8.00MiB, used=16.00KiB
    Metadata, DUP: total=51.19MiB, used=608.00KiB
    GlobalReserve, single: total=3.25MiB, used=0.00B

Convert to RAID1 both for data and metadata.

    $ btrfs balance start -m convert=raid1 -d convert=raid1 /mnt/raid

    $ btrfs filesystem show /mnt/raid
    Label: myraid  uuid: 7a1b8dc3-4b19-48f7-ba04-a99179ed9d08
            Total devices 2 FS bytes used 2.02MiB
            devid    1 size 1.00GiB used 480.00MiB path /dev/loop0
            devid    2 size 1.00GiB used 480.00MiB path /dev/loop1

    $ btrfs filesystem df /mnt/raid
    Data, RAID1: total=208.00MiB, used=1.41MiB
    System, RAID1: total=64.00MiB, used=16.00KiB
    Metadata, RAID1: total=208.00MiB, used=608.00KiB
    GlobalReserve, single: total=3.25MiB, used=0.00B

### Method #2 : direct

    $ mkfs.btrfs -L myraid -m raid1 -d raid1 /dev/loop0 /dev/loop1


## Degraded mode

In case that one of the disks failed, then mount the remaining device in
degraded mode.

Simulate a faulty disk by detaching one of the two loopback devices:

    $ umount /mnt/raid
    $ losetup -d /dev/loop1

    $ mount /dev/loop0 /mnt/raid
    mount: /mnt/raid: wrong fs type, bad option, bad superblock on /dev/loop0, \
    missing codepage or helper program, or other error.

    $ btrfs filesystem show /dev/loop0
    warning, device 1 is missing
    Label: none  uuid: 7a1b8dc3-4b19-48f7-ba04-a99179ed9d08
            Total devices 2 FS bytes used 2.02MiB
            devid    2 size 1.00GiB used 592.00MiB path /dev/loop0
            *** Some devices missing

Mount in degraded mode the available device

    $ btrfs -o degraded /dev/loop0 /mnt/raid


## Replace faulty disk

Create another bare new device surrogate (this is obviously not required if
we are working with real storage devices).

    $ dd if=/dev/zero of=hd2 bs=1G count=1
    $ losetup /dev/loop2 hd2

Add the new device to the RAID1 array.

    $ btrfs device add /dev/loop2 /mnt/raid
    Performing full device TRIM /dev/loop2 (1.00GiB) ...
    WARNING: Multiple block group profiles detected, see 'man btrfs(5)'.
    WARNING:   Metadata: single, raid1
    WARNING:   System: single, raid1

Remove missing device

    $ btrfs device delete missing /mnt/raid

Finally, balance data to spread exactly the same data to the new device.

    $ btrfs filesystem balance /mnt/raid

Check mirroring is completed

    $ btrfs filesystem show
    Label: myraid  uuid: 7a1b8dc3-4b19-48f7-ba04-a99179ed9d08
            Total devices 2 FS bytes used 2.02MiB
            devid    2 size 1.00GiB used 688.00MiB path /dev/loop1
            devid    3 size 1.00GiB used 688.00MiB path /dev/loop2
