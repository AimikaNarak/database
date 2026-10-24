-- Super Bomb Survival hub: auto dodge + auto collect + round results UI (UIFX)
-- Toggle window: RightControl. Stop everything: close the window or getgenv().SBSHubStop()

local UIFX = (function()
-- UIFX: dark-minimal UI kit for executor scripts (plain untyped Luau)
-- Usage (inline, single-file scripts):
--   local UIFX = (function() <paste this file> end)()
-- Usage (local file in executor workspace):
--   local UIFX = loadstring(readfile("UIFX.lua"))()

local UIFX = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Design tokens. Change colors here, never inline in elements.
UIFX.Theme = {
    Bg = Color3.fromRGB(16, 16, 20),
    Panel = Color3.fromRGB(23, 23, 29),
    Elevated = Color3.fromRGB(31, 31, 39),
    Stroke = Color3.fromRGB(46, 46, 56),
    Text = Color3.fromRGB(236, 236, 242),
    SubText = Color3.fromRGB(148, 148, 162),
    Accent = Color3.fromRGB(108, 138, 255),
    Good = Color3.fromRGB(78, 196, 120),
    Warn = Color3.fromRGB(238, 178, 68),
    Bad = Color3.fromRGB(232, 82, 92),
    Gold = Color3.fromRGB(255, 196, 64), -- "favourite / final" marks, streak flame
    Hardcore = Color3.fromRGB(176, 112, 255), -- rounds played with Hardcore on
    Font = Enum.Font.GothamMedium,
    FontBold = Enum.Font.GothamBold,
    Radius = 8,
}

-- Motion tokens. Fast = hover/press, Base = state change, Slow = open/close.
UIFX.Motion = {
    Fast = TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    Base = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    Slow = TweenInfo.new(0.38, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    Spring = TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
}

local Theme = UIFX.Theme
local Motion = UIFX.Motion

-- ── primitives ──────────────────────────────────────────────

local function new(class, props, children)
    local inst = Instance.new(class)
    local parent = nil
    for k, v in pairs(props or {}) do
        if k == "Parent" then
            parent = v
        else
            inst[k] = v
        end
    end
    for _, child in ipairs(children or {}) do
        child.Parent = inst
    end
    if parent then
        inst.Parent = parent
    end
    return inst
end
UIFX.new = new

local function tween(inst, info, goal)
    local t = TweenService:Create(inst, info, goal)
    t:Play()
    return t
end
UIFX.tween = tween

local function corner(radius)
    return new("UICorner", { CornerRadius = UDim.new(0, radius or Theme.Radius) })
end

local function stroke(color, transparency)
    return new("UIStroke", {
        Color = color or Theme.Stroke,
        Transparency = transparency or 0,
        Thickness = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
end

local function padding(px)
    return new("UIPadding", {
        PaddingTop = UDim.new(0, px),
        PaddingBottom = UDim.new(0, px),
        PaddingLeft = UDim.new(0, px),
        PaddingRight = UDim.new(0, px),
    })
end

local function label(text, size, color, font)
    return new("TextLabel", {
        BackgroundTransparency = 1,
        Text = text,
        TextSize = size or 13,
        TextColor3 = color or Theme.Text,
        Font = font or Theme.Font,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Size = UDim2.new(1, 0, 1, 0),
    })
end

local function isPointer(input)
    return input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch
end

local function isMove(input)
    return input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
end

-- Hidden parent first: gethui() is unreachable from game scripts.
local function guiParent()
    if type(gethui) == "function" then
        local ok, hui = pcall(gethui)
        if ok and hui then
            return hui
        end
    end
    local ok, core = pcall(function()
        return game:GetService("CoreGui")
    end)
    if ok and core then
        return core
    end
    return Players.LocalPlayer:WaitForChild("PlayerGui")
end

-- Ink ripple from the pointer position. Button needs ClipsDescendants = true.
local function ripple(button)
    local mouse = UserInputService:GetMouseLocation()
    local abs = button.AbsolutePosition
    local size = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2.2
    local dot = new("Frame", {
        BackgroundColor3 = Theme.Text,
        BackgroundTransparency = 0.86,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromOffset(mouse.X - abs.X, mouse.Y - abs.Y),
        Size = UDim2.fromOffset(0, 0),
        ZIndex = button.ZIndex + 1,
        Parent = button,
    }, { corner(9999) })
    tween(dot, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(size, size),
        BackgroundTransparency = 1,
    })
    task.delay(0.55, function()
        dot:Destroy()
    end)
end
UIFX.ripple = ripple

-- Icon into a holder Frame. spec:
--   { Image = "rbxassetid://..", Offset = Vector2, Size = Vector2, Color = Color3 }  (sprite sheets)
--   { Glyph = "A", Color = Color3 }   (letter badge, for items without a known asset)
-- Only pass asset ids read from the game or given by the user, never guessed ones.
function UIFX.icon(spec, holder)
    if not spec then
        return nil
    end
    for _, ch in ipairs(holder:GetChildren()) do
        ch:Destroy()
    end
    if spec.Image then
        return new("ImageLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Image = spec.Image,
            ImageRectOffset = spec.Offset or Vector2.zero,
            ImageRectSize = spec.Size or Vector2.zero,
            ImageColor3 = spec.Color or Color3.new(1, 1, 1),
            ScaleType = Enum.ScaleType.Fit,
            Parent = holder,
        })
    end
    local badge = new("Frame", {
        BackgroundColor3 = spec.Color or Theme.Elevated,
        Size = UDim2.fromScale(1, 1),
        Parent = holder,
    }, { corner(9999), stroke(Theme.Stroke, 0.2) })
    local l = label(spec.Glyph or "?", math.max(10, math.floor(holder.Size.Y.Offset * 0.5 + 0.5)), Theme.Text, Theme.FontBold)
    l.TextXAlignment = Enum.TextXAlignment.Center
    l.Parent = badge
    return badge
end

-- 3D icon from a live instance (BasePart or Model): clones it into a ViewportFrame.
-- Strips scripts, guis, sounds, particles and lights so only the mesh shows.
function UIFX.viewport(holder, source)
    local ok, copy = pcall(function()
        return source:Clone()
    end)
    if not ok or not copy then
        return nil
    end
    for _, d in ipairs(copy:GetDescendants()) do
        if d:IsA("LuaSourceContainer") or d:IsA("BillboardGui") or d:IsA("SurfaceGui")
            or d:IsA("Sound") or d:IsA("ParticleEmitter") or d:IsA("Light")
            or d:IsA("BodyMover") or d:IsA("Constraint") or d:IsA("TouchTransmitter")
            or d:IsA("Highlight") then
            d:Destroy()
        elseif d:IsA("BasePart") then
            d.Anchored = true
            if d.Name == "Hitbox" then
                d.Transparency = 1
            end
        end
    end
    local cf, size
    if copy:IsA("BasePart") then
        copy.Anchored = true
        cf, size = copy.CFrame, copy.Size
    elseif copy:IsA("Model") then
        cf, size = copy:GetBoundingBox()
    else
        copy:Destroy()
        return nil
    end
    for _, ch in ipairs(holder:GetChildren()) do
        ch:Destroy()
    end
    local vf = new("ViewportFrame", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Ambient = Color3.fromRGB(200, 200, 200),
        LightColor = Color3.new(1, 1, 1),
        LightDirection = Vector3.new(-1, -1, -0.5),
        Parent = holder,
    })
    local cam = new("Camera", { FieldOfView = 40, Parent = vf })
    vf.CurrentCamera = cam
    copy.Parent = vf
    local radius = size.Magnitude / 2
    local dist = radius / math.tan(math.rad(20)) * 1.05
    local dir = Vector3.new(1, 0.8, 1).Unit
    cam.CFrame = CFrame.lookAt(cf.Position + dir * dist, cf.Position)
    return vf
end

-- ── window ──────────────────────────────────────────────────

function UIFX.Window(opts)
    opts = opts or {}
    local title = opts.Title or "Script"
    local size = opts.Size or UDim2.fromOffset(520, 340)
    local toggleKey = opts.ToggleKey or Enum.KeyCode.RightControl
    local guiName = "UIFX_" .. title

    local win = { Alive = true, Tabs = {} }
    local conns = {}
    local statuses = {}
    -- elements with richer state queue an apply() here; the window Heartbeat runs it
    -- (same "lacking capability" reason as statuses)
    local updaters = {}

    local function track(conn)
        table.insert(conns, conn)
        return conn
    end
    win.track = track

    -- Single instance: a re-run removes the old window; the old copy's
    -- watchdog sees its gui lose its Parent and shuts itself down.
    local parent = guiParent()
    local old = parent:FindFirstChild(guiName)
    if old then
        old:Destroy()
    end

    local gui = new("ScreenGui", {
        Name = guiName,
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999,
    })
    gui.Parent = parent
    win.Gui = gui

    local root = new("CanvasGroup", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = size,
        BackgroundColor3 = Theme.Bg,
        GroupTransparency = 1,
        Parent = gui,
    }, { corner(Theme.Radius + 2), stroke(Theme.Stroke) })
    local scale = new("UIScale", { Scale = 0.94, Parent = root })
    win.Root = root

    -- top bar
    local topbar = new("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 38),
        Parent = root,
    })
    local titleLabel = label(title, 14, Theme.Text, Theme.FontBold)
    titleLabel.Position = UDim2.fromOffset(14, 0)
    titleLabel.Size = UDim2.new(1, -100, 1, 0)
    titleLabel.Parent = topbar
    new("Frame", {
        BackgroundColor3 = Theme.Stroke,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -1),
        Size = UDim2.new(1, 0, 0, 1),
        Parent = topbar,
    })

    local function topButton(text, xOffset, hoverColor)
        local b = new("TextButton", {
            AutoButtonColor = false,
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, xOffset, 0.5, 0),
            Size = UDim2.fromOffset(26, 26),
            BackgroundColor3 = Theme.Elevated,
            BackgroundTransparency = 1,
            Text = text,
            TextSize = 16,
            TextColor3 = Theme.SubText,
            Font = Theme.FontBold,
            Parent = topbar,
        }, { corner(6) })
        track(b.MouseEnter:Connect(function()
            tween(b, Motion.Fast, { BackgroundTransparency = 0, TextColor3 = hoverColor })
        end))
        track(b.MouseLeave:Connect(function()
            tween(b, Motion.Fast, { BackgroundTransparency = 1, TextColor3 = Theme.SubText })
        end))
        return b
    end
    local closeBtn = topButton("×", -8, Theme.Bad)
    local minBtn = topButton("–", -38, Theme.Text)

    -- smooth drag by the top bar
    do
        local dragging = false
        local startMouse, startPos
        track(topbar.InputBegan:Connect(function(input)
            if isPointer(input) then
                dragging = true
                startMouse = input.Position
                startPos = root.Position
            end
        end))
        track(UserInputService.InputEnded:Connect(function(input)
            if isPointer(input) then
                dragging = false
            end
        end))
        track(UserInputService.InputChanged:Connect(function(input)
            if dragging and isMove(input) then
                local d = input.Position - startMouse
                tween(root, Motion.Fast, {
                    Position = UDim2.new(
                        startPos.X.Scale, startPos.X.Offset + d.X,
                        startPos.Y.Scale, startPos.Y.Offset + d.Y
                    ),
                })
            end
        end))
    end

    -- navigation + pages. opts.Nav = "top": pill tab bar under the title with a sliding
    -- highlight; default: classic left sidebar.
    local topNav = opts.Nav == "top"
    local sidebar, indicator, tabList, pages
    if topNav then
        local bar = new("Frame", {
            BackgroundColor3 = Theme.Panel,
            Position = UDim2.fromOffset(12, 46),
            Size = UDim2.new(1, -24, 0, 36),
            Parent = root,
        }, { corner(9999), stroke(Theme.Stroke, 0.3) })
        indicator = new("Frame", {
            BackgroundColor3 = Theme.Accent,
            Position = UDim2.fromOffset(4, 4),
            Size = UDim2.fromOffset(0, 28),
            Visible = false,
            Parent = bar,
        }, { corner(9999) })
        new("UIGradient", {
            Rotation = 90,
            Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(200, 200, 225)),
            Parent = indicator,
        })
        tabList = new("Frame", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(4, 4),
            Size = UDim2.new(1, -8, 1, -8),
            ZIndex = 2,
            Parent = bar,
        })
        new("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 4),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = tabList,
        })
        sidebar = tabList
        pages = new("Frame", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(0, 88),
            Size = UDim2.new(1, 0, 1, -88),
            Parent = root,
        })
    else
        sidebar = new("Frame", {
            BackgroundColor3 = Theme.Panel,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(0, 38),
            Size = UDim2.new(0, 132, 1, -38),
            Parent = root,
        })
        new("UIListLayout", {
            Padding = UDim.new(0, 4),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = sidebar,
        })
        new("UIPadding", {
            PaddingTop = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            Parent = sidebar,
        })
        indicator = new("Frame", {
            BackgroundColor3 = Theme.Accent,
            BorderSizePixel = 0,
            Size = UDim2.fromOffset(3, 18),
            Position = UDim2.fromOffset(2, 14),
            Visible = false,
            Parent = root,
        }, { corner(2) })
        pages = new("Frame", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(132, 38),
            Size = UDim2.new(1, -132, 1, -38),
            Parent = root,
        })
    end

    -- open / close / minimize
    local visible = false
    local minimized = false

    function win:Show()
        visible = true
        gui.Enabled = true
        tween(root, Motion.Slow, { GroupTransparency = 0 })
        tween(scale, Motion.Spring, { Scale = 1 })
    end

    function win:Hide()
        visible = false
        tween(root, Motion.Base, { GroupTransparency = 1 })
        local t = tween(scale, Motion.Base, { Scale = 0.94 })
        t.Completed:Connect(function()
            if not visible and win.Alive then
                gui.Enabled = false
            end
        end)
    end

    function win:Toggle()
        if visible then
            win:Hide()
        else
            win:Show()
        end
    end

    function win:Destroy()
        if not win.Alive then
            return
        end
        win.Alive = false
        for _, c in ipairs(conns) do
            c:Disconnect()
        end
        table.clear(conns)
        if opts.OnClose then
            task.spawn(opts.OnClose)
        end
        local t = tween(root, Motion.Base, { GroupTransparency = 1 })
        tween(scale, Motion.Base, { Scale = 0.9 })
        t.Completed:Connect(function()
            gui:Destroy()
        end)
    end

    track(closeBtn.MouseButton1Click:Connect(function()
        win:Destroy()
    end))
    track(minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            tween(root, Motion.Base, { Size = UDim2.new(size.X.Scale, size.X.Offset, 0, 38) })
        else
            tween(root, Motion.Spring, { Size = size })
        end
    end))
    track(UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and not win.Capturing and input.KeyCode == toggleKey then
            win:Toggle()
        end
    end))
    function win:SetToggleKey(key)
        toggleKey = key
    end
    function win:GetToggleKey()
        return toggleKey
    end

    -- One thread owns every text write coming from outside (game callbacks
    -- that touch protected gui can fail with "lacking capability").
    track(RunService.Heartbeat:Connect(function()
        if not gui.Parent then
            win:Destroy()
            return
        end
        for _, s in ipairs(statuses) do
            if s.dirty then
                s.dirty = false
                s.body.Text = s.text
                s.body.TextColor3 = s.color
            end
        end
        for _, u in ipairs(updaters) do
            if u.dirty then
                u.dirty = false
                local ok, err = pcall(u.apply)
                if not ok then
                    print("[UIFX] update error: " .. tostring(err))
                end
            end
        end
    end))

    -- ── notifications ──
    local toastHolder = new("Frame", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -16, 1, -16),
        Size = UDim2.fromOffset(280, 400),
        Parent = gui,
    })
    new("UIListLayout", {
        Padding = UDim.new(0, 8),
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = toastHolder,
    })
    local toastCount = 0

    function win:Notify(text, kind, duration)
        duration = duration or 3
        local color = Theme[kind or "Accent"] or Theme.Accent
        toastCount = toastCount + 1
        local slot = new("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            LayoutOrder = toastCount,
            ClipsDescendants = false,
            Parent = toastHolder,
        })
        local card = new("Frame", {
            BackgroundColor3 = Theme.Panel,
            Position = UDim2.fromOffset(300, 0),
            Size = UDim2.new(1, 0, 1, 0),
            Parent = slot,
        }, { corner(), stroke(Theme.Stroke) })
        new("Frame", {
            BackgroundColor3 = color,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(0, 8),
            Size = UDim2.new(0, 3, 1, -16),
            Parent = card,
        }, { corner(2) })
        local msg = label(text, 13, Theme.Text)
        msg.TextWrapped = true
        msg.Position = UDim2.fromOffset(14, 0)
        msg.Size = UDim2.new(1, -24, 1, -4)
        msg.Parent = card
        local bar = new("Frame", {
            BackgroundColor3 = color,
            BackgroundTransparency = 0.4,
            BorderSizePixel = 0,
            AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.new(0, 0, 1, 0),
            Size = UDim2.new(1, 0, 0, 2),
            Parent = card,
        })
        tween(slot, Motion.Base, { Size = UDim2.new(1, 0, 0, 52) })
        tween(card, Motion.Spring, { Position = UDim2.fromOffset(0, 0) })
        tween(bar, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 0, 2) })
        task.delay(duration, function()
            local t = tween(card, Motion.Base, { Position = UDim2.fromOffset(300, 0) })
            t.Completed:Wait()
            local s = tween(slot, Motion.Base, { Size = UDim2.new(1, 0, 0, 0) })
            s.Completed:Wait()
            slot:Destroy()
        end)
    end

    -- Run a user callback; surface errors instead of swallowing them.
    local function run(fn, ...)
        if not fn then
            return
        end
        local args = table.pack(...)
        task.spawn(function()
            local ok, err = pcall(fn, table.unpack(args, 1, args.n))
            if not ok then
                print("[UIFX] callback error: " .. tostring(err))
                win:Notify(tostring(err), "Bad", 5)
            end
        end)
    end

    -- ── tabs ──
    local function selectTab(tab)
        for _, t in ipairs(win.Tabs) do
            local on = t == tab
            t.Page.Visible = on
            if topNav then
                tween(t.TabButton, Motion.Fast, { TextColor3 = on and Theme.Text or Theme.SubText })
            else
                tween(t.TabButton, Motion.Fast, {
                    BackgroundTransparency = on and 0 or 1,
                    TextColor3 = on and Theme.Text or Theme.SubText,
                })
            end
        end
        indicator.Visible = true
        if topNav then
            -- slide the pill under the chosen tab (absolute sizes are scaled by UIScale)
            local s = scale.Scale
            local x = (tab.TabButton.AbsolutePosition.X - tabList.AbsolutePosition.X) / s + 4
            local w = tab.TabButton.AbsoluteSize.X / s
            tween(indicator, Motion.Spring, {
                Position = UDim2.fromOffset(x, 4),
                Size = UDim2.fromOffset(w, 28),
            })
        else
            local y = tab.TabButton.AbsolutePosition.Y - root.AbsolutePosition.Y
            tween(indicator, Motion.Spring, {
                Position = UDim2.fromOffset(10, y / scale.Scale + 7),
            })
        end
        tab.Page.Position = UDim2.fromOffset(0, 8)
        tween(tab.Page, Motion.Base, { Position = UDim2.fromOffset(0, 0) })
    end

    function win:Tab(name)
        local tab = {}
        if topNav then
            tab.TabButton = new("TextButton", {
                AutoButtonColor = false,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 0, 1, 0),
                AutomaticSize = Enum.AutomaticSize.X,
                Text = name,
                TextSize = 13,
                TextColor3 = Theme.SubText,
                Font = Theme.FontBold,
                LayoutOrder = #win.Tabs + 1,
                ZIndex = 3,
                Parent = sidebar,
            })
            new("UIPadding", { PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16), Parent = tab.TabButton })
        else
            tab.TabButton = new("TextButton", {
                AutoButtonColor = false,
                BackgroundColor3 = Theme.Elevated,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 32),
                Text = "      " .. name,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextSize = 13,
                TextColor3 = Theme.SubText,
                Font = Theme.Font,
                LayoutOrder = #win.Tabs + 1,
                Parent = sidebar,
            }, { corner(6) })
        end
        tab.Page = new("ScrollingFrame", {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Stroke,
            Visible = false,
            Parent = pages,
        }, { padding(10) })
        new("UIListLayout", {
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = tab.Page,
        })
        table.insert(win.Tabs, tab)
        local order = 0

        track(tab.TabButton.MouseButton1Click:Connect(function()
            selectTab(tab)
        end))

        local function row(height)
            order = order + 1
            return new("Frame", {
                BackgroundColor3 = Theme.Panel,
                Size = UDim2.new(1, 0, 0, height or 38),
                LayoutOrder = order,
                Parent = tab.Page,
            }, { corner(), stroke(Theme.Stroke, 0.3) })
        end

        local function hover(target)
            track(target.MouseEnter:Connect(function()
                tween(target, Motion.Fast, { BackgroundColor3 = Theme.Elevated })
            end))
            track(target.MouseLeave:Connect(function()
                tween(target, Motion.Fast, { BackgroundColor3 = Theme.Panel })
            end))
        end

        -- small helpers shared by the richer elements
        local function mix(a, b, t)
            return a:Lerp(b, t)
        end
        local function pill(parent, text, color)
            local p = new("Frame", {
                BackgroundColor3 = mix(Theme.Panel, color, 0.18),
                Size = UDim2.fromOffset(0, 20),
                AutomaticSize = Enum.AutomaticSize.X,
                Parent = parent,
            }, { corner(9999), stroke(color, 0.55) })
            new("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 9), Parent = p })
            new("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0, 6),
                Parent = p,
            })
            local dot = new("Frame", { BackgroundColor3 = color, Size = UDim2.fromOffset(6, 6), Parent = p }, { corner(9999) })
            local t = label(text, 11, color, Theme.FontBold)
            t.Size = UDim2.fromOffset(0, 20)
            t.AutomaticSize = Enum.AutomaticSize.X
            t.Parent = p
            return p, t, dot
        end

        -- color (optional): a small coloured bar + tinted title, used for categories
        function tab:Section(text, color)
            order = order + 1
            local l = label(string.upper(text), 11, color or Theme.SubText, Theme.FontBold)
            l.Size = UDim2.new(1, 0, 0, 22)
            l.LayoutOrder = order
            l.Parent = tab.Page
            if color then
                new("UIPadding", { PaddingLeft = UDim.new(0, 10), Parent = l })
                new("Frame", {
                    BackgroundColor3 = color,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, -10, 0.5, -6),
                    Size = UDim2.fromOffset(3, 12),
                    Parent = l,
                }, { corner(2) })
            end
            return l
        end

        -- Key picker: click, then press any key (Esc cancels). callback(KeyCode)
        function tab:Keybind(text, default, callback, desc)
            local r = row(desc and 52 or 38)
            local l = label(text, 13)
            l.Position = UDim2.fromOffset(12, desc and 8 or 0)
            l.Size = UDim2.new(1, -150, 0, desc and 18 or 38)
            l.Parent = r
            if desc then
                local d = label(desc, 11, Theme.SubText)
                d.Position = UDim2.fromOffset(12, 27)
                d.Size = UDim2.new(1, -150, 0, 16)
                d.TextTruncate = Enum.TextTruncate.AtEnd
                d.Parent = r
            end
            local b = new("TextButton", {
                AutoButtonColor = false,
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -12, 0.5, 0),
                Size = UDim2.fromOffset(0, 28),
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundColor3 = Theme.Elevated,
                Text = "",
                Parent = r,
            }, { corner(8), stroke(Theme.Accent, 0.4) })
            new("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), Parent = b })
            local kl = label("", 12, Theme.Text, Theme.FontBold)
            kl.Size = UDim2.fromOffset(0, 28)
            kl.AutomaticSize = Enum.AutomaticSize.X
            kl.Parent = b
            local obj = { Value = default }
            local function show()
                kl.Text = obj.Value and obj.Value.Name or "None"
            end
            show()
            local waiting = false
            track(b.MouseButton1Click:Connect(function()
                if waiting then
                    return
                end
                waiting = true
                win.Capturing = true
                kl.Text = "press a key…"
                tween(b, Motion.Fast, { BackgroundColor3 = mix(Theme.Elevated, Theme.Accent, 0.35) })
                local conn
                conn = UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType ~= Enum.UserInputType.Keyboard then
                        return
                    end
                    conn:Disconnect()
                    if input.KeyCode ~= Enum.KeyCode.Escape then
                        obj.Value = input.KeyCode
                        run(callback, input.KeyCode)
                    end
                    show()
                    tween(b, Motion.Fast, { BackgroundColor3 = Theme.Elevated })
                    task.delay(0.2, function()
                        waiting = false
                        win.Capturing = false
                    end)
                end)
                track(conn)
            end))
            return obj
        end

        -- A toggle dressed as a warning: red card, "!" badge, RISK pill, pulsing ring when on.
        -- opts (optional): { Color = Color3, Glyph = "!", Note = true } - Note adds a third line
        -- that :SetNote(text, kind) fills; :SetLocked(bool, why) blocks turning it on.
        function tab:DangerToggle(text, default, callback, desc, pillText, opts)
            opts = opts or {}
            local tone = opts.Color or Theme.Bad
            order = order + 1
            local r = new("Frame", {
                BackgroundColor3 = mix(Theme.Panel, tone, 0.07),
                Size = UDim2.new(1, 0, 0, opts.Note and 80 or 64),
                LayoutOrder = order,
                Parent = tab.Page,
            }, { corner(10) })
            local ring = new("UIStroke", {
                Color = tone,
                Transparency = 0.55,
                Thickness = 1,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                Parent = r,
            })
            new("UIGradient", {
                Rotation = 0,
                Color = ColorSequence.new(mix(Color3.new(1, 1, 1), tone, 0.12), Color3.new(1, 1, 1)),
                Parent = r,
            })
            local badge = new("Frame", {
                BackgroundColor3 = tone,
                Position = UDim2.fromOffset(12, 14),
                Size = UDim2.fromOffset(36, 36),
                Parent = r,
            }, { corner(10) })
            local bang = label(opts.Glyph or "!", 20, Theme.Text, Theme.FontBold)
            bang.TextXAlignment = Enum.TextXAlignment.Center
            bang.Parent = badge
            local titleRow = new("Frame", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(60, 12),
                Size = UDim2.new(1, -130, 0, 20),
                Parent = r,
            })
            new("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = titleRow,
            })
            local t = label(text, 14, Theme.Text, Theme.FontBold)
            t.Size = UDim2.fromOffset(0, 20)
            t.AutomaticSize = Enum.AutomaticSize.X
            t.LayoutOrder = 1
            t.Parent = titleRow
            local riskPill = pill(titleRow, pillText or "RISKY", tone)
            riskPill.LayoutOrder = 2
            local d = label(desc or "", 11, mix(Theme.SubText, tone, 0.35))
            d.Position = UDim2.fromOffset(60, 34)
            d.Size = UDim2.new(1, -130, 0, 16)
            d.TextTruncate = Enum.TextTruncate.AtEnd
            d.Parent = r
            local note
            if opts.Note then
                note = label("", 11, Theme.SubText, Theme.FontBold)
                note.Position = UDim2.fromOffset(60, 54)
                note.Size = UDim2.new(1, -130, 0, 16)
                note.TextTruncate = Enum.TextTruncate.AtEnd
                note.Parent = r
            end
            local track_ = new("Frame", {
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -14, 0.5, 0),
                Size = UDim2.fromOffset(40, 22),
                BackgroundColor3 = Theme.Elevated,
                Parent = r,
            }, { corner(9999), stroke(tone, 0.5) })
            local knob = new("Frame", {
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 3, 0.5, 0),
                Size = UDim2.fromOffset(16, 16),
                BackgroundColor3 = Theme.SubText,
                Parent = track_,
            }, { corner(9999) })
            local hit = new("TextButton", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = "", Parent = r })
            local obj = { Value = false, Locked = false }
            local pulse
            local lockWhy = nil
            local noteData = { text = "", kind = nil, dirty = false }
            local u = { dirty = false }
            u.apply = function()
                if note then
                    note.Text = noteData.text
                    note.TextColor3 = noteData.kind and Theme[noteData.kind] or Theme.SubText
                end
            end
            table.insert(updaters, u)
            function obj:SetNote(textValue, kind)
                noteData.text = tostring(textValue)
                noteData.kind = kind
                u.dirty = true
            end
            function obj:SetLocked(locked, why)
                obj.Locked = locked and true or false
                lockWhy = why
                tween(badge, Motion.Base, { BackgroundColor3 = obj.Locked and Theme.Elevated or tone })
                bang.Text = obj.Locked and "X" or (opts.Glyph or "!")
                tween(track_, Motion.Base, { BackgroundTransparency = obj.Locked and 0.5 or 0 })
                if obj.Locked and obj.Value then
                    obj:Set(false, true)
                end
            end
            function obj:Set(v, silent)
                if v and obj.Locked then
                    win:Notify(lockWhy or "Not available here", "Warn", 4)
                    return
                end
                obj.Value = v and true or false
                tween(knob, Motion.Spring, {
                    Position = obj.Value and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
                    BackgroundColor3 = obj.Value and Theme.Text or Theme.SubText,
                })
                tween(track_, Motion.Base, { BackgroundColor3 = obj.Value and tone or Theme.Elevated })
                tween(r, Motion.Base, { BackgroundColor3 = mix(Theme.Panel, tone, obj.Value and 0.16 or 0.07) })
                if pulse then
                    pulse:Cancel()
                    pulse = nil
                end
                ring.Transparency = obj.Value and 0.1 or 0.55
                ring.Thickness = obj.Value and 2 or 1
                if obj.Value then
                    pulse = tween(ring, TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Transparency = 0.65 })
                end
                if not silent then
                    run(callback, obj.Value)
                end
            end
            track(hit.MouseButton1Click:Connect(function()
                obj:Set(not obj.Value)
            end))
            obj:Set(default, true)
            return obj
        end

        function tab:Button(text, callback)
            order = order + 1
            local b = new("TextButton", {
                AutoButtonColor = false,
                ClipsDescendants = true,
                BackgroundColor3 = Theme.Panel,
                Size = UDim2.new(1, 0, 0, 38),
                Text = "",
                LayoutOrder = order,
                Parent = tab.Page,
            }, { corner(), stroke(Theme.Stroke, 0.3) })
            local l = label(text, 13)
            l.Position = UDim2.fromOffset(12, 0)
            l.Size = UDim2.new(1, -24, 1, 0)
            l.Parent = b
            hover(b)
            local busy = false
            local obj = {}
            track(b.MouseButton1Click:Connect(function()
                ripple(b)
                if busy then
                    return
                end
                run(callback)
            end))
            track(b.MouseButton1Down:Connect(function()
                tween(b, Motion.Fast, { BackgroundColor3 = Theme.Stroke })
            end))
            -- Lock while a long job runs: obj:SetBusy(true) ... obj:SetBusy(false)
            function obj:SetBusy(on)
                busy = on
                tween(l, Motion.Fast, { TextTransparency = on and 0.5 or 0 })
            end
            function obj:SetText(t)
                l.Text = t
            end
            return obj
        end

        -- desc (optional) adds a second, dimmer line under the title
        function tab:Toggle(text, default, callback, desc)
            local r = row(desc and 52 or 38)
            local l = label(text, 13)
            l.Position = UDim2.fromOffset(12, 0)
            l.Size = UDim2.new(1, -70, 1, 0)
            l.Parent = r
            if desc then
                l.Position = UDim2.fromOffset(12, 8)
                l.Size = UDim2.new(1, -70, 0, 18)
                local d = label(desc, 11, Theme.SubText)
                d.Position = UDim2.fromOffset(12, 27)
                d.Size = UDim2.new(1, -70, 0, 16)
                d.TextTruncate = Enum.TextTruncate.AtEnd
                d.Parent = r
            end
            local track_ = new("Frame", {
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -12, 0.5, 0),
                Size = UDim2.fromOffset(36, 20),
                BackgroundColor3 = Theme.Elevated,
                Parent = r,
            }, { corner(9999), stroke(Theme.Stroke) })
            local knob = new("Frame", {
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 3, 0.5, 0),
                Size = UDim2.fromOffset(14, 14),
                BackgroundColor3 = Theme.SubText,
                Parent = track_,
            }, { corner(9999) })
            local hit = new("TextButton", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = "",
                Parent = r,
            })
            hover(r)

            local obj = { Value = false }
            function obj:Set(v, silent)
                obj.Value = v and true or false
                tween(knob, Motion.Spring, {
                    Position = obj.Value and UDim2.new(1, -17, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
                    BackgroundColor3 = obj.Value and Theme.Text or Theme.SubText,
                })
                tween(track_, Motion.Base, {
                    BackgroundColor3 = obj.Value and Theme.Accent or Theme.Elevated,
                })
                if not silent then
                    run(callback, obj.Value)
                end
            end
            track(hit.MouseButton1Click:Connect(function()
                obj:Set(not obj.Value)
            end))
            obj:Set(default, true)
            if default then
                run(callback, true)
            end
            return obj
        end

        function tab:Slider(text, min, max, default, step, callback)
            step = step or 1
            local r = row(54)
            local l = label(text, 13)
            l.Position = UDim2.fromOffset(12, 6)
            l.Size = UDim2.new(1, -90, 0, 18)
            l.Parent = r
            local valueLabel = label("", 13, Theme.SubText)
            valueLabel.TextXAlignment = Enum.TextXAlignment.Right
            valueLabel.Position = UDim2.new(1, -82, 0, 6)
            valueLabel.Size = UDim2.fromOffset(70, 18)
            valueLabel.Parent = r
            local bar = new("Frame", {
                Position = UDim2.new(0, 12, 0, 34),
                Size = UDim2.new(1, -24, 0, 6),
                BackgroundColor3 = Theme.Elevated,
                Parent = r,
            }, { corner(9999) })
            local fill = new("Frame", {
                Size = UDim2.fromScale(0, 1),
                BackgroundColor3 = Theme.Accent,
                Parent = bar,
            }, { corner(9999) })
            local knob = new("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0, 0.5),
                Size = UDim2.fromOffset(12, 12),
                BackgroundColor3 = Theme.Text,
                Parent = bar,
            }, { corner(9999) })

            local obj = { Value = default or min }
            local function render(instant)
                local a = (obj.Value - min) / (max - min)
                local info = instant and TweenInfo.new(0) or Motion.Fast
                tween(fill, info, { Size = UDim2.fromScale(a, 1) })
                tween(knob, info, { Position = UDim2.fromScale(a, 0.5) })
                valueLabel.Text = tostring(obj.Value)
            end
            function obj:Set(v, silent)
                v = math.clamp(v, min, max)
                v = min + math.floor((v - min) / step + 0.5) * step
                if v == obj.Value and not silent then
                    return
                end
                obj.Value = v
                render(false)
                if not silent then
                    run(callback, v)
                end
            end

            local dragging = false
            local function fromPointer()
                local x = UserInputService:GetMouseLocation().X
                local a = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                obj:Set(min + (max - min) * a)
            end
            track(r.InputBegan:Connect(function(input)
                if isPointer(input) then
                    dragging = true
                    tween(knob, Motion.Fast, { Size = UDim2.fromOffset(16, 16) })
                    fromPointer()
                end
            end))
            track(UserInputService.InputEnded:Connect(function(input)
                if dragging and isPointer(input) then
                    dragging = false
                    tween(knob, Motion.Fast, { Size = UDim2.fromOffset(12, 12) })
                end
            end))
            track(UserInputService.InputChanged:Connect(function(input)
                if dragging and isMove(input) then
                    fromPointer()
                end
            end))
            render(true)
            return obj
        end

        function tab:Dropdown(text, options, default, callback)
            local r = row(38)
            r.ClipsDescendants = true
            local head = new("TextButton", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 38),
                Text = "",
                Parent = r,
            })
            local l = label(text, 13)
            l.Position = UDim2.fromOffset(12, 0)
            l.Size = UDim2.new(0.5, -12, 1, 0)
            l.Parent = head
            local current = label("", 13, Theme.SubText)
            current.TextXAlignment = Enum.TextXAlignment.Right
            current.Position = UDim2.new(0.5, 0, 0, 0)
            current.Size = UDim2.new(0.5, -32, 1, 0)
            current.Parent = head
            local arrow = label("▾", 13, Theme.SubText)
            arrow.TextXAlignment = Enum.TextXAlignment.Center
            arrow.AnchorPoint = Vector2.new(1, 0)
            arrow.Position = UDim2.new(1, -8, 0, 0)
            arrow.Size = UDim2.fromOffset(18, 38)
            arrow.Parent = head
            local list = new("Frame", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(6, 40),
                Size = UDim2.new(1, -12, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = r,
            })
            new("UIListLayout", { Padding = UDim.new(0, 2), Parent = list })

            local obj = { Value = default, Options = {} }
            local open = false
            local function setOpen(v)
                open = v
                local h = open and (44 + #obj.Options * 30) or 38
                tween(r, Motion.Base, { Size = UDim2.new(1, 0, 0, h) })
                tween(arrow, Motion.Base, { Rotation = open and 180 or 0 })
            end
            function obj:Set(v, silent)
                obj.Value = v
                current.Text = v and tostring(v) or "—"
                if not silent then
                    run(callback, v)
                end
            end
            function obj:Refresh(newOptions)
                obj.Options = newOptions
                list:ClearAllChildren()
                new("UIListLayout", { Padding = UDim.new(0, 2), Parent = list })
                for _, opt in ipairs(newOptions) do
                    local o = new("TextButton", {
                        AutoButtonColor = false,
                        BackgroundColor3 = Theme.Panel,
                        Size = UDim2.new(1, 0, 0, 28),
                        Text = "  " .. tostring(opt),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextSize = 13,
                        TextColor3 = Theme.Text,
                        Font = Theme.Font,
                        Parent = list,
                    }, { corner(6) })
                    o.MouseEnter:Connect(function()
                        tween(o, Motion.Fast, { BackgroundColor3 = Theme.Elevated })
                    end)
                    o.MouseLeave:Connect(function()
                        tween(o, Motion.Fast, { BackgroundColor3 = Theme.Panel })
                    end)
                    o.MouseButton1Click:Connect(function()
                        obj:Set(opt)
                        setOpen(false)
                    end)
                end
                if open then
                    setOpen(true)
                end
            end
            track(head.MouseButton1Click:Connect(function()
                setOpen(not open)
            end))
            obj:Refresh(options or {})
            obj:Set(default, true)
            return obj
        end

        -- Live status panel. :Set() is safe from any thread; the window's
        -- Heartbeat applies the text.
        function tab:Status(titleText)
            local r = row(58)
            r.AutomaticSize = Enum.AutomaticSize.Y
            local t = label(titleText, 12, Theme.SubText, Theme.FontBold)
            t.Position = UDim2.fromOffset(12, 8)
            t.Size = UDim2.new(1, -24, 0, 16)
            t.Parent = r
            local body = label("…", 13, Theme.Text)
            body.TextWrapped = true
            body.TextYAlignment = Enum.TextYAlignment.Top
            body.AutomaticSize = Enum.AutomaticSize.Y
            body.Position = UDim2.fromOffset(12, 28)
            body.Size = UDim2.new(1, -24, 0, 18)
            body.Parent = r
            new("UIPadding", { PaddingBottom = UDim.new(0, 10), Parent = r })
            local dot = new("Frame", {
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, -12, 0, 12),
                Size = UDim2.fromOffset(8, 8),
                BackgroundColor3 = Theme.SubText,
                Parent = r,
            }, { corner(9999) })

            local s = { body = body, text = "…", color = Theme.Text, dirty = false }
            table.insert(statuses, s)
            local obj = {}
            function obj:Set(text, kind)
                s.text = tostring(text)
                s.color = kind and Theme[kind] or Theme.Text
                s.dirty = true
            end
            -- Pulse the dot while work is running: obj:SetActive(true/false)
            local pulse
            function obj:SetActive(on)
                if pulse then
                    pulse:Cancel()
                    pulse = nil
                end
                dot.BackgroundTransparency = 0
                dot.BackgroundColor3 = on and Theme.Good or Theme.SubText
                if on then
                    pulse = tween(dot, TweenInfo.new(0.8, Enum.EasingStyle.Sine,
                        Enum.EasingDirection.InOut, -1, true), { BackgroundTransparency = 0.7 })
                end
            end
            return obj
        end

        -- Row of icon + value chips (currency counters). :Set(key, text) is safe
        -- from any thread; the window's Heartbeat applies it like Status.
        -- defs = { { Key = "credits", Icon = iconSpec, Label = "Credits" }, ... }
        function tab:Counters(defs)
            local r = row(44)
            new("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDim.new(0, 6),
                VerticalAlignment = Enum.VerticalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = r,
            })
            new("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), Parent = r })
            local chips = {}
            for i, d in ipairs(defs) do
                local chip = new("Frame", {
                    BackgroundColor3 = Theme.Elevated,
                    Size = UDim2.new(1 / #defs, -6, 0, 30),
                    LayoutOrder = i,
                    Parent = r,
                }, { corner(6) })
                local holder = new("Frame", {
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(0, 0.5),
                    Position = UDim2.new(0, 6, 0.5, 0),
                    Size = UDim2.fromOffset(20, 20),
                    Parent = chip,
                })
                UIFX.icon(d.Icon, holder)
                local v = label("0", 13, Theme.Text, Theme.FontBold)
                v.Position = UDim2.fromOffset(32, 0)
                v.Size = UDim2.new(1, -36, 1, 0)
                v.TextTruncate = Enum.TextTruncate.AtEnd
                v.Parent = chip
                local s = { body = v, text = "0", color = Theme.Text, dirty = false }
                table.insert(statuses, s)
                chips[d.Key] = s
            end
            local obj = {}
            function obj:Set(key, text, kind)
                local s = chips[key]
                if s then
                    s.text = tostring(text)
                    s.color = kind and Theme[kind] or Theme.Text
                    s.dirty = true
                end
            end
            return obj
        end

        -- Hero status card: state pill + headline + detail line + HP bar + KPI chips.
        -- :Set({ State = "Collecting", Kind = "Good", Headline = "...", Detail = "...",
        --        HP = 120, MaxHP = 150, Chips = { { "Hits", 3 }, ... } })   (any thread)
        function tab:StatusCard()
            local r = row(118)
            r.BackgroundColor3 = Theme.Panel
            new("UIGradient", {
                Rotation = 90,
                Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(205, 205, 215)),
                Parent = r,
            })
            local accentBar = new("Frame", {
                BackgroundColor3 = Theme.Accent,
                BorderSizePixel = 0,
                Position = UDim2.fromOffset(0, 12),
                Size = UDim2.new(0, 3, 1, -24),
                Parent = r,
            }, { corner(2) })
            local pillHolder = new("Frame", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(14, 10),
                Size = UDim2.new(1, -28, 0, 20),
                Parent = r,
            })
            local statePill, stateText, stateDot = pill(pillHolder, "STARTING", Theme.Accent)
            local headline = label("…", 15, Theme.Text, Theme.FontBold)
            headline.Position = UDim2.fromOffset(14, 36)
            headline.Size = UDim2.new(1, -28, 0, 20)
            headline.TextTruncate = Enum.TextTruncate.AtEnd
            headline.Parent = r
            local detail = label("", 12, Theme.SubText)
            detail.Position = UDim2.fromOffset(14, 56)
            detail.Size = UDim2.new(1, -28, 0, 16)
            detail.TextTruncate = Enum.TextTruncate.AtEnd
            detail.Parent = r
            -- HP bar
            local hpLabel = label("HP", 11, Theme.SubText, Theme.FontBold)
            hpLabel.Position = UDim2.fromOffset(14, 78)
            hpLabel.Size = UDim2.fromOffset(120, 14)
            hpLabel.Parent = r
            local hpBar = new("Frame", {
                BackgroundColor3 = Theme.Elevated,
                Position = UDim2.new(0, 14, 0, 96),
                Size = UDim2.new(1, -28, 0, 6),
                Parent = r,
            }, { corner(9999) })
            local hpFill = new("Frame", {
                BackgroundColor3 = Theme.Good,
                Size = UDim2.fromScale(1, 1),
                Parent = hpBar,
            }, { corner(9999) })
            -- KPI chips, right side of the bottom area
            -- top-right, level with the state pill, so it can never run over the HP bar
            local chipRow = new("Frame", {
                BackgroundTransparency = 1,
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, -12, 0, 8),
                Size = UDim2.new(0.6, -12, 0, 24),
                Parent = r,
            })
            new("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0, 6),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = chipRow,
            })
            local chips = {}
            local function chip(i)
                if chips[i] then
                    return chips[i]
                end
                local c = new("Frame", {
                    BackgroundColor3 = Theme.Elevated,
                    Size = UDim2.fromOffset(0, 24),
                    AutomaticSize = Enum.AutomaticSize.X,
                    LayoutOrder = i,
                    Parent = chipRow,
                }, { corner(6) })
                new("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), Parent = c })
                new("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    Padding = UDim.new(0, 5),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = c,
                })
                local k = label("", 11, Theme.SubText)
                k.Size = UDim2.fromOffset(0, 24)
                k.AutomaticSize = Enum.AutomaticSize.X
                k.LayoutOrder = 1
                k.Parent = c
                local v = label("", 12, Theme.Text, Theme.FontBold)
                v.Size = UDim2.fromOffset(0, 24)
                v.AutomaticSize = Enum.AutomaticSize.X
                v.LayoutOrder = 2
                v.Parent = c
                chips[i] = { Frame = c, Key = k, Value = v }
                return chips[i]
            end

            local data = {}
            local u = { dirty = false }
            local lastKind = nil
            u.apply = function()
                local color = Theme[data.Kind or "Accent"] or Theme.Accent
                stateText.Text = string.upper(data.State or "")
                if lastKind ~= data.Kind then
                    lastKind = data.Kind
                    tween(statePill, Motion.Base, { BackgroundColor3 = mix(Theme.Panel, color, 0.18) })
                    tween(stateText, Motion.Base, { TextColor3 = color })
                    tween(stateDot, Motion.Base, { BackgroundColor3 = color })
                    tween(accentBar, Motion.Base, { BackgroundColor3 = color })
                    local st = statePill:FindFirstChildOfClass("UIStroke")
                    if st then
                        tween(st, Motion.Base, { Color = color })
                    end
                end
                headline.Text = data.Headline or ""
                detail.Text = data.Detail or ""
                local hp, maxHp = data.HP or 0, math.max(data.MaxHP or 1, 1)
                local a = math.clamp(hp / maxHp, 0, 1)
                hpLabel.Text = string.format("HP  %d / %d", math.floor(hp), math.floor(maxHp))
                tween(hpFill, Motion.Base, {
                    Size = UDim2.fromScale(a, 1),
                    BackgroundColor3 = a > 0.6 and Theme.Good or (a > 0.3 and Theme.Warn or Theme.Bad),
                })
                for i, c in ipairs(data.Chips or {}) do
                    local ch = chip(i)
                    ch.Frame.Visible = true
                    ch.Key.Text = tostring(c[1])
                    ch.Value.Text = tostring(c[2])
                end
                for i = #(data.Chips or {}) + 1, #chips do
                    chips[i].Frame.Visible = false
                end
            end
            table.insert(updaters, u)
            local obj = {}
            function obj:Set(t)
                data = t
                u.dirty = true
            end
            return obj
        end

        -- Win streak banner: big number, best / total line, last results as pips.
        -- :Set({ Streak = 34, Best = 34, Wins = 57, Recent = { true, false, ... } (newest first) })
        function tab:StreakCard(pips)
            pips = pips or 10
            local r = row(76)
            local glow = new("Frame", {
                BackgroundColor3 = Theme.Gold,
                BackgroundTransparency = 0.88,
                Position = UDim2.fromOffset(10, 10),
                Size = UDim2.fromOffset(56, 56),
                Parent = r,
            }, { corner(12) })
            new("UIStroke", { Color = Theme.Gold, Transparency = 0.5, Thickness = 1, Parent = glow })
            local num = label("0", 22, Theme.Gold, Theme.FontBold)
            num.TextXAlignment = Enum.TextXAlignment.Center
            num.Parent = glow
            local cap = label("WIN STREAK", 10, Theme.SubText, Theme.FontBold)
            cap.Position = UDim2.fromOffset(78, 12)
            cap.Size = UDim2.new(1, -90, 0, 14)
            cap.Parent = r
            local line = new("Frame", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(78, 26),
                Size = UDim2.new(1, -90, 0, 20),
                Parent = r,
            })
            new("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = line,
            })
            local title = label("", 14, Theme.Text, Theme.FontBold)
            title.Size = UDim2.fromOffset(0, 20)
            title.AutomaticSize = Enum.AutomaticSize.X
            title.LayoutOrder = 1
            title.Parent = line
            local bestPill = pill(line, "NEW BEST", Theme.Gold)
            bestPill.LayoutOrder = 3
            bestPill.Visible = false
            local bonusPill, bonusText = pill(line, "", Theme.Good)
            bonusPill.LayoutOrder = 2
            bonusPill.Visible = false
            local sub = label("", 11, Theme.SubText)
            sub.Position = UDim2.fromOffset(78, 48)
            sub.Size = UDim2.new(1, -90 - pips * 14, 0, 16)
            sub.TextTruncate = Enum.TextTruncate.AtEnd
            sub.Parent = r
            local pipRow = new("Frame", {
                BackgroundTransparency = 1,
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, -12, 0, 50),
                Size = UDim2.fromOffset(pips * 14, 12),
                Parent = r,
            })
            new("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                Padding = UDim.new(0, 4),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = pipRow,
            })
            local pipFrames = {}
            for i = 1, pips do
                -- oldest on the left, newest on the right
                pipFrames[i] = new("Frame", {
                    BackgroundColor3 = Theme.Elevated,
                    Size = UDim2.fromOffset(10, 10),
                    LayoutOrder = i,
                    Parent = pipRow,
                }, { corner(3) })
            end
            local data = {}
            local u = { dirty = false }
            local lastStreak = nil
            u.apply = function()
                local n = data.Streak or 0
                num.Text = tostring(n)
                title.Text = n == 1 and "1 win in a row" or (tostring(n) .. " wins in a row")
                bestPill.Visible = n > 0 and n >= (data.Best or 0)
                sub.Text = data.Sub or string.format("Best %d · %d wins total", data.Best or 0, data.Wins or 0)
                bonusPill.Visible = (data.Bonus or 0) > 0
                bonusText.Text = data.BonusText or ("+" .. tostring(data.Bonus or 0) .. " BONUS")
                if lastStreak and n > lastStreak then
                    num.TextSize = 28
                    tween(num, Motion.Spring, { TextSize = 22 })
                end
                lastStreak = n
                local recent = data.Recent or {}
                for i = 1, pips do
                    local res = recent[pips - i + 1]
                    local color = Theme.Elevated
                    if res == "live" then
                        color = Theme.Accent
                    elseif res == true then
                        color = Theme.Good
                    elseif res == false then
                        color = Theme.Bad
                    end
                    pipFrames[i].BackgroundColor3 = color
                end
            end
            table.insert(updaters, u)
            local obj = {}
            function obj:Set(t)
                data = t
                u.dirty = true
            end
            return obj
        end

        -- Tiles: icon, caption, big value and a green "+delta" chip.
        -- defs = { { Key =, Label =, Icon = iconSpec }, ... } ; :Set(key, value, delta)
        function tab:StatTiles(defs, columns)
            columns = columns or #defs
            order = order + 1
            local holder = new("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 64),
                LayoutOrder = order,
                Parent = tab.Page,
            })
            new("UIGridLayout", {
                CellSize = UDim2.new(1 / columns, -math.ceil(6 * (columns - 1) / columns), 0, 64),
                CellPadding = UDim2.fromOffset(6, 6),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = holder,
            })
            local tiles = {}
            for i, d in ipairs(defs) do
                local t = new("Frame", {
                    BackgroundColor3 = Theme.Panel,
                    LayoutOrder = i,
                    Parent = holder,
                }, { corner(), stroke(Theme.Stroke, 0.3) })
                local ic = new("Frame", {
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(10, 10),
                    Size = UDim2.fromOffset(18, 18),
                    Parent = t,
                })
                UIFX.icon(d.Icon, ic)
                local cap = label(string.upper(d.Label or d.Key), 10, Theme.SubText, Theme.FontBold)
                cap.Position = UDim2.fromOffset(34, 10)
                cap.Size = UDim2.new(1, -40, 0, 18)
                cap.TextTruncate = Enum.TextTruncate.AtEnd
                cap.Parent = t
                local val = label("0", 18, Theme.Text, Theme.FontBold)
                val.Position = UDim2.fromOffset(10, 32)
                val.Size = UDim2.new(1, -20, 0, 24)
                val.TextTruncate = Enum.TextTruncate.AtEnd
                val.Parent = t
                local delta = label("", 11, Theme.Good, Theme.FontBold)
                delta.TextXAlignment = Enum.TextXAlignment.Right
                delta.AnchorPoint = Vector2.new(1, 0)
                delta.Position = UDim2.new(1, -10, 0, 36)
                delta.Size = UDim2.fromOffset(60, 18)
                delta.Parent = t
                tiles[d.Key] = { Value = val, Delta = delta, v = "0", d = "" }
            end
            local u = { dirty = false }
            u.apply = function()
                for _, tl in pairs(tiles) do
                    tl.Value.Text = tl.v
                    tl.Delta.Text = tl.d
                end
            end
            table.insert(updaters, u)
            local obj = {}
            function obj:Set(key, value, delta)
                local tl = tiles[key]
                if tl then
                    tl.v = tostring(value)
                    tl.d = (delta and delta ~= 0) and ((delta > 0 and "+" or "") .. tostring(delta)) or ""
                    u.dirty = true
                end
            end
            return obj
        end

        -- Results table: one row per round, newest first, plus a pinned TOTAL row.
        -- cols = { { Key =, Icon = iconSpec }, ... }  (value columns after "Round" and "Result")
        -- :SetRows({ { Round = "#12", Result = "Survived", Kind = "Good", Values = { credits = 120, ... } }, ... })
        -- :SetTotal({ Round = "Total", Result = "8 rounds", Values = { ... } })
        function tab:RoundLog(cols, maxRows)
            maxRows = maxRows or 8
            local r = row(40)
            r.AutomaticSize = Enum.AutomaticSize.Y
            new("UIPadding", { PaddingBottom = UDim.new(0, 8), Parent = r })
            local list = new("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = r,
            })
            new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = list })
            local ROUND_W, RESULT_W = 52, 118
            local function cells(parent, height)
                local f = new("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, height),
                    Parent = parent,
                })
                new("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), Parent = f })
                local round = label("", 12, Theme.SubText, Theme.FontBold)
                round.Size = UDim2.new(0, ROUND_W, 1, 0)
                round.Parent = f
                local result = new("Frame", {
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(ROUND_W, 0),
                    Size = UDim2.new(0, RESULT_W, 1, 0),
                    Parent = f,
                })
                local vals = {}
                local n = #cols
                for i, c in ipairs(cols) do
                    local cell = label("", 12, Theme.Text, Theme.Font)
                    cell.TextXAlignment = Enum.TextXAlignment.Right
                    cell.Position = UDim2.new((i - 1) / n, ROUND_W + RESULT_W - (i - 1) / n * (ROUND_W + RESULT_W), 0, 0)
                    cell.Size = UDim2.new(1 / n, -(ROUND_W + RESULT_W) / n, 1, 0)
                    cell.Parent = f
                    vals[c.Key] = cell
                end
                return f, round, result, vals
            end
            -- header with icons
            local head, headRound = cells(list, 30)
            head.LayoutOrder = 0
            headRound.Text = "ROUND"
            headRound.TextSize = 10
            local headRes = label("RESULT", 10, Theme.SubText, Theme.FontBold)
            headRes.Position = UDim2.fromOffset(ROUND_W, 0)
            headRes.Size = UDim2.new(0, RESULT_W, 1, 0)
            headRes.Parent = head
            for i, c in ipairs(cols) do
                local n = #cols
                local ic = new("Frame", {
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(i / n, ROUND_W + RESULT_W - i / n * (ROUND_W + RESULT_W), 0.5, 0),
                    Size = UDim2.fromOffset(16, 16),
                    Parent = head,
                })
                UIFX.icon(c.Icon, ic)
            end
            new("Frame", {
                BackgroundColor3 = Theme.Stroke,
                BorderSizePixel = 0,
                Size = UDim2.new(1, -24, 0, 1),
                Position = UDim2.fromOffset(12, 0),
                LayoutOrder = 1,
                Parent = list,
            })
            local rowsHolder = new("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = 2,
                Parent = list,
            })
            new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = rowsHolder })
            local empty = label("No finished rounds yet", 12, Theme.SubText)
            empty.TextXAlignment = Enum.TextXAlignment.Center
            empty.Size = UDim2.new(1, 0, 0, 30)
            empty.Parent = rowsHolder
            -- total footer
            local totalWrap = new("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = 3,
                Parent = list,
            })
            new("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 6), Parent = totalWrap })
            local totalBox = new("Frame", {
                BackgroundColor3 = Theme.Elevated,
                Size = UDim2.new(1, 0, 0, 34),
                Parent = totalWrap,
            }, { corner(6), stroke(Theme.Good, 0.6) })
            local tf, tRound, tResult, tVals = cells(totalBox, 34)
            tf.UIPadding.PaddingLeft = UDim.new(0, 4)
            tf.UIPadding.PaddingRight = UDim.new(0, 4)
            tRound.TextColor3 = Theme.Text
            local tResLabel = label("", 11, Theme.SubText, Theme.FontBold)
            tResLabel.Parent = tResult
            for _, v in pairs(tVals) do
                v.Font = Theme.FontBold
            end

            local rowPool = {}
            local rowsData, totalData = {}, nil
            local u = { dirty = false }
            u.apply = function()
                empty.Visible = #rowsData == 0
                for i = 1, math.max(#rowsData, #rowPool) do
                    local d = rowsData[i]
                    local rp = rowPool[i]
                    if d and not rp then
                        local f, rr, res, vals = cells(rowsHolder, 28)
                        f.LayoutOrder = i
                        local strip = new("Frame", {
                            BackgroundColor3 = Theme.Hardcore,
                            BorderSizePixel = 0,
                            Position = UDim2.new(0, -8, 0.5, -8),
                            Size = UDim2.fromOffset(3, 16),
                            Visible = false,
                            Parent = f,
                        }, { corner(2) })
                        local p, pt, pd = pill(res, "", Theme.SubText)
                        p.AnchorPoint = Vector2.new(0, 0.5)
                        p.Position = UDim2.fromScale(0, 0.5)
                        rp = { Frame = f, Round = rr, Pill = p, PillText = pt, PillDot = pd, Vals = vals, Strip = strip }
                        rowPool[i] = rp
                    end
                    if rp then
                        rp.Frame.Visible = d ~= nil
                        if d then
                            local color = Theme[d.Kind or "SubText"] or Theme.SubText
                            rp.Round.Text = d.Round or ""
                            rp.Strip.Visible = d.Hardcore and true or false
                            rp.Round.TextColor3 = d.Hardcore and Theme.Hardcore or Theme.SubText
                            rp.PillText.Text = string.upper(d.Result or "")
                            rp.PillText.TextColor3 = color
                            rp.PillDot.BackgroundColor3 = color
                            rp.Pill.BackgroundColor3 = mix(Theme.Panel, color, 0.18)
                            local st = rp.Pill:FindFirstChildOfClass("UIStroke")
                            if st then
                                st.Color = color
                            end
                            for _, c in ipairs(cols) do
                                local v = d.Values and d.Values[c.Key] or 0
                                rp.Vals[c.Key].Text = v > 0 and ("+" .. tostring(v)) or tostring(v)
                                rp.Vals[c.Key].TextColor3 = v > 0 and Theme.Text or Theme.SubText
                            end
                        end
                    end
                end
                if totalData then
                    tRound.Text = totalData.Round or "TOTAL"
                    tResLabel.Text = totalData.Result or ""
                    for _, c in ipairs(cols) do
                        local v = totalData.Values and totalData.Values[c.Key] or 0
                        tVals[c.Key].Text = tostring(v)
                        tVals[c.Key].TextColor3 = v > 0 and Theme.Good or Theme.SubText
                    end
                end
            end
            table.insert(updaters, u)
            local obj = {}
            function obj:SetRows(list_)
                rowsData = {}
                for i = 1, math.min(#list_, maxRows) do
                    rowsData[i] = list_[i]
                end
                u.dirty = true
            end
            function obj:SetTotal(t)
                totalData = t
                u.dirty = true
            end
            return obj
        end

        -- Level progress used by skill cards: 0..1 and a caption
        -- levels = { 100, 300 } style thresholds; lvl = 1-based level
        local function levelProgress(xp, thresholds)
            local lo = 0
            for i, th in ipairs(thresholds) do
                if xp < th then
                    return (xp - lo) / (th - lo), i, string.format("%d / %d XP", xp, th)
                end
                lo = th
            end
            return 1, #thresholds + 1, "MAX"
        end

        -- Hero row for the equipped skill: big icon, name, level pill, XP bar, note line.
        -- :Set({ Icon = iconSpec, Name =, Xp =, Thresholds = {100, 300}, Note = "", Kind = "Accent" })
        function tab:SkillHero()
            local r = row(92)
            local plate = new("Frame", {
                BackgroundColor3 = Theme.Elevated,
                Position = UDim2.fromOffset(12, 12),
                Size = UDim2.fromOffset(68, 68),
                Parent = r,
            }, { corner(12), stroke(Theme.Stroke, 0.2) })
            local holder = new("Frame", {
                BackgroundTransparency = 1,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromOffset(56, 56),
                Parent = plate,
            })
            local cap = label("EQUIPPED SKILL", 10, Theme.SubText, Theme.FontBold)
            cap.Position = UDim2.fromOffset(92, 12)
            cap.Size = UDim2.new(1, -104, 0, 14)
            cap.Parent = r
            local nameRow = new("Frame", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(92, 28),
                Size = UDim2.new(1, -104, 0, 22),
                Parent = r,
            })
            new("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = nameRow,
            })
            local name = label("—", 16, Theme.Text, Theme.FontBold)
            name.Size = UDim2.fromOffset(0, 22)
            name.AutomaticSize = Enum.AutomaticSize.X
            name.LayoutOrder = 1
            name.Parent = nameRow
            local lvlPill, lvlText, lvlDot = pill(nameRow, "LVL 1", Theme.Accent)
            lvlPill.LayoutOrder = 2
            local bar = new("Frame", {
                BackgroundColor3 = Theme.Elevated,
                Position = UDim2.fromOffset(92, 58),
                Size = UDim2.new(1, -200, 0, 8),
                Parent = r,
            }, { corner(9999) })
            local fill = new("Frame", {
                BackgroundColor3 = Theme.Accent,
                Size = UDim2.fromScale(0, 1),
                Parent = bar,
            }, { corner(9999) })
            local xpText = label("", 11, Theme.SubText, Theme.FontBold)
            xpText.TextXAlignment = Enum.TextXAlignment.Right
            xpText.AnchorPoint = Vector2.new(1, 0)
            xpText.Position = UDim2.new(1, -12, 0, 54)
            xpText.Size = UDim2.fromOffset(96, 16)
            xpText.Parent = r
            local note = label("", 11, Theme.SubText)
            note.Position = UDim2.fromOffset(92, 70)
            note.Size = UDim2.new(1, -104, 0, 16)
            note.TextTruncate = Enum.TextTruncate.AtEnd
            note.Parent = r

            local data, lastIcon = {}, nil
            local u = { dirty = false }
            u.apply = function()
                if data.Icon ~= lastIcon then
                    lastIcon = data.Icon
                    UIFX.icon(data.Icon, holder)
                end
                name.Text = data.Name or "—"
                local a, lvl, cap_ = levelProgress(data.Xp or 0, data.Thresholds or { 100, 300 })
                local color = lvl > #(data.Thresholds or { 100, 300 }) and Theme.Good or Theme.Accent
                lvlText.Text = cap_ == "MAX" and "LVL MAX" or ("LVL " .. lvl)
                lvlText.TextColor3 = color
                lvlDot.BackgroundColor3 = color
                lvlPill.BackgroundColor3 = mix(Theme.Panel, color, 0.18)
                tween(fill, Motion.Base, { Size = UDim2.fromScale(math.clamp(a, 0, 1), 1), BackgroundColor3 = color })
                xpText.Text = cap_
                note.Text = data.Note or ""
            end
            table.insert(updaters, u)
            local obj = {}
            function obj:Set(t)
                data = t
                u.dirty = true
            end
            return obj
        end

        -- Owned skills as cards: icon, name, level pill, XP bar.
        -- Equipped = accent ring, chosen "final" skill = green ring + ★ badge. Click picks the final skill.
        -- items = { { Key =, Name =, Icon = iconSpec } } ; :Update(key, { Xp =, Equipped =, Final =, Next = })
        function tab:SkillGrid(items, onPick, columns, thresholds)
            columns = columns or 4
            thresholds = thresholds or { 100, 300 }
            order = order + 1
            local grid = new("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = order,
                Parent = tab.Page,
            })
            new("UIPadding", {
                PaddingTop = UDim.new(0, 4),
                PaddingBottom = UDim.new(0, 8),
                PaddingLeft = UDim.new(0, 4),
                PaddingRight = UDim.new(0, 4),
                Parent = grid,
            })
            new("UIGridLayout", {
                CellSize = UDim2.new(1 / columns, -math.ceil(8 * (columns - 1) / columns), 0, 112),
                CellPadding = UDim2.fromOffset(8, 8),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = grid,
            })
            local cards, state = {}, {}
            for i, it in ipairs(items) do
                local card = new("TextButton", {
                    AutoButtonColor = false,
                    ClipsDescendants = true,
                    BackgroundColor3 = Theme.Panel,
                    Text = "",
                    LayoutOrder = i,
                    Parent = grid,
                }, { corner(10) })
                local sc = new("UIScale", { Scale = 1, Parent = card })
                local st = new("UIStroke", {
                    Color = Theme.Stroke,
                    Transparency = 0.25,
                    Thickness = 1,
                    LineJoinMode = Enum.LineJoinMode.Round,
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                    Parent = card,
                })
                local plate = new("Frame", {
                    BackgroundColor3 = it.Color and mix(Theme.Elevated, it.Color, 0.28) or Theme.Elevated,
                    AnchorPoint = Vector2.new(0.5, 0),
                    Position = UDim2.new(0.5, 0, 0, 10),
                    Size = UDim2.fromOffset(46, 46),
                    Parent = card,
                }, { corner(10) })
                if it.Color then
                    -- inset pill: a full-width bar would stick out past the rounded corners
                    new("Frame", {
                        BackgroundColor3 = it.Color,
                        BorderSizePixel = 0,
                        AnchorPoint = Vector2.new(0.5, 0),
                        Position = UDim2.new(0.5, 0, 0, 3),
                        Size = UDim2.new(1, -28, 0, 3),
                        Parent = card,
                    }, { corner(9999) })
                end
                local holder = new("Frame", {
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.fromScale(0.5, 0.5),
                    Size = UDim2.fromOffset(40, 40),
                    Parent = plate,
                })
                UIFX.icon(it.Icon, holder)
                local nl = label(it.Name, 11, Theme.Text, Theme.FontBold)
                nl.TextXAlignment = Enum.TextXAlignment.Center
                nl.TextTruncate = Enum.TextTruncate.AtEnd
                nl.Position = UDim2.fromOffset(6, 60)
                nl.Size = UDim2.new(1, -12, 0, 16)
                nl.Parent = card
                local lv = label("LVL 1", 10, Theme.SubText, Theme.FontBold)
                lv.TextXAlignment = Enum.TextXAlignment.Center
                lv.Position = UDim2.fromOffset(6, 76)
                lv.Size = UDim2.new(1, -12, 0, 14)
                lv.Parent = card
                local bar = new("Frame", {
                    BackgroundColor3 = Theme.Elevated,
                    Position = UDim2.new(0, 12, 0, 96),
                    Size = UDim2.new(1, -24, 0, 5),
                    Parent = card,
                }, { corner(9999) })
                local fill = new("Frame", {
                    BackgroundColor3 = Theme.Accent,
                    Size = UDim2.fromScale(0, 1),
                    Parent = bar,
                }, { corner(9999) })
                local tag = new("Frame", {
                    Position = UDim2.fromOffset(6, 6),
                    Size = UDim2.fromOffset(0, 16),
                    AutomaticSize = Enum.AutomaticSize.X,
                    BackgroundColor3 = Theme.Accent,
                    Visible = false,
                    Parent = card,
                }, { corner(9999) })
                new("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), Parent = tag })
                local tagText = label("", 9, Theme.Bg, Theme.FontBold)
                tagText.Size = UDim2.fromOffset(0, 16)
                tagText.AutomaticSize = Enum.AutomaticSize.X
                tagText.Parent = tag
                local star = new("Frame", {
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, -6, 0, 6),
                    Size = UDim2.fromOffset(0, 18),
                    AutomaticSize = Enum.AutomaticSize.X,
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    Visible = false,
                    Parent = card,
                }, { corner(9999) })
                new("UIGradient", {
                    Rotation = 90,
                    Color = ColorSequence.new(Color3.fromRGB(255, 222, 120), Color3.fromRGB(240, 150, 40)),
                    Parent = star,
                })
                new("UIStroke", {
                    Color = Color3.fromRGB(255, 236, 170),
                    Transparency = 0.35,
                    Thickness = 1,
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                    Parent = star,
                })
                new("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 7), Parent = star })
                local starText = label("★ FINAL", 9, Color3.fromRGB(70, 40, 0), Theme.FontBold)
                starText.Size = UDim2.fromOffset(0, 18)
                starText.AutomaticSize = Enum.AutomaticSize.X
                starText.Parent = star
                cards[it.Key] = { Button = card, Stroke = st, Level = lv, Fill = fill, Tag = tag, TagText = tagText, Star = star, StarText = starText }
                state[it.Key] = {}
                track(card.MouseEnter:Connect(function()
                    tween(sc, Motion.Fast, { Scale = 1.03 })
                end))
                track(card.MouseLeave:Connect(function()
                    tween(sc, Motion.Fast, { Scale = 1 })
                end))
                track(card.MouseButton1Click:Connect(function()
                    tween(sc, Motion.Spring, { Scale = 1.03 })
                    ripple(card)
                    run(onPick, it.Key)
                end))
            end
            local u = { dirty = false }
            u.apply = function()
                for key, c in pairs(cards) do
                    local s = state[key]
                    local a, lvl, cap_ = levelProgress(s.Xp or 0, thresholds)
                    local maxed = cap_ == "MAX"
                    c.Level.Text = maxed and "LVL MAX" or string.format("LVL %d · %s", lvl, cap_)
                    c.Level.TextColor3 = maxed and Theme.Good or Theme.SubText
                    tween(c.Fill, Motion.Base, { Size = UDim2.fromScale(math.clamp(a, 0, 1), 1), BackgroundColor3 = maxed and Theme.Good or Theme.Accent })
                    local ring = s.Final and Theme.Gold or (s.Equipped and Theme.Accent or Theme.Stroke)
                    tween(c.Stroke, Motion.Base, {
                        Color = ring,
                        Thickness = (s.Final or s.Equipped) and 2 or 1,
                        Transparency = (s.Final or s.Equipped) and 0 or 0.25,
                    })
                    tween(c.Button, Motion.Base, { BackgroundColor3 = s.Equipped and mix(Theme.Panel, Theme.Accent, 0.1) or Theme.Panel })
                    c.Star.Visible = s.Final and true or false
                    if s.Equipped then
                        c.Tag.Visible = true
                        c.Tag.BackgroundColor3 = Theme.Accent
                        c.TagText.Text = "EQUIPPED"
                    elseif s.Next then
                        c.Tag.Visible = true
                        c.Tag.BackgroundColor3 = Theme.Warn
                        c.TagText.Text = "NEXT"
                    else
                        c.Tag.Visible = false
                    end
                end
            end
            table.insert(updaters, u)
            local obj = {}
            function obj:Update(key, s)
                if state[key] then
                    state[key] = s
                    u.dirty = true
                end
            end
            return obj
        end

        -- Selectable icon cards in a grid, with a "n/m" counter and All / None pills.
        -- items = { { Key =, Name =, Icon = iconSpec, Selected = bool }, ... }
        -- callback(key, selected). Selected = green ring + soft green tint + check badge.
        -- Border notes: UIStroke draws OUTSIDE the card and hover scales the card by 3%,
        -- so the grid keeps a 4px inner padding; otherwise the ring is cut by the page edge.
        function tab:ItemGrid(titleText, items, callback, columns)
            columns = columns or 4
            order = order + 1
            local head = new("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 26),
                LayoutOrder = order,
                Parent = tab.Page,
            })
            -- title and "n/m" side by side (a list layout, so the counter never overlaps)
            local titleRow = new("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -110, 1, 0),
                Parent = head,
            })
            new("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = titleRow,
            })
            local hl = label(string.upper(titleText), 11, Theme.Text, Theme.FontBold)
            hl.Size = UDim2.new(0, 0, 1, 0)
            hl.AutomaticSize = Enum.AutomaticSize.X
            hl.LayoutOrder = 1
            hl.Parent = titleRow
            local countLabel = label("", 11, Theme.SubText, Theme.FontBold)
            countLabel.Size = UDim2.new(0, 0, 1, 0)
            countLabel.AutomaticSize = Enum.AutomaticSize.X
            countLabel.LayoutOrder = 2
            countLabel.Parent = titleRow
            local function headButton(text, x)
                local b = new("TextButton", {
                    AutoButtonColor = false,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, x, 0.5, 0),
                    Size = UDim2.fromOffset(46, 20),
                    BackgroundColor3 = Theme.Elevated,
                    Text = text,
                    TextSize = 10,
                    TextColor3 = Theme.SubText,
                    Font = Theme.FontBold,
                    Parent = head,
                }, { corner(9999), stroke(Theme.Stroke, 0.2) })
                track(b.MouseEnter:Connect(function()
                    tween(b, Motion.Fast, { BackgroundColor3 = Theme.Stroke, TextColor3 = Theme.Text })
                end))
                track(b.MouseLeave:Connect(function()
                    tween(b, Motion.Fast, { BackgroundColor3 = Theme.Elevated, TextColor3 = Theme.SubText })
                end))
                return b
            end
            local noneBtn = headButton("NONE", -2)
            local allBtn = headButton("ALL", -54)

            order = order + 1
            local grid = new("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = order,
                Parent = tab.Page,
            })
            new("UIPadding", {
                PaddingTop = UDim.new(0, 4),
                PaddingBottom = UDim.new(0, 8),
                PaddingLeft = UDim.new(0, 4),
                PaddingRight = UDim.new(0, 4),
                Parent = grid,
            })
            new("UIGridLayout", {
                CellSize = UDim2.new(1 / columns, -math.ceil(8 * (columns - 1) / columns), 0, 96),
                CellPadding = UDim2.fromOffset(8, 8),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = grid,
            })

            local obj = { Selected = {}, Cards = {} }
            local function refreshCount()
                local n = 0
                for _, it in ipairs(items) do
                    if obj.Selected[it.Key] then
                        n = n + 1
                    end
                end
                countLabel.Text = string.format("%d/%d", n, #items)
            end
            local function paint(c, on, instant)
                local info = instant and TweenInfo.new(0) or Motion.Base
                tween(c.Stroke, info, {
                    Color = on and Theme.Good or Theme.Stroke,
                    Transparency = on and 0 or 0.25,
                    Thickness = on and 2 or 1,
                })
                tween(c.Button, info, { BackgroundColor3 = on and mix(Theme.Panel, Theme.Good, 0.08) or Theme.Panel })
                tween(c.Plate, info, { BackgroundColor3 = on and mix(Theme.Elevated, Theme.Good, 0.16) or Theme.Elevated })
                tween(c.Badge, info, { BackgroundTransparency = on and 0 or 1 })
                tween(c.Check, info, { TextTransparency = on and 0 or 1 })
                tween(c.NameLabel, info, { TextColor3 = on and Theme.Text or Theme.SubText })
                tween(c.Dim, info, { BackgroundTransparency = on and 1 or 0.45 })
            end
            function obj:Set(key, on, silent)
                local c = obj.Cards[key]
                if not c then
                    return
                end
                on = on and true or false
                obj.Selected[key] = on
                paint(c, on, false)
                refreshCount()
                if not silent then
                    run(callback, key, on)
                end
            end
            function obj:SetName(key, text)
                local c = obj.Cards[key]
                if c then
                    c.NameLabel.Text = text
                end
            end
            -- how many were picked up this session; shown as a small "×n" tag
            function obj:SetCount(key, n)
                local c = obj.Cards[key]
                if c then
                    c.CountText.Text = n > 0 and ("×" .. tostring(n)) or ""
                    c.CountTag.Visible = n > 0
                end
            end
            function obj:IconHolder(key)
                local c = obj.Cards[key]
                return c and c.Holder
            end

            for i, it in ipairs(items) do
                local card = new("TextButton", {
                    AutoButtonColor = false,
                    ClipsDescendants = true,
                    BackgroundColor3 = Theme.Panel,
                    Text = "",
                    LayoutOrder = i,
                    Parent = grid,
                }, { corner(10) })
                local scale_ = new("UIScale", { Scale = 1, Parent = card })
                new("UIGradient", {
                    Rotation = 90,
                    Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(200, 200, 210)),
                    Parent = card,
                })
                local st = new("UIStroke", {
                    Color = Theme.Stroke,
                    Transparency = 0.25,
                    Thickness = 1,
                    LineJoinMode = Enum.LineJoinMode.Round,
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                    Parent = card,
                })
                -- round plate behind the icon
                local plate = new("Frame", {
                    BackgroundColor3 = Theme.Elevated,
                    AnchorPoint = Vector2.new(0.5, 0),
                    Position = UDim2.new(0.5, 0, 0, 10),
                    Size = UDim2.fromOffset(48, 48),
                    Parent = card,
                }, { corner(9999) })
                local holder = new("Frame", {
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.fromScale(0.5, 0.5),
                    Size = UDim2.fromOffset(34, 34),
                    Parent = plate,
                })
                UIFX.icon(it.Icon, holder)
                -- dims the icon when not selected (no nested CanvasGroup: one per window)
                local dim = new("Frame", {
                    BackgroundColor3 = Theme.Panel,
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 1),
                    ZIndex = 5,
                    Parent = plate,
                }, { corner(9999) })
                local nl = label(it.Name, 11, Theme.SubText, Theme.FontBold)
                nl.TextXAlignment = Enum.TextXAlignment.Center
                nl.TextYAlignment = Enum.TextYAlignment.Top
                nl.TextWrapped = true
                nl.Position = UDim2.new(0, 6, 0, 64)
                nl.Size = UDim2.new(1, -12, 0, 28)
                nl.Parent = card
                local badge = new("Frame", {
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, -6, 0, 6),
                    Size = UDim2.fromOffset(16, 16),
                    BackgroundColor3 = Theme.Good,
                    BackgroundTransparency = 1,
                    Parent = card,
                }, { corner(9999) })
                local check = label("✓", 11, Theme.Bg, Theme.FontBold)
                check.TextXAlignment = Enum.TextXAlignment.Center
                check.TextTransparency = 1
                check.Parent = badge
                local countTag = new("Frame", {
                    Position = UDim2.fromOffset(6, 6),
                    Size = UDim2.fromOffset(0, 16),
                    AutomaticSize = Enum.AutomaticSize.X,
                    BackgroundColor3 = Theme.Elevated,
                    Visible = false,
                    Parent = card,
                }, { corner(9999) })
                new("UIPadding", { PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5), Parent = countTag })
                local countText = label("", 10, Theme.Text, Theme.FontBold)
                countText.Size = UDim2.fromOffset(0, 16)
                countText.AutomaticSize = Enum.AutomaticSize.X
                countText.Parent = countTag
                local c = {
                    Button = card, Stroke = st, Plate = plate, Dim = dim, Badge = badge, Check = check,
                    NameLabel = nl, Holder = holder, CountTag = countTag, CountText = countText,
                }
                obj.Cards[it.Key] = c
                track(card.MouseEnter:Connect(function()
                    tween(scale_, Motion.Fast, { Scale = 1.03 })
                end))
                track(card.MouseLeave:Connect(function()
                    tween(scale_, Motion.Fast, { Scale = 1 })
                end))
                track(card.MouseButton1Down:Connect(function()
                    tween(scale_, Motion.Fast, { Scale = 0.97 })
                end))
                track(card.MouseButton1Click:Connect(function()
                    tween(scale_, Motion.Spring, { Scale = 1.03 })
                    ripple(card)
                    obj:Set(it.Key, not obj.Selected[it.Key])
                end))
                obj.Selected[it.Key] = it.Selected and true or false
                paint(c, obj.Selected[it.Key], true)
            end
            refreshCount()
            track(allBtn.MouseButton1Click:Connect(function()
                for _, it in ipairs(items) do
                    if not obj.Selected[it.Key] then
                        obj:Set(it.Key, true)
                    end
                end
            end))
            track(noneBtn.MouseButton1Click:Connect(function()
                for _, it in ipairs(items) do
                    if obj.Selected[it.Key] then
                        obj:Set(it.Key, false)
                    end
                end
            end))
            return obj
        end

        if #win.Tabs == 1 then
            task.defer(function()
                selectTab(tab)
            end)
        end
        return tab
    end

    task.defer(function()
        win:Show()
    end)
    return win
