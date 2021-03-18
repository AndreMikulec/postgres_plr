
Postgres_PLR Project Build Status:
[![Build status](https://ci.appveyor.com/api/projects/status/d6xr4t0p3b8avoiq?svg=true)](https://ci.appveyor.com/project/AndreMikulec/postgres-plr)

Postgres_PLR Project Master Branch Build Status:
[![Build status](https://ci.appveyor.com/api/projects/status/d6xr4t0p3b8avoiq/branch/master?svg=true)](https://ci.appveyor.com/project/AndreMikulec/postgres-plr/branch/master)

### PL/R - PostgreSQL support for R as a procedural language (PL)
[![GitHub license](https://img.shields.io/github/license/postgres-plr/plr.svg?cacheSeconds=2592000)](https://github.com/postgres-plr/plr/blob/master/LICENSE)

 Copyright by Joseph E. Conway ALL RIGHTS RESERVED

 Joe Conway <mail@joeconway.com>

 Based on pltcl by Jan Wieck
 and inspired by REmbeddedPostgres by
 Duncan Temple Lang <duncan@research.bell-labs.com>
 http://www.omegahat.org/RSPostgres/

### License
- GPL V2 see [LICENSE](https://github.com/postgres-plr/plr/blob/master/LICENSE) for details

### What is This?

The Appveyor YAML markup of this respository, is composed of instructions needed to build, on Windows, using MSYS2 (instead of Microsoft Visual Studio), the PostgreSQL contributed extension "plr" (PL/R - PostgreSQL support for R as a procedural language (PL)).

This extension allows a PostgreSQL SQL developer to write code using the "R" programming language inside the "PostgreSQL database on Windows."

Get the latest "Appveyor built" plr released downloads here.

https://github.com/AndreMikulec/postgres_plr/releases/latest

My `modified instructions` are here. 
These instructions are "based on", and also are, an "enhancement of" the 
copyright holders instructions (see the link below).

https://github.com/AndreMikulec/postgres_plr/blob/master/userguide.md

Includes: 

* Examples in more detail
* Extra examples
* Extended expanation on how to install "Visual Studio" compiled plr on Windows
* Installing(compiling) using MSYS2 and using an R-sub arcitecture
* Stored Procedures
* Inline Functions

Also, includes:

* PostgreSQL researved words are capitalized
* PLR code string delimiting method is consistent
* The Window Functions area is re-organzied and enhanced
* Re-write of obsolete LANGUAGE clause (errors are fixed)
* Indentation for easier reading

The copyright holders instructions here (link).

https://github.com/postgres-plr/plr/blob/master/userguide.md
