MH = {};

-- /run print("|TInterface\\Icons\\inv_weapon_shortblade_05:0|t Hello")

MH.TextPadding = 5;
MH.IconSize = 34;
MH.NumCols = 5;
MH.IconGap = 2;
MH.TextSize = 20;

MH.Icons = {};
MH.Textures = {};
MH.Names = {};
MH.showStacks = {};

MH.defaults = {
	hide = false,
	lock = false,
	frameRef = "CENTER",
	frameX = 0,
	frameY = 0,
};

MH.herbs = {
	2449, -- Earthroot
	2447, -- Peacebloom
	765,  -- Silverleaf

	3820, -- Stranglekelp
	2453, -- Bruiseweed
	2450, -- Briarthorn
	785,  -- Mageroyal
	2452, -- Swiftthistle

	3356, -- Kingsblood
	3357, -- Liferoot
	3369, -- Grave Moss
	3355, -- Wild Steelbloom

	3358, -- Khadgar's Whisker
	3819, -- Wintersbite
	3818, -- Fadeleaf
	3821, -- Goldthorn

	8845, -- Ghost Mushroom
	8839, -- Blindweed
	8846, -- Gromsblood
	8836, -- Arthas' Tears
	4625, -- Firebloom
	8831, -- Purple Lotus
	8838, -- Sungrass

	13465, -- Mountain Silversage
	13466, -- Plaguebloom
	13467, -- Icecap
	13463, -- Dreamfoil
	13464, -- Golden Sansam

	22791, -- Netherbloom
	22792, -- Nightmare Vine
	22790, -- Ancient Lichen
	22793, -- Mana Thistle
	22786, -- Dreaming Glory
	22785, -- Felweed
	22789, -- Terocone
	22787, -- Ragveil

	36903, -- Adder's Tongue
	36906, -- Icethorn
	36905, -- Lichbloom
	39969, -- Fire Seed
	37921, -- Deadnettle
	36901, -- Goldclover
	36907, -- Talandra's Rose
	36904, -- Tiger Lily
	39970, -- Fire Leaf
};

function MH.OnLoad()

	MH.herb_map = {};
	for i,v in ipairs(MH.herbs) do
		if (v) then
			MH.herb_map[v] = true;
		end
	end
end

function MH.OnReady()

	_G.MillHouseDB = _G.MillHouseDB or {};
	MH.options = {};
	for k,v in pairs(MH.defaults) do
		if (_G.MillHouseDB[k]) then
			MH.options[k] = _G.MillHouseDB[k];
		else
			MH.options[k] = v;
		end
	end

	MH.BuildFrame();
end

function MH.OnSaving()

	local point, relativeTo, relativePoint, xOfs, yOfs = MH.UIFrame:GetPoint()
	MH.options.frameRef = relativePoint;
	MH.options.frameX = xOfs;
	MH.options.frameY = yOfs;

	_G.MillHouseDB = MH.options;
end

function MH.OnEvent(frame, event, ...)

	if (event == 'ADDON_LOADED') then
		local name = ...;
		if name == 'MillHouse' then
			MH.OnReady();
		end
	end

	if (event == 'PLAYER_LOGOUT') then

		MH.OnSaving();
	end
end

function MH.OnUpdate()

	MH.UpdateFrame();
end

function MH.BuildFrame()

	MH.Width = (MH.TextPadding * 2) + (MH.IconSize * MH.NumCols) + (MH.IconGap * (MH.NumCols - 1));

	MH.UIFrame = CreateFrame("Frame",nil,UIParent);
	MH.UIFrame:SetFrameStrata("BACKGROUND")
	MH.UIFrame:SetWidth(MH.Width);
	MH.UIFrame:SetHeight(100);
	MH.UIFrame:SetPoint(MH.options.frameRef, MH.options.frameX, MH.options.frameY);
	MH.UIFrame:SetMovable(true);

	MH.UIFrame.texture = MH.UIFrame:CreateTexture()
	MH.UIFrame.texture:SetAllPoints(MH.UIFrame)
	MH.UIFrame.texture:SetTexture(0, 0, 0)

	MH.Title = MH.UIFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
	MH.Title:SetPoint("TOPLEFT", MH.TextPadding, 0-MH.TextPadding);
	MH.Title:SetWidth(MH.Width - (MH.TextPadding + MH.TextPadding));
	MH.Title:SetText("Mill House");
	MH.Title:Show();

	MH.Text = MH.UIFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
	MH.Text:SetPoint("TOPLEFT", MH.TextPadding, 0-(MH.TextPadding+MH.TextPadding+15));
	MH.Text:SetWidth(MH.Width - (MH.TextPadding + MH.TextPadding));
	MH.Text:SetText("...");
	MH.Text:Show();

	MH.Cover = CreateFrame("Button", nil, MH.UIFrame);
	MH.Cover:SetFrameLevel(100);
	MH.Cover:SetAllPoints();
	MH.Mouseify(MH.Cover);

	for id,_ in pairs(MH.herb_map) do

		MH.Icons[id] = MH.CreateButton(0, 0, MH.IconSize, MH.IconSize, [[Interface\Icons\inv_weapon_shortblade_05]], id);
		MH.Icons[id]:SetFrameLevel(101);
	end

	MH.UpdateFrame();
end

