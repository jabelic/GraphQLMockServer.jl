module Resolver
    using Random
    export resolveOptions
    function get_index(target, ary)
        for (index, item) in enumerate(ary)
            if target == item
                return index
            end
        end
    end
    function get_method_name(func, func_names)
        func_name = string(Symbol(func))
        println(func_name in func_names, func_name)
        if func_name in func_names
            index = get_index(func_name, func_names)
            println(index)
            return Dict("index"=>index, "func_name"=>func_name)
        end
    end
    function resolveOptions(resolvers::Array, queries::Array, field_type::Any)
        # resolversは関数のarray:  [func1, func2, ...]
        # queriesは欲しいfieldがstringのArrayとして渡ってくる
        # field_typeはSchemaから情報を取得
        
        func_names = map(x->x.first, field_type)
        results = Dict()
        for func in resolvers
            try
                function_info = get_method_name(func, func_names)
                # resolverで投げられた関数がSchemaで定義されているか確認している
                if length(function_info) > 0
                    function_name = function_info["func_name"]
                    corresponding_index_in_queries = function_info["index"]
                    if function_name in queries
                        res = func()
                        # expected_type = field_type[index][function_name]
                        results[function_name] = res 
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
