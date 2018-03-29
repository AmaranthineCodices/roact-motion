--[[
    Helper for accessing spring values.
]]

local SpringHelper = {}

--[[
    Gets a specific spring's value.
]]
function SpringHelper.getValue(value)
    -- Two possible cases:
    -- 1. number (instant-set, no animation). The value is just the value.
    -- 2. table (spring). The spring's value is value.value.

    if typeof(value) == "number" then
        return value
    else
        return value.value
    end
end

--[[
    Gets all the values of a table of springs.
]]
function SpringHelper.getValues(springs)
    local values = {}

    for key, spring in pairs(springs) do
        values[key] = SpringHelper.getValue(spring)
    end

    return values
end

return SpringHelper
