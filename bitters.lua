-- bitters
--
-- lo-fi FM-capable mono/poly
-- llllllll.co/t/bitters-norns
--
-- @alanza
-- v1.0

Bitters = include("lib/bitters_engine")
UI = require("ui")
Filtergraph = require("filtergraph")
Envgraph = require("envgraph")
Graph = require("graph")

engine.name = "Bitters"

function init()
    Needs_Restart = false
    if not util.file_exists("/home/we/.local/share/SuperCollider/Extensions/TrianglePTR/TrianglePTR_scsynth.so") then
        util.os_capture("mkdir /home/we/.local/share/SuperCollider/Extensions/TrianglePTR")
        util.os_capture("cp /home/we/dust/code/bitters/bin/TrianglePTR/TrianglePTR_scsynth.so /home/we/.local/share/SuperCollider/Extensions/TrianglePTR/TrianglePTR_scsynth.so")
        print("installed TrianglePTR, please restart norns")
        Needs_Restart = true
    end
    if not util.file_exists("/home/we/.local/share/SuperCollider/Extensions/PulsePTR/PulsePTR_scsynth.so") then
        util.os_capture("mkdir /home/we/.local/share/SuperCollider/Extensions/PulsePTR")
        util.os_capture("cp /home/we/dust/code/bitters/bin/PulsePTR/PulsePTR_scsynth.so /home/we/.local/share/SuperCollider/Extensions/PulsePTR/PulsePTR_scsynth.so")
        print("installed PulsePTR, please restart norns")
        Needs_Restart = true
    end
    Restart_Message = UI.Message.new{"please restart norns"}
    Bitters.init(true)
    OscPage = Page.new(
        {"OSC 1", "OSC 2"},
        {
            Tab.new(
        {"wave1", "octave1", "coarse1", "fine1", "width1",
        "numerator1", "denominator1", "index1"},
        {
            UI.List.new(0, 24, 1, {"wave", "octave", "coarse", "fine"}),
            UI.List.new(30, 24),
            UI.List.new(50, 24, 1, {"width", "numerator", "denominator", "index"}),
            UI.List.new(80, 24)
        },
        function(self)
            self.lists[1].active = self.index <= 4
            self.lists[1].index = util.clamp(self.index, 1, 4)
            self.lists[2].active = self.index <= 4
            self.lists[2].index = util.clamp(self.index, 1, 4)
            for i = 1, 4 do
                self.lists[2].entries[i] = params:get(self.params[i])
            end
            self.lists[3].active = self.index > 4
            self.lists[3].index = util.clamp(self.index, 5, 8) - 4
            self.lists[4].active = self.index > 4
            self.lists[4].index = util.clamp(self.index, 5, 8) - 4
            for i = 5, 8 do
                self.lists[2].entries[i - 4] = params:get(self.params[i])
            end
        end,
        function(self, n, d)
            if n == 2 then
                self.index = util.clamp(self.index + d, 1, 8)
            elseif n == 3 then
                params:delta(self.params[self.index], d)
            end
            redraw()
        end),
        Tab.new(
        {"wave2", "octave2", "coarse2", "fine2", "width2",
        "numerator2", "denominator2", "index2"},
        {
            UI.List.new(0, 24, 1, {"wave", "octave", "coarse", "fine"}),
            UI.List.new(30, 24),
            UI.List.new(50, 24, 1, {"width", "numerator", "denominator", "index"}),
            UI.List.new(80, 24)
        },
        function(self)
            self.lists[1].active = self.index <= 4
            self.lists[1].index = util.clamp(self.index, 1, 4)
            self.lists[2].active = self.index <= 4
            self.lists[2].index = util.clamp(self.index, 1, 4)
            for i = 1, 4 do
                self.lists[2].entries[i] = params:get(self.params[i])
            end
            self.lists[2].text_align = "right"
            self.lists[3].active = self.index > 4
            self.lists[3].index = util.clamp(self.index, 5, 8) - 4
            self.lists[4].active = self.index > 4
            self.lists[4].index = util.clamp(self.index, 5, 8) - 4
            for i = 5, 8 do
                self.lists[2].entries[i - 4] = params:get(self.params[i])
            end
            self.lists[4].text_align = 4
        end,
        function(self, n, d)
            if n == 2 then
                self.index = util.clamp(self.index + d, 1, 8)
            elseif n == 3 then
                params:delta(self.params[self.index], d)
            end
            redraw()
        end),
    })
    FiltPage = Page.new(
    {"HIPASS", "LOWPASS"},
    {
        Tab.new(
        {"hipass", "hires"},
        {
            UI.List.new(50, 34, 1, {"frequency", "resonance"}),
            UI.List.new(80, 34)
        },
        function(self)
            self.lists[1].index = self.index
            self.lists[2].index = self.index
            for i = 1,2 do
                self.lists[2].entries[i] = params:get(self.params[i])
            end
            self.lists[2].text_align = "right"
            self.filter_graph:edit("highpass", nil, params:get(self.params[1]), params:get(self.params[2]))
            self.filter_graph:redraw()
        end,
        function(self, n, d)
            if n == 2 then
                self.index = util.clamp(self.index + d, 1, 2)
            elseif n == 3 then
                params:delta(self.params[self.index], d)
            end
            redraw()
        end),
        Tab.new(
        {"lopass", "lores"},
        {
            UI.List.new(50, 34, 1, {"frequency", "resonance"}),
            UI.List.new(80, 34)
        },
        function(self)
            self.lists[1].index = self.index
            self.lists[2].index = self.index
            for i = 1,2 do
                self.lists[2].entries[i] = params:get(self.params[i])
            end
            self.lists[2].text_align = "right"
            self.filter_graph:edit("lowpass", nil, params:get(self.params[1]), params:get(self.params[2]))
            self.filter_graph:redraw()
        end,
        function(self, n, d)
            if n == 2 then
                self.index = util.clamp(self.index + d, 1, 2)
            elseif n == 3 then
                params:delta(self.params[self.index], d)
            end
            redraw()
        end),
    })
    FiltPage.tabs[1].filter_graph = Filtergraph.new(
    10, 24000, -60, 32.5, "highpass", 12, params:get("hipass"), params:get("hires")
    )
    FiltPage.tabs[1].filter_graph:set_position_and_size(4, 22, 56, 38)
    FiltPage.tabs[2].filter_graph = Filtergraph.new(
    10, 24000, -60, 32.5, "lowpass", 12, params:get("lopass"), params:get("lores")
    )
    FiltPage.tabs[2].filter_graph:set_position_and_size(4, 22, 56, 38)
    EnvPage = Page.new(
    {"AMP", "MOD", "LFO"},
    {
        Tab.new(
        {"attack", "decay", "sustain", "release"},
        {
            UI.List.new(50, 24, 1, {"attack", "decay", "sustain", "release"}),
            UI.List.new(80, 34)
        },
        function(self)
            self.lists[1].index = self.index
            self.lists[2].index = self.index
            for i = 1,4 do
                self.lists[2].entries[i] = params:get(self.params[i])
            end
            self.lists[2].text_align = "right"
            self.env_graph:edit_adsr(params:get(self.params[1]), params:get(self.params[2]),
            params:get(self.params[3]), params:get(self.params[4]))
            self.env_graph:redraw()
        end,
        function(self, n, d)
            if n == 2 then
                self.index = util.clamp(self.index + d, 1, 4)
            elseif n == 3 then
                params:delta(self.params[self.index], d)
            end
            redraw()
        end),
        Tab.new(
        {"mattack", "mdecay", "msustain", "mrelease"},
        {
            UI.List.new(50, 24, 1, {"attack", "decay", "sustain", "release"}),
            UI.List.new(80, 34)
        },
        function(self)
            self.lists[1].index = self.index
            self.lists[2].index = self.index
            for i = 1,4 do
                self.lists[2].entries[i] = params:get(self.params[i])
            end
            self.lists[2].text_align = "right"
            self.env_graph:edit_adsr(params:get(self.params[1]), params:get(self.params[2]),
            params:get(self.params[3]), params:get(self.params[4]))
            self.env_graph:redraw()
        end,
        function(self, n, d)
            if n == 2 then
                self.index = util.clamp(self.index + d, 1, 4)
            elseif n == 3 then
                params:delta(self.params[self.index], d)
            end
            redraw()
        end),
        Tab.new(
        {"lfreq", "lfade"},
        {
            UI.List.new(50, 34, 1, {"frequency", "fade time"}),
            UI.List.new(80, 34)
        },
        function(self)
            self.lists[1].index = self.index
            self.lists[2].index = self.index
            for i = 1,2 do
                self.lists[2].entries[i] = params:get(self.params[i])
            end
            self.lfo_graph:update_functions()
            self.lfo_graph:redraw()
        end,
        function(self, n, d)
            if n == 2 then
                self.index = util.clamp(self.index + d, 1, 2)
            elseif n == 3 then
                params:delta(self.params[self.index], d)
            end
            redraw()
        end)
    })
    EnvPage.tabs[1].env_graph = Envgraph.new_adsr(0, 20, nil, nil,
    params:get("attack"), params:get("decay"), params:get("sustain"), params:get("release"),
    1, -4)
    EnvPage.tabs[1].env_graph:set_position_and_size(57, 34, 60, 25)
    EnvPage.tabs[2].env_graph = Envgraph.new_adsr(0, 20, nil, nil,
    params:get("mattack"), params:get("mdecay"), params:get("msustain"), params:get("mrelease"),
    1, -4)
    EnvPage.tabs[2].env_graph:set_position_and_size(57, 34, 60, 25)
    EnvPage.tabs[3].lfo_graph = Graph.new(0, 1, "lin", -1, 1, "lin", nil, true, false)
    EnvPage.tabs[3].lfo_graph:set_position_and_size(4, 21, 56, 34)
    EnvPage.tabs[3].lfo_graph:add_function( function(x)
        local freq = params:get("lfreq")
        local fade = params:get("lfade")
        local fade_end
        local y_fade
        local MIN_Y = 0.15

        fade_end = util.linlin(0, 10, 0, 1, fade)
        y_fade = util.linlin(0, fade_end, MIN_Y, 1, x)
        x = x * util.linlin(0.01, 10, 0.5, 10, freq)
        local y = math.sin(x * math.pi * 2)
        return y * y_fade * 0.75
    end, 4)
    MiscPage = Page.new(
    {"MISC", "MATRIX"},
    {
        Tab.new(
        {"max_polyphony", "mix", "degrade", "sync"},
        {
            UI.List.new(0, 24, 1, {"polyphony", "mix", "degrade", "sync"}),
            UI.List.new(80, 24)
        },
        function(self)
            self.lists[1].index = self.index
            self.lists[2].index = self.index
            for i = 1, 4 do
                self.lists[2].entries[i] = params:get(self.params[i])
            end
            self.lists[2].text_align = "right"
        end,
        function(self, n, d)
            if n == 2 then
                self.index = util.clamp(self.index + d, 1, 4)
            elseif n == 3 then
                params:delta(self.params[self.index], d)
            end
            redraw()
        end),
        Tab.new(
        {
            "mpitch", "lpitch",
            "mwidth1", "lwidth1", "mindex1", "lindex1",
            "mwidth2", "lwidth2", "mindex2", "lindex2",
            "mhipass", "lhipass", "mhires", "lhires",
            "mlopass", "mlopass", "mlores", "llores",
        },
        {
            UI.ScrollingList.new(4, 34, 1,
            {"pitch", "width 1", "index 1", "width 2", "index 2", "hi freq", "hi res", "lo freq", "lo res"}),
            UI.ScrollingList.new(60, 34),
            UI.ScrollingList.new(100, 34)
        },
        function(self)
            screen.move(60, 24)
            screen.level(3)
            screen.text_center("mod")
            screen.move(100, 24)
            screen.text_center("lfo")
            screen.fill()
            local row = (self.index - 1) // 2 + 1
            self.lists[1].index = row
            self.lists[1].active = false
            self.lists[2].index = row
            for i = 1, 9 do
                self.lists[2].entries[i] = params:get(self.params[2 * (i - 1) + 1])
            end
            self.lists[2].active = self.index % 2 == 1
            self.lists[2].text_align = "center"
            self.lists[3].index = row
            for i = 1, 9 do
                self.lists[3].entries[i] = params:get(self.params[2 * i])
            end
            self.lists[3].active = self.index % 2 == 0
            self.lists[3].text_align = "center"
        end,
        function(self, n, d)
            if n == 2 then
                self.index = util.clamp(self.index + d, 1, 18)
            elseif n == 3 then
                params:delta(self.params[self.index], d)
            end
            redraw()
        end)
    })
    Notes = include("lib/notes")
    Notes.init()
    Graphics = include("lib/graphics")
    Graphics.init()
    Pages = UI.Pages.new(1, 4)
    Half_Second = include("lib/halfsecond")
    Half_Second.init()
    params:bang()
    redraw()
