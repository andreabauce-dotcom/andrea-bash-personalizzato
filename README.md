# Andrea Bash

Configurazione personale per Bash basata sul framework Bash-it e su alcune
funzioni selezionate dal progetto bash_magic.

## Scelte fatte

Sono stati esclusi dal profilo predefinito:

- il plugin `base`, perché introduce funzioni e alias non necessari;
- gli alias Git completi, perché includono reset, clean, push forzati e altre operazioni rischiose;
- la cronologia eterna di bash_magic;
- l'avvio automatico di `ssh-agent`;
- i plugin Knewton, AWS, Rails e gli altri componenti legacy;
- `rmrf`, `git clean`, `git reset --hard` e analoghi alias distruttivi.

Sono state mantenute o aggiunte funzioni per:

- Git in sola consultazione;
- archivi, backup e gestione directory;
- Android SDK, ADB e logcat;
- kubectl/k3s;
- SSH e completamento Bash;
- rete, Wi-Fi e porte in ascolto;
- clipboard con `wl-clipboard`, `xclip` o `xsel`;
- cronologia Bash normale, senza copiare tutti i comandi in un secondo file.

## Installazione

Il programma di installazione non sostituisce il tuo `.bashrc`: crea un backup
con data e aggiunge un blocco identificabile e rimovibile.

```bash
bash install.sh
source ~/.bashrc
```

La destinazione predefinita è `~/.bash_it_andrea`. Puoi cambiare percorso con:

```bash
ANDREA_BASH_HOME="$HOME/.config/andrea-bash" bash install.sh
```

## Comandi principali

```text
git-info       riepilogo del repository corrente
extract FILE   estrae un archivio
backup FILE    crea una copia con timestamp
mkcd DIR       crea una directory e vi entra
path           mostra il PATH numerato
net-info       indirizzi e routing
wifi-info      stato Wi-Fi/NetworkManager
listen-ports   porte TCP/UDP in ascolto
public-ip      mostra l'IP pubblico su richiesta
adb-devices    dispositivi Android collegati
adb-shell      apre una shell ADB
k ...          usa kubectl o, se necessario, k3s kubectl
```

Il prompt mostra il percorso, il codice di uscita dell'ultimo comando e lo
stato Git. Per disattivare il controllo Git nel prompt:

```bash
export ANDREA_PROMPT_GIT=false
```

I completamenti per `gcloud` e `gh` sono presenti nel profilo, ma si attivano
soltanto se i rispettivi programmi sono installati. Se non ti servono, puoi
disabilitarli con `bash-it disable completion gcloud github-cli`.

## Rimozione

```bash
bash ~/.bash_it_andrea/uninstall.sh
```

Lo script salva una copia della configurazione prima di rimuovere il blocco.
La cartella di installazione non viene cancellata automaticamente.

