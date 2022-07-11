using GraphQLServer
using Documenter

DocMeta.setdocmeta!(GraphQLServer, :DocTestSetup, :(using GraphQLServer); recursive=true)

makedocs(;
    modules=[GraphQLServer],
    authors="Jabelic",
    repo="https://github.com/jabelic/GraphQLServer.jl/blob/{commit}{path}#{line}",
    sitename="GraphQLServer.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)
