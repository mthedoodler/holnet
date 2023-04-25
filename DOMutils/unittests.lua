local expect = require "cc.expect"
local expect, field = expect.expect, expect.field

--- A logger is an object with methods for logging messages to a file and the console.
--- This function creates a new logger object.
--- @param[string] file - The filepath to the file the logger write logs to.
--- @return[table] logger - A table containing logging functions.

function Logger(file)
    expect(1, file, "string")
    local logger = {silent = false}

    local LOG = fs.open("log.txt", "w")
    LOG.close()

    --- Log a message with a set text color.
    --- @param[string] str - The message to log.
    --- @param[number] color - The color to print to the screen.

    local function log(str, color)
        expect(1, str, "string")
        expect(2, color, "number")

        local LOG = fs.open("log.txt", "a")
        local oldColor = term.getTextColor()
        term.setTextColor(color)
        if not logger.silent then print(str) end
        LOG.writeLine(str)
        term.setTextColor(oldColor)
        LOG.close()
    end

    --- Log a message with a yellow text color.
    --- @param[string] str - The message to log.

    function logger.log(str)
        log(str, colors.yellow)
    end

    --- Log a success message with a lime text color.
    --- @param[string] str - The message to log.

    function logger.logsuccess(str) 
        log(str, colors.lime)
    end

    --- Log an error message with a red text color.
    --- @param[string] str - The message to log.

    function logger.logerr(str)
        log(str, colors.red)
    end

    return logger
end

-- A tester is an object with methods for preforming unit tests.
-- It first runs and prints every test it encounters, and when endTests is called, it
-- shows which ones passed and failed.
-- This function creates a new tester object.
-- @param[table] logger - The logger to use.
-- @return[table] tester - A table containing logging functions.

function Tester(logger)
    expect(1, logger, "table")

    local testCounter = 1
    local testResults = {}
    local tester = {}
    local testName = ""
    local runningTests = false

    --- Restarts the tests and logs an initial statement.
    --- @param[string] name - The name of the tests to preform.

    function tester.startTests(name, isSilent)
        
        testCounter = 1
        testResults = {}
        tester = {}
        testName = name
        logger.log("**** BEGIN TEST: " .. testName .. "****")
        runningTests = true
    end

    --- Passes if the given function runs without errors.
    --- @param[function] func - The function to test.
    --- @param[string] description - The summary of the test to preform.

    function tester.ensureRuns(func, description)
        if not runningTests then error("Please call tester.startTests() before preforming them.") end
        logger.log("Running Test " .. testCounter .. ": " .. description)
        local res, err = pcall(func)
        if res then
            logger.logsuccess("Test " .. testCounter .. " Passed!")
        else
            logger.logerr(err)
            logger.logerr("Test " .. testCounter .. " Failed")
        end

        testResults[testCounter] = {description=description, res=res}
        testCounter = testCounter + 1
    end

    --- Passes if the given function throws an error.
    --- @param[function] func - The function to test.
    --- @param[string] description - The summary of the test to preform.

    function tester.ensureErrors(func, description)
        if not runningTests then error("Please call tester.startTests() before preforming them.") end
        logger.log("Running Test " .. testCounter .. ": " .. description)
        local res, err = pcall(func)
        if res then
            logger.logerr("Test " .. testCounter .. " Failed")
        else
            logger.log(err)
            logger.logsuccess("Test " .. testCounter .. " Passed!")
        end

        testResults[testCounter] = {description=description, res=not res}
        testCounter = testCounter + 1
    end

    --- Passes if the given function returns an expected value.
    --- @param[function] func - The function to evaluate.
    --- @param[any] expected - The expected value func returns.
    --- @param[string] description - The summary of the test to preform.

    function tester.ensureEquals(func, description, expected)
        if not runningTests then error("Please call tester.startTests() before preforming them.") end
        logger.log("Running Test " .. testCounter .. ": " .. description)
        local val = func()
        local res = val == expected
        if res then
            logger.log("Expected: " .. textutils.serialize(expected) .. ",  Recieved: " .. textutils.serialize(val))
            logger.logsuccess("Test " .. testCounter .. " Passed!")
        else
            logger.logerr("Expected: " .. textutils.serialize(expected) .. ",  Recieved: " .. textutils.serialize(val))
            logger.logerr("Test " .. testCounter .. " Failed")
        end

        testResults[testCounter] = {description=description, res=res}
        testCounter = testCounter + 1
    end 

    --- Shows all the tests that passed vs failed.
    function tester.endTests() 

        logger.log("**** TEST RESULTS: ****")

        logger.log("Tests 1-" .. testCounter-1 .. " Concluded.")
        local passed, failed = 0, 0

         for i, v in ipairs(testResults) do
             if v.res then 
                 logger.logsuccess("Test " .. i .. " Passed!")
                 passed = passed + 1 
             else 
                 logger.logerr("Test " .. i .. " Failed: " .. textutils.serialize(v.description))
                 failed = failed + 1
             end
        end

        logger.log(passed .. " Passed, " .. failed .. " Failed.")

        testResults = {}
        testCounter = 1

        logger.log("**** END TEST: " .. testName .. "****\n")

        runningTests = false
    end

    return tester
end

return {Logger=Logger, Tester=Tester}

    