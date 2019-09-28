local awesome, client, mouse, screen, tag = awesome, client, mouse, screen, tag
local ipairs, string, os, table, tostring, tonumber, type = ipairs, string, os, table, tostring, tonumber, type

local gears         = require("gears")
local awful         = require("awful")
                      require("awful.autofocus")
local wibox         = require("wibox")
local beautiful     = require("beautiful")
local naughty       = require("naughty")
local lain          = require("lain")
local hotkeys_popup = require("awful.hotkeys_popup").widget
                      require("awful.hotkeys_popup.keys")
local my_table      = awful.util.table or gears.table 
local dpi           = require("beautiful.xresources").apply_dpi


if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        if in_error then return end
        in_error = true
        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end

local function run_once(cmd_arr)
    for _, cmd in ipairs(cmd_arr) do
        awful.spawn.with_shell(string.format("pgrep -u $USER -fx '%s' > /dev/null || (%s)", cmd, cmd))
    end
end

run_once({ "compton", "unclutter -root", "xautolock -time 30 -locker blurlock" })

awful.spawn.with_shell("~/.config/awesome/lauchConky")

local themes		= { "purplecolor" }
local chosen_theme	= themes[1]
local modkey		= "Mod4"
local altkey		= "Mod1"
local terminal		= "termite %"
local editor		= os.getenv("EDITOR") or "nano"
local rofi_settings	= "rofi -show run"
local text_editor	= "mousepad"
local browser		= "env LD_PRELOAD='/usr/lib/libhardened_malloc.so' chromium %U"
local chromium		= "env LD_PRELOAD='/usr/lib/libhardened_malloc.so' chromium --proxy-server='socks5://127.0.0.1:9050'"
local filemanager	= "thunar"
local scrlocker		= "blurlock"
local tor_browser	= "env LD_PRELOAD='/usr/lib/libhardened_malloc.so' tor-browser"

awful.util.terminal = terminal
awful.util.tagnames = { "", "" , "", "", "" }

awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.floating,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
}