function MH.CreateButton(x, y, w, h, texture, key)

	local b = CreateFrame("Button", nil, MH.UIFrame);
	b:SetPoint("TOPLEFT", x, 0-y);
	b:SetWidth(w);
	b:SetHeight(h);
	b:Hide();
	b.key = key;

	b.texture = b:CreateTexture(nil, "ARTWORK");
	b.texture:SetAllPoints(b)
	b.texture:SetTexture(texture)

	b.label = b:CreateFontString(nil, "OVERLAY");
	b.label:Show()
	b.label:ClearAllPoints()
	b.label:SetTextColor(1, 1, 1, 1);
	b.label:SetFont([[Fonts\FRIZQT__.TTF]], MH.TextSize, "OUTLINE");
	b.label:SetPoint("CENTER", b, "CENTER", 0, 0);
	b.label:SetText(" ");

	MH.Mouseify(b);

	b:SetHitRectInsets(0, 0, 0, 0);
	b:SetScript("OnEnter", function(self) MH.ShowTooltip(self.key); end);
	b:SetScript("OnLeave", function() GameTooltip:Hide(); end);

	return b;
end

function MH.Mouseify(f)

	f:EnableMouse(true);
	f:RegisterForClicks("AnyUp");
	f:RegisterForDrag("LeftButton");
	f:SetScript("OnDragStart", MH.OnDragStart);
	f:SetScript("OnDragStop", MH.OnDragStop);
	f:SetScript("OnClick", MH.OnClick);
end

function MH.ShowTooltip(itemId)

	GameTooltip:SetOwner(MH.Icons[itemId], "ANCHOR_TOP", 0, 10);

	GameTooltip:SetHyperlink(MH.Names[itemId]);
	GameTooltip:AddLine("5-stacks to mill: "..MH.showStacks[itemId]);

	GameTooltip:ClearAllPoints();
	GameTooltip:Show();
end

function MH.OnDragStart(frame)
	MH.UIFrame:StartMoving();
	MH.UIFrame.isMoving = true;
	GameTooltip:Hide()
end

function MH.OnDragStop(frame)
	MH.UIFrame:StopMovingOrSizing();
	MH.UIFrame.isMoving = false;
end

function MH.OnClick(self, aButton)
	if (aButton == "RightButton") then
		--MH.ShowMenu();
	end
end

function MH.UpdateFrame()

	--
	-- do they have inscription?
	--

	local can = IsUsableSpell("Inscription");
	if (can) then
		MH.UIFrame:Show();
	else
		MH.UIFrame:Hide();
		return;
	end


	--
	-- build the list of herbs
	--

	local matched = {};

	for bag = 1, 4, 1 do
		local slots = GetContainerNumSlots(bag);
		for slot = 1, slots, 1 do

			local itemId = GetContainerItemID(bag, slot);

			if (MH.herb_map[itemId]) then

				local tex, qty, _, _, _ = GetContainerItemInfo(bag, slot);

				matched[itemId] = (matched[itemId] or 0) + qty;

				MH.Names[itemId] = GetContainerItemLink(bag, slot);
				MH.Textures[itemId] =  tex;
			end
		end
	end


	--
	-- iterate
	--

	local showCount = 0;
	local demo_idx = 0;
	MH.showStacks = {};

	for id, qty in pairs(matched) do

		local stacks = math.floor(qty / 5);

		if (stacks > 0) then

			MH.showStacks[id] = stacks;
			showCount = showCount + 1;
		end
	end


	--
	-- hide icons we wont show
	--

	for id,_ in pairs(MH.herb_map) do
		if (not (MH.showStacks[id])) then
			MH.Icons[id]:Hide();
		end
	end


	--
	-- generate display
	--

	if (showCount == 0) then

		MH.Text:SetText("|cFFFFFFCCNothing to mill\n");
		local h = MH.Text:GetHeight();

		MH.UIFrame:SetHeight(MH.TextPadding + MH.TextPadding + 20 + h);

	else

		MH.Text:SetText("");
		local h = MH.Text:GetHeight();


		-- calc positions
		local x = 0;
		local y = 30;
		local rows = ceil(showCount / MH.NumCols);
		local last_row_count = showCount - ((rows - 1) * MH.NumCols);
		local last_row_offset = ((MH.NumCols - last_row_count) * (MH.IconSize + MH.IconGap)) / 2;
		local idx = 0;

		for id, qty in pairs(MH.showStacks) do

			local icon = MH.Icons[id];
			local row = floor(idx / MH.NumCols);
			local col = idx - (row * MH.NumCols);

			local x = MH.TextPadding + (MH.IconSize * col) + (MH.IconGap * col);
			local y = MH.TextPadding + 20 + h + (MH.IconSize * row) + (MH.IconGap * row);

			if (row == rows-1) then
				x = x + last_row_offset;
			end

			icon:SetPoint("TOPLEFT", x, 0-y);
			icon.texture:SetTexture(MH.Textures[id]);
			icon.label:SetText(MH.showStacks[id]);
			icon:Show();

			idx = idx + 1;
		end

		MH.UIFrame:SetHeight(MH.TextPadding + MH.TextPadding + 20 + h + (MH.IconSize * rows) + (MH.IconGap * (rows - 1)));
	end

end

MH.Frame = CreateFrame("Frame");
MH.Frame:Show();
MH.Frame:SetScript("OnEvent", MH.OnEvent);
MH.Frame:SetScript("OnUpdate", MH.OnUpdate);
MH.Frame:RegisterEvent("ADDON_LOADED");
MH.Frame:RegisterEvent("PLAYER_LOGOUT");

MH.OnLoad();
