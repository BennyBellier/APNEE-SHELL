#!/urb/bin/bash
######################################################################################
# Corbeille_function.sh
#
# Module contenant les fonctions applicative de la corbeille
#
# Benjamin BELLIER
# Octobre 2021 (Bash)
######################################################################################

executable='\e[1;32m'
dossier='\e[0;34m'
liensymbolique='\e[1;36m'
fichier='\e[1;37m'
neutre='\e[0;m'
erreur='\e[0;31m'

# Genere l'arborescnece de la corbeille si
# celle-ci n'existe pas deja
# $HOME/.corbeille
#    ->/files
#    ->/info
Generation_corbeille() {
  $(mkdir -p $HOME/.corbeille -m=700)
  $(mkdir -p $HOME/.corbeille/files -m=700)
  $(mkdir -p $HOME/.corbeille/info -m=700)
}

# Deplace dans la corbeille les fichiers qui sont entrés en parametre
# par l'utilisateur est genere une fichier .cobeilleinfo
# contenant la date de suppression du fichier et le chemin
# pour le restaurer
#
# ex   : corbeille efface test1.txt
# file : test1.txt
# info : test1.txt.corbeilleinfo    -> Path=/home/utilisateur/Documents/travail/
#                                   -> DeletionDate=2021-10-14T09:25:10
function Efface_fichier() {
  if [ $1 == "-r" ]; then # si l'option '-r' est entree par l'utilisateur
    shift
    for i in $@; do # boucle sur tous les fichiers entree en parametre par l'utilisateur
      f=$(find | grep $i)
      if [ -z $f ]; then # si le fichier n'existe pas
        echo -e "${erreur}ERREUR${neutre}\nLe fichier \"$i\" n'existe pas !"
      else
        Directory=$(readlink -f $f)     # recuperation du chemin du fichier
        Date=$(date +%Y-%m-%dT%H:%M:%S) # recuperation de la date de suppression
        file=$(basename $f)             # recuperation seulement du nom du fichier pour les informations de suppression

        mv $f $HOME/.corbeille/files # déplacement du fichier vers la corbeille
        i=$(basename $f)
        echo -e "$TrashInfo\nPath=$Directory\nDeletionDate=$Date" >"$HOME/.corbeille/info/$i.corbeilleinfo" # génération du fichier contenant les informations (date de suppression et chemin pour restaurer le fichier)
      fi
    done
  else
    for i in $@; do                     # boucle sur tous les fichiers entree en parametre par l'utilisateur
      if [ -e $i ]; then                # si le fichier existe
        Directory=$(readlink -f $1)     # recuperation du chemin du fichier
        Date=$(date +%Y-%m-%dT%H:%M:%S) # recuperation de la date de suppression
        file=$(basename $1)             # recuperation seulement du nom du fichier pour les informations de suppression

        mv $i $HOME/.corbeille/files # déplacement du fichier vers la corbeille
        i=$(basename $i)
        echo -e "$TrashInfo\nPath=$Directory\nDeletionDate=$Date" >"$HOME/.corbeille/info/$i.corbeilleinfo" # génération du fichier contenant les informations (date de suppression et chemin pour restaurer le fichier)
      else
        echo -e "${erreur}ERREUR${neutre}\nLe fichier \"$i\" n'existe pas !"
      fi
    done
  fi
}

