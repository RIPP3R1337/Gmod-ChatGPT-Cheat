-- Assuming this is part of your script
    include("cheat/bonesArray.lua")
    include("cheat/espMenu.lua")

-- Original Code:
if CLIENT then -- Ensure the script only runs client-side

    
    -- Menu state
    espMenuOpen = false
    lastToggleTime = 0 -- Variable to track the last time F2 was pressed


        -- Function to draw a skeleton on a player
    local function DrawSkeleton(player)
        if not player:Alive() then return end

        for _, bonePair in ipairs(skeletonBones) do
            local bone1Index = player:LookupBone(bonePair[1])
            local bone2Index = player:LookupBone(bonePair[2])

            if bone1Index and bone2Index then
                local bone1Pos, _ = player:GetBonePosition(bone1Index)
                local bone2Pos, _ = player:GetBonePosition(bone2Index)

                -- Convert bone positions to screen coordinates
                local bone1ScreenPos = bone1Pos:ToScreen()
                local bone2ScreenPos = bone2Pos:ToScreen()

                -- Draw the line between the two bones
                surface.SetDrawColor(255, 0, 0, 255) -- Red color for the skeleton lines
                surface.DrawLine(bone1ScreenPos.x, bone1ScreenPos.y, bone2ScreenPos.x, bone2ScreenPos.y)
            end
        end
    end
    
    
    
    -- Rainbow function
    local function RainbowColor()
        local hue = (CurTime() * 100) % 360 -- Calculate hue based on time
        local color = HSVToColor(hue, 1, 1) -- Convert hue to RGB

        color.a = 255
        return color
    end

    

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

-- Hook for Bunnyhop logic
hook.Add("CreateMove", "BunnyhopHook", function(cmd)
    local player = LocalPlayer()
    if not player:IsValid() or not player:Alive() then return end -- Ensure player is valid and alive

    -- Only execute if bunnyhop is enabled
    if espSettings.bunnyHopMenu then
        -- Check if the player is on the ground and pressing the jump key
        if input.IsKeyDown(KEY_SPACE) then
            -- If player is on the ground, allow jumping
            if player:OnGround() then
                cmd:SetButtons(bit.bor(cmd:GetButtons(), IN_JUMP))
            else
                -- Clear jump input to avoid "holding jump" while in air
                cmd:RemoveKey(IN_JUMP)
            end
        end
    end
end)

--[[
    hook.Add("HUDPaint", "DrawSkeletonESP", function()

        if not espSettings.skeletonEnabled then return end

        for _, player in ipairs(player.GetAll()) do
            if player ~= LocalPlayer() and player:Alive() then
                DrawSkeleton(player)
            end
        end
    end)
--]]

    -- Hook to draw enabled settings on the screen
    hook.Add("HUDPaint", "DrawEnabledFeatures", function()
        local x, y = 10, 50 -- Top left corner position
        local enabledFeatures = {}

        -- Check which features are enabled and add them to the list
        if espSettings.bunnyHopMenu then
            table.insert(enabledFeatures, "- Bunnyhop Enabled")
        end
        if espSettings.enabled then
            table.insert(enabledFeatures, "- ESP Menu Enabled")
        end
        if espSettings.showFOVCircle then
            table.insert(enabledFeatures, "- FOV Circle Enabled")
        end
        if espSettings.aimbotEnabled then
            table.insert(enabledFeatures, "- Aimbot Enabled")
        end
        if espSettings.showHealth then
            table.insert(enabledFeatures, "- HealthCheck Enabled")
        end
        if espSettings.showName then
            table.insert(enabledFeatures, "- NameCheck Enabled")
        end
        if espSettings.showSnaplines then
            table.insert(enabledFeatures, "- Snaplines Enabled")
        end
        if espSettings.showWeapon then
            table.insert(enabledFeatures, "- WeaponCheck Enabled")
        end
        if espSettings.showRole then
            table.insert(enabledFeatures, "- RoleCheck Enabled")
        end
        if espSettings.show2DBox then
            table.insert(enabledFeatures, "- 2D Box Enabled")
        end
        if espSettings.showChams then
            table.insert(enabledFeatures, "- Chams Enabled")
        end
        if espSettings.skeletonEnabled then
            table.insert(enabledFeatures, "- Skeleton Enabled")
        end

        -- Add more checks for other features you have

        -- Draw each enabled feature with the rainbow color
        for i, feature in ipairs(enabledFeatures) do
            local rainbowColor = RainbowColor() -- Use the rainbow function

            -- Draw the text with the rainbow color
            draw.SimpleText(feature, "Trebuchet24", x, y + (i - 1) * 20, rainbowColor, TEXT_ALIGN_LEFT)
        end
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


            -- Draw skeleton if enabled
            if espSettings.skeletonEnabled then
                if target ~= LocalPlayer() and target:Alive() then
                    DrawSkeleton(target)
                end
            end



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


