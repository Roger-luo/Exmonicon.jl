var documenterSearchIndex = {"docs":
[{"location":"types/","page":"types","title":"types","text":"CurrentModule = Expronicon.Types","category":"page"},{"location":"types/#Types","page":"types","title":"Types","text":"","category":"section"},{"location":"types/","page":"types","title":"types","text":"Convenient types for storing analysis results of a given Julia Expr, or for creating certain Julia objects easily.","category":"page"},{"location":"types/","page":"types","title":"types","text":"Modules = [Types]","category":"page"},{"location":"types/#Expronicon.Types","page":"types","title":"Expronicon.Types","text":"intermediate types for Julia expression objects.\n\n\n\n\n\n","category":"module"},{"location":"types/#Expronicon.Types.no_default","page":"types","title":"Expronicon.Types.no_default","text":"const no_default = NoDefault()\n\nConstant instance for NoDefault that describes a field should have no default value.\n\n\n\n\n\n","category":"constant"},{"location":"types/#Expronicon.Types.JLField","page":"types","title":"Expronicon.Types.JLField","text":"JLField <: JLExpr\nJLField(name, type, line)\n\nType describes a Julia field in a Julia struct.\n\n\n\n\n\n","category":"type"},{"location":"types/#Expronicon.Types.JLFunction","page":"types","title":"Expronicon.Types.JLFunction","text":"JLFunction <: JLExpr\n\nType describes a Julia function declaration expression.\n\n\n\n\n\n","category":"type"},{"location":"types/#Expronicon.Types.JLKwField","page":"types","title":"Expronicon.Types.JLKwField","text":"JLKwField <: JLExpr\nJLKwField(name, type, line, default=no_default)\n\nType describes a Julia field that can have a default value in a Julia struct.\n\n\n\n\n\n","category":"type"},{"location":"types/#Expronicon.Types.JLKwStruct","page":"types","title":"Expronicon.Types.JLKwStruct","text":"JLKwStruct <: JLExpr\n\nType describes a Julia struct that allows keyword definition of defaults.\n\n\n\n\n\n","category":"type"},{"location":"types/#Expronicon.Types.JLStruct","page":"types","title":"Expronicon.Types.JLStruct","text":"JLStruct <: JLExpr\n\nType describes a Julia struct.\n\n\n\n\n\n","category":"type"},{"location":"types/#Expronicon.Types.NoDefault","page":"types","title":"Expronicon.Types.NoDefault","text":"NoDefault\n\nType describes a field should have no default value.\n\n\n\n\n\n","category":"type"},{"location":"transform/","page":"Transform","title":"Transform","text":"CurrentModule = Expronicon.Transform","category":"page"},{"location":"transform/#Transform","page":"Transform","title":"Transform","text":"","category":"section"},{"location":"transform/","page":"Transform","title":"Transform","text":"Some common transformations for Julia Expr, these functions takes an Expr and returns an Expr.","category":"page"},{"location":"transform/","page":"Transform","title":"Transform","text":"Modules = [Transform]","category":"page"},{"location":"transform/#Expronicon.Transform","page":"Transform","title":"Expronicon.Transform","text":"transform functions for Julia Expr.\n\n\n\n\n\n","category":"module"},{"location":"transform/#Expronicon.Transform.flatten_blocks-Tuple{Any}","page":"Transform","title":"Expronicon.Transform.flatten_blocks","text":"flatten_blocks(ex)\n\nRemove hierachical expression blocks.\n\n\n\n\n\n","category":"method"},{"location":"transform/#Expronicon.Transform.name_only-Tuple{Any}","page":"Transform","title":"Expronicon.Transform.name_only","text":"name_only(ex)\n\nRemove everything else leaving just names, currently supports function calls, type with type variables, subtype operator <: and type annotation ::.\n\nExample\n\njulia> using Expronicon.Transform\n\njulia> name_only(:(sin(2)))\n:sin\n\njulia> name_only(:(Foo{Int}))\n:Foo\n\njulia> name_only(:(Foo{Int} <: Real))\n:Foo\n\njulia> name_only(:(x::Int))\n:x\n\n\n\n\n\n","category":"method"},{"location":"transform/#Expronicon.Transform.prettify-Tuple{Any}","page":"Transform","title":"Expronicon.Transform.prettify","text":"prettify(ex)\n\nPrettify given expression, remove all LineNumberNode and extra code blocks.\n\n\n\n\n\n","category":"method"},{"location":"transform/#Expronicon.Transform.rm_annotations-Tuple{Any}","page":"Transform","title":"Expronicon.Transform.rm_annotations","text":"rm_annotations(x)\n\nRemove type annotation of given expression.\n\n\n\n\n\n","category":"method"},{"location":"transform/#Expronicon.Transform.rm_lineinfo-Tuple{Any}","page":"Transform","title":"Expronicon.Transform.rm_lineinfo","text":"rm_lineinfo(ex)\n\nRemove LineNumberNode in a given expression.\n\n\n\n\n\n","category":"method"},{"location":"analysis/","page":"Analysis","title":"Analysis","text":"CurrentModule = Expronicon.Analysis","category":"page"},{"location":"analysis/#Analysis","page":"Analysis","title":"Analysis","text":"","category":"section"},{"location":"analysis/","page":"Analysis","title":"Analysis","text":"Functions for analysing a given Julia Expr, e.g splitting Julia function/struct definitions etc.","category":"page"},{"location":"analysis/","page":"Analysis","title":"Analysis","text":"Modules = [Analysis]","category":"page"},{"location":"analysis/#Expronicon.Analysis","page":"Analysis","title":"Expronicon.Analysis","text":"analysis functions for Julia Expr\n\n\n\n\n\n","category":"module"},{"location":"analysis/#Expronicon.Analysis.is_fn-Tuple{Any}","page":"Analysis","title":"Expronicon.Analysis.is_fn","text":"is_fn(def)\n\nCheck if given object is a function expression.\n\n\n\n\n\n","category":"method"},{"location":"analysis/#Expronicon.Analysis.is_kw_fn-Tuple{Any}","page":"Analysis","title":"Expronicon.Analysis.is_kw_fn","text":"is_kw_fn(def)\n\nCheck if a given function definition supports keyword arguments.\n\n\n\n\n\n","category":"method"},{"location":"analysis/#Expronicon.Analysis.split_doc-Tuple{Expr}","page":"Analysis","title":"Expronicon.Analysis.split_doc","text":"split_doc(ex::Expr) -> line, doc, expr\n\nSplit doc string from given expression.\n\n\n\n\n\n","category":"method"},{"location":"analysis/#Expronicon.Analysis.split_function-Tuple{Expr}","page":"Analysis","title":"Expronicon.Analysis.split_function","text":"split_function(ex::Expr) -> head, call, body\n\nSplit function head declaration with function body.\n\n\n\n\n\n","category":"method"},{"location":"analysis/#Expronicon.Analysis.split_function_head-Tuple{Expr}","page":"Analysis","title":"Expronicon.Analysis.split_function_head","text":"split_function_head(ex::Expr) -> name, args, kw, whereparams\n\nSplit function head to name, arguments, keyword arguments and where parameters.\n\n\n\n\n\n","category":"method"},{"location":"analysis/#Expronicon.Analysis.split_struct-Tuple{Expr}","page":"Analysis","title":"Expronicon.Analysis.split_struct","text":"split_struct(ex::Expr) -> ismutable, name, typevars, supertype, body\n\nSplit struct definition head and body.\n\n\n\n\n\n","category":"method"},{"location":"analysis/#Expronicon.Analysis.split_struct_name-Tuple{Any}","page":"Analysis","title":"Expronicon.Analysis.split_struct_name","text":"split_struct_name(ex::Expr) -> name, typevars, supertype\n\nSplit the name, type parameters and supertype definition from struct declaration head.\n\n\n\n\n\n","category":"method"},{"location":"codegen/","page":"CodeGen","title":"CodeGen","text":"CurrentModule = Expronicon.CodeGen","category":"page"},{"location":"codegen/#CodeGen","page":"CodeGen","title":"CodeGen","text":"","category":"section"},{"location":"codegen/","page":"CodeGen","title":"CodeGen","text":"Code generators, functions that generates Julia Expr from given arguments, Expronicon types. You can import all the functions in this module by using Expronicon.CodeGen.","category":"page"},{"location":"codegen/","page":"CodeGen","title":"CodeGen","text":"Modules = [CodeGen]","category":"page"},{"location":"codegen/#Expronicon.CodeGen","page":"CodeGen","title":"Expronicon.CodeGen","text":"collection of code generators.\n\n\n\n\n\n","category":"module"},{"location":"codegen/#Expronicon.CodeGen.codegen_ast_struct-Tuple{Any}","page":"CodeGen","title":"Expronicon.CodeGen.codegen_ast_struct","text":"codegen_ast_struct(def)\n\nGenerate pure Julia struct Expr from struct definition. This is equivalent to codegen_ast for JLStruct. See also codegen_ast.\n\nExample\n\njulia> def = JLKwStruct(:(struct Foo\n           x::Int=1\n           \n           Foo(x::Int) = new(x)\n       end))\nstruct Foo\n    x::Int = 1\nend\n\njulia> codegen_ast_struct(def)\n:(struct Foo\n      #= REPL[21]:2 =#\n      x::Int\n      Foo(x::Int) = begin\n              #= REPL[21]:4 =#\n              new(x)\n          end\n  end)\n\n\n\n\n\n","category":"method"},{"location":"codegen/#Expronicon.CodeGen.codegen_ast_struct_body-Tuple{Any}","page":"CodeGen","title":"Expronicon.CodeGen.codegen_ast_struct_body","text":"codegen_ast_struct_body(def)\n\nGenerate the struct body.\n\nExample\n\njulia> def = JLStruct(:(struct Foo\n           x::Int\n           \n           Foo(x::Int) = new(x)\n       end))\nstruct Foo\n    x::Int\nend\n\njulia> codegen_ast_struct_body(def)\nquote\n    #= REPL[15]:2 =#\n    x::Int\n    Foo(x::Int) = begin\n            #= REPL[15]:4 =#\n            new(x)\n        end\nend\n\n\n\n\n\n","category":"method"},{"location":"codegen/#Expronicon.CodeGen.codegen_ast_struct_curly-Tuple{Any}","page":"CodeGen","title":"Expronicon.CodeGen.codegen_ast_struct_curly","text":"codegen_ast_struct_curly(def)\n\nGenerate the struct name with curly if it is parameterized.\n\nExample\n\njulia> using Expronicon.Types, Expronicon.CodeGen\n\njulia> def = JLStruct(:(struct Foo{T} end))\nstruct Foo{T}\nend\n\njulia> codegen_ast_struct_curly(def)\n:(Foo{T})\n\n\n\n\n\n","category":"method"},{"location":"codegen/#Expronicon.CodeGen.codegen_ast_struct_head-Tuple{Any}","page":"CodeGen","title":"Expronicon.CodeGen.codegen_ast_struct_head","text":"codegen_ast_struct_head(def)\n\nGenerate the struct head.\n\nExample\n\njulia> using Expronicon.Types, Expronicon.CodeGen\n\njulia> def = JLStruct(:(struct Foo{T} end))\nstruct Foo{T}\nend\n\njulia> codegen_ast_struct_head(def)\n:(Foo{T})\n\njulia> def = JLStruct(:(struct Foo{T} <: AbstractArray end))\nstruct Foo{T} <: AbstractArray\nend\n\njulia> codegen_ast_struct_head(def)\n:(Foo{T} <: AbstractArray)\n\n\n\n\n\n","category":"method"},{"location":"codegen/#Expronicon.CodeGen.codegen_match","page":"CodeGen","title":"Expronicon.CodeGen.codegen_match","text":"codegen_match(f, x[, line::LineNumberNode=LineNumberNode(0), mod::Module=Main])\n\nGenerate a zero dependency match expression using MLStyle code generator, the syntax is identical to MLStyle.\n\nExample\n\ncodegen_match(:x) do\n    quote\n        1 => true\n        2 => false\n        _ => nothing\n    end\nend\n\nThis code generates the following corresponding MLStyle expression\n\n@match x begin\n    1 => true\n    2 => false\n    _ => nothing\nend\n\n\n\n\n\n","category":"function"},{"location":"","page":"Home","title":"Home","text":"CurrentModule = Expronicon","category":"page"},{"location":"#Expronicon","page":"Home","title":"Expronicon","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"(Image: Stable) (Image: Dev) (Image: Build Status) (Image: Coverage)","category":"page"},{"location":"","page":"Home","title":"Home","text":"Collective tools for metaprogramming on Julia Expr.","category":"page"},{"location":"printings/","page":"Printings","title":"Printings","text":"CurrentModule = Expronicon.Printings","category":"page"},{"location":"printings/#Printings","page":"Printings","title":"Printings","text":"","category":"section"},{"location":"printings/","page":"Printings","title":"Printings","text":"Pretty printing functions.","category":"page"},{"location":"printings/","page":"Printings","title":"Printings","text":"Modules = [Printings]","category":"page"},{"location":"printings/#Expronicon.Printings","page":"Printings","title":"Expronicon.Printings","text":"Expronicon type pretty printings.\n\n\n\n\n\n","category":"module"},{"location":"printings/#Expronicon.Printings.print_ast-Tuple{IO,Vararg{Any,N} where N}","page":"Printings","title":"Expronicon.Printings.print_ast","text":"print_ast(io::IO, xs...)\n\nPrint Julia AST. This is a custom implementation of Base.show(io, ::Expr).\n\n\n\n\n\n","category":"method"},{"location":"printings/#Expronicon.Printings.print_collection-Tuple{Any,Any}","page":"Printings","title":"Expronicon.Printings.print_collection","text":"print_collection(io, xs; delim=\",\")\n\nPrint a collection xs with deliminator delim, default is \",\".\n\n\n\n\n\n","category":"method"},{"location":"printings/#Expronicon.Printings.with_begin_end-Tuple{Any,IO}","page":"Printings","title":"Expronicon.Printings.with_begin_end","text":"with_begin_end(f, io::IO)\n\nPrint with begin ... end. See also with_marks, with_parathesis, with_curly, with_brackets.\n\n\n\n\n\n","category":"method"},{"location":"printings/#Expronicon.Printings.with_brackets-Tuple{Any,IO}","page":"Printings","title":"Expronicon.Printings.with_brackets","text":"with_brackets(f, io::IO)\n\nPrint with brackets. See also with_marks, with_parathesis, with_curly, with_begin_end.\n\n\n\n\n\n","category":"method"},{"location":"printings/#Expronicon.Printings.with_curly-Tuple{Any,IO}","page":"Printings","title":"Expronicon.Printings.with_curly","text":"with_curly(f, io::IO)\n\nPrint with curly parathesis. See also with_marks, with_parathesis, with_brackets, with_begin_end.\n\n\n\n\n\n","category":"method"},{"location":"printings/#Expronicon.Printings.with_double_quotes-Tuple{Any,IO}","page":"Printings","title":"Expronicon.Printings.with_double_quotes","text":"with_double_quotes(f, io::IO)\n\nPrint with double quotes.\n\n\n\n\n\n","category":"method"},{"location":"printings/#Expronicon.Printings.with_marks-Tuple{Any,IO,Any,Any}","page":"Printings","title":"Expronicon.Printings.with_marks","text":"with_marks(f, io, lhs, rhs)\n\nPrint using f with marks specified on LHS and RHS by lhs and rhs. See also with_parathesis, with_curly, with_brackets, with_begin_end.\n\n\n\n\n\n","category":"method"},{"location":"printings/#Expronicon.Printings.with_parathesis-Tuple{Any,IO}","page":"Printings","title":"Expronicon.Printings.with_parathesis","text":"with_parathesis(f, io::IO)\n\nPrint with parathesis. See also with_marks, with_curly, with_brackets, with_begin_end.\n\nExample\n\njulia> with_parathesis(stdout) do\n        print(1, \", \", 2)\n    end\n(1, 2)\n\n\n\n\n\n","category":"method"},{"location":"printings/#Expronicon.Printings.with_triple_quotes-Tuple{Any,IO}","page":"Printings","title":"Expronicon.Printings.with_triple_quotes","text":"with_triple_quotes(f, io::IO)\n\nPrint with triple quotes.\n\n\n\n\n\n","category":"method"}]
}
