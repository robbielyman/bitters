local page = {
    popup_active = false,
    active_page = 1,
    active_param = 1,
    pages = {{"amp"},},
}

function page:init(bool)
    self.popup_active = bool
end

function page:scroll(delta)
    local n = #(self.pages[self.active_page])
    local val = (self.active_param + delta) % n
    self.active_param = val == 0 and n or val
end

function page:left()
    local val = (self.active_page - 1) % #self.pages
    self.active_page = val == 0 and #self.pages or val
end

function page:right()
    local val = (self.active_page + 1) % #self.pages
    self.active_page = val == 0 and #self.pages or val
end

function page:delta(d)
    local param = self.pages[self.active_page][self.active_param]
    params:delta(param,d)
end

return page
