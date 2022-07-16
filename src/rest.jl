# server
using Genie
import Genie.Router: route
import Genie.Renderer.Json: json
using Genie.Requests

Genie.config.run_as_server = true

function buildSchema(arg::String)
    # TODO: parser
    return arg
end

schema = buildSchema("""
  type Query {
    quoteOfTheDay: String
    random: Float!
    rollThreeDice: [Int]
    rollDice(numDice: Int!, numSides: Int): [Int]
  }
""");

struct Schema
    description::String
end

struct Resolver
    resolvers::Any
end

struct OptionsData
    schema::Schema
    resolver::Resolver
end

struct Query
    # ここは型職人...
    query::String
end

struct InputQuery
    variables::Dict
    query::Query
end

function parseQuery(arg::Dict)
    println(arg)
    arg
end

function graphqlHTTP()
    try
        body::String = Requests.jsonpayload()
        parseQuery(body)
    catch
        println("error")
    end    
end


route("/") do
  (:message => "Hi there!") |> json
end

route("/graphql", method = POST) do
  message = jsonpayload()
  println(message)
  graphqlHTTP() |> json
#   (:echo => (message["message"] * " ") ^ message["repeat"]) |> json
end

"""
Dict{String,Any}("variables" => {
    "dice": 3,
   "sides": 6
},"query" => "\nquery {\n    random\n    rollThreeDice\n    quoteOfTheDay\n}\n")
graphql: Dict{String,Any}("variables" => {
    "dice": 3,
   "sides": 6
},"query" => "\nquery {\n    random\n    rollThreeDice\n    quoteOfTheDay\n}\n")
"""

Genie.startup()
