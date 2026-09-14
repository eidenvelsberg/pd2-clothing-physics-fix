if not _G.ClothingPhysicsFix then
    _G.ClothingPhysicsFix = true

    local physics_disabled_until = 0
    local DISABLE_ON_ENTER = 2.0

    local VANILLA_STYLES = dofile(ModPath .. "vanilla_styles.lua") or {}

    local function is_modded_outfit()
        local style = managers.blackmarket and managers.blackmarket:equipped_player_style()
        if not style then return false end
        return not VANILLA_STYLES[style]
    end

    local function set_bodies_enabled(unit, enabled)
        if not alive(unit) or not unit.num_bodies then return end
        for i = 0, unit:num_bodies() - 1 do
            local body = unit:body(i)
            if body then
                body:set_enabled(enabled)
                if not enabled then
                    body:set_velocity(Vector3(0, 0, 0))
                    body:set_angular_velocity(Vector3(0, 0, 0))
                end
            end
        end
    end

    local function get_char()
        local msm = managers.menu_scene
        return msm and msm._character_unit
    end

    Hooks:PostHook(MenuManager, "on_enter", "ClothingPhysicsFix_OnEnter", function()
        physics_disabled_until = TimerManager:game():time() + DISABLE_ON_ENTER

        DelayedCalls:Add("CPF_DisableOnEnter", 0.05, function()
            local unit = get_char()
            if alive(unit) then
                set_bodies_enabled(unit, false)
            end
        end)
    end)

    if MenuSceneManager then

        Hooks:PostHook(MenuSceneManager, "set_character", "ClothingPhysicsFix_SetCharacter", function(self)
            physics_disabled_until = TimerManager:game():time() + DISABLE_ON_ENTER

            DelayedCalls:Add("CPF_DisableOnSetChar", 0.1, function()
                if alive(self._character_unit) then
                    set_bodies_enabled(self._character_unit, false)
                end
            end)
        end)

        Hooks:PostHook(MenuSceneManager, "update", "ClothingPhysicsFix_Update", function(self, t, dt)
            local unit = self._character_unit
            if not alive(unit) then return end

            local now = TimerManager:game():time()

            if now < physics_disabled_until then
                set_bodies_enabled(unit, false)
                return
            end

            if is_modded_outfit() then
                set_bodies_enabled(unit, false)
            else
                set_bodies_enabled(unit, true)
            end
        end)
    end
end
