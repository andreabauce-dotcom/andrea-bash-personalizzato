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

Scrivi `comandi` per vedere l'elenco completo nel terminale.

```text
git-info           riepilogo del repository corrente
extract FILE       estrae un archivio (tar, zip, 7z, rar, gz, bz2, xz, zst)
backup FILE        crea una copia con timestamp
mkcd DIR           crea una directory e vi entra
trova NOME [DIR]   cerca file per nome
cerca TESTO [DIR]  cerca testo nei file (usa rg se presente)
ultimi [DIR] [MIN] file modificati negli ultimi MIN minuti (60)
grandi [DIR] [N]   elementi più pesanti della directory
path               mostra il PATH numerato
servizi            servizi systemd falliti e prossimi timer utente
log-servizio NOME  segue il log di un servizio utente (--system per quelli di sistema)
porta N            chi usa la porta N
spazio             spazio libero sui dischi reali
gpu                stato della scheda NVIDIA
audio-info         uscite e ingressi audio PipeWire/PulseAudio
net-info           indirizzi e routing
wifi-info          stato Wi-Fi/NetworkManager
listen-ports       porte TCP/UDP in ascolto
public-ip          mostra l'IP pubblico su richiesta
serve [PORTA]      condivide la directory via HTTP solo su questo PC (--lan per la rete)
adb-devices        dispositivi Android collegati
adb-shell          apre una shell ADB
adb-wifi [IP:PORTA] collega ADB via Wi-Fi (senza argomenti usa redmi-wifi.sh se c'è)
adb-screenshot     salva uno screenshot del telefono
miei-script        elenca gli script di ~/.local/bin con la loro descrizione
k ...              usa kubectl o, se necessario, k3s kubectl
```

La cronologia tiene 50000 comandi in memoria e 100000 nel file, anche se il
`.bashrc` di Ubuntu imposta valori più bassi. Per cambiarli:
`export ANDREA_HISTSIZE=... ANDREA_HISTFILESIZE=...` prima del blocco Andrea Bash.

Il prompt mostra il percorso, il codice di uscita dell'ultimo comando e lo
stato Git. Per disattivare il controllo Git nel prompt:

```bash
export ANDREA_PROMPT_GIT=false
```

I completamenti di `kubectl`, `helm` e `gh` si attivano soltanto se i
rispettivi programmi sono installati. Il completamento di `gcloud` è caricato
direttamente dal file dell'SDK, senza lanciare `gcloud info` a ogni avvio.
Il completamento automatico degli alias di Bash-it non è attivo perché
rallentava l'apertura del terminale di oltre un secondo.

## Rimozione

```bash
bash ~/.bash_it_andrea/uninstall.sh
```

Lo script salva una copia della configurazione prima di rimuovere il blocco.
La cartella di installazione non viene cancellata automaticamente.

