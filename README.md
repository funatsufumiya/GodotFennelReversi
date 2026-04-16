# GodotFennelReversi

<img src="icon.png" width="64px" height="64px" style="image-rendering: pixelated;">

***WORK-IN-PROGRESS !!***
<br>(Current status: showing hello world from fennel, basic 3d template)

Reversi game made with Godot 4.6 and [Fennel](https://fennel-lang.org/) language (Lisp on LuaJIT).

Created for Spring Lisp Game Jam 2026 https://itch.io/jam/spring-lisp-game-jam-2026

## Git submodule

Some resources may be managed by git submodule.

```bash
$ git submodule update --init --recursive --jobs 8
```

## Godot addon management

Using [godotenv](https://github.com/chickensoft-games/GodotEnv).

Please install dotnet command by `winget install Microsoft.DotNet.SDK.10` or something. (If mac, please use microsoft dotnet installer or something.)

```bash
# be sure to install godotenv command first
$ dotnet tool install --global Chickensoft.GodotEnv

$ rm -rf .addons addons
$ godotenv addons install
```

After installing addons, godot restart may need twice (for editor script loading).

## Dev (compile fennel script)

You need to [install fennel](https://fennel-lang.org/setup#downloading-a-fennel-binary) before run.

```bash
$ make
```