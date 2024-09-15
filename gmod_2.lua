if CLIENT then -- Ensure the script only runs client-side

    -- ESP, Aimbot, and Misc Settings
    local espSettings = {
        -- ESP Settings
        enabled = false,
        showName = false,
        showHealth = false,
        showWeapon = false,
        showSnaplines = false,
        showDistance = false,
        show2DBox = false, -- Option to toggle 2D Box separately
        showChams = false, -- Chams (see-through walls)
        showRole = false, -- Show player role (if available)

        -- Other Settings
        distanceLimit = 3000, -- Default distance set to 3000 units
        distanceUnit = "meters", -- Default distance unit in meters

        -- Aimbot and FOV Settings
        aimbotEnabled = false, -- Toggle aimbot
        aimSmoothness = 0.1, -- Smoothing factor for aimbot aim movement
        aimFOV = 200, -- Field of view radius for the aimbot and FOV circle
        aimBone = "ValveBiped.Bip01_Head1", -- Bone to aim at (head by default)
        maxDistance = 5000, -- Maximum distance for the aimbot to work
        showFOVCircle = false, -- FOV Circle Toggle
        checkVisibility = true,

        -- Misc Settings
        adjustFOV = 90
    }

    -- Menu state
    local espMenuOpen = false
    local lastToggleTime = 0 -- Variable to track the last time F2 was pressed

    -- Helper function to get health-based color (green to red)
    local function GetHealthColor(health)
        local healthRatio = health / 100
        local r = math.Clamp(255 - (255 * healthRatio), 0, 255)
        local g = math.Clamp(255 * healthRatio, 0, 255)
        return Color(r, g, 0, 255)
    end

    -- Helper function to convert distance to meters, feet, or units
    local function ConvertDistance(distance)
        if espSettings.distanceUnit == "meters" then
            return math.Round(distance * 0.01905, 2) .. " meters"
        elseif espSettings.distanceUnit == "feet" then
            return math.Round(distance * 0.06234, 2) .. " feet"
        elseif espSettings.distanceUnit == "units" then
            return math.Round(distance, 2) .. " units"
        else
            return math.Round(distance, 2) .. " units" -- Default to units if something goes wrong
        end
    end

    -- Add back the CalculateBox function
    local function CalculateBox(target)
        local ply = LocalPlayer()
        local distance = ply:GetPos():Distance(target:GetPos())

        -- Scale the box based on distance (closer = bigger)
        local scale = math.Clamp(2000 / distance, 0.5, 1.5)
        local min, max = target:OBBMins(), target:OBBMaxs()
        local headPos = target:GetPos() + Vector(0, 0, max.z) -- Head of the player
        local feetPos = target:GetPos() -- Feet of the player

        -- Calculate 2D screen positions
        local screenPosTop = headPos:ToScreen()
        local screenPosBottom = feetPos:ToScreen()

        local boxHeight = (screenPosBottom.y - screenPosTop.y) * scale
        local boxWidth = boxHeight / 2 -- Aspect ratio for box width

        return screenPosTop, screenPosBottom, boxWidth, boxHeight, distance
    end

    -- Menu creation with categories
    local function OpenESPMenu()
        if IsValid(ESPMenu) then
            ESPMenu:Remove()
        end

        ESPMenu = vgui.Create("DFrame")
        ESPMenu:SetSize(450, 600)
        ESPMenu:SetTitle("GMod Helper Menu")
        ESPMenu:Center()
        ESPMenu:MakePopup()

        -- Create a property sheet for categories
        local sheet = vgui.Create("DPropertySheet", ESPMenu)
        sheet:Dock(FILL)

        -- ESP Category
        local espPanel = vgui.Create("DPanel", sheet)
        espPanel:SetBackgroundColor(Color(50, 50, 50, 255))
        sheet:AddSheet("ESP", espPanel, "icon16/eye.png")

        -- Checkbox for enabling ESP
        local enabledCheckBox = vgui.Create("DCheckBoxLabel", espPanel)
        enabledCheckBox:SetPos(10, 10)
        enabledCheckBox:SetText("Enabled")
        enabledCheckBox:SetValue(espSettings.enabled)
        enabledCheckBox:SizeToContents()
        enabledCheckBox.OnChange = function(_, val)
            espSettings.enabled = val
        end

        -- Name display checkbox
        local nameCheckBox = vgui.Create("DCheckBoxLabel", espPanel)
        nameCheckBox:SetPos(10, 30)
        nameCheckBox:SetText("Name")
        nameCheckBox:SetValue(espSettings.showName)
        nameCheckBox:SizeToContents()
        nameCheckBox.OnChange = function(_, val)
            espSettings.showName = val
        end

        -- Health display checkbox
        local healthCheckBox = vgui.Create("DCheckBoxLabel", espPanel)
        healthCheckBox:SetPos(10, 50)
        healthCheckBox:SetText("Health")
        healthCheckBox:SetValue(espSettings.showHealth)
        healthCheckBox:SizeToContents()
        healthCheckBox.OnChange = function(_, val)
            espSettings.showHealth = val
        end

        -- Weapon display checkbox
        local weaponCheckBox = vgui.Create("DCheckBoxLabel", espPanel)
        weaponCheckBox:SetPos(10, 70)
        weaponCheckBox:SetText("Weapon")
        weaponCheckBox:SetValue(espSettings.showWeapon)
        weaponCheckBox:SizeToContents()
        weaponCheckBox.OnChange = function(_, val)
            espSettings.showWeapon = val
        end

        -- Snapline display checkbox
        local snaplineCheckBox = vgui.Create("DCheckBoxLabel", espPanel)
        snaplineCheckBox:SetPos(10, 90)
        snaplineCheckBox:SetText("Snaplines")
        snaplineCheckBox:SetValue(espSettings.showSnaplines)
        snaplineCheckBox:SizeToContents()
        snaplineCheckBox.OnChange = function(_, val)
            espSettings.showSnaplines = val
        end

        -- Distance display checkbox
        local distanceCheckBox = vgui.Create("DCheckBoxLabel", espPanel)
        distanceCheckBox:SetPos(10, 110)
        distanceCheckBox:SetText("Show Distance")
        distanceCheckBox:SetValue(espSettings.showDistance)
        distanceCheckBox:SizeToContents()
        distanceCheckBox.OnChange = function(_, val)
            espSettings.showDistance = val
        end

        -- Toggle 2D Box display
        local box2DCheckBox = vgui.Create("DCheckBoxLabel", espPanel)
        box2DCheckBox:SetPos(10, 130)
        box2DCheckBox:SetText("Show 2D Box")
        box2DCheckBox:SetValue(espSettings.show2DBox)
        box2DCheckBox:SizeToContents()
        box2DCheckBox.OnChange = function(_, val)
            espSettings.show2DBox = val
        end

        -- Chams option
        local chamsCheckBox = vgui.Create("DCheckBoxLabel", espPanel)
        chamsCheckBox:SetPos(10, 150)
        chamsCheckBox:SetText("Chams (See-through)")
        chamsCheckBox:SetValue(espSettings.showChams)
        chamsCheckBox:SizeToContents()
        chamsCheckBox.OnChange = function(_, val)
            espSettings.showChams = val
        end

        -- Role display checkbox
        local roleCheckBox = vgui.Create("DCheckBoxLabel", espPanel)
        roleCheckBox:SetPos(10, 170)
        roleCheckBox:SetText("Show Role")
        roleCheckBox:SetValue(espSettings.showRole)
        roleCheckBox:SizeToContents()
        roleCheckBox.OnChange = function(_, val)
            espSettings.showRole = val
        end


        -- In the ESP panel

        local glowCheckBox = vgui.Create("DCheckBoxLabel", espPanel)
        glowCheckBox:SetPos(10, 250)
        glowCheckBox:SetText("Enable Player Glow")
        glowCheckBox:SetValue(espSettings.showGlow)
        glowCheckBox:SizeToContents()
        glowCheckBox.OnChange = function(_, val)
        espSettings.showGlow = val
        end
                
        local glowColorPicker = vgui.Create("DColorMixer", espPanel)
        glowColorPicker:SetPos(10, 280)
        glowColorPicker:SetSize(200, 150)
        glowColorPicker:SetPalette(true)
        glowColorPicker:SetAlphaBar(true)
        glowColorPicker:SetWangs(true)
        glowColorPicker:SetColor(espSettings.glowColor or Color(255, 0, 0))
        glowColorPicker.ValueChanged = function(_, color)
        espSettings.glowColor = color    
        end


        -- Aimbot Category
        local aimbotPanel = vgui.Create("DPanel", sheet)
        aimbotPanel:SetBackgroundColor(Color(50, 50, 50, 255))
        sheet:AddSheet("Aimbot", aimbotPanel, "icon16/bomb.png")

        -- Aimbot toggle
        local aimbotCheckBox = vgui.Create("DCheckBoxLabel", aimbotPanel)
        aimbotCheckBox:SetPos(10, 10)
        aimbotCheckBox:SetText("Enable Aimbot")
        aimbotCheckBox:SetValue(espSettings.aimbotEnabled)
        aimbotCheckBox:SizeToContents()
        aimbotCheckBox.OnChange = function(_, val)
            espSettings.aimbotEnabled = val
        end

        -- Aim smoothness slider
        local smoothSlider = vgui.Create("DNumSlider", aimbotPanel)
        smoothSlider:SetPos(10, 40)
        smoothSlider:SetSize(300, 20)
        smoothSlider:SetMin(0.01)
        smoothSlider:SetMax(1)
        smoothSlider:SetDecimals(2)
        smoothSlider:SetText("Aim Smoothness")
        smoothSlider:SetValue(espSettings.aimSmoothness)
        smoothSlider.OnValueChanged = function(_, val)
            espSettings.aimSmoothness = val
        end

        -- Aim FOV slider (affects both the aimbot and the FOV circle)
        local fovSlider = vgui.Create("DNumSlider", aimbotPanel)
        fovSlider:SetPos(10, 70)
        fovSlider:SetSize(300, 20)
        fovSlider:SetMin(10)
        fovSlider:SetMax(500)
        fovSlider:SetText("Aimbot FOV & FOV Circle")
        fovSlider:SetValue(espSettings.aimFOV)
        fovSlider.OnValueChanged = function(_, val)
            espSettings.aimFOV = val
        end

        -- Max distance slider for aimbot
        local distanceSlider = vgui.Create("DNumSlider", aimbotPanel)
        distanceSlider:SetPos(10, 100)
        distanceSlider:SetSize(300, 20)
        distanceSlider:SetMin(500)
        distanceSlider:SetMax(5000)
        distanceSlider:SetText("Max Aimbot Distance")
        distanceSlider:SetValue(espSettings.maxDistance)
        distanceSlider.OnValueChanged = function(_, val)
            espSettings.maxDistance = val
        end

        -- FOV Circle Toggle
        local fovCircleCheckBox = vgui.Create("DCheckBoxLabel", aimbotPanel)
        fovCircleCheckBox:SetPos(10, 160)
        fovCircleCheckBox:SetText("Show FOV Circle")
        fovCircleCheckBox:SetValue(espSettings.showFOVCircle)
        fovCircleCheckBox:SizeToContents()
        fovCircleCheckBox.OnChange = function(_, val)
            espSettings.showFOVCircle = val
        end

        -- Aimbot visibility check toggle in the aimbot panel
        local visibilityCheckBox = vgui.Create("DCheckBoxLabel", aimbotPanel)
        visibilityCheckBox:SetPos(10, 190)
        visibilityCheckBox:SetText("Check Visibility (Ignore players behind walls)")
        visibilityCheckBox:SetValue(espSettings.checkVisibility)
        visibilityCheckBox:SizeToContents()
        visibilityCheckBox.OnChange = function(_, val)
            espSettings.checkVisibility = val
        end


        -- Bone selection (Head by default)
        local boneLabel = vgui.Create("DLabel", aimbotPanel)
        boneLabel:SetPos(10, 130)
        boneLabel:SetText("Aim Bone:")
        boneLabel:SizeToContents()

        local boneCombo = vgui.Create("DComboBox", aimbotPanel)
        boneCombo:SetPos(100, 130)
        boneCombo:SetSize(150, 20)
        boneCombo:SetValue("Head")
        boneCombo:AddChoice("Head")
        boneCombo:AddChoice("Spine")
        boneCombo:AddChoice("Pelvis")
        boneCombo.OnSelect = function(_, _, value)
            if value == "Head" then
                espSettings.aimBone = "ValveBiped.Bip01_Head1"
            elseif value == "Spine" then
                espSettings.aimBone = "ValveBiped.Bip01_Spine"
            elseif value == "Pelvis" then
                espSettings.aimBone = "ValveBiped.Bip01_Pelvis"
            end
        end

        -- Other Settings Category
        local otherPanel = vgui.Create("DPanel", sheet)
        otherPanel:SetBackgroundColor(Color(50, 50, 50, 255))
        sheet:AddSheet("Other Settings", otherPanel, "icon16/cog.png")

        -- Distance limit slider
        local distanceLimitSlider = vgui.Create("DNumSlider", otherPanel)
        distanceLimitSlider:SetPos(10, 10)
        distanceLimitSlider:SetSize(300, 20)
        distanceLimitSlider:SetMin(1000)
        distanceLimitSlider:SetMax(7500)
        distanceLimitSlider:SetValue(espSettings.distanceLimit)
        distanceLimitSlider:SetText("Distance Limit")
        distanceLimitSlider.OnValueChanged = function(_, val)
            espSettings.distanceLimit = val
        end

        -- Distance unit combo box (meters or feet)
        local distanceUnitLabel = vgui.Create("DLabel", otherPanel)
        distanceUnitLabel:SetPos(10, 50)
        distanceUnitLabel:SetText("Distance Unit:")
        distanceUnitLabel:SizeToContents()

        local distanceUnitCombo = vgui.Create("DComboBox", otherPanel)
        distanceUnitCombo:SetPos(120, 50)
        distanceUnitCombo:SetSize(100, 20)
        distanceUnitCombo:SetValue(espSettings.distanceUnit)
        distanceUnitCombo:AddChoice("meters")
        distanceUnitCombo:AddChoice("feet")
        distanceUnitCombo:AddChoice("units")
        distanceUnitCombo.OnSelect = function(_, _, value)
            espSettings.distanceUnit = value
        end


    -- Override the paint function to apply a rainbow background if enabled
    ESPMenu.Paint = function(self, w, h)
        if espSettings.rainbowMenu then
            local hue = (CurTime() * 100) % 360 -- Calculate hue based on time
            local color = HSVToColor(hue, 1, 1) -- Convert hue to RGB
            surface.SetDrawColor(color.r, color.g, color.b, color.a)
        else
            surface.SetDrawColor(50, 50, 50, 255) -- Default background color
        end
        surface.DrawRect(0, 0, w, h) -- Draw the background
    end
    
