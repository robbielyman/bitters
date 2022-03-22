local page = {
    popup_active = false,
    active_page = 1,
    active_param = 1,
    pages = {},
}

function page:init(bool)
    self.popup_active = bool
    self.pages = {
        {
            -- amp env ADSR
            params = {"attack", "decay", "sustain", "release"},
            render = function()
                graphics:text(0, 8, "AMP ENV", 8)
                local attack        = params:get("attack")
                local decay         = params:get("decay")
                local sustain       = params:get("sustain")
                local release       = params:get("release")
                graphics:mls(15,40,16+2*attack,15,
                    self.active_param == 1 and 16 or 8)
                graphics:mls(16+2*attack,15,17+2*attack+2*decay,40 - 20*sustain,
                    self.active_param == 2 and 16 or 8)
                graphics:mls(17+2*attack+2*decay,40-20*sustain,110-release,40-20*sustain,
                    self.active_param == 3 and 16 or 8)
                graphics:mls(110-release,40-20*sustain,110,40,
                    self.active_param == 4 and 16 or 8)
                graphics:text(10, 50, "ATK", self.active_param == 1 and 16 or 8)
                graphics:text(10, 60, string.format("%2.2f", attack), self.active_param == 1 and 16 or 8)
                graphics:text(40, 50, "DCY", self.active_param == 2 and 16 or 8)
                graphics:text(40, 60, string.format("%2.2f", decay), self.active_param == 2 and 16 or 8)
                graphics:text(70, 50, "SUS", self.active_param == 3 and 16 or 8)
                graphics:text(70, 60, string.format("%2.2f", sustain), self.active_param == 3 and 16 or 8)
                graphics:text(100,50, "REL", self.active_param == 4 and 16 or 8)
                graphics:text(100,60, string.format("%2.2f", release), self.active_param == 4 and 16 or 8)
            end
        },
        {
            -- mod env ADSR
            params = {"mattack", "mdecay", "msustain", "mrelease"},
            render = function()
                graphics:text(0, 8, "MOD ENV", 8)
                local attack        = params:get("mattack")
                local decay         = params:get("mdecay")
                local sustain       = params:get("msustain")
                local release       = params:get("mrelease")
                graphics:mls(15,40,16+2*attack,15,
                    self.active_param == 1 and 16 or 8)
                graphics:mls(16+2*attack,15,17+2*attack+2*decay,40 - 20*sustain,
                    self.active_param == 2 and 16 or 8)
                graphics:mls(17+2*attack+2*decay,40-20*sustain,110-release,40-20*sustain,
                    self.active_param == 3 and 16 or 8)
                graphics:mls(110-release,40-20*sustain,110,40,
                    self.active_param == 4 and 16 or 8)
                graphics:text(10, 50, "ATK", self.active_param == 1 and 16 or 8)
                graphics:text(10, 60, string.format("%2.2f", attack), self.active_param == 1 and 16 or 8)
                graphics:text(40, 50, "DCY", self.active_param == 2 and 16 or 8)
                graphics:text(40, 60, string.format("%2.2f", decay), self.active_param == 2 and 16 or 8)
                graphics:text(70, 50, "SUS", self.active_param == 3 and 16 or 8)
                graphics:text(70, 60, string.format("%2.2f", sustain), self.active_param == 3 and 16 or 8)
                graphics:text(100,50, "REL", self.active_param == 4 and 16 or 8)
                graphics:text(100,60, string.format("%2.2f", release), self.active_param == 4 and 16 or 8)
            end
        },
        {
            -- LFO
            params = {"lfreq", "lfade"},
            render = function()
                graphics:text(0, 8, "LFO", 8)
                local freq  = params:get("lfreq")
                local fade  = params:get("lfade")
                local round_fade = fade - (fade % 1)
                local quarter = 10/freq
                local phase = 1
                local i = 1
                while i <= 80-quarter do
                    local add = phase == 2 and 10 or phase == 0 and - 10 or 0
                    local direction = phase == 1 and 10 or phase == 0 and 10 or -10
                    graphics:mlrs(14+i, 30 + add, quarter, direction, self.active_param == 1 and 16 or 8)
                    phase = (phase + 1) % 4
                    i = i + quarter
                end
                local add = phase == 2 and 10 or phase == 0 and - 10 or 0
                local direction = phase == 1 and 10 or phase == 0 and 10 or -10
                local remainder = 80 % quarter == 0 and quarter or 80 % quarter
                graphics:mlrs(14 + i, 30 + add, remainder, direction*remainder/quarter,
                    self.active_param == 1 and 16 or 8)
                for j = 1, round_fade + 1 do
                    graphics:mlrs(99+j,40,0,(-20)*(j/(round_fade + 1)),self.active_param == 2 and 16 or 8)
                end
                graphics:text(10, 50, "FREQ", self.active_param == 1 and 16 or 8)
                graphics:text(10, 60, string.format("%2.2f", freq), self.active_param == 1 and 16 or 8)
                graphics:text(100, 50, "FADE", self.active_param == 2 and 16 or 8)
                graphics:text(100, 60, string.format("%2.2f", fade), self.active_param == 2 and 16 or 8)
            end
        },
        {
            -- Misc
            params = {"degrade", "mix", "mpitch", "lpitch",},
            render = function()
                graphics:text(0, 8, "MISC", 8)
                local degrade   = params:get("degrade")
                local mix       = params:get("mix")
                local mpitch    = params:get("mpitch")
                local lpitch    = params:get("lpitch")
                local freq      = params:get("lfreq")
                local attack    = params:get("mattack")
                local decay     = params:get("mdecay")
                local sustain   = params:get("msustain")
                local release   = params:get("mrelease")
                -- degrade
                local degrade_width = util.linlin(0, 1, 1, 5, degrade)
                for i = 0,25,degrade_width do
                    graphics:rect(1+i, 30, degrade_width, -10*math.sin(math.pi * i / 12.5), 
                    self.active_param == 1 and 16 or 8)
                end
                -- mix
                graphics:mls(35, 30, 65, 30, 6)
                graphics:rect(50 + 15*mix -1, 25, 2, 10, self.active_param == 2 and 16 or 8)
                -- env > pitch
                graphics:mls(70, 40, 71+0.5*attack, 40 - 25*mpitch,
                    self.active_param == 3 and 16 or 8)
                graphics:mls(71+0.5*attack, 40 - 25*mpitch, 71+0.5*attack+0.5*decay, 40-20*sustain*mpitch,
                    self.active_param == 3 and 16 or 8)
                graphics:mls(72+0.5*attack+0.5*decay, 40-20*sustain*mpitch,
                    90-0.5*release, 40-20*sustain*mpitch,
                    self.active_param == 3 and 16 or 8)
                graphics:mls(90-0.5*release, 40-20*sustain*mpitch,90,40,
                    self.active_param == 3 and 16 or 8)
                -- lfo > pitch
                local quarter = 10/freq
                local phase = 1
                local i = 1
                while i <= 30-quarter do
                    local add = phase == 2 and 10 or phase == 0 and - 10 or 0
                    local direction = phase == 1 and 10 or phase == 0 and 10 or -10
                    graphics:mlrs(100+i, 30 + lpitch*add, quarter, lpitch*direction, self.active_param == 4 and 16 or 8)
                    phase = (phase + 1) % 4
                    i = i + quarter
                end
                local add = phase == 2 and 10 or phase == 0 and - 10 or 0
                local direction = phase == 1 and 10 or phase == 0 and 10 or -10
                local remainder = 30 % quarter == 0 and quarter or 30 % quarter
                graphics:mlrs(100 + i, 30 + lpitch*add, remainder, lpitch*direction*remainder/quarter,
                    self.active_param == 4 and 16 or 8)
                graphics:text(10, 50, "DGRD", self.active_param == 1 and 16 or 8)
                graphics:text(10, 60, string.format("%2.2f", degrade), self.active_param == 1 and 16 or 8)
                graphics:text(40, 50, "MIX", self.active_param == 2 and 16 or 8)
                graphics:text(40, 60, string.format("%2.2f", mix), self.active_param == 2 and 16 or 8)
                graphics:text(70, 50, "E>PIT", self.active_param == 3 and 16 or 8)
                graphics:text(70, 60, string.format("%2.2f", mpitch), self.active_param == 3 and 16 or 8)
                graphics:text(100, 50, "L>PIT", self.active_param == 4 and 16 or 8)
                graphics:text(100, 60, string.format("%2.2f", lpitch), self.active_param == 4 and 16 or 8)
            end
        },
        {
            -- Osc 1
            params = {"wave1", "octave1", "coarse1", "fine1", },
            render = function()
                graphics:text(0, 8, "OSC 1", 8)
            end
        },
        {
            -- Osc 1 part two
            params = {"width1", "numerator1", "denominator1", "index1",
                "mwidth1", "lwidth1", "mindex1", "lindex1"},
            render = function()
                graphics:text(0, 8, "OSC 1", 8)
            end
        },
        {
            -- Osc 2
            params = {"wave2", "octave2", "coarse2", "fine2", },
            render = function()
                graphics:text(0, 8, "OSC 2", 8)
            end
        },
        {
            -- Osc 2 part two
            params = {"width2", "numerator2", "denominator2", "index2",
                "mwidth2", "lwidth2", "mindex2", "lindex2"},
            render = function()
                graphics:text(0, 8, "OSC 2", 8)
            end
        },
        {
            -- highpass
            params = {"hipass", "hires", "mhipass", "lhipass", "mhires", "lhires", },
            render = function()
                graphics:text(0, 8, "HIPASS", 8)
            end
        },
        {
            -- lowpass
            params = {"lopass", "lores", "mlopass", "llopass", "mlores", "llores", },
            render = function()
                graphics:text(0, 8, "LOPASS", 8)
            end
        },
    }
end

function page:scroll(delta)
    local n = #(self.pages[self.active_page].params)
    local val = (self.active_param + delta) % n
    self.active_param = val == 0 and n or val
end

function page:left()
    local val = (self.active_page - 1) % #self.pages
    self.active_page = val == 0 and #self.pages or val
    self.active_param = 1
end

function page:right()
    local val = (self.active_page + 1) % #self.pages
    self.active_page = val == 0 and #self.pages or val
    self.active_param = 1
end

function page:delta(d)
    local param = self.pages[self.active_page].params[self.active_param]
    params:delta(param,d)
end

function page:render()
    graphics:setup()
    if self.popup_active then
        graphics:rect(43, 29, 42, 10, 5)
        graphics:rect(44, 30, 40, 8, 0)
        graphics:text(45, 36, "please restart norns", 16)
    else
        local current_page = self.pages[self.active_page]
        current_page.render()
    end
    graphics:teardown()
end

return page