end

return UIFX

end)()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Bombs = workspace:WaitForChild("Bombs", 10)
local Explosions = workspace:WaitForChild("Explosions", 10)
if not Bombs or not Explosions then
	error("Aimia - Super Bomb Survival: workspace.Bombs/Explosions missing - wrong game? PlaceId " .. tostring(game.PlaceId))
end

-- one copy at a time (also stops the old no-UI dodge script)
if getgenv().SBSHubStop then
	pcall(getgenv().SBSHubStop)
end
if getgenv().SBSDodgeStop then
	pcall(getgenv().SBSDodgeStop)
end

local LOG = "SBSHub.log"
local CONFIG = "SBSHub.json"

local S = {
	running = true,
	conns = {},
	dodgeOn = true,
	collectOn = true,
	flyOn = true, -- free 3D glide + hover instead of staying on the floor
	bringOn = true, -- pull items we own the physics of onto us
	bombCtlOn = true, -- slow + push away bombs we own the physics of
	voidOn = false, -- drop owned bombs below FallenPartsDestroyHeight instead of pushing
	voided = 0,
	voidGone = 0,
	voidBlasts = 0,
	voidSeen = setmetatable({}, { __mode = "k" }),
	autoSkill = true, -- level every owned skill to 3, then use the final one
	autoClaim = true, -- claim finished hourly / daily / vip challenges
	hardcoreOn = nil, -- nil = follow the game's own setting until the toggle is used
	lastHcSet = 0,
	claimed = 0,
	lastClaim = {},
	finalSkill = nil,
	skillNote = "",
	lastSwap = 0,
	hold = nil,
	pushed = 0,
	slowed = 0,
	brought = 0,
	blasts = {},
	lastBlast = {},
	slowSeen = setmetatable({}, { __mode = "k" }),
	pushSeen = setmetatable({}, { __mode = "k" }),
	selected = {},
	-- movement
	moving = false,
	mode = nil, -- "dodge" | "item"
	target = nil,
	item = nil,
	lastPlan = 0,
	lastReport = 0,
	-- bookkeeping
	lastHealth = nil,
	hits = 0,
	dodges = 0,
	radii = {},
	landCache = {},
	recent = {},
	status = {},
	dead = false,
	snapbacks = 0,
	blockedFloor = 0,
	blockedLava = 0,
	-- collecting
	tries = {}, -- [instance] = { first = t, lastTouch = t, name = }
	skip = {}, -- [instance] = until time
	collected = 0,
	collectedBy = {},
	failed = 0,
	stats0 = nil,
	state = "starting",
}

