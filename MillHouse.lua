MH = {};

MH.Width = 100;
MH.TextPadding = 5;

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

	MH.UIFrame = CreateFrame("Frame",nil,UIParent);
	MH.UIFrame:SetFrameStrata("BACKGROUND")
	MH.UIFrame:SetWidth(100)
	MH.UIFrame:SetHeight(100)
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
	MH.Cover:SetFrameLevel(128);
	MH.Cover:SetAllPoints();
	MH.Cover:EnableMouse(true);
	MH.Cover:RegisterForClicks("AnyUp");
	MH.Cover:RegisterForDrag("LeftButton");
	MH.Cover:SetScript("OnDragStart", MH.OnDragStart);
	MH.Cover:SetScript("OnDragStop", MH.OnDragStop);
	MH.Cover:SetScript("OnClick", MH.OnClick);

	MH.UpdateFrame();
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
	-- build the list of herbs
	--

	local matched = {};
	local names = {};

	for bag = 1, 4, 1 do
		local slots = GetContainerNumSlots(bag);
		for slot = 1, slots, 1 do

			local itemId = GetContainerItemID(bag, slot);

			if (MH.herb_map[itemId]) then

				local _, qty, _, _, _ = GetContainerItemInfo(bag, slot);

				matched[itemId] = (matched[itemId] or 0) + qty;
				names[itemId] = GetContainerItemLink(bag, slot);
			end
		end
	end


	--
	-- iterate
	--

	local text = "";
	local added = false;

	for id, qty in pairs(matched) do

		local stacks = math.floor(qty / 5);

		if (stacks > 0) then

			text = text .. string.format("%s : |cFF00FF00%d\n", names[id], stacks);
			added = true;
		end
	end

	if (not added) then
		text = "|cFFFFFFCCNothing to mill\n";
	end


	MH.Text:SetText(text);
	local h = MH.Text:GetHeight();
	MH.UIFrame:SetHeight(MH.TextPadding + MH.TextPadding + 15 + h);
end

MH.Frame = CreateFrame("Frame");
MH.Frame:Show();
MH.Frame:SetScript("OnEvent", MH.OnEvent);
MH.Frame:SetScript("OnUpdate", MH.OnUpdate);
MH.Frame:RegisterEvent("ADDON_LOADED");
MH.Frame:RegisterEvent("PLAYER_LOGOUT");

MH.OnLoad();
