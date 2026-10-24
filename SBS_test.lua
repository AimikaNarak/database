local P = ((function()
		local P = {};
		local j = game:GetService("TweenService");
		local Y = game:GetService("UserInputService");
		local X = game:GetService("RunService");
		local M = game:GetService("Players");
		P.Theme = {
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
				Gold = Color3.fromRGB(255, 196, 64),
				Hardcore = Color3.fromRGB(176, 112, 255),
				Font = Enum.Font.GothamMedium,
				FontBold = Enum.Font.GothamBold,
				Radius = 8,
			};
		P.Motion = {
				Fast = TweenInfo.new(.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				Base = TweenInfo.new(.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				Slow = TweenInfo.new(.38, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				Spring = TweenInfo.new(.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			};
		local z = P.Theme;
		local o = P.Motion;
		local function q(P, j, Y)
			local X = Instance.new(P);
			local M = nil;
			for P, j in pairs(j or {}) do
				if P == "Parent" then
					M = j;
				else
					X[P] = j;
				end;
			end;
			for P, j in ipairs(Y or {}) do
				j.Parent = X;
			end;
			if M then
				X.Parent = M;
			end;
			return X;
		end;
		P.new = q;
		local function S(P, Y, X)
			local M = j:Create(P, Y, X);
			M:Play();
			return M;
		end;
		P.tween = S;
		local function W(P)
			return q("UICorner", { CornerRadius = UDim.new(0, P or z.Radius) });
		end;
		local function O(P, j)
			return q("UIStroke", {
				Color = P or z.Stroke,
				Transparency = j or 0,
				Thickness = 1,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			});
		end;
		local function V(P)
			return q("UIPadding", {
				PaddingTop = UDim.new(0, P),
				PaddingBottom = UDim.new(0, P),
				PaddingLeft = UDim.new(0, P),
				PaddingRight = UDim.new(0, P),
			});
		end;
		local function e(P, j, Y, X)
			return q("TextLabel", {
				BackgroundTransparency = 1,
				Text = P,
				TextSize = j or 13,
				TextColor3 = Y or z.Text,
				Font = X or z.Font,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Center,
				Size = UDim2.new(1, 0, 1, 0),
			});
		end;
		local function v(P)
			return P.UserInputType == Enum.UserInputType.MouseButton1 or P.UserInputType == Enum.UserInputType.Touch;
		end;
		local function f(P)
			return P.UserInputType == Enum.UserInputType.MouseMovement or P.UserInputType == Enum.UserInputType.Touch;
		end;
		local function n()
			if type(gethui) == "function" then
				local P, j = pcall(gethui);
				if P and j then
					return j;
				end;
			end;
			local P, j = pcall(function()
					return game:GetService("CoreGui");
				end);
			if P and j then
				return j;
			end;
			return M.LocalPlayer:WaitForChild("PlayerGui");
		end;
		local function C(P)
			local j = Y:GetMouseLocation();
			local X = P.AbsolutePosition;
			local M = math.max(P.AbsoluteSize.X, P.AbsoluteSize.Y) * 2.2;
			local o = q("Frame", {
					BackgroundColor3 = z.Text,
					BackgroundTransparency = .86,
					AnchorPoint = Vector2.new(.5, .5),
					Position = UDim2.fromOffset(j.X - X.X, j.Y - X.Y),
					Size = UDim2.fromOffset(0, 0),
					ZIndex = P.ZIndex + 1,
					Parent = P,
				}, { W(9999) });
			S(o, TweenInfo.new(.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(M, M), BackgroundTransparency = 1 });
			task.delay(.55, function()
				o:Destroy();
			end);
		end;
		P.ripple = C;
		function P.icon(P, j)
			if not P then
				return nil;
			end;
			for P, j in ipairs(j:GetChildren()) do
				j:Destroy();
			end;
			if P.Image then
				return q("ImageLabel", {
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 1),
					Image = P.Image,
					ImageRectOffset = P.Offset or Vector2.zero,
					ImageRectSize = P.Size or Vector2.zero,
					ImageColor3 = P.Color or Color3.new(1, 1, 1),
					ScaleType = Enum.ScaleType.Fit,
					Parent = j,
				});
			end;
			local Y = q("Frame", { BackgroundColor3 = P.Color or z.Elevated, Size = UDim2.fromScale(1, 1), Parent = j }, { W(9999), O(z.Stroke, .2) });
			local X = e(P.Glyph or "?", math.max(10, math.floor(j.Size.Y.Offset * .5 + .5)), z.Text, z.FontBold);
			X.TextXAlignment = Enum.TextXAlignment.Center;
			X.Parent = Y;
			return Y;
		end;
		function P.viewport(P, j)
			local Y, X = pcall(function()
					return j:Clone();
				end);
			if not Y or not X then
				return nil;
			end;
			for P, j in ipairs(X:GetDescendants()) do
				if j:IsA("LuaSourceContainer") or j:IsA("BillboardGui") or j:IsA("SurfaceGui") or j:IsA("Sound") or j:IsA("ParticleEmitter") or j:IsA("Light") or j:IsA("BodyMover") or j:IsA("Constraint") or j:IsA("TouchTransmitter") or j:IsA("Highlight") then
					j:Destroy();
				elseif j:IsA("BasePart") then
					j.Anchored = true;
					if j.Name == "Hitbox" then
						j.Transparency = 1;
					end;
				end;
			end;
			local M, z;
			if X:IsA("BasePart") then
				X.Anchored = true;
				M, z = X.CFrame, X.Size;
			elseif X:IsA("Model") then
				M, z = X:GetBoundingBox();
			else
				X:Destroy();
				return nil;
			end;
			for P, j in ipairs(P:GetChildren()) do
				j:Destroy();
			end;
			local o = q("ViewportFrame", {
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 1),
					Ambient = Color3.fromRGB(200, 200, 200),
					LightColor = Color3.new(1, 1, 1),
					LightDirection = Vector3.new(-1, -1, -0.5),
					Parent = P,
				});
			local S = q("Camera", { FieldOfView = 40, Parent = o });
			o.CurrentCamera = S;
			X.Parent = o;
			local W = z.Magnitude / 2;
			local O = (W / math.tan(math.rad(20))) * 1.05;
			local V = (Vector3.new(1, .8, 1)).Unit;
			S.CFrame = CFrame.lookAt(M.Position + V * O, M.Position);
			return o;
		end;
		function P.Window(j)
			j = j or {};
			local M = j.Title or "Script";
			local D = j.Size or UDim2.fromOffset(520, 340);
			local i = j.ToggleKey or Enum.KeyCode.RightControl;
			local K = "UIFX_" .. M;
			local y = { Alive = true, Tabs = {} };
			local k = {};
			local A = {};
			local p = {};
			local function T(P)
				table.insert(k, P);
				return P;
			end;
			y.track = T;
			local B = n();
			local x = B:FindFirstChild(K);
			if x then
				x:Destroy();
			end;
			local c = q("ScreenGui", {
					Name = K,
					ResetOnSpawn = false,
					IgnoreGuiInset = true,
					ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
					DisplayOrder = 999,
				});
			c.Parent = B;
			y.Gui = c;
			local G = q("CanvasGroup", {
					AnchorPoint = Vector2.new(.5, .5),
					Position = UDim2.fromScale(.5, .5),
					Size = D,
					BackgroundColor3 = z.Bg,
					GroupTransparency = 1,
					Parent = c,
				}, { W(z.Radius + 2), O(z.Stroke) });
			local a = q("UIScale", { Scale = .94, Parent = G });
			y.Root = G;
			local w = q("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 38), Parent = G });
			local l = e(M, 14, z.Text, z.FontBold);
			l.Position = UDim2.fromOffset(14, 0);
			l.Size = UDim2.new(1, -100, 1, 0);
			l.Parent = w;
			q("Frame", {
				BackgroundColor3 = z.Stroke,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 1, -1),
				Size = UDim2.new(1, 0, 0, 1),
				Parent = w,
			});
			local function L(P, j, Y)
				local X = q("TextButton", {
						AutoButtonColor = false,
						AnchorPoint = Vector2.new(1, .5),
						Position = UDim2.new(1, j, .5, 0),
						Size = UDim2.fromOffset(26, 26),
						BackgroundColor3 = z.Elevated,
						BackgroundTransparency = 1,
						Text = P,
						TextSize = 16,
						TextColor3 = z.SubText,
						Font = z.FontBold,
						Parent = w,
					}, { W(6) });
				T(X.MouseEnter:Connect(function()
					S(X, o.Fast, { BackgroundTransparency = 0, TextColor3 = Y });
				end));
				T(X.MouseLeave:Connect(function()
					S(X, o.Fast, { BackgroundTransparency = 1, TextColor3 = z.SubText });
				end));
				return X;
			end;
			local Z = L("\195\151", -8, z.Bad);
			local t = L("\226\128\147", -38, z.Text);
			do
				local P = false;
				local j, X;
				T(w.InputBegan:Connect(function(Y)
					if v(Y) then
						P = true;
						j = Y.Position;
						X = G.Position;
					end;
				end));
				T(Y.InputEnded:Connect(function(j)
					if v(j) then
						P = false;
					end;
				end));
				T(Y.InputChanged:Connect(function(Y)
					if P and f(Y) then
						local P = Y.Position - j;
						S(G, o.Fast, { Position = UDim2.new(X.X.Scale, X.X.Offset + P.X, X.Y.Scale, X.Y.Offset + P.Y) });
					end;
				end));
			end;
			local F = j.Nav == "top";
			local E, d, U, R;
			if F then
				local P = q("Frame", {
						BackgroundColor3 = z.Panel,
						Position = UDim2.fromOffset(12, 46),
						Size = UDim2.new(1, -24, 0, 36),
						Parent = G,
					}, { W(9999), O(z.Stroke, .3) });
				d = q("Frame", {
						BackgroundColor3 = z.Accent,
						Position = UDim2.fromOffset(4, 4),
						Size = UDim2.fromOffset(0, 28),
						Visible = false,
						Parent = P,
					}, { W(9999) });
				q("UIGradient", { Rotation = 90, Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(200, 200, 225)), Parent = d });
				U = q("Frame", {
						BackgroundTransparency = 1,
						Position = UDim2.fromOffset(4, 4),
						Size = UDim2.new(1, -8, 1, -8),
						ZIndex = 2,
						Parent = P,
					});
				q("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(0, 4),
					SortOrder = Enum.SortOrder.LayoutOrder,
					Parent = U,
				});
				E = U;
				R = q("Frame", {
						BackgroundTransparency = 1,
						Position = UDim2.fromOffset(0, 88),
						Size = UDim2.new(1, 0, 1, -88),
						Parent = G,
					});
			else
				E = q("Frame", {
						BackgroundColor3 = z.Panel,
						BorderSizePixel = 0,
						Position = UDim2.fromOffset(0, 38),
						Size = UDim2.new(0, 132, 1, -38),
						Parent = G,
					});
				q("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = E });
				q("UIPadding", {
					PaddingTop = UDim.new(0, 8),
					PaddingLeft = UDim.new(0, 8),
					PaddingRight = UDim.new(0, 8),
					Parent = E,
				});
				d = q("Frame", {
						BackgroundColor3 = z.Accent,
						BorderSizePixel = 0,
						Size = UDim2.fromOffset(3, 18),
						Position = UDim2.fromOffset(2, 14),
						Visible = false,
						Parent = G,
					}, { W(2) });
				R = q("Frame", {
						BackgroundTransparency = 1,
						Position = UDim2.fromOffset(132, 38),
						Size = UDim2.new(1, -132, 1, -38),
						Parent = G,
					});
			end;
			local u = false;
			local g = false;
			function y.Show(P)
				u = true;
				c.Enabled = true;
				S(G, o.Slow, { GroupTransparency = 0 });
				S(a, o.Spring, { Scale = 1 });
			end;
			function y.Hide(P)
				u = false;
				S(G, o.Base, { GroupTransparency = 1 });
				local j = S(a, o.Base, { Scale = .94 });
				j.Completed:Connect(function()
					if not u and y.Alive then
						c.Enabled = false;
					end;
				end);
			end;
			function y.Toggle(P)
				if u then
					y:Hide();
				else
					y:Show();
				end;
			end;
			function y.Destroy(P)
				if not y.Alive then
					return;
				end;
				y.Alive = false;
				for P, j in ipairs(k) do
					j:Disconnect();
				end;
				table.clear(k);
				if j.OnClose then
					task.spawn(j.OnClose);
				end;
				local Y = S(G, o.Base, { GroupTransparency = 1 });
				S(a, o.Base, { Scale = .9 });
				Y.Completed:Connect(function()
					c:Destroy();
				end);
			end;
			T(Z.MouseButton1Click:Connect(function()
				y:Destroy();
			end));
			T(t.MouseButton1Click:Connect(function()
				g = not g;
				if g then
					S(G, o.Base, { Size = UDim2.new(D.X.Scale, D.X.Offset, 0, 38) });
				else
					S(G, o.Spring, { Size = D });
				end;
			end));
			T(Y.InputBegan:Connect(function(P, j)
				if not j and (not y.Capturing and P.KeyCode == i) then
					y:Toggle();
				end;
			end));
			function y.SetToggleKey(j, P)
				i = P;
			end;
			function y.GetToggleKey(P)
				return i;
			end;
			T(X.Heartbeat:Connect(function()
				if not c.Parent then
					y:Destroy();
					return;
				end;
				for P, j in ipairs(A) do
					if j.dirty then
						j.dirty = false;
						j.body.Text = j.text;
						j.body.TextColor3 = j.color;
					end;
				end;
				for P, j in ipairs(p) do
					if j.dirty then
						j.dirty = false;
						local P, Y = pcall(j.apply);
						if not P then
							print("[UIFX] update error: " .. tostring(Y));
						end;
					end;
				end;
			end));
			local r = q("Frame", {
					BackgroundTransparency = 1,
					AnchorPoint = Vector2.new(1, 1),
					Position = UDim2.new(1, -16, 1, -16),
					Size = UDim2.fromOffset(280, 400),
					Parent = c,
				});
			q("UIListLayout", {
				Padding = UDim.new(0, 8),
				VerticalAlignment = Enum.VerticalAlignment.Bottom,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Parent = r,
			});
			local s = 0;
			function y.Notify(X, P, j, Y)
				Y = Y or 3;
				local M = z[j or "Accent"] or z.Accent;
				s = s + 1;
				local V = q("Frame", {
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 0, 0),
						LayoutOrder = s,
						ClipsDescendants = false,
						Parent = r,
					});
				local v = q("Frame", {
						BackgroundColor3 = z.Panel,
						Position = UDim2.fromOffset(300, 0),
						Size = UDim2.new(1, 0, 1, 0),
						Parent = V,
					}, { W(), O(z.Stroke) });
				q("Frame", {
					BackgroundColor3 = M,
					BorderSizePixel = 0,
					Position = UDim2.fromOffset(0, 8),
					Size = UDim2.new(0, 3, 1, -16),
					Parent = v,
				}, { W(2) });
				local f = e(P, 13, z.Text);
				f.TextWrapped = true;
				f.Position = UDim2.fromOffset(14, 0);
				f.Size = UDim2.new(1, -24, 1, -4);
				f.Parent = v;
				local n = q("Frame", {
						BackgroundColor3 = M,
						BackgroundTransparency = .4,
						BorderSizePixel = 0,
						AnchorPoint = Vector2.new(0, 1),
						Position = UDim2.new(0, 0, 1, 0),
						Size = UDim2.new(1, 0, 0, 2),
						Parent = v,
					});
				S(V, o.Base, { Size = UDim2.new(1, 0, 0, 52) });
				S(v, o.Spring, { Position = UDim2.fromOffset(0, 0) });
				S(n, TweenInfo.new(Y, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 0, 2) });
				task.delay(Y, function()
					local P = S(v, o.Base, { Position = UDim2.fromOffset(300, 0) });
					P.Completed:Wait();
					local j = S(V, o.Base, { Size = UDim2.new(1, 0, 0, 0) });
					j.Completed:Wait();
					V:Destroy();
				end);
			end;
			local function I(P, ...)
				if not P then
					return;
				end;
				local j = table.pack(...);
				task.spawn(function()
					local Y, X = pcall(P, table.unpack(j, 1, j.n));
					if not Y then
						print("[UIFX] callback error: " .. tostring(X));
						y:Notify(tostring(X), "Bad", 5);
					end;
				end);
			end;
			local function h(P)
				for j, Y in ipairs(y.Tabs) do
					local X = Y == P;
					Y.Page.Visible = X;
					if F then
						S(Y.TabButton, o.Fast, { TextColor3 = X and z.Text or z.SubText });
					else
						S(Y.TabButton, o.Fast, { BackgroundTransparency = X and 0 or 1, TextColor3 = X and z.Text or z.SubText });
					end;
				end;
				d.Visible = true;
				if F then
					local j = a.Scale;
					local Y = ((P.TabButton.AbsolutePosition.X - U.AbsolutePosition.X)) / j + 4;
					local X = P.TabButton.AbsoluteSize.X / j;
					S(d, o.Spring, { Position = UDim2.fromOffset(Y, 4), Size = UDim2.fromOffset(X, 28) });
				else
					local j = P.TabButton.AbsolutePosition.Y - G.AbsolutePosition.Y;
					S(d, o.Spring, { Position = UDim2.fromOffset(10, j / a.Scale + 7) });
				end;
				P.Page.Position = UDim2.fromOffset(0, 8);
				S(P.Page, o.Base, { Position = UDim2.fromOffset(0, 0) });
			end;
			function y.Tab(X, j)
				local M = {};
				if F then
					M.TabButton = q("TextButton", {
							AutoButtonColor = false,
							BackgroundTransparency = 1,
							Size = UDim2.new(0, 0, 1, 0),
							AutomaticSize = Enum.AutomaticSize.X,
							Text = j,
							TextSize = 13,
							TextColor3 = z.SubText,
							Font = z.FontBold,
							LayoutOrder = #y.Tabs + 1,
							ZIndex = 3,
							Parent = E,
						});
					q("UIPadding", { PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16), Parent = M.TabButton });
				else
					M.TabButton = q("TextButton", {
							AutoButtonColor = false,
							BackgroundColor3 = z.Elevated,
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 0, 32),
							Text = "      " .. j,
							TextXAlignment = Enum.TextXAlignment.Left,
							TextSize = 13,
							TextColor3 = z.SubText,
							Font = z.Font,
							LayoutOrder = #y.Tabs + 1,
							Parent = E,
						}, { W(6) });
				end;
				M.Page = q("ScrollingFrame", {
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Size = UDim2.new(1, 0, 1, 0),
						CanvasSize = UDim2.new(),
						AutomaticCanvasSize = Enum.AutomaticSize.Y,
						ScrollBarThickness = 3,
						ScrollBarImageColor3 = z.Stroke,
						Visible = false,
						Parent = R,
					}, { V(10) });
				q("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = M.Page });
				table.insert(y.Tabs, M);
				local n = 0;
				T(M.TabButton.MouseButton1Click:Connect(function()
					h(M);
				end));
				local function D(P)
					n = n + 1;
					return q("Frame", {
						BackgroundColor3 = z.Panel,
						Size = UDim2.new(1, 0, 0, P or 38),
						LayoutOrder = n,
						Parent = M.Page,
					}, { W(), O(z.Stroke, .3) });
				end;
				local function i(P)
					T(P.MouseEnter:Connect(function()
						S(P, o.Fast, { BackgroundColor3 = z.Elevated });
					end));
					T(P.MouseLeave:Connect(function()
						S(P, o.Fast, { BackgroundColor3 = z.Panel });
					end));
				end;
				local function K(P, j, Y)
					return P:Lerp(j, Y);
				end;
				local function k(P, j, Y)
					local X = q("Frame", {
							BackgroundColor3 = K(z.Panel, Y, .18),
							Size = UDim2.fromOffset(0, 20),
							AutomaticSize = Enum.AutomaticSize.X,
							Parent = P,
						}, { W(9999), O(Y, .55) });
					q("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 9), Parent = X });
					q("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						Padding = UDim.new(0, 6),
						Parent = X,
					});
					local M = q("Frame", { BackgroundColor3 = Y, Size = UDim2.fromOffset(6, 6), Parent = X }, { W(9999) });
					local o = e(j, 11, Y, z.FontBold);
					o.Size = UDim2.fromOffset(0, 20);
					o.AutomaticSize = Enum.AutomaticSize.X;
					o.Parent = X;
					return X, o, M;
				end;
				function M.Section(Y, P, j)
					n = n + 1;
					local X = e(string.upper(P), 11, j or z.SubText, z.FontBold);
					X.Size = UDim2.new(1, 0, 0, 22);
					X.LayoutOrder = n;
					X.Parent = M.Page;
					if j then
						q("UIPadding", { PaddingLeft = UDim.new(0, 10), Parent = X });
						q("Frame", {
							BackgroundColor3 = j,
							BorderSizePixel = 0,
							Position = UDim2.new(0, -10, .5, -6),
							Size = UDim2.fromOffset(3, 12),
							Parent = X,
						}, { W(2) });
					end;
					return X;
				end;
				function M.Keybind(V, P, j, X, M)
					local v = D(M and 52 or 38);
					local f = e(P, 13);
					f.Position = UDim2.fromOffset(12, M and 8 or 0);
					f.Size = UDim2.new(1, -150, 0, M and 18 or 38);
					f.Parent = v;
					if M then
						local P = e(M, 11, z.SubText);
						P.Position = UDim2.fromOffset(12, 27);
						P.Size = UDim2.new(1, -150, 0, 16);
						P.TextTruncate = Enum.TextTruncate.AtEnd;
						P.Parent = v;
					end;
					local n = q("TextButton", {
							AutoButtonColor = false,
							AnchorPoint = Vector2.new(1, .5),
							Position = UDim2.new(1, -12, .5, 0),
							Size = UDim2.fromOffset(0, 28),
							AutomaticSize = Enum.AutomaticSize.X,
							BackgroundColor3 = z.Elevated,
							Text = "",
							Parent = v,
						}, { W(8), O(z.Accent, .4) });
					q("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), Parent = n });
					local C = e("", 12, z.Text, z.FontBold);
					C.Size = UDim2.fromOffset(0, 28);
					C.AutomaticSize = Enum.AutomaticSize.X;
					C.Parent = n;
					local i = { Value = j };
					local function k()
						C.Text = i.Value and i.Value.Name or "None";
					end;
					k();
					local A = false;
					T(n.MouseButton1Click:Connect(function()
						if A then
							return;
						end;
						A = true;
						y.Capturing = true;
						C.Text = "press a key\226\128\166";
						S(n, o.Fast, { BackgroundColor3 = K(z.Elevated, z.Accent, .35) });
						local P;
						P = Y.InputBegan:Connect(function(j)
								if j.UserInputType ~= Enum.UserInputType.Keyboard then
									return;
								end;
								P:Disconnect();
								if j.KeyCode ~= Enum.KeyCode.Escape then
									i.Value = j.KeyCode;
									I(X, j.KeyCode);
								end;
								k();
								S(n, o.Fast, { BackgroundColor3 = z.Elevated });
								task.delay(.2, function()
									A = false;
									y.Capturing = false;
								end);
							end);
						T(P);
					end));
					return i;
				end;
				function M.DangerToggle(f, P, j, Y, X, V, v)
					v = v or {};
					local C = v.Color or z.Bad;
					n = n + 1;
					local D = q("Frame", {
							BackgroundColor3 = K(z.Panel, C, .07),
							Size = UDim2.new(1, 0, 0, v.Note and 80 or 64),
							LayoutOrder = n,
							Parent = M.Page,
						}, { W(10) });
					local i = q("UIStroke", {
							Color = C,
							Transparency = .55,
							Thickness = 1,
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
							Parent = D,
						});
					q("UIGradient", { Rotation = 0, Color = ColorSequence.new(K(Color3.new(1, 1, 1), C, .12), Color3.new(1, 1, 1)), Parent = D });
					local A = q("Frame", {
							BackgroundColor3 = C,
							Position = UDim2.fromOffset(12, 14),
							Size = UDim2.fromOffset(36, 36),
							Parent = D,
						}, { W(10) });
					local B = e(v.Glyph or "!", 20, z.Text, z.FontBold);
					B.TextXAlignment = Enum.TextXAlignment.Center;
					B.Parent = A;
					local x = q("Frame", {
							BackgroundTransparency = 1,
							Position = UDim2.fromOffset(60, 12),
							Size = UDim2.new(1, -130, 0, 20),
							Parent = D,
						});
					q("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						Padding = UDim.new(0, 8),
						SortOrder = Enum.SortOrder.LayoutOrder,
						Parent = x,
					});
					local c = e(P, 14, z.Text, z.FontBold);
					c.Size = UDim2.fromOffset(0, 20);
					c.AutomaticSize = Enum.AutomaticSize.X;
					c.LayoutOrder = 1;
					c.Parent = x;
					local G = k(x, V or "RISKY", C);
					G.LayoutOrder = 2;
					local a = e(X or "", 11, K(z.SubText, C, .35));
					a.Position = UDim2.fromOffset(60, 34);
					a.Size = UDim2.new(1, -130, 0, 16);
					a.TextTruncate = Enum.TextTruncate.AtEnd;
					a.Parent = D;
					local w;
					if v.Note then
						w = e("", 11, z.SubText, z.FontBold);
						w.Position = UDim2.fromOffset(60, 54);
						w.Size = UDim2.new(1, -130, 0, 16);
						w.TextTruncate = Enum.TextTruncate.AtEnd;
						w.Parent = D;
					end;
					local l = q("Frame", {
							AnchorPoint = Vector2.new(1, .5),
							Position = UDim2.new(1, -14, .5, 0),
							Size = UDim2.fromOffset(40, 22),
							BackgroundColor3 = z.Elevated,
							Parent = D,
						}, { W(9999), O(C, .5) });
					local L = q("Frame", {
							AnchorPoint = Vector2.new(0, .5),
							Position = UDim2.new(0, 3, .5, 0),
							Size = UDim2.fromOffset(16, 16),
							BackgroundColor3 = z.SubText,
							Parent = l,
						}, { W(9999) });
					local Z = q("TextButton", {
							BackgroundTransparency = 1,
							Size = UDim2.fromScale(1, 1),
							Text = "",
							Parent = D,
						});
					local t = { Value = false, Locked = false };
					local F;
					local E = nil;
					local d = { text = "", kind = nil, dirty = false };
					local U = { dirty = false };
					U.apply = function()
							if w then
								w.Text = d.text;
								w.TextColor3 = d.kind and z[d.kind] or z.SubText;
							end;
						end;
					table.insert(p, U);
					function t.SetNote(Y, P, j)
						d.text = tostring(P);
						d.kind = j;
						U.dirty = true;
					end;
					function t.SetLocked(Y, P, j)
						t.Locked = P and true or false;
						E = j;
						S(A, o.Base, { BackgroundColor3 = t.Locked and z.Elevated or C });
						B.Text = t.Locked and "X" or (v.Glyph or "!");
						S(l, o.Base, { BackgroundTransparency = t.Locked and .5 or 0 });
						if t.Locked and t.Value then
							t:Set(false, true);
						end;
					end;
					function t.Set(X, P, j)
						if P and t.Locked then
							y:Notify(E or "Not available here", "Warn", 4);
							return;
						end;
						t.Value = P and true or false;
						S(L, o.Spring, { Position = t.Value and UDim2.new(1, -19, .5, 0) or UDim2.new(0, 3, .5, 0), BackgroundColor3 = t.Value and z.Text or z.SubText });
						S(l, o.Base, { BackgroundColor3 = t.Value and C or z.Elevated });
						S(D, o.Base, { BackgroundColor3 = K(z.Panel, C, t.Value and .16 or .07) });
						if F then
							F:Cancel();
							F = nil;
						end;
						i.Transparency = t.Value and .1 or .55;
						i.Thickness = t.Value and 2 or 1;
						if t.Value then
							F = S(i, TweenInfo.new(.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Transparency = .65 });
						end;
						if not j then
							I(Y, t.Value);
						end;
					end;
					T(Z.MouseButton1Click:Connect(function()
						t:Set(not t.Value);
					end));
					t:Set(j, true);
					return t;
				end;
				function M.Button(Y, P, j)
					n = n + 1;
					local X = q("TextButton", {
							AutoButtonColor = false,
							ClipsDescendants = true,
							BackgroundColor3 = z.Panel,
							Size = UDim2.new(1, 0, 0, 38),
							Text = "",
							LayoutOrder = n,
							Parent = M.Page,
						}, { W(), O(z.Stroke, .3) });
					local V = e(P, 13);
					V.Position = UDim2.fromOffset(12, 0);
					V.Size = UDim2.new(1, -24, 1, 0);
					V.Parent = X;
					i(X);
					local v = false;
					local f = {};
					T(X.MouseButton1Click:Connect(function()
						C(X);
						if v then
							return;
						end;
						I(j);
					end));
					T(X.MouseButton1Down:Connect(function()
						S(X, o.Fast, { BackgroundColor3 = z.Stroke });
					end));
					function f.SetBusy(j, P)
						v = P;
						S(V, o.Fast, { TextTransparency = P and .5 or 0 });
					end;
					function f.SetText(j, P)
						V.Text = P;
					end;
					return f;
				end;
				function M.Toggle(M, P, j, Y, X)
					local V = D(X and 52 or 38);
					local v = e(P, 13);
					v.Position = UDim2.fromOffset(12, 0);
					v.Size = UDim2.new(1, -70, 1, 0);
					v.Parent = V;
					if X then
						v.Position = UDim2.fromOffset(12, 8);
						v.Size = UDim2.new(1, -70, 0, 18);
						local P = e(X, 11, z.SubText);
						P.Position = UDim2.fromOffset(12, 27);
						P.Size = UDim2.new(1, -70, 0, 16);
						P.TextTruncate = Enum.TextTruncate.AtEnd;
						P.Parent = V;
					end;
					local f = q("Frame", {
							AnchorPoint = Vector2.new(1, .5),
							Position = UDim2.new(1, -12, .5, 0),
							Size = UDim2.fromOffset(36, 20),
							BackgroundColor3 = z.Elevated,
							Parent = V,
						}, { W(9999), O(z.Stroke) });
					local n = q("Frame", {
							AnchorPoint = Vector2.new(0, .5),
							Position = UDim2.new(0, 3, .5, 0),
							Size = UDim2.fromOffset(14, 14),
							BackgroundColor3 = z.SubText,
							Parent = f,
						}, { W(9999) });
					local C = q("TextButton", {
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 1, 0),
							Text = "",
							Parent = V,
						});
					i(V);
					local K = { Value = false };
					function K.Set(X, P, j)
						K.Value = P and true or false;
						S(n, o.Spring, { Position = K.Value and UDim2.new(1, -17, .5, 0) or UDim2.new(0, 3, .5, 0), BackgroundColor3 = K.Value and z.Text or z.SubText });
						S(f, o.Base, { BackgroundColor3 = K.Value and z.Accent or z.Elevated });
						if not j then
							I(Y, K.Value);
						end;
					end;
					T(C.MouseButton1Click:Connect(function()
						K:Set(not K.Value);
					end));
					K:Set(j, true);
					if j then
						I(Y, true);
					end;
					return K;
				end;
				function M.Slider(n, P, j, X, M, O, V)
					O = O or 1;
					local C = D(54);
					local i = e(P, 13);
					i.Position = UDim2.fromOffset(12, 6);
					i.Size = UDim2.new(1, -90, 0, 18);
					i.Parent = C;
					local K = e("", 13, z.SubText);
					K.TextXAlignment = Enum.TextXAlignment.Right;
					K.Position = UDim2.new(1, -82, 0, 6);
					K.Size = UDim2.fromOffset(70, 18);
					K.Parent = C;
					local y = q("Frame", {
							Position = UDim2.new(0, 12, 0, 34),
							Size = UDim2.new(1, -24, 0, 6),
							BackgroundColor3 = z.Elevated,
							Parent = C,
						}, { W(9999) });
					local k = q("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = z.Accent, Parent = y }, { W(9999) });
					local A = q("Frame", {
							AnchorPoint = Vector2.new(.5, .5),
							Position = UDim2.fromScale(0, .5),
							Size = UDim2.fromOffset(12, 12),
							BackgroundColor3 = z.Text,
							Parent = y,
						}, { W(9999) });
					local p = { Value = M or j };
					local function B(P)
						local Y = ((p.Value - j)) / ((X - j));
						local M = P and TweenInfo.new(0) or o.Fast;
						S(k, M, { Size = UDim2.fromScale(Y, 1) });
						S(A, M, { Position = UDim2.fromScale(Y, .5) });
						K.Text = tostring(p.Value);
					end;
					function p.Set(M, P, Y)
						P = math.clamp(P, j, X);
						P = j + math.floor(((P - j)) / O + .5) * O;
						if P == p.Value and not Y then
							return;
						end;
						p.Value = P;
						B(false);
						if not Y then
							I(V, P);
						end;
					end;
					local x = false;
					local function c()
						local P = (Y:GetMouseLocation()).X;
						local M = math.clamp(((P - y.AbsolutePosition.X)) / y.AbsoluteSize.X, 0, 1);
						p:Set(j + ((X - j)) * M);
					end;
					T(C.InputBegan:Connect(function(P)
						if v(P) then
							x = true;
							S(A, o.Fast, { Size = UDim2.fromOffset(16, 16) });
							c();
						end;
					end));
					T(Y.InputEnded:Connect(function(P)
						if x and v(P) then
							x = false;
							S(A, o.Fast, { Size = UDim2.fromOffset(12, 12) });
						end;
					end));
					T(Y.InputChanged:Connect(function(P)
						if x and f(P) then
							c();
						end;
					end));
					B(true);
					return p;
				end;
				function M.Dropdown(M, P, j, Y, X)
					local O = D(38);
					O.ClipsDescendants = true;
					local V = q("TextButton", {
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 0, 38),
							Text = "",
							Parent = O,
						});
					local v = e(P, 13);
					v.Position = UDim2.fromOffset(12, 0);
					v.Size = UDim2.new(.5, -12, 1, 0);
					v.Parent = V;
					local f = e("", 13, z.SubText);
					f.TextXAlignment = Enum.TextXAlignment.Right;
					f.Position = UDim2.new(.5, 0, 0, 0);
					f.Size = UDim2.new(.5, -32, 1, 0);
					f.Parent = V;
					local n = e("\226\150\190", 13, z.SubText);
					n.TextXAlignment = Enum.TextXAlignment.Center;
					n.AnchorPoint = Vector2.new(1, 0);
					n.Position = UDim2.new(1, -8, 0, 0);
					n.Size = UDim2.fromOffset(18, 38);
					n.Parent = V;
					local C = q("Frame", {
							BackgroundTransparency = 1,
							Position = UDim2.fromOffset(6, 40),
							Size = UDim2.new(1, -12, 0, 0),
							AutomaticSize = Enum.AutomaticSize.Y,
							Parent = O,
						});
					q("UIListLayout", { Padding = UDim.new(0, 2), Parent = C });
					local i = { Value = Y, Options = {} };
					local K = false;
					local function y(P)
						K = P;
						local j = K and (44 + #i.Options * 30) or 38;
						S(O, o.Base, { Size = UDim2.new(1, 0, 0, j) });
						S(n, o.Base, { Rotation = K and 180 or 0 });
					end;
					function i.Set(Y, P, j)
						i.Value = P;
						f.Text = P and tostring(P) or "\226\128\148";
						if not j then
							I(X, P);
						end;
					end;
					function i.Refresh(j, P)
						i.Options = P;
						C:ClearAllChildren();
						q("UIListLayout", { Padding = UDim.new(0, 2), Parent = C });
						for P, j in ipairs(P) do
							local Y = q("TextButton", {
									AutoButtonColor = false,
									BackgroundColor3 = z.Panel,
									Size = UDim2.new(1, 0, 0, 28),
									Text = "  " .. tostring(j),
									TextXAlignment = Enum.TextXAlignment.Left,
									TextSize = 13,
									TextColor3 = z.Text,
									Font = z.Font,
									Parent = C,
								}, { W(6) });
							Y.MouseEnter:Connect(function()
								S(Y, o.Fast, { BackgroundColor3 = z.Elevated });
							end);
							Y.MouseLeave:Connect(function()
								S(Y, o.Fast, { BackgroundColor3 = z.Panel });
							end);
							Y.MouseButton1Click:Connect(function()
								i:Set(j);
								y(false);
							end);
						end;
						if K then
							y(true);
						end;
					end;
					T(V.MouseButton1Click:Connect(function()
						y(not K);
					end));
					i:Refresh(j or {});
					i:Set(Y, true);
					return i;
				end;
				function M.Status(j, P)
					local Y = D(58);
					Y.AutomaticSize = Enum.AutomaticSize.Y;
					local X = e(P, 12, z.SubText, z.FontBold);
					X.Position = UDim2.fromOffset(12, 8);
					X.Size = UDim2.new(1, -24, 0, 16);
					X.Parent = Y;
					local M = e("\226\128\166", 13, z.Text);
					M.TextWrapped = true;
					M.TextYAlignment = Enum.TextYAlignment.Top;
					M.AutomaticSize = Enum.AutomaticSize.Y;
					M.Position = UDim2.fromOffset(12, 28);
					M.Size = UDim2.new(1, -24, 0, 18);
					M.Parent = Y;
					q("UIPadding", { PaddingBottom = UDim.new(0, 10), Parent = Y });
					local o = q("Frame", {
							AnchorPoint = Vector2.new(1, 0),
							Position = UDim2.new(1, -12, 0, 12),
							Size = UDim2.fromOffset(8, 8),
							BackgroundColor3 = z.SubText,
							Parent = Y,
						}, { W(9999) });
					local O = {
							body = M,
							text = "\226\128\166",
							color = z.Text,
							dirty = false,
						};
					table.insert(A, O);
					local V = {};
					function V.Set(Y, P, j)
						O.text = tostring(P);
						O.color = j and z[j] or z.Text;
						O.dirty = true;
					end;
					local v;
					function V.SetActive(j, P)
						if v then
							v:Cancel();
							v = nil;
						end;
						o.BackgroundTransparency = 0;
						o.BackgroundColor3 = P and z.Good or z.SubText;
						if P then
							v = S(o, TweenInfo.new(.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { BackgroundTransparency = .7 });
						end;
					end;
					return V;
				end;
				function M.Counters(Y, j)
					local X = D(44);
					q("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal,
						Padding = UDim.new(0, 6),
						VerticalAlignment = Enum.VerticalAlignment.Center,
						SortOrder = Enum.SortOrder.LayoutOrder,
						Parent = X,
					});
					q("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), Parent = X });
					local M = {};
					for Y, o in ipairs(j) do
						local S = q("Frame", {
								BackgroundColor3 = z.Elevated,
								Size = UDim2.new(1 / #j, -6, 0, 30),
								LayoutOrder = Y,
								Parent = X,
							}, { W(6) });
						local O = q("Frame", {
								BackgroundTransparency = 1,
								AnchorPoint = Vector2.new(0, .5),
								Position = UDim2.new(0, 6, .5, 0),
								Size = UDim2.fromOffset(20, 20),
								Parent = S,
							});
						P.icon(o.Icon, O);
						local V = e("0", 13, z.Text, z.FontBold);
						V.Position = UDim2.fromOffset(32, 0);
						V.Size = UDim2.new(1, -36, 1, 0);
						V.TextTruncate = Enum.TextTruncate.AtEnd;
						V.Parent = S;
						local v = {
								body = V,
								text = "0",
								color = z.Text,
								dirty = false,
							};
						table.insert(A, v);
						M[o.Key] = v;
					end;
					local o = {};
					function o.Set(X, P, j, Y)
						local o = M[P];
						if o then
							o.text = tostring(j);
							o.color = Y and z[Y] or z.Text;
							o.dirty = true;
						end;
					end;
					return o;
				end;
				function M.StatusCard(P)
					local j = D(118);
					j.BackgroundColor3 = z.Panel;
					q("UIGradient", { Rotation = 90, Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(205, 205, 215)), Parent = j });
					local Y = q("Frame", {
							BackgroundColor3 = z.Accent,
							BorderSizePixel = 0,
							Position = UDim2.fromOffset(0, 12),
							Size = UDim2.new(0, 3, 1, -24),
							Parent = j,
						}, { W(2) });
					local X = q("Frame", {
							BackgroundTransparency = 1,
							Position = UDim2.fromOffset(14, 10),
							Size = UDim2.new(1, -28, 0, 20),
							Parent = j,
						});
					local M, O, V = k(X, "STARTING", z.Accent);
					local v = e("\226\128\166", 15, z.Text, z.FontBold);
					v.Position = UDim2.fromOffset(14, 36);
					v.Size = UDim2.new(1, -28, 0, 20);
					v.TextTruncate = Enum.TextTruncate.AtEnd;
					v.Parent = j;
					local f = e("", 12, z.SubText);
					f.Position = UDim2.fromOffset(14, 56);
					f.Size = UDim2.new(1, -28, 0, 16);
					f.TextTruncate = Enum.TextTruncate.AtEnd;
					f.Parent = j;
					local n = e("HP", 11, z.SubText, z.FontBold);
					n.Position = UDim2.fromOffset(14, 78);
					n.Size = UDim2.fromOffset(120, 14);
					n.Parent = j;
					local C = q("Frame", {
							BackgroundColor3 = z.Elevated,
							Position = UDim2.new(0, 14, 0, 96),
							Size = UDim2.new(1, -28, 0, 6),
							Parent = j,
						}, { W(9999) });
					local i = q("Frame", { BackgroundColor3 = z.Good, Size = UDim2.fromScale(1, 1), Parent = C }, { W(9999) });
					local y = q("Frame", {
							BackgroundTransparency = 1,
							AnchorPoint = Vector2.new(1, 0),
							Position = UDim2.new(1, -12, 0, 8),
							Size = UDim2.new(.6, -12, 0, 24),
							Parent = j,
						});
					q("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Right,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						Padding = UDim.new(0, 6),
						SortOrder = Enum.SortOrder.LayoutOrder,
						Parent = y,
					});
					local A = {};
					local function T(P)
						if A[P] then
							return A[P];
						end;
						local j = q("Frame", {
								BackgroundColor3 = z.Elevated,
								Size = UDim2.fromOffset(0, 24),
								AutomaticSize = Enum.AutomaticSize.X,
								LayoutOrder = P,
								Parent = y,
							}, { W(6) });
						q("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), Parent = j });
						q("UIListLayout", {
							FillDirection = Enum.FillDirection.Horizontal,
							VerticalAlignment = Enum.VerticalAlignment.Center,
							Padding = UDim.new(0, 5),
							SortOrder = Enum.SortOrder.LayoutOrder,
							Parent = j,
						});
						local Y = e("", 11, z.SubText);
						Y.Size = UDim2.fromOffset(0, 24);
						Y.AutomaticSize = Enum.AutomaticSize.X;
						Y.LayoutOrder = 1;
						Y.Parent = j;
						local X = e("", 12, z.Text, z.FontBold);
						X.Size = UDim2.fromOffset(0, 24);
						X.AutomaticSize = Enum.AutomaticSize.X;
						X.LayoutOrder = 2;
						X.Parent = j;
						A[P] = { Frame = j, Key = Y, Value = X };
						return A[P];
					end;
					local B = {};
					local x = { dirty = false };
					local c = nil;
					x.apply = function()
							local P = z[B.Kind or "Accent"] or z.Accent;
							O.Text = string.upper(B.State or "");
							if c ~= B.Kind then
								c = B.Kind;
								S(M, o.Base, { BackgroundColor3 = K(z.Panel, P, .18) });
								S(O, o.Base, { TextColor3 = P });
								S(V, o.Base, { BackgroundColor3 = P });
								S(Y, o.Base, { BackgroundColor3 = P });
								local j = M:FindFirstChildOfClass("UIStroke");
								if j then
									S(j, o.Base, { Color = P });
								end;
							end;
							v.Text = B.Headline or "";
							f.Text = B.Detail or "";
							local j, X = B.HP or 0, math.max(B.MaxHP or 1, 1);
							local q = math.clamp(j / X, 0, 1);
							n.Text = string.format("HP  %d / %d", math.floor(j), math.floor(X));
							S(i, o.Base, { Size = UDim2.fromScale(q, 1), BackgroundColor3 = q > .6 and z.Good or (q > .3 and z.Warn or z.Bad) });
							for P, j in ipairs(B.Chips or {}) do
								local Y = T(P);
								Y.Frame.Visible = true;
								Y.Key.Text = tostring(j[1]);
								Y.Value.Text = tostring(j[2]);
							end;
							for P = #((B.Chips or {})) + 1, #A, 1 do
								A[P].Frame.Visible = false;
							end;
						end;
					table.insert(p, x);
					local G = {};
					function G.Set(j, P)
						B = P;
						x.dirty = true;
					end;
					return G;
				end;
				function M.StreakCard(j, P)
					P = P or 10;
					local Y = D(76);
					local X = q("Frame", {
							BackgroundColor3 = z.Gold,
							BackgroundTransparency = .88,
							Position = UDim2.fromOffset(10, 10),
							Size = UDim2.fromOffset(56, 56),
							Parent = Y,
						}, { W(12) });
					q("UIStroke", {
						Color = z.Gold,
						Transparency = .5,
						Thickness = 1,
						Parent = X,
					});
					local M = e("0", 22, z.Gold, z.FontBold);
					M.TextXAlignment = Enum.TextXAlignment.Center;
					M.Parent = X;
					local O = e("WIN STREAK", 10, z.SubText, z.FontBold);
					O.Position = UDim2.fromOffset(78, 12);
					O.Size = UDim2.new(1, -90, 0, 14);
					O.Parent = Y;
					local V = q("Frame", {
							BackgroundTransparency = 1,
							Position = UDim2.fromOffset(78, 26),
							Size = UDim2.new(1, -90, 0, 20),
							Parent = Y,
						});
					q("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						Padding = UDim.new(0, 8),
						SortOrder = Enum.SortOrder.LayoutOrder,
						Parent = V,
					});
					local v = e("", 14, z.Text, z.FontBold);
					v.Size = UDim2.fromOffset(0, 20);
					v.AutomaticSize = Enum.AutomaticSize.X;
					v.LayoutOrder = 1;
					v.Parent = V;
					local f = k(V, "NEW BEST", z.Gold);
					f.LayoutOrder = 3;
					f.Visible = false;
					local n, C = k(V, "", z.Good);
					n.LayoutOrder = 2;
					n.Visible = false;
					local i = e("", 11, z.SubText);
					i.Position = UDim2.fromOffset(78, 48);
					i.Size = UDim2.new(1, -90 - P * 14, 0, 16);
					i.TextTruncate = Enum.TextTruncate.AtEnd;
					i.Parent = Y;
					local K = q("Frame", {
							BackgroundTransparency = 1,
							AnchorPoint = Vector2.new(1, 0),
							Position = UDim2.new(1, -12, 0, 50),
							Size = UDim2.fromOffset(P * 14, 12),
							Parent = Y,
						});
					q("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Right,
						Padding = UDim.new(0, 4),
						SortOrder = Enum.SortOrder.LayoutOrder,
						Parent = K,
					});
					local y = {};
					for P = 1, P, 1 do
						y[P] = q("Frame", {
								BackgroundColor3 = z.Elevated,
								Size = UDim2.fromOffset(10, 10),
								LayoutOrder = P,
								Parent = K,
							}, { W(3) });
					end;
					local A = {};
					local T = { dirty = false };
					local B = nil;
					T.apply = function()
							local j = A.Streak or 0;
							M.Text = tostring(j);
							v.Text = j == 1 and "1 win in a row" or (tostring(j) .. " wins in a row");
							f.Visible = j > 0 and j >= ((A.Best or 0));
							i.Text = A.Sub or string.format("Best %d \194\183 %d wins total", A.Best or 0, A.Wins or 0);
							n.Visible = ((A.Bonus or 0)) > 0;
							C.Text = A.BonusText or ("+" .. (tostring(A.Bonus or 0) .. " BONUS"));
							if B and j > B then
								M.TextSize = 28;
								S(M, o.Spring, { TextSize = 22 });
							end;
							B = j;
							local Y = A.Recent or {};
							for j = 1, P, 1 do
								local X = Y[(P - j) + 1];
								local M = z.Elevated;
								if X == "live" then
									M = z.Accent;
								elseif X == true then
									M = z.Good;
								elseif X == false then
									M = z.Bad;
								end;
								y[j].BackgroundColor3 = M;
							end;
						end;
					table.insert(p, T);
					local x = {};
					function x.Set(j, P)
						A = P;
						T.dirty = true;
					end;
					return x;
				end;
				function M.StatTiles(X, j, Y)
					Y = Y or #j;
					n = n + 1;
					local o = q("Frame", {
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 0, 64),
							LayoutOrder = n,
							Parent = M.Page,
						});
					q("UIGridLayout", {
						CellSize = UDim2.new(1 / Y, -math.ceil((6 * ((Y - 1))) / Y), 0, 64),
						CellPadding = UDim2.fromOffset(6, 6),
						SortOrder = Enum.SortOrder.LayoutOrder,
						Parent = o,
					});
					local S = {};
					for j, Y in ipairs(j) do
						local X = q("Frame", { BackgroundColor3 = z.Panel, LayoutOrder = j, Parent = o }, { W(), O(z.Stroke, .3) });
						local M = q("Frame", {
								BackgroundTransparency = 1,
								Position = UDim2.fromOffset(10, 10),
								Size = UDim2.fromOffset(18, 18),
								Parent = X,
							});
						P.icon(Y.Icon, M);
						local V = e(string.upper(Y.Label or Y.Key), 10, z.SubText, z.FontBold);
						V.Position = UDim2.fromOffset(34, 10);
						V.Size = UDim2.new(1, -40, 0, 18);
						V.TextTruncate = Enum.TextTruncate.AtEnd;
						V.Parent = X;
						local v = e("0", 18, z.Text, z.FontBold);
						v.Position = UDim2.fromOffset(10, 32);
						v.Size = UDim2.new(1, -20, 0, 24);
						v.TextTruncate = Enum.TextTruncate.AtEnd;
						v.Parent = X;
						local f = e("", 11, z.Good, z.FontBold);
						f.TextXAlignment = Enum.TextXAlignment.Right;
						f.AnchorPoint = Vector2.new(1, 0);
						f.Position = UDim2.new(1, -10, 0, 36);
						f.Size = UDim2.fromOffset(60, 18);
						f.Parent = X;
						S[Y.Key] = {
								Value = v,
								Delta = f,
								v = "0",
								d = "",
							};
					end;
					local V = { dirty = false };
					V.apply = function()
							for P, j in pairs(S) do
								j.Value.Text = j.v;
								j.Delta.Text = j.d;
							end;
						end;
					table.insert(p, V);
					local v = {};
					function v.Set(X, P, j, Y)
						local M = S[P];
						if M then
							M.v = tostring(j);
							M.d = ((Y and Y ~= 0)) and (((Y > 0 and "+" or "")) .. tostring(Y)) or "";
							V.dirty = true;
						end;
					end;
					return v;
				end;
				function M.RoundLog(X, j, Y)
					Y = Y or 8;
					local M = D(40);
					M.AutomaticSize = Enum.AutomaticSize.Y;
					q("UIPadding", { PaddingBottom = UDim.new(0, 8), Parent = M });
					local o = q("Frame", {
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 0, 0),
							AutomaticSize = Enum.AutomaticSize.Y,
							Parent = M,
						});
					q("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = o });
					local S, V = 52, 118;
					local function v(P, Y)
						local X = q("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, Y), Parent = P });
						q("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), Parent = X });
						local M = e("", 12, z.SubText, z.FontBold);
						M.Size = UDim2.new(0, S, 1, 0);
						M.Parent = X;
						local o = q("Frame", {
								BackgroundTransparency = 1,
								Position = UDim2.fromOffset(S, 0),
								Size = UDim2.new(0, V, 1, 0),
								Parent = X,
							});
						local W = {};
						local O = #j;
						for P, j in ipairs(j) do
							local Y = e("", 12, z.Text, z.Font);
							Y.TextXAlignment = Enum.TextXAlignment.Right;
							Y.Position = UDim2.new(((P - 1)) / O, (S + V) - (((P - 1)) / O) * ((S + V)), 0, 0);
							Y.Size = UDim2.new(1 / O, -((S + V)) / O, 1, 0);
							Y.Parent = X;
							W[j.Key] = Y;
						end;
						return X, M, o, W;
					end;
					local f, n = v(o, 30);
					f.LayoutOrder = 0;
					n.Text = "ROUND";
					n.TextSize = 10;
					local C = e("RESULT", 10, z.SubText, z.FontBold);
					C.Position = UDim2.fromOffset(S, 0);
					C.Size = UDim2.new(0, V, 1, 0);
					C.Parent = f;
					for Y, X in ipairs(j) do
						local M = #j;
						local z = q("Frame", {
								BackgroundTransparency = 1,
								AnchorPoint = Vector2.new(1, .5),
								Position = UDim2.new(Y / M, (S + V) - (Y / M) * ((S + V)), .5, 0),
								Size = UDim2.fromOffset(16, 16),
								Parent = f,
							});
						P.icon(X.Icon, z);
					end;
					q("Frame", {
						BackgroundColor3 = z.Stroke,
						BorderSizePixel = 0,
						Size = UDim2.new(1, -24, 0, 1),
						Position = UDim2.fromOffset(12, 0),
						LayoutOrder = 1,
						Parent = o,
					});
					local i = q("Frame", {
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 0, 0),
							AutomaticSize = Enum.AutomaticSize.Y,
							LayoutOrder = 2,
							Parent = o,
						});
					q("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = i });
					local y = e("No finished rounds yet", 12, z.SubText);
					y.TextXAlignment = Enum.TextXAlignment.Center;
					y.Size = UDim2.new(1, 0, 0, 30);
					y.Parent = i;
					local A = q("Frame", {
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 0, 0),
							AutomaticSize = Enum.AutomaticSize.Y,
							LayoutOrder = 3,
							Parent = o,
						});
					q("UIPadding", {
						PaddingLeft = UDim.new(0, 8),
						PaddingRight = UDim.new(0, 8),
						PaddingTop = UDim.new(0, 6),
						Parent = A,
					});
					local T = q("Frame", { BackgroundColor3 = z.Elevated, Size = UDim2.new(1, 0, 0, 34), Parent = A }, { W(6), O(z.Good, .6) });
					local B, x, c, G = v(T, 34);
					B.UIPadding.PaddingLeft = UDim.new(0, 4);
					B.UIPadding.PaddingRight = UDim.new(0, 4);
					x.TextColor3 = z.Text;
					local a = e("", 11, z.SubText, z.FontBold);
					a.Parent = c;
					for P, j in pairs(G) do
						j.Font = z.FontBold;
					end;
					local w = {};
					local l, L = {}, nil;
					local Z = { dirty = false };
					Z.apply = function()
							y.Visible = #l == 0;
							for P = 1, math.max(#l, #w), 1 do
								local Y = l[P];
								local X = w[P];
								if Y and not X then
									local j, Y, M, o = v(i, 28);
									j.LayoutOrder = P;
									local S = q("Frame", {
											BackgroundColor3 = z.Hardcore,
											BorderSizePixel = 0,
											Position = UDim2.new(0, -8, .5, -8),
											Size = UDim2.fromOffset(3, 16),
											Visible = false,
											Parent = j,
										}, { W(2) });
									local O, V, e = k(M, "", z.SubText);
									O.AnchorPoint = Vector2.new(0, .5);
									O.Position = UDim2.fromScale(0, .5);
									X = {
											Frame = j,
											Round = Y,
											Pill = O,
											PillText = V,
											PillDot = e,
											Vals = o,
											Strip = S,
										};
									w[P] = X;
								end;
								if X then
									X.Frame.Visible = Y ~= nil;
									if Y then
										local P = z[Y.Kind or "SubText"] or z.SubText;
										X.Round.Text = Y.Round or "";
										X.Strip.Visible = Y.Hardcore and true or false;
										X.Round.TextColor3 = Y.Hardcore and z.Hardcore or z.SubText;
										X.PillText.Text = string.upper(Y.Result or "");
										X.PillText.TextColor3 = P;
										X.PillDot.BackgroundColor3 = P;
										X.Pill.BackgroundColor3 = K(z.Panel, P, .18);
										local M = X.Pill:FindFirstChildOfClass("UIStroke");
										if M then
											M.Color = P;
										end;
										for P, j in ipairs(j) do
											local M = Y.Values and Y.Values[j.Key] or 0;
											X.Vals[j.Key].Text = M > 0 and ("+" .. tostring(M)) or tostring(M);
											X.Vals[j.Key].TextColor3 = M > 0 and z.Text or z.SubText;
										end;
									end;
								end;
							end;
							if L then
								x.Text = L.Round or "TOTAL";
								a.Text = L.Result or "";
								for P, j in ipairs(j) do
									local Y = L.Values and L.Values[j.Key] or 0;
									G[j.Key].Text = tostring(Y);
									G[j.Key].TextColor3 = Y > 0 and z.Good or z.SubText;
								end;
							end;
						end;
					table.insert(p, Z);
					local t = {};
					function t.SetRows(j, P)
						l = {};
						for j = 1, math.min(#P, Y), 1 do
							l[j] = P[j];
						end;
						Z.dirty = true;
					end;
					function t.SetTotal(j, P)
						L = P;
						Z.dirty = true;
					end;
					return t;
				end;
				local function B(P, j)
					local Y = 0;
					for j, X in ipairs(j) do
						if P < X then
							return ((P - Y)) / ((X - Y)), j, string.format("%d / %d XP", P, X);
						end;
						Y = X;
					end;
					return 1, #j + 1, "MAX";
				end;
				function M.SkillHero(j)
					local Y = D(92);
					local X = q("Frame", {
							BackgroundColor3 = z.Elevated,
							Position = UDim2.fromOffset(12, 12),
							Size = UDim2.fromOffset(68, 68),
							Parent = Y,
						}, { W(12), O(z.Stroke, .2) });
					local M = q("Frame", {
							BackgroundTransparency = 1,
							AnchorPoint = Vector2.new(.5, .5),
							Position = UDim2.fromScale(.5, .5),
							Size = UDim2.fromOffset(56, 56),
							Parent = X,
						});
					local V = e("EQUIPPED SKILL", 10, z.SubText, z.FontBold);
					V.Position = UDim2.fromOffset(92, 12);
					V.Size = UDim2.new(1, -104, 0, 14);
					V.Parent = Y;
					local v = q("Frame", {
							BackgroundTransparency = 1,
							Position = UDim2.fromOffset(92, 28),
							Size = UDim2.new(1, -104, 0, 22),
							Parent = Y,
						});
					q("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						Padding = UDim.new(0, 8),
						SortOrder = Enum.SortOrder.LayoutOrder,
						Parent = v,
					});
					local f = e("\226\128\148", 16, z.Text, z.FontBold);
					f.Size = UDim2.fromOffset(0, 22);
					f.AutomaticSize = Enum.AutomaticSize.X;
					f.LayoutOrder = 1;
					f.Parent = v;
					local n, C, i = k(v, "LVL 1", z.Accent);
					n.LayoutOrder = 2;
					local y = q("Frame", {
							BackgroundColor3 = z.Elevated,
							Position = UDim2.fromOffset(92, 58),
							Size = UDim2.new(1, -200, 0, 8),
							Parent = Y,
						}, { W(9999) });
					local A = q("Frame", { BackgroundColor3 = z.Accent, Size = UDim2.fromScale(0, 1), Parent = y }, { W(9999) });
					local T = e("", 11, z.SubText, z.FontBold);
					T.TextXAlignment = Enum.TextXAlignment.Right;
					T.AnchorPoint = Vector2.new(1, 0);
					T.Position = UDim2.new(1, -12, 0, 54);
					T.Size = UDim2.fromOffset(96, 16);
					T.Parent = Y;
					local x = e("", 11, z.SubText);
					x.Position = UDim2.fromOffset(92, 70);
					x.Size = UDim2.new(1, -104, 0, 16);
					x.TextTruncate = Enum.TextTruncate.AtEnd;
					x.Parent = Y;
					local c, G = {}, nil;
					local a = { dirty = false };
					a.apply = function()
							if c.Icon ~= G then
								G = c.Icon;
								P.icon(c.Icon, M);
							end;
							f.Text = c.Name or "\226\128\148";
							local j, Y, X = B(c.Xp or 0, c.Thresholds or { 100, 300 });
							local q = Y > #((c.Thresholds or { 100, 300 })) and z.Good or z.Accent;
							C.Text = X == "MAX" and "LVL MAX" or ("LVL " .. Y);
							C.TextColor3 = q;
							i.BackgroundColor3 = q;
							n.BackgroundColor3 = K(z.Panel, q, .18);
							S(A, o.Base, { Size = UDim2.fromScale(math.clamp(j, 0, 1), 1), BackgroundColor3 = q });
							T.Text = X;
							x.Text = c.Note or "";
						end;
					table.insert(p, a);
					local w = {};
					function w.Set(j, P)
						c = P;
						a.dirty = true;
					end;
					return w;
				end;
				function M.SkillGrid(V, j, Y, X, O)
					X = X or 4;
					O = O or { 100, 300 };
					n = n + 1;
					local v = q("Frame", {
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 0, 0),
							AutomaticSize = Enum.AutomaticSize.Y,
							LayoutOrder = n,
							Parent = M.Page,
						});
					q("UIPadding", {
						PaddingTop = UDim.new(0, 4),
						PaddingBottom = UDim.new(0, 8),
						PaddingLeft = UDim.new(0, 4),
						PaddingRight = UDim.new(0, 4),
						Parent = v,
					});
					q("UIGridLayout", {
						CellSize = UDim2.new(1 / X, -math.ceil((8 * ((X - 1))) / X), 0, 112),
						CellPadding = UDim2.fromOffset(8, 8),
						SortOrder = Enum.SortOrder.LayoutOrder,
						Parent = v,
					});
					local f, D = {}, {};
					for j, X in ipairs(j) do
						local M = q("TextButton", {
								AutoButtonColor = false,
								ClipsDescendants = true,
								BackgroundColor3 = z.Panel,
								Text = "",
								LayoutOrder = j,
								Parent = v,
							}, { W(10) });
						local O = q("UIScale", { Scale = 1, Parent = M });
						local V = q("UIStroke", {
								Color = z.Stroke,
								Transparency = .25,
								Thickness = 1,
								LineJoinMode = Enum.LineJoinMode.Round,
								ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
								Parent = M,
							});
						local n = q("Frame", {
								BackgroundColor3 = X.Color and K(z.Elevated, X.Color, .28) or z.Elevated,
								AnchorPoint = Vector2.new(.5, 0),
								Position = UDim2.new(.5, 0, 0, 10),
								Size = UDim2.fromOffset(46, 46),
								Parent = M,
							}, { W(10) });
						if X.Color then
							q("Frame", {
								BackgroundColor3 = X.Color,
								BorderSizePixel = 0,
								AnchorPoint = Vector2.new(.5, 0),
								Position = UDim2.new(.5, 0, 0, 3),
								Size = UDim2.new(1, -28, 0, 3),
								Parent = M,
							}, { W(9999) });
						end;
						local i = q("Frame", {
								BackgroundTransparency = 1,
								AnchorPoint = Vector2.new(.5, .5),
								Position = UDim2.fromScale(.5, .5),
								Size = UDim2.fromOffset(40, 40),
								Parent = n,
							});
						P.icon(X.Icon, i);
						local y = e(X.Name, 11, z.Text, z.FontBold);
						y.TextXAlignment = Enum.TextXAlignment.Center;
						y.TextTruncate = Enum.TextTruncate.AtEnd;
						y.Position = UDim2.fromOffset(6, 60);
						y.Size = UDim2.new(1, -12, 0, 16);
						y.Parent = M;
						local k = e("LVL 1", 10, z.SubText, z.FontBold);
						k.TextXAlignment = Enum.TextXAlignment.Center;
						k.Position = UDim2.fromOffset(6, 76);
						k.Size = UDim2.new(1, -12, 0, 14);
						k.Parent = M;
						local A = q("Frame", {
								BackgroundColor3 = z.Elevated,
								Position = UDim2.new(0, 12, 0, 96),
								Size = UDim2.new(1, -24, 0, 5),
								Parent = M,
							}, { W(9999) });
						local p = q("Frame", { BackgroundColor3 = z.Accent, Size = UDim2.fromScale(0, 1), Parent = A }, { W(9999) });
						local B = q("Frame", {
								Position = UDim2.fromOffset(6, 6),
								Size = UDim2.fromOffset(0, 16),
								AutomaticSize = Enum.AutomaticSize.X,
								BackgroundColor3 = z.Accent,
								Visible = false,
								Parent = M,
							}, { W(9999) });
						q("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), Parent = B });
						local x = e("", 9, z.Bg, z.FontBold);
						x.Size = UDim2.fromOffset(0, 16);
						x.AutomaticSize = Enum.AutomaticSize.X;
						x.Parent = B;
						local c = q("Frame", {
								AnchorPoint = Vector2.new(1, 0),
								Position = UDim2.new(1, -6, 0, 6),
								Size = UDim2.fromOffset(0, 18),
								AutomaticSize = Enum.AutomaticSize.X,
								BackgroundColor3 = Color3.new(1, 1, 1),
								Visible = false,
								Parent = M,
							}, { W(9999) });
						q("UIGradient", { Rotation = 90, Color = ColorSequence.new(Color3.fromRGB(255, 222, 120), Color3.fromRGB(240, 150, 40)), Parent = c });
						q("UIStroke", {
							Color = Color3.fromRGB(255, 236, 170),
							Transparency = .35,
							Thickness = 1,
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
							Parent = c,
						});
						q("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 7), Parent = c });
						local G = e("\226\152\133 FINAL", 9, Color3.fromRGB(70, 40, 0), z.FontBold);
						G.Size = UDim2.fromOffset(0, 18);
						G.AutomaticSize = Enum.AutomaticSize.X;
						G.Parent = c;
						f[X.Key] = {
								Button = M,
								Stroke = V,
								Level = k,
								Fill = p,
								Tag = B,
								TagText = x,
								Star = c,
								StarText = G,
							};
						D[X.Key] = {};
						T(M.MouseEnter:Connect(function()
							S(O, o.Fast, { Scale = 1.03 });
						end));
						T(M.MouseLeave:Connect(function()
							S(O, o.Fast, { Scale = 1 });
						end));
						T(M.MouseButton1Click:Connect(function()
							S(O, o.Spring, { Scale = 1.03 });
							C(M);
							I(Y, X.Key);
						end));
					end;
					local i = { dirty = false };
					i.apply = function()
							for P, j in pairs(f) do
								local Y = D[P];
								local X, M, q = B(Y.Xp or 0, O);
								local W = q == "MAX";
								j.Level.Text = W and "LVL MAX" or string.format("LVL %d \194\183 %s", M, q);
								j.Level.TextColor3 = W and z.Good or z.SubText;
								S(j.Fill, o.Base, { Size = UDim2.fromScale(math.clamp(X, 0, 1), 1), BackgroundColor3 = W and z.Good or z.Accent });
								local V = Y.Final and z.Gold or (Y.Equipped and z.Accent or z.Stroke);
								S(j.Stroke, o.Base, { Color = V, Thickness = ((Y.Final or Y.Equipped)) and 2 or 1, Transparency = ((Y.Final or Y.Equipped)) and 0 or .25 });
								S(j.Button, o.Base, { BackgroundColor3 = Y.Equipped and K(z.Panel, z.Accent, .1) or z.Panel });
								j.Star.Visible = Y.Final and true or false;
								if Y.Equipped then
									j.Tag.Visible = true;
									j.Tag.BackgroundColor3 = z.Accent;
									j.TagText.Text = "EQUIPPED";
								elseif Y.Next then
									j.Tag.Visible = true;
									j.Tag.BackgroundColor3 = z.Warn;
									j.TagText.Text = "NEXT";
								else
									j.Tag.Visible = false;
								end;
							end;
						end;
					table.insert(p, i);
					local y = {};
					function y.Update(Y, P, j)
						if D[P] then
							D[P] = j;
							i.dirty = true;
						end;
					end;
					return y;
				end;
				function M.ItemGrid(v, j, Y, X, V)
					V = V or 4;
					n = n + 1;
					local f = q("Frame", {
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 0, 26),
							LayoutOrder = n,
							Parent = M.Page,
						});
					local D = q("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, -110, 1, 0), Parent = f });
					q("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						Padding = UDim.new(0, 8),
						SortOrder = Enum.SortOrder.LayoutOrder,
						Parent = D,
					});
					local i = e(string.upper(j), 11, z.Text, z.FontBold);
					i.Size = UDim2.new(0, 0, 1, 0);
					i.AutomaticSize = Enum.AutomaticSize.X;
					i.LayoutOrder = 1;
					i.Parent = D;
					local y = e("", 11, z.SubText, z.FontBold);
					y.Size = UDim2.new(0, 0, 1, 0);
					y.AutomaticSize = Enum.AutomaticSize.X;
					y.LayoutOrder = 2;
					y.Parent = D;
					local function k(P, j)
						local Y = q("TextButton", {
								AutoButtonColor = false,
								AnchorPoint = Vector2.new(1, .5),
								Position = UDim2.new(1, j, .5, 0),
								Size = UDim2.fromOffset(46, 20),
								BackgroundColor3 = z.Elevated,
								Text = P,
								TextSize = 10,
								TextColor3 = z.SubText,
								Font = z.FontBold,
								Parent = f,
							}, { W(9999), O(z.Stroke, .2) });
						T(Y.MouseEnter:Connect(function()
							S(Y, o.Fast, { BackgroundColor3 = z.Stroke, TextColor3 = z.Text });
						end));
						T(Y.MouseLeave:Connect(function()
							S(Y, o.Fast, { BackgroundColor3 = z.Elevated, TextColor3 = z.SubText });
						end));
						return Y;
					end;
					local A = k("NONE", -2);
					local p = k("ALL", -54);
					n = n + 1;
					local B = q("Frame", {
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 0, 0),
							AutomaticSize = Enum.AutomaticSize.Y,
							LayoutOrder = n,
							Parent = M.Page,
						});
					q("UIPadding", {
						PaddingTop = UDim.new(0, 4),
						PaddingBottom = UDim.new(0, 8),
						PaddingLeft = UDim.new(0, 4),
						PaddingRight = UDim.new(0, 4),
						Parent = B,
					});
					q("UIGridLayout", {
						CellSize = UDim2.new(1 / V, -math.ceil((8 * ((V - 1))) / V), 0, 96),
						CellPadding = UDim2.fromOffset(8, 8),
						SortOrder = Enum.SortOrder.LayoutOrder,
						Parent = B,
					});
					local x = { Selected = {}, Cards = {} };
					local function c()
						local P = 0;
						for j, Y in ipairs(Y) do
							if x.Selected[Y.Key] then
								P = P + 1;
							end;
						end;
						y.Text = string.format("%d/%d", P, #Y);
					end;
					local function G(P, j, Y)
						local X = Y and TweenInfo.new(0) or o.Base;
						S(P.Stroke, X, { Color = j and z.Good or z.Stroke, Transparency = j and 0 or .25, Thickness = j and 2 or 1 });
						S(P.Button, X, { BackgroundColor3 = j and K(z.Panel, z.Good, .08) or z.Panel });
						S(P.Plate, X, { BackgroundColor3 = j and K(z.Elevated, z.Good, .16) or z.Elevated });
						S(P.Badge, X, { BackgroundTransparency = j and 0 or 1 });
						S(P.Check, X, { TextTransparency = j and 0 or 1 });
						S(P.NameLabel, X, { TextColor3 = j and z.Text or z.SubText });
						S(P.Dim, X, { BackgroundTransparency = j and 1 or .45 });
					end;
					function x.Set(M, P, j, Y)
						local z = x.Cards[P];
						if not z then
							return;
						end;
						j = j and true or false;
						x.Selected[P] = j;
						G(z, j, false);
						c();
						if not Y then
							I(X, P, j);
						end;
					end;
					function x.SetName(Y, P, j)
						local X = x.Cards[P];
						if X then
							X.NameLabel.Text = j;
						end;
					end;
					function x.SetCount(Y, P, j)
						local X = x.Cards[P];
						if X then
							X.CountText.Text = j > 0 and ("\195\151" .. tostring(j)) or "";
							X.CountTag.Visible = j > 0;
						end;
					end;
					function x.IconHolder(j, P)
						local Y = x.Cards[P];
						return Y and Y.Holder;
					end;
					for j, Y in ipairs(Y) do
						local X = q("TextButton", {
								AutoButtonColor = false,
								ClipsDescendants = true,
								BackgroundColor3 = z.Panel,
								Text = "",
								LayoutOrder = j,
								Parent = B,
							}, { W(10) });
						local M = q("UIScale", { Scale = 1, Parent = X });
						q("UIGradient", { Rotation = 90, Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(200, 200, 210)), Parent = X });
						local O = q("UIStroke", {
								Color = z.Stroke,
								Transparency = .25,
								Thickness = 1,
								LineJoinMode = Enum.LineJoinMode.Round,
								ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
								Parent = X,
							});
						local V = q("Frame", {
								BackgroundColor3 = z.Elevated,
								AnchorPoint = Vector2.new(.5, 0),
								Position = UDim2.new(.5, 0, 0, 10),
								Size = UDim2.fromOffset(48, 48),
								Parent = X,
							}, { W(9999) });
						local v = q("Frame", {
								BackgroundTransparency = 1,
								AnchorPoint = Vector2.new(.5, .5),
								Position = UDim2.fromScale(.5, .5),
								Size = UDim2.fromOffset(34, 34),
								Parent = V,
							});
						P.icon(Y.Icon, v);
						local f = q("Frame", {
								BackgroundColor3 = z.Panel,
								BackgroundTransparency = 1,
								Size = UDim2.fromScale(1, 1),
								ZIndex = 5,
								Parent = V,
							}, { W(9999) });
						local n = e(Y.Name, 11, z.SubText, z.FontBold);
						n.TextXAlignment = Enum.TextXAlignment.Center;
						n.TextYAlignment = Enum.TextYAlignment.Top;
						n.TextWrapped = true;
						n.Position = UDim2.new(0, 6, 0, 64);
						n.Size = UDim2.new(1, -12, 0, 28);
						n.Parent = X;
						local D = q("Frame", {
								AnchorPoint = Vector2.new(1, 0),
								Position = UDim2.new(1, -6, 0, 6),
								Size = UDim2.fromOffset(16, 16),
								BackgroundColor3 = z.Good,
								BackgroundTransparency = 1,
								Parent = X,
							}, { W(9999) });
						local i = e("\226\156\147", 11, z.Bg, z.FontBold);
						i.TextXAlignment = Enum.TextXAlignment.Center;
						i.TextTransparency = 1;
						i.Parent = D;
						local K = q("Frame", {
								Position = UDim2.fromOffset(6, 6),
								Size = UDim2.fromOffset(0, 16),
								AutomaticSize = Enum.AutomaticSize.X,
								BackgroundColor3 = z.Elevated,
								Visible = false,
								Parent = X,
							}, { W(9999) });
						q("UIPadding", { PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5), Parent = K });
						local y = e("", 10, z.Text, z.FontBold);
						y.Size = UDim2.fromOffset(0, 16);
						y.AutomaticSize = Enum.AutomaticSize.X;
						y.Parent = K;
						local k = {
								Button = X,
								Stroke = O,
								Plate = V,
								Dim = f,
								Badge = D,
								Check = i,
								NameLabel = n,
								Holder = v,
								CountTag = K,
								CountText = y,
							};
						x.Cards[Y.Key] = k;
						T(X.MouseEnter:Connect(function()
							S(M, o.Fast, { Scale = 1.03 });
						end));
						T(X.MouseLeave:Connect(function()
							S(M, o.Fast, { Scale = 1 });
						end));
						T(X.MouseButton1Down:Connect(function()
							S(M, o.Fast, { Scale = .97 });
						end));
						T(X.MouseButton1Click:Connect(function()
							S(M, o.Spring, { Scale = 1.03 });
							C(X);
							x:Set(Y.Key, not x.Selected[Y.Key]);
						end));
						x.Selected[Y.Key] = Y.Selected and true or false;
						G(k, x.Selected[Y.Key], true);
					end;
					c();
					T(p.MouseButton1Click:Connect(function()
						for P, j in ipairs(Y) do
							if not x.Selected[j.Key] then
								x:Set(j.Key, true);
							end;
						end;
					end));
					T(A.MouseButton1Click:Connect(function()
						for P, j in ipairs(Y) do
							if x.Selected[j.Key] then
								x:Set(j.Key, false);
							end;
						end;
					end));
					return x;
				end;
				if #y.Tabs == 1 then
					task.defer(function()
						h(M);
					end);
				end;
				return M;
			end;
			task.defer(function()
				y:Show();
			end);
			return y;
		end;
		return P;
	end))();