-- Misc Category
        local miscPanel = vgui.Create("DPanel", sheet)
        miscPanel:SetBackgroundColor(Color(50, 50, 50, 255))
        sheet:AddSheet("Misc", miscPanel, "icon16/star.png")
    

        -- FOV Slider for adjusting FOV
        local fovSlider = vgui.Create("DNumSlider", miscPanel)
        fovSlider:SetPos(10, 50)
        fovSlider:SetSize(300, 20)
        fovSlider:SetMin(10)
        fovSlider:SetMax(150)
        fovSlider:SetText("Adjust FOV")
        fovSlider:SetValue(espSettings.adjustFOV or 90) -- Default to 90 FOV
        fovSlider.OnValueChanged = function(_, val)
            espSettings.adjustFOV = val
            LocalPlayer():SetFOV(val, 0) -- Apply the FOV in real-time
        end

        -- FOV Reset Button to reset to default Garry's Mod FOV (90)
        local fovResetButton = vgui.Create("DButton", miscPanel)
        fovResetButton:SetPos(10, 70)
        fovResetButton:SetSize(100, 30)
        fovResetButton:SetText("Reset FOV")
        fovResetButton.DoClick = function()
            espSettings.adjustFOV = 90 -- Reset the value in the settings to 90
            fovSlider:SetValue(90) -- Reset the slider to 90
            LocalPlayer():SetFOV(90, 0) -- Reset the FOV back to the default (90)
        end


                -- Add rainbow menu toggle to the Misc section
        local rainbowMenuCheckBox = vgui.Create("DCheckBoxLabel", miscPanel)
        rainbowMenuCheckBox:SetPos(10, 10)  -- Adjusted position, ensuring it's below other elements
        rainbowMenuCheckBox:SetText("Enable Rainbow Menu")
        rainbowMenuCheckBox:SetValue(espSettings.rainbowMenu or false)
        rainbowMenuCheckBox:SizeToContents()
        rainbowMenuCheckBox.OnChange = function(_, val)
            espSettings.rainbowMenu = val
        end



    end
    
    -- Custom function to draw a circle
    local function DrawCircle(x, y, radius, seg, color)
        local cir = {}

        table.insert(cir, { x = x, y = y })

        for i = 0, seg do
            local a = math.rad((i / seg) * -360)
            table.insert(cir, { x = x + math.sin(a) * radius, y = y + math.cos(a) * radius })
        end

        surface.SetDrawColor(color)
        surface.DrawPoly(cir)
    end


    -- Custom function to draw a wireframe circle (just the outline)
    local function DrawWireframeCircle(x, y, radius, seg, color)
        surface.SetDrawColor(color)

        local cir = {}

        for i = 0, seg do
            local a = math.rad((i / seg) * 360)
            table.insert(cir, { x = x + math.sin(a) * radius, y = y + math.cos(a) * radius })
        end

        -- Draw connected lines between the points to form the wireframe circle
        for i = 1, #cir - 1 do
            surface.DrawLine(cir[i].x, cir[i].y, cir[i + 1].x, cir[i + 1].y)
        end
        -- Connect the last point to the first to complete the circle
        surface.DrawLine(cir[#cir].x, cir[#cir].y, cir[1].x, cir[1].y)
    end




    -- Function to draw FOV circle as a wireframe (round line)
    local function DrawFOVCircle()
        if not espSettings.showFOVCircle then return end

        -- Reset any previous material override
        render.MaterialOverride(nil)

        -- Ensure no textures are used for the circle
        draw.NoTexture()

        local screenCenterX, screenCenterY = ScrW() / 2, ScrH() / 2
        local fovRadius = espSettings.aimFOV or 200 -- Get FOV radius from the aimbot settings

        -- Default to white color for the wireframe outline
        local color = Color(255, 255, 255, 255)

        -- Draw the wireframe circle
        DrawWireframeCircle(screenCenterX, screenCenterY, fovRadius, 100, color)
    end

    -- Function to dynamically calculate the 2D box size based on player distance

    local function CalculateBox(target)
        local ply = LocalPlayer()
        local distance = ply:GetPos():Distance(target:GetPos())

        -- Scale the box based on distance (closer = bigger)
        local scale = math.Clamp(2000 / distance, 0.5, 1.5)
        local min, max = target:OBBMins(), target:OBBMaxs()
        local targetPos = target:GetPos()
        local headPos = target:GetPos() + Vector(0, 0, max.z) -- Head of the player
        local feetPos = target:GetPos() -- Feet of the player

        -- Calculate 2D screen positions
        local screenPosTop = headPos:ToScreen()
        local screenPosBottom = feetPos:ToScreen()
        local boxHeight = (screenPosBottom.y - screenPosTop.y) * scale
        local boxWidth = boxHeight / 2 -- Aspect ratio for box width
        return screenPosTop, screenPosBottom, boxWidth, boxHeight, distance

    end



    -- Function to apply chams (through walls visibility)

    local function ApplyChams(target)

        if not espSettings.showChams then return end
            cam.Start3D()
            render.MaterialOverride(Material("models/wireframe"))
            render.SuppressEngineLighting(true)
            target:DrawModel()
            render.SuppressEngineLighting(false)
            render.MaterialOverride(nil)
            cam.End3D()
    end


    -- Function to perform visibility check using a trace line
    local function IsPlayerVisible(target)
        local ply = LocalPlayer()
        local targetPos = target:GetBonePosition(target:LookupBone(espSettings.aimBone)) or target:GetPos()
        
        -- Trace from player's eye position to target's bone position
        local trace = util.TraceLine({
            start = ply:EyePos(),
            endpos = targetPos,
            filter = ply, -- Ignore the player doing the tracing
            mask = MASK_SHOT -- Ensure we check against walls and solid objects
        })

        return not trace.Hit or trace.Entity == target -- Returns true if no hit or the hit entity is the target
    end

    -- Function to find the best target for aimbot
    local function FindAimbotTarget()
        local ply = LocalPlayer()
        local closestTarget = nil
        local closestDist = espSettings.aimFOV

        for _, target in pairs(player.GetAll()) do
            if target == ply or not target:Alive() or not IsValid(target) then continue end

            -- Perform visibility check if the setting is enabled
            if espSettings.checkVisibility and not IsPlayerVisible(target) then
                continue -- Skip this target if they are behind a wall
            end

            local targetPos = target:GetBonePosition(target:LookupBone(espSettings.aimBone))
            local screenPos = targetPos:ToScreen()
            local distToCrosshair = math.Distance(ScrW() / 2, ScrH() / 2, screenPos.x, screenPos.y)

            local distanceToPlayer = ply:GetPos():Distance(target:GetPos())
            if distToCrosshair <= closestDist and distanceToPlayer <= espSettings.maxDistance then
                closestTarget = target
                closestDist = distToCrosshair
            end
        end

        return closestTarget
    end


    -- Aimbot function to adjust aim towards the target
    local function AimAtTarget(target)
        if not IsValid(target) then return end

        local ply = LocalPlayer()
        local boneID = target:LookupBone(espSettings.aimBone)
        if not boneID then return end

        local targetPos = target:GetBonePosition(boneID)
        local aimAng = (targetPos - ply:GetShootPos()):Angle()
        
        -- Smooth aiming (lerp to avoid snapping)
        ply:SetEyeAngles(LerpAngle(espSettings.aimSmoothness, ply:EyeAngles(), aimAng))
    end
    
    -- Function to draw rainbow text
    local function DrawRainbowText()
        -- Get the current time-based hue, and mod it by 360 to keep it within the 0-360 range
        local hue = (CurTime() * 100) % 360 
        -- Convert the hue to RGB using Garry's Mod's built-in function
        local color = HSVToColor(hue, 1, 1)

        -- Draw the text with the calculated color
        draw.SimpleText(
            "Menu Initialized",  -- The text to display
            "Trebuchet24",       -- Font to use
            10, 10,              -- X, Y position on the screen
            color,               -- Rainbow color based on the hue
            TEXT_ALIGN_LEFT,     -- Horizontal alignment
            TEXT_ALIGN_TOP       -- Vertical alignment
        )
    end

    -- Hook into HUDPaint to draw the rainbow text efficiently
    hook.Add("HUDPaint", "ShowRainbowText", DrawRainbowText)

    
    
        -- Hook to run the aimbot in the game loop
    hook.Add("Think", "Aimbot_Think", function()
        if not espSettings.aimbotEnabled then return end

        local target = FindAimbotTarget()
        if target then
            AimAtTarget(target)
        end
    end)
    

    -- Adjust FOV in real-time
    hook.Add("CalcView", "AdjustFOV", function(ply, pos, angles, fov)
        if espSettings.adjustFOV then
            return { fov = espSettings.adjustFOV }
        end
    end)



    -- Keybind for toggling the ESP menu
    hook.Add("Think", "ESP_OpenMenu", function()
        if input.IsKeyDown(KEY_INSERT) and CurTime() > lastToggleTime + 0.15 then
            if not espMenuOpen then
                OpenESPMenu()
                espMenuOpen = true
            else
                if IsValid(ESPMenu) then
                    ESPMenu:Remove()
                end
                espMenuOpen = false
            end
            lastToggleTime = CurTime() -- Update the last toggle time
        end
    end)

    -- Hook for glow effect
    hook.Add("PreDrawHalos", "AddPlayerGlow", function()
        if not espSettings.showGlow then return end
        local players = {}
        for _, ply in pairs(player.GetAll()) do
            if ply != LocalPlayer() and ply:Alive() then
                table.insert(players, ply)
            end
        end
        halo.Add(players, espSettings.glowColor or Color(255, 0, 0), 1, 1, 2, true, true)
    end)




    -- Function to draw ESP in 2D (HUDPaint)
    hook.Add("HUDPaint", "ESP_Draw2D", function()
        if not espSettings.enabled then return end

        local ply = LocalPlayer()

        for _, target in pairs(player.GetAll()) do
            if target == ply or not target:Alive() or not IsValid(target) then continue end

            local distance = ply:GetPos():Distance(target:GetPos())
            if distance > espSettings.distanceLimit then continue end

            -- Get 2D box and positions
            local screenPosTop, screenPosBottom, boxWidth, boxHeight, dist = CalculateBox(target)

            -- Draw 2D Box if enabled
            if espSettings.show2DBox then
                surface.SetDrawColor(GetHealthColor(target:Health()))
                surface.DrawOutlinedRect(screenPosTop.x - boxWidth / 2, screenPosTop.y, boxWidth, boxHeight)
            end

            -- Show snaplines from the bottom of the screen to the player's feet
            if espSettings.showSnaplines then
                surface.SetDrawColor(GetHealthColor(target:Health()))
                surface.DrawLine(ScrW() / 2, ScrH(), screenPosBottom.x, screenPosBottom.y)
            end

            -- Show player name
            if espSettings.showName then
                draw.SimpleText(target:Nick(), "DermaDefault", screenPosTop.x, screenPosTop.y - 15, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
            end

            -- Show player health
            if espSettings.showHealth then
                draw.SimpleText("HP: " .. target:Health(), "DermaDefault", screenPosBottom.x, screenPosBottom.y + 5, Color(0, 255, 0, 255), TEXT_ALIGN_CENTER)
            end

            -- Show active weapon
            if espSettings.showWeapon and IsValid(target:GetActiveWeapon()) then
                draw.SimpleText("Weapon: " .. target:GetActiveWeapon():GetClass(), "DermaDefault", screenPosBottom.x, screenPosBottom.y + 25, Color(255, 255, 0, 255), TEXT_ALIGN_CENTER)
            end

            -- Show role (if available)
            if espSettings.showRole and target:GetUserGroup() then
                draw.SimpleText("Role: " .. target:GetUserGroup(), "DermaDefault", screenPosTop.x, screenPosTop.y - 30, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
            end

            -- Show distance to the player
            if espSettings.showDistance then
                draw.SimpleText("Distance: " .. ConvertDistance(distance), "DermaDefault", screenPosBottom.x, screenPosBottom.y + 45, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
            end

            -- Apply chams if enabled
            ApplyChams(target)
        end

        -- Draw FOV Circle if enabled
        DrawFOVCircle()
    end)
end
