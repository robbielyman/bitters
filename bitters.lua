-- bitters
--
-- lo-fi FM-capable mono/poly
-- llllllll.co/t/bitters-norns
--
-- @alanza
-- v0.1
--

engine.name = "Bitters"

function init()
    local needs_restart = false
    if not util.file_exists("/home/we/.local/share/SuperCollider/Extensions/TrianglePTR/TrianglePTR_scsynth.so") then
        util.os_capture("mkdir /home/we/.local/share/SuperCollider/Extensions/TrianglePTR")
        util.os_capture("cp /home/we/dust/code/bitters/bin/TrianglePTR/TrianglePTR_scsynth.so /home/we/.local/share/SuperCollider/Extensions/TrianglePTR/TrianglePTR_scsynth.so")
        print("installed TrianglePTR, please restart norns")
        needs_restart = true
    end
    if not util.file_exists("/home/we/.local/share/SuperCollider/Extensions/PulsePTR/PulsePTR_scsynth.so") then
        util.os_capture("mkdir /home/we/.local/share/SuperCollider/Extensions/PulsePTR")
        util.os_capture("cp /home/we/dust/code/bitters/bin/PulsePTR/PulsePTR_scsynth.so /home/we/.local/share/SuperCollider/Extensions/PulsePTR/PulsePTR_scsynth.so")
        print("installed PulsePTR, please restart norns")
        needs_restart = true
    end
    parameters = include("lib/parameters")
    parameters.init()
    notes = include("lib/notes")
    notes.init()
    page = include("lib/page")
    page:init(needs_restart)
    half_second = include("lib/halfsecond")
    half_second.init()
    screen_dirty = true
    params:bang()
end

function key(n,z)
    if n == 2 then
        page:left()
    elseif n == 3 then
        page:right()
    end
    screen_dirty = true
end

function enc(n,d)
    if n == 1 then
        if d < 0 then
            page:left()
        else
            page:right()
        end
    elseif n == 2 then
        page:scroll(d)
    elseif n == 3 then
        page:delta(d)
    end
    screen_dirty = true
end

function r()
  norns.script.load(norns.state.script)
end

