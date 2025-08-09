#!/usr/bin/env bash

tui::navigate::main() {
    while true; do       
        NAVIGATION_STATUS=1

        case $(tui::menu::main) in
            1) installer::install_nvidia ;;
            2) installer::uninstall_nvidia ;;
            3) tui::navigate::extras ;;
            4) break ;; # Encerra a navegação
        esac
    done
}

tui::navigate::extras() {
    case $(tui::menu::extras) in
        1) extra::install_cuda ;;
        2) extra::install_optix ;;
        3) extra::switch_nvidia_drm ;;
        4) extra::switch_nvidia_pvma ;;
        # 5) Volta ao menu principal por padrão
    esac
    return
}

tui::navigate::flavors() {
    case $(tui::menu::flavors) in
        1) installer::install_nvidia_proprietary ;;
        2) installer::install_nvidia_open ;;
        # 3) Volta ao menu principal por padrão
    esac
    return
}