local j = game:GetService("Players");
local Y = game:GetService("RunService");
local X = game:GetService("CollectionService");
local M = game:GetService("HttpService");
local z = game:GetService("ReplicatedStorage");
local o = j.LocalPlayer;
local q = workspace:WaitForChild("Bombs", 10);
local S = workspace:WaitForChild("Explosions", 10);
if not q or not S then
	error("Aimia - Super Bomb Survival: workspace.Bombs/Explosions missing - wrong game? PlaceId " .. tostring(game.PlaceId));
end;
if (getgenv()).SBSHubStop then
	pcall((getgenv()).SBSHubStop);
end;
if (getgenv()).SBSDodgeStop then
	pcall((getgenv()).SBSDodgeStop);
end;
local W = "SBSHub.log";
local O = "SBSHub.json";
local V = {
		running = true,
		conns = {},
		dodgeOn = true,
		collectOn = true,
		flyOn = true,
		bringOn = true,
		bombCtlOn = true,
		voidOn = false,
		voided = 0,
		voidGone = 0,
		voidBlasts = 0,
		voidSeen = setmetatable({}, { __mode = "k" }),
		autoSkill = true,
		autoClaim = true,
		hardcoreOn = nil,
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
		moving = false,
		mode = nil,
		target = nil,
		item = nil,
		lastPlan = 0,
		lastReport = 0,
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
		tries = {},
		skip = {},
		collected = 0,
		collectedBy = {},
		failed = 0,
		stats0 = nil,
		state = "starting",
	};
