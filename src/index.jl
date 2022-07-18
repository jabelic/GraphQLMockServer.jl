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


_schema = buildSchema("""
  type Query {
    quoteOfTheDay: String
    random: Float!
    rollThreeDice: [Int]
    rollDice(numDice: Int!, numSides: Int): [Int]
  }
""");


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
    # ここは型職人...
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
    println("queries", queries)
    Dict("queries"=>queries)
end

# OptionsData
function graphqlHTTP(args::Dict)
    # argsはschema, resolverを持つ
    try
        body::Dict{String, Any} = Requests.jsonpayload()
        println(body)
        parsed_inputs = parseInputs(body)
        # resolverはmessage
        results = resolveOptions(args["resolver"], parsed_inputs["queries"])
        return Dict("data"=>results)
    catch
        println("error")
    end    
end


route("/") do
  (:message => "Hi there!") |> json
end

route("/graphql", method = POST) do
#   message = jsonpayload()
  input = Dict("schema"=>_schema, "resolver"=>[quoteOfTheDay, random, rollThreeDice])
  graphqlHTTP(input) |> json
end

Genie.startup()
