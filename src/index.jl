module GraphQLServerIndex
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
    using .Schema: buildSchema, get_field_type
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
        # variables = haskey(arg, "variables") ? [arg["variables"]] : nothing
        queries = parseQuery(query)
        Dict("queries"=>queries)
        # Dict(schema => arg["schema"],
        #     resolver => arg["resolver"]
        # )
    end

    # OptionsData
    function graphqlHTTP(args::Dict)
        # argsはschema, resolverを持つ
        try
            body::Dict{String, Any} = Requests.jsonpayload()
            println("body: ",body)
            parsed_inputs = parseInputs(body)
            resolver = nothing
            schema = nothing
            if haskey(args, "resolver") 
                resolver = args["resolver"]
            end
            if haskey(args, "schema") 
                schema = args["schema"]
            end
            # println(resolver, schema)
            field_type = get_field_type(args["schema"])# schemaを見ている
            # println("field_type:", field_type)
            # println("parsed_inputs[queries]", parsed_inputs["queries"])
            results = resolveOptions(resolver, schema, field_type, parsed_inputs["queries"])
            # println("re:",results)
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
