#!/bin/bash
set -e

echo "Git clone config"
echo " - max size: $SIZE"
echo " - repo: $REPO"

echo "Creating temp dir..."
TMP1=$(tmptmpfs start -s $SIZE)
echo "  TMP1=$TMP1"

echo "Cloning git repo..."
cd "$TMP1"
git clone --depth 1 --progress "$REPO"
NAME=$(find . -maxdepth 1 -type d | tail -n 1 | sed "s/^\.\///")
echo "  NAME=$NAME"

echo "Creating tarball..."
TMP2=$(tmptmpfs start -s $SIZE)
TARB="$NAME.tar.gz"
echo "  TMP2=$TMP2"
echo "  TARB=$TARB"
cd "$TMP1" && tar czvf "$TMP2/$TARB" "$NAME"

echo ""
echo "Git checkout succeeded."

echo ""
echo "$COOKIE"
echo "dir: $TMP1/$NAME"
echo "tar: $TMP2/$TARB"
