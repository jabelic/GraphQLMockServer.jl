module Schema
export buildSchema
    function buildSchema(arg::String)
        # TODO: parser
        # schema = replace(arg, r"\s"=>s"")
        schema = arg
        println(schema)
        
        for i=1:length(schema)
            # print()
        end
        return schema
    end
end