awful.util.taglist_buttons = my_table.join(
    awful.button({ }, 1, function(t) t:view_only() end),
    awful.button({ modkey }, 1, function(t)
        if client.focus then
            client.focus:move_to_tag(t)
        end
    end),
    awful.button({ }, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, function(t)
        if client.focus then
            client.focus:toggle_tag(t)
        end
    end),
    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

awful.util.tasklist_buttons = my_table.join(
    awful.button({ }, 1, function (c)
        if c == client.focus then
            c.minimized = true
        else
            c.minimized = false
            if not c:isvisible() and c.first_tag then
                c.first_tag:view_only()
            end
            client.focus = c
            c:raise()
        end
    end),
    awful.button({ }, 2, function (c) c:kill() end),
    awful.button({ }, 3, function ()
        local instance = nil

        return function ()
            if instance and instance.wibox.visible then
                instance:hide()
                instance = nil
            else
                instance = awful.menu.clients({theme = {width = 250}})
            end
        end
    end),
    awful.button({ }, 4, function () awful.client.focus.byidx(1) end),
    awful.button({ }, 5, function () awful.client.focus.byidx(-1) end)
)

lain.layout.termfair.nmaster           = 3
lain.layout.termfair.ncol              = 1
lain.layout.termfair.center.nmaster    = 3
lain.layout.termfair.center.ncol       = 1
lain.layout.cascade.tile.offset_x      = dpi(2)
lain.layout.cascade.tile.offset_y      = dpi(32)
lain.layout.cascade.tile.extra_padding = dpi(5)
lain.layout.cascade.tile.nmaster       = 5
lain.layout.cascade.tile.ncol          = 2

beautiful.init(string.format("%s/.config/awesome/themes/%s/theme.lua", os.getenv("HOME"), chosen_theme))

local myawesomemenu = {
    { "hotkeys", function() return false, hotkeys_popup.show_help end },
    { "manual", terminal .. " -e man awesome" },
    { "edit config", string.format("%s -e %s %s", terminal, editor, awesome.conffile) },
    { "restart", awesome.restart },
    { "quit", function() awesome.quit() end }
}

awful.util.mymainmenu = awful.menu({ items = { 
		{ "awesome", myawesomemenu, beautiful.awesome_icon },
                { "terminal", terminal },
                { "text editor", mousepad },
                { "file manager", filemanager },
                { "browser", chromium }
                                  }
                        })

screen.connect_signal("property::geometry", function(s)
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper

        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end)

awful.screen.connect_for_each_screen(function(s) beautiful.at_screen_connect(s) end)

root.buttons(my_table.join(
    awful.button({ }, 3, function () awful.util.mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))


globalkeys = my_table.join(
--hotkeys
awful.key({ modkey,           }, "Print", function() os.execute("screenshot") end, 
		{description = "Take A Screenshot", group = "hotkeys"}),

awful.key({ altkey, "Control" }, "l", function () os.execute(scrlocker) end, 
		{description = "Lock Screen", group = "hotkeys"}),

awful.key({                   }, "XF86MonBrightnessUp", function () os.execute("xbacklight -inc 10") end, 
		{description = "Increase Brightness", group = "hotkeys"}),

awful.key({                   }, "XF86MonBrightnessDown", function () os.execute("xbacklight -dec 10") end, 
		{description = "Decrease Brightness", group = "hotkeys"}),

awful.key({                   }, "XF86AudioRaiseVolume", function () os.execute(string.format("amixer -q set %s 5%%+", beautiful.volume.channel)) beautiful.volume.update() end, 	
		{description = "Increase Volume", group = "hotkeys"}),

awful.key({                   }, "XF86AudioLowerVolume", function () os.execute(string.format("amixer -q set %s 5%%-", beautiful.volume.channel)) beautiful.volume.update() end, 	
		{description = "Decrease Volume", group = "hotkeys"}),

awful.key({                   }, "XF86AudioMute", function () os.execute(string.format("amixer -q set %s toggle", beautiful.volume.togglechannel or beautiful.volume.channel)) beautiful.volume.update() end, 
		{description = "Mute Volume", group = "hotkeys"}),

awful.key({ modkey,           }, "c", function () awful.spawn.with_shell("xsel | xsel -i -b") end, 
		{description = "Copy Terminal To Gtk", group = "hotkeys"}),

awful.key({ modkey,           }, "v", function () awful.spawn.with_shell("xsel -b | xsel") end, 
		{description = "Copy Gtk To Terminal", group = "hotkeys"}),

--tag
awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
		{description = "View Previous", group = "tag"}),

awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
		{description = "View Next", group = "tag"}),

awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
		{description = "Go Back", group = "tag"}),

awful.key({ altkey,           }, "Left", function () lain.util.tag_view_nonempty(-1) end,
		{description = "View  Previous Nonempty", group = "tag"}),

awful.key({ altkey,            }, "Right", function () lain.util.tag_view_nonempty(1) end,
		{description = "View  Previous Nonempty", group = "tag"}),

awful.key({ modkey, "Shift"   }, "n", function () lain.util.add_tag() end,
		{description = "Add New Tag", group = "tag"}),

awful.key({ modkey, "Shift"   }, "r", function () lain.util.rename_tag() end,
		{description = "Rename Tag", group = "tag"}),

awful.key({ modkey, "Shift"   }, "Left", function () lain.util.move_tag(-1) end,
		{description = "Move Tag To The Left", group = "tag"}),

awful.key({ modkey, "Shift"   }, "Right", function () lain.util.move_tag(1) end,
		{description = "Move Tag To The Right", group = "tag"}),

awful.key({ modkey, "Shift"   }, "d", function () lain.util.delete_tag() end,
		{description = "Delete Tag", group = "tag"}),