local function report(msg)
	local line = os.date("%H:%M:%S") .. " " .. msg
	print("[SBSHub] " .. msg)
	local ok, err = pcall(function()
		if isfile(LOG) then
			appendfile(LOG, line .. "\n")
		else
			writefile(LOG, line .. "\n")
		end
	end)
	if not ok and not S.logErr then
		S.logErr = true
		print("[SBSHub] log file failed: " .. tostring(err))
	end
end

-- ── item catalogue ─────────────────────────────────────────
-- Names are the instance names seen in workspace.Bombs (live scan 2026-10-22) and
-- ReplicatedStorage/InfoModules/ShinyDrops. A whitelist on purpose: ZapTrap also carries
-- ObjName but is a hazard.
local ICON = {
	credit = function(color)
		return { Image = "rbxassetid://501403413", Offset = Vector2.new(0, 0), Size = Vector2.new(240, 240), Color = color or Color3.new(1, 0.847, 0) }
	end,
	gem = { Image = "rbxassetid://501403413", Offset = Vector2.new(480, 0), Size = Vector2.new(240, 240), Color = Color3.new(0, 1, 0.467) },
	candy = { Image = "rbxassetid://511701551" },
	-- frame 0,0 of this sheet is the dark "not found yet" silhouette; 400,200 is the
	-- coloured "Completed" frame the round HUD uses
	shiny = { Image = "rbxassetid://76387801397445", Offset = Vector2.new(400, 200), Size = Vector2.new(200, 200) },
}
local function glyph(ch, r, g, b)
	return { Glyph = ch, Color = Color3.fromRGB(r, g, b) }
