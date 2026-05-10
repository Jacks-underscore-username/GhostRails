local GHOST_RAILS = {
    ["ghost-straight-rail"] = true,
    ["ghost-curved-rail-a"] = true,
    ["ghost-curved-rail-b"] = true,
}

local SENTINEL = "ghost-rail-sentinel"

local function place_sentinel(ghost_rail)
    local surface = ghost_rail.surface
    local force   = ghost_rail.force
    local pos     = ghost_rail.position

    local s       = surface.create_entity {
        name        = SENTINEL,
        position    = pos,
        direction   = ghost_rail.direction,
        force       = force,
        raise_built = false,
    }
    return (s and s.valid) and s or nil
end

local function on_ghost_rail_built(entity)
    if not GHOST_RAILS[entity.name] then return end

    local sentinel = place_sentinel(entity)
    if not sentinel then return end

    storage.ghost_rail_sentinels           = storage.ghost_rail_sentinels or {}
    storage.sentinel_to_rail               = storage.sentinel_to_rail or {}

    local rail_key                         = script.register_on_object_destroyed(entity)
    local sentinel_key                     = script.register_on_object_destroyed(sentinel)

    storage.ghost_rail_sentinels[rail_key] = { key = sentinel_key, entity = sentinel }
    storage.sentinel_to_rail[sentinel_key] = rail_key
end

local function on_object_destroyed(event)
    local key                    = event.registration_number
    storage.ghost_rail_sentinels = storage.ghost_rail_sentinels or {}
    storage.sentinel_to_rail     = storage.sentinel_to_rail or {}

    if storage.ghost_rail_sentinels[key] then
        local entry = storage.ghost_rail_sentinels[key]
        if entry.entity and entry.entity.valid then
            entry.entity.destroy()
        end
        storage.sentinel_to_rail[entry.key] = nil
        storage.ghost_rail_sentinels[key]   = nil
    elseif storage.sentinel_to_rail[key] then
        local rail_key                         = storage.sentinel_to_rail[key]
        storage.ghost_rail_sentinels[rail_key] = nil
        storage.sentinel_to_rail[key]          = nil
    end
end

local TRAIN_TYPES = {
    locomotive          = true,
    ["cargo-wagon"]     = true,
    ["fluid-wagon"]     = true,
    ["artillery-wagon"] = true,
}

local function explode_train(train)
    for _, carriage in pairs(train.carriages) do
        if carriage.valid then
            carriage.surface.create_entity {
                name     = "explosion",
                position = carriage.position,
                force    = carriage.force,
            }
            carriage.die()
        end
    end
end

local function on_entity_damaged(event)
    if event.entity.name ~= SENTINEL then return end
    local cause = event.cause
    if not (cause and cause.valid and TRAIN_TYPES[cause.type]) then return end

    explode_train(cause.train)
end

local RAIL_FILTERS = {
    { filter = "type", type = "straight-rail" },
    { filter = "type", type = "curved-rail-a", mode = "or" },
    { filter = "type", type = "curved-rail-b", mode = "or" },
}

script.on_event(defines.events.on_built_entity, function(e) on_ghost_rail_built(e.entity) end, RAIL_FILTERS)
script.on_event(defines.events.on_robot_built_entity, function(e) on_ghost_rail_built(e.entity) end, RAIL_FILTERS)
script.on_event(defines.events.script_raised_built, function(e) on_ghost_rail_built(e.entity) end)
script.on_event(defines.events.script_raised_revive, function(e) on_ghost_rail_built(e.entity) end)
script.on_event(defines.events.on_entity_cloned, function(e) on_ghost_rail_built(e.destination) end)

script.on_event(defines.events.on_object_destroyed, on_object_destroyed)

script.on_event(defines.events.on_entity_damaged, on_entity_damaged,
    { { filter = "name", name = SENTINEL } })

script.on_init(function()
    storage.ghost_rail_sentinels = {}
    storage.sentinel_to_rail     = {}
end)

script.on_configuration_changed(function()
    storage.ghost_rail_sentinels = storage.ghost_rail_sentinels or {}
    storage.sentinel_to_rail     = storage.sentinel_to_rail or {}
end)
