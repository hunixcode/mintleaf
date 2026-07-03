<div align="center">
    <div>
        <img src="./assets/mint-logo.png" height="150px">
        <img src="./assets/upf-logo.png" height="150px">
    </div>
    <h1>Configuration post-install Linux Mint</h1>
    <p>Deux scripts principaux sont à votre disposition : <b>full-setup.sh</b> (après installation) </br>et <b>traitement.sh</b> (après retour de prêt).</p>
</div>

## 1. Installation complète — `full-setup.sh`

Utilisation juste après avoir installé Linux Mint sur la machine.

```sh
chmod +x full-setup.sh
sudo bash full-setup.sh
```

**Ce script effectue dans l'ordre :**

1. mise à jour complète du système (`apt update && apt upgrade -y`)
2. installation des applications : VLC, Zotero, Mediathèque numérique
3. vérification et correction du fuseau horaire (Pacific/Tahiti) et de la sync NTP
4. création de l'utilisateur `pret` (mot de passe : `pret`)

## 2. Traitement de retour — `traitement.sh`

Utilisation quand un élève rend l'ordinateur.

```sh
chmod +x traitement.sh
sudo bash traitement.sh
```

**Ce script effectue dans l'ordre :**

1. vérifie que les applications sont toujours installées, les réinstalle si besoin
2. vérifie et corrige l'horloge (timezone + NTP)
3. supprime tous les réseaux WiFi enregistrés sur la machine
4. supprime l'utilisateur `pret` et tout son répertoire personnel
5. recrée l'utilisateur `pret` (mot de passe : `pret`)

**Si le script se bloque avec le message :**

> Des processus de l'utilisateur 'pret' sont encore actifs

L'utilisateur `pret` est encore connecté ou a des processus en cours.
Redémarrez la machine, puis relancez `sudo bash traitement.sh`.

## 3. Dépannage

### "Permission denied" ou "Veuillez exécuter en tant que root"

Vous devez lancer les scripts avec `sudo` :

```sh
sudo bash full-setup.sh
```

### "apt update" échoue

Vérifiez que la machine a accès à Internet. Si vous êtes derrière un proxy,
configurez-le d'abord (Paramètres réseau > Proxy).

### "Le paquet Mediathèque est introuvable"

Vérifiez que le dossier `Packages/` est bien présent à côté du script et
qu'il contient le fichier `.deb` (Mediatheque Numerique Desktop Player Setup.deb).

### L'utilisateur "pret" existe déjà

Le script détecte automatiquement un utilisateur existant et met à jour
son mot de passe. Aucune action manuelle nécessaire.

### Le script reste bloqué ou s'arrête en erreur

Relisez le message d'erreur dans le terminal. Les cas les plus fréquents, voici les mesures à prendre
au cas où vous rencontreriez les problèmes suivants :

| Erreur | Cause | Solution |
|--------|-------|----------|
| `Processus pret actifs` | Session ouverte | `reboot` puis relancer |
| `apt: command not found` | Pas sur Linux Mint | Vérifier l'OS |
| `wget: command not found` | wget manquant | `apt install wget -y` |
| Echec d'installation Zotero | Pas d'internet | Vérifier la connexion |

Si jamais n'hésitez pas à ouvrir un Issue sur le [repo en ligne](https://github.com/hunix443/mintleaf/issues) pour expliquer votre problème.
:P