end

function Bitters.param_changed_callback(id)
    local page
    if Pages.index == 1 then
        page = OscPage
    elseif Pages.index == 2 then
        page = FiltPage
    elseif Pages.index == 3 then
        page = EnvPage
    elseif Pages.index == 4 then
        page = MiscPage
    end
    local tab = page.tabs[page.ui.index]
    local found = false
    for _, v in pairs(tab.params) do
        if v == id then
            found = true
            break
        end
    end
    if not found then
        Popup = {
            text = params:lookup_param(id).name .. ": " .. params:get(id),
            redraw = function(self)
                graphics:rect(8, 0, 128 - 16, 6, 0)
                screen.move(64, 6)
                screen.level(8)
                screen.text_center(self.text)
                screen.fill()
            end
        }
        if Popup_Clock then
            clock.cancel(Popup_Clock)
        end
        Popup_Clock = clock.run(function()
            clock.sleep(1)
            Popup = nil
            redraw()
        end)
    end
    redraw()
end

function r()
  norns.script.load(norns.state.script)
end

function redraw()
    Graphics:setup()
    if Needs_Restart then
        Restart_Message:redraw()
    else
        Pages:redraw()
        if Pages.index == 1 then
            OscPage:redraw()
        elseif Pages.index == 2 then
            FiltPage:redraw()
        elseif Pages.index == 3 then
            EnvPage:redraw()
        elseif Pages.index == 4 then
            MiscPage:redraw()
        end
        if Popup then
            Popup:redraw()
        end
    end
    Graphics:teardown()
