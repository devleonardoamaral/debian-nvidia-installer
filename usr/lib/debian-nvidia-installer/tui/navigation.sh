#!/usr/bin/env bash

tui::navigate::main() {
    while true; do       
        NAVIGATION_STATUS=1

        case $(tui::menu::main) in
            1) installer::install_nvidia ;;
            2) installer::uninstall_nvidia ;;
            3) tui::navigate::extras ;;
            4) 
                log::info "Interface encerrada pelo usuário."
                break 
            ;;
        esac
        
        # Pausa para visualização de resultados no final da navegação
        if ! (( NAVIGATION_STATUS )); then
            log::input _ "Pressione Enter para continuar..."
        fi
    done
}

tui::navigate::extras() {
    case $(tui::menu::extras) in
        1) installer::install_cuda ;;
        2) installer::install_optix ;;
        3) installer::enable_drm ;;
        # 4) Volta ao menu principal por padrão
    esac
    return
}

tui::navigate::flavors() {
    case $(tui::menu::flavors) in
        1) installer::install_nvidia_proprietary ;;
        2) installer::install_nvidia_open ;;
        3)
            log::info "Operação cancelada pelo usuário."
            tui::show_msgbox "Aviso" "Operação cancelada"
            NAVIGATION_STATUS=0
            return
            ;;
    esac

    NAVIGATION_STATUS=0
    return
}