local Profile = {}

Profile.Settings = {
    {
        ["Setting"] = "AOE",
        ["Options"] = {
            { ["Name"] = "AOE", ["Tooltip"] = "AOE ON", ["Colour"] = { ["r"] = 0, ["g"] = 1, ["b"] = 0, ["a"] = 1 }, },
            { ["Name"] = "AOE", ["Tooltip"] = "AOE OFF", ["Colour"] = { ["r"] = 1, ["g"] = 0, ["b"] = 0, ["a"] = 1 }, },
        },
    },
    {
        ["Setting"] = "Debuffs",
        ["Options"] = {
            { ["Name"] = "Debuffs", ["Tooltip"] = "Debuffs ON", ["Colour"] = { ["r"] = 0, ["g"] = 1, ["b"] = 0, ["a"] = 1 }, },
            { ["Name"] = "Debuffs", ["Tooltip"] = "Debuffs OFF", ["Colour"] = { ["r"] = 1, ["g"] = 0, ["b"] = 0, ["a"] = 1 }, },
        },
    },
    {
        ["Setting"] = "CDs",
        ["Options"] = {
            { ["Name"] = "CDs", ["Tooltip"] = "CDs ON", ["Colour"] = { ["r"] = 0, ["g"] = 1, ["b"] = 0, ["a"] = 1 }, },
            { ["Name"] = "CDs", ["Tooltip"] = "CDs OFF", ["Colour"] = { ["r"] = 1, ["g"] = 0, ["b"] = 0, ["a"] = 1 }, },
        },
    },
    {
        ["Setting"] = "MudraType",
        ["Options"] = {
            { ["Name"] = "Raiton", ["Tooltip"] = "Raiton", ["Colour"] = { ["r"] = 0, ["g"] = 1, ["b"] = 0, ["a"] = 1 }, },
            { ["Name"] = "Fuma", ["Tooltip"] = "Fuma", ["Colour"] = { ["r"] = 1, ["g"] = 0, ["b"] = 0, ["a"] = 1 }, },
            { ["Name"] = "Hyoton", ["Tooltip"] = "Hyoton", ["Colour"] = { ["r"] = 0, ["g"] = 0, ["b"] = 1, ["a"] = 1 }, },
        },
    },
    {
        ["Setting"] = "MudraType2",
        ["Options"] = {
            { ["Name"] = "Doton OFF", ["Tooltip"] = "Doton OFF", ["Colour"] = { ["r"] = 1, ["g"] = 0, ["b"] = 0, ["a"] = 1 }, },
            { ["Name"] = "Doton ON", ["Tooltip"] = "Doton ON", ["Colour"] = { ["r"] = 0, ["g"] = 1, ["b"] = 0, ["a"] = 1 }, },
        },
    },
}

