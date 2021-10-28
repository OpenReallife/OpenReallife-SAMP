# Contributing to OpenReallife SA:MP

We love your input! We want to make contributing to this project as easy and transparent as possible, whether it's:

- Reporting an issue
- Discussing the current state of the code
- Submitting a fix
- Proposing new features
- Becoming a maintainer

## Quickstart Local Pawno Development

Nachfolgend wird erklärt, wie man einen SA:MP Development Server lokal aufsetzt und startet.

## Server konfigurieren

Navigiere zu `/samp`

### Datei server.cfg überprüfen

- Öffne `server.cfg`
- In der Zeile `gamemode0` sollte folgendes stehen: `gamemode0 openReallife`
- In der Zeile `plugins` sollte folgendes stehen: `plugins mysql sscanf streamer`

### MySQL-Datenbank aufsetzen

Klicke [hier](https://www.javatpoint.com/creating-mysql-database-with-xampp) um zu lernen, wie man lokal eine MySQL-Datenbank mit XAMPP aufsetzt

- Navigiere zu `PhpMyAdmin`
- Öffne die erstellte Datenbank
- Öffne den Tab `Import`
- Importiere die Datenbank-Datei `openReallife_DB.sql`
  </br>
  </br>
  <img height=600 src="https://raw.githubusercontent.com/OpenReallife/OpenReallife-SAMP/main/SetupMySQL.png"/>

- Navigiere zu `/samp/include`
- Erstelle eine Datei mit den Namen `mysql_connect.inc`
- Öffne die Datei `mysql_connect.inc`
- Konfiguriere den Code:

```c++
    /*
	SQL Auth Data
    */

    #define SQL_HOSTNAME "localhost"
    #define SQL_DATABASE [DATABASE NAME]
    #define SQL_USERNAME [DATABASE USERNAME]
    #define SQL_PASSWORD [DATABASE PASSWORT]
```

- Datei Speichern

## Server starten

Navigiere zu `/samp`

- Starte `samp-server.exe`
- Überprüfe, ob der Server korrekt gestartet
  </br>
  </br>
  <img height=400 src="https://raw.githubusercontent.com/OpenReallife/OpenReallife-SAMP/main/SampServer.png"/>

## Server im Launcher hinzufügen

- Starte den `San Andreas Multiplayer 0.3.7-R4` Launcher
- Drücke IconButton `Add Server`
- Trage die Serverdaten ein: `localhost:7777`
- Drücke Button `OK`
- Der Development Server wird in der Serverliste im Tab `Favorites` angezeigt
  </br>
  </br>
  <img height=400 src="https://raw.githubusercontent.com/OpenReallife/OpenReallife-SAMP/main/SAMPLauncher.png"/>
