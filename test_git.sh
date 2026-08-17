#!/bin/bash
export PATH="/cmd:/bin:/mingw64/bin:/usr/bin:$PATH"
export HOME="$USERPROFILE"
export MSYSTEM=MINGW64

echo "Testing git..."
git --version
echo "Exit code: $?"
