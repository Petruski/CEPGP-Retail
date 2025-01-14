--[[ Globals ]]--
CEPGP_VERSION = "1.12.7";
SLASH_CEPGP1 = "/CEPGP";
SLASH_CEPGP2 = "/cep";
CEPGP_VERSION_NOTIFIED = false;
CEPGP_mode = "guild";
CEPGP_recordholder = "";
CEPGP_distPlayer = "";
CEPGP_combatModule = "";
CEPGP_distGP = false;
CEPGP_lootSlot = nil;
CEPGP_target = nil;
CEPGP_DistID = nil;
CEPGP_distSlot = nil;
CEPGP_distSlotID = nil;
CEPGP_distItemLink = nil;
CEPGP_debugMode = false;
CEPGP_critReverse = false; --Criteria reverse
CEPGP_distributing = false;
CEPGP_overwritelog = false;
CEPGP_override_confirm = false;
CEPGP_confirmrestore = false;
CEPGP_looting = false;
CEPGP_traffic_clear = false;
CEPGP_criteria = 4;
CEPGP_kills = 0;
CEPGP_frames = {CEPGP_guild, CEPGP_raid, CEPGP_loot, CEPGP_distribute, CEPGP_options, CEPGP_options_page_2, CEPGP_options_page_3, CEPGP_distribute_popup, CEPGP_context_popup, CEPGP_save_guild_logs, CEPGP_restore_guild_logs, CEPGP_settings_import, CEPGP_override, CEPGP_traffic, CEPGP_standby};
CEPGP_boss_config_frames = {CEPGP_options_page_3_mc, CEPGP_options_page_3_bwl, CEPGP_options_page_3_zg, CEPGP_options_page_3_aq20, CEPGP_options_page_3_aq40, CEPGP_options_page_3_naxx, CEPGP_options_page_3_worldboss};
CEPGP_LANGUAGE = GetDefaultLanguage("player");
CEPGP_responses = {};
CEPGP_itemsTable = {};
CEPGP_roster = {};
CEPGP_raidRoster = {};
CEPGP_vInfo = {};
CEPGP_vSearch = "GUILD";
CEPGP_ElvUI = nil;
CEPGP_groupVersion = {};
CEPGP_RAZORGORE_EGG_COUNT = 0;
CEPGP_THEKAL_PARAMS = {};
CEPGP_snapshot = nil;
CEPGP_use = false;
CEPGP_ignoreUpdates = false;
CEPGP_award = false;
CEPGP_plugins = {};

--[[ SAVED VARIABLES ]]--
CHANNEL = nil;
CEPGP_lootChannel = nil;
MOD = nil;
COEF = nil;
MOD_COEF = nil;
BASEGP = nil;
STANDBYEP = false;
STANDBYOFFLINE = false;
CEPGP_min_threshold = nil;
ALLOW_FORCED_SYNC = false;
CEPGP_force_sync_rank = nil;
CEPGP_standby_accept_whispers = false;
CEPGP_standby_share = false;
CEPGP_standby_whisper_msg = "standby";
CEPGP_keyword = nil;
CEPGP_standby_byrank = true;
CEPGP_standby_manual = false;
CEPGP_notice = false;
CEPGP_loot_GUI = false;
CEPGP_auto_pass = false;
CEPGP_raid_wide_dist = false;
CEPGP_1120_notice = false;
CEPPG_gp_tooltips = false;
CEPGP_suppress_announcements = false;
STANDBYPERCENT = nil;
STANDBYRANKS = {};
SLOTWEIGHTS = {};
DEFSLOTWEIGHTS = {["2HWEAPON"] = 2,["WEAPONMAINHAND"] = 1.5,["WEAPON"] = 1.5,["WEAPONOFFHAND"] = 0.5,["HOLDABLE"] = 0.5,["SHIELD"] = 0.5,["RANGED"] = 0.5,["RANGEDRIGHT"] = 0.5,["RELIC"] = 0.5,["HEAD"] = 1,["NECK"] = 0.5,["SHOULDER"] = 0.75,["CLOAK"] = 0.5,["CHEST"] = 1,["ROBE"] = 1,["WRIST"] = 0.5,["HAND"] = 0.75,["WAIST"] = 0.75,["LEGS"] = 1,["FEET"] = 0.75,["FINGER"] = 0.5,["TRINKET"] = 0.75};
AUTOEP = {};
EPVALS = {};
RECORDS = {};
OVERRIDE_INDEX = {};
TRAFFIC = {};
CEPGP_raid_logs = {};
CEPGP_standbyRoster = {};
CEPGP_minEP = {false, 0};

local L = CEPGP_Locale:GetLocale("CEPGP")


