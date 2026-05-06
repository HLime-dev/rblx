if not writefile then
    warn("Executor tidak support writefile")
    return
end

local fileName = "game_dump.txt"
local buffer = {}
local count = 0

for _, v in pairs(game:GetDescendants()) do
    count += 1
    
    local success, result = pcall(function()
        return v:GetFullName()
    end)

    if success and result then
        table.insert(buffer, result)
    end

    -- tiap 500 data langsung flush ke file (biar ga overload)
    if count % 500 == 0 then
        writefile(fileName, table.concat(buffer, "\n"))
        task.wait()
    end
end

-- final write
writefile(fileName, table.concat(buffer, "\n"))

print("Selesai dump ke:", fileName)
