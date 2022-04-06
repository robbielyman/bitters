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
            params = {"wave1", "octave1", "coarse1", "fine1", "width1", "numerator1", "denominator1", "index1"},
            render = function()
                graphics:text(0, 8, "OSC 1", 8)
                local wave      = params:get("wave1")
                local octave    = params:get("octave1")
                local coarse    = params:get("coarse1")
                local fine      = params:get("fine1")
                local width     = params:get("width1")
                local numerator = params:get("numerator1")
                local denominator = params:get("denominator1")
                local index     = params:get("index1")
                graphics:text(10, 20, "WAV", self.active_param == 1 and 16 or 8)
                graphics:text(10, 30, wave == 1 and "TRI" or "SQR", self.active_param == 1 and 16 or 8)
                graphics:text(40, 20, "OCT", self.active_param == 2 and 16 or 8)
                graphics:text(40, 30, octave, self.active_param == 2 and 16 or 8)
                graphics:text(70, 20, "CRS", self.active_param == 3 and 16 or 8)
                graphics:text(70, 30, coarse, self.active_param == 3 and 16 or 8)
                graphics:text(100, 20, "FINE", self.active_param == 4 and 16 or 8)
                graphics:text(100, 30, string.format("%2.2f", fine), self.active_param == 4 and 16 or 8)
                graphics:text(10, 50, "WID", self.active_param == 5 and 16 or 8)
                graphics:text(10, 60, string.format("%2.2f", width), self.active_param == 5 and 16 or 8)
                graphics:text(55, 50, "FM", self.active_param == 6 and 16 or self.active_param == 7 and 16 or 8)
                graphics:text(50, 60, numerator, self.active_param == 6 and 16 or 8)
                graphics:text(60, 60, "/", 8)
                graphics:text(70, 60, denominator, self.active_param == 7 and 16 or 8)
                graphics:text(100, 50, "IND", self.active_param == 8 and 16 or 8)
                graphics:text(100, 60, string.format("%2.2f", index), self.active_param == 8 and 16 or 8)
            end
        },
        {
            -- Osc 1 part two
            params = {"mwidth1", "lwidth1", "mindex1", "lindex1"},
            render = function()
                graphics:text(0, 8, "OSC 1", 8)
                local mwidth    = params:get("mwidth1")
                local lwidth    = params:get("lwidth1")
                local mindex    = params:get("mindex1")
                local lindex   = params:get("lindex1")
                local freq      = params:get("lfreq")
                local attack    = params:get("mattack")
                local decay     = params:get("mdecay")
                local sustain   = params:get("msustain")
                local release   = params:get("mrelease")
                -- env > width
                graphics:mls(10, 40, 11+0.5*attack, 40 - 25*mwidth,
                    self.active_param == 1 and 16 or 8)
                graphics:mls(11 + 0.5*attack, 40 - 25*mwidth, 11 + 0.5*attack + 0.5*decay, 40 - 20*sustain*mwidth,
                    self.active_param == 1 and 16 or 8)
                graphics:mls(12 + 0.5*attack + 0.5*decay, 40-20*sustain*mwidth,
                    30-0.5*release, 40-20*sustain*mwidth,
                    self.active_param == 1 and 16 or 8)
                graphics:mls(30-0.5*release, 40 - 20*sustain*mwidth, 30, 40,
                    self.active_param == 1 and 16 or 8)
                -- lfo > width
                local quarter = 10/freq
                local phase = 1
                local i = 1
                while i <= 30-quarter do
                    local add = phase == 2 and 10 or phase == 0 and -10 or 0
                    local direction = phase == 1 and 10 or phase == 0 and 10 or -10
                    graphics:mlrs(35+i, 30 + lwidth*add, quarter, lwidth*direction, self.active_param == 2 and 16 or 8)
                    phase = (phase + 1) % 4
                    i = i + quarter
                end
                local add = phase == 2 and 10 or phase == 0 and - 10 or 0
                local direction = phase == 1 and 10 or phase == 0 and 10 or -10
                local remainder = 30 % quarter == 0 and quarter or 30 % quarter
                graphics:mlrs(35 + i, 30 + lwidth*add, remainder, lwidth*direction*remainder/quarter,
                    self.active_param == 2 and 16 or 8)
                -- env > index
                graphics:mls(70, 40, 71+0.5*attack, 40 - 25*mindex,
                    self.active_param == 3 and 16 or 8)
                graphics:mls(71 + 0.5*attack, 40 - 25*mindex, 71 + 0.5*attack + 0.5*decay, 40 - 20*sustain*mindex,
                    self.active_param == 3 and 16 or 8)
                graphics:mls(72 + 0.5*attack + 0.5*decay, 40-20*sustain*mindex,
                    90-0.5*release, 40-20*sustain*mindex,
                    self.active_param == 3 and 16 or 8)
                graphics:mls(90-0.5*release, 40 - 20*sustain*mindex, 90, 40,
                    self.active_param == 3 and 16 or 8)
                -- lfo > index
                quarter = 10/freq
                phase = 1
                i = 1
                while i <= 30-quarter do
                    add = phase == 2 and 10 or phase == 0 and -10 or 0
                    direction = phase == 1 and 10 or phase == 0 and 10 or -10
                    graphics:mlrs(95+i, 30 + lindex*add, quarter, lindex*direction, self.active_param == 4 and 16 or 8)
                    phase = (phase + 1) % 4
                    i = i + quarter
                end
                add = phase == 2 and 10 or phase == 0 and - 10 or 0
                direction = phase == 1 and 10 or phase == 0 and 10 or -10
                remainder = 30 % quarter == 0 and quarter or 30 % quarter
                graphics:mlrs(95 + i, 30 + lindex*add, remainder, lindex*direction*remainder/quarter,
                    self.active_param == 4 and 16 or 8)
                --
                graphics:text(10, 50, "E>WID", self.active_param == 1 and 16 or 8)
                graphics:text(10, 60, string.format("%2.2f", mwidth), self.active_param == 1 and 16 or 8)
                graphics:text(40, 50, "L>WID", self.active_param == 2 and 16 or 8)
                graphics:text(40, 60, string.format("%2.2f", lwidth), self.active_param == 2 and 16 or 8)
                graphics:text(70, 50, "E>IND", self.active_param == 3 and 16 or 8)
                graphics:text(70, 60, string.format("%2.2f", mindex), self.active_param == 3 and 16 or 8)
                graphics:text(100, 50, "L>IND", self.active_param == 4 and 16 or 8)
                graphics:text(100, 60, string.format("%2.2f", lindex), self.active_param == 4 and 16 or 8)
            end
        },
        {
            -- Osc 2
            params = {"wave2", "octave2", "coarse2", "fine2", "width2", "numerator2", "denominator2", "index2"},
            render = function()
                graphics:text(0, 8, "OSC 2", 8)
                local wave      = params:get("wave2")
                local octave    = params:get("octave2")
                local coarse    = params:get("coarse2")
                local fine      = params:get("fine2")
                local width     = params:get("width2")
                local numerator = params:get("numerator2")
                local denominator = params:get("denominator2")
                local index     = params:get("index2")
                graphics:text(10, 20, "WAV", self.active_param == 1 and 16 or 8)
                graphics:text(10, 30, wave == 1 and "TRI" or "SQR", self.active_param == 1 and 16 or 8)
                graphics:text(40, 20, "OCT", self.active_param == 2 and 16 or 8)
                graphics:text(40, 30, octave, self.active_param == 2 and 16 or 8)
                graphics:text(70, 20, "CRS", self.active_param == 3 and 16 or 8)
                graphics:text(70, 30, coarse, self.active_param == 3 and 16 or 8)
                graphics:text(100, 20, "FINE", self.active_param == 4 and 16 or 8)
                graphics:text(100, 30, string.format("%2.2f", fine), self.active_param == 4 and 16 or 8)
                graphics:text(10, 50, "WID", self.active_param == 5 and 16 or 8)
                graphics:text(10, 60, string.format("%2.2f", width), self.active_param == 5 and 16 or 8)
                graphics:text(55, 50, "FM", self.active_param == 6 and 16 or self.active_param == 7 and 16 or 8)
                graphics:text(50, 60, numerator, self.active_param == 6 and 16 or 8)
                graphics:text(60, 60, "/", 8)
                graphics:text(70, 60, denominator, self.active_param == 7 and 16 or 8)
                graphics:text(100, 50, "IND", self.active_param == 8 and 16 or 8)
                graphics:text(100, 60, string.format("%2.2f", index), self.active_param == 8 and 16 or 8)
            end
        },
        {
            -- Osc 2 part two
            params = {"mwidth2", "lwidth2", "mindex2", "lindex2"},
            render = function()
                graphics:text(0, 8, "OSC 2", 8)
                local mwidth    = params:get("mwidth2")
                local lwidth    = params:get("lwidth2")
                local mindex    = params:get("mindex2")
                local lindex    = params:get("lindex2")
                local freq      = params:get("lfreq")
                local attack    = params:get("mattack")
                local decay     = params:get("mdecay")
                local sustain   = params:get("msustain")
                local release   = params:get("mrelease")
                -- env > width
                graphics:mls(10, 40, 11+0.5*attack, 40 - 25*mwidth,
                    self.active_param == 1 and 16 or 8)
                graphics:mls(11 + 0.5*attack, 40 - 25*mwidth, 11 + 0.5*attack + 0.5*decay, 40 - 20*sustain*mwidth,
                    self.active_param == 1 and 16 or 8)
                graphics:mls(12 + 0.5*attack + 0.5*decay, 40-20*sustain*mwidth,
                    30-0.5*release, 40-20*sustain*mwidth,
                    self.active_param == 1 and 16 or 8)
                graphics:mls(30-0.5*release, 40 - 20*sustain*mwidth, 30, 40,
                    self.active_param == 1 and 16 or 8)
                -- lfo > width
                local quarter = 10/freq
                local phase = 1
                local i = 1
                while i <= 30-quarter do
                    local add = phase == 2 and 10 or phase == 0 and -10 or 0
                    local direction = phase == 1 and 10 or phase == 0 and 10 or -10
                    graphics:mlrs(35+i, 30 + lwidth*add, quarter, lwidth*direction, self.active_param == 2 and 16 or 8)
                    phase = (phase + 1) % 4
                    i = i + quarter
                end
                local add = phase == 2 and 10 or phase == 0 and - 10 or 0
                local direction = phase == 1 and 10 or phase == 0 and 10 or -10
                local remainder = 30 % quarter == 0 and quarter or 30 % quarter
                graphics:mlrs(35 + i, 30 + lwidth*add, remainder, lwidth*direction*remainder/quarter,
                    self.active_param == 2 and 16 or 8)
                -- env > index
                graphics:mls(70, 40, 71+0.5*attack, 40 - 25*mindex,
                    self.active_param == 3 and 16 or 8)
                graphics:mls(71 + 0.5*attack, 40 - 25*mindex, 71 + 0.5*attack + 0.5*decay, 40 - 20*sustain*mindex,
                    self.active_param == 3 and 16 or 8)
                graphics:mls(72 + 0.5*attack + 0.5*decay, 40-20*sustain*mindex,
                    90-0.5*release, 40-20*sustain*mindex,
                    self.active_param == 3 and 16 or 8)
                graphics:mls(90-0.5*release, 40 - 20*sustain*mindex, 90, 40,
                    self.active_param == 3 and 16 or 8)
                -- lfo > index
                quarter = 10/freq
                phase = 1
                i = 1
                while i <= 30-quarter do
                    add = phase == 2 and 10 or phase == 0 and -10 or 0
                    direction = phase == 1 and 10 or phase == 0 and 10 or -10
                    graphics:mlrs(95+i, 30 + lindex*add, quarter, lindex*direction, self.active_param == 4 and 16 or 8)
                    phase = (phase + 1) % 4
                    i = i + quarter
                end
                add = phase == 2 and 10 or phase == 0 and - 10 or 0
                direction = phase == 1 and 10 or phase == 0 and 10 or -10
                remainder = 30 % quarter == 0 and quarter or 30 % quarter
                graphics:mlrs(95 + i, 30 + lindex*add, remainder, lindex*direction*remainder/quarter,
                    self.active_param == 4 and 16 or 8)
                --
                graphics:text(10, 50, "E>WID", self.active_param == 1 and 16 or 8)
                graphics:text(10, 60, string.format("%2.2f", mwidth), self.active_param == 1 and 16 or 8)
                graphics:text(40, 50, "L>WID", self.active_param == 2 and 16 or 8)
                graphics:text(40, 60, string.format("%2.2f", lwidth), self.active_param == 2 and 16 or 8)
                graphics:text(70, 50, "E>IND", self.active_param == 3 and 16 or 8)
                graphics:text(70, 60, string.format("%2.2f", mindex), self.active_param == 3 and 16 or 8)
                graphics:text(100, 50, "L>IND", self.active_param == 4 and 16 or 8)
                graphics:text(100, 60, string.format("%2.2f", lindex), self.active_param == 4 and 16 or 8)
            end
        },
        {
            -- highpass
            params = {"hipass", "hires", "mhipass", "lhipass", "mhires", "lhires", },
            render = function()
                graphics:text(0, 8, "HIPASS", 8)
                local hipass    = params:get("hipass")
                local hires     = params:get("hires")
                local mhipass   = params:get("mhipass")
                local lhipass   = params:get("lhipass")
                local mhires    = params:get("mhires")
                local lhires    = params:get("lhires")
                graphics:text(10, 20, "CUT", self.active_param == 1 and 16 or 8)
                graphics:text(10, 30, hipass, self.active_param == 1 and 16 or 8)
                graphics:text(55, 20, "E>CUT", self.active_param == 3 and 16 or 8)
                graphics:text(55, 30, string.format("%2.2f", mhipass), self.active_param == 3 and 16 or 8)
                graphics:text(100, 20, "L>CUT", self.active_param == 4 and 16 or 8)
                graphics:text(100, 30, string.format("%2.2f", lhipass), self.active_param == 4 and 16 or 8)
                graphics:text(10, 50, "RES", self.active_param == 2 and 16 or 8)
                graphics:text(10, 60, string.format("%2.2f", hires), self.active_param == 2 and 16 or 8)
                graphics:text(55, 50, "E>RES", self.active_param == 5 and 16 or 8)
                graphics:text(55, 60, string.format("%2.2f", mhires), self.active_param == 5 and 16 or 8)
                graphics:text(100, 50, "L>RES", self.active_param == 6 and 16 or 8)
                graphics:text(100, 60, string.format("%2.2f", lhires), self.active_param == 6 and 16 or 8)
            end
        },
        {
            -- lowpass
            params = {"lopass", "lores", "mlopass", "llopass", "mlores", "llores", },
            render = function()
                graphics:text(0, 8, "LOPASS", 8)
                local lopass    = params:get("lopass")
                local lores     = params:get("lores")
                local mlopass   = params:get("mlopass")
                local llopass   = params:get("llopass")
                local mlores    = params:get("mlores")
                local llores    = params:get("llores")
                graphics:text(10, 20, "CUT", self.active_param == 1 and 16 or 8)
                graphics:text(10, 30, lopass, self.active_param == 1 and 16 or 8)
                graphics:text(55, 20, "E>CUT", self.active_param == 3 and 16 or 8)
                graphics:text(55, 30, string.format("%2.2f", mlopass), self.active_param == 3 and 16 or 8)
                graphics:text(100, 20, "L>CUT", self.active_param == 4 and 16 or 8)
                graphics:text(100, 30, string.format("%2.2f", llopass), self.active_param == 4 and 16 or 8)
                graphics:text(10, 50, "RES", self.active_param == 2 and 16 or 8)
                graphics:text(10, 60, string.format("%2.2f", lores), self.active_param == 2 and 16 or 8)
                graphics:text(55, 50, "E>RES", self.active_param == 5 and 16 or 8)
                graphics:text(55, 60, string.format("%2.2f", mlores), self.active_param == 5 and 16 or 8)
                graphics:text(100, 50, "L>RES", self.active_param == 6 and 16 or 8)
                graphics:text(100, 60, string.format("%2.2f", llores), self.active_param == 6 and 16 or 8)
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
        graphics:rect(13, 29, 94, 10, 5)
        graphics:rect(14, 30, 92, 8, 0)
        graphics:text(15, 36, "please restart norns", 16)
    else
        local current_page = self.pages[self.active_page]
        current_page.render()
    end
    graphics:teardown()
end

return page