end

local CATEGORIES = {
	{ Title = "Coins & Shinies", Items = {
		{ Key = "Coin_copper", Name = "Copper Coin", Icon = ICON.credit(Color3.fromRGB(222, 140, 80)), Selected = true },
		{ Key = "Coin_silver", Name = "Silver Coin", Icon = ICON.credit(Color3.fromRGB(210, 214, 224)), Selected = true },
		{ Key = "Coin_gold", Name = "Gold Coin", Icon = ICON.credit(), Selected = true },
		{ Key = "Coin_rosegold", Name = "Rosegold Coin", Icon = ICON.credit(Color3.fromRGB(255, 156, 150)), Selected = true },
		{ Key = "Coin_red", Name = "Red Coin", Icon = ICON.credit(Color3.fromRGB(235, 72, 72)), Selected = true },
		-- off by default: rounds with an EventIcon pickup died 23% vs 13% without (2026-10-22 log, 67 rounds)
		{ Key = "EventIcon", Name = "Event Icon", Icon = glyph("★", 230, 190, 60), Selected = false },
		{ Key = "ShinyRock", Name = "Shiny Rock", Icon = glyph("✦", 120, 200, 230), Selected = true },
	} },
	{ Title = "Event", Items = {
		{ Key = "HalloweenCandy", Name = "Halloween Candy", Icon = ICON.candy, Selected = true },
	} },
	{ Title = "Boost (permanent relics)", Items = {
		{ Key = "StatUp_Speed", Name = "Speed Relic", Icon = glyph("S", 70, 120, 200), Selected = true },
		{ Key = "StatUp_Jump", Name = "Jump Relic", Icon = glyph("J", 70, 160, 110), Selected = true },
		{ Key = "StatUp_Charge", Name = "Charge Relic", Icon = glyph("C", 200, 160, 60), Selected = true },
		{ Key = "StatUp_Health", Name = "Health Relic", Icon = glyph("H", 200, 70, 80), Selected = true },
		{ Key = "StatUp_Defense", Name = "Defense Relic", Icon = glyph("D", 120, 120, 140), Selected = true },
	} },
	{ Title = "Power-ups", Items = {
		{ Key = "CrystalShield", Name = "Crystal Shield", Icon = glyph("◆", 120, 200, 230), Selected = true },
		{ Key = "FireShield", Name = "Fire Shield", Icon = glyph("◆", 230, 120, 60), Selected = true },
		{ Key = "MagicShield", Name = "Magic Shield", Icon = glyph("◆", 170, 110, 230), Selected = true },
		{ Key = "SuperSoda", Name = "Supercharge Soda", Icon = glyph("S", 90, 170, 230), Selected = false },
		{ Key = "SpamSoda", Name = "Spam Soda", Icon = glyph("S", 230, 90, 150), Selected = false },
		{ Key = "Pizza", Name = "Pizza", Icon = glyph("P", 230, 170, 70), Selected = true },
		{ Key = "PizzaBox", Name = "Pizza Box", Icon = glyph("P", 190, 130, 70), Selected = true },
		{ Key = "SizeChanger_Grow", Name = "Grow", Icon = glyph("+", 90, 90, 110), Selected = false },
		{ Key = "SizeChanger_Shrink", Name = "Shrink", Icon = glyph("–", 90, 90, 110), Selected = false },
	} },
}
local ITEM_BY_KEY = {}
for _, cat in ipairs(CATEGORIES) do
	for _, it in ipairs(cat.Items) do
		ITEM_BY_KEY[it.Key] = it
		S.selected[it.Key] = it.Selected
	end
