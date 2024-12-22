#!/bin/bash

# instalador seguro de servidor openvpn para debian, ubuntu, centos, amazon linux 2, fedora y arch linux

function isroot() {
    if [ "$euid" -ne 0 ]; then
        return 1
    fi
}

function tunavailable() {
    if [ ! -e /dev/net/tun ]; then
        return 1
    fi
}

function checkos() {
    if [[ -e /etc/debian_version ]]; then
        os="debian"
        # shellcheck disable=sc1091
        source /etc/os-release

        if [[ $id == "debian" || $id == "raspbian" ]]; then
            if [[ $version_id -lt 8 ]]; then
                echo "⚠️ Tu versión de Debian no es compatible."
                echo "Sin embargo, si estás usando Debian >= 8 o la versión inestable/prueba, puedes continuar bajo tu propio riesgo."
                echo ""
                until [[ $continue =~ (y|n) ]]; do
                    read -rp "¿continuar? [y/n]: " -e continue
                done
                if [[ $continue == "n" ]]; then
                    exit 1
                fi
            fi
        elif [[ $id == "ubuntu" ]]; then
            os="ubuntu"
            major_ubuntu_version=$(echo "$version_id" | cut -d '.' -f1)
            if [[ $major_ubuntu_version -lt 16 ]]; then
                echo "⚠️ Tu versión de Ubuntu no es compatible."
                echo "Sin embargo, si estás usando Ubuntu >= 16.04 o beta, puedes continuar bajo tu propio riesgo."
                echo ""
                until [[ $continue =~ (y|n) ]]; do
                    read -rp "¿continuar? [y/n]: " -e continue
                done
                if [[ $continue == "n" ]]; then
                    exit 1
                fi
            fi
        fi
    elif [[ -e /etc/system-release ]]; then
        # shellcheck disable=sc1091
        source /etc/os-release
        if [[ $id == "fedora" ]]; then
            os="fedora"
        fi
        if [[ $id == "centos" ]]; then
            os="centos"
            if [[ ! $version_id =~ (7|8) ]]; then
                echo "⚠️ Tu versión de CentOS no es compatible."
                echo "El script solo admite CentOS 7 y CentOS 8."
                exit 1
            fi
        fi
        if [[ $id == "amzn" ]]; then
            os="amzn"
            if [[ $version_id != "2" ]]; then
                echo "⚠️ Tu versión de Amazon Linux no es compatible."
                echo "El script solo admite Amazon Linux 2."
                exit 1
            fi
        fi
    elif [[ -e /etc/arch-release ]]; then
        os=arch
    else
        echo "Parece que no estás ejecutando este instalador en un sistema de Debian, Ubuntu, Fedora, CentOS, Amazon Linux 2 o Arch Linux."
        exit 1
    fi
}

# (Otras funciones de verificación y de instalación siguen aquí)

# Mensaje de bienvenida en español
echo "¡Bienvenido a Nuntius-VPN!"
echo "¡Listo para configurar tu servidor OpenVPN!"
