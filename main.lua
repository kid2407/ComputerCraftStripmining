local function command_help()
    print("This program support the following commands:")
    print("- help <subcommand>: Get more information on a subcommand")
    print("- tunnel: Dig a tunnel with the specified parameters")
    print("- stripmine: Do some stripmining with the specified parameters")
end

local whitelist = {"minecraft:torch", "ore", "diamond_ore"}

print("Welcome to kid2407s mining program version 1.0.0!")
command_help()

local function isInteger(str)
    return not (str == "" or str:find("%D")) -- str:match("%D") also works
end

local function place_torch()
    local itemData
    for i = 1, 16 do
        itemData = turtle.getItemDetail(i)
        if itemData and itemData.name == "minecraft:torch" then
            turtle.turnRight()
            turtle.turnRight()
            turtle.select(i)
            turtle.place()
            turtle.turnRight()
            turtle.turnRight()
        end
    end
end

local function calculate_required_fuel_for_mining(length, width, height, doStripmining)
    local fuelUsage = 0

    -- One vertical layer
    fuelUsage = fuelUsage + ((width - 1) * height) + ((height - 1) * width)
    -- If height not even, then one more movement of width-1
    if height % 2 == 1 then
        fuelUsage = fuelUsage + width - 1
    end

    -- Going back down from the top of the tunnel
    fuelUsage = fuelUsage + height - 1
    -- Move forward one block
    fuelUsage = fuelUsage + 1
    -- Repeat for the entire length
    fuelUsage = fuelUsage * length

    if doStripmining then
        local numberOfBranches = math.floor(length / 3)
        fuelUsage = fuelUsage + (numberOfBranches * (2 * (9 + width)))
    end

    return fuelUsage
end

local function clear_terminal()
    term.clear()
    term.setCursorPos(1, 1)
end

local function clean_inventory()
    local details
    local earlyReturn
    for i = 1, 16 do
        details = turtle.getItemDetail(i)
        if details then
            earlyReturn = false
            for _, v in pairs(whitelist) do
                if details.name:match(v) then
                    earlyReturn = true
                    break
                end
            end
            if not earlyReturn then
                turtle.select(i)
                turtle.drop()
            end
        end
    end
    turtle.select(1)
end

local function mine_whitelisted_blocks()
    local success, detectedBlock

    for i = 1, 4 do
        turtle.turnRight()
        success, detectedBlock = turtle.inspect()
        if success then
            for _, v in pairs(whitelist) do
                if detectedBlock.name:match(v) then
                    turtle.dig()
                end
            end
        end
    end

    success, detectedBlock = turtle.inspectDown()
    if success then
        for _, v in pairs(whitelist) do
            if detectedBlock.name:match(v) then
                turtle.digDown()
            end
        end
    end

    success, detectedBlock = turtle.inspectUp()
    if success then
        for _, v in pairs(whitelist) do
            if detectedBlock.name:match(v) then
                turtle.digUp()
            end
        end
    end
end

local function dig_single_tunnel()
    -- Lower layer
    for i = 1, 5 do
        while true do
            if turtle.detect() then
                turtle.dig()
            end
            sleep(0.5)
            if not turtle.detect() then
                turtle.forward()
                break
            end
        end
        mine_whitelisted_blocks()
    end
    -- Go up
    while true do
        if turtle.detectUp() then
            turtle.digUp()
        end
        sleep(0.5)
        if not turtle.detectUp() then
            turtle.up()
            break
        end
    end
    mine_whitelisted_blocks()
    turtle.turnRight()
    turtle.turnRight()
    -- And way back
    for i = 1, 5 do
        while true do
            if turtle.detect() then
                turtle.dig()
            end
            sleep(0.5)
            if not turtle.detect() then
                turtle.forward()
                break
            end
        end
        mine_whitelisted_blocks()
    end
    turtle.down()
end

local function do_stripmining(width)
    turtle.turnLeft()
    dig_single_tunnel()
    for i = 1, width - 1 do
        turtle.forward()
    end
    dig_single_tunnel()
    for i = 1, width - 1 do
        turtle.forward()
    end
    turtle.turnRight()
end

