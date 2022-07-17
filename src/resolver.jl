module Resolver
    using Random
    export quoteOfTheDay, random, rollThreeDice, resolveOptions
    function get_method_name(func)
        try
            return string(Symbol(func))
        catch
            println("Error: method not found")
        end
    end
    function resolveOptions(args::Array, queries::Array)
        results = Dict()
        for func in args
            try
                function_name = get_method_name(func)
                if length(findall(x->x==function_name , queries)) > 0
                    res = func()
                    # typeof(res) == String ? append!(results, Dict(function_name=>[res])) : append!(results, Dict(function_name=>res))
                    # typeof(res) == String ? results[function_name] = res : append!(results, Dict(function_name=>res))
                    results[function_name] = res 
                end
            catch
                print("Error: ", func)
            end
        end
        println("resolve::", results)
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
