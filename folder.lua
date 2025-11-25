-- Nama file hasil scan
local filename = "workspace_scan.txt"

-- Fungsi rekursif untuk scan folder
local function scanFolder(obj, indent)
    indent = indent or ""
    local result = indent .. obj.Name .. " (" .. obj.ClassName .. ")\n"

    for _, child in ipairs(obj:GetChildren()) do
        result = result .. scanFolder(child, indent .. "  ")
    end
    return result
end

-- Mulai scan Workspace
local output = "=== Workspace Folder Scan ===\n\n"
output = output .. scanFolder(workspace)

-- Simpan ke file lokal
writefile(filename, output)

print("[SCAN COMPLETE] File disimpan sebagai:", filename)