local function do_mining(length, width, height, torchDistance, doStripmining)
    local noMoreBlocks = false
    for i = 1, length do
        if i > 1 then
            noMoreBlocks = false
            while not noMoreBlocks do
                if turtle.detect() then
                    turtle.dig()
                end
                sleep(0.5)
                if not turtle.detect() then
                    noMoreBlocks = true
                end
            end
            turtle.forward()
            if i % torchDistance == torchDistance - 1 then
                place_torch()
            end
        end
        turtle.turnRight()
        for j = 0, height - 1 do
            for k = 0, width - 2 do
                noMoreBlocks = false
                while not noMoreBlocks do
                    if turtle.detect() then
                        turtle.dig()
                    end
                    sleep(0.5)
                    if not turtle.detect() then
                        noMoreBlocks = true
                    end
                end
                turtle.forward()
            end
            if j ~= height - 1 then
                turtle.turnRight()
                turtle.turnRight()

                noMoreBlocks = false
                while not noMoreBlocks do
                    if turtle.detectUp() then
                        turtle.digUp()
                    end
                    sleep(0.5)
                    if not turtle.detectUp() then
                        noMoreBlocks = true
                    end
                end

                turtle.up()
            end
        end
        if height % 2 == 1 then
            turtle.turnRight()
            turtle.turnRight()
            for l = 1, width - 1 do
                noMoreBlocks = false
                while not noMoreBlocks do
                    if turtle.detect() then
                        turtle.dig()
                    end
                    sleep(0.5)
                    if not turtle.detect() then
                        noMoreBlocks = true
                    end
                end
                turtle.forward()
            end
        end
        turtle.turnRight()
        for m = 1, height - 1 do
            noMoreBlocks = false
            while not noMoreBlocks do
                if turtle.detectDown() then
                    turtle.digDown()
                end
                sleep(0.5)
                if not turtle.detectDown() then
                    noMoreBlocks = true
                end
            end
            turtle.down()
        end
        if i % 3 == 0 then
            clean_inventory()
            -- Check if stripmining is active and the next tunnels should be made
            if doStripmining then
                do_stripmining(width)
            end
        end
    end
end

local function prepare_mining(doStripmining)
    clear_terminal()
    local input = nil
    local length = 3
    local width = 1
    local height = 2
    local torchDistance = 5

    while true do
        print("Please enter a tunnel length:")
        input = io.read()
        if isInteger(input) then
            length = tonumber(input)
            break
        end
    end

    while true do
        print("Please enter a tunnel height:")
        input = io.read()
        if isInteger(input) then
            height = tonumber(input)
            break
        end
    end

    while true do
        print("Please enter a tunnel width:")
        input = io.read()
        if isInteger(input) then
            width = tonumber(input)
            break
        end
    end

    while true do
        print("Please enter how far the torches should be placed:")
        input = io.read()
        if isInteger(input) then
            torchDistance = tonumber(input)
            break
        end
    end

    local fuelLevel = turtle.getFuelLevel()
    local requiredFuel = calculate_required_fuel_for_mining(length, width, height, doStripmining)
    local belowRequiredFuel = fuelLevel < requiredFuel
    if belowRequiredFuel == true then
        print("Required Fuel: " .. requiredFuel)
        print("Available Fuel: " .. fuelLevel)
        while (belowRequiredFuel == true) do
            print(
                (requiredFuel - fuelLevel) ..
                    " more fuel required to run. Please insert fuel in the first slot and press enter to refuel."
            )
            input = io.read()
            turtle.select(1)
            if turtle.getItemCount() > 0 then
                while (turtle.getItemCount() > 0 and belowRequiredFuel == true) do
                    if not turtle.refuel(1) then
                        print("No valid fuel in the first slot!")
                        break
                    end
                    fuelLevel = turtle.getFuelLevel()
                    belowRequiredFuel = fuelLevel < requiredFuel
                end
            else
                print("No fuel in the first slot!")
            end
        end
    end
    print("Ready to mine!")
    do_mining(length, width, height, torchDistance, doStripmining)
end

-- Program to dig a straigth tunnel
local function command_tunnel()
    prepare_mining(false)
end

-- Program to do some stripmining
local function command_stripmine()
    prepare_mining(true)
end

while true do
    print("Please choose a command:")
    local input = string.lower(io.read())

    if input == "tunnel" then
        command_tunnel()
    elseif input == "help" then
        command_help()
    elseif input == "stripmine" then
        command_stripmine()
    elseif input == "exit" then
        print("Exiting the program!")
        break
    else
        print("Invalid command!")
    end
end