local function e(P)
	local j = os.date("%H:%M:%S") .. (" " .. P);
	print("[SBSHub] " .. P);
	local Y, X = pcall(function()
			if isfile(W) then
				appendfile(W, j .. "\n");
			else
				writefile(W, j .. "\n");
			end;
		end);
	if not Y and not V.logErr then
		V.logErr = true;
		print("[SBSHub] log file failed: " .. tostring(X));
	end;
end;
local v = {
		credit = function(P)
			return {
				Image = "rbxassetid://501403413",
				Offset = Vector2.new(0, 0),
				Size = Vector2.new(240, 240),
				Color = P or Color3.new(1, .847, 0),
			};
		end,
		gem = {
			Image = "rbxassetid://501403413",
			Offset = Vector2.new(480, 0),
			Size = Vector2.new(240, 240),
			Color = Color3.new(0, 1, .467),
		},
		candy = { Image = "rbxassetid://511701551" },
		shiny = { Image = "rbxassetid://76387801397445", Offset = Vector2.new(400, 200), Size = Vector2.new(200, 200) },
	};
local function f(P, j, Y, X)
	return { Glyph = P, Color = Color3.fromRGB(j, Y, X) };
end;
local n = {
		{ Title = "Coins & Shinies", Items = {
				{
					Key = "Coin_copper",
					Name = "Copper Coin",
					Icon = v.credit(Color3.fromRGB(222, 140, 80)),
					Selected = true,
				},
				{
					Key = "Coin_silver",
					Name = "Silver Coin",
					Icon = v.credit(Color3.fromRGB(210, 214, 224)),
					Selected = true,
				},
				{
					Key = "Coin_gold",
					Name = "Gold Coin",
					Icon = v.credit(),
					Selected = true,
				},
				{
					Key = "Coin_rosegold",
					Name = "Rosegold Coin",
					Icon = v.credit(Color3.fromRGB(255, 156, 150)),
					Selected = true,
				},
				{
					Key = "Coin_red",
					Name = "Red Coin",
					Icon = v.credit(Color3.fromRGB(235, 72, 72)),
					Selected = true,
				},
				{
					Key = "EventIcon",
					Name = "Event Icon",
					Icon = f("\226\152\133", 230, 190, 60),
					Selected = false,
				},
				{
					Key = "ShinyRock",
					Name = "Shiny Rock",
					Icon = f("\226\156\166", 120, 200, 230),
					Selected = true,
				},
			} },
		{ Title = "Event", Items = { {
					Key = "HalloweenCandy",
					Name = "Halloween Candy",
					Icon = v.candy,
					Selected = true,
				} } },
		{ Title = "Boost (permanent relics)", Items = {
				{
					Key = "StatUp_Speed",
					Name = "Speed Relic",
					Icon = f("S", 70, 120, 200),
					Selected = true,
				},
				{
					Key = "StatUp_Jump",
					Name = "Jump Relic",
					Icon = f("J", 70, 160, 110),
					Selected = true,
				},
				{
					Key = "StatUp_Charge",
					Name = "Charge Relic",
					Icon = f("C", 200, 160, 60),
					Selected = true,
				},
				{
					Key = "StatUp_Health",
					Name = "Health Relic",
					Icon = f("H", 200, 70, 80),
					Selected = true,
				},
				{
					Key = "StatUp_Defense",
					Name = "Defense Relic",
					Icon = f("D", 120, 120, 140),
					Selected = true,
				},
			} },
		{ Title = "Power-ups", Items = {
				{
					Key = "CrystalShield",
					Name = "Crystal Shield",
					Icon = f("\226\151\134", 120, 200, 230),
					Selected = true,
				},
				{
					Key = "FireShield",
					Name = "Fire Shield",
					Icon = f("\226\151\134", 230, 120, 60),
					Selected = true,
				},
				{
					Key = "MagicShield",
					Name = "Magic Shield",
					Icon = f("\226\151\134", 170, 110, 230),
					Selected = true,
				},
				{
					Key = "SuperSoda",
					Name = "Supercharge Soda",
					Icon = f("S", 90, 170, 230),
					Selected = false,
				},
				{
					Key = "SpamSoda",
					Name = "Spam Soda",
					Icon = f("S", 230, 90, 150),
					Selected = false,
				},
				{
					Key = "Pizza",
					Name = "Pizza",
					Icon = f("P", 230, 170, 70),
					Selected = true,
				},
				{
					Key = "PizzaBox",
					Name = "Pizza Box",
					Icon = f("P", 190, 130, 70),
					Selected = true,
				},
				{
					Key = "SizeChanger_Grow",
					Name = "Grow",
					Icon = f("+", 90, 90, 110),
					Selected = false,
				},
				{
					Key = "SizeChanger_Shrink",
					Name = "Shrink",
					Icon = f("\226\128\147", 90, 90, 110),
					Selected = false,
				},
			} },
	};
