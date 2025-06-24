#!/bin/bash -e

# This script builds a portable TeX Live distribution.
# It uses the "Symlink hijack" method to work around installer bugs.

# --- 0. Check input ---
if [ -z "$1" ]; then
  echo "Error: No TeX Live year provided."
  echo "Usage: .github/scripts/build-texlive.sh <YEAR>"
  exit 1
fi

# --- 1. Set up variables ---
TEXLIVE_YEAR="$1"
BIN_DIR="$INSTALL_DIR/$TEXLIVE_YEAR/bin/x86_64-linux"
echo "--- Building TeX Live $TEXLIVE_YEAR ---"
echo "Installation Directory: $INSTALL_DIR"

# --- 2. Symlink hijack ---
# The installer insists on writing to /usr/local/texlive.
# We redirect this path to our desired installation directory.
echo "Creating symlink hijack for /usr/local/texlive..."
mkdir -p "$INSTALL_DIR"
sudo rm -rf /usr/local/texlive
sudo ln -s "$INSTALL_DIR" /usr/local/texlive

# --- 3. Download and install ---
echo "Downloading TeX Live installer..."
wget http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
tar -xzf install-tl-unx.tar.gz
cd install-tl-*/
echo "Starting TeX Live installation..."
./install-tl --profile=../texlive.profile -no-gui

# --- 4. Set and export PATH for subsequent steps ---
echo "Adding $BIN_DIR to GITHUB_PATH"
echo "$BIN_DIR" >> $GITHUB_PATH
export PATH="$BIN_DIR:$PATH"

# --- 5. Verify the installation ---
echo "Verifying installation..."
which tlmgr
tlmgr --version
echo "--- TeX Live base installation complete ---"
