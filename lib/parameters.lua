local parameters = {
    waiting_to_save = false,
    save_on_edit = true,
}

function parameters:init(bool)
    self.save_on_edit = bool == nil and true or bool
    params:add_separator("b i t t e r s")
    params:add{
        type        = "control",
        id          = "amp",
        name        = "volume",
        controlspec = controlspec.new(0, 1, 'lin', 0.01, 0.5),
        action      = function(x)
            engine.bit_set("amp", x)
            parameters:save()
			screen_dirty = true
        end
    }
    params:add{
        type        = "control",
        id          = "degrade",
        name        = "degrade",
        controlspec = controlspec.new(0, 1, 'lin', 0.01, 0),
        action      = function(x)
            engine.bit_set("degrade", x)
            parameters:save()
			screen_dirty = true
        end
    }
    params:add{
        type        = "control",
        id          = "mix",
        name        = "osc mix",
        controlspec = controlspec.new(-1, 1, 'lin', 0.01, 0),
        action      = function(x)
            engine.bit_set("mix", x)
            parameters:save()
			screen_dirty = true
        end
    }
    params:add{
        type        = "control",
        id          = "mpitch",
        name        = "env > pitch",
        controlspec = controlspec.new(0, 1, 'lin', 0.01, 0),
        action      = function(x)
            engine.bit_set("mpitch", x)
            parameters:save()
			screen_dirty = true
        end
    }
    params:add{
        type        = "control",
        id          = "lpitch",
        name        = "lfo > pitch",
        controlspec = controlspec.new(0, 1, 'lin', 0.01, 0),
        action      = function(x)
            engine.bit_set("lpitch", x)
            parameters:save()
			screen_dirty = true
        end
    }
    for i = 1,2 do
        params:add_group("osc "..i, 11 + i)
        params:add{
            type        = "number",
            id          = "octave"..i,
            name        = "octave",
            min         = -2,
            max         = 1,
            default     = 0,
            action      = function(x)
                local val = 12*x + params:get("coarse"..i) + 0.01*params:get("fine"..i)
                engine.bit_set("pitch"..i, val)
                parameters:save()
			screen_dirty = true
            end
        }
        params:add{
            type        = "number",
            id          = "coarse"..i,
            name        = "coarse",
            min         = -12,
            max         = 12,
            default     = 0,
            action      = function(x)
                local val = 12*params:get("octave"..i) + x + 0.01*params:get("fine"..i)
                engine.bit_set("pitch"..i, val)
                parameters:save()
			screen_dirty = true
            end
        }
        params:add{
            type        = "control",
            id          = "fine"..i,
            name        = "fine",
            controlspec = controlspec.new(-100, 100, 'lin', 1, 0, "cents"),
            action      = function(x)
                local val = 12*params:get("octave"..i) + params:get("coarse"..i) + 0.01*x
                engine.bit_set("pitch"..i, val)
                parameters:save()
			screen_dirty = true
            end
        }
        params:add{
            type        = "option",
            id          = "wave"..i,
            name        = "waveform",
            options     = {"triangle", "square"},
            default     = i,
            action      = function(x)
                engine.bit_set("tri"..i, x == 1 and 1 or 0)
                engine.bit_set("pulse"..i, x == 1 and 0 or 1)
                parameters:save()
			screen_dirty = true
            end
        }
        params:add{
            type        = "control",
            id          = "width"..i,
            name        = "width",
            controlspec = controlspec.new(0, 1, 'lin', 0.01, 0.5),
            action      = function(x)
                engine.bit_set("width"..i, x)
                parameters:save()
			screen_dirty = true
            end
        }
        params:add{
            type        = "control",
            id          = "mwidth"..i,
            name        = "env > width",
            controlspec = controlspec.new(0, 1, 'lin', 0.01, 0),
            action      = function(x)
                engine.bit_set("mwidth"..i, x)
                parameters:save()
			screen_dirty = true
            end
        }
        params:add{
            type        = "control",
            id          = "lwidth"..i,
            name        = "lfo > width",
            controlspec = controlspec.new(0, 1, 'lin', 0.01, 0),
            action      = function(x)
                engine.bit_set("lwidth"..i, x)
                parameters:save()
			screen_dirty = true
            end
        }
        params:add{
            type        = "number",
            id          = "numerator"..i,
            name        = "fm numerator",
            min         = 1,
            max         = 30,
            default     = 1,
            action      = function(x)
                local val = x / params:get("denominator"..i)
                engine.bit_set("ratio"..i, val)
                parameters:save()
			screen_dirty = true
            end
        }
        params:add{
            type        = "number",
            id          = "denominator"..i,
            name        = "fm denominator",
            min         = 1,
            max         = 30,
            default     = 1,
            action      = function(x)
                local val = params:get("numerator"..i) / x
                engine.bit_set("ratio"..i, val)
                parameters:save()
			screen_dirty = true
            end
        }
        params:add{
            type        = "control",
            id          = "index"..i,
            name        = "fm index",
            controlspec = controlspec.new(0, 10, 'lin', 0.1, 0),
            action      = function(x)
                engine.bit_set("index"..i, x)
                parameters:save()
			screen_dirty = true
            end
        }
        params:add{
            type        = "control",
            id          = "mindex"..i,
            name        = "env > index",
            controlspec = controlspec.new(0, 1, 'lin', 0.1, 0),
            action      = function(x)
                engine.bit_set("mindex"..i, x)
                parameters:save()
			screen_dirty = true
            end
        }
        params:add{
            type        = "control",
            id          = "lindex"..i,
            name        = "lfo > index",
            controlspec = controlspec.new(0, 1, 'lin', 0.1, 0),
            action      = function(x)
                engine.bit_set("lindex"..i, x)
                parameters:save()
			screen_dirty = true
            end
        }
    end
    params:add{
        type        = "option",
        id          = "sync",
        name        = "sync",
        options     = {"off","on"},
        action      = function(x)
            engine.bit_set("sync", x-1)
            parameters:save()
			screen_dirty = true
        end
    }
    params:add_group("highpass", 6)
    params:add{
        type        = "control",
        id          = "hipass",
        name        = "cutoff",
        controlspec = controlspec.new(0.01, 20000, 'exp', 0.01, 10),
        action      = function(x)
            engine.bit_set("hipass", x)
            parameters:save()
			screen_dirty = true
        end
    }
    params:add{
        type        = "control",
        id          = "mhipass",
        name        = "env > cutoff",
        controlspec = controlspec.new(0, 1, 'lin', 0.01, 0),
        action      = function(x)
            engine.bit_set("mhipass", x)
            parameters:save()
			screen_dirty = true
        end
    }
    params:add{
        type        = "control",
        id          = "lhipass",
        name        = "lfo > cutoff",
        controlspec = controlspec.new(0, 1, 'lin', 0.01, 0),
        action      = function(x)
            engine.bit_set("lhipass", x)
            parameters:save()
			screen_dirty = true
        end
    }
    params:add{
        type        = "control",
        id          = "hires",
        name        = "resonance",
        controlspec = controlspec.new(0, 1, 'lin', 0.01, 0),
        action      = function(x)
            engine.bit_set("hires", x)
            parameters:save()
			screen_dirty = true
        end
    }
    params:add{
        type        = "control",
        id          = "mhires",
        name        = "env > res",
        controlspec = controlspec.new(0, 1, 'lin', 0.01, 0),
        action      = function(x)
            engine.bit_set("mhires", x)
            parameters:save()
			screen_dirty = true
        end
    }
    params:add{
        type        = "control",
        id          = "lhires",
        name        = "lfo > res",
        controlspec = controlspec.new(0, 1, 'lin', 0.01, 0),
        action      = function(x)
            engine.bit_set("lhires", x)
            parameters:save()
			screen_dirty = true
        end
    }
    params:add_group("lowpass", 6)
    params:add{
        type        = "control",
        id          = "lopass",
        name        = "cutoff",
        controlspec = controlspec.new(0.01, 20000, 'exp', 0.01, 20000),
        action      = function(x)
            engine.bit_set("lopass", x)
            parameters:save()
			screen_dirty = true
        end
    }
    params:add{
        type        = "control",
        id          = "mlopass",
        name        = "env > cutoff",
        controlspec = controlspec.new(0, 1, 'lin', 0.01, 0),
        action      = function(x)
            engine.bit_set("mlopass", x)
            parameters:save()
			screen_dirty = true
        end
    }
    params:add{
        type        = "control",
        id          = "llopass",
        name        = "lfo > cutoff",
        controlspec = controlspec.new(0, 1, 'lin', 0.01, 0),
        action      = function(x)
            engine.bit_set("llopass", x)
            parameters:save()
			screen_dirty = true
        end
    }
    params:add{
        type        = "control",
        id          = "lores",
        name        = "resonance",
        controlspec = controlspec.new(0, 1, 'lin', 0.01, 0),
        action      = function(x)
            engine.bit_set("lores", x)
            parameters:save()
			screen_dirty = true
        end
    }
    params:add{
        type        = "control",
        id          = "mlores",
        name        = "env > res",
        controlspec = controlspec.new(0, 1, 'lin', 0.01, 0),
        action      = function(x)
            engine.bit_set("mlores", x)
            parameters:save()
			screen_dirty = true
        end
    }
    params:add{
        type        = "control",
        id          = "llores",
        name        = "lfo > res",
        controlspec = controlspec.new(0, 1, 'lin', 0.01, 0),
        action      = function(x)
            engine.bit_set("llores", x)
            parameters:save()
			screen_dirty = true
        end
    }
    params:add_group("amp env", 4)
    params:add{
        type        = "control",
        id          = "attack",
        name        = "attack",
        controlspec = controlspec.new(0.01, 10, 'exp', 0.01, 0.0015),
        action      = function(x)
            engine.bit_set("attack", x)
            parameters:save()
			screen_dirty = true
        end
    }
    params:add{
        type        = "control",
        id          = "decay",
        name        = "decay",
        controlspec = controlspec.new(0.01, 10, 'exp', 0.01, 0.8),
        action      = function(x)
            engine.bit_set("decay", x)
            parameters:save()
			screen_dirty = true
        end
    }
    params:add{
        type        = "control",
        id          = "sustain",
        name        = "sustain",
        controlspec = controlspec.new(0, 1, 'lin', 0.01, 1),
        action      = function(x)
            engine.bit_set("sustain", x)
            parameters:save()
			screen_dirty = true
        end
    }
    params:add{
        type        = "control",
        id          = "release",
        name        = "release",
        controlspec = controlspec.new(0.01, 10, 'exp', 0.01, .131),
        action      = function(x)
            engine.bit_set("release", x)
            parameters:save()
			screen_dirty = true
        end
    }
    params:add_group("mod env", 4)
    params:add{
        type        = "control",
        id          = "mattack",
        name        = "attack",
        controlspec = controlspec.new(0.01, 10, 'exp', 0.01, 0.0015),
        action      = function(x)
            engine.bit_set("mattack", x)
            parameters:save()
			screen_dirty = true
        end
    }
    params:add{
        type        = "control",
        id          = "mdecay",
        name        = "decay",
        controlspec = controlspec.new(0.01, 10, 'exp', 0.01, 0.8),
        action      = function(x)
            engine.bit_set("mdecay", x)
            parameters:save()
			screen_dirty = true
        end
    }
    params:add{
        type        = "control",
        id          = "msustain",
        name        = "sustain",
        controlspec = controlspec.new(0, 1, 'lin', 0.01, 1),
        action      = function(x)
            engine.bit_set("msustain", x)
            parameters:save()
			screen_dirty = true
        end
    }
    params:add{
        type        = "control",
        id          = "mrelease",
        name        = "release",
        controlspec = controlspec.new(0.01, 10, 'exp', 0.01, .131),
        action      = function(x)
            engine.bit_set("mrelease", x)
            parameters:save()
			screen_dirty = true
        end
    }
    params:add{
        type        = "control",
        id          = "lfreq",
        name        = "lfo frequency",
        controlspec = controlspec.new(0.001, 10, 'exp', 0.01, 4, "hz"),
        action      = function(x)
            engine.bit_set("lfreq", x)
            parameters:save()
			screen_dirty = true
        end
    }
    params:add{
        type        = "control",
        id          = "lfade",
        name        = "lfo fade in",
        controlspec = controlspec.new(0.01, 10, 'exp', 0.01, 0),
        action      = function(x)
            engine.bit_set("lfade", x)
            parameters:save()
			screen_dirty = true
        end
    }

    params:add_separator("midi")
    params:add{
        type        = "control",
        id          = "max_polyphony",
        name        = "max polyphony",
        controlspec = controlspec.new(0, 100, 'lin', 1, 20, 'notes', 1/100),
        action      = function(x)
            engine.bit_set_polyphony(math.floor(x))
            parameters:save()
        end
    }
end

function parameters:save()
    if not self.save_on_edit then
        return
    end
    local temp = clock.run(function()
        if self.waiting_to_save then
            clock.cancel(self.waiting_to_save)
            self.waiting_to_save = nil
        end
        clock.sleep(1)
        params:write(_path.data .. "bitters/default.pset")
    end)
    self.waiting_to_save = temp
end

return parameters
