#!/bin/bash

#==============================
#         Fonctions
#==============================


function WaitEnter(){
    echo ""
    echo -e "Veuillez taper sur la touche ENTREE pour continuer"
    read
}

function addUser(){
  read -p "Entrez le nom d'utilisateur que vous souhaitez créer : " username
  if [ -z $username ]; then
    echo "Le champ est vide"
    echo "code error:1"
    exit
  fi

  grep -E "^$username" /etc/passwd >/dev/null
  if [ $? -eq 0 ]; then
    echo "$username existe déjà !"
    echo "code error:2"
    exit
  fi

  read -p "Entrez le path pour votre répertoire personnel : " pathRepo
  if [ -z $pathRepo ]; then
    echo "Le champ est vide"
    echo "code error:3"
    exit
  fi
  createRepo=$pathRepo
  createRepo=${createRepo%/*}
  if [ -d "$pathRepo" ]; then
    echo "Ce repertoire existe deja"
    echo "code error:4"
    exit
  else
    if [ ! -d "$createRepo" ]; then
      mkdir "$createRepo"
    fi
  fi

  read -p "Entrez la date d'expiration format AAAAMMJJ : " expirationDate
  if [ -z $expirationDate ]; then
    echo "Le champ est vide"
    echo "code error:5"
    exit
  fi
  if [ $expirationDate -lt $(date +%Y%m%d) ]; then
    echo "La date est antérieur à aujourd'hui"
    echo "code error:6"
    exit
  fi

  read -p "Entrez le path du shell que vous souhaitez utiliser (exemple: /bin/bash): " shellSetup
  if [ -z $shellSetup ]; then
    echo "Le champ est vide"
    echo "code error:7"
    exit
  fi
  if [ ! -f "$shellSetup" ]; then
    echo "Ce shell n'est pas installé"
    echo "code error:8"
    exit
  fi

  read -p "Entrez l'identifiant que vous souhaitez : " uidNumber
  if [ -z $uidNumber ]; then
    echo "Le champ est vide"
    echo "code error:9"
    exit
  fi

  useradd -d $pathRepo -e $expirationDate -f 0 -s $shellSetup -u $uidNumber $username
  passwd $username
  [ $? -eq 0 ] && echo "$username a été ajouté !" || echo "problème lors de l'ajout code error:10"
  echo ""
  echo "Le nouvel utilisateur $username a été créé avec succès !"

}

function modifyUser(){
  read -p "Entrez le nom d'utilisateur que vous souhaitez modifier : " username
  if [ -z $username ]; then
    echo "Le champ est vide"
    echo "code error:11"
    exit
  fi
  grep -e "^$username" /etc/passwd >/dev/null
  if [ $? -eq 0 ]; then
    echo "l'utilisateur $username existe, nous allons le modifier !"
  else
    echo "l'utilisateur $username n'existe pas !"
    echo "code error:12"
    exit
  fi

  read -p "Modifier le nom de l'utilisateur ? [y/n] " answer
  if [ "$answer" == "y" ]; then
    read -p "Entrez le nouveau nom d'utilisateur : " newUsername
    if [ -z $newUsername ]; then
      echo "Le champ est vide"
      echo "code error:13"
      exit
    fi
    usermod -l $newUsername $username
    username=$newUsername
  fi

  read -p "Modifier le path du repertoire ? [y/n] " answer
  if [ "$answer" == "y" ]; then
    read -p "Entrez le nouveau path du repertoire : " newPathRepo
    if [ -z $newPathRepo ]; then
      echo "Le champ est vide"
      echo "code error:14"
      exit
    fi
    if [ -d "$newPathRepo" ]; then
      echo "Ce repertoire existe deja"
      echo "code error:15"
      exit
    fi
    usermod -d $newPathRepo -m $username
  fi

  read -p "Modifier la date d'expiration ? [y/n] " answer
  if [ "$answer" == "y" ]; then
    read -p "Entrez la nouvelle date d'expiration format AAAAMMJJ : " newExpirationDate
    if [ -z $newExpirationDate ]; then
      echo "Le champ est vide"
      echo "code error:16"
      exit
    fi
    if [ $newExpirationDate -ge $(date +%Y%m%d) ]; then
      usermod -e $newExpirationDate $username
    else
      echo "La date est antérieur à aujourd'hui"
      echo "code error:17"
      exit
    fi
  fi

  read -p "Changer de mot de passe ? [y/n] " answer
  if [ "$answer" == "y" ]; then
    passwd $username
  fi

  read -p "Modifier le shell ? [y/n] " answer
  if [ "$answer" == "y" ]; then
    read -p "Entrez le path du nouveau shell (exemple: /bin/bash): " newShellSetup
    if [ -z $newShellSetup ]; then
      echo "Le champ est vide"
      echo "code error:18"
      exit
    fi
    if [ ! -f "$newShellSetup" ]; then
      echo "Ce shell n'est pas installé"
      echo "code error:19"
      exit
    fi
    usermod -s $newShellSetup $username
  fi

  read -p "Modifier l'identifiant (UID) ? [y/n] " answer
  if [ "$answer" == "y" ]; then
    read -p "Entrez le nouvel identifiant (UID) : " newUidNumber
    if [ -z $newUidNumber ]; then
      echo "Le champ est vide"
      echo "code error:20"
      exit
    fi
    usermod -u $newUidNumber $username
  fi

}

function deleteUser(){
  read -p "Entrez le nom d'utilisateur que vous souhaitez supprimer : " username
  if [ -z $username ]; then
    echo "Le champ est vide"
    echo "code error:21"
    exit
  fi
  grep -e "^$username" /etc/passwd >/dev/null
  if [ $? -eq 0 ]; then
    echo "l'utilisateur $username existe, nous allons le supprimer !"
  else
    echo "l'utilisateur $username n'existe pas !"
    echo "code error:22"
    exit
  fi
  read -p "Voulez vous supprimer $username meme s'il est connecté ? [y/n] " answer1
  read -p "Voulez vous supprimer son répertoire ? [y/n] " answer2
  if [ "$answer2" == "y" -a "$answer1" == "y" ]; then
    userdel -f -r $username
  else
    if [ "$answer2" == "y" ]; then
      userdel -r $username
    fi
    if [ "$answer1" == "y" ]; then
      userdel -f $username
    else
      userdel $username
    fi
  fi
}

#==============================
#            Menu
#==============================

if [ $(id -u) -eq 0 ]; then

while [[ True ]]; do

echo `clear`;

echo "                 +-+-+-+-+-+"
echo "                 |H|a|m|z|a|"
echo "                 +-+-+-+-+-+"
echo ""
echo "-----------------------------------------------";
echo "|                   MENU                      |";
echo "-----------------------------------------------";
echo "       Ajout d'un utilisateur : Tapez 1 ";
echo "    Modification d'un utilisateur : Tapez 2 ";
echo "     Suppression d'un utilisateur : Tapez 3 ";
echo "           Quitter : Tapez q ou Q";
echo "";

read -p "    Que souhaitez vous ? " choix

case "$choix" in
        1)
          addUser;
          WaitEnter
            ;;
        2)
          modifyUser;
          WaitEnter
            ;;
        3)
          deleteUser;
          WaitEnter
            ;;
        "q"|"Q")
            echo "Fermeture...";
            break
            ;;
    *) echo "Erreur";WaitEnter;
  esac

done

else
    echo "Il faut etre root pour lancer ce script"
fi
