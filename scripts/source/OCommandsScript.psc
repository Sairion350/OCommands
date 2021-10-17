ScriptName OCommandsScript Extends OStimAddon 
import PapyrusUtil

; Add new commands by simply making a new event named CMD_NameOfYourCommand with argument of 1 string 

; Call things in the console like: ostim info
; args should be a csv list
; Go wild and add whatever you want here
; Hard req. for now: https://www.nexusmods.com/skyrimspecialedition/mods/52964 

 ;(actra) = One of the following: dom/sub/third/player
 ; [] = optional argument

Event CMD_Help(string args)
	Console("Check OCommandsScript for all commands")
EndEvent

Event CMD_ToggleStim(string args)
	{Toggles the stimulation sim on and off}

	if ostim.DisableStimulationCalculation
		console("Stimulation is now ON")
	else 
		console("Stimulation is now OFF")
	endif 

	ostim.DisableStimulationCalculation = !ostim.DisableStimulationCalculation
EndEvent 

	Event CMD_TST(string args) ; ALIAS
		CMD_ToggleStim(args)
	EndEvent

Event CMD_SetExcMult(string args)
	{Usage - ostim SetExcMult (float) [(actra)] - Set actor's excitement multiplier to the given number. Changes the global mult instead if no actor given}

	string[] arg = StringSplit(args, ",")

	if !ostim.AnimationRunning()
		Console("No scene running")
		return 
	endif 

	float newValue = arg[0] as float  

	actor who
	if arg.Length > 1 
		who = StringToActra(arg[1])
	endif 

	if !who 
		Console("Setting GLOBAL excitement mult to " + newValue)
		ostim.SexExcitementMult = newValue
	else 
		ostim.SetStimMult(who, newValue)
		Console("Setting " + who.GetDisplayName() + " excitement mult to " + newValue)
	endif 
EndEvent 

	Event CMD_SEM(string args) ; ALIAS
		CMD_SetExcMult(args)
	EndEvent 

Event CMD_SetExc(string args)
	{Usage - ostim SetExc (float) [(actra)] - Set excitement to the given number. Defaults to player if no arg}

	string[] arg = StringSplit(args, ",")

	if !ostim.AnimationRunning()
		Console("No scene running")
		return 
	endif 

	float newValue = arg[0] as float  

	actor who
	if arg.Length > 1 
		who = StringToActra(arg[1])
	endif 

	if !who 
		who = PlayerRef
	endif 

	ostim.SetActorExcitement(who, newValue)

	Console("Setting " + who.GetDisplayName() + " excitement to " + newValue)
EndEvent 

	Event CMD_SEC(string args) ; ALIAS
		CMD_SetExc(args)
	EndEvent

Event CMD_Restart(string args)
	{Restart the current OStim scene. If none is running, starts the last one again}
	string[] arg = StringSplit(args, ",")

	if ostim.AnimationRunning()
		ostim.EndAnimation(false)
		while ostim.AnimationRunning()
			Utility.waitmenumode(0.01)
		endwhile 
	endif 

	actor[] people = ostim.GetActors()
	while people.Length < 3 
		people = PushActor(people, none)
	endwhile 


	ostim.startscene(people[0], people[1], zthirdactor=people[2])
EndEvent 


Event CMD_Orgasm(string args)
	{Usage - ostim qstart [(actra)] - Orgasm. Defaults to Dom if no arg}
	string[] arg = StringSplit(args, ",")

	if !ostim.AnimationRunning()
		Console("No scene running")
		return 
	endif 

	actor who = StringToActra(arg[0])

	if !who 
		if ostim.IsPlayerInvolved()
			who = ostim.GetDomActor()
		else 
			Console("Error: cannot default orgasm to player because player is not involved")
			Return
		endif 
	endif 

	ostim.SetActorExcitement(who, 110.0)

	Console("Making " + who.GetDisplayName() + " orgasm")
EndEvent

Event CMD_QStart(string args)
	{Usage - ostim qstart [m/f/npc] - spawn a copy of a male or female char and start a scene with them, or start an npc on npc scene}
	string[] arg = StringSplit(args, ",")

	int female = 0x1A69A ;ysolda 
	int male = 0x1A6A4 ; nazeem

	int with = female 

	if arg[0] == "m" 
		with = male 
	elseif arg[0] == "f"
		with = female 
	elseif arg[0] == "npc"
		actor a  = PlayerRef.PlaceActorAtMe(outils.GetNPC(male).GetLeveledActorBase())
		actor b  = PlayerRef.PlaceActorAtMe(outils.GetNPC(female).GetLeveledActorBase())

		while !a.Is3DLoaded()
			Utility.Wait(0.5)
		EndWhile
		ostim.startscene(a, b)
		return 
	endif 

	actor spawned = PlayerRef.PlaceActorAtMe(outils.GetNPC(with).GetLeveledActorBase())

	ostim.startscene(playerref, spawned )
EndEvent

Event CMD_stop(string args)
	ostim.EndAnimation(false)
EndEvent 

Event CMD_subinfo(string args)

	int i = 0
	int max = ostim.subthreadquest.GetNumAliases()
	while i < max 
		OStimSubthread thread = ostim.subthreadquest.GetNthAlias(i) as OStimSubthread

		Console(">  Subthread: " + i)

		if !thread.IsInUse()
			Console(">    In use: False")
		else 
			Console(">    In use: True")
			Console(">    Linked to main: " + thread.LinkedToMain)
			Console(">")
			Console(">")
			Console(">    Dom: " + thread.domactor.GetDisplayName() + " (" + thread.domactor + ")")
			Console(">	  Sub: " + thread.subactor.GetDisplayName() + " (" + thread.subactor + ")")
			Console(">	  Third: " + thread.thirdactor.GetDisplayName() + " (" + thread.thirdactor + ")")
			Console(">")
			Console(">")
			Console(">	  Speed: " + thread.currspeed + "/" + thread.maxspeed)
			Console(">")
			Console(">	  Time per speed: " + thread.timeperspeed)
		endif 

		Console(">-----------------")

		i += 1
	endwhile
EndEvent 

Event CMD_info(string args)
{Dumps a large amount of OStim's internal state to console}
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
	Console(">	Main Excitement mult: " + ostim.SexExcitementMult)
	Console(">	Aggressive: " + ostim.IsSceneAggressiveThemed())
	Console(">	Aggressor: " + ostim.GetAggressiveActor().GetDisplayName() + " (" + ostim.GetAggressiveActor() + ")")
	Console(">")
	Console(">")
	Console(">	Dom: " + ostim.GetDomActor().GetDisplayName() + " (" + ostim.GetDomActor() + ")")
	Console(">	Sub: " + ostim.GetSubActor().GetDisplayName() + " (" + ostim.GetSubActor() + ")")
	Console(">	Third: " + ostim.GetThirdActor().GetDisplayName() + " (" + ostim.GetThirdActor() + ")")
	Console(">")
	Console(">")
	Console(">	Sexes: " + GetSexString(ostim.GetActors()))
	Console(">")
	Console(">")
	If (OStim.TossClothesOntoGround)
		Console(">	Stored Dom clothes: " + ostim.GetUndressScript().DomEquipmentDrops as string )
	else 
		Console(">	Stored Dom clothes: " + ostim.GetUndressScript().DomEquipmentForms as string )
	endif 
	If (OStim.TossClothesOntoGround)
		Console(">	Stored Sub clothes: " + ostim.GetUndressScript().SubEquipmentDrops as string )
	else 
		Console(">	Stored Sub clothes: " + ostim.GetUndressScript().SubEquipmentForms as string )
	endif 
	If (OStim.TossClothesOntoGround)
		Console(">	Stored Third clothes: " + ostim.GetUndressScript().ThirdEquipmentDrops as string )
	else 
		Console(">	Stored Third clothes: " + ostim.GetUndressScript().ThirdEquipmentForms as string )
	endif 
	Console(">")
	Console(">")
	Console(">	Excitement: " + ostim.GetActorExcitement(ostim.GetDomActor()) + " | " + ostim.GetActorExcitement(ostim.GetSubActor()) + " | " + ostim.GetActorExcitement(ostim.GetThirdActor()))
	Console(">")
	Console(">	Excitement multipliers: " + ostim.getstimmult(ostim.GetDomActor()) + " | " + ostim.getstimmult(ostim.GetSubActor()) + " | " + ostim.getstimmult(ostim.GetThirdActor()))
	Console(">")
	Console(">	Current stimulation/sec: " + ostim.GetCurrentStimulation(ostim.GetDomActor()) * ostim.GetStimMult(ostim.GetDomActor()) + " | " + ostim.GetCurrentStimulation(ostim.GetSubActor()) * ostim.GetStimMult(ostim.GetSubActor()) + " | " + ostim.GetCurrentStimulation(ostim.GetThirdActor()) * ostim.GetStimMult(ostim.GetThirdActor()) )
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

actor Function StringToActra(string in)
	if in == "dom" 
		return ostim.GetDomActor()
	elseif in == "sub"
		return ostim.GetSubActor()
	elseif in == "third"
		return ostim.GetThirdActor()
	elseif in == "player"
		return playerref
	else 
		return none
	endif 


EndFunction