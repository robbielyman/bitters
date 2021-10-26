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
    if not util.file_exists("/home/we/.local/share/SuperCollider/Extensions/TrianglePTR/TrianglePTR_scsynth.so") then
        util.os_capture("mkdir /home/we/.local/share/SuperCollider/Extensions/TrianglePTR")
        util.os_capture("cp /home/we/dust/code/bitters/bin/TrianglePTR/TrianglePTR_scsynth.so /home/we/.local/share/SuperCollider/Extensions/TrianglePTR/TrianglePTR_scsynth.so")
        print("installed TrianglePTR, please restart norns")
    end
    if not util.file_exists("/home/we/.local/share/SuperCollider/Extensions/PulsePTR/PulsePTR_scsynth.so") then
        util.os_capture("mkdir /home/we/.local/share/SuperCollider/Extensions/PulsePTR")
        util.os_capture("cp /home/we/dust/code/bitters/bin/PulsePTR/PulsePTR_scsynth.so /home/we/.local/share/SuperCollider/Extensions/PulsePTR/PulsePTR_scsynth.so")
        print("installed PulsePTR, please restart norns")
    end
    notes = include("lib/notes")
    notes.init()
end