end

-- saved selection (per-viewer convenience)
do
	local ok, data = pcall(function()
		return HttpService:JSONDecode(readfile(CONFIG))
	end)
	if ok and type(data) == "table" then
		if type(data.selected) == "table" then
			for k, v in pairs(data.selected) do
				if ITEM_BY_KEY[k] then
					S.selected[k] = v and true or false
				end
			end
		end
		if data.dodge ~= nil then
			S.dodgeOn = data.dodge and true or false
		end
		if data.collect ~= nil then
			S.collectOn = data.collect and true or false
		end
		if data.hardcoreOn ~= nil then
			S.hardcoreOn = data.hardcoreOn and true or false
		end
		if type(data.uiKey) == "string" and Enum.KeyCode[data.uiKey] then
			S.uiKey = Enum.KeyCode[data.uiKey]
		end
		if type(data.finalSkill) == "number" then
			S.finalSkill = data.finalSkill
		end
		for _, k in ipairs({ "flyOn", "bringOn", "bombCtlOn", "autoSkill", "autoClaim", "voidOn" }) do
			if data[k] ~= nil then
				S[k] = data[k] and true or false
			end
		end
	end
end
local function saveConfig()
	pcall(function()
		writefile(CONFIG, HttpService:JSONEncode({ selected = S.selected, dodge = S.dodgeOn, collect = S.collectOn, flyOn = S.flyOn, bringOn = S.bringOn, bombCtlOn = S.bombCtlOn, autoSkill = S.autoSkill, finalSkill = S.finalSkill, autoClaim = S.autoClaim, hardcoreOn = S.hardcoreOn, voidOn = S.voidOn, uiKey = S.uiKey and S.uiKey.Name or nil }))
	end)
end

-- ── remotes / hook ─────────────────────────────────────────
-- Floor hazards (Spike/Burning/Electric) and lava are reported by the CLIENT
-- (StarterCharacterScripts/LocalInteractions). LocalObjectInteraction is also the
-- coin/pizza pickup, so only the lava call is dropped.
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local FloorRemote = Remotes:WaitForChild("FloorObjectInteraction")
local LocalRemote = Remotes:WaitForChild("LocalObjectInteraction")
local AfkRemote = ReplicatedStorage:WaitForChild("NotThere")

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
	if S.running and not checkcaller() and getnamecallmethod() == "FireServer" then
		-- gliding never sets MoveDirection, so the game would mark us AFK after 120s
		if self == AfkRemote and (...) == true then
			return nil
		end
		if self == FloorRemote then
			S.blockedFloor = S.blockedFloor + 1
			return nil
		end
		if self == LocalRemote then
			local part = ...
			if typeof(part) == "Instance" and part:HasTag("LocalLava") then
				S.blockedLava = S.blockedLava + 1
				return nil
			end
		end
	end
	return oldNamecall(self, ...)
end))

-- ── threats ────────────────────────────────────────────────
-- no DisarmBonus/BombName on these but they hurt (live scan 2026-10-22)
local HAZARD_NAMES = { ZapTrap = 12, ClusterBomb = 20 }
-- Zones measured as the part's own box + margin: Grimbell's kill zone, poison gas
-- (anchored, size varies), floor toxic traps (4x2x5, live scan 2026-10-22)
local HAZARD_BOXES = { GrimRadius = 6, PoisonCloud = 6, ToxicTrap = 5 }

local function isBomb(o)
	if HAZARD_NAMES[o.Name] then
		return true
	end
	if o:GetAttribute("DisarmBonus") ~= nil then
		return true
	end
	return o:FindFirstChild("BombName") ~= nil
end

local function bombRadius(o)
	local n = o.Name
	if HAZARD_NAMES[n] then
		return HAZARD_NAMES[n]
	end
	-- measured 2026-10-21: "explosion" up to 33, "death" 42; Grimbell (~24 studs/s) precedes "death"
	-- Grimbell goes off once it is ~37 studs from you with a 40-47 "death" blast
	-- (3 of 4 deaths, rounds 56/60/61 on 2026-10-22, all at exactly d=37): stay > 64
	if n == "Grimbell" then
		return 64
	end
	-- a Nuke is one bomb whose blast grows in steps: r 15 -> 25 -> 30 -> 40 -> 50
	-- (deaths in rounds 32 and 43 on 2026-10-22 were inside r 25-30 at 22-30 studs)
	if string.find(n, "Nuke") then
		return 62
	end
	-- homing/chaser rockets follow us and caused most remaining hits
	if string.find(n, "Rocket") or string.find(n, "Homing") or string.find(n, "Chaser") then
		return 36
	end
	if string.find(n, "Big") or string.find(n, "Mega") then
		return 40
	end
	return 28
end

local lastSeen = setmetatable({}, { __mode = "k" })

local function instPos(o)
	if o:IsA("BasePart") then
		return o.Position, o.AssemblyLinearVelocity
	end
	if o:IsA("Model") then
		local pp = o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart")
		return o:GetPivot().Position, pp and pp.AssemblyLinearVelocity or Vector3.zero
	end
	return nil
end

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.RespectCanCollide = true
rayParams.IgnoreWater = true

local function refreshFilter(char)
	local list = { Bombs, Explosions }
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Character then
			table.insert(list, p.Character)
		end
	end
	if char then
		table.insert(list, char)
	end
	rayParams.FilterDescendantsInstances = list
end

local function landing(o, pos, vel, now)
	if vel.Y > -3 then
		return pos
	end
	local c = S.landCache[o]
	if c and now - c.t < 0.25 then
		return Vector3.new(pos.X, c.y, pos.Z)
	end
	local hit = workspace:Raycast(pos, Vector3.new(0, -500, 0), rayParams)
	local y = hit and hit.Position.Y or pos.Y
	S.landCache[o] = { t = now, y = y }
	return Vector3.new(pos.X, y, pos.Z)
end

-- parts set on fire / electrified hurt on touch server-side (measured 2026-10-21)
local HAZARD_TAGS = { "Burning", "Electric" }

local function collectThreats(hrpPos, now)
	local list = {}
	local keep = {}
	for _, b in ipairs(S.blasts) do
		if os.clock() - b.t < b.life then
			table.insert(keep, b)
			table.insert(list, { p = b.p, r = b.r, n = "blast", raw = b.p, v = Vector3.zero })
		end
	end
	S.blasts = keep
	for _, tag in ipairs(HAZARD_TAGS) do
		for _, part in ipairs(CollectionService:GetTagged(tag)) do
			if part:IsA("BasePart") and part:IsDescendantOf(workspace) then
				local flat = Vector3.new(part.Position.X - hrpPos.X, 0, part.Position.Z - hrpPos.Z).Magnitude
				local half = math.max(part.Size.X, part.Size.Z) / 2
				if flat < 60 + half then
					table.insert(list, { box = part.CFrame, size = part.Size / 2, r = 4, p = part.Position, n = tag .. ":" .. part.Name, raw = part.Position, v = Vector3.zero })
				end
			end
		end
	end
	for _, o in ipairs(Bombs:GetChildren()) do
		if HAZARD_BOXES[o.Name] and o:IsA("BasePart") then
			table.insert(list, { box = o.CFrame, size = o.Size / 2, r = HAZARD_BOXES[o.Name], p = o.Position, n = o.Name, raw = o.Position, v = Vector3.zero })
		elseif isBomb(o) then
			local pos, vel = instPos(o)
			if pos then
				local seen = lastSeen[o]
				if vel.Magnitude < 0.5 and seen and now - seen.t > 0.05 then
					local derived = (pos - seen.p) / (now - seen.t)
					if derived.Magnitude < 200 then
						vel = derived
					end
				end
				lastSeen[o] = { p = pos, t = now }
				local flat = Vector3.new(pos.X - hrpPos.X, 0, pos.Z - hrpPos.Z).Magnitude
				if flat < 120 then
					local r = bombRadius(o)
					table.insert(list, { p = landing(o, pos, vel, now), r = r, n = o.Name, raw = pos, v = vel })
					-- still falling: some bombs go off on contact, keep clear of the bomb itself too
					if vel.Y < -3 then
						table.insert(list, { p = pos, r = 10 })
					end
					local side = Vector3.new(vel.X, 0, vel.Z)
					if side.Magnitude > 4 then
						table.insert(list, { p = pos + vel * 0.6, r = r })
						table.insert(list, { p = pos + vel * 1.2, r = r })
					end
				end
			end
		end
	end
	return list
