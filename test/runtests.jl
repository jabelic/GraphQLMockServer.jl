using Test
include("../src/GraphQLServer.jl")
using .GraphQLServer: graphqlHTTP, buildSchema, graphqlApp, listen
using Genie
include("../src/query.jl")
using .Query: parseQuery
# include("../src/schema.jl")
# using .Schema: buildSchema, get_field_type
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
  type Author {
    id: ID!
    firstName: String
    lastName: String
    love{
        food
        color
    }
    hoge(id:ID!): {
        name
    }
  }
"""

const sample_input = Dict("query"=>"""
query {
    random
    rollThreeDice
    quoteOfTheDay
}
""")

println(buildSchema(schema_case))
@testset "GraphQLServer.jl" begin
    # Write your tests here.
    @test get_index(3, [1 2 3 4 5]) == 3
    @test get_index("type", ["type", "Query", "{", "}"]) == 1
    @test get_index("Query", ["type", "Query", "{", "}"]) == 2
    @test get_index("{", ["type", "Query", "{", "}"]) == 3
    @test get_index("}", ["type", "Query", "{", "}"]) == 4

    # === Schema === 
    # @test buildSchema(schema_case) == Dict{String, Any}(
    #     "type" => Dict{String,Any}(
    #         "queries" => Dict{String,Any}(
    #             "Query" => ["quoteOfTheDay" => "String",
    #                         "random" => "Float!",
    #                         "rollThreeDice" => "[Int]"]
    #             )
    #         )
    #     )
    # @test buildSchema(schema_case2) == Dict{String, Any}(
    #     "type" => Dict{String,Any}(
    #         "queries" => Dict{String,Any}(
    #             "Author" => ["id" => "ID",
    #                         "firstName" => "String",
    #                         "lastName" => "String"]
    #             )
    #         )
    #     )

    #  === Query ===
    # @test parseQuery([sample_input["query"]]) == ["random", "rollThreeDice", "quoteOfTheDay"]
end
