module GraphQLServer
export graphqlHTTP, buildSchema, graphqlApp, listen

    # server
    using Genie
    import Genie.Router: route
    import Genie.Renderer.Json: json
    using Genie.Requests
    Genie.config.run_as_server = true

    using Parameters

    include("./query.jl")
    using .Query: parseQuery
    include("./schema.jl")
    using .Schema: buildSchema
    include("./resolver.jl")
    using .Resolver: resolveOptions


    struct _Schema
        description::String
    end

    struct _Resolver
        resolvers::Any
    end

    @with_kw struct OptionsData
        schema::_Schema
        resolver::_Resolver
    end

    struct _Query
        # FIXME: parse
        field::String
    end

    struct InputQuery
        variables::Dict
        query::String
    end


    function parseInputs(arg::Dict)
        query = haskey(arg, "query") ? [arg["query"]] : nothing
        variables = haskey(arg, "variables") ? [arg["variables"]] : nothing
        queries = parseQuery(query)
        Dict("queries"=>queries)
    end

    # OptionsData
    function graphqlHTTP(args::Dict)
        # argsはschema, resolverを持つ
        try
            body::Dict{String, Any} = Requests.jsonpayload()
            parsed_inputs = parseInputs(body)
            results = resolveOptions(args["resolver"], parsed_inputs["queries"])
            Dict("data"=>results)
        catch
            println("error")
        end    
    end

    function graphqlApp(input)
        route(input["endpoint"], method = POST) do
            graphqlHTTP(input) |> json
        end
    end

    function listen()
        Genie.startup()
    end

end
