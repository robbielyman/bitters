local MusicUtil = require("musicutil")

local notes = {}

function notes.init()
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
                    engine.bit_note_on(d.note, d.vel, 600)
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

return notes