function Profile:SkillTable(Data,Target,ClassTypeID)
	self.SendConsoleMessage(ClassTypeID.."PROFILE",1)

    local PlayerPOS = Data.PlayerPOS
    local TargetPOS = Data.TargetPOS
    local TargetCastingInterruptible = Data.TargetCastingInterruptible
    local PlayerMoving = Data.PlayerMoving
    local PlayerInCombat = Data.PlayerInCombat
    local PlayerID = Data.PlayerID
    local TargetID = Data.TargetID
    local TargetDistance = Data.TargetDistance
    local TargetHP = Data.TargetHP
    local PlayerHP = Data.PlayerHP
    local PartySize = Data.PartySize
    local PlayerLevel = Data.PlayerLevel
    local CastingInfo = Data.CastingInfo
    local CurrentCast = Data.CurrentCast
    local LastCast = Data.LastCast
    local LastCastTime = Data.LastCastTime
    local LastCombo = Data.LastCombo
    local CurrentChannel = Data.CurrentChannel
    local GaugeData1 = Data.GaugeData1
    local GaugeData2 = Data.GaugeData2
    local AOETimeout = Data.AOETimeout
    local JumpTimeout = Data.JumpTimeout
    local CastTimeout = Data.CastTimeout

	
    local HasDotonBuff = self.TargetBuff2(Player,497,0,"Has",PlayerID)
	local HasMudraBuff = self.TargetBuff2(Player,{496,497},0,"Has",PlayerID)
	local HasSuitonBuff = self.TargetBuff2(Player,507,0,"Has",PlayerID)
	local HasKassatsuBuff = self.TargetBuff2(Player,501,0,"Has",PlayerID)
	local HasTenChiJinBuff = self.TargetBuff2(Player,1186,0,"Has",PlayerID)
	local HasMeisuiBuff = self.TargetBuff2(Player,2689,0,"Has",PlayerID)

	local HasActiveMudraSkill = ActionList:Get(1,2265):CanCastResult() ~= 572

	for i,e in pairs(Player.buffs) do
		local BuffID = e.id
		if e.ownerid == PlayerID then
			if BuffID == 497 then HasKassatsuBuff = true end
			if BuffID == 496 or BuffID == 497 then HasMudraBuff = true end
			if BuffID == 507 then HasSuitonBuff = true end
			if BuffID == 501 then HasDotonBuff = true end
			if BuffID == 1186 then HasTenChiJinBuff = true end
			if BuffID == 2689 then HasMeisuiBuff = true end
		end
	end

	--d("Ten Chi Jin - HasTenChiJinBuff: "..tostring(HasTenChiJinBuff))
	local TargetHasTrickAttack = 0
	local AttackableTarget = false
	if table.valid(Target) == true then
		AttackableTarget = Target.attackable
		PlayerID = Player.id
		TargetID = Target.id
		TargetDistance = Target.distance2d
		TargetHP = Target.hp.percent
		for i,e in pairs(Target.buffs) do
			local BuffID = e.id
			if e.ownerid == PlayerID then
				if BuffID == 3254 then TargetHasTrickAttack = e.duration end
				if BuffID == 638 then TargetHasTrickAttack = e.duration end
			end
		end
	end

	local MudraActions = {
		[2259] = "Ten",
		[2261] = "Chi",
		[2263] = "Jin",
		[18805] = "Ten",
		[18806] = "Chi",
		[18807] = "Jin",
		[2264] = "Kassatsu",
		[7403] = "Ten Chi Jin",
		[18873] = "Fuma",
		[18877] = "Raiton",
		[18881] = "Suiton",
	}

	local LastActionWasMudra = MudraActions[CurrentCast] ~= nil or MudraActions[LastCast] ~= nil

	--d("HasActiveMudraSkill: "..tostring(HasActiveMudraSkill))
	--d("HasMudraBuff: "..tostring(HasMudraBuff))
	--d("HasKassatsuBuff: "..tostring(HasKassatsuBuff))
	--d("LastActionWasMudra: "..tostring(LastActionWasMudra))
	--d("LastCastTime: "..LastCastTime)
	if HasMudraBuff == false and HasKassatsuBuff == false and (LastActionWasMudra == false or LastCastTime > 500) then 
		--d("---------------------- RESET 1")
		self.NinjaLastMudra = 0 
		LastActionWasMudra = false 
	end

	if HasMudraBuff == true and LastActionWasMudra == true and (LastCastTime > 5000 or (LastCastTime > 1500 and HasActiveMudraSkill)) then 
		--d("---------------------- RESET 2")
		self.NinjaLastMudra = 0 
		LastActionWasMudra = false 
	end

	local TrickAttack = ActionList:Get(1,2258)
	if self.NinjaLastMudra == 2 and TrickAttack.cd + 5 < TrickAttack.cdmax then
		self.NinjaLastMudra = 0
		--d("Trick Mudra Clear")
	end


	local Kassatsu = ActionList:Get(1,2264)
	local Ten = ActionList:Get(1,2259)
	local MudraCurrentCharges = math.floor((Ten.cdmax /Ten.recasttime) - ((Ten.cdmax - Ten.cd) / Ten.recasttime))
	if Ten.isoncd == false or HasMudraBuff == true or HasKassatsuBuff == true then MudraCurrentCharges = 1 end

	if self.NinjaLastMudra == 0 then
		--local MudraCharges = ActionList:Get(1,2259).charges

		--d("MudraCurrentCharges: "..tostring(MudraCurrentCharges))
		local AOEType = { ["Filter"] = "Enemy", ["Name"] = "Circle", ["TargetPoint"] = PlayerPOS, ["AOERange"] = 5, ["MaxDistance"] = 0, ["LineWidth"] = 0, ["Angle"] = 0, }
		local EnemiesAroundSelf = self.EntityInCount(AOEType)

		local EnemiesAroundTarget = 0
		if table.valid(Target) == true then
			--d("Valid Target")
			--d(Target)
			--d(Target.name)
			local AOEType2 = { ["Filter"] = "Enemy", ["Name"] = "Circle", ["TargetPoint"] = TargetPOS, ["AOERange"] = 5, ["MaxDistance"] = 20, ["LineWidth"] = 0, ["Angle"] = 0, }
			EnemiesAroundTarget = self.EntityInCount(AOEType2)
		end

		--d("EnemiesAroundSelf: "..tostring(EnemiesAroundSelf))
		--d("EnemiesAroundTarget: "..tostring(EnemiesAroundTarget))


		--d("TrickAttack.cd: "..TrickAttack.cd)
		--d("TrickAttack.cdmax: "..TrickAttack.cdmax)

		--d("PlayerLevel: "..tostring(PlayerLevel >= 32))
		--d("AttackableTarget: "..tostring(AttackableTarget))
		--d("HasSuitonBuff: "..tostring(HasSuitonBuff))
		--d("TrickAttack1: "..tostring(TrickAttack.cd ~= 0))
		--d("TrickAttack2: "..tostring(TrickAttack.cd + 10 < TrickAttack.cdmax))
		--d("MudraType: "..tostring(self.GetSettingsValue(ClassTypeID,"MudraType") == 1))

		local GeneralCheck = HasSuitonBuff == false and MudraCurrentCharges > 0 and TrickAttack.cd ~= 0 and TrickAttack.cd + 10 < TrickAttack.cdmax
		if PlayerLevel >= 45 and GaugeData1[2] == 0 and MudraCurrentCharges > 0 then
			self.NinjaLastMudra = 1
		elseif PlayerLevel >= 45 and AttackableTarget == true and HasSuitonBuff == false and TrickAttack.cd + 2 > TrickAttack.cdmax and MudraCurrentCharges > 0 then
			self.NinjaLastMudra = 2
		elseif PlayerLevel >= 35 and EnemiesAroundSelf > 2 and (PlayerLevel < 76 or HasKassatsuBuff == false) and HasDotonBuff == false and PlayerMoving == false and GeneralCheck == true and self.GetSettingsValue(ClassTypeID,"AOE") == 1 and AOETimeout == false and self.GetSettingsValue(ClassTypeID,"MudraType2") == 2 then
			self.NinjaLastMudra = 6
		elseif PlayerLevel >= 35 and AttackableTarget == true and EnemiesAroundTarget > 2 and GeneralCheck == true and self.GetSettingsValue(ClassTypeID,"AOE") == 1 and AOETimeout == false and self.GetSettingsValue(ClassTypeID,"AOE") == 1 and AOETimeout == false then
			self.NinjaLastMudra = 5
		elseif PlayerLevel >= 32 and (PlayerLevel < 76 or HasKassatsuBuff == false) and AttackableTarget == true and GeneralCheck == true and self.GetSettingsValue(ClassTypeID,"MudraType") == 1 then
			self.NinjaLastMudra = 3
		elseif PlayerLevel >= 30 and (PlayerLevel < 76 or HasKassatsuBuff == false) and AttackableTarget == true and GeneralCheck == true and self.GetSettingsValue(ClassTypeID,"MudraType") == 2 then
			self.NinjaLastMudra = 4
		elseif PlayerLevel >= 45 and AttackableTarget == true and GeneralCheck == true and ((PlayerLevel >= 76 and HasKassatsuBuff == true) or self.GetSettingsValue(ClassTypeID,"MudraType") == 3) then
			self.NinjaLastMudra = 7
		end
	end

	--d("self.NinjaLastMudra: "..tostring(self.NinjaLastMudra))




	-- Ten 2259, Chi 2261, Jin 2263
	-- Ten 18805, Chi 18806, Jin 18807

	-- Huton
	-- Jin > Chi > Ten - 2263 > 18806 > 18805
	-- Chi > Jin > Ten - 2261 > 18807 > 18805

	-- Suiton
	-- Ten > Chi > Jin - 2259 > 18806 > 18807
	-- Chi > Ten > Jin - 2261 > 18805 > 18807


	-- Doton
	-- Ten > Jin > Chi -
	-- Jin > Ten > Chi -

	-- Raiton
	-- Ten > Chi - 2259 > 18805
	-- Jin > Chi - 2263 > 18805
	--d(" ------------------ ")
	--d("self.NinjaLastMudra: "..tostring(self.NinjaLastMudra))
	--d("LastActionWasMudra: "..tostring(LastActionWasMudra))
	--d(" ------------------ ")
	self.SendConsoleMessage("NinjaLastMudra: "..self.NinjaLastMudra,3)
	self.SendConsoleMessage("LastActionWasMudra: "..tostring(LastActionWasMudra),3)
	
	local SkillList = {
		{
			["Type"] = 2, ["Name"] = "Kassatsu", ["ID"] = 2264, ["Range"] = 0, ["TargetCast"] = false, --["SettingValue"] = self.GetSettingsValue(ClassTypeID,"AOE") == 1 and AOETimeout == false,
			["LastCastIDMust"] = { [2258] = true, },
		},
		{
			["Type"] = 2, ["Name"] = "Ten Chi Jin", ["ID"] = 7403, ["Range"] = 0, ["TargetCast"] = false, ["OtherCheck"] = HasKassatsuBuff == false and MudraCurrentCharges == 0 and TrickAttack.isoncd == true and Kassatsu.isoncd == true and TrickAttack.cd < 30 and Kassatsu.cd < 30, ["LastActionTimeout"] = "NinjaMudra", ["LastActionTime"] = 0,
		},
		{
			["Type"] = 2, ["Name"] = "Meisui", ["ID"] = 16489, ["Range"] = 0, ["TargetCast"] = false, ["OtherCheck"] = HasSuitonBuff == true and TrickAttack.isoncd == true and Kassatsu.isoncd == true and TrickAttack.cd < 30 and Kassatsu.cd < 30, ["LastActionTimeout"] = "NinjaMudra", ["LastActionTime"] = 0,
		},

		{ -- Huton
			["Type"] = 2, ["Name"] = "Huton", ["ID"] = 2269, ["Range"] = 0, ["TargetCast"] = false,
			["LastCastID"] = { [18805] = true, }, ["OtherCheck"] = self.NinjaLastMudra == 1 and GaugeData1[2] == 0, ["Buff"] = HasMudraBuff == true,
		},
		{ -- Huton - Starter
			["Type"] = 2, ["Name"] = "Huton - Jin", ["ID"] = 2263, ["Range"] = 0, ["TargetCast"] = false,
			["LastCastIDNOT"] = { [2263] = true, [18806] = true, [18805] = true }, ["OtherCheck"] = self.NinjaLastMudra == 1 and GaugeData1[2] == 0, ["Buff"] = HasMudraBuff == false, ["LastActionTimeout"] = "NinjaMudra", ["LastActionTime"] = 0,
		},
		{ -- Huton - 2nd Filler
			["Type"] = 2, ["Name"] = "Huton - Jin", ["ID"] = 18807, ["Range"] = 0, ["TargetCast"] = false,
			["LastCastID"] = { [2261] = true, }, ["OtherCheck"] = self.NinjaLastMudra == 1 and GaugeData1[2] == 0, ["Buff"] = HasMudraBuff == true, ["LastActionTimeout"] = "NinjaMudra", ["LastActionTime"] = 0,
		},
		{ -- Huton - 2nd
			["Type"] = 2, ["Name"] = "Huton - Chi", ["ID"] = 18806, ["Range"] = 0, ["TargetCast"] = false,
			["LastCastID"] = { [2263] = true, }, ["OtherCheck"] = self.NinjaLastMudra == 1 and GaugeData1[2] == 0, ["Buff"] = HasMudraBuff == true, ["LastActionTimeout"] = "NinjaMudra", ["LastActionTime"] = 0,
		},
		{ -- Huton - Finish
			["Type"] = 2, ["Name"] = "Huton - Ten", ["ID"] = 18805, ["Range"] = 0, ["TargetCast"] = false,
			["LastCastID"] = { [18806] = true, [18807] = true, }, ["OtherCheck"] = self.NinjaLastMudra == 1 and GaugeData1[2] == 0, ["Buff"] = HasMudraBuff == true, ["LastActionTimeout"] = "NinjaMudra", ["LastActionTime"] = 0,
		},

		{ -- Doton
			["Type"] = 2, ["Name"] = "Doton", ["ID"] = 2270, ["Range"] = 0, ["TargetCast"] = false,
			["LastCastID"] = { [18806] = true, }, ["OtherCheck"] = self.NinjaLastMudra == 6, ["Buff"] = HasMudraBuff == true,
		},
		{ -- Doton - Starter
			["Type"] = 2, ["Name"] = "Doton - Ten", ["ID"] = 2259, ["Range"] = 0, ["TargetCast"] = false,
			["LastCastIDNOT"] = { [2259] = true, [18805] = true, [18807] = true, [18806] = true, }, ["OtherCheck"] = self.NinjaLastMudra == 6, ["Buff"] = HasMudraBuff == false or HasKassatsuBuff == true, ["LastActionTimeout"] = "NinjaMudra", ["LastActionTime"] = 0,
		},
		{ -- Doton - Starter
			["Type"] = 2, ["Name"] = "Kassatsu - Doton - Ten", ["ID"] = 18805, ["Range"] = 0, ["TargetCast"] = false,
			["LastCastIDNOT"] = { [2259] = true, [18805] = true, [18807] = true, [18806] = true, }, ["OtherCheck"] = self.NinjaLastMudra == 6, ["Buff"] = HasMudraBuff == false or HasKassatsuBuff == true, ["LastActionTimeout"] = "NinjaMudra", ["LastActionTime"] = 0,
		},
		{ -- Doton - 2nd Filler
			["Type"] = 2, ["Name"] = "Doton - Jin", ["ID"] = 18807, ["Range"] = 0, ["TargetCast"] = false,
			["LastCastID"] = { [2259] = true, [18805] = true, }, ["OtherCheck"] = self.NinjaLastMudra == 6, ["Buff"] = HasMudraBuff == true or HasKassatsuBuff == true, ["LastActionTimeout"] = "NinjaMudra", ["LastActionTime"] = 0,
		},
		--{ -- Doton - 2nd Filler
		--	["Type"] = 2, ["Name"] = "Doton - Ten", ["ID"] = 18805, ["Range"] = 0, ["TargetCast"] = false,
		--	["LastCastID"] = { [2263] = true, [18807] = true, }, ["OtherCheck"] = self.NinjaLastMudra == 6, ["Buff"] = HasMudraBuff == true or HasKassatsuBuff == true, ["LastActionTimeout"] = "NinjaMudra", ["LastActionTime"] = 0,
		--},
		{ -- Doton - Finish
			["Type"] = 2, ["Name"] = "Doton - Chi", ["ID"] = 18806, ["Range"] = 0, ["TargetCast"] = false,
			["LastCastID"] = { [18805] = true, [18807] = true, }, ["OtherCheck"] = self.NinjaLastMudra == 6, ["Buff"] = HasMudraBuff == true or HasKassatsuBuff == true, ["LastActionTimeout"] = "NinjaMudra", ["LastActionTime"] = 0,
		},

 		-- Mudras
		-- Buff Lock Actions?
		-- Track Mudra Type Reset Off Buff?

		{
			["Type"] = 1, ["Name"] = "Trick Attack", ["ID"] = 2258, ["Range"] = 3, ["TargetCast"] = true, ["SettingValue"] = self.GetSettingsValue(ClassTypeID,"CDs") == 1,
			["Buff"] = HasSuitonBuff, ["OtherCheck"] = PlayerInCombat == true,
		},
		-- Ten Action 18873
		--18873	Fuma Shuriken
		--18874	Fuma Shuriken
		--18875	Fuma Shuriken

		--18876	Katon
		--18877	Raiton
		--18878	Hyoton

		--18879	Huton
		--18880	Doton
		--18881	Suiton

		{ -- Ten Chi Jin - Fuma
			["Type"] = 1, ["Name"] = "Ten Chi Jin - Fuma", ["ID"] = 18873, ["LastCastIDNOT"] = { [18873] = true, [18877] = true, [18881] = true, }, ["Range"] = 0, ["TargetCast"] = true, ["Buff"] = HasTenChiJinBuff == true,
		},
		{ -- Ten Chi Jin - Raiton
			["Type"] = 1, ["Name"] = "Ten Chi Jin - Raiton", ["ID"] = 18877, ["LastCastID"] = { [18873] = true, }, ["Range"] = 0, ["TargetCast"] = true, ["Buff"] = HasTenChiJinBuff == true,
		},
		{ -- Ten Chi Jin - Suiton
			["Type"] = 1, ["Name"] = "Ten Chi Jin - Suiton", ["ID"] = 18881, ["LastCastID"] = { [18877] = true, }, ["Range"] = 0, ["TargetCast"] = true, ["Buff"] = HasTenChiJinBuff == true,
		},
		--{ -- Ten Chi Jin - Raiton
		--	["Type"] = 1, ["Name"] = "Ten Chi Jin - Raiton", ["ID"] = 2267, ["Range"] = 0, ["TargetCast"] = false, ["Buff"] = HasTenChiJinBuff == true,
		--},

		{ -- Katon
			["Type"] = 1, ["Name"] = "Katon", ["ID"] = 2266, ["Range"] = 0, ["TargetCast"] = true,
			["LastCastID"] = { [18805] = true, }, ["OtherCheck"] = self.NinjaLastMudra == 5, ["Buff"] = HasMudraBuff == true, ["LastActionTimeout"] = "NinjaMudra", ["LastActionTime"] = 0,
		},
		{ -- Katon - Starter
			["Type"] = 1, ["Name"] = "Kassatsu - Katon - Chi", ["ID"] = 18806, ["Range"] = 0, ["TargetCast"] = false,
			["LastCastIDNOT"] = { [2261] = true, [18805] = true, [18806] = true }, ["OtherCheck"] = self.NinjaLastMudra == 5, ["Buff"] = HasMudraBuff == false or HasKassatsuBuff == true, ["LastActionTimeout"] = "NinjaMudra", ["LastActionTime"] = 0,
		},
		{ -- Katon - Starter
			["Type"] = 1, ["Name"] = "Katon - Chi", ["ID"] = 2261, ["Range"] = 0, ["TargetCast"] = false,
			["LastCastIDNOT"] = { [2261] = true,  [18805] = true }, ["OtherCheck"] = self.NinjaLastMudra == 5, ["Buff"] = HasMudraBuff == false or HasKassatsuBuff == true, ["LastActionTimeout"] = "NinjaMudra", ["LastActionTime"] = 0,
		},

		{ -- Katon - Finish
			["Type"] = 1, ["Name"] = "Katon - Ten", ["ID"] = 18805, ["Range"] = 0, ["TargetCast"] = false,
			["LastCastID"] = { [2261] = true, [18806] = true, [2263] = true, [18807] = true, }, ["OtherCheck"] = self.NinjaLastMudra == 5, ["Buff"] = HasMudraBuff == true, ["LastActionTimeout"] = "NinjaMudra", ["LastActionTime"] = 0,
		},


		{ -- Fuma
			["Type"] = 1, ["Name"] = "Fuma", ["ID"] = 2265, ["Range"] = 0, ["TargetCast"] = true,
			["LastCastID"] = { [2259] = true, [18805] = true, }, ["OtherCheck"] = self.NinjaLastMudra == 4, ["Buff"] = HasMudraBuff == true, ["LastActionTimeout"] = "NinjaMudra", ["LastActionTime"] = 0,
		},
		{ -- Fuma - Starter
			["Type"] = 1, ["Name"] = "Kassatsu - Fuma - Ten", ["ID"] = 18805, ["Range"] = 0, ["TargetCast"] = false,
			["LastCastIDNOT"] = { [2259] = true, [18805] = true, }, ["OtherCheck"] = self.NinjaLastMudra == 4, ["Buff"] = HasMudraBuff == false or HasKassatsuBuff == true, ["LastActionTimeout"] = "NinjaMudra", ["LastActionTime"] = 0,
		},
		{ -- Fuma - Starter
			["Type"] = 1, ["Name"] = "Fuma - Ten", ["ID"] = 2259, ["Range"] = 0, ["TargetCast"] = false,
			["LastCastIDNOT"] = { [2259] = true, [18805] = true, }, ["OtherCheck"] = self.NinjaLastMudra == 4, ["Buff"] = HasMudraBuff == false or HasKassatsuBuff == true, ["LastActionTimeout"] = "NinjaMudra", ["LastActionTime"] = 0,
		},


		{ -- Raiton
			["Type"] = 1, ["Name"] = "Raiton", ["ID"] = 2267, ["Range"] = 0, ["TargetCast"] = true,
			["LastCastID"] = { [18806] = true, }, ["OtherCheck"] = self.NinjaLastMudra == 3, ["Buff"] = HasMudraBuff == true, ["LastActionTimeout"] = "NinjaMudra", ["LastActionTime"] = 0,
		},
		{ -- Raiton - Starter
			["Type"] = 1, ["Name"] = "Kassatsu - Raiton - Ten", ["ID"] = 18805, ["Range"] = 0, ["TargetCast"] = false,
			["LastCastIDNOT"] = { [2259] = true, [18805] = true, [18806] = true }, ["OtherCheck"] = self.NinjaLastMudra == 3, ["Buff"] = HasMudraBuff == false or HasKassatsuBuff == true, ["LastActionTimeout"] = "NinjaMudra", ["LastActionTime"] = 0,
		},
		{ -- Raiton - Starter
			["Type"] = 1, ["Name"] = "Raiton - Ten", ["ID"] = 2259, ["Range"] = 0, ["TargetCast"] = false,
			["LastCastIDNOT"] = { [2259] = true, [18805] = true, [18806] = true }, ["OtherCheck"] = self.NinjaLastMudra == 3, ["Buff"] = HasMudraBuff == false or HasKassatsuBuff == true, ["LastActionTimeout"] = "NinjaMudra", ["LastActionTime"] = 0,
		},
		{ -- Raiton - Finish
			["Type"] = 1, ["Name"] = "Raiton - Chi", ["ID"] = 18806, ["Range"] = 0, ["TargetCast"] = false,
			["LastCastID"] = { [2259] = true, [18805] = true, [2263] = true, }, ["OtherCheck"] = self.NinjaLastMudra == 3, ["Buff"] = HasMudraBuff == true, ["LastActionTimeout"] = "NinjaMudra", ["LastActionTime"] = 0,
		},

		-- Ten 2259, Chi 2261, Jin 2263
		-- Ten 18805, Chi 18806, Jin 18807

		{ -- Hyoton
			["Type"] = 1, ["Name"] = "Hyoton", ["ID"] = 2268, ["Range"] = 0, ["TargetCast"] = true,
			["LastCastID"] = { [18807] = true, }, ["OtherCheck"] = self.NinjaLastMudra == 7, ["Buff"] = HasMudraBuff == true, ["LastActionTimeout"] = "NinjaMudra", ["LastActionTime"] = 0,
		},
		{ -- Hyoton - Starter
			["Type"] = 1, ["Name"] = "Kassatsu - Hyoton - Ten", ["ID"] = 18805, ["Range"] = 0, ["TargetCast"] = false,
			["LastCastIDNOT"] = { [2259] = true, [18805] = true, [2261] = true, [18806] = true }, ["OtherCheck"] = self.NinjaLastMudra == 7, ["Buff"] = HasMudraBuff == false or HasKassatsuBuff == true, ["LastActionTimeout"] = "NinjaMudra", ["LastActionTime"] = 0,
		},
		{ -- Hyoton - Starter
			["Type"] = 1, ["Name"] = "Hyoton - Ten", ["ID"] = 2259, ["Range"] = 0, ["TargetCast"] = false,
			["LastCastIDNOT"] = { [2259] = true, [18805] = true, [2261] = true, [18806] = true }, ["OtherCheck"] = self.NinjaLastMudra == 7, ["Buff"] = HasMudraBuff == false or HasKassatsuBuff == true, ["LastActionTimeout"] = "NinjaMudra", ["LastActionTime"] = 0,
		},
		{ -- Hyoton - Finish
			["Type"] = 1, ["Name"] = "Hyoton - Jin", ["ID"] = 18807, ["Range"] = 0, ["TargetCast"] = false,
			["LastCastID"] = { [2259] = true, [18805] = true, [2261] = true, [18806] = true, }, ["OtherCheck"] = self.NinjaLastMudra == 7, ["Buff"] = HasMudraBuff == true, ["LastActionTimeout"] = "NinjaMudra", ["LastActionTime"] = 0,
		},

		{ -- Suiton
			["Type"] = 1, ["Name"] = "Suiton", ["ID"] = 2271, ["Range"] = 0, ["TargetCast"] = true,
			["LastCastID"] = { [18807] = true, }, ["OtherCheck"] = self.NinjaLastMudra == 2, ["Buff"] = HasMudraBuff == true,
		},
		{ -- Suiton - Starter
			["Type"] = 1, ["Name"] = "Suiton - Ten", ["ID"] = 2259, ["Range"] = 0, ["TargetCast"] = false,
			["LastCastIDNOT"] = { [2259] = true, [18806] = true, [18807] = true }, ["OtherCheck"] = self.NinjaLastMudra == 2, ["Buff"] = HasMudraBuff == false, ["LastActionTimeout"] = "NinjaMudra", ["LastActionTime"] = 0,
		},
		{ -- Suiton - 2nd Filler
			["Type"] = 1, ["Name"] = "Suiton - Chi", ["ID"] = 18806, ["Range"] = 0, ["TargetCast"] = false,
			["LastCastID"] = { [2259] = true, }, ["OtherCheck"] = self.NinjaLastMudra == 2, ["Buff"] = HasMudraBuff == true, ["LastActionTimeout"] = "NinjaMudra", ["LastActionTime"] = 0,
		},
		{ -- Suiton - 2nd
			["Type"] = 1, ["Name"] = "Suiton - Ten", ["ID"] = 18805, ["Range"] = 0, ["TargetCast"] = false,
			["LastCastID"] = { [2261] = true, }, ["OtherCheck"] = self.NinjaLastMudra == 2, ["Buff"] = HasMudraBuff == true, ["LastActionTimeout"] = "NinjaMudra", ["LastActionTime"] = 0,
		},
		{ -- Suiton - Finish
			["Type"] = 1, ["Name"] = "Suiton - Jin", ["ID"] = 18807, ["Range"] = 0, ["TargetCast"] = false,
			["LastCastID"] = { [18806] = true, [18805] = true, }, ["OtherCheck"] = self.NinjaLastMudra == 2, ["Buff"] = HasMudraBuff == true, ["LastActionTimeout"] = "NinjaMudra", ["LastActionTime"] = 0,
		},
		-- 4776

		{
			["Type"] = 1, ["Name"] = "Fleeting Raiju", ["ID"] = 25778, ["Range"] = 3, ["TargetCast"] = true, ["OtherCheck"] = self.NinjaLastMudra == 0 and LastActionWasMudra == false and GaugeData1[2] > 15000 or GaugeData1[2] == 0, ["Buff"] = HasMudraBuff == false and HasTenChiJinBuff == false,
		},
		{
			["Type"] = 1, ["Name"] = "Forked Raiju", ["ID"] = 25777, ["Range"] = 20, ["TargetCast"] = true, ["OtherCheck"] = self.NinjaLastMudra == 0 and LastActionWasMudra == false and GaugeData1[2] > 15000 or GaugeData1[2] == 0, ["Buff"] = HasMudraBuff == false and HasTenChiJinBuff == false,
		},

		-- AOE Combo

		{
			["Type"] = 2, ["Name"] = "Death Blossom", ["ID"] = 2254, ["Range"] = 0, ["TargetCast"] = false, ["AOECount"] = 3, ["SettingValue"] = self.GetSettingsValue(ClassTypeID,"AOE") == 1 and AOETimeout == false, ["Buff"] = HasMudraBuff == false and HasTenChiJinBuff == false,
			["AOEType"] = { ["Filter"] = "Enemy", ["Name"] = "Circle", ["TargetPoint"] = PlayerPOS, ["AOERange"] = 5, ["MaxDistance"] = 0, ["LineWidth"] = 0, ["Angle"] = 0, }, ["OtherCheck"] = self.NinjaLastMudra == 0 and LastActionWasMudra == false,
			["ComboIDNOT"] = { [2254] = PlayerLevel >= 52 }, --["ComboID"] = { [0] = true, [2254] = PlayerLevel < 52, [16488] = true, },
		},
		{
			["Type"] = 2, ["Name"] = "Hakke Mujinsatsu", ["ID"] = 16488, ["Range"] = 0, ["TargetCast"] = false, ["ComboID"] = { [2254] = true, }, ["AOECount"] = 3, ["SettingValue"] = self.GetSettingsValue(ClassTypeID,"AOE") == 1 and AOETimeout == false, ["Buff"] = HasMudraBuff == false and HasTenChiJinBuff == false,
			["AOEType"] = { ["Filter"] = "Enemy", ["Name"] = "Circle", ["TargetPoint"] = PlayerPOS, ["AOERange"] = 5, ["MaxDistance"] = 0, ["LineWidth"] = 0, ["Angle"] = 0, }, ["OtherCheck"] = self.NinjaLastMudra == 0 and LastActionWasMudra == false,
		},

		-- Single Target Combo
		{
			["Type"] = 1, ["Name"] = "Spinning Edge", ["ID"] = 2240, ["Range"] = 25, ["TargetCast"] = true, ["OtherCheck"] = self.NinjaLastMudra == 0 and LastActionWasMudra == false, ["Buff"] = HasMudraBuff == false and HasTenChiJinBuff == false,
			["ComboIDNOT"] = { [2240] = PlayerLevel >= 4, [2242] = PlayerLevel >= 26, }, -- ["ComboID"] = { [0] = true, [2240] = PlayerLevel < 4, [2242] = PlayerLevel < 26, [2255] = true, [3563] = true, },
		},
		{
			["Type"] = 1, ["Name"] = "Gust Slash", ["ID"] = 2242, ["Range"] = 25, ["TargetCast"] = true, ["ComboID"] = { [2240] = true, }, ["OtherCheck"] = self.NinjaLastMudra == 0 and LastActionWasMudra == false, ["Buff"] = HasMudraBuff == false and HasTenChiJinBuff == false,
		},
		{
			["Type"] = 1, ["Name"] = "Armor Crush", ["ID"] = 3563, ["Range"] = 25, ["TargetCast"] = true, ["ComboID"] = { [2242] = true, }, ["OtherCheck"] = self.NinjaLastMudra == 0 and LastActionWasMudra == false and GaugeData1[2] > 0 and GaugeData1[2] < 15000, ["Buff"] = HasMudraBuff == false and HasTenChiJinBuff == false,
		},
		{
			["Type"] = 1, ["Name"] = "Aeolian Edge", ["ID"] = 2255, ["Range"] = 25, ["TargetCast"] = true, ["ComboID"] = { [2242] = true, }, ["OtherCheck"] = self.NinjaLastMudra == 0 and LastActionWasMudra == false and GaugeData1[2] > 15000 or GaugeData1[2] == 0, ["Buff"] = HasMudraBuff == false and HasTenChiJinBuff == false,
		},

		{
			["Type"] = 1, ["Name"] = "Throwing Dagger", ["ID"] = 2247, ["Range"] = 25, ["TargetCast"] = true, ["OtherCheck"] = self.NinjaLastMudra == 0 and LastActionWasMudra == false, ["Buff"] = HasMudraBuff == false and HasTenChiJinBuff == false,
		},
		{
			["Type"] = 1, ["Name"] = "Dream Within a Dream", ["ID"] = 3566, ["Range"] = 3, ["TargetCast"] = true, ["OtherCheck"] = self.NinjaLastMudra == 0 and LastActionWasMudra == false, ["Buff"] = HasMudraBuff == false and HasTenChiJinBuff == false and TargetHasTrickAttack == true,
		},

		{
			["Type"] = 1, ["Name"] = "Muh", ["ID"] = 2248, ["Range"] = 3, ["TargetCast"] = true, ["OtherCheck"] = GaugeData1[1] < 50 and self.NinjaLastMudra == 0 and LastActionWasMudra == false, ["Buff"] = HasMudraBuff == false and HasTenChiJinBuff == false,
		},

		{
			["Type"] = 1, ["Name"] = "Bhavacakra", ["ID"] = 7402, ["Range"] = 3, ["TargetCast"] = true, ["SettingValue"] = self.GetSettingsValue(ClassTypeID,"CDs") == 1, ["OtherCheck"] = self.NinjaLastMudra == 0 and LastActionWasMudra == false and PlayerInCombat == true,
			["Buff"] = HasMudraBuff == false and HasTenChiJinBuff == false and HasMeisuiBuff == true, ["LastActionTimeout"] = "NinjaMudra", ["LastActionTime"] = 500, ["LastActionOnlyTime"] = true,
		},
        
		{
			["Type"] = 1, ["Name"] = "Bunshin", ["ID"] = 16493, ["Range"] = 0, ["TargetCast"] = false, ["SettingValue"] = self.GetSettingsValue(ClassTypeID,"CDs") == 1, ["OtherCheck"] = self.NinjaLastMudra == 0 and LastActionWasMudra == false and PlayerInCombat == true,
			["Buff"] = HasMudraBuff == false and HasTenChiJinBuff == false, ["LastActionTimeout"] = "NinjaMudra", ["LastActionTime"] = 500, ["LastActionOnlyTime"] = true,
		},
		{
			["Type"] = 1, ["Name"] = "HellFrog Medium", ["ID"] = 7401, ["Range"] = 25, ["TargetCast"] = true, ["SettingValue"] = self.GetSettingsValue(ClassTypeID,"CDs") == 1, ["OtherCheck"] = self.NinjaLastMudra == 0 and LastActionWasMudra == false and PlayerInCombat == true,
			["Buff"] = HasMudraBuff == false and HasTenChiJinBuff == false, ["LastActionTimeout"] = "NinjaMudra", ["LastActionTime"] = 500, ["LastActionOnlyTime"] = true,
			["AOECount"] = 3, ["AOEType"] = { ["Filter"] = "Enemy", ["Name"] = "Circle", ["TargetPoint"] = TargetPOS, ["AOERange"] = 6, ["MaxDistance"] = 25, ["LineWidth"] = 0, ["Angle"] = 0, },
		},
		{
			["Type"] = 1, ["Name"] = "Bhavacakra", ["ID"] = 7402, ["Range"] = 3, ["TargetCast"] = true, ["SettingValue"] = self.GetSettingsValue(ClassTypeID,"CDs") == 1, ["OtherCheck"] = self.NinjaLastMudra == 0 and LastActionWasMudra == false and PlayerInCombat == true,
			["Buff"] = HasMudraBuff == false and HasTenChiJinBuff == false, ["LastActionTimeout"] = "NinjaMudra", ["LastActionTime"] = 500, ["LastActionOnlyTime"] = true,
		},
        
		-- Shared CDS
		{
			["Type"] = 1, ["Name"] = "Feint", ["ID"] = 7549, ["Range"] = 0, ["TargetCast"] = true, ["SettingValue"] = self.GetSettingsValue(ClassTypeID,"CDs") == 1, ["OtherCheck"] = self.NinjaLastMudra == 0 and LastActionWasMudra == false and PlayerInCombat == true, ["Buff"] = HasMudraBuff == false and HasTenChiJinBuff == false, ["LastActionTimeout"] = "NinjaMudra", ["LastActionTime"] = 500, ["LastActionOnlyTime"] = true,
		},
		{
			["Type"] = 1, ["Name"] = "Bloodbath", ["ID"] = 7542, ["Range"] = 0, ["TargetCast"] = false, ["SettingValue"] = self.GetSettingsValue(ClassTypeID,"CDs") == 1, ["OtherCheck"] = self.NinjaLastMudra == 0 and LastActionWasMudra == false and PlayerInCombat == true and PlayerHP < 50, ["Buff"] = HasMudraBuff == false and HasTenChiJinBuff == false, ["LastActionTimeout"] = "NinjaMudra", ["LastActionTime"] = 500, ["LastActionOnlyTime"] = true,
		},
		{
			["Type"] = 1, ["Name"] = "Seccond Wind", ["ID"] = 7541, ["Range"] = 0, ["TargetCast"] = false, ["SettingValue"] = self.GetSettingsValue(ClassTypeID,"CDs") == 1, ["OtherCheck"] = self.NinjaLastMudra == 0 and LastActionWasMudra == false and PlayerInCombat == true and PlayerHP < 30, ["Buff"] = HasMudraBuff == false and HasTenChiJinBuff == false, ["LastActionTimeout"] = "NinjaMudra", ["LastActionTime"] = 500, ["LastActionOnlyTime"] = true,
		},
	}


	self.SendConsoleMessage(ClassTypeID.."PROFILE END",1)
    return SkillList
end

return Profile