#!/bin/bash

BINSRC="./target/debug/tmptmpfs"
BINDST="/usr/local/bin/tmptmpfs"

if [[ $USER != "root" ]]; then
    echo "Run with sudo"
    exit 1
fi

if [[ ! -e "$BINSRC" ]]; then
    echo "Run 'cargo build' first"
    exit 1
fi

cp "$BINSRC" "$BINDST"
chmod 04755 "$BINDST"