end

-- positive = outside every blast, negative = inside one
local function margin(point, threats)
	local best = math.huge
	for _, t in ipairs(threats) do
		local m
		if t.box then
			local lp = t.box:PointToObjectSpace(point)
			local cl = Vector3.new(
				math.clamp(lp.X, -t.size.X, t.size.X),
				math.clamp(lp.Y, -t.size.Y, t.size.Y),
				math.clamp(lp.Z, -t.size.Z, t.size.Z))
			m = (lp - cl).Magnitude - t.r
		else
			m = (point - t.p).Magnitude - t.r
		end
		if m < best then
			best = m
		end
	end
	return best
end

local function floorAt(point, hrpY)
	local origin = Vector3.new(point.X, hrpY + 4, point.Z)
	local hit = workspace:Raycast(origin, Vector3.new(0, -30, 0), rayParams)
	if not hit or hit.Instance:HasTag("LocalLava") or hit.Instance:HasTag("Burning") or hit.Instance:HasTag("Electric") then
		return nil
	end
	if hit.Position.Y < hrpY - 12 then
		return nil
	end
	return Vector3.new(point.X, hit.Position.Y + 3, point.Z)
end

local DIRS = 16
local DISTS = { 8, 16, 26, 38, 55, 75, 95 }

-- the glide pushes into walls, so the straight line must be open (measured 2026-10-21)
local function pathClear(from, to)
	local flat = Vector3.new(to.X, from.Y, to.Z) - from
	if flat.Magnitude < 0.5 then
		return true
	end
	return workspace:Raycast(from, flat, rayParams) == nil
end

-- items can sit on another level: check the real 3D line to them
local function lineClear(from, to)
	local d = to - from
	if d.Magnitude < 0.5 then
		return true
	end
	return workspace:Raycast(from, d, rayParams) == nil
end

local function plan(hrp, threats)
	local here = hrp.Position
	local bestPt, bestScore = nil, margin(here, threats)
	local hereScore = bestScore
	for i = 1, DIRS do
		local a = (i / DIRS) * math.pi * 2
		local dir = Vector3.new(math.cos(a), 0, math.sin(a))
		for _, d in ipairs(DISTS) do
			local pt = floorAt(here + dir * d, here.Y)
			if pt and not pathClear(here, pt) then
				break
			end
			if pt then
				local score = margin(pt, threats) - d * 0.08
				if score > bestScore then
					bestScore = score
					bestPt = pt
				end
			end
		end
	end
	return bestPt, hereScore
end

-- Free 3D version: any open point in the air around us. Ground explosions cannot reach
-- a point high enough above them. Margins are computed first (cheap) and only a candidate
-- that would beat the best one is checked with raycasts / overlap.
local FLY_DIRS = 12
local FLY_DISTS = { 0, 10, 20, 32, 48, 70 }
local FLY_HEIGHTS = { 0, 14, 28, 42, -14 }
local overlap = OverlapParams.new()
overlap.FilterType = Enum.RaycastFilterType.Exclude
overlap.RespectCanCollide = true

local function insideGeometry(pt)
	overlap.FilterDescendantsInstances = rayParams.FilterDescendantsInstances
	return #workspace:GetPartBoundsInRadius(pt, 2.5, overlap) > 0
end

-- Highest point we allow above the real floor. Without it the planner kept stacking
-- "+42" moves and parked us 153 studs over the arena (2026-10-22).
local MAX_ALT = 55

-- The game publishes its arena ceiling as workspace.DefaultCeilingHeight (295). Going
-- above it (we reached 332) coincided with the server round clock freezing for an hour.
-- Void bombs only where nobody else plays: a Roblox private server (PrivateServerId set)
-- or a server with just us in it. Measured 2026-10-23 in a 1-player server whose
-- PrivateServerId was empty, so "solo" has to count too.
local function serverKind()
	if game.PrivateServerId ~= "" then
		return "private"
	end
	if #Players:GetPlayers() <= 1 then
		return "solo"
	end
	return "public"
end

local function ceilingY()
	local c = workspace:GetAttribute("DefaultCeilingHeight")
	return (type(c) == "number" and c or 295) - 15
end

local function floorBelow(pos)
	local hit = workspace:Raycast(pos, Vector3.new(0, -400, 0), rayParams)
	return hit and hit.Position.Y
end

local function plan3D(hrp, threats, relaxed)
	local here = hrp.Position
	local floorY = not relaxed and floorBelow(here) or nil
	local hereScore = margin(here, threats)
	local bestPt, bestScore = nil, hereScore
	for i = 1, FLY_DIRS do
		local a = (i / FLY_DIRS) * math.pi * 2
		local dir = Vector3.new(math.cos(a), 0, math.sin(a))
		for _, d in ipairs(FLY_DISTS) do
			if d > 0 or i == 1 then
				for _, h in ipairs(FLY_HEIGHTS) do
					local pt = here + dir * d + Vector3.new(0, h, 0)
					local inBand = pt.Y <= ceilingY() and (not floorY or (pt.Y <= floorY + MAX_ALT and pt.Y >= floorY + 2))
					local score = margin(pt, threats) - (d + math.abs(h)) * 0.06
					if inBand and score > bestScore and lineClear(here, pt) and not insideGeometry(pt) then
						bestScore = score
						bestPt = pt
					end
				end
			end
		end
	end
	return bestPt, hereScore
end

local function stopMove(hum)
	if S.moving then
		S.moving = false
		S.mode = nil
		S.target = nil
		S.item = nil
		hum:Move(Vector3.zero, false)
	end
end

-- ── collecting ─────────────────────────────────────────────
-- Items with LocalItem_Type (coins, pizza, shiny rock) are collected by the game's own
-- LocalInteractions when our Humanoid touches them; the rest (relics, shields, candy)
-- by the server's Touched. Either way: glide onto the item, plus firetouchinterest.
local function touchParts(o)
	local list = {}
	if o:IsA("BasePart") and o:FindFirstChildOfClass("TouchTransmitter") then
		table.insert(list, o)
	end
	for _, d in ipairs(o:GetDescendants()) do
		if d:IsA("BasePart") and d:FindFirstChildOfClass("TouchTransmitter") then
			table.insert(list, d)
		end
	end
	return list
end

-- heal items wait until we are at half HP or below
local HEAL_KEYS = { Pizza = true, PizzaBox = true }
-- shields: one at a time, only when no protection is running
local SHIELD_KEYS = { CrystalShield = true, FireShield = true, MagicShield = true }

local function protected(char)
	if not char then
		return false
	end
	if char:FindFirstChild("CrystalBubble") or char:FindFirstChild("FireBubble") or char:FindFirstChild("MagicBubbleFF") then
		return true
	end
	return char:GetAttribute("MagicShielded") == true
end

local function shieldPending()
	for o in pairs(S.tries) do
		if SHIELD_KEYS[o.Name] and o.Parent then
			return true
		end
	end
	return false
end

local function itemAvailable(o, now, bombHead)
	if not S.selected[o.Name] or not o.Parent then
		return false
	end
	local char = LocalPlayer.Character
	if o.Name == "EventIcon" and S.hcNow then
		return false -- never in hardcore
	end
	if HEAL_KEYS[o.Name] then
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if not hum or hum.Health > hum.MaxHealth * 0.5 then
			return false
		end
	end
	if SHIELD_KEYS[o.Name] and (protected(char) or shieldPending()) then
		return false
	end
	if o:GetAttribute("Collected") or o:GetAttribute("Debounce") == true then
		return false
	end
	if bombHead and o:GetAttribute("LocalItem_Type") then
		return false -- the game refuses these while you carry the BombHead
	end
	local until_ = S.skip[o]
	if until_ and now < until_ then
		return false
	end
	return true
end

local function findItem(hrp, threats, now, bombHead)
	local best, bestD = nil, math.huge
	for _, o in ipairs(Bombs:GetChildren()) do
		if itemAvailable(o, now, bombHead) and not S.tries[o] then
			local pos = instPos(o)
			if pos then
				local d = (pos - hrp.Position).Magnitude
				if d < bestD and d < 300 and (#threats == 0 or margin(pos, threats) >= 6) and lineClear(hrp.Position, pos) then
					best, bestD = o, d
				end
			end
		end
	end
	return best, bestD
end

local function touchItem(hrp, o, now)
	local t = S.tries[o]
	if not t then
		t = { first = now, lastTouch = 0, name = o.Name }
		S.tries[o] = t
	end
	if now - t.lastTouch < 0.3 then
		return
	end
	t.lastTouch = now
	for _, p in ipairs(touchParts(o)) do
		firetouchinterest(hrp, p, 0)
		firetouchinterest(hrp, p, 1)
	end
	-- Coins/pizza: credits arrive from the touch alone, but stats.coinsgrabbed (and the
	-- "Grab N coins" challenge) only counts the game's own report from LocalInteractions:
	-- LocalObjectInteraction:FireServer(part). Measured 2026-10-23: coinsgrabbed stuck at 16
	-- after hundreds of hub pickups. Send it once per item, like the game does.
	local kind = o:GetAttribute("LocalItem_Type")
	if (kind == "Coin" or kind == "Pizza" or kind == "Taco") and not t.reported and o:IsA("BasePart") then
		t.reported = true
		LocalRemote:FireServer(o)
	end
end

-- did the items we touched really go? (removed or marked Collected)
local function settleTries(now)
	for o, t in pairs(S.tries) do
		if not o.Parent or o:GetAttribute("Collected") then
			S.tries[o] = nil
			S.collected = S.collected + 1
			S.collectedBy[t.name] = (S.collectedBy[t.name] or 0) + 1
			report("collected " .. t.name)
		elseif now - t.first > 3 then
			S.tries[o] = nil
			S.skip[o] = now + 20
			S.failed = S.failed + 1
			report("could not collect " .. t.name .. " (skipping 20s)")
		end
	end
end

-- ── live stats ─────────────────────────────────────────────
local function readStats()
	local ok, st = pcall(function()
		return getrenv()._G.MyData.stats
	end)
	if ok and type(st) == "table" then
		return st
	end
	return nil
end

-- ── round results (persisted across sessions) ──────────────
local TOTALS_FILE = "SBSHubTotals.json"
local STAT_KEYS = { "credits", "gems", "hcandy", "shinies" }
local TOTALS = { rounds = 0, survived = 0, died = 0, credits = 0, gems = 0, hcandy = 0, shinies = 0, items = 0, history = {} }
do
	local ok, data = pcall(function()
		return HttpService:JSONDecode(readfile(TOTALS_FILE))
	end)
	if ok and type(data) == "table" then
		for k, v in pairs(data) do
			TOTALS[k] = v
		end
		if type(TOTALS.history) ~= "table" then
			TOTALS.history = {}
		end
	end
end
local function saveTotals()
	local ok, err = pcall(function()
		writefile(TOTALS_FILE, HttpService:JSONEncode(TOTALS))
	end)
	if not ok then
		report("saving totals failed: " .. tostring(err))
	end
end

-- ── skills: level every owned skill to 3, then settle on the final one ──
-- Data (MenuModules/Skills.lua): XP lives in LocalPlayer.skill["sk<id>"], owned when >= 1,
-- LVL 2 at 100, LVL 3 at 300. Equip = Remotes.swapSkill:InvokeServer("skill", id, xp, slot2);
-- "NEXT" back means it equips on respawn. XP comes from playing rounds with the skill
-- equipped, not from using it (measured 2026-10-22: Bomb 100 -> 213 with no skill use).
local SKILL_THRESHOLDS = { 100, 300 }
local SKILL_MAX_XP = 300
-- never auto-equip: Self-Destruct (4) hurts you, 66 is the random-skill slot
local SKILL_NEVER = { [4] = true, [66] = true }
local SkillInfo = nil
do
	local old = getthreadidentity and getthreadidentity()
	if setthreadidentity then
		setthreadidentity(2)
	end
	local ok, res = pcall(function()
		return require(ReplicatedStorage:WaitForChild("InfoModules"):WaitForChild("Skills")).Info
	end)
	if setthreadidentity and old then
		setthreadidentity(old)
	end
	if ok then
		SkillInfo = res
	else
		report("skill info require failed: " .. tostring(res))
	end
end
local SwapRemote = Remotes:WaitForChild("swapSkill")
local SKILL_SHEET = "rbxassetid://134921135570827" -- RoundUi currentSkill sheet, 100px cells

local function skillIcon(id)
	local it = SkillInfo and SkillInfo[id]
	if not it or not it.image then
		return { Glyph = "?", Color = Color3.fromRGB(60, 60, 72) }
	end
	return { Image = SKILL_SHEET, Offset = it.image * 100, Size = Vector2.new(100, 100) }
end

local function skillXp(id)
	local folder = LocalPlayer:FindFirstChild("skill")
	local v = folder and folder:FindFirstChild("sk" .. id)
	return v and v.Value or 0
end

local function ownedSkills()
	local list = {}
	local folder = LocalPlayer:FindFirstChild("skill")
	if not folder or not SkillInfo then
		return list
	end
	for id = 1, #SkillInfo do
		local v = folder:FindFirstChild("sk" .. id)
		if v and v.Value >= 1 and not SKILL_NEVER[id] then
			table.insert(list, { id = id, xp = v.Value, info = SkillInfo[id] })
		end
	end
	return list
end

-- default final skill: best lvl-3 cooldown among maxed movement/defense skills
local function defaultFinal(list)
	local best, bestCd = nil, math.huge
	for _, s in ipairs(list) do
		local cd = s.info.cooldown and s.info.cooldown[3] or 99
		local useful = s.info.type == "M" or s.info.type == "D"
		if s.xp >= SKILL_MAX_XP and useful and cd < bestCd then
			best, bestCd = s.id, cd
		end
	end
	return best
end

-- next skill to level: the closest to LVL 3 first (fewest rounds wasted), else none
local function nextToLevel(list, current)
	local best, bestXp = nil, -1
	for _, s in ipairs(list) do
		if s.xp < SKILL_MAX_XP and s.id ~= current and s.xp > bestXp then
			best, bestXp = s.id, s.xp
		end
	end
	return best
end

-- ── UI ─────────────────────────────────────────────────────
local win = UIFX.Window({
	Title = "Aimia - Super Bomb Survival",
	Size = UDim2.fromOffset(680, 560),
	Nav = "top",
	ToggleKey = S.uiKey or Enum.KeyCode.RightControl,
	OnClose = function()
		if getgenv().SBSHubStop then
			getgenv().SBSHubStop()
		end
	end,
})

local STAT_DEFS = {
	{ Key = "credits", Label = "Coins", Icon = ICON.credit() },
	{ Key = "gems", Label = "Gems", Icon = ICON.gem },
	{ Key = "hcandy", Label = "Candy", Icon = ICON.candy },
	{ Key = "shinies", Label = "Shinies", Icon = ICON.shiny },
}
local LOG_COLS = {
	{ Key = "credits", Icon = ICON.credit() },
	{ Key = "gems", Icon = ICON.gem },
	{ Key = "hcandy", Icon = ICON.candy },
}

local UI = {}
do
	local main = win:Tab("Overview")
	UI.card = main:StatusCard()
	UI.streak = main:StreakCard(10)
	main:Section("Balance · gained this round")
	UI.tiles = main:StatTiles(STAT_DEFS, 4)
	main:Section("Round results")
	UI.log = main:RoundLog(LOG_COLS, 8)

	local col = win:Tab("Collect")
	UI.grids = {}
	for _, cat in ipairs(CATEGORIES) do
		local items = {}
		for _, it in ipairs(cat.Items) do
			table.insert(items, { Key = it.Key, Name = it.Name, Icon = it.Icon, Selected = S.selected[it.Key] })
		end
		local g = col:ItemGrid(cat.Title, items, function(key, on)
			S.selected[key] = on
			saveConfig()
		end, 4)
		for _, it in ipairs(cat.Items) do
			UI.grids[it.Key] = g
		end
	end

	local sk = win:Tab("Skills")
	sk:Toggle("Auto level skills", S.autoSkill, function(on)
		S.autoSkill = on
		saveConfig()
	end, "Swap to an unfinished skill when the equipped one hits LVL 3")
	UI.skillHero = sk:SkillHero()
	-- grouped like the shop tabs; colours are the game's own type colours
	local SKILL_GROUPS = {
		{ Type = "O", Title = "Offense", Color = Color3.fromRGB(255, 0, 89) },
		{ Type = "M", Title = "Movement", Color = Color3.fromRGB(116, 255, 57) },
		{ Type = "D", Title = "Defense", Color = Color3.fromRGB(98, 106, 255) },
		{ Type = "N", Title = "Other", Color = Color3.fromRGB(140, 93, 12) },
	}
	local owned = ownedSkills()
	local function pick(id)
		S.finalSkill = id
		saveConfig()
		local it = SkillInfo and SkillInfo[id]
		win:Notify("Final skill: " .. (it and it.name or tostring(id)), "Good", 3)
	end
	UI.skillGrids = {}
	local grids = {}
	for _, g in ipairs(SKILL_GROUPS) do
		local items = {}
		for _, sd in ipairs(owned) do
			if sd.info.type == g.Type then
				table.insert(items, { Key = sd.id, Name = sd.info.name, Icon = skillIcon(sd.id), Color = g.Color })
			end
		end
		if #items > 0 then
			sk:Section(g.Title .. " · " .. #items, g.Color)
			local grid = sk:SkillGrid(items, pick, 4, SKILL_THRESHOLDS)
			table.insert(grids, grid)
			for _, it in ipairs(items) do
				UI.skillGrids[it.Key] = grid
			end
		end
	end
	-- one object with :Update(id, state) that forwards to the right group
	UI.skillGrid = {
		Update = function(_, id, st)
			local grid = UI.skillGrids[id]
			if grid then
				grid:Update(id, st)
			end
		end,
	}

	local set = win:Tab("Settings")
	set:Section("Mode")
	do
		local opts = LocalPlayer:FindFirstChild("options")
		local hcVal = opts and opts:FindFirstChild("hardcore")
		if S.hardcoreOn == nil then
			S.hardcoreOn = hcVal and hcVal.Value or false
		end
	end
	set:DangerToggle("Hardcore mode", S.hardcoreOn, function(on)
		S.hardcoreOn = on
		S.lastHcSet = 0
		saveConfig()
		if on then
			win:Notify("Hardcore on · 35 HP, perks off · some rounds will be lost", "Bad", 5)
		end
	end, "More credits per round · 35 HP, perks off · expect to lose some rounds", "RISKY")
	UI.voidCard = set:DangerToggle("Void bombs", S.voidOn, function(on)
		S.voidOn = on
		saveConfig()
	end, "Drops every bomb you control under the map", "FOR PRIVATE SERVER",
		{ Color = Color3.fromRGB(150, 110, 255), Glyph = "Ø", Note = true })
	set:Section("Survival")
	set:Toggle("Auto dodge", S.dodgeOn, function(on)
		S.dodgeOn = on
		saveConfig()
	end, "Move out of every predicted blast, fire and electric zone")
	set:Toggle("Fly freely", S.flyOn, function(on)
		S.flyOn = on
		if not on then
			S.hold = nil
		end
		saveConfig()
	end, "Dodge in 3D and hover in the air instead of staying on the floor")
	set:Toggle("Slow + push away bombs", S.bombCtlOn, function(on)
		S.bombCtlOn = on
		saveConfig()
	end, "Bombs you own the physics of fall slowly and get pushed out of range")
	set:Section("Farming")
	set:Toggle("Auto collect", S.collectOn, function(on)
		S.collectOn = on
		saveConfig()
	end, "Go after the items picked in the Collect tab when it is safe")
	set:Toggle("Bring items to me", S.bringOn, function(on)
		S.bringOn = on
		saveConfig()
	end, "Pull items you own the physics of straight onto your character")
	set:Toggle("Auto claim challenges", S.autoClaim, function(on)
		S.autoClaim = on
		saveConfig()
	end, "Claim hourly, daily and VIP gem rewards as soon as they are done")
	UI.challenges = set:Status("Challenges")
	set:Section("Results")
	set:Button("Reset total results", function()
		TOTALS = { rounds = 0, survived = 0, died = 0, credits = 0, gems = 0, hcandy = 0, shinies = 0, items = 0, history = {} }
		saveTotals()
		win:Notify("Total results reset", "Warn", 3)
	end)
	set:Section("Interface")
	set:Keybind("Show / hide key", win:GetToggleKey(), function(key)
		S.uiKey = key
		win:SetToggleKey(key)
		saveConfig()
		win:Notify("Show / hide key: " .. key.Name, "Good", 4)
	end, "Click, then press the key you want. Esc cancels")
end

-- 3D icons for items the game has no image for. Sources, in order:
--  1) models the client already has: ReplicatedStorage.Decor.Pizza, and the shop's
--     Boosts > Spawn preview viewports (SuperSoda / EventIcon, child "Object")
--  2) a copy cached in getgenv() the first time the item showed up in the map, so a
--     re-run in the same game session starts with every icon seen so far
--  The rest live only in ServerStorage and appear once they spawn.
do
	local cache = getgenv().SBSIconCache or {}
	getgenv().SBSIconCache = cache
	local done = {}

	local function keep(key, inst)
		if cache[key] then
			return
		end
		local ok, copy = pcall(function()
			local was = inst.Archivable
			inst.Archivable = true
			local c = inst:Clone()
			inst.Archivable = was
			return c
		end)
		if ok and copy then
			cache[key] = copy
		end
	end

	local function apply(key, inst)
		local it = ITEM_BY_KEY[key]
		local g = UI.grids[key]
		if done[key] or not it or not g or not (it.Icon and it.Icon.Glyph) then
			return
		end
		local ok, err = pcall(UIFX.viewport, g:IconHolder(key), inst)
		if ok then
			done[key] = true
		else
			report("icon for " .. key .. " failed: " .. tostring(err))
		end
	end

	-- 1) client-side models
	pcall(function()
		local decor = ReplicatedStorage:FindFirstChild("Decor")
		local pizza = decor and decor:FindFirstChild("Pizza")
		if pizza then
			keep("Pizza", pizza)
		end
	end)
	pcall(function()
		for _, vf in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
			if vf:IsA("ViewportFrame") and vf.Parent and ITEM_BY_KEY[vf.Parent.Name] then
				local obj = vf:FindFirstChild("Object") or vf:FindFirstChildWhichIsA("Model") or vf:FindFirstChildWhichIsA("BasePart")
				if obj then
					keep(vf.Parent.Name, obj)
				end
			end
		end
	end)
	for key, inst in pairs(cache) do
		apply(key, inst)
	end

	-- 2) live items: learn names and cache models as they appear
	task.spawn(function()
		local named = {}
		while S.running and win.Alive do
			for _, o in ipairs(Bombs:GetChildren()) do
				local key = o.Name
				if ITEM_BY_KEY[key] then
					if not named[key] then
						named[key] = true
						local objName = o:GetAttribute("ObjName")
						local g = UI.grids[key]
						if g and objName then
							g:SetName(key, objName)
						end
					end
					if not cache[key] then
						keep(key, o)
					end
					if not done[key] and cache[key] then
						apply(key, cache[key])
					end
				end
			end
			task.wait(1)
		end
	end)
