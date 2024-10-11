#!/bin/bash

# los ldif
usuariosss="usuario.ldif"
gruposss="grupo.ldif"

# los uid
generar_uidNumber() {
    if [ ! -f $usuariosss ]; then
        echo 1000
    else
        ultimo_uid=$(sudo ldapsearch -x -LLL -b "ou=People,dc=guapardo,dc=ldap" "(objectClass=posixAccount)" uidNumber | grep uidNumber | sort -n | tail -1 | awk '{print $2}')
        echo $((ultimo_uid + 1))
    fi
}

# lo mismo que en usuarios
generar_gidNumber() {
    if [ ! -f $gruposss ]; then
        echo 1000
    else
        ultimo_gid=$(sudo ldapsearch -x -LLL -b "ou=Groups,dc=guapardo,dc=ldap" "(objectClass=posixGroup)" gidNumber | grep gidNumber | sort -n | tail -1 | awk '{print $2}')
        echo $((ultimo_gid + 1))
    fi
}

# Crea un usuario
crear_usuario() {
    read -p "Nombre del usuario: " usuario
    read -s -p "Contraseña: " contra
    echo
    uidNumber=$(generar_uidNumber)
    gidNumber=$(generar_gidNumber)

    # el archivo ldif
    cat <<EOF > $usuariosss
dn: uid=$usuario,ou=People,dc=guapardo,dc=ldap
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: top
cn: $usuario
sn: $usuario
uid: $usuario
uidNumber: $uidNumber
gidNumber: $gidNumber
userPassword: $(slappasswd -s $contra)
loginShell: /bin/bash
homeDirectory: /home/$usuario

EOF

    # agrega los usuarios creados

    sudo ldapadd -x -D cn=admin,dc=guapardo,dc=ldap -W -f $usuariosss
}

# crea el grupo

crear_grupo() {
    read -p "Nombre del grupo: " grupo
    gidNumber=$(generar_gidNumber)

    # lo mismo que el de usuarios, el archivo ldif de grupos

    cat <<EOF > $gruposss
dn: cn=$grupo,ou=Groups,dc=guapardo,dc=ldap
objectClass: posixGroup
objectClass: top
cn: $grupo
gidNumber: $gidNumber

EOF

    # y esto agrega el grupo

    sudo ldapadd -x -D cn=admin,dc=guapardo,dc=ldap -W -f $gruposss
}

# el menú sin el while true :')

menu() {
    echo "Menú:"
    echo "1. Crear usuario"
    echo "2. Crear grupo"
    echo "3. Salir"
    read -p "Elige una opción: " opcion

    case $opcion in
        1)
            crear_usuario
            ;;
        2)
            crear_grupo
            ;;
        3)
            echo "Saliendo..."
            exit 0
            ;;
        *)
            echo "Opción no válida."
            ;;
    esac
    menu
}

menu