--[[ EVENT AND COMMAND HANDLER ]]--
function CEPGP_OnEvent(event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
	
	if event == "ADDON_LOADED" and arg1 == "CEPGP" then --arg1 = addon name
		CEPGP_initialise();
	elseif event == "GUILD_ROSTER_UPDATE" or event == "GROUP_ROSTER_UPDATE" then
		CEPGP_rosterUpdate(event);
		
	elseif event == "PARTY_LOOT_METHOD_CHANGED" then
		if GetLootMethod() == "master" and IsInRaid("player") and CEPGP_isML() == 0 then
			_G["CEPGP_confirmation"]:Show();
		else
			_G["CEPGP_confirmation"]:Hide();
		end
	elseif event == "CHAT_MSG_BN_WHISPER" then
		local sender = arg2;
		for i = 1, BNGetNumFriends() do
			local _, accName, _, _, name = BNGetFriendInfo(i);
			local inRaid = false;
			for i = 1, GetNumGroupMembers() do
				if CEPGP_raidRoster[i][1] == GetRaidRosterInfo(i) then
					inRaid = true;
					break;
				end
			end
			if sender == accName then --Behaves the same way for both Battle Tag and RealID friends
				if string.lower(arg1) == string.lower(CEPGP_standby_whisper_msg) then
					if (CEPGP_standby_manual and CEPGP_standby_accept_whispers) and
						not CEPGP_tContains(CEPGP_standbyRoster, name) and not inRaid and CEPGP_tContains(CEPGP_roster, name, true) then
						CEPGP_addToStandby(name);
					end
				elseif (string.lower(arg1) == string.lower(CEPGP_keyword) and CEPGP_distributing) or
						(string.lower(arg1) == "!info" or string.lower(arg1) == "!infoguild" or
						string.lower(arg1) == "!inforaid" or string.lower(arg1) == "!infoclass") then
						CEPGP_handleComms("CHAT_MSG_WHISPER", arg1, name);
				end
				return;
			end
		end
		
	
	elseif event == "CHAT_MSG_WHISPER" and string.lower(arg1) == string.lower(CEPGP_standby_whisper_msg) and CEPGP_standby_manual and CEPGP_standby_accept_whispers then
		if not CEPGP_tContains(CEPGP_standbyRoster, arg5)
		and not CEPGP_tContains(CEPGP_raidRoster, arg5, true)
		and CEPGP_tContains(CEPGP_roster, arg5, true) then
			CEPGP_addToStandby(arg5);
		end
			
	elseif (event == "CHAT_MSG_WHISPER" and string.lower(arg1) == string.lower(CEPGP_keyword) and CEPGP_distributing) or
		(event == "CHAT_MSG_WHISPER" and string.lower(arg1) == "!info") or
		(event == "CHAT_MSG_WHISPER" and (string.lower(arg1) == "!infoguild" or string.lower(arg1) == "!inforaid" or string.lower(arg1) == "!infoclass")) then
			CEPGP_handleComms(event, arg1, arg5);
	
	elseif (event == "CHAT_MSG_ADDON") then
		if (arg1 == "CEPGP")then
			if string.find(arg4, "-") then
				arg4 = string.sub(arg4, 0, string.find(arg4, "-")-1);
			end
			CEPGP_IncAddonMsg(arg2, arg4);
		end
	
	elseif CEPGP_use then --EPGP and loot distribution related 
		if event == "COMBAT_LOG_EVENT_UNFILTERED" then
			local _, action, _, _, _, _, _, guid, name = CombatLogGetCurrentEventInfo();
			if action == "UNIT_DIED" and string.find(guid, "Creature") then
				if name == L["Zealot Zath"] or name == L["Zealot Lor'Khan"] then
					CEPGP_handleCombat(name);
					return;
				end
				if name == L["Flamewaker Elite"] or name == L["Flamewaker Healer"] then
					CEPGP_handleCombat(name, true);
				end
				if bossNameIndex[name] then
					CEPGP_handleCombat(name);
				end
			elseif action == "SPELL_CAST_SUCCESS" then
				local spellID, spellName;
				_, _, _, _, name, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo();
				if name == L["Razorgore the Untamed"] and spellID == 19873 then --Razorgore casts destroy egg
					CEPGP_kills = CEPGP_kills + 1;
				end
			end
			
		elseif event == "CHAT_MSG_MONSTER_EMOTE" then
			if arg1 == L["%s is resurrected by a nearby ally!"] then
				if arg2 == L["Zealot Lor'Khan"] then
					CEPGP_THEKAL_PARAMS["LOR'KHAN_DEAD"] = false;
				elseif arg2 == L["Zealot Zath"] then
					CEPGP_THEKAL_PARAMS["ZATH_DEAD"] = false;
				elseif arg2 == L["High Priest Thekal"] and not (CEPGP_THEKAL_PARAMS["LOR'KHAN_DEAD"] or CEPGP_THEKAL_PARAMS["ZATH_DEAD"]) then
					CEPGP_THEKAL_PARAMS["THEKAL_DEAD"] = false;
				end
			end
			
		elseif event == "CHAT_MSG_MONSTER_YELL" then
			if arg2 == L["The Prophet Skeram"] then
				if arg1 == L["You only delay... the inevetable."] then
					CEPGP_handleCombat(arg2, true);
				end
			end
			
		elseif (event == "LOOT_OPENED" or event == "LOOT_CLOSED" or event == "LOOT_SLOT_CLEARED") then
			CEPGP_handleLoot(event, arg1, arg2);
		
		elseif event == "PLAYER_REGEN_DISABLED" then -- Player has started combat
			if CEPGP_debugMode then
				CEPGP_print("Combat started");
			end
			CEPGP_kills = 0;
			CEPGP_THEKAL_PARAMS = {["ZATH_DEAD"] = false, ["LOR'KHAN_DEAD"] = false, ["THEKAL_DEAD"] = false};
		end
	end
end

function SlashCmdList.CEPGP(msg, editbox)
	msg = string.lower(msg);
	if msg == "" then
		CEPGP_print("Classic EPGP Usage");
		CEPGP_print("|cFF80FF80show|r - |cFFFF8080Manually shows the CEPGP window|r");
		CEPGP_print("|cFF80FF80version|r - |cFFFF8080Checks the version of the addon everyone in your raid is running|r");
		
	elseif msg == "show" then
		CEPGP_populateFrame();
		ShowUIPanel(CEPGP_frame);
		CEPGP_toggleFrame("");
		CEPGP_updateGuild();
	
	elseif msg == "version" then
		CEPGP_vInfo = {};
		CEPGP_vSearch = "GUILD";
		CEPGP_SendAddonMsg("version-check", "GUILD");
		CEPGP_groupVersion = {};
		for i = 1, GetNumGuildMembers() do
			local name, _, _, _, class, _, _, _, online, _, classFileName = GetGuildRosterInfo(i);
			if string.find(name, "-") then
				name = string.sub(name, 0, string.find(name, "-")-1);
			end
			if online then
				CEPGP_groupVersion[i] = {
					[1] = name,
					[2] = "Addon not enabled",
					[3] = class,
					[4] = classFileName
				};
			else
				CEPGP_groupVersion[i] = {
					[1] = name,
					[2] = "Offline",
					[3] = class,
					[4] = classFileName
				};
			end
		end
		CEPGP_groupVersion = CEPGP_tSort(CEPGP_groupVersion, 1);
		ShowUIPanel(CEPGP_version);
		CEPGP_UpdateVersionScrollBar();
	
	elseif strfind(msg, "currentchannel") then
		CEPGP_print("Current channel to report: " .. getCurChannel());
		
	elseif strfind(msg, "debugmode") then
		CEPGP_debugMode = not CEPGP_debugMode;
		if CEPGP_debugMode then
			CEPGP_print("Debug Mode Enabled");
		else
			CEPGP_print("Debug Mode Disabled");
		end
		
	elseif strfind(msg, "debug") then
		CEPGP_debuginfo:Show();
	
	else
		CEPGP_print("|cFF80FF80" .. msg .. "|r |cFFFF8080is not a valid request. Type /CEPGP to check addon usage|r", true);
	end
end

--[[ LOOT COUNCIL FUNCTIONS ]]--

function CEPGP_RaidAssistLootClosed()
		HideUIPanel(CEPGP_distribute_popup);
		HideUIPanel(CEPGP_distribute);
		HideUIPanel(CEPGP_loot_CEPGP_distributing);
		HideUIPanel(distributing);
		CEPGP_distribute_item_tex:SetBackdrop(nil);
		_G["CEPGP_distribute_item_tex"]:SetScript('OnEnter', function() end);
		_G["CEPGP_distribute_item_name_frame"]:SetScript('OnClick', function() end);
end

function CEPGP_RaidAssistLootDist(link, gp, raidwide) --raidwide refers to whether or not the ML would like everyone in the raid to be able to see the distribution window
	if UnitIsGroupAssistant("player") or raidwide then --Only returns true if the unit is raid ASSIST, not raid leader
		ShowUIPanel(distributing);
		CEPGP_itemsTable = {};
		CEPGP_UpdateLootScrollBar();
		local name, iString, _, _, _, _, _, _, slot, tex = GetItemInfo(CEPGP_DistID);
		CEPGP_distSlot = slot;
		if not name and CEPGP_itemExists(CEPGP_DistID) then
			local item = Item:CreateFromItemID(tonumber(CEPGP_DistID));
			item:ContinueOnItemLoad(function()
				name, iString, _, _, _, _, _, _, slot, tex = GetItemInfo(CEPGP_DistID);	
				CEPGP_responses = {};
				_G["CEPGP_distribute_item_name"]:SetText(link);
				if iString then
					_G["CEPGP_distribute_item_tex"]:SetScript('OnEnter', function()
																			GameTooltip:SetOwner(_G["CEPGP_distribute_item_tex"], "ANCHOR_TOPLEFT") GameTooltip:SetHyperlink(iString)
																			GameTooltip:Show()
																		end);
					_G["CEPGP_distribute_item_texture"]:SetTexture(tex);
					_G["CEPGP_distribute_item_name_frame"]:SetScript('OnClick', function() SetItemRef(iString) end);
				else
					_G["CEPGP_distribute_item_tex"]:SetScript('OnEnter', function() end);
					_G["CEPGP_distribute_item_texture"]:SetTexture(nil);
				end
				_G["CEPGP_distribute_item_tex"]:SetScript('OnLeave', function() GameTooltip:Hide() end);
				_G["CEPGP_distribute_GP_value"]:SetText(gp);				
			end);
		else
			CEPGP_responses = {};
			_G["CEPGP_distribute_item_name"]:SetText(link);
			if iString then
				_G["CEPGP_distribute_item_tex"]:SetScript('OnEnter', function()
																		GameTooltip:SetOwner(_G["CEPGP_distribute_item_tex"], "ANCHOR_TOPLEFT") GameTooltip:SetHyperlink(iString)
																		GameTooltip:Show()
																	end);
				_G["CEPGP_distribute_item_texture"]:SetTexture(tex);
				_G["CEPGP_distribute_item_name_frame"]:SetScript('OnClick', function() SetItemRef(iString) end);
			else
				_G["CEPGP_distribute_item_tex"]:SetScript('OnEnter', function() end);
				_G["CEPGP_distribute_item_texture"]:SetTexture(nil);
			end
			_G["CEPGP_distribute_item_tex"]:SetScript('OnLeave', function() GameTooltip:Hide() end);
			_G["CEPGP_distribute_GP_value"]:SetText(gp);
		end
	end
end

--[[ ADD EPGP FUNCTIONS ]]--

function CEPGP_AddRaidEP(amount, msg, encounter)
	amount = math.floor(amount);
	local total = GetNumGroupMembers();
	if total > 0 then
		for i = 1, total do
			local name = GetRaidRosterInfo(i);
			if CEPGP_tContains(CEPGP_roster, name, true) then
				local index = CEPGP_getIndex(name, CEPGP_roster[name][1]);
				if not CEPGP_checkEPGP(CEPGP_roster[name][5]) then
					GuildRosterSetOfficerNote(index, amount .. "," .. BASEGP);
				else
					EP,GP = CEPGP_getEPGP(CEPGP_roster[name][5]);
					EP = tonumber(EP);
					GP = tonumber(GP);
					EP = EP + amount;
					if GP < BASEGP then
						GP = BASEGP;
					end
					if EP < 0 then
						EP = 0;
					end
					GuildRosterSetOfficerNote(index, EP .. "," .. GP);
				end
			end
		end
	end
	if msg ~= "" and msg ~= nil or encounter then
		if encounter then -- a boss was killed
			TRAFFIC[CEPGP_ntgetn(TRAFFIC)+1] = {"Raid", UnitName("player"), "Add Raid EP +" .. amount .. " - " .. encounter, "", "", "", "", "", time()};
			CEPGP_ShareTraffic("Raid", UnitName("player"), "Add Raid EP +" .. amount .. " - " .. encounter);
			CEPGP_sendChatMessage(msg, CHANNEL);
		else -- EP was manually given, could be either positive or negative, and a message was written
			if tonumber(amount) <= 0 then
				TRAFFIC[CEPGP_ntgetn(TRAFFIC)+1] = {"Raid", UnitName("player"), "Subtract Raid EP +" .. amount .. " (" .. msg .. ")", "", "", "", "", "", time()};
				CEPGP_ShareTraffic("Raid", UnitName("player"), "Subtract Raid EP " .. amount .. " (" .. msg .. ")");
				CEPGP_sendChatMessage(amount .. " EP taken from all raid members (" .. msg .. ")", CHANNEL);
			else
				TRAFFIC[CEPGP_ntgetn(TRAFFIC)+1] = {"Raid", UnitName("player"), "Add Raid EP +" .. amount .. " (" .. msg .. ")", "", "", "", "", "", time()};
				CEPGP_ShareTraffic("Raid", UnitName("player"), "Add Raid EP +" .. amount .. " (" .. msg .. ")");
				CEPGP_sendChatMessage(amount .. " EP awarded to all raid members (" .. msg .. ")", CHANNEL);
			end
		end
	else -- no message was written
		if tonumber(amount) <= 0 then
			amount = string.sub(amount, 2, string.len(amount));
			TRAFFIC[CEPGP_ntgetn(TRAFFIC)+1] = {"Raid", UnitName("player"), "Subtract Raid EP -" .. amount, "", "", "", "", "", time()};
			CEPGP_ShareTraffic("Raid", UnitName("player"), "Subtract Raid EP -" .. amount);	
			CEPGP_sendChatMessage(amount .. " EP taken from all raid members", CHANNEL);
		else
			TRAFFIC[CEPGP_ntgetn(TRAFFIC)+1] = {"Raid", UnitName("player"), "Add Raid EP +" .. amount, "", "", "", "", "", time()};
			CEPGP_ShareTraffic("Raid", UnitName("player"), "Add Raid EP +" .. amount);
			CEPGP_sendChatMessage(amount .. " EP awarded to all raid members", CHANNEL);
		end
	end
	CEPGP_UpdateTrafficScrollBar();
end

function CEPGP_addGuildEP(amount, msg)
	if amount == nil then
		CEPGP_print("Please enter a valid number", 1);
		return;
	end
	local total = CEPGP_ntgetn(CEPGP_roster);
	local EP, GP = nil;
	amount = math.floor(amount);
	CEPGP_ignoreUpdates = true;
	CEPGP_SendAddonMsg("?IgnoreUpdates;true");
	C_Timer.After(0.1, function()
		if total > 0 then
			for name,_ in pairs(CEPGP_roster)do
				offNote = CEPGP_roster[name][5];
				local index = CEPGP_getIndex(name, CEPGP_roster[name][1]);
				if offNote == "" or offNote == "Click here to set an Officer's Note" then
					GuildRosterSetOfficerNote(index, amount .. "," .. BASEGP);
				else
					EP,GP = CEPGP_getEPGP(CEPGP_roster[name][5]);
					EP = tonumber(EP) + tonumber(amount);
					GP = tonumber(GP);
					if GP < BASEGP then
						GP = BASEGP;
					end
					if EP < 0 then
						EP = 0;
					end
					GuildRosterSetOfficerNote(index, EP .. "," .. GP);
				end
			end
		end
	end);
	C_Timer.After(1, function()
		CEPGP_ignoreUpdates = false;
		CEPGP_SendAddonMsg("?IgnoreUpdates;false");
		if tonumber(amount) <= 0 then
			amount = string.sub(amount, 2, string.len(amount));
			if msg ~= "" and msg ~= nil then
				CEPGP_sendChatMessage(amount .. " EP taken from all guild members (" .. msg .. ")", CHANNEL);
				TRAFFIC[CEPGP_ntgetn(TRAFFIC)+1] = {"Guild", UnitName("player"), "Subtract Guild EP -" .. amount .. " (" .. msg .. ")", "", "", "", "", "", time()};
				CEPGP_ShareTraffic("Guild", UnitName("player"), "Subtract Guild EP -" .. amount .. " (" .. msg .. ")");
			else
				CEPGP_sendChatMessage(amount .. " EP taken from all guild members", CHANNEL);
				TRAFFIC[CEPGP_ntgetn(TRAFFIC)+1] = {"Guild", UnitName("player"), "Subtract Guild EP -" .. amount, "", "", "", "", "", time()};
				CEPGP_ShareTraffic("Guild", UnitName("player"), "Subtract Guild EP -" .. amount);
			end
		else
			if msg ~= "" and msg ~= nil then
				CEPGP_sendChatMessage(amount .. " EP awarded to all guild members (" .. msg .. ")", CHANNEL);
				TRAFFIC[CEPGP_ntgetn(TRAFFIC)+1] = {"Guild", UnitName("player"), "Add Guild EP +" .. amount .. " (" .. msg .. ")", "", "", "", "", "", time()};
				CEPGP_ShareTraffic("Guild", UnitName("player"), "Add Guild EP +" .. amount .. " (" .. msg .. ")");
			else
				CEPGP_sendChatMessage(amount .. " EP awarded to all guild members", CHANNEL);
				TRAFFIC[CEPGP_ntgetn(TRAFFIC)+1] = {"Guild", UnitName("player"), "Add Guild EP +" .. amount, "", "", "", "", "", time()};
				CEPGP_ShareTraffic("Guild", UnitName("player"), "Add Guild EP +" .. amount);
			end
		end
		CEPGP_UpdateTrafficScrollBar();
		CEPGP_rosterUpdate("GUILD_ROSTER_UPDATE");
	end);
end

function CEPGP_addStandbyEP(amount, boss, msg)
	if amount == nil then
		CEPGP_print("Please enter a valid number", 1);
		return;
	end
	local inRaid = false;
	if CEPGP_standby_byrank then
		for name, _ in pairs(CEPGP_roster) do
			inRaid = false;
			for _, v in ipairs(CEPGP_raidRoster) do
				if name == v[1] then
					inRaid = true;
					break;
				end
			end
			if not inRaid then
				local _, rank, _, _, offNote, _, _, _, online = GetGuildRosterInfo(CEPGP_roster[name][1]);
				local EP,GP = CEPGP_getEPGP(CEPGP_roster[name][5]);
				EP = math.floor(tonumber(EP) + amount);
				GP = math.floor(tonumber(GP));
				if GP < BASEGP then
					GP = BASEGP;
				end
				if EP < 0 then
					EP = 0;
				end				
				for i = 1, table.getn(STANDBYRANKS) do
					if STANDBYRANKS[i][1] == rank then
						if STANDBYRANKS[i][2] == true and (online or STANDBYOFFLINE) then
							local index = CEPGP_getIndex(name, CEPGP_roster[name][1]);
							if offNote == "" or offNote == "Click here to set an Officer's Note" then
								GuildRosterSetOfficerNote(index, EP .. "," .. BASEGP);
							else
								GuildRosterSetOfficerNote(index, EP .. "," .. GP);
							end
							if boss then
								CEPGP_SendAddonMsg("STANDBYEP;"..name..";You have been awarded "..amount.." standby EP for encounter " .. boss, "GUILD");
							elseif msg ~= "" and msg ~= nil then
								if tonumber(amount) > 0 then
									CEPGP_SendAddonMsg("STANDBYEP;"..name..";You have been awarded "..amount.." standby EP - "..msg, "GUILD");
								elseif tonumber(amount) < 0 then
									CEPGP_SendAddonMsg("STANDBYEP;"..name..";"..amount.." standby EP has been taken from you - "..msg, "GUILD");
								end
							else
								if tonumber(amount) > 0 then
									CEPGP_SendAddonMsg("STANDBYEP;"..name..";You have been awarded "..amount.." standby EP", "GUILD");
								elseif tonumber(amount) < 0 then
									CEPGP_SendAddonMsg("STANDBYEP;"..name..";"..amount.." standby EP has been taken from you", "GUILD");
								end
							end
						end
					end
				end
			end
		end
	elseif CEPGP_standby_manual then
		for _, x in pairs(CEPGP_standbyRoster) do
			local name = x[1];
			inRaid = false;
			for _, v in ipairs(CEPGP_raidRoster) do
				if name == v[1] then
					inRaid = true;
					break;
				end
			end
			if not inRaid then
				local _, rank, _, _, offNote, _, _, _, online = GetGuildRosterInfo(CEPGP_roster[name][1]);
				if online or STANDBYOFFLINE then
					local EP,GP = CEPGP_getEPGP(CEPGP_roster[name][5]);
					EP = tonumber(EP) + amount;
					GP = tonumber(GP);
					if GP < BASEGP then
						GP = BASEGP;
					end
					if EP < 0 then
						EP = 0;
					end
					local index = CEPGP_getIndex(name, CEPGP_roster[name][1]);
					if offNote == "" or offNote == "Click here to set an Officer's Note" then
						GuildRosterSetOfficerNote(index, EP .. "," .. BASEGP);
					else
						GuildRosterSetOfficerNote(index, EP .. "," .. GP);
					end
					if boss then
						CEPGP_SendAddonMsg("STANDBYEP;"..name..";You have been awarded "..amount.." standby EP for encounter " .. boss, "GUILD");
					elseif msg ~= "" and msg ~= nil then
						if tonumber(amount) > 0 then
							CEPGP_SendAddonMsg("STANDBYEP;"..name..";You have been awarded "..amount.." standby EP - "..msg, "GUILD");
						elseif tonumber(amount) < 0 then
							CEPGP_SendAddonMsg("STANDBYEP;"..name..";"..amount.." standby EP has been taken from you - "..msg, "GUILD");
						end
					else
						if tonumber(amount) > 0 then
							CEPGP_SendAddonMsg("STANDBYEP;"..name..";You have been awarded "..amount.." standby EP", "GUILD");
						elseif tonumber(amount) < 0 then
							CEPGP_SendAddonMsg("STANDBYEP;"..name..";"..amount.." standby EP has been taken from you", "GUILD");
						end
					end
				end
			end
		end
	end
	if tonumber(amount) > 0 then
		TRAFFIC[CEPGP_ntgetn(TRAFFIC)+1] = {"Guild", UnitName("player"), "Standby EP +" .. amount, "", "", "", "", "", time()};
	elseif tonumber(amount) < 0 then
		TRAFFIC[CEPGP_ntgetn(TRAFFIC)+1] = {"Guild", UnitName("player"), "Standby EP " .. amount, "", "", "", "", "", time()};
	end
	if tonumber(amount) > 0 then
		CEPGP_ShareTraffic("Guild", UnitName("player"), "Standby EP +" .. amount);
	elseif tonumber(amount) < 0 then
		CEPGP_ShareTraffic("Guild", UnitName("player"), "Standby EP " .. amount);
	end
	CEPGP_UpdateTrafficScrollBar();
	CEPGP_UpdateStandbyScrollBar();
end

function CEPGP_addGP(player, amount, itemID, itemLink, msg)
	if amount == nil then
		CEPGP_print("Please enter a valid number", 1);
		return;
	end
	local EP, GP = nil;
	amount = math.floor(amount);
	if CEPGP_tContains(CEPGP_roster, player, true) then
		offNote = CEPGP_roster[player][5];
		local index = CEPGP_getIndex(player, CEPGP_roster[player][1]);
		if offNote == "" or offNote == "Click here to set an Officer's Note" then
			GuildRosterSetOfficerNote(index, "0," .. BASEGP);
			offNote = "0," .. BASEGP;
		end
		EP,GP = CEPGP_getEPGP(offNote);
		GPB = GP;
		GP = tonumber(GP) + amount;
		EP = tonumber(EP);
		if GP < BASEGP then
			GP = BASEGP;
		end
		if EP < 0 then
			EP = 0;
		end
		GuildRosterSetOfficerNote(index, EP .. "," .. GP);
		if not itemID then
			if tonumber(amount) <= 0 then -- Number is negative or 0
				amount = string.sub(amount, 2, string.len(amount));
				if msg ~= "" and msg ~= nil then
					CEPGP_sendChatMessage(amount .. " GP taken from " .. player .. "(" .. msg .. ")", CHANNEL);
					CEPGP_ShareTraffic(player, UnitName("player"), "Subtract GP " .. amount .. " (" .. msg .. ")", EP, EP, GP - amount, GPB);
					TRAFFIC[CEPGP_ntgetn(TRAFFIC)+1] = {
						[1] = player,
						[2] = UnitName("player"),
						[3] = "Subtract GP " .. amount .. " (" .. msg .. ")",
						[4] = EP,
						[5] = EP,
						[6] = GPB,
						[7] = GP,
						[9] = time()
					};
				else
					CEPGP_sendChatMessage(amount .. " GP taken from " .. player, CHANNEL);
					CEPGP_ShareTraffic(player, UnitName("player"), "Subtract GP " .. amount, EP, EP, GP - amount, GPB);
					TRAFFIC[CEPGP_ntgetn(TRAFFIC)+1] = {
						[1] = player,
						[2] = UnitName("player"),
						[3] = "Subtract GP " .. amount,
						[4] = EP,
						[5] = EP,
						[6] = GPB,
						[7] = GP,
						[9] = time()
					};
				end
			else -- Number is positive
				if msg ~= "" and msg ~= nil then
					CEPGP_sendChatMessage(amount .. " GP added to " .. player .. " (" .. msg .. ")", CHANNEL);
					CEPGP_ShareTraffic(player, UnitName("player"), "Add GP " .. amount .. " (" .. msg .. ")", EP, EP, GPB, GP);
					TRAFFIC[CEPGP_ntgetn(TRAFFIC)+1] = {
						[1] = player,
						[2] = UnitName("player"),
						[3] = "Add GP " .. amount .. " (" .. msg .. ")",
						[4] = EP,
						[5] = EP,
						[6] = GPB,
						[7] = GP,
						[9] = time()
					};
				else
					CEPGP_sendChatMessage(amount .. " GP added to " .. player, CHANNEL);
					CEPGP_ShareTraffic(player, UnitName("player"), "Add GP " .. amount, EP, EP, GPB, GP);
					TRAFFIC[CEPGP_ntgetn(TRAFFIC)+1] = {
						[1] = player,
						[2] = UnitName("player"),
						[3] = "Add GP " .. amount,
						[4] = EP,
						[5] = EP,
						[6] = GPB,
						[7] = GP,
						[9] = time()
					};
				end
			end
		else -- If an item is associated with the message then the number cannot be negative
			if not itemLink then
				_, itemLink = GetItemInfo(tonumber(itemID));
			end
			if msg ~= "" and msg ~= nil then
				TRAFFIC[CEPGP_ntgetn(TRAFFIC)+1] = {
					[1] = player,
					[2] = UnitName("player"),
					[3] = "Add GP " .. amount .. " (" .. msg .. ")",
					[4] = EP,
					[5] = EP,
					[6] = GPB,
					[7] = GP,
					[8] = itemLink,
					[9] = time()
				};
			else
				TRAFFIC[CEPGP_ntgetn(TRAFFIC)+1] = {
					[1] = player,
					[2] = UnitName("player"),
					[3] = "Add GP " .. amount,
					[4] = EP,
					[5] = EP,
					[6] = GPB,
					[7] = GP,
					[8] = itemLink,
					[9] = time()
				};
			end
			if itemLink then
				if msg ~= "" and msg ~= nil then
					TRAFFIC[CEPGP_ntgetn(TRAFFIC)][8] = itemLink;
					CEPGP_ShareTraffic(player, UnitName("player"), "Add GP " .. amount .. " (" .. msg .. ")", EP, EP, GPB, GP, itemID);
				else
					CEPGP_ShareTraffic(player, UnitName("player"), "Add GP " .. amount, EP, EP, GPB, GP, itemID);
				end
			else
				if msg ~= "" and msg ~= nil then
					CEPGP_ShareTraffic(player, UnitName("player"), "Add GP " .. amount .. " (" .. msg .. ")", EP, EP, GPB, GP);
				else
					CEPGP_ShareTraffic(player, UnitName("player"), "Add GP " .. amount, EP, EP, GPB, GP);
				end
				
			end
		end
		CEPGP_UpdateTrafficScrollBar();
	else
		CEPGP_print(player .. " not found in guild roster - no GP given");
		CEPGP_print("If this was a mistake, you can manually award them GP via the CEPGP guild menu");
	end
end

function CEPGP_addEP(player, amount, msg)
	if amount == nil then
		CEPGP_print("Please enter a valid number", 1);
		return;
	end
	amount = math.floor(amount);
	local EP, GP = nil;
	if CEPGP_tContains(CEPGP_roster, player, true) then
		offNote = CEPGP_roster[player][5];
		local index = CEPGP_getIndex(player, CEPGP_roster[player][1]);
		if offNote == "" or offNote == "Click here to set an Officer's Note" then
			GuildRosterSetOfficerNote(index, "0," .. BASEGP);
			offNote = "0," .. BASEGP;
		end
		EP,GP = CEPGP_getEPGP(offNote);
		EPB = EP;
		EP = tonumber(EP) + amount;
		GP = tonumber(GP);
		if GP < BASEGP then
			GP = BASEGP;
		end
		if EP < 0 then
			EP = 0;
		end
		GuildRosterSetOfficerNote(index, EP .. "," .. GP);
		if tonumber(amount) <= 0 then
			if msg ~= "" and msg ~= nil then
				amount = string.sub(amount, 2, string.len(amount));
				CEPGP_sendChatMessage(amount .. " EP taken from " .. player .. " (" .. msg .. ")", CHANNEL);
				TRAFFIC[CEPGP_ntgetn(TRAFFIC)+1] = {
					[1] = player,
					[2] = UnitName("player"),
					[3] = "Subtract EP -" .. amount .. " (" .. msg .. ")",
					[4] = EPB,
					[5] = EP,
					[6] = GP,
					[7] = GP,
					[9] = time()
				};
				CEPGP_ShareTraffic(player, UnitName("player"), "Subtract EP -" .. amount .. " (" .. msg .. ")", EPB, EP, GP, GP);
			else
				amount = string.sub(amount, 2, string.len(amount));
				CEPGP_sendChatMessage(amount .. " EP taken from " .. player, CHANNEL);
				TRAFFIC[CEPGP_ntgetn(TRAFFIC)+1] = {
					[1] = player,
					[2] = UnitName("player"),
					[3] = "Subtract EP -" .. amount,
					[4] = EPB,
					[5] = EP,
					[6] = GP,
					[7] = GP,
					[9] = time()
				};
				CEPGP_ShareTraffic(player, UnitName("player"), "Subtract EP -" .. amount, EPB, EP, GP, GP);
			end
		else
			if msg ~= "" and msg ~= nil then
				CEPGP_sendChatMessage(amount .. " EP added to " .. player .. " (" .. msg .. ")", CHANNEL);
				TRAFFIC[CEPGP_ntgetn(TRAFFIC)+1] = {
					[1] = player,
					[2] = UnitName("player"),
					[3] = "Add EP +" .. amount .. " (" .. msg .. ")",
					[4] = EPB,
					[5] = EP,
					[6] = GP,
					[7] = GP,
					[9] = time()
				};
				CEPGP_ShareTraffic(player, UnitName("player"), "Add EP +" .. amount .. " (" .. msg ..")", EPB, EP, GP, GP);
			else
				CEPGP_sendChatMessage(amount .. " EP added to " .. player, CHANNEL);
				TRAFFIC[CEPGP_ntgetn(TRAFFIC)+1] = {
					[1] = player,
					[2] = UnitName("player"),
					[3] = "Add EP +" .. amount,
					[4] = EPB,
					[5] = EP,
					[6] = GP,
					[7] = GP,
					[9] = time()
				};
				CEPGP_ShareTraffic(player, UnitName("player"), "Add EP +" .. amount, EPB, EP, GP, GP);
			end
		end
		CEPGP_UpdateTrafficScrollBar();
	else
		CEPGP_print("Player not found in guild CEPGP_roster.", true);
	end
end

function CEPGP_decay(amount, msg)
	if amount == nil then
		CEPGP_print("Please enter a valid number", 1);
		return;
	end
	CEPGP_updateGuild();
	local EP, GP = nil;
	CEPGP_ignoreUpdates = true;
	CEPGP_SendAddonMsg("?IgnoreUpdates;true");
	C_Timer.After(0.1, function()
		for name,_ in pairs(CEPGP_roster)do
			EP, GP = CEPGP_getEPGP(CEPGP_roster[name][5]);
			local index = CEPGP_getIndex(name, CEPGP_roster[name][1]);
			--[[if offNote == "" or offNote == "Click here to set an Officer's Note" then
				GuildRosterSetOfficerNote(index, 0 .. "," .. BASEGP);
				EP,GP = CEPGP_getEPGP(offNote);
			else]]
				EP = math.floor(tonumber(EP)*(1-(amount/100)));
				if CEPGP_minGPDecayFactor then
					GP = CEPGP_round((tonumber((GP-BASEGP))*(1-(amount/100)))+BASEGP);
				else
					GP = CEPGP_round((tonumber(GP)*(1-(amount/100))));
				end
				if GP < BASEGP then
					GP = BASEGP;
				end
				if EP < 0 then
					EP = 0;
				end
				GuildRosterSetOfficerNote(index, EP .. "," .. GP);
			--end
		end
	end);
	C_Timer.After(1, function()
		CEPGP_ignoreUpdates = false;
		CEPGP_SendAddonMsg("?IgnoreUpdates;false");
		if tonumber(amount) <= 0 then
			amount = string.sub(amount, 2, string.len(amount));
			if msg ~= "" and msg ~= nil then
				CEPGP_sendChatMessage("Guild EPGP inflated by " .. amount .. "% (" .. msg .. ")", CHANNEL);
				TRAFFIC[CEPGP_ntgetn(TRAFFIC)+1] = {"Guild", UnitName("player"), "Inflated EPGP +" .. amount .. "% (" .. msg .. ")", "", "", "", "", "", time()}; 
				CEPGP_ShareTraffic("Guild", UnitName("player"), "Inflated EPGP +" .. amount .. "% (" .. msg .. ")");
			else
				CEPGP_sendChatMessage("Guild EPGP inflated by " .. amount .. "%", CHANNEL);
				TRAFFIC[CEPGP_ntgetn(TRAFFIC)+1] = {"Guild", UnitName("player"), "Inflated EPGP +" .. amount .. "%", "", "", "", "", "", time()}; 
				CEPGP_ShareTraffic("Guild", UnitName("player"), "Inflated EPGP +" .. amount .. "%");
			end
		else
			if msg ~= "" and msg ~= nil then
				CEPGP_sendChatMessage("Guild EPGP decayed by " .. amount .. "% (" .. msg .. ")", CHANNEL);
				TRAFFIC[CEPGP_ntgetn(TRAFFIC)+1] = {"Guild", UnitName("player"), "Decay EPGP -" .. amount .. "% (" .. msg .. ")", "", "", "", "", "", time()}; 
				CEPGP_ShareTraffic("Guild", UnitName("player"), "Decayed EPGP -" .. amount .. "% (" .. msg .. ")");
			else
				CEPGP_sendChatMessage("Guild EPGP decayed by " .. amount .. "%", CHANNEL);
				TRAFFIC[CEPGP_ntgetn(TRAFFIC)+1] = {"Guild", UnitName("player"), "Decay EPGP -" .. amount .. "%", "", "", "", "", "", time()}; 
				CEPGP_ShareTraffic("Guild", UnitName("player"), "Decayed EPGP -" .. amount .. "%");
			end
		end
		CEPGP_UpdateTrafficScrollBar();
		CEPGP_rosterUpdate("GUILD_ROSTER_UPDATE");
	end);
end

function CEPGP_resetAll(msg)
	local total = CEPGP_ntgetn(CEPGP_roster);
	CEPGP_ignoreUpdates = true;
	CEPGP_SendAddonMsg("?IgnoreUpdates;true");
	C_Timer.After(0.1, function()
		if total > 0 then
			for i = 1, total, 1 do
				GuildRosterSetOfficerNote(i, "0,"..BASEGP);
			end
		end
	end);
	if msg ~= "" and msg ~= nil then
		TRAFFIC[CEPGP_ntgetn(TRAFFIC)+1] = {"Guild", UnitName("player"), "Cleared EPGP standings (" .. msg .. ")", "", "", "", "", "", time()};
		CEPGP_ShareTraffic("Guild", UnitName("player"), "Cleared EPGP standings (" .. msg .. ")");
		CEPGP_sendChatMessage("All EPGP standings have been cleared! (" .. msg .. ")", CHANNEL);
	else
		TRAFFIC[CEPGP_ntgetn(TRAFFIC)+1] = {"Guild", UnitName("player"), "Cleared EPGP standings", "", "", "", "", "", time()};
		CEPGP_ShareTraffic("Guild", UnitName("player"), "Cleared EPGP standings");
		CEPGP_sendChatMessage("All EPGP standings have been cleared!", CHANNEL);
	end
	C_Timer.After(1, function()
		CEPGP_ignoreUpdates = false;
		CEPGP_SendAddonMsg("?IgnoreUpdates;false");
		CEPGP_UpdateTrafficScrollBar();
		CEPGP_rosterUpdate("GUILD_ROSTER_UPDATE");
	end);
end