--client
awful.key({ modkey, "Control" }, "n", function () local c = awful.client.restore() if c then client.focus = c c:raise() end end,
		{description = "Restore Minimized", group = "client"}),

awful.key({ altkey,           }, "j", function () awful.client.focus.byidx( 1) end,
		{description = "Focus Next By Index", group = "client"}),

awful.key({ altkey,           }, "k", function () awful.client.focus.byidx(-1) end,
		{description = "Focus Previous By Index", group = "client"}),

awful.key({ modkey,            }, "j", function() awful.client.focus.global_bydirection("down") if client.focus then client.focus:raise() end end,
		{description = "Focus Down", group = "client"}),

awful.key({ modkey,            }, "k", function() awful.client.focus.global_bydirection("up") if client.focus then client.focus:raise() end end,
		{description = "Focus Up", group = "client"}),

awful.key({ modkey,            }, "h", function() awful.client.focus.global_bydirection("left") if client.focus then client.focus:raise() end end,
		{description = "Focus Left", group = "client"}),

awful.key({ modkey,           }, "l", function() awful.client.focus.global_bydirection("right") if client.focus then client.focus:raise() end end,
		{description = "Focus Right", group = "client"}),

awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1) end,
		{description = "Swap With Next Client By Index", group = "client"}),

awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1) end,
		{description = "Swap With Previous Client By Index", group = "client"}),

awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
		{description = "Jump To Urgent Client", group = "client"}),

awful.key({ modkey,           }, "Tab", function () awful.client.focus.history.previous() if client.focus then client.focus:raise() end end,
		{description = "Go Back", group = "client"}),

--screen
awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
		{description = "Focus The Next Screen", group = "screen"}),

awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
		{description = "Focus The Previous Screen", group = "screen"}),

--layout
awful.key({ modkey,           }, "Down", function () lain.util.useless_gaps_resize(1) end,
		{description = "Increment Useless Gaps", group = "layout"}),

awful.key({ modkey,           }, "Up", function () lain.util.useless_gaps_resize(-1) end,
		{description = "Decrement Useless Gaps", group = "layout"}),

awful.key({ modkey, "Control"   }, "Right",     function () awful.tag.incmwfact( 0.05) end,
		{description = "Increase Master Width Factor", group = "layout"}),

awful.key({ modkey, "Control"   }, "Left",     function () awful.tag.incmwfact(-0.05) end,
		{description = "Decrease Master Width Factor", group = "layout"}),

awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
		{description = "Increase The Number Of Master Clients", group = "layout"}),

awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
		{description = "Decrease The Number Of Master Clients", group = "layout"}),

awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true) end,
		{description = "Increase The Number Of Columns", group = "layout"}),

awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true) end,
		{description = "Decrease The Number Of Columns", group = "layout"}),

awful.key({ modkey,           }, "space", function () awful.layout.inc( 1) end,
		{description = "Select Next", group = "layout"}),

awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1) end,
		{description = "Select Previous", group = "layout"}),

--widgets
awful.key({ altkey,           }, "c", function () if beautiful.cal then beautiful.cal.show(7) end end,
		{description = "Show Calendar", group = "widgets"}),

awful.key({ altkey,           }, "h", function () if beautiful.fs then beautiful.fs.show(7) end end,
		{description = "Show Filesystem", group = "widgets"}),

awful.key({ altkey,           }, "w", function () if beautiful.weather then beautiful.weather.show(7) end end,
		{description = "Show Weather", group = "widgets"}),

awful.key({ altkey, "Control" }, "Up", function () os.execute("mpc toggle") beautiful.mpd.update() end,
		{description = "Mpc Toggle", group = "widgets"}),

awful.key({ altkey, "Control" }, "Down", function () os.execute("mpc stop") beautiful.mpd.update() end,
		{description = "Mpc Stop", group = "widgets"}),

