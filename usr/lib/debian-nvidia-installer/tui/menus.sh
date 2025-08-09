#!/usr/bin/env bash

tui::menu::main() {
    local choice
    choice=$(tui::show_menu "$(tr::t "tui.title.main")" "$(tr::t "tui.menutitle.selectoption")" \
            1 "$(tr::t "tui.install.drivers")" \
            2 "$(tr::t "tui.uninstall.drivers")"\
            3 "$(tr::t "tui.extras")" \
            4 "$(tr::t "tui.exit")")
    echo "${choice:-4}"
}

tui::menu::extras() {
    local choice
    choice=$(tui::show_menu "$(tr::t "tui.title.extras")" "$(tr::t "tui.menutitle.selectoption")" \
            1 "$(tr::t "tui.install.cuda")" \
            2 "$(tr::t "tui.install.optix")" \
            3 "$(tr::t "tui.switch.nvidiadrm")" \
            4 "$(tr::t "tui.switch.pvma")" \
            5 "$(tr::t "tui.exit")")
    echo "${choice:-5}"
}

tui::menu::flavors() {
    local choice
    choice=$(tui::show_menu "" "$(tr::t "tui.menutitle.selectflavor")" \
    1 "$(tr::t "tui.install.proprietary")" \
    2 "$(tr::t "tui.install.open")" \
    3 "$(tr::t "tui.exit")")

    echo "${choice:-3}"
}