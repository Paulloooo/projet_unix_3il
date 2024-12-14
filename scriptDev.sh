#!/bin/bash

echo -e "Avec quel serveur voulez-vous développer ?\n1 - Node JS\n2 - Django\n"
read server

if [ $SERVER -eq 1 ]; then
	echo "nodeJS!!"
elif [ $SERVER -eq 2 ]; then
	echo "autre truc python nul !!"
else 
	echo "Vous avez entré une mauvaise option, recommencez !"
fi

if git -v &> /dev/null; then
	echo "Git est installé"
else 
	echo "Installation de Git..."
	echo y | apt-get install git > /dev/null 
fi

