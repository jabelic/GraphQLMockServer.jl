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
using .Resolver: quoteOfTheDay, random, rollThreeDice, resolveOptions


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
    query = haskey(arg, "query") ? arg["query"] : nothing
    variables = haskey(arg, "variables") ? arg["variables"] : nothing
    # println(parseQuery(query))
    # println(variables)
    parseQuery(query)
end

# OptionsData
function graphqlHTTP(args)
    try
        body::Dict{String, Any} = Requests.jsonpayload()
        println(args["resolver"])
        results = resolveOptions(args["resolver"])
        println("results:::", results)
        return parseInputs(body)
    catch
        println("error")
    end    
end


route("/") do
  (:message => "Hi there!") |> json
end

route("/graphql", method = POST) do
  message = jsonpayload()
  println("入力: ", message)
  println(_schema)
  input = Dict("schema"=>_schema, "resolver"=>[quoteOfTheDay, random, rollThreeDice])
  graphqlHTTP(input) |> json
#   (:echo => (message["message"] * " ") ^ message["repeat"]) |> json
end

"""
Dict{String,Any}("variables" => {
    "dice": 3,
   "sides": 6
},"query" => "\nquery {\n    random\n    rollThreeDice\n    quoteOfTheDay\n}\n")
"""

Genie.startup()