awful.key({ altkey, "Control" }, "Left", function () os.execute("mpc prev") beautiful.mpd.update() end,
		{description = "Mpc Prev", group = "widgets"}),

awful.key({ altkey, "Control" }, "Right", function () os.execute("mpc next") beautiful.mpd.update() end,
		{description = "Mpc Next", group = "widgets"}),

awful.key({ altkey,           }, "0", function () local common = { text = "MPD widget ", position = "top_middle", timeout = 2 } if beautiful.mpd.timer.started then beautiful.mpd.timer:stop() common.text = common.text .. lain.util.markup.bold("OFF") else beautiful.mpd.timer:start() common.text = common.text .. lain.util.markup.bold("ON") end naughty.notify(common) end,
		{description = "Mpc On/Off", group = "widgets"}),

--launcher
awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
		{description = "Terminal", group = "launcher"}),

awful.key({ modkey,           }, "z", function () awful.screen.focused().quake:toggle() end,
		{description = "Quake Terminal", group = "launcher"}),

awful.key({ modkey,           }, "i", function () awful.spawn(browser) end,
		{description = "Chromium", group = "launcher"}),

awful.key({ modkey,           }, "y", function () awful.spawn(chromium) end,
		{description = "Chromium with tor", group = "launcher"}),

awful.key({ modkey,           }, "a", function () awful.spawn(text_editor) end,
		{description = "Txt Editor", group = "launcher"}),

awful.key({ modkey,           }, "/", function () awful.spawn(filemanager) end,
		{description = "File Manager", group = "launcher"}),

awful.key({ modkey,           }, "g", function () awful.spawn(tor_browser) end,
		{description = "Tor Browser", group = "launcher"}),

awful.key({ modkey,           }, "r", function () awful.screen.focused().mypromptbox:run() end,
		{description = "Run Prompt", group = "launcher"}),

awful.key({ modkey,           }, "p", function () awful.spawn(rofi_settings) end),

--awesome
awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
		{description = "Show Help", group="awesome"}),

awful.key({ modkey,           }, "w", function () awful.util.mymainmenu:show() end,
		{description = "Show Main Menu", group = "awesome"}),

awful.key({ modkey,           }, "b", function () for s in screen do s.mywibox.visible = not s.mywibox.visible if s.mybottomwibox then s.mybottomwibox.visible = not s.mybottomwibox.visible end end end,
		{description = "Toggle Wibox", group = "awesome"}),

awful.key({ modkey, "Control" }, "r", awesome.restart,
		{description = "Reload Awesome", group = "awesome"}),

awful.key({ modkey, "Shift"   }, "q", awesome.quit,
		{description = "Quit Awesome", group = "awesome"}),

awful.key({ modkey,           }, "x", function () awful.prompt.run { prompt = "Run Lua code: ", textbox      = awful.screen.focused().mypromptbox.widget, exe_callback = awful.util.eval, history_path = awful.util.get_cache_dir() .. "/history_eval" } end,
		{description = "Lua Execute Prompt", group = "awesome"})

)

clientkeys = my_table.join(
    awful.key({ modkey,           }, "d",      lain.util.magnify_client,
              {description = "Free Client", group = "client"}),

    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "Toggle Fullscreen", group = "client"}),

    awful.key({ modkey,		  }, "q",      function (c) c:kill()                         end,
              {description = "Close", group = "client"}),

    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "Toggle Floating", group = "client"}),

    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "Move To Master", group = "client"}),

    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "Move To Screen", group = "client"}),

    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "Toggle Keep On Top", group = "client"}),
 
   awful.key({ modkey,           }, "n",
        function (c)
            c.minimized = true
        end ,
        {description = "Minimize", group = "client"}),

    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "Maximize", group = "client"})
)

