-- Bitters Engine lib
-- Engine params and functions
--
-- @module BittersEngine
-- @release v1.0
-- @author Alanza

local Bitters = {}

-- redefine to implement, e.g. automatic param saving
-- or setting the screen dirty
function Bitters.param_changed_callback()
end

-- adds a list of params
-- @bool midicontrol If false, don't build and set-up midi params
function Bitters.init(midicontrol)
    params:add_separator("bitters", "b i t t e r s")
    params:add{
        type        = "trigger",
        id          = "randomize",
        name        = "randomize",
        action      = function()
            for _,p in pairs({
                "degrade", "mix", "width1", "width2", "mwidth1", "mwidth2", "lwidth1", "lwidth2",
                -- "index1", "index2", "mindex1", "mindex2", "lindex1", "lindex2",
                -- "hipass", "mhipass", "lhipass", "hires", "mhires", "lhires",
                -- "lopass", "mlopass", "llopass", "lores", "mlores", "llores",
                "attack", "decay", "sustain", "release",
                "mattack", "mdecay", "msustain", "mrelease",
                "lfreq", "lfade"
            }) do
                params:set_raw(p, math.random())
            end
            for _,p in pairs({"octave1", "octave2"}) do
                params:set(p, math.random(-2,1))
            end
            for _,p in pairs({"wave1", "wave2"}) do
                params:set(p, math.random(1,2))
            end
            -- for _,p in pairs({"numerator1", "numerator2", "denominator1", "denominator2"}) do
            --    params:set(p, math.random(1,30))
            -- end
        end
    }
    params:add{
        type        = "control",
        id          = "amp",
        name        = "volume",
        controlspec = controlspec.new(0, 1, 'lin', 0.01, 0.5),
        action      = function(x)
            engine.bit_set("amp", x)
            Bitters.param_changed_callback("amp")
        end
    }
    params:add{
        type        = "control",
        id          = "degrade",
        name        = "degrade",
        controlspec = controlspec.new(0, 1, 'lin', 0.01, 0),
        action      = function(x)
            engine.bit_set("degrade", x)
            Bitters.param_changed_callback("degrade")
        end
    }
    params:add{
        type        = "control",
        id          = "mix",
        name        = "osc mix",
        controlspec = controlspec.new(-1, 1, 'lin', 0.01, 0),
        action      = function(x)
            engine.bit_set("mix", x)
            Bitters.param_changed_callback("mix")
        end
    }
    params:add{
        type        = "control",
        id          = "mpitch",
        name        = "env > pitch",
        controlspec = controlspec.new(0, 1, 'lin', 0.01, 0),
        action      = function(x)
            engine.bit_set("mpitch", x)
            Bitters.param_changed_callback("mpitch")
        end
    }
    params:add{
        type        = "control",
        id          = "lpitch",
        name        = "lfo > pitch",
        controlspec = controlspec.new(0, 1, 'lin', 0.01, 0),
        action      = function(x)
            engine.bit_set("lpitch", x)
            Bitters.param_changed_callback("lpitch")
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
                Bitters.param_changed_callback("octave" .. i)
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
                Bitters.param_changed_callback("coarse" .. i)
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
                Bitters.param_changed_callback("fine" .. i)
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
                Bitters.param_changed_callback("wave" .. i)
            end
        }
        params:add{
            type        = "control",
            id          = "width"..i,
            name        = "width",
            controlspec = controlspec.new(0, 1, 'lin', 0.01, 0.5),
            action      = function(x)
                engine.bit_set("width"..i, x)
                Bitters.param_changed_callback("width" .. i)
            end
        }
        params:add{
            type        = "control",
            id          = "mwidth"..i,
            name        = "env > width",
            controlspec = controlspec.new(0, 1, 'lin', 0.01, 0),
            action      = function(x)
                engine.bit_set("mwidth"..i, x)
                Bitters.param_changed_callback("mwidth" .. i)
            end
        }
        params:add{
            type        = "control",
            id          = "lwidth"..i,
            name        = "lfo > width",
            controlspec = controlspec.new(0, 1, 'lin', 0.01, 0),
            action      = function(x)
                engine.bit_set("lwidth"..i, x)
                Bitters.param_changed_callback("lwidth" .. i)
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
                Bitters.param_changed_callback("numerator" .. i)
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
                Bitters.param_changed_callback("denominator" .. i)
            end
        }
        params:add{
            type        = "control",
            id          = "index"..i,
            name        = "fm index",
            controlspec = controlspec.new(0, 5, 'lin', 0.01, 0),
            action      = function(x)
                engine.bit_set("index"..i, x)
                Bitters.param_changed_callback("index" .. i)
            end
        }
        params:add{
            type        = "control",
            id          = "mindex"..i,
            name        = "env > index",
            controlspec = controlspec.UNIPOLAR,
            action      = function(x)
                engine.bit_set("mindex"..i, x)
                Bitters.param_changed_callback("mindex" .. i)
            end
        }
        params:add{
            type        = "control",
            id          = "lindex"..i,
            name        = "lfo > index",
            controlspec = controlspec.UNIPOLAR,
            action      = function(x)
                engine.bit_set("lindex"..i, x)
                Bitters.param_changed_callback("lindex" .. i)
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
            Bitters.param_changed_callback("sync")
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
            Bitters.param_changed_callback("hipass")
        end
    }
    params:add{
        type        = "control",
        id          = "mhipass",
        name        = "env > cutoff",
        controlspec = controlspec.new(0, 1, 'lin', 0.01, 0),
        action      = function(x)
            engine.bit_set("mhipass", x)
            Bitters.param_changed_callback("mhipass")
        end
    }
    params:add{
        type        = "control",
        id          = "lhipass",
        name        = "lfo > cutoff",
        controlspec = controlspec.new(0, 1, 'lin', 0.01, 0),
        action      = function(x)
            engine.bit_set("lhipass", x)
            Bitters.param_changed_callback("lhipass")
        end
    }
    params:add{
        type        = "control",
        id          = "hires",
        name        = "resonance",
        controlspec = controlspec.new(0, 1, 'lin', 0.01, 0),
        action      = function(x)
            engine.bit_set("hires", x)
            Bitters.param_changed_callback("hires")
        end
    }
    params:add{
        type        = "control",
        id          = "mhires",
        name        = "env > res",
        controlspec = controlspec.new(0, 1, 'lin', 0.01, 0),
        action      = function(x)
            engine.bit_set("mhires", x)
            Bitters.param_changed_callback("mhires")
        end
    }
    params:add{
        type        = "control",
        id          = "lhires",
        name        = "lfo > res",
        controlspec = controlspec.new(0, 1, 'lin', 0.01, 0),
        action      = function(x)
            engine.bit_set("lhires", x)
            Bitters.param_changed_callback("lhires")
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
            Bitters.param_changed_callback("lopass")
        end
    }
    params:add{
        type        = "control",
        id          = "mlopass",
        name        = "env > cutoff",
        controlspec = controlspec.new(0, 1, 'lin', 0.01, 0),
        action      = function(x)
            engine.bit_set("mlopass", x)
            Bitters.param_changed_callback("mlopass")
        end
    }
    params:add{
        type        = "control",
        id          = "llopass",
        name        = "lfo > cutoff",
        controlspec = controlspec.new(0, 1, 'lin', 0.01, 0),
        action      = function(x)
            engine.bit_set("llopass", x)
            Bitters.param_changed_callback("llopass")
        end
    }
    params:add{
        type        = "control",
        id          = "lores",
        name        = "resonance",
        controlspec = controlspec.new(0, 1, 'lin', 0.01, 0),
        action      = function(x)
            engine.bit_set("lores", x)
            Bitters.param_changed_callback("lores")
        end
    }
    params:add{
        type        = "control",
        id          = "mlores",
        name        = "env > res",
        controlspec = controlspec.new(0, 1, 'lin', 0.01, 0),
        action      = function(x)
            engine.bit_set("mlores", x)
            Bitters.param_changed_callback("mlores")
        end
    }
    params:add{
        type        = "control",
        id          = "llores",
        name        = "lfo > res",
        controlspec = controlspec.new(0, 1, 'lin', 0.01, 0),
        action      = function(x)
            engine.bit_set("llores", x)
            Bitters.param_changed_callback("llores")
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
            Bitters.param_changed_callback("attack")
        end
    }
    params:add{
        type        = "control",
        id          = "decay",
        name        = "decay",
        controlspec = controlspec.new(0.01, 10, 'exp', 0.01, 0.8),
        action      = function(x)
            engine.bit_set("decay", x)
            Bitters.param_changed_callback("decay")
        end
    }
    params:add{
        type        = "control",
        id          = "sustain",
        name        = "sustain",
        controlspec = controlspec.new(0, 1, 'lin', 0.01, 1),
        action      = function(x)
            engine.bit_set("sustain", x)
            Bitters.param_changed_callback("sustain")
        end
    }
    params:add{
        type        = "control",
        id          = "release",
        name        = "release",
        controlspec = controlspec.new(0.01, 10, 'exp', 0.01, .131),
        action      = function(x)
            engine.bit_set("release", x)
            Bitters.param_changed_callback("release")
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
            Bitters.param_changed_callback("mattack")
        end
    }
    params:add{
        type        = "control",
        id          = "mdecay",
        name        = "decay",
        controlspec = controlspec.new(0.01, 10, 'exp', 0.01, 0.8),
        action      = function(x)
            engine.bit_set("mdecay", x)
            Bitters.param_changed_callback("mdecay")
        end
    }
    params:add{
        type        = "control",
        id          = "msustain",
        name        = "sustain",
        controlspec = controlspec.new(0, 1, 'lin', 0.01, 1),
        action      = function(x)
            engine.bit_set("msustain", x)
            Bitters.param_changed_callback("msustain")
        end
    }
    params:add{
        type        = "control",
        id          = "mrelease",
        name        = "release",
        controlspec = controlspec.new(0.01, 10, 'exp', 0.01, .131),
        action      = function(x)
            engine.bit_set("mrelease", x)
            Bitters.param_changed_callback("mrelease")
        end
    }
    params:add{
        type        = "control",
        id          = "lfreq",
        name        = "lfo frequency",
        controlspec = controlspec.new(0.001, 10, 'exp', 0.01, 4, "hz"),
        action      = function(x)
            engine.bit_set("lfreq", x)
            Bitters.param_changed_callback("lfreq")
        end
    }
    params:add{
        type        = "control",
        id          = "lfade",
        name        = "lfo fade in",
        controlspec = controlspec.new(0.01, 10, 'exp', 0.01, 0),
        action      = function(x)
            engine.bit_set("lfade", x)
            Bitters.param_changed_callback("lfade")
        end
    }
    if not midicontrol then
        return
    end
    params:add_separator("midi_sep", "midi")
    params:add{
        type        = "control",
        id          = "max_polyphony",
        name        = "max polyphony",
        controlspec = controlspec.new(0, 100, 'lin', 1, 10, 'notes', 1/100),
        action      = function(x)
            engine.bit_set_polyphony(math.floor(x))
            Bitters.param_changed_callback("max_polyphony")
        end
    }
    local mididevice = {}
    local mididevice_list={"none"}
    midi_channels={"all"}
    for i=1,16 do
        table.insert(midi_channels,i)
    end
    for _,dev in pairs(midi.devices) do
        if dev.port ~= nil then
            local name = string.lower(dev.name)
            table.insert(mididevice_list,name)
            print("adding " .. name .. " to port " ..dev.port)
            mididevice[name] = {
                name = name,
                port = dev.port,
                midi = midi.connect(dev.port),
                active = false,
            }
            mididevice[name].midi.event = function(data)
                if mididevice[name].active == false then
                    return
                end
                local d = midi.to_msg(data)
                if d.ch ~= midi_channels[params:get("midichannel")]
                    and params:get("midichannel") > 1 then
                    return
                end
                if d.type == "note_on" then
                    local amp = util.linexp(1, 127, 0.01, 1.0, d.vel)
                    engine.bit_note_on(d.note, amp, 600)
                elseif d.type == "note_off" then
                    engine.bit_note_off(d.note)
                elseif d.cc == 64 then -- sustain pedal
                    local val = d.val > 126 and 1 or 0
                    if params:get("pedal_mode") == 1 then
                        engine.bit_sustain(val)
                    else
                        engine.bit_sostenuto(val)
                    end
                end
            end
        end
    end
    tab.print(mididevice_list)

    params:add{
        type    = "option",
        id      = "pedal_mode",
        name    = "pedal mode",
        options = {"sustain", "sostenuto"},
        default = 1,
    }
    params:add{
        type    = "option",
        id      = "midi",
        name    = "midi in",
        options = mididevice_list,
        default = 1
    }
    params:set_action("midi", function(v)
        if v == 1 then return end
        for _, dev in pairs(mididevice) do
            dev.active = false
        end
        mididevice[mididevice_list[v]].active = true
    end)
    params:add{
        type    = "option",
        id      = "midichannel",
        name    = "midi ch",
        options = midi_channels,
        default = 1
    }

    if #mididevice_list>1 then
        params:set("midi",2)
    end
end

-- Note on function
-- @int note Midi note number
-- @number vel Velocity (0.0-1.0)
-- @number time Gate time (optional)
function Bitters.note_on(note, vel, time)
    if not time then time = 600 end
    engine.bit_note_on(note, vel, time)
end

-- Note off function
-- @int note Midi note number
function Bitters.note_off(note)
    engine.bit_note_off(note)
end

return Bitters
