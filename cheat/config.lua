-- Change anything if you don't like the default settings. You could also change the statments to be automatically true

    -- ESP, Aimbot, and Misc Settings

    espSettings = espSettings or {
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
        skeletonEnabled = false,

        -- Other Settings
        distanceLimit = 3000, -- Default distance set to 3000 units
        distanceUnit = "Units", -- Default distance unit in meters

        -- Aimbot and FOV Settings
        aimbotEnabled = false, -- Toggle aimbot
        aimSmoothness = 0.1, -- Smoothing factor for aimbot aim movement
        aimFOV = 200, -- Field of view radius for the aimbot and FOV circle
        aimBone = "ValveBiped.Bip01_Head1", -- Bone to aim at (head by default)
        maxDistance = 2500, -- Default Maximum distance for the aimbot to work
        showFOVCircle = false, -- FOV Circle Toggle
        checkVisibility = true,

        -- Misc Settings
        adjustFOVEnabled = false,
        adjustFOV = 100


    }