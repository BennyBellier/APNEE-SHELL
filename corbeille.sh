#!/usr/bin/bash
######################################################################################
# corbeille.sh
#
# Module permettant le fonctionnement de la corbeille en fonction de l'entree
# de l'utilisateur
#
# Benjamin BELLIER
# Octobre 2021 (Bash)
######################################################################################

source corbeille_function.sh
jaune='\e[1;33m'
neutre='\e[0;m'

function main() {
  if [ $# -ne 0 ]; then # si l'utilisateur a entree des parametres, on execute le programme
    TrashInfo='[Trash Info]'

    Generation_corbeille

    Execution_entree "$@"
  else # sinon ona affiche une erreur
    echo -e '\t corbeille.sh v1.0\n\t A program to emulate trash for Linux'
  fi
}

function Execution_entree() {
  if [ $1 == "efface" ]; then # detection du parametre "efface"
    shift
    if [ -z $1 ]; then # on ne peut effacer aucun fichier ou dossier
      echo -e "${jaune}Usage: corbeille efface [-r] <fichier1> <fichier2> ...${neutre}"
    else
      Efface_fichier "$@"
    fi

  elif
    [ $1 == "restaure" ]
  then # detection du parametre "restaure"
    shift
    if [ -z $1 ]; then # on ne peut effacer aucun fichier ou dossier
      echo -e "${jaune}Usage: corbeille restaure [-r] <fichier1> <fichier2> ...${neutre}"
    else
      Restaure_fichier "$@"
    fi

  elif
    [ $1 == "info" ]
  then # detection du parametre "info"
    shift
    if [ -z $1 ]; then # si aucun fichier n'est préciser alors on affiche les infos de tous les fichiers
      Info_fichier_empty
    else # sinon on affiche les info des fichiers specifier par l'utilisateur
      Info_fichier_list "$@"
    fi

  elif
    [ $1 == "vide" ]
  then # detection du parametre "vide"
    shift
    if [ -z $1 ]; then # si aucun fichier n'est preciser alors on vide toute la corbeille
      Avertissement_vide_empty
      Vide_fichier_empty
    else # sinon on supprime seulement les fichiers specifier par l'utilisateur
      Avertissement_vide_list "$@"
      Vide_fichier_list "$@"
    fi
  fi
}

# Si le fichier est appelé en tant qu'executable
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
  main "$@"
fi