end

-- Challenges (MenuModules/Challenges.lua): _G.MyData.challenges.<hourly|daily|vip> =
-- { name, num, complete, rewarded }; claim = Remotes.challengeGem:InvokeServer(key) -> true.
-- vip needs _G.MyData.options.vip.
local ClaimRemote = Remotes:WaitForChild("challengeGem")
local CHALLENGE_KEYS = { "hourly", "daily", "vip" }

local function checkChallenges()
	local ok, data = pcall(function()
		return getrenv()._G.MyData
	end)
	if not ok or type(data) ~= "table" or type(data.challenges) ~= "table" then
		return
	end
	local vip = type(data.options) == "table" and data.options.vip == true
	local lines = {}
	local now = os.clock()
	for _, key in ipairs(CHALLENGE_KEYS) do
		local c = data.challenges[key]
		if type(c) == "table" then
			local done = (c.complete or 0) >= (c.num or 1)
			local status
			if key == "vip" and not vip then
				status = "needs VIP pass"
			elseif c.rewarded then
				status = "claimed ✓"
			elseif done then
				status = "ready"
				if S.autoClaim and now - (S.lastClaim[key] or 0) > 15 then
					S.lastClaim[key] = now
					local okClaim, res = pcall(function()
						return ClaimRemote:InvokeServer(key)
					end)
					if okClaim and res == true then
						S.claimed = S.claimed + 1
						status = "claimed ✓"
						report("claimed " .. key .. " challenge: " .. tostring(c.name))
						win:Notify("Claimed " .. key .. " challenge", "Good", 4)
					else
						status = "claim failed: " .. tostring(res)
						report("claim " .. key .. " failed: " .. tostring(res))
					end
				end
			else
				status = string.format("%d/%d", c.complete or 0, c.num or 0)
			end
			table.insert(lines, string.format("%s · %s · %s", string.upper(key), tostring(c.name), status))
		end
	end
	table.insert(lines, string.format("Claimed by the hub this session: %d", S.claimed))
	UI.challenges:Set(table.concat(lines, "\n"))
end

local OptionRemote = Remotes:WaitForChild("chooseOption")
local function syncHardcore()
	local opts = LocalPlayer:FindFirstChild("options")
	local hcVal = opts and opts:FindFirstChild("hardcore")
	if not hcVal or S.hardcoreOn == nil or hcVal.Value == S.hardcoreOn then
		return
	end
	local st = readStats()
	if S.hardcoreOn and st and (st.wins or 0) < 50 then
		return -- still locked
	end
	if os.clock() - S.lastHcSet < 10 then
		return
	end
	S.lastHcSet = os.clock()
	OptionRemote:FireServer("hc", S.hardcoreOn)
	report("hardcore option -> " .. tostring(S.hardcoreOn))
end

-- skill levelling loop (own thread: InvokeServer yields)
task.spawn(function()
	while S.running and win.Alive do
		local ok, err = pcall(function()
			local list = ownedSkills()
			local skillVal = LocalPlayer:FindFirstChild("skill")
			local nextVal = LocalPlayer:FindFirstChild("nextSkill")
			local cur = skillVal and skillVal.Value or 0
			local pending = nextVal and nextVal.Value or -1
			local final = S.finalSkill
			local owned = false
			for _, sd in ipairs(list) do
				if sd.id == final then
					owned = true
				end
			end
			if not owned then
				final = defaultFinal(list)
			end
			local now = os.clock()
			if S.autoSkill and SkillInfo then
				local target = nil
				if cur <= 0 or skillXp(cur) >= SKILL_MAX_XP then
					target = nextToLevel(list, cur) or final
				end
				if not target then
					S.skillNote = cur > 0 and "Levelling this skill · swaps at LVL 3" or ""
				elseif target == cur then
					S.skillNote = "Every skill is MAX · using the final skill"
				elseif target == pending then
					S.skillNote = "Equips " .. SkillInfo[target].name .. " on respawn"
				elseif now - S.lastSwap > 10 then
					S.lastSwap = now
					local okSwap, res = pcall(function()
						return SwapRemote:InvokeServer("skill", target, skillXp(target), false)
					end)
					local name = SkillInfo[target].name
					if not okSwap then
						report("swapSkill error: " .. tostring(res))
						S.skillNote = "Swap failed: " .. tostring(res)
					elseif res == "NEXT" then
						report("skill " .. name .. " equips on respawn")
						S.skillNote = "Equips " .. name .. " on respawn"
					elseif type(res) == "string" then
						report("swapSkill refused: " .. res)
						S.skillNote = "Swap refused: " .. res
					else
						report("equipped skill " .. name)
						S.skillNote = "Equipped " .. name
					end
				end
			else
				S.skillNote = "Auto level is off"
			end
			-- UI
			for _, sd in ipairs(list) do
				UI.skillGrid:Update(sd.id, { Xp = sd.xp, Equipped = sd.id == cur, Next = sd.id == pending and pending ~= cur, Final = sd.id == final })
			end
			local curInfo = SkillInfo and SkillInfo[cur]
			UI.skillHero:Set({
				Icon = cur > 0 and skillIcon(cur) or nil,
				Name = curInfo and curInfo.name or "No skill",
				Xp = cur > 0 and skillXp(cur) or 0,
				Thresholds = SKILL_THRESHOLDS,
				Note = S.skillNote,
			})
		end)
		pcall(syncHardcore)
		do
			local kind = serverKind()
			S.voidAllowed = kind ~= "public"
			local n = #Players:GetPlayers()
			local txt
			if kind == "private" then
				txt = "Private server · void bombs available"
			elseif kind == "solo" then
				txt = "Public server, only you here · void bombs available"
			else
				txt = string.format("Public server · %d players · void bombs paused", n)
			end
			UI.voidCard:SetNote(txt, S.voidAllowed and "Good" or "Warn")
			if UI.voidCard.Locked ~= not S.voidAllowed then
				UI.voidCard:SetLocked(not S.voidAllowed, "Void bombs only works in a private server or when you are alone")
				if S.voidAllowed and S.voidOn and not UI.voidCard.Value then
					UI.voidCard:Set(true, true)
				end
			end
		end
		local okC, errC = pcall(checkChallenges)
		if not okC and errC ~= S.lastClaimErr then
			S.lastClaimErr = errC
			report("challenge loop error: " .. tostring(errC))
		end
		if not ok and err ~= S.lastSkillErr then
			S.lastSkillErr = err
			report("skill loop error: " .. tostring(err))
		end
		task.wait(2)
	end
end)

-- End-of-round scorecard (StarterGui/ScoreCard/scorecardScript):
-- scorecard.OnClientEvent(points, bonus, intensityMult, mult, coinsTotal, rando, noPremium).
-- The card's streak line is min(100, (WinStreak - 2) * 5) once WinStreak >= 3.
table.insert(S.conns, Remotes:WaitForChild("scorecard").OnClientEvent:Connect(function(pts, bonus, mult1, mult2, total)
	S.lastCard = { pts = pts, bonus = bonus, mult1 = mult1, mult2 = mult2, total = total }
	report(string.format("scorecard: points %s bonus %s x%s x%s total %s", tostring(pts), tostring(bonus), tostring(mult1), tostring(mult2), tostring(total)))
end))

local function streakBonus(n)
	if n < 3 then
		return 0
	end
	return math.min(100, (n - 2) * 5)
end

-- ── main loop ──────────────────────────────────────────────
table.insert(S.conns, Explosions.ChildAdded:Connect(function(e)
	if e:IsA("Explosion") then
		local r = e.BlastRadius
		if not S.radii[e.Name] or r > S.radii[e.Name] then
			S.radii[e.Name] = r
		end
		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if e.Position.Y < workspace.FallenPartsDestroyHeight + 50 then
			S.voidBlasts = S.voidBlasts + 1
		end
		local grow = e.Name == "nuke"
		local tnow = os.clock()
		table.insert(S.blasts, { p = e.Position, r = grow and 58 or (r + 6), t = tnow, life = grow and 3 or 0.6 })
		-- Carpet bombing (AirStrike): same-name blasts ~9 studs apart every few tenths of a
		-- second walking in a line (rounds 51 and 53 died to it on 2026-10-22). Extend the
		-- line ahead so the dodge leaves it before the next blasts arrive.
		local last = S.lastBlast[e.Name]
		if last and tnow - last.t < 1.5 then
			local step = e.Position - last.p
			local len = step.Magnitude
			if len > 4 and len < 25 then
				for k = 1, 10 do
					table.insert(S.blasts, { p = e.Position + step * k, r = math.max(r, 16) + 6, t = tnow, life = 2.5 })
				end
				if not S.lineLogged or tnow - S.lineLogged > 3 then
					S.lineLogged = tnow
					report(string.format("carpet line: %s step %.1f studs every %.2fs", e.Name, len, tnow - last.t))
				end
			end
		end
		S.lastBlast[e.Name] = { p = e.Position, t = tnow }
		if hrp then
			local d = (hrp.Position - e.Position).Magnitude
			table.insert(S.recent, { t = os.clock(), name = e.Name, r = r, d = d })
			if #S.recent > 30 then
				table.remove(S.recent, 1)
			end
		end
	end
end))

local function fmt(n)
	local s = tostring(math.floor(n))
	local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
	if out:sub(1, 1) == "," then
		out = out:sub(2)
	end
	return out
end

-- A round runs from getting the PlayingHumanoid tag until 8s after losing it,
-- so the end-of-round rewards still land in that round's numbers.
local ROUND_GRACE = 8
-- Income only: every rise between two reads is added, drops are ignored. A plain
-- end-minus-start counted skill purchases as a loss (round 7 on 2026-10-22: -8688 coins).
local function trackGains(st)
	local r = S.round
	for _, k in ipairs(STAT_KEYS) do
		local v = st[k] or 0
		local diff = v - (r.last[k] or v)
		if diff > 0 then
			r.gain[k] = (r.gain[k] or 0) + diff
		end
		r.last[k] = v
	end
end

local function roundDelta(st)
	local r = S.round
	trackGains(st)
	local d = { items = S.collected - r.items0 }
	for _, k in ipairs(STAT_KEYS) do
		d[k] = r.gain[k] or 0
	end
	return d
end

local function finishRound(st)
	local r = S.round
	-- delta first: roundDelta reads S.round (clearing it first was the "always round #1" bug)
	local d = roundDelta(st)
	S.round = nil
	TOTALS.rounds = TOTALS.rounds + 1
	if r.died then
		TOTALS.died = TOTALS.died + 1
	else
		TOTALS.survived = TOTALS.survived + 1
	end
	for k, v in pairs(d) do
		TOTALS[k] = (TOTALS[k] or 0) + v
	end
	if r.hc then
		TOTALS.hcRounds = (TOTALS.hcRounds or 0) + 1
	end
	table.insert(TOTALS.history, 1, { n = TOTALS.rounds, died = r.died, d = d, hc = r.hc })
	while #TOTALS.history > 10 do
		table.remove(TOTALS.history)
	end
	saveTotals()
	report(string.format("round %d %s%s: coins %+d gems %+d candy %+d shinies %+d items %d",
		TOTALS.rounds, r.hc and "HARDCORE " or "", r.died and "died" or "survived", d.credits, d.gems, d.hcandy, d.shinies, d.items))
	win:Notify(string.format("%sRound %d %s · +%d coins · +%d candy", r.hc and "Hardcore · " or "", TOTALS.rounds, r.died and "lost" or "survived", d.credits, d.hcandy), r.died and "Bad" or (r.hc and "Hardcore" or "Good"), 4)
end

local function trackRound(hum, st, now)
	local playing = hum and hum:HasTag("PlayingHumanoid")
	if playing then
		if not S.round then
			S.round = { last = {}, gain = {}, items0 = S.collected, died = false, t0 = now }
			for _, k in ipairs(STAT_KEYS) do
				S.round.last[k] = st[k] or 0
			end
		end
		S.round.leftAt = nil
		trackGains(st)
		local tr = LocalPlayer:FindFirstChild("ThisRound")
		local hcRound = tr and tr:FindFirstChild("hardcore")
		if hcRound and hcRound.Value then
			S.round.hc = true
		end
		if hum.Health <= 0 then
			S.round.died = true
		end
	elseif S.round then
		if hum and hum.Health <= 0 then
			S.round.died = true
		end
		S.round.leftAt = S.round.leftAt or now
		trackGains(st)
		if now - S.round.leftAt >= ROUND_GRACE then
			finishRound(st)
		end
	end
end

local STATE_STYLE = {
	{ "^Dodging", "Dodging", "Warn" },
	{ "^Collecting", "Collecting", "Good" },
	{ "^Safe", "Safe", "Accent" },
	{ "^Lobby", "Lobby", "SubText" },
	{ "^Dead", "Dead", "Bad" },
}

local function clockText()
	local ok, txt = pcall(function()
		local timer = LocalPlayer.PlayerGui.RoundUi.Top.YY.Timer
		return timer:FindFirstChildWhichIsA("TextLabel", true).Text
	end)
	return ok and txt or nil
end

