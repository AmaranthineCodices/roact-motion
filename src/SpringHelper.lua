--[[
    Helper for accessing spring values.
]]

local SpringHelper = {}

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

return SpringHelper