# Restaure le fichier contenue dans la corbeille entree en parametre par l'utilisateur
# si la sous-arborescence du fichier n'existe plus alors elle est recreer.
# Cette fonction utilise les donnees contenue dans le .corbeilleinfo du fichier correspondant
function Restaure_fichier() {
  for i in $@; do # boucle sur les fichiers entree en parametre par l'utilsateur
    if [ -e $i ]; then
      EndLength=${#i}                                                        # on recupère la longueur du nom du fichier à restaurer
      Path=$(cat $HOME/.corbeille/info/$i.corbeilleinfo | head -2 | tail +2) # on recupere le chemin du fichier a restaurer dans le fichier info de la corbeille lui correspondant
      Path=${Path:5}                                                         # on supprime le début de la ligne "Path=" qui ne nous interresse pas
      Directories=${Path:0:-EndLength}                                       # on recupère le chemin sans le nom du fichier pour regenerer les dossiers parents si ils ont étaient supprimé

      mkdir -p "$Directories"                     # on génere les dossier parents si il n'existe pas
      mv "$HOME/.corbeille/files/$i" "$Path"      # on replace le fichier à son emplacement d'origine
      rm "$HOME/.corbeille/info/$i.corbeilleinfo" # on supprime le fichier info de la corbeille
    else                                          # le fichier n'est pas dans la corbeille
      echo -e "${erreur}ERREUR${neutre}\nLe fichier \"$i\" n'est pas dans la corbeille !"
    fi
  done
}

# Sous-fonction permettant d'afficher le type avec la couleur correspondant a ce type
# pour le fichier en parametre
colorisation_type() {
  if [ -d "$HOME/.corbeille/files/${i}" ]; then # on regarde le type de fichier pour afficher le type de celui-ci
    echo -e "Type : ${dossier}Dossier${neutre}"
  elif [ -L "$HOME/.corbeille/files/${i}" ]; then
    echo -e "Type : ${liensymbolique}Lien symbolique${neutre}"
  elif [ -x "$HOME/.corbeille/files/${i}" ]; then
    echo -e "Type : ${executable}Executable${neutre}"
  elif [ -f "$HOME/.corbeille/files/${i}" ]; then
    echo -e "Type : ${fichier}Fichier${neutre}"
  fi
}

# Affiche les informations sur tout les fichiers contenue dans la corbeille,
# les informations affiches sont :
# nom, emplacement avant suppression et date de suppression
function Info_fichier_empty() {
  for i in $(
    find $HOME/.corbeille/info
  ); do
    if [ $i != "$HOME/.corbeille/info" ]; then # on exclus le dossier courant que nous retourne la commande find
      i=$(basename $i)
      i=${i:0:-14}                                                           # on exclus le .corbeilleinfo
      Path=$(cat $HOME/.corbeille/info/$i.corbeilleinfo | head -2 | tail +2) # on recupere le chemin du fichier dans le fichier info de la corbeille lui correspondant
      Path=${Path:5}                                                         # on supprime le début de la ligne "Path=" qui ne nous interresse pas
      Date=$(cat $HOME/.corbeille/info/$i.corbeilleinfo | tail +3)           # on recupère la date de suppression du fichier
      Date=${Date:13}                                                        # on supprime le début de la ligne "DeletionDate=" qui ne nous interresse pas
      Jour=${Date:0:10}                                                      # yyy-mm-dd
      Heure=${Date:11}                                                       # hh:mm:ss

      echo "[ $i ]"
      colorisation_type "$i"

      echo -e "Chemin du fichier : \"$Path\"\nDate de supression : $Jour $Heure\n" # affichage des informations pour chaque fichier dans la corbeille
    fi
  done
}

# Affiche les informations sur les fichiers contenue dans la corbeille
# dont l'utilisateur a entree leur noms en parametre
# les informations affiches sont :
# nom, emplacement avant suppression et date de suppression
function Info_fichier_list() {
  for i in $@; do                                                            # boucle sur tout les fichier entree en parametre par l'utilisateur
    i=$(basename $i)                                                         # on recupere seulement le nom du fichier pas son extension
    if [ -e "$HOME/.corbeille/info/$i.corbeilleinfo" ]; then                 # si le fichier existe
      Path=$(cat $HOME/.corbeille/info/$i.corbeilleinfo | head -2 | tail +2) # on recupere le chemin du fichier a restaurer dans le fichier info de la corbeille lui correspondant
      Path=${Path:5}                                                         # on supprime le début de la ligne "Path=" qui ne nous interresse pas
      Date=$(cat $HOME/.corbeille/info/$i.corbeilleinfo | tail +3)           # on recupère la date de suppression du fichier
      Date=${Date:13}                                                        # on supprime le début de la ligne "DeletionDate=" qui ne nous interresse pas
      Jour=${Date:0:10}                                                      # yyy-mm-dd
      Heure=${Date:11}                                                       # hh:mm:ss

      echo "[ $i ]"
      colorisation_type "$i"

      echo -e "Chemin du fichier : \"$Path\"\nDate de supression : $Jour $Heure\n" # affichage des informations pour chaque fichier dans la corbeille
    else                                                                           # le fichier n'est pas dans la corbeille
      echo -e "${erreur}ERREUR${neutre}\nLe fichier \"$i\" n'est pas dans la corbeille !"
    fi
  done
}

# Vide la corbeille, tout les fichiers contenue dans la corbeille
# ainsi que leur informations pour les restaurer sont supprime
function Vide_fichier() {
  for i in $(# boucle sur tout les fichiers contenue dans la corbeille
    find $HOME/.corbeille/files
  ); do
    if [ $i != "$HOME/.corbeille/files" ]; then       # on en supprime pas le dossier parent
      i=$(basename $i)                                # recuperation du nom du fichier sans le chemin vers la corbeille
      $(rm -r $HOME/.corbeille/files/$i)              # suppression définitive du fichier
      $(rm -r $HOME/.corbeille/info/$i.corbeilleinfo) # suppression des informations sur le fichier correspondant
    fi
  done
}

# Vide la corbeille, tout les fichiers entree en parametre par l'utilisateur
# et qui sont contenue dans la corbeille ainsi que leur informations
# pour les restaurer sont supprime
function Vide_fichier_list() {
  for i in $@; do                                     # boucle sur les fichiers entree en parametre par l'utilisateur
    i=$(basename $i)                                  # on en veut que le nom du fichier pas le chemin
    if [ -e $i ]; then                                # si le fichier existe alors
      $(rm -r $HOME/.corbeille/files/$i)              # suppression définitive du fichier
      $(rm -r $HOME/.corbeille/info/$i.corbeilleinfo) # suppression des informations sur le fichier correspondant
    fi
  done
}

# Affiche un avertissement pour la suppression complete de la poubelle
function Avertissement_vide_empty() {
  echo -e "${erreur}Attention${neutre}\nVous êtes sur le point de vider entierment la corbeille,\ntout son contenue sera définitivement supprimer !"
  read -p "Souhaitez-vous continuer ? [O/n] " vide
  vide=${vide:-'Y'}

  if [[ $vide == "N" || $vide == "n" ]]; then
    echo -e "\n${fichier}Annulation${neutre}\nLa corbeille n'a pas était vidé"
    exit
  fi
}

# Sous fonction permettant de lister les fichiers present avec une couleur de police
# en fonction de leur type : dossier, fichier, executable et lien symbolique
function colorisation_par_type() {
  if [ -d "$HOME/.corbeille/files/${1}" ]; then # on regarde le type de fichier pour afficher le type de celui-ci
    echo -ne "${dossier}${1}${neutre}  "
  elif [ -L "$HOME/.corbeille/files/${1}" ]; then
    echo -ne "${liensymbolique}${1}${neutre}  "
  elif [ -x "$HOME/.corbeille/files/${1}" ]; then
    echo -ne "${executable}${1}${neutre}  "
  elif [ -f "$HOME/.corbeille/files/${1}" ]; then
    echo -ne "${fichier}${1}${neutre}  "
  fi
}

# Affiche un avertissement pour la suppression de plusieurs element de la poubelle
function Avertissement_vide_list() {
  echo -e "${erreur}Attention${neutre}\nVous êtes sur le point de vider les fichiers :"
  for i in $@; do
    i=$(basename $i)
    if [ -e "$HOME/.corbeille/info/$i.corbeilleinfo" ]; then
      colorisation_par_type "$i"
    fi
  done
  echo -e "\nIls seront définitivement supprimés !"
  read -p "Souhaitez-vous continuer ? [O/n] " vide
  vide=${vide:-'Y'}

  if [[ $vide == "N" || $vide == "n" ]]; then
    echo -e "\n${fichier}Annulation${neutre}\nLa corbeille n'a pas était vidé !"
    exit
  fi
}

# Condition si le script corbeille_function.sh est appelé
# comme main, on retourne une erreur
if [ "${BASH_SOURCE[0]}" == "$0" ]; then
  echo -e "\t Usage: corbeille [efface, restaure, info, vide] [-r] ..."
fi
