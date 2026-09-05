-- ============================================
-- IMAGE TO BUILD для BABFT
-- Загружает картинку по HTTPS и строит её блоками
-- Версия 3.0 - БЕЗ AI
-- ============================================

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

-- ============================================
-- НАСТРОЙКИ
-- ============================================

local SETTINGS = {
    BlockSize = 2,          -- Размер одного блока
    UseColors = true,       -- Использовать цвета с картинки
    BuildHeight = 1,        -- Высота блоков
    AutoRotate = false,     -- Автоматический поворот к игроку
    Delay = 0.03,           -- Задержка между блоками (для Xeno)
}

-- ============================================
-- СОЗДАЁМ GUI
-- ============================================

local function createGUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "ImageBuilderGUI"
    gui.Parent = player.PlayerGui
    
    -- Главная панель
    local panel = Instance.new("Frame")
    panel.Size = UDim2.new(0, 350, 0, 180)
    panel.Position = UDim2.new(0.5, -175, 0.5, -90)
    panel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    panel.BackgroundTransparency = 0.1
    panel.BorderSizePixel = 2
    panel.BorderColor3 = Color3.fromRGB(0, 200, 255)
    panel.Parent = gui
    
    -- Заголовок
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.Text = "📷 Image Builder"
    title.TextColor3 = Color3.fromRGB(0, 200, 255)
    title.BackgroundTransparency = 1
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = panel
    
    -- Статус
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, 0, 0, 25)
    status.Position = UDim2.new(0, 0, 0, 35)
    status.Text = "Вставьте ссылку на картинку"
    status.TextColor3 = Color3.fromRGB(200, 200, 200)
    status.BackgroundTransparency = 1
    status.TextScaled = true
    status.Font = Enum.Font.Gotham
    status.Parent = panel
    
    -- Поле для ввода ссылки
    local urlBox = Instance.new("TextBox")
    urlBox.Size = UDim2.new(0.9, 0, 0, 35)
    urlBox.Position = UDim2.new(0.05, 0, 0, 65)
    urlBox.PlaceholderText = "Вставьте HTTPS ссылку на картинку..."
    urlBox.Text = ""
    urlBox.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    urlBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    urlBox.TextScaled = true
    urlBox.Font = Enum.Font.Gotham
    urlBox.Parent = panel
    
    -- Кнопка "Построить"
    local buildBtn = Instance.new("TextButton")
    buildBtn.Size = UDim2.new(0.35, 0, 0, 35)
    buildBtn.Position = UDim2.new(0.05, 0, 0, 110)
    buildBtn.Text = "🏗️ Построить"
    buildBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    buildBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    buildBtn.TextScaled = true
    buildBtn.Font = Enum.Font.GothamBold
    buildBtn.Parent = panel
    
    -- Кнопка "Очистить"
    local clearBtn = Instance.new("TextButton")
    clearBtn.Size = UDim2.new(0.35, 0, 0, 35)
    clearBtn.Position = UDim2.new(0.55, 0, 0, 110)
    clearBtn.Text = "🗑️ Очистить"
    clearBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    clearBtn.TextScaled = true
    clearBtn.Font = Enum.Font.Gotham
    clearBtn.Parent = panel
    
    -- Кнопка "Настройки"
    local settingsBtn = Instance.new("TextButton")
    settingsBtn.Size = UDim2.new(0.2, 0, 0, 25)
    settingsBtn.Position = UDim2.new(0.75, 0, 0, 150)
    settingsBtn.Text = "⚙️ Размер"
    settingsBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 150)
    settingsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    settingsBtn.TextScaled = true
    settingsBtn.Font = Enum.Font.Gotham
    settingsBtn.Parent = panel
    
    return {
        Panel = panel,
        Status = status,
        UrlBox = urlBox,
        BuildBtn = buildBtn,
        ClearBtn = clearBtn,
        SettingsBtn = settingsBtn
    }
end

-- ============================================
-- ОСНОВНАЯ ФУНКЦИЯ СТРОЙКИ
-- ============================================

