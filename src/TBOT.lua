--[[

	Universal Triggerbot Module (TBOT) by Nxyzen © CC0 1.0 Universal (2026)

	https://github.com/uchihaweplay-gif/TBOT

]]

--// Luraph Macros

if LPH_OBFUSCATED == nil then
	LPH_NO_VIRTUALIZE = function(...)
		return ...
	end
end

--// Cache

local game, workspace = game, workspace
local getrawmetatable, pcall, next, tick, getgenv = getrawmetatable, pcall, next, tick, getgenv
local Vector2new, Vector3zero, CFramenew = Vector2.new, Vector3.zero, CFrame.new
local Color3fromRGB, Color3fromHSV = Color3.fromRGB, Color3.fromHSV
local Drawingnew = Drawing and Drawing.new
local tablefind, tableremove = table.find, table.remove
local stringlower, stringsub = string.lower, string.sub
local mouse1press, mouse1release, taskwait = mouse1press, mouse1release, task.wait
local clonefunction, cloneref = clonefunction or LPH_NO_VIRTUALIZE(function(...)
	return ...
end), cloneref or LPH_NO_VIRTUALIZE(function(...)
	return ...
end)

local GameMetatable = getrawmetatable and getrawmetatable(game) or {
	__index = LPH_NO_VIRTUALIZE(function(self, Index)
		return self[Index]
	end),

	__newindex = LPH_NO_VIRTUALIZE(function(self, Index, Value)
		self[Index] = Value
	end)
}

local __index = GameMetatable.__index
local __newindex = GameMetatable.__newindex

local _GetService = __index(game, "GetService")
local GetService = function(Service)
	return cloneref(_GetService(game, Service))
end

--// Services

local RunService = GetService("RunService")
local UserInputService = GetService("UserInputService")
local Players = GetService("Players")

--// Service Methods

local LocalPlayer = __index(Players, "LocalPlayer")
local Camera = __index(workspace, "CurrentCamera")

local FindFirstChild, FindFirstChildOfClass = __index(game, "FindFirstChild"), __index(game, "FindFirstChildOfClass")
local GetDescendants = __index(game, "GetDescendants")
local WorldToViewportPoint = __index(Camera, "WorldToViewportPoint")
local GetPartsObscuringTarget = __index(Camera, "GetPartsObscuringTarget")
local GetMouseLocation = __index(UserInputService, "GetMouseLocation")
local GetPlayers = __index(Players, "GetPlayers")
local GetPlayerFromCharacter = __index(Players, "GetPlayerFromCharacter")
local Mouse = __index(LocalPlayer, "GetMouse")(LocalPlayer)

--// Variables

local Typing, Running, ServiceConnections = false, false, {}

local Connect, Disconnect = __index(game, "DescendantAdded").Connect

do
	local TemporaryConnection = Connect(__index(game, "DescendantAdded"), function() end)
	Disconnect = TemporaryConnection.Disconnect
	Disconnect(TemporaryConnection)
end

--// Environment

getgenv().TBOT = {
	DeveloperSettings = {
		UpdateMode = "RenderStepped",
		TeamCheckOption = "TeamColor",
		DisableWarnings = false
	},

	Settings = {
		Enabled = true,

		TeamCheck = true,
		AliveCheck = true,
		WallCheck = true,

		Delay = 0,

		TriggerKey = Enum.UserInputType.MouseButton2,
		Toggle = false
	},

	Blacklisted = {}
}

local Environment, _warn = getgenv().TBOT, clonefunction(warn)
warn = function(...)
	return not Environment.DeveloperSettings.DisableWarnings and _warn(...)
end

repeat
	taskwait(0)
until Environment

--// Core Functions