for i = 1, 9 do

    local descr_view, descr_toggle, descr_move, descr_toggle_focus
    if i == 1 or i == 9 then
        descr_view = {description = "View Tag #", group = "tag"}
        descr_toggle = {description = "Toggle Tag #", group = "tag"}
        descr_move = {description = "Move Focused Client To Tag #", group = "tag"}
        descr_toggle_focus = {description = "Toggle Focused Client On Tag #", group = "tag"}
    end
    globalkeys = my_table.join(globalkeys,

        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  descr_view),

        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  descr_toggle),

        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  descr_move),

        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  descr_toggle_focus)
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)


root.keys(globalkeys)

awful.rules.rules = {

    { rule = { },
      properties = { border_width = 0,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen,
                     size_hints_honor = false
     }
    },


    { rule_any = { type = { "dialog", "normal" } },
      properties = { titlebars_enabled = false } },

    -- Floating clients.
	{ rule = { role = "About" },
        properties = { floating = true, ontop= true,width = 600 , height = 400, x = 300, y = 100 } },

	{ rule = { name = "Task Manager - Chromium" },
        properties = { floating = true, ontop= true,width = 600 , height = 400, x = 300, y = 100 } },

	{ rule = { name = "Text Import" },
        properties = { floating = true, ontop= true,width = 800 , height = 600, x = 300, y = 100 } },

	{ rule = { name = "Open File" },
        properties = { floating = true, ontop= true,width = 800 , height = 500, x = 300, y = 100 } },

    	{ rule = { name = "Library" },
        properties = { floating = true, ontop= true,width = 800 , height = 500, x = 300, y = 100 } },

	{ rule = { role = "pop-up" },
        properties = { floating = true, ontop= true,width = 600 , height = 400, x = 300, y = 100 } },

	{ rule = { class = "Thunar" },
        properties = { floating = true, ontop= true,width = 1000 , height = 600, x = 180, y = 90 } },

        { rule = { name = "Rename" },
        properties = { floating = true, ontop= true,width = 500 , height = 300, x = 180, y = 90 } },

	{ rule = { name = "About the Xfce Desktop Environment" },
        properties = { floating = true, ontop= true,width = 400 , height = 400, x = 450, y = 200 } },

	{ rule = { name = "Burp Suite Community Edition" },
        properties = { floating = true, ontop= true,width = 1000 , height = 600, x = 200, y = 50 } },

	{ rule = { class = "xpdf" },
        properties = { floating = true, ontop= true,width = 800 , height = 600, x = 300, y = 100 } },

	{ rule = { name = "xarchiver" },
        properties = { floating = true, ontop= true,width = 800 , height = 600, x = 300, y = 100 } },

	{ rule = { name = "Extract files" },
        properties = { floating = true, ontop= true,width = 800 , height = 600, x = 300, y = 100 } },

	{ rule = { name = "Please select the destination directory" },
        properties = { floating = true, ontop= true,width = 800 , height = 600, x = 300, y = 100 } },

	{ rule = { name = "Customize Look and Feel" },
        properties = { floating = true, ontop= true,width = 800 , height = 600, x = 300, y = 100 } },

    	{ rule = { class = "Gimp", role = "gimp-image-window" },
          properties = { maximized = true } },
}

client.connect_signal("manage", function (c)
       c.shape = function(cr,w,h)
        gears.shape.rounded_rect(cr,w,h,5)
end
    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then

        awful.placement.no_offscreen(c)
    end
end)

client.connect_signal("request::titlebars", function(c)

    if beautiful.titlebar_fun then
        beautiful.titlebar_fun(c)
        return
    end

    local buttons = my_table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 2, function() c:kill() end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c, {size = dpi(14)}) : setup {
        { 
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { 
            { 
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { 
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)


client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = true})
end)


function border_adjust(c)
    if c.maximized then 
        c.border_width = 0
    elseif #awful.screen.focused().clients > 1 then
        c.border_width = beautiful.border_width
        c.border_color = beautiful.border_focus
    end
end

client.connect_signal("property::maximized", border_adjust)
client.connect_signal("focus", border_adjust)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
