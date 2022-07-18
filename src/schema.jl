module Schema
export buildSchema, get_field_type

    # struct _AST
    #     type::Dict
    # end
    # function get_field_and_type(arg)
    # end
    function parse(arg::String)
        nodes = split(arg)
        ast = Dict{Any, Any}()
        isType = false
        modeSchema = false # {}の内部
        fieldMode = false
        typeMode = false
        currentFieldName::String = ""
        for node in nodes
            if !modeSchema && node == "type"
                isType = true
                ast["type"] = nothing
            elseif !modeSchema && node == "Query" && isType
                isType = false
                # tmp = []
                # tmp = append!(tmp, Dict("Query"=>Dict()))
                ast["type"] = Dict{String, Any}("queries"=>nothing)
                ast["type"]["queries"] = Dict{String, Any}("Query"=>[])
            # elseif Query以外のtypeの入力
            elseif node == "{" && !modeSchema
                modeSchema = true
            elseif node == "}" && modeSchema
                modeSchema = false
            elseif modeSchema
                if !fieldMode
                    fieldMode = true
                    currentFieldName = SubString(node, 1, length(node)-1)
                    
                    # ERROR handling
                    if length(currentFieldName) == 0
                        println("AST Error")
                        exit()
                    end
                    
                elseif fieldMode
                    append!(ast["type"]["queries"]["Query"], Dict(currentFieldName=>node))
                    currentFieldName = ""
                    fieldMode = false
                end
            end
        end
        return ast
    end
    function buildSchema(schema::String)
        println("schema", schema)
        AST = parse(schema)
        return AST
    end

    function get_field_type(arg::Dict)
        return haskey(arg["type"]["queries"], "Query") ?  arg["type"]["queries"]["Query"] : nothing
    end
end
# type Query {
#     quoteOfTheDay: String
#     random: Float!
#     rollThreeDice: [Int]
#     rollDice(numDice: Int!, numSides: Int): [Int]
# }