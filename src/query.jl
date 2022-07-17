module Query
export parseQuery
    function parseQuery(arg::Array{String})
        println(arg)
        println(arg[1])
        println(split(arg[1]))
        query_statement = split(arg[1])
        parsed_query_len = length(query_statement)
        queries = []
        if query_statement[1]=="query" &&  query_statement[2]=="{"
            for s = 3:parsed_query_len
                if query_statement[s] == "}"
                    break
                end
                append!(queries, [query_statement[s]])
            end
        end
        return queries
    end
end