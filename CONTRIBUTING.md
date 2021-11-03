# Contributing to OpenReallife SA:MP

We love your input! We want to make contributing to this project as easy and transparent as possible, whether it's:

- Reporting an issue
- Discussing the current state of the code
- Submitting a fix
- Proposing new features
- Becoming a maintainer

## Quickstart Local Pawno Development

The following explains how to set up and start an SA:MP Development Server locally.

## Server konfigurieren

Navigate to `/samp`

### 1. Check server.cfg file

- Open `server.cfg`
- In the line `gamemode0` should be: `gamemode0 openReallife`
- In the line `plugins` should be: `plugins mysql sscanf streamer`

### 2. Set up local MySQL database

Click [here](https://www.javatpoint.com/creating-mysql-database-with-xampp) to learn how to set up a local MySQL database with XAMPP.

- Navigate to `PhpMyAdmin`
- Open the `Import` tab
- Import the database file `openReallife_DB.sql` ([File](https://raw.githubusercontent.com/OpenReallife/OpenReallife-SAMP/main/openReallife_DB.sql))
  </br>
  </br>
  <img height=500 src="https://raw.githubusercontent.com/OpenReallife/OpenReallife-SAMP/main/SetupMySQL.png"/>

  - A database with the name `ni6595017_1_DB` is created
  - This contains the tables: `carshop`, `faction`, `user`, `vehicle`
    </br>
    </br>
    <img height=200 src="https://raw.githubusercontent.com/OpenReallife/OpenReallife-SAMP/main/DB.png"/>

### 3. Create file mysql_connect.inc

- Navigate to `/samp/include`
- Create a file with the name `mysql_connect.inc`
- Open the file `mysql_connect.inc`
- Configure the code:

```c++
    /*
	SQL Auth Data
    */

    #define SQL_HOSTNAME "localhost"
    #define SQL_DATABASE "ni6595017_1_DB"
    #define SQL_USERNAME [DATABASE USERNAME]
    #define SQL_PASSWORD [DATABASE PASSWORT]
```

- Save file

## Start server

Navigate to `/samp`

- Start `samp-server.exe`
- Check if the server was started correctly
  </br>
  </br>
  <img height=400 src="https://raw.githubusercontent.com/OpenReallife/OpenReallife-SAMP/main/SampServer.png"/>

## Add server in launcher

- Launch the `San Andreas Multiplayer 0.3.7-R4` Launcher
- Press IconButton `Add Server`
- Enter the server data: `localhost:7777`
- Press `OK` Button
- The development server will be displayed in the server list in the `Favorites` tab.
  </br>
  </br>
  <img height=400 src="https://raw.githubusercontent.com/OpenReallife/OpenReallife-SAMP/main/SAMPLauncher.png"/>
