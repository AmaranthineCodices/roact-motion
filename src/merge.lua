--[[
    A simple function for merging two tables together to form a new table.
    Later tables overwrite earlier ones, i.e. merge(a, b) causes keys from b to
    overwrite keys from a, if there is a conflict.
]]

return function(...)
    local merged = {}
    local count = select("#", ...)

    for i = 1, count do
        local current = select(i, ...)

        for key, value in pairs(current) do
            merged[key] = value
        end
    end

    return merged
end