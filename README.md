# GodotFennelReversi

Reversi game made with Godot 4.6 and fennel language.

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