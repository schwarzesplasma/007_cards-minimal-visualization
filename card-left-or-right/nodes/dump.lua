local Dump = {}

function Dump.table(t, name)
    print("TABLE:", name or "")
    for k, v in pairs(t) do
        print("  ", k, "=", v, "(type:", type(v) .. ")")
    end
end

return Dump