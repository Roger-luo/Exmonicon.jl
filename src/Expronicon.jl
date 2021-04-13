module Expronicon

using MLStyle
using Markdown
using DocStringExtensions
using OrderedCollections
using MLStyle.MatchImpl
using MLStyle.AbstractPatterns

export 
    # types
    NoDefault, JLExpr, JLFor, JLIfElse, JLMatch,
    JLFunction, JLField, JLKwField, JLStruct, JLKwStruct,
    # analysis
    @expr, @test_expr, compare_expr, compare_vars,
    AnalysisError, is_function, is_kw_function, is_struct,
    is_ifelse, is_for, is_field, is_field_default,
    split_function, split_function_head, split_struct,
    split_struct_name, split_ifelse, annotations,
    uninferrable_typevars, has_symbol,
    is_literal, has_kwfn_constructor, has_plain_constructor,
    # transformations
    no_default, prettify, rm_lineinfo, flatten_blocks, name_only,
    rm_annotations, replace_symbol, subtitute, eval_interp, eval_literal,
    # codegen
    codegen_ast,
    codegen_ast_kwfn,
    codegen_ast_kwfn_plain,
    codegen_ast_kwfn_infer,
    codegen_ast_struct,
    codegen_ast_struct_head,
    codegen_ast_struct_body,
    codegen_match,
    construct_method_plain,
    construct_method_inferable,
    struct_name_plain,
    struct_name_without_inferable,
    # x functions
    xtuple,
    xnamedtuple,
    xcall,
    xpush,
    xfirst,
    xlast,
    xprint,
    xprintln,
    xmap,
    xmapreduce,
    xiterate,
    # match
    @syntax_pattern,
    # printings
    with_marks, with_parathesis, with_curly,
    with_brackets, within_line, within_indent,
    with_begin_end, indent, no_indent,
    no_indent_first_line, indent_print,
    indent_println, print_expr, PrintState




include("patches.jl")
include("types.jl")
include("transform.jl")
include("analysis.jl")
include("codegen.jl")
include("match.jl")
# include("printing.jl")
include("printing2.jl")

end
