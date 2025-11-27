local listCommands = {}

-- Scan RemoteEvents
for _,v in pairs(game:GetDescendants()) do
    if v:IsA("RemoteEvent") then
        table.insert(listCommands, "[RemoteEvent] " .. v:GetFullName())
    elseif v:IsA("RemoteFunction") then
        table.insert(listCommands, "[RemoteFunction] " .. v:GetFullName())
    elseif v:IsA("BindableEvent") then
        table.insert(listCommands, "[BindableEvent] " .. v:GetFullName())
    elseif v:IsA("ProximityPrompt") then
        table.insert(listCommands, "[ProximityPrompt] " .. v:GetFullName())
    end
end

-- Scan ContextActionService registered actions
local CAS = game:GetService("ContextActionService")
local actions = CAS:GetAllBoundActionInfo()

for actionName,info in pairs(actions) do
    table.insert(listCommands, "[Action] " .. actionName)
end

-- Format hasil
local finalText = "=== Dangerous Night Command Scan ===\n\n"
for _,cmd in pairs(listCommands) do
    finalText = finalText .. cmd .. "\n"
end

-- Simpan ke file lokal
writefile("DangerousNight_Commands.txt", finalText)
