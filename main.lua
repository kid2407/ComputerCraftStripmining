local function command_help()
    print("This program support the following commands:")
    print("- help <subcommand>: Get more information on a subcommand")
    print("- tunnel: Dig a tunnel with the specified parameters")
    print("- stripmine: Do some stripmining with the specified parameters")
end

print("Welcome to kid2407s mining program version 1.0.0!")
command_help()

local function isInteger(str)
    return not (str == "" or str:find("%D")) -- str:match("%D") also works
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

local function do_mining(boolean, doStripmining)
    clear_terminal()
    local input = nil
    local length = 3
    local width = 1
    local height = 2

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
    local noMoreBlocks = false
    -- Mining part here
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
                turtle.forward()
            end
            turtle.turnRight()
            for m = 1, height - 1 do
                turtle.down()
            end
        else
            turtle.turnRight()
            for m = 1, height - 1 do
                turtle.down()
            end
        end
    end
end

-- Program to dig a straigth tunnel
local function command_tunnel()
    do_mining(false)
end

-- Program to do some stripmining
local function command_stripmine()
    do_mining(true)
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
