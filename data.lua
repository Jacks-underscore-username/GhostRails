local GHOST_TINT = { 15, 133, 255, 112 }

local function tint_pictures(t)
    if type(t) ~= "table" then return end
    if t.filename then
        if not t.draw_as_shadow then
            t.tint = GHOST_TINT
        end
    else
        for k, v in pairs(t) do
            if k ~= "segment_visualisation_endings" then
                tint_pictures(v)
            end
        end
    end
end

local recipe                = table.deepcopy(data.raw["recipe"]["rail"])
recipe.name                 = "ghost-rail"
recipe.localised_name       = { "recipe-name.ghost-rail" }
recipe.ingredients          = { { type = "item", name = "rail", amount = 1 } }
recipe.results              = { { type = "item", name = "ghost-rail", amount = 100 } }

local item                  = table.deepcopy(data.raw["rail-planner"]["rail"])
item.name                   = "ghost-rail"
item.localised_name         = { "item-name.ghost-rail" }
item.place_result           = "ghost-straight-rail"
item.rails                  = {
    "ghost-straight-rail",
    "ghost-curved-rail-a",
    "ghost-curved-rail-b"
}
item.icons                  = {
    {
        icon      = item.icon,
        icon_size = item.icon_size,
        tint      = {
            r = GHOST_TINT[1] / 255,
            g = GHOST_TINT[2] / 255,
            b = GHOST_TINT[3] / 255,
            a = GHOST_TINT[4] / 255,
        },
    },
}
item.icon                   = nil
item.icon_size              = nil

local straightRail          = table.deepcopy(data.raw["straight-rail"]["straight-rail"])
straightRail.name           = "ghost-straight-rail"
straightRail.collision_mask = { layers = { rail = true } }
straightRail.minable.result = "ghost-rail"
tint_pictures(straightRail.pictures)

local curvedRailA = table.deepcopy(data.raw["curved-rail-a"]["curved-rail-a"])
curvedRailA.name = "ghost-curved-rail-a"
curvedRailA.collision_mask = { layers = { rail = true } }
curvedRailA.minable.result = "ghost-rail"
curvedRailA.placeable_by.item = "ghost-rail"
tint_pictures(curvedRailA.pictures)

local curvedRailB = table.deepcopy(data.raw["curved-rail-b"]["curved-rail-b"])
curvedRailB.name = "ghost-curved-rail-b"
curvedRailB.collision_mask = { layers = { rail = true } }
curvedRailB.minable.result = "ghost-rail"
curvedRailB.placeable_by.item = "ghost-rail"
tint_pictures(curvedRailB.pictures)

local sentinel = {
    type = "simple-entity-with-owner",
    name = "ghost-rail-sentinel",
    icon = "__core__/graphics/empty.png",
    icon_size = 1,
    flags = {
        "placeable-neutral", "placeable-off-grid",
        "not-on-map", "not-blueprintable", "not-deconstructable",
        "not-selectable-in-game", "building-direction-16-way",
    },
    hidden = true,
    max_health = 1,
    collision_box = { { -1.32, -1.9 }, { 1.32, 1.9 } },
    collision_mask = { layers = { train = true }, not_colliding_with_itself = true },
    selection_box = { { 0, 0 }, { 0, 0 } },
    resistances = {
        { type = "impact",    percent = 100 },
        { type = "fire",      percent = 100 },
        { type = "explosion", percent = 100 },
        { type = "physical",  percent = 100 },
        { type = "poison",    percent = 100 },
        { type = "acid",      percent = 100 },
    },
    picture = {
        filename = "__core__/graphics/empty.png",
        priority = "low",
        width = 1,
        height = 1,
    },
}

local technology = {
    type = "technology",
    name = "ghost-rails",
    icons = {
        {
            icon      = "__base__/graphics/technology/railway.png",
            icon_size = 256,
            tint      = {
                r = GHOST_TINT[1] / 255,
                g = GHOST_TINT[2] / 255,
                b = GHOST_TINT[3] / 255,
                a = GHOST_TINT[4] / 255,
            },
        },
    },
    prerequisites = { "automated-rail-transportation", "RTFlyingFreight" },
    effects = {
        { type = "unlock-recipe", recipe = "ghost-rail" },
    },
    unit = {
        count = 200,
        ingredients = {
            { "automation-science-pack", 1 },
            { "logistic-science-pack",   1 }
        },
        time = 30,
    },
}

data:extend { recipe, item, straightRail, curvedRailA, curvedRailB, sentinel, technology }