local C = {};
for P, j in ipairs(n) do
	for P, j in ipairs(j.Items) do
		C[j.Key] = j;
		V.selected[j.Key] = j.Selected;
	end;
end;
do
	local P, j = pcall(function()
			return M:JSONDecode(readfile(O));
		end);
	if P and type(j) == "table" then
		if type(j.selected) == "table" then
			for P, j in pairs(j.selected) do
				if C[P] then
					V.selected[P] = j and true or false;
				end;
			end;
		end;
		if j.dodge ~= nil then
			V.dodgeOn = j.dodge and true or false;
		end;
		if j.collect ~= nil then
			V.collectOn = j.collect and true or false;
		end;
		if j.hardcoreOn ~= nil then
			V.hardcoreOn = j.hardcoreOn and true or false;
		end;
		if type(j.uiKey) == "string" and Enum.KeyCode[j.uiKey] then
			V.uiKey = Enum.KeyCode[j.uiKey];
		end;
		if type(j.finalSkill) == "number" then
			V.finalSkill = j.finalSkill;
		end;
		for P, Y in ipairs({
			"flyOn",
			"bringOn",
			"bombCtlOn",
			"autoSkill",
			"autoClaim",
			"voidOn",
		}) do
			if j[Y] ~= nil then
				V[Y] = j[Y] and true or false;
			end;
		end;
	end;
