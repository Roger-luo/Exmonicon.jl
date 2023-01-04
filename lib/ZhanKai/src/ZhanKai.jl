module ZhanKai

using Expronicon: Substitute, print_expr, sprint_expr, rm_lineinfo, rm_nothing, rm_single_block, canonicalize_lambda_head
using Expronicon.ADT: @adt
using Configurations: @option, Maybe
using MLStyle: @match, @switch, @case
using Glob: @glob_str, GlobMatch, glob
using GarishPrint: pprint_struct
using TOML: TOML
using UUIDs: uuid1
using Pkg: Pkg
using Serialization: serialize, deserialize

include("ignore/ignore.jl")

using .GitIgnore: IgnoreFile, parse, @pattern_str

include("options.jl")
include("expand.jl")
include("process.jl")

end
