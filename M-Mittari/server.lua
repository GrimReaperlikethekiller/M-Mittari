local name = GetCurrentResourceName()
local path = GetResourcePath(name).."/Client/"
local Client = { "Client" }
local write = {}

function readAll(file)
    local f = io.open(file, "rb")
    local content = f:read("*all")
    f:close()
    return content
end

for i, v in pairs(Client) do
    local code = readAll(path..v..".lua")
    write[v] = code
end

local user = {}

RegisterServerEvent(name..":send", function() 
    local src = source
    if not user[src] then
        TriggerClientEvent(name..":get", src, write)
        user[src] = true
    end
end)

AddEventHandler('playerDropped', function()
    user[source] = nil
end)
