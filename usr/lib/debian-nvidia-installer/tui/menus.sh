#!/usr/bin/env bash

tui::menu::main() {
    local choice
    choice=$(tui::show_menu "$(tr::t "tui.title.main")" "$(tr::t "tui.menutitle.selectoption")" \
            1 "$(tr::t "tui.menuoption.installdrivers")" \
            2 "$(tr::t "tui.menuoption.uninstalldrivers")"\
            3 "$(tr::t "tui.menuoption.extras")" \
            4 "$(tr::t "tui.button.exit")")
    echo "${choice:-4}"
}

tui::menu::extras() {
    local choice
    choice=$(tui::show_menu "$(tr::t "tui.title.extras")" "$(tr::t "tui.menutitle.selectoption")" \
            1 "$(tr::t "tui.menuoption.installcuda")" \
            2 "$(tr::t "tui.menuoption.installoptix")" \
            3 "$(tr::t "tui.menuoption.switchnvidiadrm")" \
            4 "$(tr::t "tui.menuoption.switchpvma")" \
            5 "$(tr::t "tui.button.exit")")
    echo "${choice:-5}"
}

tui::menu::flavors() {
    local choice
    choice=$(tui::show_menu "" "$(tr::t "tui.menutitle.selectflavor")" \
    1 "$(tr::t "tui.menuoption.installproprietary")" \
    2 "$(tr::t "tui.menuoption.installopen")" \
    3 "$(tr::t "tui.button.exit")")

    echo "${choice:-3}"
}