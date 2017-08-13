if not TTTVote then
	TTTVote = {}
	file.CreateDir( "vote" )

	AddCSLuaFile("vote/shared/vote_overrides_shd.lua")
	AddCSLuaFile("vote/shared/player.lua")
	AddCSLuaFile("vote/client/cl_halos.lua")
	AddCSLuaFile("vote/client/cl_menu.lua")
	AddCSLuaFile("vote/client/cl_changelog.lua")
	AddCSLuaFile("vote/client/cl_messages.lua")
	AddCSLuaFile("vote/client/cl_deathgrip.lua")
	AddCSLuaFile("vote/cl_init.lua")
	AddCSLuaFile("vote/shared.lua")
	AddCSLuaFile("autorun/ttt_vote_autorun.lua")

	// All Files via Workshop
	resource.AddWorkshop("828347015")
	resource.AddFile("materials/vgui/ttt/icon_hunter.vmt")
	resource.AddFile("materials/vgui/ttt/sprite_hunter.vmt")
	resource.AddFile("materials/vgui/ttt/icon_jackal.vmt")
	resource.AddFile("materials/vgui/ttt/sprite_jackal.vmt")
	resource.AddFile("materials/vgui/ttt/icon_shini.vmt")
	resource.AddFile("materials/vgui/ttt/icon_side.vmt")
	resource.AddFile("materials/vgui/ttt/sprite_side.vmt")

	// Convars
	CreateConVar("ttt_startvotes","5",{FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, "Setze die Vote mit der jeder startet.")
	local totem = CreateConVar("ttt_totem","1", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, "Soll TTT Totem aktiviert sein?"):GetBool()
	local vote = CreateConVar("ttt_vote","1", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, "Soll TTT Vote aktiviert sein?"):GetBool()
	local deathgrip = CreateConVar("ttt_deathgrip","1", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, "Soll TTT Death Grip aktiviert sein?"):GetBool()

	SetGlobalBool("ttt_totem", totem)
	SetGlobalBool("ttt_vote", vote)
	SetGlobalBool("ttt_deathgrip", deathgrip)

	function TotemEnabled() return GetGlobalBool("ttt_totem", false) end

	function VoteEnabled() return GetGlobalBool("ttt_vote", false) end

	function DeathGripEnabled() return GetGlobalBool("ttt_deathgrip", false) end

	// Execute Files
	include("vote/shared/vote_overrides_shd.lua")
	include("vote/shared/player.lua")
	if VoteEnabled() then
		include("vote/server/vote.lua")
	else
		print("TTT Vote is disabled, set ttt_vote to 1 to enable!(requires restart or map change)")
	end
	if TotemEnabled() then
		include("vote/server/totem.lua")
	else
		print("TTT Totem is disabled, set ttt_totem to 1 to enable!(requires restart or map change)")
	end
	if DeathGripEnabled() then
		include("vote/server/deathgrip.lua")
	else
		print("TTT Death Grip is disabled, set ttt_deathgrip to 1 to enable!(requires restart or map change)")
	end

	// Tables and vars
	if VoteEnabled() then
		TTTVote.VoteBetters = {}
	end
	if TotemEnabled() then
		TTTVote.AnyTotems = true
	end

	// NetworkStrings
	util.AddNetworkString("ClientInitVote") --Why cant fucking Global Bools or Replicated CVars work earlier
	if VoteEnabled() then
		util.AddNetworkString("VoteChangelog")
		util.AddNetworkString("TTTVoteMenu")
		util.AddNetworkString("TTTPlacedVote")
		util.AddNetworkString("TTTVoteMessage")
		util.AddNetworkString("TTTResetVote")
		util.AddNetworkString("TTTVoteMenu")
		util.AddNetworkString("TTTVoteCurse")
		util.AddNetworkString("TTTVoteFailure")
	end

	if DeathGripEnabled() then
		util.AddNetworkString("TTTDeathGrip")
		util.AddNetworkString("TTTDeathGripReset")
		util.AddNetworkString("TTTDeathGripMessage")
		util.AddNetworkString("TTTShinigamiInfo")
		util.AddNetworkString("TTTDeathGripInfo")
	end

	if TotemEnabled() then
		util.AddNetworkString("TTTTotem")
		util.AddNetworkString("TTTVotePlaceTotem")
	end

	print("TTT Vote has been successfully loaded!")

	hook.Add("PlayerInitialSpawn", "ClientInitVote", function(ply)
		net.Start("ClientInitVote")
		net.WriteBool(VoteEnabled())
		net.WriteBool(DeathGripEnabled())
		net.WriteBool(TotemEnabled())
		net.Send(ply)
	end)
end
