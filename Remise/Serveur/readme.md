
### Serveur hébergé et base de données
Notre serveur ainsi que notre base de données sont hébergés sur le cloud de google à l'adresse "https://polypaint.me".

Aucun besoin de lancer le serveur localement. 

Si vous le voulez par contre, vous pouvez lancée la commande dotnet PolyPaint.API.dll, ce qui va partir localement le serveur. (Les clients sont liés au serveur héberger en ligne)

### Instruction de connexion
Afin de vous connecter à notre application, vous devez fournir l'un des identifiant suivant

|Nom d'utilisateur| Mot de passe|
|--|--|
|user.1|!12345Aa|
|user.2|!12345Aa|
|user.3|!12345Aa|
|user.4|!12345Aa|


## Connection simultanée et déconnexion
Il est important de noter que vous ne pouvez que vous connecter qu'à un seul compte en simultané. Il vous sera impossible de vous connecter si vous êtes déjà connecté avec le même compte.

Lorsque vous souhaitez vous déconnecter du compte sur la plateforme iOS, veuillez double cliquer sur le menu principal pour ouvrir le gestionnaire d'application et supprimer l'application. Sur le client lourd, simplement quitter l'application.

## Connection invalide.
La gestion d'erreur de connexion n'est pas assumé sur le client lourd. Vous n'allez donc pas voir d'erreur si vous entrez une mauvaise combinaison d'authentification. Par contre, vous allez rester à l'écran de connexion.

## Client Lourd
Pour exécuter le client lourd, veuillez partir le fichier PolyPaint.exe.

## Client Léger
Pour exécuter le client léger, aller dans le dossier iOS où le fichier podfile se retrouve puis exécuter la commande pod install. Par la suite, ouvrir le projet ios.xcworkspace et compiler le code avec XCODE, signer le certificat avec votre compte développeur puis installer l'application sur votre tablette. Accepter le certificat dans vos paramètres généraux et ouvrez l'application. Connectez-vous et appuyez sur la pastille chat.

Vous êtes prêt à clavarder.