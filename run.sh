#!/usr/bin/env bash

set -eo pipefail

SCRIPTDIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd "$SCRIPTDIR"

rm -rf ./result nixos.qcow2

for arg do
    shift
    [ "$arg" = "--graphical" ] && GRAPHICAL=t && continue
done

nix-build '<nixpkgs/nixos>' -A vm -I nixpkgs=channel:nixos-23.11 -I nixos-config=./configuration.nix

if [[ -n "$GRAPHICAL" ]]; then
    ./result/bin/run-nixos-vm
else
    QEMU_KERNEL_PARAMS=console=ttyS0 ./result/bin/run-nixos-vm -nographic; reset
fi
