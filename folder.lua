local HttpService = game:GetService("HttpService")

MainTab:CreateButton({
    Name = "Copy Points JSON",
    Callback = function()
        if #markedPoints < 4 then
            warn("Tandai 4 titik dulu!")
            return
        end
        local data = {}
        for i, pos in ipairs(markedPoints) do
            data[i] = {x = pos.X, y = pos.Y, z = pos.Z}
        end
        local json = HttpService:JSONEncode(data)
        
        -- copy ke clipboard (Delta mendukung fungsi copy)
        pcall(function() setclipboard(json) end)
        print("Points copied to clipboard!")
    end
})
