#!/bin/bash

# Couleurs
ROUGE='\033[0;31m'
VERT='\033[0;32m'
JAUNE='\033[1;33m'
BLEU='\033[0;34m'
NC='\033[0m'

# Vérification root
if [ "$EUID" -ne 0 ]; then
    echo -e "${ROUGE}Veuillez exécuter ce script en tant que root.${NC}"
    exit 1
fi

afficher_menu() {
    clear
    echo -e "${BLEU}╔══════════════════════════════════════╗${NC}"
    echo -e "${BLEU}║     GESTIONNAIRE D'UTILISATEURS     ║${NC}"
    echo -e "${BLEU}╠══════════════════════════════════════╣${NC}"
    echo -e "${BLEU}║${NC}  1. Lister les utilisateurs          ${BLEU}║${NC}"
    echo -e "${BLEU}║${NC}  2. Ajouter un utilisateur           ${BLEU}║${NC}"
    echo -e "${BLEU}║${NC}  3. Supprimer un utilisateur         ${BLEU}║${NC}"
    echo -e "${BLEU}║${NC}  4. Modifier un utilisateur          ${BLEU}║${NC}"
    echo -e "${BLEU}║${NC}  5. Quitter                          ${BLEU}║${NC}"
    echo -e "${BLEU}╚══════════════════════════════════════╝${NC}"
    echo ""
    read -p "$(echo -e ${JAUNE}"Votre choix : "${NC})" choix
}

lister_utilisateurs() {
    echo -e "${VERT}Liste des utilisateurs locaux :${NC}"
    echo ""
    printf "%-20s %-8s %-25s %-20s\n" "Nom" "UID" "Groupe(s)" "Home"
    printf "%-20s %-8s %-25s %-20s\n" "--------------------" "--------" "-------------------------" "--------------------"

    while IFS=: read -r username passwd uid gid info home shell; do
        if [ "$uid" -ge 1000 ] && [ "$uid" -lt 65534 ]; then
            groups=$(groups "$username" 2>/dev/null | cut -d: -f2- | xargs)
            printf "%-20s %-8d %-25s %-20s\n" "$username" "$uid" "$groups" "$home"
        fi
    done < /etc/passwd

    echo ""
    read -p "Appuyez sur Entrée pour continuer..."
}

ajouter_utilisateur() {
    echo -e "${VERT}Ajout d'un nouvel utilisateur${NC}"
    read -p "Nom d'utilisateur : " username
    read -p "Nom complet : " fullname
    read -p "Groupe principal (laisser vide = $username) : " group
    read -p "Shell (/bin/bash) : " shell
    read -p "Home (/home/$username) : " home

    if id "$username" &>/dev/null; then
        echo -e "${ROUGE}L'utilisateur $username existe déjà.${NC}"
        read -p "Appuyez sur Entrée..."
        return
    fi

    shell=${shell:-/bin/bash}
    home=${home:-/home/$username}
    group=${group:-$username}

    useradd -m -d "$home" -s "$shell" -c "$fullname" "$username"
    if [ "$group" != "$username" ]; then
        groupadd -f "$group"
        usermod -g "$group" "$username"
    fi

    echo -e "${VERT}Utilisateur $username créé. Définissez son mot de passe :${NC}"
    passwd "$username"
    read -p "Appuyez sur Entrée..."
}

supprimer_utilisateur() {
    echo -e "${ROUGE}Suppression d'un utilisateur${NC}"
    read -p "Nom d'utilisateur à supprimer : " username

    if ! id "$username" &>/dev/null; then
        echo -e "${ROUGE}L'utilisateur $username n'existe pas.${NC}"
        read -p "Appuyez sur Entrée..."
        return
    fi

    echo -e "${JAUNE}ATTENTION : Cette action est irréversible !${NC}"
    read -p "Supprimer aussi le home et la boîte mail ? (o/N) : " delhome

    if [ "$delhome" = "o" ] || [ "$delhome" = "O" ]; then
        userdel -r "$username"
        echo -e "${VERT}Utilisateur $username et ses fichiers supprimés.${NC}"
    else
        userdel "$username"
        echo -e "${VERT}Utilisateur $username supprimé (home conservé).${NC}"
    fi
    read -p "Appuyez sur Entrée..."
}