end;
local function D()
	pcall(function()
		writefile(O, M:JSONEncode({
			selected = V.selected,
			dodge = V.dodgeOn,
			collect = V.collectOn,
			flyOn = V.flyOn,
			bringOn = V.bringOn,
			bombCtlOn = V.bombCtlOn,
			autoSkill = V.autoSkill,
			finalSkill = V.finalSkill,
			autoClaim = V.autoClaim,
			hardcoreOn = V.hardcoreOn,
			voidOn = V.voidOn,
			uiKey = V.uiKey and V.uiKey.Name or nil,
		}));
	end);
end;
local i = z:WaitForChild("Remotes");
local K = i:WaitForChild("FloorObjectInteraction");
local y = i:WaitForChild("LocalObjectInteraction");
local k = z:WaitForChild("NotThere");
local A;
A = hookmetamethod(game, "__namecall", newcclosure(function(P, ...)
		if V.running and (not checkcaller() and getnamecallmethod() == "FireServer") then
			if P == k and (...) == true then
				return nil;
			end;
			if P == K then
				V.blockedFloor = V.blockedFloor + 1;
				return nil;
			end;
			if P == y then
				local P = ...;
				if typeof(P) == "Instance" and P:HasTag("LocalLava") then
					V.blockedLava = V.blockedLava + 1;
					return nil;
				end;
			end;
		end;
		return A(P, ...);
	end));
local p = { ZapTrap = 12, ClusterBomb = 20 };
local T = { GrimRadius = 6, PoisonCloud = 6, ToxicTrap = 5 };
local function B(P)
	if p[P.Name] then
		return true;
	end;
	if P:GetAttribute("DisarmBonus") ~= nil then
		return true;
	end;
	return P:FindFirstChild("BombName") ~= nil;
end;
local function x(P)
	local j = P.Name;
	if p[j] then
		return p[j];
	end;
	if j == "Grimbell" then
		return 64;
	end;
	if string.find(j, "Nuke") then
		return 62;
	end;
	if string.find(j, "Rocket") or string.find(j, "Homing") or string.find(j, "Chaser") then
		return 36;
	end;
	if string.find(j, "Big") or string.find(j, "Mega") then
		return 40;
	end;
	return 28;
end;
local c = setmetatable({}, { __mode = "k" });
local function G(P)
	if P:IsA("BasePart") then
		return P.Position, P.AssemblyLinearVelocity;
	end;
	if P:IsA("Model") then
		local j = P.PrimaryPart or P:FindFirstChildWhichIsA("BasePart");
		return (P:GetPivot()).Position, j and j.AssemblyLinearVelocity or Vector3.zero;
	end;
	return nil;
end;
local a = RaycastParams.new();
a.FilterType = Enum.RaycastFilterType.Exclude;
a.RespectCanCollide = true;
a.IgnoreWater = true;
local function w(P)
	local Y = { q, S };
	for P, j in ipairs(j:GetPlayers()) do
		if j.Character then
			table.insert(Y, j.Character);
		end;
	end;
	if P then
		table.insert(Y, P);
	end;
	a.FilterDescendantsInstances = Y;
end;
local function l(P, j, Y, X)
	if Y.Y > -3 then
		return j;
	end;
	local M = V.landCache[P];
	if M and X - M.t < .25 then
		return Vector3.new(j.X, M.y, j.Z);
	end;
	local z = workspace:Raycast(j, Vector3.new(0, -500, 0), a);
	local o = z and z.Position.Y or j.Y;
	V.landCache[P] = { t = X, y = o };
	return Vector3.new(j.X, o, j.Z);