local FixUsername = LPH_NO_VIRTUALIZE(function(String)
	for _, Value in next, GetPlayers(Players) do
		local Name = __index(Value, "Name")

		if stringsub(stringlower(Name), 1, #String) == stringlower(String) then
			return Name
		end
	end
end)

local CancelTrigger = LPH_NO_VIRTUALIZE(function()
	Running = false
end)

local CheckTarget = LPH_NO_VIRTUALIZE(function(Character)
	if not Character then return false end
	
	local Settings = Environment.Settings
	local DeveloperSettings = Environment.DeveloperSettings
	local TeamCheckOption = DeveloperSettings.TeamCheckOption
	local Humanoid = FindFirstChildOfClass(Character, "Humanoid")
	local Player = GetPlayerFromCharacter(Players, Character)

	if not Humanoid or not Player then
		return false
	end

	-- Alive Check
	if Settings.AliveCheck and __index(Humanoid, "Health") <= 0 then
		return false
	end

	-- Team Check
	if Settings.TeamCheck and __index(Player, TeamCheckOption) == __index(LocalPlayer, TeamCheckOption) then
		return false
	end

	-- Blacklist Check
	if tablefind(Environment.Blacklisted, __index(Player, "Name")) then
		return false
	end

	-- Wall Check
	if Settings.WallCheck then
		local TargetPosition = __index(Character, "Position")
		local BlacklistTable = {}
		
		if LocalPlayer.Character then
			for _, part in next, GetDescendants(LocalPlayer.Character) do
				BlacklistTable[#BlacklistTable + 1] = part
			end
		end

		for _, _Value in next, GetDescendants(Character) do
			BlacklistTable[#BlacklistTable + 1] = _Value
		end

		if #GetPartsObscuringTarget(Camera, {TargetPosition}, BlacklistTable) > 0 then
			return false
		end
	end

	return true
end)

local Load = function()
	local Settings = Environment.Settings
	local DeveloperSettings = Environment.DeveloperSettings
	local UpdateMode = DeveloperSettings.UpdateMode

	if mouse1press and mouse1release then
		ServiceConnections.TriggerBot = Connect(__index(RunService, UpdateMode), LPH_NO_VIRTUALIZE(function()
			if Settings.Enabled and Mouse.Target and Running then
				local Character = Mouse.Target.Parent

				if CheckTarget(Character) then
					if Settings.Delay ~= 0 then
						taskwait(Settings.Delay)
					end

					mouse1press()
					taskwait(0)
					mouse1release()
				end
			end
		end))
	end
end

--// Typing Check

ServiceConnections.TypingStartedConnection = Connect(__index(UserInputService, "TextBoxFocused"), function()
	Typing = true
end)

ServiceConnections.TypingEndedConnection = Connect(__index(UserInputService, "TextBoxFocusReleased"), function()
	Typing = false
end)

--// Input Handler

ServiceConnections.InputBeganConnection = Connect(__index(UserInputService, "InputBegan"), LPH_NO_VIRTUALIZE(function(Input)
	if Typing then
		return
	end

	local TriggerKey, Toggle = Environment.Settings.TriggerKey, Environment.Settings.Toggle

	if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == TriggerKey or Input.UserInputType == TriggerKey then
		if Toggle then
			Running = not Running
		else
			Running = true
		end
	end
end))

ServiceConnections.InputEndedConnection = Connect(__index(UserInputService, "InputEnded"), LPH_NO_VIRTUALIZE(function(Input)
	if Typing then
		return
	end

	local TriggerKey = Environment.Settings.TriggerKey

	if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == TriggerKey or Input.UserInputType == TriggerKey then
		CancelTrigger()
	end
end))

--// Initialize

repeat
	taskwait(0)
until Environment and Load

Load()

Environment.Exit = LPH_NO_VIRTUALIZE(function(self)
	assert(self, "TBOT.Exit: Missing parameter #1 \"self\" <table>.")

	for Index, _ in next, ServiceConnections do
		pcall(Disconnect, ServiceConnections[Index])
	end

	Load = nil
	CheckTarget = nil
	CancelTrigger = nil
	FixUsername = nil

	getgenv().TBOT = nil
	pcall(collectgarbage, "step", 200)
end)

Environment.Restart = LPH_NO_VIRTUALIZE(function()
	for Index, _ in next, ServiceConnections do
		pcall(Disconnect, ServiceConnections[Index])
	end

	Load()
end)

Environment.Blacklist = LPH_NO_VIRTUALIZE(function(self, Username)
	assert(self, "TBOT.Blacklist: Missing parameter #1 \"self\" <table>.")
	assert(Username, "TBOT.Blacklist: Missing parameter #2 \"Username\" <string>.")

	Username = FixUsername(Username)

	assert(Username, "TBOT.Blacklist: User "..Username.." couldn't be found.")

	self.Blacklisted[#self.Blacklisted + 1] = Username
end)

Environment.Whitelist = LPH_NO_VIRTUALIZE(function(self, Username)
	assert(self, "TBOT.Whitelist: Missing parameter #1 \"self\" <table>.")
	assert(Username, "TBOT.Whitelist: Missing parameter #2 \"Username\" <string>.")

	Username = FixUsername(Username)

	assert(Username, "TBOT.Whitelist: User "..Username.." couldn't be found.")

	local Index = tablefind(self.Blacklisted, Username)

	assert(Index, "TBOT.Whitelist: User "..Username.." is not blacklisted.")

	tableremove(self.Blacklisted, Index)
end)

Environment.Load = Load

setmetatable(Environment, {__call = Load})

return Environment
