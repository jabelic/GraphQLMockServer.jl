module Resolver
    # using Random
    export resolveOptions, get_index

    # 純粋関数
    function get_index(target, ary)
        for (index, item) in enumerate(ary)
            if target == item
                return index
            end
        end
    end

    function get_method_name(func, func_names)
        func_name = string(Symbol(func))
        # println(func_name in func_names, func_name)
        if func_name in func_names
            index = get_index(func_name, func_names)
            # println(index)
            return Dict("index"=>index, "func_name"=>func_name)
        end
    end
    
    function get_type_info(arg::String)
        # println(arg)
        is_ary_exp = r"\[(.+)\]"
        is_required_exp = r"(.+)!$"
        # https://qiita.com/NagaokaKenichi/items/d341dc092012e05d6606
        graphql_reserved_types = ["Int", "Boolean", "String", "Float", "ID"]
        match_to_ary_type = match(is_ary_exp, arg)
        match_to_required_type = match(is_required_exp, arg)
        # println(match_to_ary_type, match_to_required_type)
        # 本当はここもparse必要
        if match_to_ary_type != nothing
            if arg == "ID" || arg == "ID!" || arg == "[ID]" || arg == "[ID!]"
                return ["Int", "Int32", "Int64", "Nothing"]
            else
                # Array
                types = match_to_ary_type[1]
                tmp = []
                append!(tmp, [types])
                return tmp
            end
            # return ["Array{$types, Any}"]
        elseif match_to_required_type != nothing
            if arg == "ID" || arg == "ID!" || arg == "[ID]" || arg == "[ID!]"
                return ["Int", "Int32", "Int64", "Nothing"]
            else
                types = match_to_required_type[1]
                tmp = []
                append!(tmp, [types])
                return tmp
            end
        elseif arg in graphql_reserved_types
            if arg == "ID" || arg == "ID!" || arg == "[ID]" || arg == "[ID!]"
                return ["Int", "Int32", "Int64", "Nothing"]
            else
                return [arg, "Nothing"]
            end
        else
            tmp = []
            append!(tmp, [arg])
            return tmp
        end
    end

    function is_type_valid(from_schema_type, from_resolver_response_type::String, res, schema)
        # from_schema_type: ["Loves"]
        # println("is_type_valid::")
        # println(from_schema_type[1])
        # println(from_resolver_response_type)
        # println("==================")
        # println(from_resolver_response_type in from_schema_type , length(findall(from_schema_type[1], from_resolver_response_type))>0)
        if from_resolver_response_type in from_schema_type || length(findall(from_schema_type[1], from_resolver_response_type))>0
            return true
        end
        types = schema["root"]["type"]
        # println("response: ", res) # Dict("name" => "john")
        # println("types: ",types) # Dict{Any,Any}("Query" => Dict{Any,Any}("id" => "ID!","love" => "Loves!"),"Loves" => Dict{Any,Any}("name" => "String"))
        # println("keys of types",keys(types))# Any["Query", "Loves"]
        # println("from_schema_type: ", from_schema_type) # Any["Loves"]
        # println("from_resolver_response_type: ", from_resolver_response_type) #Dict{String,String}
        for type in keys(types)
            if type!= "Query" && type in from_schema_type
                # println(type!= "Query" , type in from_schema_type)
                # println("type in loop", type) # Loves
                # println("types[type]: ", types[type]) # Dict{Any,Any}("name" => "String")
                field_in_schema = types[type]
                _key_names = [it for it in keys(field_in_schema)] # name
                _val_types = [it for it in values(field_in_schema)] # String/
                # println("::::::",_key_names, _val_types) # ["name"]["String"]
                # println(_key_names[1]) # name
                # println(typeof(_key_names[1])) #String
                # println(" _val_types[1]", _val_types[1], "   ", typeof(_val_types[1]))
                # println(res[_key_names[1]]) #john
                # println(typeof(res[_key_names[1]]))  #String
                # println("condition if:", "$(typeof(res[_key_names[1]]))" == _val_types[1])
                if "$(typeof(res[_key_names[1]]))" == _val_types[1]
                    return true
                end
                # return key.second
            end
        end
    end
    
    function resolveOptions(resolvers::Any, schema::Any, field_type::Any)
        # println(resolvers)
        # Function[quoteOfTheDay, random, rollThreeDice]
        # println(schema)
        # Dict{Any,Any}("root" => Dict{Any,Any}("type" => Dict{Any,Any}("Query" => Dict{Any,Any}("random" => "Float!","quoteOfTheDay" => "String","rollThreeDice" => "[Int]"))))
        # println(field_type)
        # Dict{Any,Any}("random" => "Float!","quoteOfTheDay" => "String","rollThreeDice" => "[Int]")

        
        # resolversは関数のarray:  [func1, func2, ...]
        # queriesは欲しいfieldがstringのArrayとして渡ってくる
        # field_typeはSchemaから情報を取得
        
        # 本来は逆かも. 今はresolverを回しているけど, schemaの方をforで回した方がいいかも
        # func_names = map(x->x.first, field_type)
        func_names = keys(field_type)
        
        query = nothing
        results = Dict()
        if haskey(schema["root"]["type"], "Query")
            query = schema["root"]["type"]["Query"]
        else
            println("Error: no type Query")
        end
        for field in query
            # query
            fieldname = field.first
            fieldtype = field.second
            # resolversの中から一致するfieldのresolverを探す
            for func in resolvers
                try
                    function_info = get_method_name(func, func_names)
                    # println("funcsion_info====", function_info, length(function_info))
                    corresponding_index_in_queries::Any = nothing
                    function_name::String = ""
                    # println("-0-2")
                    if length(function_info) > 0
                        # println("-0-2---2--3-4-4")
                        function_name = function_info["func_name"]
                        corresponding_index_in_queries = function_info["index"]
                    end
                    # println("-------44-----")
                    if function_name == fieldname
                        res = func()
                        expected_type::String = fieldtype
                        # println("expected_type::::::::", expected_type)
                        current_resolver_return_type = get_type_info(expected_type)
                        println("current_resolver_return_type",current_resolver_return_type)
                        println("]]]]]]]]]]response:",res)
                        if is_type_valid(current_resolver_return_type, "$(typeof(res))", res, schema)
                            results[function_name] = res
                            println("response:",res)
                        end
                    end
                catch
                    println("ERROR")
                end
            end
            # println("999")
        end
        println(results)
        return results
        
        # results = Dict()
        # for func in resolvers
        #     try
        #         function_info = get_method_name(func, func_names)
        #         # resolverで投げられた関数がSchemaで定義されているか確認している
        #         if length(function_info) > 0
        #             function_name::String = function_info["func_name"]
        #             corresponding_index_in_queries::Int = function_info["index"]
        #             if function_name in queries
        #                 res = func()
        #                 expected_type::String = field_type[corresponding_index_in_queries].second
        #                 current_resolver_return_type = get_type_info(expected_type)
        #                 if is_type_valid(current_resolver_return_type, "$(typeof(res))")
        #                     results[function_name] = res
        #                 end
        #             end
        #         end
        #     catch
        #         println("Error: ", func)
        #     end
        # end
        # println("resolve::", results)
    end

end