end

Tab = {}
Tab.__index = Tab

function Tab.new(params, lists, hook, enc)
    local t = {}
    setmetatable(t, Tab)
    t.params = params
    t.lists = lists
    t.hook = hook
    t.index = 1
    t.enc = enc
    return t
end

function Tab:redraw()
    self:hook()
    for _, list in self.lists do
        list:redraw()
    end
end

Page = {}
Page.__index = Page

function Page.new(titles, tabs)
    local p = {}
    setmetatable(p, Page)
    p.tabs = tabs
    p.active_tab = 1
    p.ui = UI.Tabs.new(1, titles)
    return p
end

function Page:enc(n, d)
    local tab = self.tabs[self.ui.index]
    tab:enc(n, d)
    redraw()
end

function Page:key(n, z)
    -- switches tabs
    if n == 2 and z == 1 then
        self.ui:set_index_delta(-1, true)
        redraw()
    elseif n == 3 and z == 1 then
        self.ui:set_index_delta(1, true)
        redraw()
    end
end

function Page:redraw()
    self.ui:redraw()
    self.tabs[self.ui.index]:redraw()
end

function enc(n, d)
    if n == 1 then
        Pages:set_index_delta(d, false)
    elseif Pages.index == 1 then
        OscPage:enc(n, d)
    elseif Pages.index == 2 then
        FiltPage:enc(n, d)
    elseif Pages.index == 3 then
        EnvPage:enc(n, d)
    elseif Pages.index == 4 then
        MiscPage:enc(n, d)
    end
    Popup = nil
    redraw()
end

function key(n, z)
    if Pages.index == 1 then
        OscPage:key(n, z)
    elseif Pages.index == 2 then
        FiltPage:key(n, z)
    elseif Pages.index == 3 then
        EnvPage:key(n, z)
    elseif Pages.index == 4 then
        MiscPage:key(n, z)
    end
    Popup = nil
    redraw()
end