modifier_utilisateur() {
    echo -e "${VERT}Modification d'un utilisateur${NC}"
    read -p "Nom d'utilisateur à modifier : " username

    if ! id "$username" &>/dev/null; then
        echo -e "${ROUGE}L'utilisateur $username n'existe pas.${NC}"
        read -p "Appuyez sur Entrée..."
        return
    fi

    while true; do
        clear
        echo -e "${BLEU}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLEU}║     MODIFICATION DE $username        ${BLEU}║${NC}"
        echo -e "${BLEU}╠══════════════════════════════════════╣${NC}"
        echo -e "${BLEU}║${NC}  1. Changer le nom d'utilisateur    ${BLEU}║${NC}"
        echo -e "${BLEU}║${NC}  2. Changer le nom complet (GECOS)  ${BLEU}║${NC}"
        echo -e "${BLEU}║${NC}  3. Changer le groupe principal      ${BLEU}║${NC}"
        echo -e "${BLEU}║${NC}  4. Ajouter à un groupe secondaire   ${BLEU}║${NC}"
        echo -e "${BLEU}║${NC}  5. Changer le shell                 ${BLEU}║${NC}"
        echo -e "${BLEU}║${NC}  6. Changer le répertoire home       ${BLEU}║${NC}"
        echo -e "${BLEU}║${NC}  7. Verrouiller/Déverrouiller        ${BLEU}║${NC}"
        echo -e "${BLEU}║${NC}  8. Changer le mot de passe          ${BLEU}║${NC}"
        echo -e "${BLEU}║${NC}  0. Retour au menu principal         ${BLEU}║${NC}"
        echo -e "${BLEU}╚══════════════════════════════════════╝${NC}"
        echo ""
        read -p "$(echo -e ${JAUNE}"Votre choix : "${NC})" sub_choix

        case $sub_choix in
            1)
                read -p "Nouveau nom d'utilisateur : " newname
                usermod -l "$newname" "$username"
                if [ $? -eq 0 ]; then
                    echo -e "${VERT}Nom changé : $username → $newname${NC}"
                    username=$newname
                fi
                ;;
            2)
                read -p "Nouveau nom complet : " fullname
                usermod -c "$fullname" "$username"
                echo -e "${VERT}Nom complet mis à jour.${NC}"
                ;;
            3)
                read -p "Nouveau groupe principal : " group
                usermod -g "$group" "$username"
                echo -e "${VERT}Groupe principal changé.${NC}"
                ;;
            4)
                read -p "Groupe secondaire à ajouter : " group
                usermod -aG "$group" "$username"
                echo -e "${VERT}Utilisateur ajouté au groupe $group.${NC}"
                ;;
            5)
                read -p "Nouveau shell (ex: /bin/bash) : " shell
                chsh -s "$shell" "$username"
                echo -e "${VERT}Shell changé.${NC}"
                ;;
            6)
                read -p "Nouveau home (ex: /home/nouveau) : " home
                read -p "Déplacer le contenu actuel ? (o/N) : " mvhome
                if [ "$mvhome" = "o" ] || [ "$mvhome" = "O" ]; then
                    usermod -m -d "$home" "$username"
                else
                    usermod -d "$home" "$username"
                fi
                echo -e "${VERT}Répertoire home changé.${NC}"
                ;;
            7)
                status=$(passwd -S "$username" 2>/dev/null | cut -d' ' -f2)
                if [ "$status" = "L" ]; then
                    passwd -u "$username"
                    echo -e "${VERT}Compte déverrouillé.${NC}"
                else
                    passwd -l "$username"
                    echo -e "${JAUNE}Compte verrouillé.${NC}"
                fi
                ;;
            8)
                passwd "$username"
                ;;
            0)
                break
                ;;
            *)
                echo -e "${ROUGE}Choix invalide.${NC}"
                ;;
        esac
        read -p "Appuyez sur Entrée..."
    done
}

while true; do
    afficher_menu
    case $choix in
        1) lister_utilisateurs ;;
        2) ajouter_utilisateur ;;
        3) supprimer_utilisateur ;;
        4) modifier_utilisateur ;;
        5)
            echo -e "${VERT}Au revoir !${NC}"
            exit 0
            ;;
        *)
            echo -e "${ROUGE}Choix invalide.${NC}"
            read -p "Appuyez sur Entrée..."
            ;;
    esac
done
