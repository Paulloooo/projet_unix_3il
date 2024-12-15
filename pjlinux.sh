#!/bin/bash

# Sélection du type de serveur
echo -e "Avec quel serveur voulez-vous développer ?\n1 - Node JS\n2 - Django\n"
read SERVER

if [[ "$SERVER" -eq 1 ]]; then
    APP_TYPE="nodejs"
    APP_PORT=3000
elif [[ "$SERVER" -eq 2 ]]; then
    APP_TYPE="django"
    APP_PORT=8000
else
    echo "Option invalide."
    exit 1
fi

# Maj des paquets et installation des dépendances
echo "Mise à jour des paquets et installation des outils nécessaires..."
sudo apt update && sudo apt install -y $([[ "$APP_TYPE" == "nodejs" ]] && echo "nodejs npm" || echo "python3 python3-pip")

APP_DIR="/var/www/mon_application"
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
    sudo pm2 start app.js --name "mon_application" --watch -- --port=$APP_PORT
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