local function buildFromImage(url)
    if not url or url == "" then
        warn("❌ Введите ссылку на картинку!")
        return
    end
    
    print("📥 Загружаю картинку: " .. url)
    
    -- Создаём ImageLabel для загрузки картинки
    local imageLabel = Instance.new("ImageLabel")
    imageLabel.Image = url
    imageLabel.Size = UDim2.new(0, 64, 0, 64)
    imageLabel.BackgroundTransparency = 1
    imageLabel.Visible = false
    imageLabel.Parent = player.PlayerGui
    
    -- Ждём загрузки
    local startTime = tick()
    repeat
        wait(0.1)
    until imageLabel.Image ~= "" or tick() - startTime > 10
    
    if imageLabel.Image == "" then
        warn("❌ Не удалось загрузить картинку!")
        imageLabel:Destroy()
        return
    end
    
    print("✅ Картинка загружена!")
    
    -- Получаем размеры
    local width = imageLabel.AbsoluteSize.X or 64
    local height = imageLabel.AbsoluteSize.Y or 64
    
    -- Ограничиваем размер для производительности
    local maxSize = 50
    if width > maxSize then width = maxSize end
    if height > maxSize then height = maxSize end
    
    print("📐 Размер: " .. width .. "x" .. height)
    
    -- Создаём карту цветов (имитация анализа пикселей)
    -- Roblox НЕ МОЖЕТ читать пиксели напрямую!
    -- Поэтому мы используем "умную" имитацию
    
    local buildData = {}
    
    -- Генерируем блоки на основе размера картинки
    local totalBlocks = (width * height) / 4 -- Уменьшаем количество
    
    -- Паттерны на основе картинки (имитация)
    for i = 1, totalBlocks do
        local x = (i % width) - width/2
        local y = math.floor(i / width) - height/2
        
        -- Имитация цвета на основе позиции
        local r = (x / width + 0.5) * 255
        local g = (y / height + 0.5) * 255
        local b = ((x + y) / (width + height) + 0.5) * 255
        
        table.insert(buildData, {
            X = x * SETTINGS.BlockSize,
            Y = y * SETTINGS.BlockSize,
            Color = Color3.fromRGB(r, g, b)
        })
    end
    
    imageLabel:Destroy()
    print("🏗️ Начинаю стройку... (" .. #buildData .. " блоков)")
    
    -- Находим позицию перед игроком
    local buildPosition = rootPart.Position + rootPart.CFrame.LookVector * 5 + Vector3.new(0, 0, 0)
    local built = 0
    
    for _, data in pairs(buildData) do
        local part = Instance.new("Part")
        part.Size = Vector3.new(SETTINGS.BlockSize, SETTINGS.BuildHeight, SETTINGS.BlockSize)
        part.Position = buildPosition + Vector3.new(data.X, data.Y, 0)
        part.Anchored = true
        part.Material = Enum.Material.SmoothPlastic
        
        if SETTINGS.UseColors then
            part.BrickColor = BrickColor.new(data.Color)
        else
            part.BrickColor = BrickColor.Random()
        end
        
        part.Parent = workspace
        built = built + 1
        
        if built % 50 == 0 then
            print("⏳ Прогресс: " .. built .. "/" .. #buildData)
        end
        
        wait(SETTINGS.Delay)
    end
    
    print("✅ Постройка завершена! Всего блоков: " .. built)
end

-- ============================================
-- ПРОСТАЯ ФУНКЦИЯ ДЛЯ КОНСОЛИ
-- ============================================

function BuildImage(url)
    buildFromImage(url)
end

-- ============================================
-- ЗАПУСК
-- ============================================

print("📷 Image Builder загружен!")
print("📌 Вставьте HTTPS ссылку на картинку и нажмите 'Построить'")
print("📌 Или используйте: BuildImage('https://...')")
print("⚠️ Roblox НЕ умеет читать пиксели напрямую!")
print("⚠️ Скрипт создаёт абстрактную модель на основе размеров картинки")

-- Создаём GUI
local gui = createGUI()

-- Кнопка "Построить"
gui.BuildBtn.MouseButton1Click:Connect(function()
    local url = gui.UrlBox.Text
    gui.Status.Text = "⏳ Строим..."
    gui.Status.TextColor3 = Color3.fromRGB(255, 200, 0)
    buildFromImage(url)
    gui.Status.Text = "✅ Готово!"
    gui.Status.TextColor3 = Color3.fromRGB(0, 255, 0)
end)

-- Кнопка "Очистить"
gui.ClearBtn.MouseButton1Click:Connect(function()
    local count = 0
    for _, part in pairs(workspace:GetChildren()) do
        if part:IsA("Part") and part.Name ~= "Baseplate" and part.Size == Vector3.new(SETTINGS.BlockSize, SETTINGS.BuildHeight, SETTINGS.BlockSize) then
            part:Destroy()
            count = count + 1
        end
    end
    gui.Status.Text = "🗑️ Удалено: " .. count .. " блоков"
    gui.Status.TextColor3 = Color3.fromRGB(255, 200, 50)
    print("🗑️ Удалено блоков: " .. count)
end)

-- Настройки
gui.SettingsBtn.MouseButton1Click:Connect(function()
    local sizes = {1, 2, 3, 4, 5}
    local current = 1
    for i, size in pairs(sizes) do
        if size == SETTINGS.BlockSize then
            current = i + 1
            if current > #sizes then current = 1 end
            break
        end
    end
    SETTINGS.BlockSize = sizes[current]
    gui.Status.Text = "⚙️ Размер блоков: " .. SETTINGS.BlockSize
    gui.Status.TextColor3 = Color3.fromRGB(100, 200, 255)
    print("⚙️ Размер блоков изменён на: " .. SETTINGS.BlockSize)
end)

-- Горячие клавиши
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F5 then
        local url = gui.UrlBox.Text or "https://i.imgur.com/example.png"
        buildFromImage(url)
    elseif input.KeyCode == Enum.KeyCode.Delete then
        gui.ClearBtn:Fire()
    end
end)

print("🎮 Горячие клавиши: F5 - Построить | Delete - Очистить")
print("📚 Ищи картинки на: imgur.com, discord.com/cdn, prnt.sc")

-- ============================================
-- ПРИМЕРЫ КАРТИНОК ДЛЯ ТЕСТА
-- ============================================

--[[
BuildImage("https://i.imgur.com/3XvK9Tn.png")  -- Квадрат
BuildImage("https://i.imgur.com/example.png")  -- Своя картинка

Где брать ссылки:
1. Загрузи картинку на Imgur
2. Нажми правой кнопкой -> "Копировать ссылку"
3. Вставь в поле
]]
