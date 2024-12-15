#!/bin/bash

SERVER=0
VSCODE=0

#On demande à l'utilisateur s'il veut développer avec Node JS ou Django
while [ $SERVER -ne 1 ] && [ $SERVER -ne 2 ]; do
	echo -e "Avec quel serveur voulez-vous développer ?\n1 - Node JS\n2 - Django\n"
	read SERVER
done

#Suivant le choix, on vérifie si les paquets nécessaires sont installés
if [ $SERVER -eq 1 ]; then
	#On vérifie si Node JS est installé
	if node -v &> /dev/null; then
		echo "Node JS est installé"
	else 
		echo "Installation de Node JS..."
		echo y | apt-get install nodejs > /dev/null 
	fi

	#On vérifie si NPM est installé
	if npm -v &> /dev/null; then
		echo "NPM est installé"
	else 
		echo "Installation de NPM..."
		echo y | apt-get install npm > /dev/null 
	fi
fi 

if [ $SERVER -eq 2 ]; then
	#On vérifie si Python est installé
	if python -V &> /dev/null; then
		echo "Python est installé"
	else 
		echo "Installation de Python..."
		echo y | apt-get install python > /dev/null 
	fi

	#On vérifie si Django est installé
	if django-admin --version &> /dev/null; then
		echo "Django est installé"
	else 
		echo "Installation de Django..."
		echo y | apt-get install django > /dev/null 
	fi
fi

#On vérifie si Git est installé
if git -v &> /dev/null; then
	echo "Git est installé"
else 
	echo "Installation de Git..."
	echo y | apt-get install git > /dev/null 
fi

#Optionnel, mais on vérifie si l'utilisateur a VSCode
#Si non, on lui propose de l'installer
if code -v &> /dev/null; then
	echo "Vous avez installé VS Code, bon choix :)"
else 
	echo -e "Voulez-vous installer Visual Studio Code ?\n1 - Oui\n2 - Non\n"
	read VSCODE
	if [ $VSCODE -eq 1 ]; then
		echo "Installation de Visual Studio Code..."
		echo y | apt-get install code > /dev/null 
	fi
fi
