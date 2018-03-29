--[[
    A table of configuration values.
    Can be mutated at any time.
]]

return {
    -- The maximum amount of time to spend, per frame, in spring step.
    -- This stops a "spiral of death", where the render function takes so long
    -- to execute that it slows down the framerate, causing the integrator to
    -- work more, which slows down the framerate further, ad infinitum.
    -- See: https://gafferongames.com/post/fix_your_timestep#semi-fixed-timestep
    maximumFrameTime = 0.2,
    -- How many seconds between steps.
    stepInterval = 1 / 120,
    -- The precision to use when stepping springs.
    -- Lower values yield more precise results at the cost of more computational work.
    precision = 1e-2,
    -- The default stiffness of springs if one is not supplied.
    defaultStiffness = 170,
    -- The default damping of springs if one is not supplied.
    defaultDamping = 26,
}
