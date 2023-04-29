#!/bin/bash

VERT="\\033[1;32m"
NORMAL="\\033[0;39m"
ROUGE="\\033[1;31m"
ROSE="\\033[1;35m"
BLEU="\\033[1;34m"
BLANC="\\033[0;02m"
BLANCLAIR="\\033[1;08m"
JAUNE="\\033[1;33m"
CYAN="\\033[1;36m"

clear

if [ $(id -u) != 0 ] ; then
  echo "${ROUGE}Les droits de super-utilisateur (root) sont requis"
  echo "Veuillez lancer 'sudo $0' ou connectez-vous en tant que root, puis relancez $0 ${NORMAL}"
  exit 1
fi

apt_install() {
  apt-get -o Dpkg::Options::="--force-confdef" -y install "$@"
  if [ $? -ne 0 ]; then
    echo "${ROUGE}Ne peut installer $@ - Annulation${NORMAL}"
    exit 1
  fi
}

service_action(){
  if [ "${INSTALLATION_TYPE}" = "pigen" ];then
    service $2 $1
    return $?
  else
    if [ "$1" = "status" ];then
      systemctl is-active --quiet $2
    else
      systemctl $1 $2
    fi
    if [ $? -ne 0 ]; then
      service $2 $1
      return $?
    fi
    return 0
  fi
}



clear


echo
echo
echo "${BLANC}     ...     ..                                             .               "
echo "  .=*8888x <?88h.                                         @88>             "
echo " X>   8888H> '8888          u.          u.                 %8P              "
echo " 88h.  8888   8888    ...ue888b   ...ue888b       uL        .         .u    "
echo "'8888  8888     88>   888R Y888r  888R Y888r  .ue888Nc..  .@88u    ud8888.  "
echo "  888  8888.xH888x.   888R I888>  888R I888> d88E  888E    888E  :888 8888. "
echo "   X  :88*~   *8888>  888R I888>  888R I888> 888E  888E    888E  d888  88%  "
echo " ~    !         888>  888R I888>  888R I888> 888E  888E    888E  8888.+     "
echo "  .H8888h.      ?88  u8888cJ888  u8888cJ888  888E  888E    888E  8888L      "
echo " : ^ 88888h.    '!     *888*P      *888*P    888& .888E    888&  '8888c. .+ "
echo " ^     88888hx.+        'Y          'Y       *888  888&    R888    88888%   "
echo "        ^ **                                        888E             YP     "
echo "                                             .dWi    88E                    "
echo "                                             4888~  J8%                     "
echo "                                              ^ ===*                        ${NORMAL}"
echo






echo "${BLANC}SCRIPT POST INSTALL RASPBIAN"
echo
echo "=================================================================="
echo "INFO:"
echo "Ce script à pour objectif de :"
echo "- Mettre à jour le système"
echo "- Proposer les installations d'utilitaires essentiels au système"
echo "- Redémarrer le système une fois les installations terminées"
echo "==================================================================${NORMAL}"
echo



echo
while true; do
read -p "Voulez vous continuer ? (y/n) " yn
case $yn in 
	[yY] ) echo ${ROUGE}"Lancement de l'installation..."${NORMAL};
		sleep 1
		break;;
	[nN] ) echo Sortie...;
		exit;;
	* ) echo Réponse non valide;;
esac
done
echo


clear

echo
echo "${BLANC}======================"
echo
echo "Installation en cours"
echo
echo "======================${NORMAL}"
echo


sleep 1

step_1_upgrade() {
  clear
  echo "${BLEU}MISE A JOUR DU SYSTEME"
  echo "=======================${NORMAL}"
  echo
  echo "${JAUNE}Veuillez patienter...${NORMAL}"
  echo

  apt update
  apt-get -f install
  apt-get -y dist-upgrade

  echo
  echo
  echo "${VERT}===================="
  echo "Mise à jour réussie"
  echo "====================${NORMAL}"
  echo
}


sleep 3


step_2_mainpackage() {
  clear
  echo "${BLEU}INSTALLATION UTILITAIRES"
  echo "=========================${NORMAL}"
  echo
  echo "${JAUNE}Veuillez patienter...${NORMAL}"
  echo

  LIST_OF_APPS="libffi-dev libssl-dev python3 python3-pip checkinstall curl git make cmake yasm aptitude build-essential screen ppp apparmor jq wget udisks2 libglib2.0-bin dbus lsb-release systemd-journal-remote"

  apt install -y $LIST_OF_APPS

  echo
  echo "${VERT}======================================"
  echo "Installation des utilitaires terminée"
  echo "======================================${NORMAL}"
  echo
}


sleep 3


step_3_final() {
  clear
  echo
  echo "${VERT}======================================"
  echo "MISE A JOUR ET INSTALLATION TERMINEE"
  echo "======================================${NORMAL}"
  echo
  echo "Un redémarrage devrait être effectué"
  echo
}


step_4_reboot() {
  echo
  echo "${VERT}==========="
  echo "REDEMARRAGE"
  echo ==========="${NORMAL}"
  echo

  while true; do

  read -p "Voulez vous redémarrer ? (y/n) " yn

  case $yn in 
  	[yY] ) echo ${ROUGE}Redémarrage en cours dans 5 secondes${NORMAL};
  		sleep 5
  		reboot now;;
  	[nN] ) echo Sortie...;
  		exit;;
  	* ) echo Réponse non valide;;
  esac

  done
  echo
}


STEP=0
VERSION=V4-stable
INSTALLATION_TYPE='standard'

while getopts ":s:v:w:m:i:" opt; do
  case $opt in
    s) STEP="$OPTARG"
    ;;
    v) VERSION="$OPTARG"
    ;;
    w) WEBSERVER_HOME="$OPTARG"
    ;;
    i) INSTALLATION_TYPE="$OPTARG"
    ;;
    \?) echo "${ROUGE}Invalid option -$OPTARG${NORMAL}" >&2
    ;;
  esac
done



case ${STEP} in
  0)
  echo "${JAUNE}Commence toutes les étapes de l'installation${NORMAL}"
  step_1_upgrade
  step_2_mainpackage
  step_3_final
  step_4_reboot
  ;;
  1) step_1_upgrade
  ;;
  2) step_2_mainpackage
  ;;
  3) step_3_final
  ;;
  3) step_4_reboot
  ;;
  *) echo "${ROUGE}Désolé, Je ne peux sélectionner une ${STEP} étape pour vous !${NORMAL}"
  ;;
esac


exit 0
