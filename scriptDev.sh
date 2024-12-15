#!/bin/bash

SERVER=0
VSCODE=0
APP_DIR="/var/www/mon_application"

#On demande à l'utilisateur s'il veut développer avec Node JS ou Django
while [ $SERVER -ne 1 ] && [ $SERVER -ne 2 ]; do
	echo -e "Avec quel serveur voulez-vous développer ?\n1 - Node JS\n2 - Django\n"
	read SERVER
done

#Suivant le choix, on vérifie si les paquets nécessaires sont installés
if [ $SERVER -eq 1 ]; then
    APP_TYPE="nodejs"
    APP_PORT=3000
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
    APP_TYPE="django"
    APP_PORT=8000
	#On vérifie si Python est installé
	if python -V &> /dev/null; then
		echo "Python est installé"
	else 
		echo "Installation de Python..."
		echo y | apt-get install python3 python3-pip > /dev/null 
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

#on demande le nom du projet et on va chercher le dossier associé qui a été clone au préalable 
APP_DIR=""
while [ $APP_DIR -eq "" ]; do
	echo -e "Le projet a été cloné dans quel dossier ?\n"
	read APP_DIR 
	if [ ! -d "$APP_DIR" ]; then
		echo "Le dossier n'existe pas"
		APP_DIR=""
	fi
done

cd $APP_DIR
echo "Installation des dépendances..."
if [[ "$APP_TYPE" == "nodejs" ]]; then
    sudo npm install
else
    pip3 install -r requirements.txt
fi

# Configuration et lancement de l'application
echo "Lancement de l'application..."
if [[ "$APP_TYPE" == "nodejs" ]]; then
    sudo npm install -g pm2
    sudo pm2 start app.js --name "$APP_DIR" --watch -- --port=$APP_PORT
    sudo pm2 save
else
    python3 manage.py migrate
    python3 manage.py collectstatic --noinput
    gunicorn --workers 3 --bind 0.0.0.0:$APP_PORT mon_application.wsgi:application &
fi

# Test de connectivité
echo "Test de l'application sur le port $APP_PORT..."
curl -s --head http://localhost:$APP_PORT | grep "200 OK" > /dev/null

if [[ $? -eq 0 ]]; then
    echo "Application déployée avec succès sur le port $APP_PORT !"
else
    echo "Échec du déploiement. Vérifiez les journaux pour plus d'informations."
    exit 1
fi
