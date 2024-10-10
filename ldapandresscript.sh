#!/bin/bash

# donde se guardan los usuarios
usuariosss="usuarios.ldif"

# Creo un usuario
crear_usuario() {
    read -p "Nombre del usuario: " usuario
    read -s -p "Contraseña: " contra
    echo

    # añado el usuario al LDIF
    cat <<EOF >> $usuariosss
dn: uid=$usuario,ou=People,dc=guapardo,dc=ldap
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: top
cn: $usuario
sn: $usuario
uid: $usuario
userPassword: $contra
loginShell: /bin/bash
homeDirectory: /home/$usuario

EOF

    sudo ldapadd -x -D cn=admin,dc=guapardo,dc=ldap -W -f $usuariosss
}

# Menú principal
while true; do
    echo "Menú:"
    echo "1. Crear usuario"
    echo "2. Salir"
    read -p "Elige una opción: " opcion

    case $opcion in
        1)
            crear_usuario
            ;;
        2)
            echo "Saliendo..."
            exit 0
            ;;
        *)
            echo "Opción no válida."
            ;;
    esac
done
