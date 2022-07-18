module Resolver
    using Random
    export resolveOptions

    # 純粋関数
    function get_index(target, ary)
        for (index, item) in enumerate(ary)
            if target == item
                return index
            end
        end
    end

    function get_method_name(func, func_names)
        println("get_method_name:: ")
        func_name = string(Symbol(func))
        println(func_name in func_names, func_name)
        if func_name in func_names
            index = get_index(func_name, func_names)
            println(index)
            println("================")
            return Dict("index"=>index, "func_name"=>func_name)
        end
    end
    
    function get_type_info(arg::String)
        is_ary_exp = r"\[(.+)\]"
        is_required_exp = r"(.+)!$"
        # https://qiita.com/NagaokaKenichi/items/d341dc092012e05d6606
        graphql_reserved_types = ["Int", "Boolean", "String", "Float", "ID"]
        match_to_ary_type = match(is_ary_exp, arg)
        match_to_required_type = match(is_required_exp, arg)
        # 本当はここもparse必要
        if match_to_ary_type != nothing
            # Array
            types = match_to_ary_type[1]
            tmp = []
            append!(tmp, [types])
            return tmp
            return ["Array{$types, Any}"]
        elseif match_to_required_type != nothing
            types = match_to_required_type[1]
            tmp = []
            append!(tmp, [types])
            return tmp
        elseif arg in graphql_reserved_types
            return [arg, "Nothing"]
        end
    end

    function is_type_valid(from_schema, from_resolver_response::String)
        println("is_type_valid::")
        println(from_schema[1])
        println(from_resolver_response)
        println("==================")
        if from_resolver_response in from_schema || length(findall(from_schema[1], from_resolver_response))>0
            return true
        end
    end
    
    function resolveOptions(resolvers::Array, queries::Array, field_type::Any)
        # resolversは関数のarray:  [func1, func2, ...]
        # queriesは欲しいfieldがstringのArrayとして渡ってくる
        # field_typeはSchemaから情報を取得
        
        # 本来は逆かも. 今はresolverを回しているけど, schemaの方をforで回した方がいいかも
        func_names = map(x->x.first, field_type)
        results = Dict()
        for func in resolvers
            try
                function_info = get_method_name(func, func_names)
                # resolverで投げられた関数がSchemaで定義されているか確認している
                if length(function_info) > 0
                    function_name::String = function_info["func_name"]
                    corresponding_index_in_queries::Int = function_info["index"]
                    if function_name in queries
                        res = func()
                        expected_type::String = field_type[corresponding_index_in_queries].second
                        current_primitive_gql_type = get_type_info(expected_type)
                        if is_type_valid(current_primitive_gql_type, "$(typeof(res))")
                            results[function_name] = res
                        end
                    end
                end
            catch
                println("Error: ", func)
            end
        end
        println("resolve::", results)
        results
    end

end
