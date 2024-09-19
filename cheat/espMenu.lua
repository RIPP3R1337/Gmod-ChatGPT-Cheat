    -- Menu creation with categories
    function OpenESPMenu()
        if IsValid(ESPMenu) then
            ESPMenu:Remove()
        end

        ESPMenu = vgui.Create("DFrame")
        ESPMenu:SetSize(450, 600)
        ESPMenu:SetTitle("RIPP3R's GMod Cheat Menu")
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
        enabledCheckBox:SetText("Enable Menu")
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

        local skeletonCheckBox = vgui.Create("DCheckBoxLabel", espPanel)
        skeletonCheckBox:SetPos(10, 190)
        skeletonCheckBox:SetText("Show Skeleton")
        skeletonCheckBox:SizeToContents()
        skeletonCheckBox:SetValue(espSettings.skeletonEnabled)
        skeletonCheckBox:SetToolTip("Draw skeleton on players.")


        skeletonCheckBox.OnChange = function(_, val)
            espSettings.skeletonEnabled = val
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
        boneCombo:SetValue("Neck")
        boneCombo:AddChoice("Head")
        boneCombo:AddChoice("Spine")
        boneCombo:AddChoice("Pelvis")
        boneCombo:AddChoice("Neck")
        boneCombo:SetToolTip("Select the bone to aim at. Options include Head, Spine, and Pelvis.")

        boneCombo.OnSelect = function(_, _, value)
            if value == "Head" then
                espSettings.aimBone = "ValveBiped.Bip01_Head1"
            elseif value == "Spine" then
                espSettings.aimBone = "ValveBiped.Bip01_Spine1"
            elseif value == "Pelvis" then
                espSettings.aimBone = "ValveBiped.Bip01_Pelvis"
            elseif value == "Neck" then
                espSettings.AimBone = "ValveBuped.Bip01_Neck"
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
        distanceUnitCombo:AddChoice("Meters")
        distanceUnitCombo:AddChoice("Feet")
        distanceUnitCombo:AddChoice("Units")
        distanceUnitCombo:SetToolTip("For our EU/US people. Keep Units on if you'd like to know ingame distance for Aimbot/ESP")
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
        fovSlider:SetValue(espSettings.adjustFOV or 100) -- Default to 90 FOV
        fovSlider.OnValueChanged = function(_, val)
            espSettings.adjustFOV = val
            LocalPlayer():SetFOV(val, 0) -- Apply the FOV in real-time
        end

        -- FOV Reset Button to reset to default Garry's Mod FOV (100)
        local fovResetButton = vgui.Create("DButton", miscPanel)
        fovResetButton:SetPos(10, 70)
        fovResetButton:SetSize(100, 30)
        fovResetButton:SetText("Reset FOV")
        fovResetButton.DoClick = function()
            espSettings.adjustFOV = 100 -- Reset the value in the settings to 90
            fovSlider:SetValue(100) -- Reset the slider to 90
            LocalPlayer():SetFOV(100, 0) -- Reset the FOV back to the default (90)
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

        -- Add rainbow menu toggle to the Misc section
        local bunnyHopMenuCheckBox = vgui.Create("DCheckBoxLabel", miscPanel)
        bunnyHopMenuCheckBox:SetPos(10, 30)  -- Adjusted position, ensuring it's below other elements
        bunnyHopMenuCheckBox:SetText("Enable Bunnyhop")
        bunnyHopMenuCheckBox:SetValue(espSettings.bunnyHopMenu or false)
        bunnyHopMenuCheckBox:SizeToContents()
        bunnyHopMenuCheckBox:SetToolTip("You go wee woo")
        bunnyHopMenuCheckBox.OnChange = function(_, val)
            espSettings.bunnyHopMenu = val
        end
    end