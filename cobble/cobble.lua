-- Cobblestone Generator script for Mining Turtles. Created by NicholasDJM (https://github.com/NicholasDJM/cc-programs)
if not turtle then
    printError "Requires a Mining Turtle"
    return
end

local function pick(item)
    if item == "minecraft:diamond_pickaxe" then
        return true
    else
        return false
    end
end

local function equip()
    print("Attempting to equip a pickaxe...")
    for i=1,16 do
        local item = turtle.getItemDetail(i)
        if item and pick(item.name) then
            local originalSlot = turtle.getSelectedSlot()
            print("Found a pickaxe")
            turtle.select(i)
            turtle.equipRight()
            turtle.select(originalSlot)
            return true
        end
    end
    print("Couldn't find a pickaxe")
    return false
end
local isChest = false
local isEmpty = false
local message = false
print("Looking for chest...")
while not isEmpty do
    local block, blockData = turtle.inspect()
    if blockData.name~="minecraft:chest" and not isChest then
        turtle.turnLeft()
    else
        if not message then
            print("Found a chest! Emptying inventory...")
            message=true
        end
        isChest=true
        local count=0
        for i=1,16 do
            turtle.select(i)
            local item = turtle.getItemDetail()
            if item~=nil and not pick(item.name) then
                turtle.drop()
            else
                count=count+1
            end
        end
        for i=1,16 do
            if turtle.getItemSpace(i)==64 then
                count=count+1
            end
        end
        if count>=16 then
            isEmpty=true
        end
    end
end
turtle.select(1)
local mined=0
local function counter()
    local s = "s"
    if mined==1 then s = "" end
    print("Mined "..mined.." block"..s..".")
end
do
    local fileExists = fs.exists("/cobble_count.txt")
    if fileExists then
        local file = fs.open("/cobble_count.txt", "r")
        local data = file.readAll()
        file.close()
        data = tonumber(data)
        if type(data) == "number" then
            print("Getting latest count of blocks mined...")
            mined = data
            counter()
        end
    end
end
local function saveMined(num)
    local file = fs.open("/cobble_count.txt", "w")
    file.write(num)
    file.close()
end
print("Inventory empty, mining in opposite direction...")
turtle.turnLeft()
turtle.turnLeft()
local error=false
local function mine(blockData)
    if blockData.name=="minecraft:cobblestone" or blockData.name=="minecraft:stone" then
        local blockBroken, reason = turtle.dig()
        if reason=="No tool to dig with" then
            if not equip() then
                printError("No tool to dig with")
                error=true
            else
                select(1)
            end
        end
        if mined % 100 == 0 and mined~=0 then
            counter()
        end
        mined=mined+1
        saveMined(mined)
    end
end
local function waitUntilDrop()
    local dropped=false
    repeat
        if turtle.drop() then
            dropped=true
        end
        sleep(0.1)
    until dropped
end
local function drop(dropFromCurrentOnly)
    local dropFromCurrentOnly = dropFromCurrentOnly or false
    turtle.turnLeft()
    turtle.turnLeft()
    if not dropFromCurrentOnly then
        print("Inventory full, Emptying...")
        for i=1,16 do
            turtle.select(i)
            waitUntilDrop()
        end
        turtle.select(1)
    else
        waitUntilDrop()
    end
    turtle.turnRight()
    turtle.turnRight()
end
local needNextSlot=false
while not error do
    local block, blockData = turtle.inspect()
    if turtle.getItemSpace() > 0 then
        if turtle.getItemDetail()~=nil then
            if turtle.getItemDetail().name == "minecraft:cobblestone" then
                mine(blockData)
            else
                needNextSlot=true
            end
        else
            mine(blockData)
        end
    elseif needNextSlot then
        if turtle.getSelectedSlot()~=16 then
            turtle.select(turtle.getSelectedSlot()+1)
            if turtle.getItemDetail()~=nil then
                drop(true)
            end
        else
            drop()
        end
        needNextSlot=false
    else
        needNextSlot=true
    end
end
