
# Serveur hébergé et base de données
Notre serveur ainsi que notre base de données sont hébergés sur le cloud de google à l'adresse "https://polypaint.me".

Aucun besoin de lancer le serveur localement. Ce dossier est présent seulement en cas de problème.

Il est possible de rouler le serveur localement avec la commande `dotnet run -p Backend/PolyPaint.API/PolyPaint.API.csproj`.


Cependant, les clients sont liés avec le serveur sur Google

# Client Lourd
Pour exécuter le client lourd, veuillez partir le fichier PolyPaint.exe.

# Client Léger
Pour exécuter le client léger, 
- Aller dans le dossier iOS où le fichier podfile se retrouve puis exécuter la commande pod install
- Ouvrir le projet ios.xcworkspace
- Compiler le code avec XCODE
- Signer le certificat avec votre compte développeur 
- Installer l'application sur votre tablette
- Accepter le certificat dans vos paramètres généraux et ouvrez l'application