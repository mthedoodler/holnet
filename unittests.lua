function Tester(logger)

    local TEST_COUNTER = 1
    local TEST_RESULTS = {}
    local tester = {}

    function tester.ensureRuns(testFunc, msg)
        logger.log("Running Test " .. TEST_COUNTER .. ": " .. msg)
        local res, msg = pcall(testFunc)
        if res then
            logger.logsuccess("Test " .. TEST_COUNTER .. " Passed!")
        else
            logger.logerr(msg)
            logger.logerr("Test " .. TEST_COUNTER .. " Failed")
        end

        TEST_RESULTS[TEST_COUNTER] = {msg=msg, res=res}
        TEST_COUNTER = TEST_COUNTER + 1
    end

    function tester.ensureErrors(testFunc, msg)
        logger.log("Running Test " .. TEST_COUNTER .. ": " .. msg)
        local res, msg = pcall(testFunc)
        if res then
            logger.logerr("Test " .. TEST_COUNTER .. " Failed")
        else
            logger.log(msg)
            logger.logsuccess("Test " .. TEST_COUNTER .. " Passed!")
        end

        TEST_RESULTS[TEST_COUNTER] = {msg=msg, res=not res}
        TEST_COUNTER = TEST_COUNTER + 1
    end

    function tester.ensureEquals(testFunc, msg, expected)
        logger.log("Running Test " .. TEST_COUNTER .. ": " .. msg)
        local val = testFunc()
        local res = val == expected
        if res then
            logger.log("Expected: " .. textutils.serialize(expected) .. ",  Recieved: " .. textutils.serialize(val))
            logger.logsuccess("Test " .. TEST_COUNTER .. " Passed!")
        else
            logger.logerr("Expected: " .. textutils.serialize(expected) .. ",  Recieved: " .. textutils.serialize(val))
            logger.logerr("Test " .. TEST_COUNTER .. " Failed")
        end

        TEST_RESULTS[TEST_COUNTER] = {msg=msg, res=res}
        TEST_COUNTER = TEST_COUNTER + 1
    end 

    function tester.endTests()
        logger.log("Tests 1-" .. TEST_COUNTER-1 .. " Concluded.")
        local passed, failed = 0, 0

         for i, v in ipairs(TEST_RESULTS) do
             if v.res then 
                 logger.logsuccess("Test " .. i .. " Passed!")
                 passed = passed + 1 
             else 
                 logger.logerr("Test " .. i .. " Failed: " .. textutils.serialize(v.msg))
                 failed = failed + 1
             end
        end

        logger.log(passed .. " Passed, " .. failed .. " Failed.")

        TEST_RESULTS = {}
        TEST_COUNTER = 1
    end

    return tester
end

function Logger(file)

    local logger = {}

    local LOG = fs.open("log.txt", "w")

    function logger.log(str) 
        local col = term.getTextColor()
        term.setTextColor(colors.yellow)
        print(str)
        LOG.write(str .. "\n")
        term.setTextColor(col)
    end

    function logger.logsuccess(str) 
        local col = term.getTextColor()
        term.setTextColor(colors.lime)
        print(str)
        LOG.write(str .. "\n")
        term.setTextColor(col)
    end

    function logger.logerr(str)
        local col = term.getTextColor()
        term.setTextColor(colors.red)
        print(str)
        LOG.write(str .. "\n")
        term.setTextColor(col)
    end

    return logger
end

return {Logger=Logger, Tester=Tester}

    