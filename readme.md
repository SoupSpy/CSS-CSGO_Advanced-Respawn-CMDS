# Advanced Respawn Commands (v0.1.0 - 08/29/2024)

## DESCRIPTION

This plugin contains advanced respawn commands that can be really useful in game modes like fun, public, or jailbreak.

## BUGS
None, yet.

## COMMANDS
| Name          | Type  | Help                                                                 |
|---------------|-------|----------------------------------------------------------------------|
| `sm_grespawn` | admin | Respawns the dead player(s) at the eye position of the person using the command, i.e., where they are looking. |
| `sm_hgoto`    | admin | Teleports the person using the command to the position where the player died. |
| `sm_hrespawn` | admin | Respawns the dead player(s) at the position where they died.          |
| `sm_respawn`  | admin | Respawns the dead player(s).                                         |

## USAGE
```ini
[SM] Usage: sm_hrespawn <name|userid> [Players must be dead]
[SM] Usage: sm_grespawn <name|userid> <freeze 1|0> <freeze time != 0>
[SM] Usage: sm_respawn <name|userid>]
[SM] Usage: sm_hgoto <name|userid> [Player must be dead]
```

## CVARS
```c
// Enables or Disables the plugin itself.
// -
// Default: "1"
// Minimum: "0.000000"
// Maximum: "1.000000"
sm_vxrespawn_enable "1"

// Enter the command line required to trigger the freeze plugin on your server; 
// if there isn't one, leave it blank. Leaving it blank will disable the freeze arguments in the Grespawn command.
// -
// Default: "sm_freeze"
sm_vxrespawn_freezecmd "sm_freeze"

// Enables or Disables the Grespawn command.
// -
// Default: "1"
// Minimum: "0.000000"
// Maximum: "1.000000"
sm_vxrespawn_grespawn "1"

// Enables or Disables the regular respawn command.
// -
// Default: "1"
// Minimum: "0.000000"
// Maximum: "1.000000"
sm_vxrespawn_respawn "1"
```

## PHRASES
```c
"Phrases"
{
	"prefix"
	{
		"en"	"{darkred}[ {olive}VortéX Respawn {darkred}]{default}"
		"tr"	"{darkred}[ {olive}VortéX Respawn {darkred}]{default}"
	}
	"checkConsole"
	{
		"en"	"Check console for more info!"
		"tr"	"Daha fazla bilgi için console bakın!"
	}
	"respawned"
	{
		"#format"	"{1:s}"
		"en"	"Respawned player {1}"
		"tr"	"Oyuncu {1} yeniden canlandırıldı"
	}
	"disabled"
	{
		"en"	"This plugin is disabled."
		"tr"	"Bu eklenti devredışı."
	}
	"disabledCmd"
	{
		"en"	"This command is disabled."
		"tr"	"Bu komut devredışı."
	}
	"eye angle pos"
	{
		"#format"	"{1:s}"
		"en"	"Respawned player {1} at your eye angle,"
		"tr"	"Oyuncu {1} gözünüzle baktığınız yerde yeniden canlandırıldı,"
	}
	"freeze"
	{
		"#format"	"{1:s},{2:d}"
		"en"	"Froze player {1} for {2} seconds at"
		"tr"	"Şu konumda oyuncu {1} {2} saniyeliğine donduruldu"
	}
	"tp to corpse failed"
	{
		"#format"	"{1:s}"
		"en"	"Could not find player {1}'s corpse position!"
		"tr"	"Oyuncu {1} cesetinin bulunduğu pozisyonu bulamadım!"
	}
	"tp to corpse failed chat"
	{
		"#format"	"{1:s}"
		"en"	"Could not find player {grey}{1}{default}'s corpse position!"
		"tr"	"Oyuncu {grey}{1}{default} cesetinin bulunduğu pozisyonu bulamadım!"
	}
	"hrespawn"
	{
		"#format"	"{1:s}"
		"en"	"Respawned player {1} at"
		"tr"	"Oyuncu {1} şu pozisyonda yeniden canlandırıldı"
	}
	"tp to corpse"
	{
		"#format"	"{1:s}"
		"en"	"Teleported to {grey}{1}{default}'s corpse position:"
		"tr"	"Oyuncu {grey}{1}{default}'nun cesetinin bulunduğu yere ışınlandınız:"
	}
}
```

## If you have any suggestions for additions to the plugin, you can either edit the plugin yourself or let me know in the comments section. If you encounter any issues with the plugin and would like me to fix them, please feel free to let me know.