local function updateUI(hum)
	local st = readStats()
	local now = os.clock()
	for o, t in pairs(S.voidSeen) do
		if t ~= true and not o.Parent then
			S.voidGone = S.voidGone + 1
			S.voidSeen[o] = true
		end
	end
	if S.voidOn and (not S.lastVoidReport or now - S.lastVoidReport > 30) and S.voided > 0 then
		S.lastVoidReport = now
		report(string.format("void: sent %d, gone %d, blasts under the map %d", S.voided, S.voidGone, S.voidBlasts))
	end
	-- a frozen round clock means the server's round loop is stuck: nothing will pay out
	-- until you rejoin, so say so instead of farming a dead server
	if hum and hum:HasTag("PlayingHumanoid") then
		local txt = clockText()
		if txt ~= S.clockTxt then
			if S.freezeTest then
				report(string.format("round clock moving again %.0fs after pausing bomb control / bring", now - S.freezeTest))
				S.freezeTest = nil
			end
			S.clockTxt = txt
			S.clockT = now
			S.clockWarned = false
		elseif S.clockT and now - S.clockT > 90 and not S.clockWarned then
			S.clockWarned = true
			-- Suspect: the server waits for bombs that never go off because we keep pushing
			-- them away. Pause our physics meddling and see if the clock resumes.
			S.freezeTest = now
			S.pauseMeddle = now + 45
			report("round clock frozen at " .. tostring(txt) .. " for 90s - pausing bomb control + bring for 45s to test")
			win:Notify("Round clock frozen · pausing bomb control to test", "Bad", 8)
		elseif S.freezeTest and now - S.freezeTest > 50 and not S.freezeReported then
			S.freezeReported = true
			report("round clock still frozen 50s after pausing bomb control - not our meddling, rejoin")
			win:Notify("Server round loop stuck · rejoin the server", "Bad", 10)
		end
	end
	if st then
		trackRound(hum, st, now)
		local d = S.round and roundDelta(st) or {}
		for _, def in ipairs(STAT_DEFS) do
			UI.tiles:Set(def.Key, fmt(st[def.Key] or 0), d[def.Key])
		end
		-- result rows: the running round first, then the finished ones
		local rows = {}
		if S.round then
			local vals = {}
			for k, v in pairs(d) do
				vals[k] = v
			end
			local hc = S.round.hc
			table.insert(rows, {
				Round = "#" .. (TOTALS.rounds + 1),
				Result = (hc and "HC " or "") .. (S.round.died and "Died" or "Live"),
				Kind = S.round.died and "Bad" or (hc and "Hardcore" or "Accent"),
				Hardcore = hc,
				Values = vals,
			})
		end
		for _, h in ipairs(TOTALS.history) do
			table.insert(rows, {
				Round = "#" .. h.n,
				Result = (h.hc and "HC " or "") .. (h.died and "Died" or "Survived"),
				Kind = h.died and "Bad" or (h.hc and "Hardcore" or "Good"),
				Hardcore = h.hc,
				Values = h.d,
			})
		end
		UI.log:SetRows(rows)
		UI.log:SetTotal({
			Round = "TOTAL",
			Result = string.format("%d rounds · %d won · %d HC", TOTALS.rounds, TOTALS.survived, TOTALS.hcRounds or 0),
			Values = { credits = TOTALS.credits, gems = TOTALS.gems, hcandy = TOTALS.hcandy, shinies = TOTALS.shinies, items = TOTALS.items },
		})
	end
	for key, n in pairs(S.collectedBy) do
		local g = UI.grids[key]
		if g then
			g:SetCount(key, n)
		end
	end

	-- win streak straight from the game: Player.WinStreak (current), stats.topstreak, leaderstats.Wins
	do
		local ws = LocalPlayer:FindFirstChild("WinStreak")
		local ls = LocalPlayer:FindFirstChild("leaderstats")
		local wins = ls and ls:FindFirstChild("Wins")
		local recent = {}
		if S.round then
			-- the running round is not decided yet: shown as an accent "live" pip
			recent[1] = "live"
		end
		for _, h in ipairs(TOTALS.history) do
			table.insert(recent, not h.died)
		end
		local n = ws and ws.Value or 0
		local bonus = streakBonus(n)
		local sub = string.format("Best %d · %d wins", st and st.topstreak or 0, wins and wins.Value or (st and st.wins or 0))
		if n >= 22 then
			sub = sub .. " · bonus maxed"
		elseif n >= 3 then
			sub = sub .. string.format(" · max bonus in %d", 22 - n)
		else
			sub = sub .. string.format(" · bonus starts in %d", 3 - n)
		end
		if S.lastCard and S.lastCard.total then
			sub = sub .. " · last reward +" .. tostring(S.lastCard.total)
		end
		UI.streak:Set({
			Streak = n,
			Best = st and st.topstreak or 0,
			Wins = wins and wins.Value or (st and st.wins or 0),
			Recent = recent,
			Bonus = bonus,
			BonusText = "+" .. bonus .. " STREAK BONUS",
			Sub = sub,
		})
	end

	local pillText, kind = "Starting", "Accent"
	for _, s in ipairs(STATE_STYLE) do
		if string.find(S.state, s[1]) then
			pillText, kind = s[2], s[3]
			break
		end
	end
	local detail
	if S.round then
		local secs = math.floor(now - S.round.t0)
		detail = string.format("%sRound #%d · %d:%02d elapsed · %d items this round", S.round.hc and "Hardcore · " or "", TOTALS.rounds + 1, math.floor(secs / 60), secs % 60, S.collected - S.round.items0)
	else
		detail = string.format("%d rounds played · %d survived", TOTALS.rounds, TOTALS.survived)
	end
	UI.card:Set({
		State = pillText,
		Kind = kind,
		Headline = S.state,
		Detail = detail,
		HP = hum and hum.Health or 0,
		MaxHP = hum and hum.MaxHealth or 100,
		Chips = {
			{ "Hits", S.hits },
			{ "Dodges", S.dodges },
			{ "Pushed", S.pushed },
			{ "Items", S.collected },
		},
	})
end

table.insert(S.conns, RunService.Heartbeat:Connect(function()
	if not S.running then
		return
	end
	local now = os.clock()
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local hrp = char and char:FindFirstChild("HumanoidRootPart")

	if now - S.lastReport >= 0.5 then
		S.lastReport = now
		local ok, err = pcall(updateUI, hum)
		if not ok and err ~= S.lastUiErr then
			S.lastUiErr = err
			report("UI update error: " .. tostring(err))
		end
	end
	if not hum or not hrp then
		S.state = "Waiting for character"
		return
	end
	if hum.Health <= 0 then
		if not S.dead then
			S.dead = true
			local near = {}
			for _, x in ipairs(S.recent) do
				if now - x.t < 1.5 then
					table.insert(near, string.format("%s r=%d d=%.0f", x.name, x.r, x.d))
				end
			end
			report("DIED (last hp " .. tostring(S.lastHealth) .. ") recent explosions: " .. table.concat(near, "; "))
		end
		S.state = "Dead - waiting for respawn"
		S.lastHealth = nil
		return
	end
	S.dead = false

	if S.lastHealth and hum.Health < S.lastHealth - 0.5 then
		S.hits = S.hits + 1
		local tags = {}
		for name, t in pairs(S.status) do
			if now - t < 1.5 then
				table.insert(tags, name)
			end
		end
		report(string.format("took %.0f dmg (hp %.0f) margin %.1f mode %s status [%s]",
			S.lastHealth - hum.Health, hum.Health, S.hereScore or -1, tostring(S.mode), table.concat(tags, ",")))
	end
	S.lastHealth = hum.Health

	-- flagged AFK already: clear it the way the game does when you walk
	if LocalPlayer:GetAttribute("NotThere") and (not S.lastUnAfk or now - S.lastUnAfk > 2) then
		local opts = LocalPlayer:FindFirstChild("options")
		local afkOpt = opts and opts:FindFirstChild("AFK")
		if not (afkOpt and afkOpt:GetAttribute("ManuallySet")) then
			S.lastUnAfk = now
			AfkRemote:FireServer(false)
		end
	end

	if not hum:HasTag("PlayingHumanoid") then
		stopMove(hum)
		S.hold = nil
		S.state = "Lobby - waiting for a round"
		return
	end

	if now - S.lastPlan < 0.1 then
		return
	end
	S.lastPlan = now
	refreshFilter(char)
	for o in pairs(S.tries) do
		local pos = o.Parent and instPos(o)
		if pos and (pos - hrp.Position).Magnitude < 8 then
			touchItem(hrp, o, now)
		end
	end
	settleTries(now)

	local threats = collectThreats(hrp.Position, now)
	local pt, hereScore = nil, math.huge
	if #threats > 0 then
		if S.flyOn then
			pt, hereScore = plan3D(hrp, threats)
			if not pt and hereScore < 4 then
				-- every in-band spot failed (round 47 died standing still at margin -26):
				-- take any open spot under the ceiling instead
				pt = plan3D(hrp, threats, true)
			end
			if not pt and hereScore < 0 then
				-- still nothing (round 67 died at margin -23.5): run straight away from the
				-- threats pushing on us, no line checks, kept under the ceiling
				local push = Vector3.zero
				for _, t in ipairs(threats) do
					local tp = t.p
					local away = hrp.Position - tp
					local m = away.Magnitude - t.r
					if m < 0 and away.Magnitude > 0.1 then
						push = push + away.Unit * (-m)
					end
				end
				if push.Magnitude > 0.1 then
					local goal = hrp.Position + push.Unit * 30
					goal = Vector3.new(goal.X, math.min(goal.Y, ceilingY()), goal.Z)
					pt = goal
					report("flee fallback: no open spot, running straight out")
				end
			end
		else
			pt, hereScore = plan(hrp, threats)
		end
	end
	S.hereScore = hereScore
	S.threatCount = #threats

	-- Hardcore: 35 HP and one bomb (50-65 dmg) kills, so wider margins, no flying down to
	-- items (bring only), and hover high above the floor where ground blasts (max r 42) end.
	local hcRound = false
	do
		local tr = LocalPlayer:FindFirstChild("ThisRound")
		local v = tr and tr:FindFirstChild("hardcore")
		hcRound = v and v.Value or false
	end
	S.hcNow = hcRound
	local SAFE = hcRound and 12 or 4
	local CALM = hcRound and 16 or 6

	-- 1) dodging wins over everything
	if S.dodgeOn then
		local keep = false
		if S.mode == "dodge" and S.target and #threats > 0 then
			local stuck = S.progressT and now - S.progressT > 0.4
			local open
			if S.flyOn then
				open = lineClear(hrp.Position, S.target)
			else
				open = pathClear(hrp.Position, S.target)
			end
			keep = not stuck and margin(S.target, threats) >= SAFE and open
		end
		if keep then
			S.state = string.format("Dodging · %d threats", #threats)
			return
		end
		if hereScore < SAFE and pt then
			if S.mode ~= "dodge" then
				S.dodges = S.dodges + 1
			end
			S.moving = true
			S.mode = "dodge"
			S.target = pt
			S.item = nil
			S.progressT = now
			S.progressD = nil
			S.state = string.format("Dodging · %d threats", #threats)
			return
		end
		if S.mode == "dodge" and hereScore < CALM then
			S.state = string.format("Dodging · %d threats", #threats)
			return
		end
	end
	if S.mode == "dodge" then
		stopMove(hum)
	end

	-- 2) collecting when it is safe enough
	if S.collectOn then
		local bombHead = char:FindFirstChild("BombHead") ~= nil
		-- keep the current item while it is still there and safe
		if not hcRound and S.mode == "item" and S.item and itemAvailable(S.item, now, bombHead) then
			local pos = instPos(S.item)
			local stuck = S.progressT and now - S.progressT > 1.5
			if pos and not stuck and (#threats == 0 or margin(pos, threats) >= 4) then
				S.state = "Collecting " .. (ITEM_BY_KEY[S.item.Name] and ITEM_BY_KEY[S.item.Name].Name or S.item.Name)
				return
			end
			if stuck then
				S.skip[S.item] = now + 20
				report("stuck going to " .. S.item.Name .. " (skipping 20s)")
			end
		end
		-- items whose physics we own can simply be pulled onto us
		if S.bringOn and not (S.pauseMeddle and now < S.pauseMeddle) then
			local n = 0
			for _, it in ipairs(Bombs:GetChildren()) do
				if n >= 3 then
					break
				end
				if itemAvailable(it, now, bombHead) and not S.tries[it] then
					local part = it:IsA("BasePart") and it or (it:IsA("Model") and (it.PrimaryPart or it:FindFirstChildWhichIsA("BasePart")))
					if SHIELD_KEYS[it.Name] then
						-- touchItem below registers it in S.tries, so the next shield waits
						if shieldPending() then
							part = nil
						end
					end
					if part and not part.Anchored and isnetworkowner(part) then
						n = n + 1
						if it:IsA("Model") then
							it:PivotTo(hrp.CFrame)
						else
							part.CFrame = hrp.CFrame
						end
						part.AssemblyLinearVelocity = Vector3.zero
						S.brought = S.brought + 1
						touchItem(hrp, it, now)
					end
				end
			end
		end
		local o, d = nil, nil
		if not hcRound then
			o, d = findItem(hrp, threats, now, bombHead)
		end
		if o then
			S.moving = true
			S.mode = "item"
			S.item = o
			S.target = nil
			S.progressT = now
			S.progressD = nil
			S.state = string.format("Collecting %s (%.0f studs)", ITEM_BY_KEY[o.Name] and ITEM_BY_KEY[o.Name].Name or o.Name, d)
			return
		end
	end
	if S.mode == "item" then
		stopMove(hum)
	end
	if S.flyOn and not S.moving then
		local here = hrp.Position
		local fy = floorBelow(here)
		if (fy and here.Y > fy + MAX_ALT + 5) or here.Y > ceilingY() + 5 then
			fy = fy or (ceilingY() - 50)
			local goal = Vector3.new(here.X, fy + (hcRound and 45 or 4), here.Z)
			S.moving = true
			S.mode = "dodge"
			S.target = goal
			S.progressT = now
			S.progressD = nil
			S.state = "Coming back down to the play area"
			return
		end
	end
	if hcRound and S.flyOn and not S.moving then
		local here = hrp.Position
		-- only climb over a real floor within 80 studs: with no floor found the old code
		-- treated "here" as the floor and kept climbing (reached Y=332 on 2026-10-22)
		local down = workspace:Raycast(here, Vector3.new(0, -80, 0), rayParams)
		local floorY = down and down.Position.Y
		local wantY = floorY and (floorY + 45) or here.Y
		if floorY and here.Y < wantY - 3 then
			-- stay under any ceiling (cave maps)
			local up = workspace:Raycast(here, Vector3.new(0, wantY - here.Y + 4, 0), rayParams)
			if up then
				wantY = up.Position.Y - 4
			end
			wantY = math.min(wantY, ceilingY())
			local goal = Vector3.new(here.X, wantY, here.Z)
			if wantY > here.Y + 2 and (#threats == 0 or margin(goal, threats) >= SAFE) then
				S.moving = true
				S.mode = "dodge"
				S.target = goal
				S.progressT = now
				S.progressD = nil
				S.state = "Hardcore · climbing to safe altitude"
				return
			end
		end
	end
	S.state = (hcRound and "Hardcore · " or "") .. (#threats > 0 and string.format("Safe · %d threats nearby", #threats) or "Safe · nothing to do")
end))

-- Glide (CFrame per Stepped, before physics). Walking measured 22.8 studs/s and got caught;
-- Humanoid:Move from Heartbeat is wiped by ControlModule (measured 2026-10-21).
local GLIDE_SPEED = 65
local GLIDE_ESCAPE = 110

table.insert(S.conns, RunService.Stepped:Connect(function(_, dt)
	if not S.running then
		return
	end
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hum or not hrp or hum.Health <= 0 then
		return
	end
	local now = os.clock()

	if S.arrived and now - S.arrived.t > 0.6 then
		local off = (hrp.Position - S.arrived.p).Magnitude
		if off > 6 and not S.moving then
			S.snapbacks = S.snapbacks + 1
			report(string.format("SNAPBACK %.1f studs after glide", off))
		end
		S.arrived = nil
	end

	-- bombs whose physics we own: fall slowly, and get pushed out of blast range
	if S.bombCtlOn and hum:HasTag("PlayingHumanoid") and not (S.pauseMeddle and now < S.pauseMeddle) then
		for _, o in ipairs(Bombs:GetChildren()) do
			if isBomb(o) then
				local part = o:IsA("BasePart") and o or (o:IsA("Model") and (o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart")))
				if part and not part.Anchored and isnetworkowner(part) and S.voidOn and S.voidAllowed then
					-- below FallenPartsDestroyHeight the owner's physics deletes the part
					local voidY = workspace.FallenPartsDestroyHeight - 100
					if o:IsA("Model") then
						o:PivotTo(CFrame.new(part.Position.X, voidY, part.Position.Z))
					else
						part.CFrame = CFrame.new(part.Position.X, voidY, part.Position.Z)
					end
					part.AssemblyLinearVelocity = Vector3.zero
					if not S.voidSeen[o] then
						S.voidSeen[o] = os.clock()
						S.voided = S.voided + 1
					end
				elseif part and not part.Anchored and isnetworkowner(part) then
					local v = part.AssemblyLinearVelocity
					if v.Y < -10 then
						part.AssemblyLinearVelocity = Vector3.new(v.X, -10, v.Z)
						if not S.slowSeen[o] then
							S.slowSeen[o] = true
							S.slowed = S.slowed + 1
						end
					end
					local pos = part.Position
					local flat = Vector3.new(pos.X - hrp.Position.X, 0, pos.Z - hrp.Position.Z)
					local keepDist = bombRadius(o) + 10
					local nm = o.Name
					-- homing rockets turn back at us after every push; keep them very far
					if string.find(nm, "Rocket") or string.find(nm, "Homing") or string.find(nm, "Chaser") then
						keepDist = 150
					end
					if flat.Magnitude < keepDist and math.abs(pos.Y - hrp.Position.Y) < keepDist then
						local dir = flat.Magnitude > 0.1 and flat.Unit or Vector3.new(1, 0, 0)
						local newPos = Vector3.new(hrp.Position.X, pos.Y, hrp.Position.Z) + dir * keepDist
						if o:IsA("Model") then
							o:PivotTo(CFrame.new(newPos) * o:GetPivot().Rotation)
						else
							part.CFrame = CFrame.new(newPos) * part.CFrame.Rotation
						end
						if not S.pushSeen[o] then
							S.pushSeen[o] = true
							S.pushed = S.pushed + 1
						end
					end
				end
			end
		end
	end

	if not S.moving then
		-- hover where the last move ended instead of dropping back to the floor
		if S.flyOn and S.hold and hum:HasTag("PlayingHumanoid") then
			-- a jump we did not make = the game teleported us (round end, respawn): let go,
			-- or the hold pins us in the arena forever (stuck a whole hour on 2026-10-22)
			if (hrp.Position - S.hold).Magnitude > 15 then
				S.hold = nil
				report("hover released: the game moved the character")
			else
				hrp.CFrame = CFrame.new(S.hold) * hrp.CFrame.Rotation
				hrp.AssemblyLinearVelocity = Vector3.zero
			end
		end
		return
	end
	local goal
	if S.mode == "item" and S.item then
		goal = instPos(S.item)
		if not goal then
			stopMove(hum)
			return
		end
		if (goal - hrp.Position).Magnitude < 6 then
			touchItem(hrp, S.item, now)
		end
	elseif S.mode == "dodge" and S.target then
		if S.flyOn then
			goal = S.target
		else
			goal = Vector3.new(S.target.X, S.target.Y - 3 + hum.HipHeight + hrp.Size.Y / 2, S.target.Z)
		end
	else
		return
	end
	local delta = goal - hrp.Position
	local dist = delta.Magnitude
	local flatDist = Vector3.new(delta.X, 0, delta.Z).Magnitude
	if S.mode == "dodge" and flatDist < 1.5 and (not S.flyOn or dist < 1.5) then
		S.arrived = { t = now, p = hrp.Position }
		S.hold = hrp.Position
		stopMove(hum)
		return
	end
	S.hold = hrp.Position
	if not S.progressD or dist < S.progressD - 1 then
		S.progressD = dist
		S.progressT = now
	end
	if dist < 0.5 then
		hrp.AssemblyLinearVelocity = Vector3.zero
		return
	end
	-- escape speed when standing inside a predicted blast (Grimbell runs ~22-30 studs/s)
	local speed = (S.mode == "dodge" and (S.hereScore or 99) < 0) and GLIDE_ESCAPE or GLIDE_SPEED
	local stepLen = math.min(speed * dt, dist)
	hrp.CFrame = CFrame.new(hrp.Position + delta.Unit * stepLen) * hrp.CFrame.Rotation
	hrp.AssemblyLinearVelocity = Vector3.zero
end))

-- Roblox's 20-minute idle kick: fake an input on every Idled and every 4 minutes.
-- (The game's own AFK flag, NotThere, is handled by the __namecall hook above.)
do
	local VirtualUser = game:GetService("VirtualUser")
	local function poke()
		pcall(function()
			VirtualUser:CaptureController()
			VirtualUser:ClickButton2(Vector2.new())
		end)
	end
	table.insert(S.conns, LocalPlayer.Idled:Connect(poke))
	task.spawn(function()
		while S.running do
			task.wait(240)
			if S.running then
				poke()
			end
		end
	end)
end

-- status children the game adds to the character (burned/poisoned/zapped...), for hit reports
local function watchChar(char)
	table.insert(S.conns, char.ChildAdded:Connect(function(c)
		if not c:IsA("BasePart") and not c:IsA("Accessory") and not c:IsA("Script") then
			S.status[c.Name] = os.clock()
		end
	end))
end
if LocalPlayer.Character then
	watchChar(LocalPlayer.Character)
end
table.insert(S.conns, LocalPlayer.CharacterAdded:Connect(watchChar))

getgenv().SBSHubStop = function()
	if not S.running then
		return
	end
	S.running = false
	for _, c in ipairs(S.conns) do
		c:Disconnect()
	end
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum:Move(Vector3.zero, false)
	end
	getgenv().SBSHubStop = nil
	if win.Alive then
		win:Destroy()
	end
	report("stopped")
end
getgenv().SBSHubState = S

report("started")
win:Notify("Aimia - Super Bomb Survival loaded · press " .. win:GetToggleKey().Name .. " to show / hide", "Good", 10)