end;
local L = { "Burning", "Electric" };
local function Z(P, j)
	local Y = {};
	local M = {};
	for P, j in ipairs(V.blasts) do
		if os.clock() - j.t < j.life then
			table.insert(M, j);
			table.insert(Y, {
				p = j.p,
				r = j.r,
				n = "blast",
				raw = j.p,
				v = Vector3.zero,
			});
		end;
	end;
	V.blasts = M;
	for j, M in ipairs(L) do
		for j, X in ipairs(X:GetTagged(M)) do
			if X:IsA("BasePart") and X:IsDescendantOf(workspace) then
				local j = (Vector3.new(X.Position.X - P.X, 0, X.Position.Z - P.Z)).Magnitude;
				local z = math.max(X.Size.X, X.Size.Z) / 2;
				if j < 60 + z then
					table.insert(Y, {
						box = X.CFrame,
						size = X.Size / 2,
						r = 4,
						p = X.Position,
						n = M .. (":" .. X.Name),
						raw = X.Position,
						v = Vector3.zero,
					});
				end;
			end;
		end;
	end;
	for X, M in ipairs(q:GetChildren()) do
		if T[M.Name] and M:IsA("BasePart") then
			table.insert(Y, {
				box = M.CFrame,
				size = M.Size / 2,
				r = T[M.Name],
				p = M.Position,
				n = M.Name,
				raw = M.Position,
				v = Vector3.zero,
			});
		elseif B(M) then
			local X, z = G(M);
			if X then
				local o = c[M];
				if z.Magnitude < .5 and (o and j - o.t > .05) then
					local P = ((X - o.p)) / ((j - o.t));
					if P.Magnitude < 200 then
						z = P;
					end;
				end;
				c[M] = { p = X, t = j };
				local q = (Vector3.new(X.X - P.X, 0, X.Z - P.Z)).Magnitude;
				if q < 120 then
					local P = x(M);
					table.insert(Y, {
						p = l(M, X, z, j),
						r = P,
						n = M.Name,
						raw = X,
						v = z,
					});
					if z.Y < -3 then
						table.insert(Y, { p = X, r = 10 });
					end;
					local o = Vector3.new(z.X, 0, z.Z);
					if o.Magnitude > 4 then
						table.insert(Y, { p = X + z * .6, r = P });
						table.insert(Y, { p = X + z * 1.2, r = P });
					end;
				end;
			end;
		end;
	end;
	return Y;
end;
local function t(P, j)
	local Y = math.huge;
	for j, X in ipairs(j) do
		local M;
		if X.box then
			local j = X.box:PointToObjectSpace(P);
			local Y = Vector3.new(math.clamp(j.X, -X.size.X, X.size.X), math.clamp(j.Y, -X.size.Y, X.size.Y), math.clamp(j.Z, -X.size.Z, X.size.Z));
			M = ((j - Y)).Magnitude - X.r;
		else
			M = ((P - X.p)).Magnitude - X.r;
		end;
		if M < Y then
			Y = M;
		end;
	end;
	return Y;
end;
local function F(P, j)
	local Y = Vector3.new(P.X, j + 4, P.Z);
	local X = workspace:Raycast(Y, Vector3.new(0, -30, 0), a);
	if not X or X.Instance:HasTag("LocalLava") or X.Instance:HasTag("Burning") or X.Instance:HasTag("Electric") then
		return nil;
	end;
	if X.Position.Y < j - 12 then
		return nil;
	end;
	return Vector3.new(P.X, X.Position.Y + 3, P.Z);
end;
local E = 16;
local d = {
		8,
		16,
		26,
		38,
		55,
		75,
		95,
	};
local function U(P, j)
	local Y = Vector3.new(j.X, P.Y, j.Z) - P;
	if Y.Magnitude < .5 then
		return true;
	end;
	return workspace:Raycast(P, Y, a) == nil;
end;
local function R(P, j)
	local Y = j - P;
	if Y.Magnitude < .5 then
		return true;
	end;
	return workspace:Raycast(P, Y, a) == nil;
end;
local function u(P, j)
	local Y = P.Position;
	local X, M = nil, t(Y, j);
	local z = M;
	for P = 1, E, 1 do
		local z = (((P / E)) * math.pi) * 2;
		local o = Vector3.new(math.cos(z), 0, math.sin(z));
		for P, z in ipairs(d) do
			local q = F(Y + o * z, Y.Y);
			if q and not U(Y, q) then
				break;
			end;
			if q then
				local P = t(q, j) - z * .08;
				if P > M then
					M = P;
					X = q;
				end;
			end;
		end;
	end;
	return X, z;
end;
local g = 12;
local r = {
		0,
		10,
		20,
		32,
		48,
		70,
	};
local s = {
		0,
		14,
		28,
		42,
		-14,
	};
local I = OverlapParams.new();
I.FilterType = Enum.RaycastFilterType.Exclude;
I.RespectCanCollide = true;
local function h(P)
	I.FilterDescendantsInstances = a.FilterDescendantsInstances;
	return #workspace:GetPartBoundsInRadius(P, 2.5, I) > 0;
end;
local N = 55;
local function J()
	if game.PrivateServerId ~= "" then
		return "private";
	end;
	if #j:GetPlayers() <= 1 then
		return "solo";
	end;
	return "public";
end;
local function m()
	local P = workspace:GetAttribute("DefaultCeilingHeight");
	return ((type(P) == "number" and P or 295)) - 15;
end;
local function H(P)
	local j = workspace:Raycast(P, Vector3.new(0, -400, 0), a);
	return j and j.Position.Y;
end;
local function b(P, j, Y)
	local X = P.Position;
	local M = not Y and H(X) or nil;
	local z = t(X, j);
	local o, q = nil, z;
	for P = 1, g, 1 do
		local Y = (((P / g)) * math.pi) * 2;
		local z = Vector3.new(math.cos(Y), 0, math.sin(Y));
		for Y, S in ipairs(r) do
			if S > 0 or P == 1 then
				for P, Y in ipairs(s) do
					local W = (X + z * S) + Vector3.new(0, Y, 0);
					local O = W.Y <= m() and ((not M or (W.Y <= M + N and W.Y >= M + 2)));
					local V = t(W, j) - ((S + math.abs(Y))) * .06;
					if O and (V > q and (R(X, W) and not h(W))) then
						q = V;
						o = W;
					end;
				end;
			end;
		end;
	end;
	return o, z;
end;
local function Q(P)
	if V.moving then
		V.moving = false;
		V.mode = nil;
		V.target = nil;
		V.item = nil;
		P:Move(Vector3.zero, false);
	end;
end;
local function Py(P)
	local j = {};
	if P:IsA("BasePart") and P:FindFirstChildOfClass("TouchTransmitter") then
		table.insert(j, P);
	end;
	for P, Y in ipairs(P:GetDescendants()) do
		if Y:IsA("BasePart") and Y:FindFirstChildOfClass("TouchTransmitter") then
			table.insert(j, Y);
		end;
	end;
	return j;
end;
local jy = { Pizza = true, PizzaBox = true };
local Yy = { CrystalShield = true, FireShield = true, MagicShield = true };
local function Xy(P)
	if not P then
		return false;
	end;
	if P:FindFirstChild("CrystalBubble") or P:FindFirstChild("FireBubble") or P:FindFirstChild("MagicBubbleFF") then
		return true;
	end;
	return P:GetAttribute("MagicShielded") == true;
end;
local function My()
	for P in pairs(V.tries) do
		if Yy[P.Name] and P.Parent then
			return true;
		end;
	end;
	return false;
end;
local function zy(P, j, Y)
	if not V.selected[P.Name] or not P.Parent then
		return false;
	end;
	local X = o.Character;
	if P.Name == "EventIcon" and V.hcNow then
		return false;
	end;
	if jy[P.Name] then
		local P = X and X:FindFirstChildOfClass("Humanoid");
		if not P or P.Health > P.MaxHealth * .5 then
			return false;
		end;
	end;
	if Yy[P.Name] and ((Xy(X) or My())) then
		return false;
	end;
	if P:GetAttribute("Collected") or P:GetAttribute("Debounce") == true then
		return false;
	end;
	if Y and P:GetAttribute("LocalItem_Type") then
		return false;
	end;
	local M = V.skip[P];
	if M and j < M then
		return false;
	end;
	return true;
