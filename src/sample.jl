using Genie
import Genie.Router: route
import Genie.Renderer.Json: json
Genie.config.run_as_server = true

include("./GraphQLServer.jl")
using .GraphQLServer: graphqlHTTP, buildSchema

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


_schema = buildSchema("""
  type Query {
    quoteOfTheDay: String
    random: Float!
    rollThreeDice: [Int]
    rollDice(numDice: Int!, numSides: Int): [Int]
  }
""");

route("/") do
  (:message => "Hi there!") |> json
end
 
route("/graphql", method = POST) do
  input = Dict("schema"=>_schema, "resolver"=>[quoteOfTheDay, random, rollThreeDice])
  println(input)
  graphqlHTTP(input) |> json
end

Genie.startup()