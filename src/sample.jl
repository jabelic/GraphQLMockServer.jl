# Sample Mock Server Usecases
# これがこのライブラリを使用したmock serverのサンプルコードになります

include("./GraphQLServer.jl")
using .GraphQLServer: buildSchema, graphqlApp, listen

# Resolver
function quoteOfTheDay()
    rand() < 0.5 ? "Take it easy" : "Salvation lies within"
end
function random()
    rand()
end
function rollThreeDice()
    map(x -> Int(1 + floor(rand() * 6)), [1 2 3])
end
function rollDice(args)
    output = []
    for i = 0:args.numDice
        append!(output, Int(1 + floor(rand() * (args.numSides || 6))))
    end
    output
end

# Define Schema
_schema = buildSchema("""
  type Query {
    quoteOfTheDay: String
    random: Float!
    rollThreeDice: [Int]
  }
""");
# rollDice(numDice: Int!, numSides: Int): [Int]

input = Dict("endpoint"=>"/graphql", "schema"=>_schema, "resolver"=>[quoteOfTheDay, random, rollThreeDice])
graphqlApp(input)
input2 = Dict("endpoint"=>"/", "schema"=>_schema, "resolver"=>[quoteOfTheDay, random, rollThreeDice])
graphqlApp(input2)

listen()