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
            # FIXME
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
            # FIXME
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
        if from_resolver_response_type in from_schema_type || length(findall(from_schema_type[1], from_resolver_response_type))>0
            return true
        end
        types = schema["root"]["type"]
        for type in keys(types)
            if type!= "Query" && type in from_schema_type
                field_in_schema = types[type]
                _key_names = [it for it in keys(field_in_schema)] # name
                _val_types = [it for it in values(field_in_schema)] # String/
                for index = 1:length(_val_types)
                    if "$(typeof(res[_key_names[index]]))" == _val_types[index]
                        return true
                    end
                end
            end
        end
    end
    
    function resolveOptions(resolvers::Any, schema::Any, field_type::Any, queries)
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
                    corresponding_index_in_queries::Any = nothing
                    function_name::String = ""
                    if length(function_info) > 0
                        function_name = function_info["func_name"]
                        corresponding_index_in_queries = function_info["index"]
                    end
                    if function_name == fieldname && function_name in queries
                        res = func()
                        expected_type::String = fieldtype
                        # println("expected_type::::::::", expected_type)
                        current_resolver_return_type = get_type_info(expected_type)
                        # println("current_resolver_return_type",current_resolver_return_type)
                        # println("]]]]]]]]]]response:",res)
                        if is_type_valid(current_resolver_return_type, "$(typeof(res))", res, schema)
                            results[function_name] = res
                            # println("response:",res)
                        end
                    end
                catch
                    println("ERROR")
                end
            end
        end
        return results
    end

end
