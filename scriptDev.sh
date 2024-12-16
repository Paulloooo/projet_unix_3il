#!/bin/bash

SERVER=0
VSCODE=0
APP_DIR="mon_application"

# Demander le serveur
while [ "$SERVER" -ne 1 ] && [ "$SERVER" -ne 2 ]; do
	echo -e "Avec quel serveur voulez-vous développer ?\n1 - Node JS\n2 - Django\n"
	read SERVER
done

if [ "$SERVER" -eq 1 ]; then
    APP_TYPE="nodejs"
    APP_PORT=3000
	if ! command -v node &> /dev/null; then
		echo "Installation de Node JS..."
		sudo apt-get -y install nodejs > /dev/null 2>&1
	fi
	if ! command -v npm &> /dev/null; then
		echo "Installation de NPM..."
		sudo apt-get -y install npm > /dev/null 2>&1
	fi
elif [ "$SERVER" -eq 2 ]; then
    APP_TYPE="django"
    APP_PORT=8000
	if ! command -v python3 &> /dev/null; then
		echo "Installation de Python..."
		sudo apt-get -y install python3 python3-pip > /dev/null 2>&1
	fi
	if ! python3 -m django --version &> /dev/null; then
		echo "Installation de Django..."
		pip3 install django > /dev/null 2>&1
	fi
fi

# Vérification de Git
if ! command -v git &> /dev/null; then
	echo "Installation de Git..."
	sudo apt-get -y install git
fi

# Vérification de VSCode
if ! command -v code &> /dev/null; then
	echo -e "Voulez-vous installer Visual Studio Code ?\n1 - Oui\n2 - Non\n"
	read VSCODE
	if [ "$VSCODE" -eq 1 ]; then
		echo "Installation de Visual Studio Code..."
		sudo apt-get -y install code  > /dev/null 2>&1
	fi
fi

# Demander le dossier de l'application
while [ -z "$APP_DIR" ]; do
	echo -e "Le projet a été cloné dans quel dossier ?\n"
	read APP_DIR
	if [ ! -d "$APP_DIR" ]; then
		echo "Le dossier n'existe pas"
		APP_DIR=""
	fi
done

cd "$APP_DIR"
echo "Installation des dépendances..."
if [[ "$APP_TYPE" == "nodejs" ]]; then
	echo "Installation des dépendances Node JS..."
    npm install  > /dev/null 2>&1
else
    if [ -f requirements.txt ]; then
		echo "Installation des dépendances Django..."
        pip3 install -r requirements.txt
    else
        echo "Fichier requirements.txt introuvable. Dépendances non installées."
    fi
fi

# Lancement de l'application
echo "Lancement de l'application..."
if [[ "$APP_TYPE" == "nodejs" ]]; then
    sudo npm install -g pm2  > /dev/null 2>&1
    pm2 start app.js --name "$(basename "$APP_DIR")" --watch -- --port="$APP_PORT"
    pm2 save
else
    python3 manage.py migrate
    python3 manage.py collectstatic --noinput
    if command -v gunicorn &> /dev/null; then
        gunicorn --workers 3 --bind 0.0.0.0:"$APP_PORT" mon_application.wsgi:application &
    else
        echo "Gunicorn non installé. Veuillez l'installer pour démarrer l'application Django."
        exit 1
    fi
fi

#On teste si l'utilisateur a curl d'installé
if ! command -v curl &> /dev/null; then
	echo "Installation de curl..."
	sudo apt-get -y install curl > /dev/null 2>&1
fi

# Test de connectivité
echo "Test de l'application sur le port $APP_PORT..."
if curl -s --head "http://localhost:$APP_PORT" | grep "200 OK" > /dev/null; then
    echo "Application déployée avec succès sur le port $APP_PORT !"
else
    echo "Échec du déploiement. Vérifiez les journaux pour plus d'informations."
    exit 1
fi
