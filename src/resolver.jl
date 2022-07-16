module Resolver
    using Random
    export quoteOfTheDay, random, rollThreeDice,resolveOptions
    function resolveOptions(args::Array)
        results = []
        for func in args
            try
                res = func()
                typeof(res) == String ? append!(results, [res]) : append!(results, res)
            catch
                print("Error: ", func)
            end
        end
        results
    end
        
    function quoteOfTheDay()
        rand() < 0.5 ? "Take it easy" : "Salvation lies within"
    end
    function random()
        rand()
    end
    function rollThreeDice()
        map(x -> 1 + floor(rand() * 6), [1 2 3])
    end
    function rollDice(args)
        output = []
        for i = 0:args.numDice
            append!(output, 1 + floor(rand() * (args.numSides || 6)))
        end
        output
    end
end
