module Schema
export buildSchema
    function parse(arg::String)
        lines = split(arg)
        ast = Dict()
        for item in lines
            
        end
    end
    function buildSchema(arg::String)
        # TODO: parser
        # schema = replace(arg, r"\s"=>s"")
        schema = arg
        println("schema", schema)
        
        for i=1:length(schema)
            # print()
        end
        return schema
    end
end
# type Query {
#     quoteOfTheDay: String
#     random: Float!
#     rollThreeDice: [Int]
#     rollDice(numDice: Int!, numSides: Int): [Int]
# }