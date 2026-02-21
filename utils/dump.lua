local Dump = {}

function Dump.toString(t, name)
    local lines = {}

    table.insert(lines,  "\nTABLE: " .. (name or ""))

    for k, v in pairs(t) do
        table.insert(lines,
            k .. " = " .. tostring(v) .. " (type: " .. type(v) .. ")"
        )
    end

    return table.concat(lines, "\n")
end

return Dump
