
-- // Corrected Metamethod Hook - Closest Player Target
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local folder = ReplicatedStorage:FindFirstChild("{4EDEC5D4-66F6-4D81-BF9D-2239AE7E63FD}")
local remote = folder and folder:FindFirstChild("{263A5960-8936-4086-B957-8DD1C7B1BA5F}")

if not remote then
    warn("❌ Remote not found")
    return
end

local function getClosestPlayer()
    local closest, minDist = nil, math.huge
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (plr.Character.HumanoidRootPart.Position - myRoot.Position).Magnitude
            if dist < minDist and dist < 250 then
                minDist = dist
                closest = plr
            end
        end
    end
    return closest
end

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    
    if self == remote and method == "FireServer" then
        local args = {...}   -- 元の引数をコピー
        
        if #args >= 1 and typeof(args[1]) == "table" then
            local main = args[1]
            
            local closest = getClosestPlayer()
            if closest and closest.Character and closest.Character:FindFirstChild("HumanoidRootPart") then
                local targetPos = closest.Character.HumanoidRootPart.Position
                
                -- 安全にデータ書き換え
                if typeof(main) == "table" and main[1] and typeof(main[1]) == "table" then
                    local data = main[1]
                    
                    if data[3] and data[3][1] and data[3][1][2] then
                        local inner = data[3][1][2]
                        inner[5] = targetPos + Vector3.new(0, 2.8, 0)  -- 頭狙い
                        inner[7] = targetPos
                    end
                    
                    if data[5] then
                        data[5] = targetPos
                    end
                    
                    if data[4] then
                        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if myRoot then
                            data[4] = (targetPos - myRoot.Position).Unit
                        end
                    end
                end
            end
        end
        
        -- 正しく元の関数を呼ぶ
        return oldNamecall(self, table.unpack(args))
    end
    
    return oldNamecall(self, ...)
end)

print("✅ Metamethod Hook Fixed & Activated")
print("   一番近いプレイヤーを狙うようにしました")
