# Sample Mock Server Usecases
# これがこのライブラリを使用したmock serverのサンプルコードになります

include("./src/GraphQLServer.jl")
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

function id()
    return 10
end

function love()
    Dict("name"=>"john", "live"=>"tokyo")
end

# Define Schema
_schema = buildSchema("""
  type Query {
    quoteOfTheDay: String
    random: Float!
    rollThreeDice: [Int]
  }
""");

schema2 = buildSchema("""
type Query {
    id: ID!
    love: Loves!
}
type Loves {
    name: String
    live: String
}
""");
# rollDice(numDice: Int!, numSides: Int): [Int]

input = Dict("endpoint"=>"/graphql", "schema"=>_schema, "resolver"=>[quoteOfTheDay, random, rollThreeDice])
graphqlApp(input)
input2 = Dict("endpoint"=>"/", "schema"=>schema2, "resolver"=>[id, love])
graphqlApp(input2)

listen()