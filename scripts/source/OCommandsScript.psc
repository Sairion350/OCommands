ScriptName OCommandsScript Extends OStimAddon 
import PapyrusUtil

; Add new commands by simply making a new event named CMD_NameOfYourCommand with argument of 1 string 

; Call things in the console like: ostim info
; args should be a csv list
; Go wild and add whatever you want here
; Hard req. for now: https://www.nexusmods.com/skyrimspecialedition/mods/52964


Event CMD_Help(string args)
	Console("Check OCommandsScript for all commands")
EndEvent

Event CMD_info(string args)
{Dumps a large of OStim's internal state to console}
	Console("   ___     _   _           ")
	Console("  /___\\___| |_(_)_ __ ___  ")
	Console(" //  // __| __| | '_ ` _ \\ ")
	Console("/ \\_//\\__ \\ |_| | | | | | |")
	Console("\\___/ |___/\\__|_|_| |_| |_|")
	Console(">")
	Console(">	API Version: " + ostim.GetAPIVersion())
	Console(">")
	Console(">")
	Console(">")
	Console(">	Running: " + ostim.AnimationRunning())
	Console(">	Aggressive: " + ostim.IsSceneAggressiveThemed())
	Console(">	Aggressor: " + ostim.GetAggressiveActor().GetDisplayName() + " (" + ostim.GetAggressiveActor() + ")")
	Console(">")
	Console(">")
	Console(">	Dom: " + ostim.GetDomActor().GetDisplayName() + " (" + ostim.GetDomActor() + ")")
	Console(">	Sub: " + ostim.GetSubActor().GetDisplayName() + " (" + ostim.GetSubActor() + ")")
	Console(">	Third: " + ostim.GetThirdActor().GetDisplayName() + " (" + ostim.GetThirdActor() + ")")
	Console(">")
	Console(">	Sex: " + GetSexString(ostim.GetActors()))
	Console(">")
	Console(">	Excitement: " + ostim.GetActorExcitement(ostim.GetDomActor()) + " | " + ostim.GetActorExcitement(ostim.GetSubActor()) + " | " + ostim.GetActorExcitement(ostim.GetThirdActor()))
	Console(">")
	Console(">	Excitement multipliers: " + ostim.getstimmult(ostim.GetDomActor()) + " | " + ostim.getstimmult(ostim.GetSubActor()) + " | " + ostim.getstimmult(ostim.GetThirdActor()))
	Console(">")
	Console(">")
	Console(">	Using automode: " + ostim.AIRunning)
	Console(">	Active metadata: " + ostim.GetAllSceneMetadata() as string)
	Console(">")
	Console(">")
	Console(">	Current scene: " + ostim.GetCurrentAnimationSceneID())
	Console(">	Speed: " + ostim.GetCurrentAnimationSpeed() + "/" + ostim.GetCurrentAnimationMaxSpeed())
	Console(">")
	Console(">")
	Console(">	Elapsed time: " + ostim.GetTimeSinceStart())

EndEvent






















Event OnConsoleOStim(string eventName, string in, float _, Form sender)
	string[] args = StringSplit(in, " ")

	string command
	if args.Length == 1 
		command = "help" ; default to help
		args = outils.stringarray()
	elseif args.Length == 2
		command = args[1]
		args = outils.stringarray()
	else 
		command = args[1]
		args = SliceStringArray(args, 2)
	endif 

	string callback = "CMD_" + command
	RegisterForOEvent(callback)

	int me = ModEvent.Create(callback)
	
	ModEvent.PushString(me, StringJoin(args, ","))
	ModEvent.Send(me)
EndEvent




Event OnInit()
	CustomConsoleCommands.RegisterCommand("ostim")

	RegisteredEvents = OUtils.stringarray("OnConsoleOStim")
	InstallAddon("OCommands")
EndEvent

Function Console(String In) Global
	MiscUtil.PrintConsole("OCmds: " + In)
EndFunction

string Function GetSexString(actor[] acts)
	string ret = ""

	int i = 0
	int l = acts.Length
	While i < l 
		if ostim.AppearsFemale(acts[i]) && !ostim.IsFemale(acts[i])
			ret = ret + "Futa | "
		elseif ostim.AppearsFemale(acts[i])
			ret = ret + "Female | "
		elseif !ostim.AppearsFemale(acts[i])
			ret = ret + "Male | "
		else 

		endif 
	
		i += 1
	EndWhile

	return ret
EndFunction