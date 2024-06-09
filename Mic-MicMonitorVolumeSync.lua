obs = obslua

source_name_1 = "Mic/Aux"  -- Replace with your first audio source name
source_name_2 = "Desktop Audio"  -- Replace with your second audio source name

prev_volume_1 = 0
prev_volume_2 = 0
last_time = 0

function script_description()
    return "Synchronize audio levels between two sources."
end

function script_properties()
    local props = obs.obs_properties_create()
    obs.obs_properties_add_text(props, "source_name_1", "Audio Source 1", obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(props, "source_name_2", "Audio Source 2", obs.OBS_TEXT_DEFAULT)
    return props
end

function script_update(settings)
    source_name_1 = obs.obs_data_get_string(settings, "source_name_1")
    source_name_2 = obs.obs_data_get_string(settings, "source_name_2")
end

function get_volume(source_name)
    local source = obs.obs_get_source_by_name(source_name)
    if source then
        local volume = obs.obs_source_get_volume(source)
        obs.obs_source_release(source)
        return volume
    end
    return nil
end

function set_volume(source_name, volume)
    local source = obs.obs_get_source_by_name(source_name)
    if source then
        obs.obs_source_set_volume(source, volume)
        obs.obs_source_release(source)
    end
end

function script_tick(seconds)
    local current_time = os.clock()
    if current_time - last_time >= 0.05 then  -- Run every 0.05 seconds
        last_time = current_time

        local volume_1 = get_volume(source_name_1)
        local volume_2 = get_volume(source_name_2)
        
        if volume_1 and volume_2 then
            if volume_1 ~= prev_volume_1 then
                set_volume(source_name_2, volume_1)
                prev_volume_1 = volume_1
                prev_volume_2 = volume_1
            elseif volume_2 ~= prev_volume_2 then
                set_volume(source_name_1, volume_2)
                prev_volume_1 = volume_2
                prev_volume_2 = volume_2
            end
        end
    end
end
