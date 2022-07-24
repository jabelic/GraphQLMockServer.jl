using Test
include("../src/GraphQLServer.jl")
using .GraphQLServer: graphqlHTTP, buildSchema, graphqlApp, listen
using Genie
include("../src/query.jl")
using .Query: parseQuery
include("../src/schema.jl")
using .Schema: get_AST
include("../src/resolver.jl")
using .Resolver: resolveOptions, get_index
    
schema_case = """
  type Query{
    quoteOfTheDay: String
    random: Float!
    rollThreeDice: [Int]
  }
"""
schema_case2 = """
  type Query {
    id: ID!
    firstName: String
    lastName: String
    love: Love!
    sports: [Sports]
  }
"""

# type Author {
schema_case3 = """
  type Query {
    id: ID!
    firstName: String
    lastName: String
    love: Loves!
    sports: [Sports]
  }
  type Loves {
      name: String
  }
  type Sports {
      experienced: String
  }
"""


const sample_input = Dict("query"=>"""
query {
    random
    rollThreeDice
    quoteOfTheDay
}
""")
@testset "GraphQLServer.jl" begin
    # Write your tests here.
    @test get_index(3, [1 2 3 4 5]) == 3
    @test get_index("type", ["type", "Query", "{", "}"]) == 1
    @test get_index("Query", ["type", "Query", "{", "}"]) == 2
    @test get_index("{", ["type", "Query", "{", "}"]) == 3
    @test get_index("}", ["type", "Query", "{", "}"]) == 4

    # === Schema === 
    @test get_AST(schema_case) == Dict{Any,Any}(
        "root" => Dict{Any,Any}(
            "type" => Dict{Any,Any}(
                "Query" => Dict{Any,Any}(
                    "random" => "Float!","quoteOfTheDay" => "String","rollThreeDice" => "[Int]"
                    )
                )
            )
        )
    @test get_AST(schema_case2) == Dict{Any,Any}(
        "root" => Dict{Any,Any}(
            "type" => Dict{Any,Any}(
                "Query" => Dict{Any,Any}(
                    "sports" => "[Sports]",
                    "id" => "ID!",
                    "lastName" => "String",
                    "firstName" => "String",
                    "love" => "Love!"
                    )
                )
            )
        )
    @test get_AST(schema_case3) == Dict{Any,Any}(
            "root" => Dict{Any,Any}(
                "type" => Dict{Any,Any}(
                    "Query" => Dict{Any,Any}(
                        "sports" => "[Sports]",
                        "id" => "ID!",
                        "lastName" => "String",
                        "firstName" => "String",
                        "love" => "Loves!"
                        ),
                    "Loves" => Dict{Any,Any}(
                        "name" => "String"
                        ),
                    "Sports" => Dict{Any,Any}(
                        "experienced" => "String"
                        )
                    )
                )
            )
    #  === Query ===
    # @test parseQuery([sample_input["query"]]) == ["random", "rollThreeDice", "quoteOfTheDay"]
end

