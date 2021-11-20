#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="advanced-wifi"
rp_module_desc="Advanced wifi manager with OSK"
rp_module_help="This is a wifi manager terminal app with an on screen keyboard, for when no keyboard is in reach!"
rp_module_section="exp"
rp_module_flags="rpi nobin"
rp_module_repo="git https://github.com/OfficialPhilcomm/retropie-wifi-manager.git master"

function depends_advanced-wifi() {
  getDepends ruby ruby-dev
}

function sources_advanced-wifi() {
  gitPullOrClone "$md_inst"
}

function install_advanced-wifi() {
  cd "$md_inst"
  chown -R $user:$user "$md_inst"
  chmod -R 755 "$md_inst"

  sudo gem install curses require_all
}
