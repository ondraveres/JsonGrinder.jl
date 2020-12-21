using Documenter
using JsonGrinder

DocMeta.setdocmeta!(JsonGrinder, :DocTestSetup, :(using JsonGrinder); recursive=true)

makedocs(
    sitename = "JsonGrinder",
    format = Documenter.HTML(),
    modules = [JsonGrinder],
    pages = ["Home" => "index.md",
    "Schema" => "schema.md",
    "Creating extractors" => "extractors.md",
    "Extractor functions" => "exfunctions.md",
    "Developers" => "developers.md",
	],

)

deploydocs(
    repo = "github.com/pevnak/JsonGrinder.jl.git",
)
