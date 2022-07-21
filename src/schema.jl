module Schema
export buildSchema, get_field_type

    reserved_char = ["{", "}", "\$", "@", ":", "!"]
    
    function get_AST(arg)
        lines = split(arg, r"\n")
        println("lines", lines)
        AST::Any = Dict{Any, Any}("root"=>nothing)
        
        """Query, Mutation, カスタム型(Student, Book, getStudents, getFolders, getIds...)
        typeの後に続くキーワード。
        """
        kinds_of_type::Any = ""

        for row in lines
            row = replace(row, r"\s+"=>";")
            # ;type;Query{ のようになっている
            # 先頭の;を取り除く
            _row = length(row) > 1 && SubString(row, 1, 1) == ";" ? row[2:end] : row
            println("_row:", _row)
            tmp = ""
            field = ""
            for (index, char) in enumerate(_row)
                if occursin(char, "{") || char == "{"
                    # スキーマ定義で型と{の間にspaceがなければここへくる
                    if occursin(tmp, "Query") || tmp == "Query"
                        kinds_of_type = "Query"
                        AST["root"]["type"] = Dict{Any, Any}("Query"=>nothing)
                    else
                        # kinds_of_typeに入る文字列をここでゲットする　
                        # typeの後ろ, {の前に入る. tmpを参照のこと。
                    end
                elseif occursin(char, "}") || char == "}"
                    # ネストしている場合は要注意
                elseif occursin(char, "\$")|| char == "\$"
                # elseif occursin(char, "@") || char == "@"
                elseif occursin(char, ":") || char == ":"
                    # パス
                elseif occursin(char, "!") || char == "!"
                    # println("LLLLLLLLLLLLLLLLLLL")
                    # represent it Required field
                    if occursin(tmp, "String") || tmp == "String"
                        AST["root"]["type"][kinds_of_type][field] = "String!"
                    elseif occursin(tmp, "ID") || tmp == "ID"
                        AST["root"]["type"][kinds_of_type][field] = "ID!"
                    elseif occursin(tmp, "Boolean") || tmp == "Boolean"
                        AST["root"]["type"][kinds_of_type][field] = "Boolean!"
                    elseif occursin(tmp, "Float") || tmp == "Float"
                        AST["root"]["type"][kinds_of_type][field] = "Float!"
                    elseif occursin(tmp, "Int") || tmp == "Int"
                        AST["root"]["type"][kinds_of_type][field] = "Int!"
                    end
                    tmp = ""

                # elseif occursin(char, "[") || char == "["
                # ]だけ見ていれば配列型であることは把握できる？

                elseif occursin(char, "]") || char == "]"
                    if occursin(tmp, "[Int") || tmp == "[Int"
                        AST["root"]["type"][kinds_of_type][field] = "[Int]"
                    elseif occursin(tmp, "[String") || tmp == "[String"
                        AST["root"]["type"][kinds_of_type][field] = "[String]"
                    elseif occursin(tmp, "[Boolean") || tmp == "[Boolean"
                        AST["root"]["type"][kinds_of_type][field] = "[Boolean]"
                    elseif occursin(tmp, "[Float") || tmp == "[Float"
                        AST["root"]["type"][kinds_of_type][field] = "[Float]"
                    elseif occursin(tmp, "[Id") || tmp == "[ID"
                        AST["root"]["type"][kinds_of_type][field] = "[ID]"
                    end

                elseif occursin(char, ";") || char == ";"
                    # 一区切り
                    if occursin(tmp, "type") || tmp == "type"
                        AST["root"] = Dict{Any, Any}("type"=>nothing)
                    elseif occursin(tmp, "Query") || tmp == "Query"
                        # スキーマ定義で型と{の間にspaceがあればここへくる
                        kinds_of_type = "Query"
                        AST["root"]["type"] = Dict{Any, Any}("Query"=>nothing)
                    elseif length(kinds_of_type) > 1
                        # println("kinds_of_type:::::", kinds_of_type)
                        # println(AST["root"]["type"])
                        # println(haskey(AST["root"]["type"], "Query"))
                        if haskey(AST["root"]["type"], "Query")
                            if AST["root"]["type"]["Query"]!=nothing
                                AST["root"]["type"]["Query"] = merge(AST["root"]["type"]["Query"], Dict{Any, Any}(tmp=>nothing))
                            else
                                AST["root"]["type"]["Query"] = Dict{Any, Any}(tmp=>nothing)
                            end
                            field = tmp
                        end
                    end
                    tmp = ""

                elseif index == length(_row)
                    if occursin(tmp, "String") || tmp == "String"
                        AST["root"]["type"][kinds_of_type][field] = "String"
                    # elseif occursin(tmp, "String!") || tmp == "String!"
                    #     AST["root"]["type"][kinds_of_type][field] = "String!"
                    elseif occursin(tmp, "ID") || tmp == "ID"
                        AST["root"]["type"][kinds_of_type][field] = "ID"
                    # elseif occursin(tmp, "ID!") || tmp == "ID!"
                    #     AST["root"]["type"][kinds_of_type][field] = "ID!"
                    elseif occursin(tmp, "Boolean") || tmp == "Boolean"
                        AST["root"]["type"][kinds_of_type][field] = "Boolean"
                    # elseif occursin(tmp, "Boolean!") || tmp == "Boolean!"
                    #     AST["root"]["type"][kinds_of_type][field] = "Boolean!"
                    elseif occursin(tmp, "Float") || tmp == "Float"
                        AST["root"]["type"][kinds_of_type][field] = "Float"
                    # elseif occursin(tmp, "Float!") || tmp == "Float!"
                    #     AST["root"]["type"][kinds_of_type][field] = "Float!"
                    elseif occursin(tmp, "Int") || tmp == "Int"
                        AST["root"]["type"][kinds_of_type][field] = "Int"
                    # elseif occursin(tmp, "Int!") || tmp == "Int!"
                    #     AST["root"]["type"][kinds_of_type][field] = "Int!"
                    # elseif occursin(tmp, "[Int]") || tmp == "[Int]"
                    #     AST["root"]["type"][kinds_of_type][field] = "[Int]"
                    else
                        # custom type
                    end
                else
                    tmp *= char
                end
                println(tmp)
            end
        end
        println("AST", AST)
        println()
    end

    # 行で分ける
    # 空白を詰めて1文字ずつ解析
    # 特殊文字と単語をnodeとして, ASTを構築
    function parse(arg::String)
        get_AST(arg)# 新しく作るやつ

        nodes = split(arg) # FIXME: split の方法を変える. tokenを定義する
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
        # println("schema", schema)
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