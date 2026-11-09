# thinkpadSync

Spoločný setup dvoch notebookov s Arch Linuxom, spravovaný cez **chezmoi + Git**.
Repozitár je verejný. Obsahuje iba vybrané konfigurácie, nie zálohu systému.

## Čo sa prenáša

- Fish: spoločné aliasy, príkaz `aliasy`, cesta k používateľským skriptom.
- Kitty: veľkosť písma, vkladanie, skratky a taby; existujúca HyDE téma zostáva lokálna.
- `setup-push` a `setup-pull` na odoslanie a prevzatie zmien.
- Voliteľný profil HyDE: vlastné skratky, pravidlá okien, Pyprland dropdowny,
  nahrávanie obrazovky a výber tapety. Obrázky sa neprenášajú.

**Desktopový profil vyžaduje kompatibilný Hyprland s Lua konfiguráciou a HyDE.**
Nie je určený pre i3, Sway ani staršie Hyprland konfigurácie `.conf`.
Na neznámom notebooku odpovedz pri inicializácii na otázku o HyDE `false`.
Repozitár neinštaluje HyDE ani aplikácie a nekopíruje ich generované témy.
Waybar, napájanie, displeje, zvuk, VPN a pracovné projekty zostávajú lokálne.

## Prvé nastavenie na X230

Nainštaluj iba nástroje synchronizácie (Fish/Kitty podľa potreby):

```sh
sudo pacman -S --needed chezmoi git python
chezmoi init https://github.com/Matistikoff/thinkpadSync.git
```

Pred aplikovaním presuň vlastné aliasy do `~/.config/fish/aliases.local.fish`
a ďalšie Fish úpravy do `~/.config/fish/config.local.fish`, ak ich chceš zachovať.
Hardvérové a pracovné Hyprland úpravy môžu zostať v `~/.config/hypr/local.lua`.
Nevkladaj doň celý pôvodný HyDE vstupný súbor, iba vlastné nastavenia.
Lokálne nastavenia Kitty patria do `~/.config/kitty/local.conf`.

```sh
bash "$(chezmoi source-path)/scripts/apply.sh"
```

Skript vytvorí zálohu existujúcich spravovaných súborov v
`~/.local/state/thinkpadSync/backups/`, zobrazí rozdiely a spýta sa pred zmenami.
Pri ručnom `chezmoi apply` sa táto záloha nevytvára. Po aplikovaní otvor nový terminál.
Na tomto prvom notebooku bol chezmoi nainštalovaný do `~/.local/bin`.

## X230: prechod z DWM na Hyprland

Na X230 teraz zvoľ **false**; Fish sa zosynchronizuje a DWM zostane nedotknutý.
Prechod pracovnej plochy je samostatný krok: najprv nainštalovať a vyskúšať
Hyprland s kompatibilným HyDE, pričom zachovať funkčnú DWM reláciu ako zálohu.
Potom v `chezmoi edit-config` zmeň `hydeDesktop = false` na `true`, skontroluj
`chezmoi diff` a znovu spusti `scripts/apply.sh` podľa postupu vyššie.
Displej X230 nastav osobitne; rozlíšenie ani výstupy prvého notebooku sa nekopírujú.

## Každodenná práca

```sh
aliasy                       # úprava spoločných aliasov
bindy                        # úprava spoločných skratiek (iba profil HyDE)
chezmoi diff                 # kontrola zmien
setup-push "Nové skratky"    # uložiť upravené spravované súbory a odoslať
# na druhom notebooku:
setup-pull
```

Zmeny môžeš robiť na oboch notebookoch. Najprv načítaj aktuálnu verziu,
až potom upravuj. Nejde o živú automatickú synchronizáciu.
`setup-pull` odmietne prepísať lokálne zmeny a používa iba Git fast-forward.
Pri odmietnutom push/pull treba zosúladiť Git vetvy; nepoužívaj force push.
Na odosielanie potrebuje každý notebook vlastné GitHub prihlásenie
(napr. `gh auth login` a `gh auth setup-git`); čítanie verejného repozitára ho nepotrebuje.

`setup-push` zachytáva len už spravované bežné súbory. Nové súbory pridávaj
vedome cez `chezmoi add <súbor>` a potom Git add/commit/push v zdrojovom repozitári.
Šablóny (aktuálne Pyprland) uprav cez `chezmoi edit ~/.config/pypr/config.toml`,
potom skontroluj `chezmoi diff` a aplikuj; `re-add` šablóny neprepisuje.

## Výnimky pre konkrétny notebook

- Fish: `aliases.local.fish`, `config.local.fish`.
- Hyprland: `local.lua`; existujúce `monitors.lua` a `monitors.conf` sa nespravujú.
- Kitty: `local.conf`.
- Profil: `hydeDesktop` v lokálnom `~/.config/chezmoi/chezmoi.toml`.

Lokálne výnimky sa načítavajú posledné. Prepnutie profilu na `false` prestane
spravovať desktopové súbory, ale neodstráni už aplikované súbory.
Nesynchronizuj celé `~/.config`, Fish universal variables, históriu, `/etc`,
SSH kľúče, tokeny ani prihlasovacie údaje.

## Programy pre voliteľné funkcie

HyDE profil predpokladá už funkčný HyDE, Hyprland s Lua API a Pyprland.
Terminál: Kitty; editor aliasov: Neovim; editor skratiek: Vim.
Dropdowny: Spotify, Ferdium, teams-for-linux (iba ak ich používaš).
Nahrávanie: wf-recorder, slurp, libpulse (`pactl`), rofi, libnotify, util-linux.
Tapety: Python, ImageMagick, file, rofi a funkčné témy/stav HyDE.
`monitory` používa nwg-displays. Chýbajúce voliteľné programy neinštalujeme automaticky.
Numpad skratky sú zachované, ale X230 bez externej klávesnice ich nemusí vedieť použiť.