end;
local function oy(P, j, Y, X)
	local M, z = nil, math.huge;
	for o, q in ipairs(q:GetChildren()) do
		if zy(q, Y, X) and not V.tries[q] then
			local Y = G(q);
			if Y then
				local X = ((Y - P.Position)).Magnitude;
				if X < z and (X < 300 and (((#j == 0 or t(Y, j) >= 6)) and R(P.Position, Y))) then
					M, z = q, X;
				end;
			end;
		end;
	end;
	return M, z;
end;
local function qy(P, j, Y)
	local X = V.tries[j];
	if not X then
		X = { first = Y, lastTouch = 0, name = j.Name };
		V.tries[j] = X;
	end;
	if Y - X.lastTouch < .3 then
		return;
	end;
	X.lastTouch = Y;
	for j, Y in ipairs(Py(j)) do
		firetouchinterest(P, Y, 0);
		firetouchinterest(P, Y, 1);
	end;
	local M = j:GetAttribute("LocalItem_Type");
	if ((M == "Coin" or M == "Pizza" or M == "Taco")) and (not X.reported and j:IsA("BasePart")) then
		X.reported = true;
		y:FireServer(j);
	end;
end;
local function Sy(P)
	for j, Y in pairs(V.tries) do
		if not j.Parent or j:GetAttribute("Collected") then
			V.tries[j] = nil;
			V.collected = V.collected + 1;
			V.collectedBy[Y.name] = ((V.collectedBy[Y.name] or 0)) + 1;
			e("collected " .. Y.name);
		elseif P - Y.first > 3 then
			V.tries[j] = nil;
			V.skip[j] = P + 20;
			V.failed = V.failed + 1;
			e("could not collect " .. (Y.name .. " (skipping 20s)"));
		end;
	end;
end;
local function Wy()
	local P, j = pcall(function()
			return (getrenv())._G.MyData.stats;
		end);
	if P and type(j) == "table" then
		return j;
	end;
	return nil;
end;
local Oy = "SBSHubTotals.json";
local Vy = {
		"credits",
		"gems",
		"hcandy",
		"shinies",
	};
local ey = {
		rounds = 0,
		survived = 0,
		died = 0,
		credits = 0,
		gems = 0,
		hcandy = 0,
		shinies = 0,
		items = 0,
		history = {},
	};
do
	local P, j = pcall(function()
			return M:JSONDecode(readfile(Oy));
		end);
	if P and type(j) == "table" then
		for P, j in pairs(j) do
			ey[P] = j;
		end;
		if type(ey.history) ~= "table" then
			ey.history = {};
		end;
	end;
end;
local function vy()
	local P, j = pcall(function()
			writefile(Oy, M:JSONEncode(ey));
		end);
	if not P then
		e("saving totals failed: " .. tostring(j));
	end;
end;
local fy = { 100, 300 };
local ny = 300;
local Cy = { [4] = true, [66] = true };
local Dy = nil;
do
	local P = getthreadidentity and getthreadidentity();
	if setthreadidentity then
		setthreadidentity(2);
	end;
	local j, Y = pcall(function()
			return (require((z:WaitForChild("InfoModules")):WaitForChild("Skills"))).Info;
		end);
	if setthreadidentity and P then
		setthreadidentity(P);
	end;
	if j then
		Dy = Y;
	else
		e("skill info require failed: " .. tostring(Y));
	end;
end;
local iy = i:WaitForChild("swapSkill");
local Ky = "rbxassetid://134921135570827";
local function yy(P)
	local j = Dy and Dy[P];
	if not j or not j.image then
		return { Glyph = "?", Color = Color3.fromRGB(60, 60, 72) };
	end;
	return { Image = Ky, Offset = j.image * 100, Size = Vector2.new(100, 100) };
end;
local function ky(P)
	local j = o:FindFirstChild("skill");
	local Y = j and j:FindFirstChild("sk" .. P);
	return Y and Y.Value or 0;
end;
local function Ay()
	local P = {};
	local j = o:FindFirstChild("skill");
	if not j or not Dy then
		return P;
	end;
	for Y = 1, #Dy, 1 do
		local X = j:FindFirstChild("sk" .. Y);
		if X and (X.Value >= 1 and not Cy[Y]) then
			table.insert(P, { id = Y, xp = X.Value, info = Dy[Y] });
		end;
	end;
	return P;
end;
local function py(P)
	local j, Y = nil, math.huge;
	for P, X in ipairs(P) do
		local M = X.info.cooldown and X.info.cooldown[3] or 99;
		local z = X.info.type == "M" or X.info.type == "D";
		if X.xp >= ny and (z and M < Y) then
			j, Y = X.id, M;
		end;
	end;
	return j;
end;
local function Ty(P, j)
	local Y, X = nil, -1;
	for P, M in ipairs(P) do
		if M.xp < ny and (M.id ~= j and M.xp > X) then
			Y, X = M.id, M.xp;
		end;
	end;
	return Y;
end;
local By = P.Window({
		Title = "Aimia - Super Bomb Survival",
		Size = UDim2.fromOffset(680, 560),
		Nav = "top",
		ToggleKey = V.uiKey or Enum.KeyCode.RightControl,
		OnClose = function()
			if (getgenv()).SBSHubStop then
				(getgenv()).SBSHubStop();
			end;
		end,
	});
local xy = {
		{ Key = "credits", Label = "Coins", Icon = v.credit() },
		{ Key = "gems", Label = "Gems", Icon = v.gem },
		{ Key = "hcandy", Label = "Candy", Icon = v.candy },
		{ Key = "shinies", Label = "Shinies", Icon = v.shiny },
	};
local cy = { { Key = "credits", Icon = v.credit() }, { Key = "gems", Icon = v.gem }, { Key = "hcandy", Icon = v.candy } };
local Gy = {};
do
	local P = By:Tab("Overview");
	Gy.card = P:StatusCard();
	Gy.streak = P:StreakCard(10);
	P:Section("Balance \194\183 gained this round");
	Gy.tiles = P:StatTiles(xy, 4);
	P:Section("Round results");
	Gy.log = P:RoundLog(cy, 8);
	local j = By:Tab("Collect");
	Gy.grids = {};
	for P, Y in ipairs(n) do
		local X = {};
		for P, j in ipairs(Y.Items) do
			table.insert(X, {
				Key = j.Key,
				Name = j.Name,
				Icon = j.Icon,
				Selected = V.selected[j.Key],
			});
		end;
		local M = j:ItemGrid(Y.Title, X, function(P, j)
				V.selected[P] = j;
				D();
			end, 4);
		for P, j in ipairs(Y.Items) do
			Gy.grids[j.Key] = M;
		end;
	end;
	local Y = By:Tab("Skills");
	Y:Toggle("Auto level skills", V.autoSkill, function(P)
		V.autoSkill = P;
		D();
	end, "Swap to an unfinished skill when the equipped one hits LVL 3");
	Gy.skillHero = Y:SkillHero();
	local X = {
			{ Type = "O", Title = "Offense", Color = Color3.fromRGB(255, 0, 89) },
			{ Type = "M", Title = "Movement", Color = Color3.fromRGB(116, 255, 57) },
			{ Type = "D", Title = "Defense", Color = Color3.fromRGB(98, 106, 255) },
			{ Type = "N", Title = "Other", Color = Color3.fromRGB(140, 93, 12) },
		};
	local M = Ay();
	local function z(P)
		V.finalSkill = P;
		D();
		local j = Dy and Dy[P];
		By:Notify("Final skill: " .. ((j and j.name or tostring(P))), "Good", 3);
	end;
	Gy.skillGrids = {};
	local q = {};
	for P, j in ipairs(X) do
		local X = {};
		for P, Y in ipairs(M) do
			if Y.info.type == j.Type then
				table.insert(X, {
					Key = Y.id,
					Name = Y.info.name,
					Icon = yy(Y.id),
					Color = j.Color,
				});
			end;
		end;
		if #X > 0 then
			Y:Section(j.Title .. (" \194\183 " .. #X), j.Color);
			local P = Y:SkillGrid(X, z, 4, fy);
			table.insert(q, P);
			for j, Y in ipairs(X) do
				Gy.skillGrids[Y.Key] = P;
			end;
		end;
	end;
	Gy.skillGrid = { Update = function(P, j, Y)
				local X = Gy.skillGrids[j];
				if X then
					X:Update(j, Y);
				end;
			end };
	local S = By:Tab("Settings");
	S:Section("Mode");
	do
		local P = o:FindFirstChild("options");
		local j = P and P:FindFirstChild("hardcore");
		if V.hardcoreOn == nil then
			V.hardcoreOn = j and j.Value or false;
		end;
	end;
	S:DangerToggle("Hardcore mode", V.hardcoreOn, function(P)
		V.hardcoreOn = P;
		V.lastHcSet = 0;
		D();
		if P then
			By:Notify("Hardcore on \194\183 35 HP, perks off \194\183 some rounds will be lost", "Bad", 5);
		end;
	end, "More credits per round \194\183 35 HP, perks off \194\183 expect to lose some rounds", "RISKY");
	Gy.voidCard = S:DangerToggle("Void bombs", V.voidOn, function(P)
			V.voidOn = P;
			D();
		end, "Drops every bomb you control under the map", "FOR PRIVATE SERVER", { Color = Color3.fromRGB(150, 110, 255), Glyph = "\195\152", Note = true });
	S:Section("Survival");
	S:Toggle("Auto dodge", V.dodgeOn, function(P)
		V.dodgeOn = P;
		D();
	end, "Move out of every predicted blast, fire and electric zone");
	S:Toggle("Fly freely", V.flyOn, function(P)
		V.flyOn = P;
		if not P then
			V.hold = nil;
		end;
		D();
	end, "Dodge in 3D and hover in the air instead of staying on the floor");
	S:Toggle("Slow + push away bombs", V.bombCtlOn, function(P)
		V.bombCtlOn = P;
		D();
	end, "Bombs you own the physics of fall slowly and get pushed out of range");
	S:Section("Farming");
	S:Toggle("Auto collect", V.collectOn, function(P)
		V.collectOn = P;
		D();
	end, "Go after the items picked in the Collect tab when it is safe");
	S:Toggle("Bring items to me", V.bringOn, function(P)
		V.bringOn = P;
		D();
	end, "Pull items you own the physics of straight onto your character");
	S:Toggle("Auto claim challenges", V.autoClaim, function(P)
		V.autoClaim = P;
		D();
	end, "Claim hourly, daily and VIP gem rewards as soon as they are done");
	Gy.challenges = S:Status("Challenges");
	S:Section("Results");
	S:Button("Reset total results", function()
		ey = {
				rounds = 0,
				survived = 0,
				died = 0,
				credits = 0,
				gems = 0,
				hcandy = 0,
				shinies = 0,
				items = 0,
				history = {},
			};
		vy();
		By:Notify("Total results reset", "Warn", 3);
	end);
	S:Section("Interface");
	S:Keybind("Show / hide key", By:GetToggleKey(), function(P)
		V.uiKey = P;
		By:SetToggleKey(P);
		D();
		By:Notify("Show / hide key: " .. P.Name, "Good", 4);
	end, "Click, then press the key you want. Esc cancels");
end;
do
	local j = (getgenv()).SBSIconCache or {};
	(getgenv()).SBSIconCache = j;
	local Y = {};
	local function X(P, Y)
		if j[P] then
			return;
		end;
		local X, M = pcall(function()
				local P = Y.Archivable;
				Y.Archivable = true;
				local j = Y:Clone();
				Y.Archivable = P;
				return j;
			end);
		if X and M then
			j[P] = M;
		end;
	end;
	local function M(j, X)
		local M = C[j];
		local z = Gy.grids[j];
		if Y[j] or not M or not z or not ((M.Icon and M.Icon.Glyph)) then
			return;
		end;
		local o, q = pcall(P.viewport, z:IconHolder(j), X);
		if o then
			Y[j] = true;
		else
			e("icon for " .. (j .. (" failed: " .. tostring(q))));
		end;
	end;
	pcall(function()
		local P = z:FindFirstChild("Decor");
		local j = P and P:FindFirstChild("Pizza");
		if j then
			X("Pizza", j);
		end;
	end);
	pcall(function()
		for P, j in ipairs(o.PlayerGui:GetDescendants()) do
			if j:IsA("ViewportFrame") and (j.Parent and C[j.Parent.Name]) then
				local P = j:FindFirstChild("Object") or j:FindFirstChildWhichIsA("Model") or j:FindFirstChildWhichIsA("BasePart");
				if P then
					X(j.Parent.Name, P);
				end;
			end;
		end;
	end);
	for P, j in pairs(j) do
		M(P, j);
	end;
	task.spawn(function()
		local P = {};
		while V.running and By.Alive do
			for z, o in ipairs(q:GetChildren()) do
				local q = o.Name;
				if C[q] then
					if not P[q] then
						P[q] = true;
						local j = o:GetAttribute("ObjName");
						local Y = Gy.grids[q];
						if Y and j then
							Y:SetName(q, j);
						end;
					end;
					if not j[q] then
						X(q, o);
					end;
					if not Y[q] and j[q] then
						M(q, j[q]);
					end;
				end;
			end;
			task.wait(1);
		end;
	end);
end;
local ay = i:WaitForChild("challengeGem");
local wy = { "hourly", "daily", "vip" };
local function ly()
	local P, j = pcall(function()
			return (getrenv())._G.MyData;
		end);
	if not P or type(j) ~= "table" or type(j.challenges) ~= "table" then
		return;
	end;
	local Y = type(j.options) == "table" and j.options.vip == true;
	local X = {};
	local M = os.clock();
	for P, z in ipairs(wy) do
		local o = j.challenges[z];
		if type(o) == "table" then
			local P = ((o.complete or 0)) >= ((o.num or 1));
			local j;
			if z == "vip" and not Y then
				j = "needs VIP pass";
			elseif o.rewarded then
				j = "claimed \226\156\147";
			elseif P then
				j = "ready";
				if V.autoClaim and M - ((V.lastClaim[z] or 0)) > 15 then
					V.lastClaim[z] = M;
					local P, Y = pcall(function()
							return ay:InvokeServer(z);
						end);
					if P and Y == true then
						V.claimed = V.claimed + 1;
						j = "claimed \226\156\147";
						e("claimed " .. (z .. (" challenge: " .. tostring(o.name))));
						By:Notify("Claimed " .. (z .. " challenge"), "Good", 4);
					else
						j = "claim failed: " .. tostring(Y);
						e("claim " .. (z .. (" failed: " .. tostring(Y))));
					end;
				end;
			else
				j = string.format("%d/%d", o.complete or 0, o.num or 0);
			end;
			table.insert(X, string.format("%s \194\183 %s \194\183 %s", string.upper(z), tostring(o.name), j));
		end;
	end;
	table.insert(X, string.format("Claimed by the hub this session: %d", V.claimed));
	Gy.challenges:Set(table.concat(X, "\n"));
end;
local Ly = i:WaitForChild("chooseOption");
local function Zy()
	local P = o:FindFirstChild("options");
	local j = P and P:FindFirstChild("hardcore");
	if not j or V.hardcoreOn == nil or j.Value == V.hardcoreOn then
		return;
	end;
	local Y = Wy();
	if V.hardcoreOn and (Y and ((Y.wins or 0)) < 50) then
		return;
	end;
	if os.clock() - V.lastHcSet < 10 then
		return;
	end;
	V.lastHcSet = os.clock();
	Ly:FireServer("hc", V.hardcoreOn);
	e("hardcore option -> " .. tostring(V.hardcoreOn));
end;
task.spawn(function()
	while V.running and By.Alive do
		local P, Y = pcall(function()
				local P = Ay();
				local j = o:FindFirstChild("skill");
				local Y = o:FindFirstChild("nextSkill");
				local X = j and j.Value or 0;
				local M = Y and Y.Value or -1;
				local z = V.finalSkill;
				local q = false;
				for P, j in ipairs(P) do
					if j.id == z then
						q = true;
					end;
				end;
				if not q then
					z = py(P);
				end;
				local S = os.clock();
				if V.autoSkill and Dy then
					local j = nil;
					if X <= 0 or ky(X) >= ny then
						j = Ty(P, X) or z;
					end;
					if not j then
						V.skillNote = X > 0 and "Levelling this skill \194\183 swaps at LVL 3" or "";
					elseif j == X then
						V.skillNote = "Every skill is MAX \194\183 using the final skill";
					elseif j == M then
						V.skillNote = "Equips " .. (Dy[j].name .. " on respawn");
					elseif S - V.lastSwap > 10 then
						V.lastSwap = S;
						local P, Y = pcall(function()
								return iy:InvokeServer("skill", j, ky(j), false);
							end);
						local X = Dy[j].name;
						if not P then
							e("swapSkill error: " .. tostring(Y));
							V.skillNote = "Swap failed: " .. tostring(Y);
						elseif Y == "NEXT" then
							e("skill " .. (X .. " equips on respawn"));
							V.skillNote = "Equips " .. (X .. " on respawn");
						elseif type(Y) == "string" then
							e("swapSkill refused: " .. Y);
							V.skillNote = "Swap refused: " .. Y;
						else
							e("equipped skill " .. X);
							V.skillNote = "Equipped " .. X;
						end;
					end;
				else
					V.skillNote = "Auto level is off";
				end;
				for P, j in ipairs(P) do
					Gy.skillGrid:Update(j.id, {
						Xp = j.xp,
						Equipped = j.id == X,
						Next = j.id == M and M ~= X,
						Final = j.id == z,
					});
				end;
				local W = Dy and Dy[X];
				Gy.skillHero:Set({
					Icon = X > 0 and yy(X) or nil,
					Name = W and W.name or "No skill",
					Xp = X > 0 and ky(X) or 0,
					Thresholds = fy,
					Note = V.skillNote,
				});
			end);
		pcall(Zy);
		do
			local P = J();
			V.voidAllowed = P ~= "public";
			local Y = #j:GetPlayers();
			local X;
			if P == "private" then
				X = "Private server \194\183 void bombs available";
			elseif P == "solo" then
				X = "Public server, only you here \194\183 void bombs available";
			else
				X = string.format("Public server \194\183 %d players \194\183 void bombs paused", Y);
			end;
			Gy.voidCard:SetNote(X, V.voidAllowed and "Good" or "Warn");
			if Gy.voidCard.Locked ~= not V.voidAllowed then
				Gy.voidCard:SetLocked(not V.voidAllowed, "Void bombs only works in a private server or when you are alone");
				if V.voidAllowed and (V.voidOn and not Gy.voidCard.Value) then
					Gy.voidCard:Set(true, true);
				end;
			end;
		end;
		local X, M = pcall(ly);
		if not X and M ~= V.lastClaimErr then
			V.lastClaimErr = M;
			e("challenge loop error: " .. tostring(M));
		end;
		if not P and Y ~= V.lastSkillErr then
			V.lastSkillErr = Y;
			e("skill loop error: " .. tostring(Y));
		end;
		task.wait(2);
	end;
end);
table.insert(V.conns, (i:WaitForChild("scorecard")).OnClientEvent:Connect(function(P, j, Y, X, M)
	V.lastCard = {
			pts = P,
			bonus = j,
			mult1 = Y,
			mult2 = X,
			total = M,
		};
	e(string.format("scorecard: points %s bonus %s x%s x%s total %s", tostring(P), tostring(j), tostring(Y), tostring(X), tostring(M)));
end));
local function ty(P)
	if P < 3 then
		return 0;
	end;
	return math.min(100, ((P - 2)) * 5);
end;
table.insert(V.conns, S.ChildAdded:Connect(function(P)
	if P:IsA("Explosion") then
		local j = P.BlastRadius;
		if not V.radii[P.Name] or j > V.radii[P.Name] then
			V.radii[P.Name] = j;
		end;
		local Y = o.Character;
		local X = Y and Y:FindFirstChild("HumanoidRootPart");
		if P.Position.Y < workspace.FallenPartsDestroyHeight + 50 then
			V.voidBlasts = V.voidBlasts + 1;
		end;
		local M = P.Name == "nuke";
		local z = os.clock();
		table.insert(V.blasts, {
			p = P.Position,
			r = M and 58 or (j + 6),
			t = z,
			life = M and 3 or .6,
		});
		local q = V.lastBlast[P.Name];
		if q and z - q.t < 1.5 then
			local Y = P.Position - q.p;
			local X = Y.Magnitude;
			if X > 4 and X < 25 then
				for X = 1, 10, 1 do
					table.insert(V.blasts, {
						p = P.Position + Y * X,
						r = math.max(j, 16) + 6,
						t = z,
						life = 2.5,
					});
				end;
				if not V.lineLogged or z - V.lineLogged > 3 then
					V.lineLogged = z;
					e(string.format("carpet line: %s step %.1f studs every %.2fs", P.Name, X, z - q.t));
				end;
			end;
		end;
		V.lastBlast[P.Name] = { p = P.Position, t = z };
		if X then
			local Y = ((X.Position - P.Position)).Magnitude;
			table.insert(V.recent, {
				t = os.clock(),
				name = P.Name,
				r = j,
				d = Y,
			});
			if #V.recent > 30 then
				table.remove(V.recent, 1);
			end;
		end;
	end;
end));
local function Fy(P)
	local j = tostring(math.floor(P));
	local Y = ((j:reverse()):gsub("(%d%d%d)", "%1,")):reverse();
	if Y:sub(1, 1) == "," then
		Y = Y:sub(2);
	end;
	return Y;
end;
local Ey = 8;
local function dy(P)
	local j = V.round;
	for Y, X in ipairs(Vy) do
		local M = P[X] or 0;
		local z = M - ((j.last[X] or M));
		if z > 0 then
			j.gain[X] = ((j.gain[X] or 0)) + z;
		end;
		j.last[X] = M;
	end;
end;
local function Uy(P)
	local j = V.round;
	dy(P);
	local Y = { items = V.collected - j.items0 };
	for P, X in ipairs(Vy) do
		Y[X] = j.gain[X] or 0;
	end;
	return Y;
end;
local function Ry(P)
	local j = V.round;
	local Y = Uy(P);
	V.round = nil;
	ey.rounds = ey.rounds + 1;
	if j.died then
		ey.died = ey.died + 1;
	else
		ey.survived = ey.survived + 1;
	end;
	for P, j in pairs(Y) do
		ey[P] = ((ey[P] or 0)) + j;
	end;
	if j.hc then
		ey.hcRounds = ((ey.hcRounds or 0)) + 1;
	end;
	table.insert(ey.history, 1, {
		n = ey.rounds,
		died = j.died,
		d = Y,
		hc = j.hc,
	});
	while #ey.history > 10 do
		table.remove(ey.history);
	end;
	vy();
	e(string.format("round %d %s%s: coins %+d gems %+d candy %+d shinies %+d items %d", ey.rounds, j.hc and "HARDCORE " or "", j.died and "died" or "survived", Y.credits, Y.gems, Y.hcandy, Y.shinies, Y.items));
	By:Notify(string.format("%sRound %d %s \194\183 +%d coins \194\183 +%d candy", j.hc and "Hardcore \194\183 " or "", ey.rounds, j.died and "lost" or "survived", Y.credits, Y.hcandy), j.died and "Bad" or (j.hc and "Hardcore" or "Good"), 4);
end;
local function uy(P, j, Y)
	local X = P and P:HasTag("PlayingHumanoid");
	if X then
		if not V.round then
			V.round = {
					last = {},
					gain = {},
					items0 = V.collected,
					died = false,
					t0 = Y,
				};
			for P, Y in ipairs(Vy) do
				V.round.last[Y] = j[Y] or 0;
			end;
		end;
		V.round.leftAt = nil;
		dy(j);
		local X = o:FindFirstChild("ThisRound");
		local M = X and X:FindFirstChild("hardcore");
		if M and M.Value then
			V.round.hc = true;
		end;
		if P.Health <= 0 then
			V.round.died = true;
		end;
	elseif V.round then
		if P and P.Health <= 0 then
			V.round.died = true;
		end;
		V.round.leftAt = V.round.leftAt or Y;
		dy(j);
		if Y - V.round.leftAt >= Ey then
			Ry(j);
		end;
	end;
end;
local gy = {
		{ "^Dodging", "Dodging", "Warn" },
		{ "^Collecting", "Collecting", "Good" },
		{ "^Safe", "Safe", "Accent" },
		{ "^Lobby", "Lobby", "SubText" },
		{ "^Dead", "Dead", "Bad" },
	};
local function ry()
	local P, j = pcall(function()
			local P = o.PlayerGui.RoundUi.Top.YY.Timer;
			return (P:FindFirstChildWhichIsA("TextLabel", true)).Text;
		end);
	return P and j or nil;
end;
local function sy(P)
	local j = Wy();
	local Y = os.clock();
	for P, j in pairs(V.voidSeen) do
		if j ~= true and not P.Parent then
			V.voidGone = V.voidGone + 1;
			V.voidSeen[P] = true;
		end;
	end;
	if V.voidOn and (((not V.lastVoidReport or Y - V.lastVoidReport > 30)) and V.voided > 0) then
		V.lastVoidReport = Y;
		e(string.format("void: sent %d, gone %d, blasts under the map %d", V.voided, V.voidGone, V.voidBlasts));
	end;
	if P and P:HasTag("PlayingHumanoid") then
		local P = ry();
		if P ~= V.clockTxt then
			if V.freezeTest then
				e(string.format("round clock moving again %.0fs after pausing bomb control / bring", Y - V.freezeTest));
				V.freezeTest = nil;
			end;
			V.clockTxt = P;
			V.clockT = Y;
			V.clockWarned = false;
		elseif V.clockT and (Y - V.clockT > 90 and not V.clockWarned) then
			V.clockWarned = true;
			V.freezeTest = Y;
			V.pauseMeddle = Y + 45;
			e("round clock frozen at " .. (tostring(P) .. " for 90s - pausing bomb control + bring for 45s to test"));
			By:Notify("Round clock frozen \194\183 pausing bomb control to test", "Bad", 8);
		elseif V.freezeTest and (Y - V.freezeTest > 50 and not V.freezeReported) then
			V.freezeReported = true;
			e("round clock still frozen 50s after pausing bomb control - not our meddling, rejoin");
			By:Notify("Server round loop stuck \194\183 rejoin the server", "Bad", 10);
		end;
	end;
	if j then
		uy(P, j, Y);
		local X = V.round and Uy(j) or {};
		for P, Y in ipairs(xy) do
			Gy.tiles:Set(Y.Key, Fy(j[Y.Key] or 0), X[Y.Key]);
		end;
		local M = {};
		if V.round then
			local P = {};
			for j, Y in pairs(X) do
				P[j] = Y;
			end;
			local j = V.round.hc;
			table.insert(M, {
				Round = "#" .. (ey.rounds + 1),
				Result = ((j and "HC " or "")) .. ((V.round.died and "Died" or "Live")),
				Kind = V.round.died and "Bad" or (j and "Hardcore" or "Accent"),
				Hardcore = j,
				Values = P,
			});
		end;
		for P, j in ipairs(ey.history) do
			table.insert(M, {
				Round = "#" .. j.n,
				Result = ((j.hc and "HC " or "")) .. ((j.died and "Died" or "Survived")),
				Kind = j.died and "Bad" or (j.hc and "Hardcore" or "Good"),
				Hardcore = j.hc,
				Values = j.d,
			});
		end;
		Gy.log:SetRows(M);
		Gy.log:SetTotal({ Round = "TOTAL", Result = string.format("%d rounds \194\183 %d won \194\183 %d HC", ey.rounds, ey.survived, ey.hcRounds or 0), Values = {
				credits = ey.credits,
				gems = ey.gems,
				hcandy = ey.hcandy,
				shinies = ey.shinies,
				items = ey.items,
			} });
	end;
	for P, j in pairs(V.collectedBy) do
		local Y = Gy.grids[P];
		if Y then
			Y:SetCount(P, j);
		end;
	end;
	do
		local P = o:FindFirstChild("WinStreak");
		local Y = o:FindFirstChild("leaderstats");
		local X = Y and Y:FindFirstChild("Wins");
		local M = {};
		if V.round then
			M[1] = "live";
		end;
		for P, j in ipairs(ey.history) do
			table.insert(M, not j.died);
		end;
		local z = P and P.Value or 0;
		local q = ty(z);
		local S = string.format("Best %d \194\183 %d wins", j and j.topstreak or 0, X and X.Value or (j and j.wins or 0));
		if z >= 22 then
			S = S .. " \194\183 bonus maxed";
		elseif z >= 3 then
			S = S .. string.format(" \194\183 max bonus in %d", 22 - z);
		else
			S = S .. string.format(" \194\183 bonus starts in %d", 3 - z);
		end;
		if V.lastCard and V.lastCard.total then
			S = S .. (" \194\183 last reward +" .. tostring(V.lastCard.total));
		end;
		Gy.streak:Set({
			Streak = z,
			Best = j and j.topstreak or 0,
			Wins = X and X.Value or (j and j.wins or 0),
			Recent = M,
			Bonus = q,
			BonusText = "+" .. (q .. " STREAK BONUS"),
			Sub = S,
		});
	end;
	local X, M = "Starting", "Accent";
	for P, j in ipairs(gy) do
		if string.find(V.state, j[1]) then
			X, M = j[2], j[3];
			break;
		end;
	end;
	local z;
	if V.round then
		local P = math.floor(Y - V.round.t0);
		z = string.format("%sRound #%d \194\183 %d:%02d elapsed \194\183 %d items this round", V.round.hc and "Hardcore \194\183 " or "", ey.rounds + 1, math.floor(P / 60), P % 60, V.collected - V.round.items0);
	else
		z = string.format("%d rounds played \194\183 %d survived", ey.rounds, ey.survived);
	end;
	Gy.card:Set({
		State = X,
		Kind = M,
		Headline = V.state,
		Detail = z,
		HP = P and P.Health or 0,
		MaxHP = P and P.MaxHealth or 100,
		Chips = {
			{ "Hits", V.hits },
			{ "Dodges", V.dodges },
			{ "Pushed", V.pushed },
			{ "Items", V.collected },
		},
	});
end;
table.insert(V.conns, Y.Heartbeat:Connect(function()
	if not V.running then
		return;
	end;
	local P = os.clock();
	local j = o.Character;
	local Y = j and j:FindFirstChildOfClass("Humanoid");
	local X = j and j:FindFirstChild("HumanoidRootPart");
	if P - V.lastReport >= .5 then
		V.lastReport = P;
		local j, X = pcall(sy, Y);
		if not j and X ~= V.lastUiErr then
			V.lastUiErr = X;
			e("UI update error: " .. tostring(X));
		end;
	end;
	if not Y or not X then
		V.state = "Waiting for character";
		return;
	end;
	if Y.Health <= 0 then
		if not V.dead then
			V.dead = true;
			local j = {};
			for Y, X in ipairs(V.recent) do
				if P - X.t < 1.5 then
					table.insert(j, string.format("%s r=%d d=%.0f", X.name, X.r, X.d));
				end;
			end;
			e("DIED (last hp " .. (tostring(V.lastHealth) .. (") recent explosions: " .. table.concat(j, "; "))));
		end;
		V.state = "Dead - waiting for respawn";
		V.lastHealth = nil;
		return;
	end;
	V.dead = false;
	if V.lastHealth and Y.Health < V.lastHealth - .5 then
		V.hits = V.hits + 1;
		local j = {};
		for Y, X in pairs(V.status) do
			if P - X < 1.5 then
				table.insert(j, Y);
			end;
		end;
		e(string.format("took %.0f dmg (hp %.0f) margin %.1f mode %s status [%s]", V.lastHealth - Y.Health, Y.Health, V.hereScore or -1, tostring(V.mode), table.concat(j, ",")));
	end;
	V.lastHealth = Y.Health;
	if o:GetAttribute("NotThere") and ((not V.lastUnAfk or P - V.lastUnAfk > 2)) then
		local j = o:FindFirstChild("options");
		local Y = j and j:FindFirstChild("AFK");
		if not ((Y and Y:GetAttribute("ManuallySet"))) then
			V.lastUnAfk = P;
			k:FireServer(false);
		end;
	end;
	if not Y:HasTag("PlayingHumanoid") then
		Q(Y);
		V.hold = nil;
		V.state = "Lobby - waiting for a round";
		return;
	end;
	if P - V.lastPlan < .1 then
		return;
	end;
	V.lastPlan = P;
	w(j);
	for j in pairs(V.tries) do
		local Y = j.Parent and G(j);
		if Y and ((Y - X.Position)).Magnitude < 8 then
			qy(X, j, P);
		end;
	end;
	Sy(P);
	local M = Z(X.Position, P);
	local z, S = nil, math.huge;
	if #M > 0 then
		if V.flyOn then
			z, S = b(X, M);
			if not z and S < 4 then
				z = b(X, M, true);
			end;
			if not z and S < 0 then
				local P = Vector3.zero;
				for j, Y in ipairs(M) do
					local M = Y.p;
					local z = X.Position - M;
					local o = z.Magnitude - Y.r;
					if o < 0 and z.Magnitude > .1 then
						P = P + z.Unit * (-o);
					end;
				end;
				if P.Magnitude > .1 then
					local j = X.Position + P.Unit * 30;
					j = Vector3.new(j.X, math.min(j.Y, m()), j.Z);
					z = j;
					e("flee fallback: no open spot, running straight out");
				end;
			end;
		else
			z, S = u(X, M);
		end;
	end;
	V.hereScore = S;
	V.threatCount = #M;
	local W = false;
	do
		local P = o:FindFirstChild("ThisRound");
		local j = P and P:FindFirstChild("hardcore");
		W = j and j.Value or false;
	end;
	V.hcNow = W;
	local O = W and 12 or 4;
	local v = W and 16 or 6;
	if V.dodgeOn then
		local j = false;
		if V.mode == "dodge" and (V.target and #M > 0) then
			local Y = V.progressT and P - V.progressT > .4;
			local z;
			if V.flyOn then
				z = R(X.Position, V.target);
			else
				z = U(X.Position, V.target);
			end;
			j = not Y and (t(V.target, M) >= O and z);
		end;
		if j then
			V.state = string.format("Dodging \194\183 %d threats", #M);
			return;
		end;
		if S < O and z then
			if V.mode ~= "dodge" then
				V.dodges = V.dodges + 1;
			end;
			V.moving = true;
			V.mode = "dodge";
			V.target = z;
			V.item = nil;
			V.progressT = P;
			V.progressD = nil;
			V.state = string.format("Dodging \194\183 %d threats", #M);
			return;
		end;
		if V.mode == "dodge" and S < v then
			V.state = string.format("Dodging \194\183 %d threats", #M);
			return;
		end;
	end;
	if V.mode == "dodge" then
		Q(Y);
	end;
	if V.collectOn then
		local Y = j:FindFirstChild("BombHead") ~= nil;
		if not W and (V.mode == "item" and (V.item and zy(V.item, P, Y))) then
			local j = G(V.item);
			local Y = V.progressT and P - V.progressT > 1.5;
			if j and (not Y and ((#M == 0 or t(j, M) >= 4))) then
				V.state = "Collecting " .. ((C[V.item.Name] and C[V.item.Name].Name or V.item.Name));
				return;
			end;
			if Y then
				V.skip[V.item] = P + 20;
				e("stuck going to " .. (V.item.Name .. " (skipping 20s)"));
			end;
		end;
		if V.bringOn and not ((V.pauseMeddle and P < V.pauseMeddle)) then
			local j = 0;
			for M, z in ipairs(q:GetChildren()) do
				if j >= 3 then
					break;
				end;
				if zy(z, P, Y) and not V.tries[z] then
					local Y = z:IsA("BasePart") and z or (z:IsA("Model") and ((z.PrimaryPart or z:FindFirstChildWhichIsA("BasePart"))));
					if Yy[z.Name] then
						if My() then
							Y = nil;
						end;
					end;
					if Y and (not Y.Anchored and isnetworkowner(Y)) then
						j = j + 1;
						if z:IsA("Model") then
							z:PivotTo(X.CFrame);
						else
							Y.CFrame = X.CFrame;
						end;
						Y.AssemblyLinearVelocity = Vector3.zero;
						V.brought = V.brought + 1;
						qy(X, z, P);
					end;
				end;
			end;
		end;
		local z, o = nil, nil;
		if not W then
			z, o = oy(X, M, P, Y);
		end;
		if z then
			V.moving = true;
			V.mode = "item";
			V.item = z;
			V.target = nil;
			V.progressT = P;
			V.progressD = nil;
			V.state = string.format("Collecting %s (%.0f studs)", C[z.Name] and C[z.Name].Name or z.Name, o);
			return;
		end;
	end;
	if V.mode == "item" then
		Q(Y);
	end;
	if V.flyOn and not V.moving then
		local j = X.Position;
		local Y = H(j);
		if (Y and j.Y > (Y + N) + 5) or j.Y > m() + 5 then
			Y = Y or (m() - 50);
			local X = Vector3.new(j.X, Y + ((W and 45 or 4)), j.Z);
			V.moving = true;
			V.mode = "dodge";
			V.target = X;
			V.progressT = P;
			V.progressD = nil;
			V.state = "Coming back down to the play area";
			return;
		end;
	end;
	if W and (V.flyOn and not V.moving) then
		local j = X.Position;
		local Y = workspace:Raycast(j, Vector3.new(0, -80, 0), a);
		local z = Y and Y.Position.Y;
		local o = z and (z + 45) or j.Y;
		if z and j.Y < o - 3 then
			local Y = workspace:Raycast(j, Vector3.new(0, (o - j.Y) + 4, 0), a);
			if Y then
				o = Y.Position.Y - 4;
			end;
			o = math.min(o, m());
			local X = Vector3.new(j.X, o, j.Z);
			if o > j.Y + 2 and ((#M == 0 or t(X, M) >= O)) then
				V.moving = true;
				V.mode = "dodge";
				V.target = X;
				V.progressT = P;
				V.progressD = nil;
				V.state = "Hardcore \194\183 climbing to safe altitude";
				return;
			end;
		end;
	end;
	V.state = ((W and "Hardcore \194\183 " or "")) .. ((#M > 0 and string.format("Safe \194\183 %d threats nearby", #M) or "Safe \194\183 nothing to do"));
end));
local Iy = 65;
local hy = 110;
table.insert(V.conns, Y.Stepped:Connect(function(P, j)
	if not V.running then
		return;
	end;
	local Y = o.Character;
	local X = Y and Y:FindFirstChildOfClass("Humanoid");
	local M = Y and Y:FindFirstChild("HumanoidRootPart");
	if not X or not M or X.Health <= 0 then
		return;
	end;
	local z = os.clock();
	if V.arrived and z - V.arrived.t > .6 then
		local P = ((M.Position - V.arrived.p)).Magnitude;
		if P > 6 and not V.moving then
			V.snapbacks = V.snapbacks + 1;
			e(string.format("SNAPBACK %.1f studs after glide", P));
		end;
		V.arrived = nil;
	end;
	if V.bombCtlOn and (X:HasTag("PlayingHumanoid") and not ((V.pauseMeddle and z < V.pauseMeddle))) then
		for P, j in ipairs(q:GetChildren()) do
			if B(j) then
				local P = j:IsA("BasePart") and j or (j:IsA("Model") and ((j.PrimaryPart or j:FindFirstChildWhichIsA("BasePart"))));
				if P and (not P.Anchored and (isnetworkowner(P) and (V.voidOn and V.voidAllowed))) then
					local Y = workspace.FallenPartsDestroyHeight - 100;
					if j:IsA("Model") then
						j:PivotTo(CFrame.new(P.Position.X, Y, P.Position.Z));
					else
						P.CFrame = CFrame.new(P.Position.X, Y, P.Position.Z);
					end;
					P.AssemblyLinearVelocity = Vector3.zero;
					if not V.voidSeen[j] then
						V.voidSeen[j] = os.clock();
						V.voided = V.voided + 1;
					end;
				elseif P and (not P.Anchored and isnetworkowner(P)) then
					local Y = P.AssemblyLinearVelocity;
					if Y.Y < -10 then
						P.AssemblyLinearVelocity = Vector3.new(Y.X, -10, Y.Z);
						if not V.slowSeen[j] then
							V.slowSeen[j] = true;
							V.slowed = V.slowed + 1;
						end;
					end;
					local X = P.Position;
					local z = Vector3.new(X.X - M.Position.X, 0, X.Z - M.Position.Z);
					local o = x(j) + 10;
					local q = j.Name;
					if string.find(q, "Rocket") or string.find(q, "Homing") or string.find(q, "Chaser") then
						o = 150;
					end;
					if z.Magnitude < o and math.abs(X.Y - M.Position.Y) < o then
						local Y = z.Magnitude > .1 and z.Unit or Vector3.new(1, 0, 0);
						local q = Vector3.new(M.Position.X, X.Y, M.Position.Z) + Y * o;
						if j:IsA("Model") then
							j:PivotTo(CFrame.new(q) * (j:GetPivot()).Rotation);
						else
							P.CFrame = CFrame.new(q) * P.CFrame.Rotation;
						end;
						if not V.pushSeen[j] then
							V.pushSeen[j] = true;
							V.pushed = V.pushed + 1;
						end;
					end;
				end;
			end;
		end;
	end;
	if not V.moving then
		if V.flyOn and (V.hold and X:HasTag("PlayingHumanoid")) then
			if ((M.Position - V.hold)).Magnitude > 15 then
				V.hold = nil;
				e("hover released: the game moved the character");
			else
				M.CFrame = CFrame.new(V.hold) * M.CFrame.Rotation;
				M.AssemblyLinearVelocity = Vector3.zero;
			end;
		end;
		return;
	end;
	local S;
	if V.mode == "item" and V.item then
		S = G(V.item);
		if not S then
			Q(X);
			return;
		end;
		if ((S - M.Position)).Magnitude < 6 then
			qy(M, V.item, z);
		end;
	elseif V.mode == "dodge" and V.target then
		if V.flyOn then
			S = V.target;
		else
			S = Vector3.new(V.target.X, ((V.target.Y - 3) + X.HipHeight) + M.Size.Y / 2, V.target.Z);
		end;
	else
		return;
	end;
	local W = S - M.Position;
	local O = W.Magnitude;
	local v = (Vector3.new(W.X, 0, W.Z)).Magnitude;
	if V.mode == "dodge" and (v < 1.5 and ((not V.flyOn or O < 1.5))) then
		V.arrived = { t = z, p = M.Position };
		V.hold = M.Position;
		Q(X);
		return;
	end;
	V.hold = M.Position;
	if not V.progressD or O < V.progressD - 1 then
		V.progressD = O;
		V.progressT = z;
	end;
	if O < .5 then
		M.AssemblyLinearVelocity = Vector3.zero;
		return;
	end;
	local f = ((V.mode == "dodge" and ((V.hereScore or 99)) < 0)) and hy or Iy;
	local n = math.min(f * j, O);
	M.CFrame = CFrame.new(M.Position + W.Unit * n) * M.CFrame.Rotation;
	M.AssemblyLinearVelocity = Vector3.zero;
end));
do
	local P = game:GetService("VirtualUser");
	local function j()
		pcall(function()
			P:CaptureController();
			P:ClickButton2(Vector2.new());
		end);
	end;
	table.insert(V.conns, o.Idled:Connect(j));
	task.spawn(function()
		while V.running do
			task.wait(240);
			if V.running then
				j();
			end;
		end;
	end);
end;
local function Ny(P)
	table.insert(V.conns, P.ChildAdded:Connect(function(P)
		if not P:IsA("BasePart") and (not P:IsA("Accessory") and not P:IsA("Script")) then
			V.status[P.Name] = os.clock();
		end;
	end));
end;
if o.Character then
	Ny(o.Character);
end;
table.insert(V.conns, o.CharacterAdded:Connect(Ny));
(getgenv()).SBSHubStop = function()
		if not V.running then
			return;
		end;
		V.running = false;
		for P, j in ipairs(V.conns) do
			j:Disconnect();
		end;
		local P = o.Character;
		local j = P and P:FindFirstChildOfClass("Humanoid");
		if j then
			j:Move(Vector3.zero, false);
		end;
		(getgenv()).SBSHubStop = nil;
		if By.Alive then
			By:Destroy();
		end;
		e("stopped");
	end;
(getgenv()).SBSHubState = V;
e("started");
By:Notify("Aimia - Super Bomb Survival loaded \194\183 press " .. ((By:GetToggleKey()).Name .. " to show / hide"), "Good", 10);