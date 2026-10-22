using Test, Symbolics
include(joinpath(@__DIR__, "..", "slider-server-environment", "MathFormulas.jl"))
using .MathFormulas

@testset "Mathematical formulas" begin
    cases = [
        ("x^3/100 + b*x^2/10 -3*x + 4", 2.0, 3.0, -0.72),
        ("sin(x) + cos(x) + tan(x)", 0.0, 0.0, 1.0),
        ("exp(x) + log(b) + sqrt(b)", 0.0, 4.0, 3.0 + log(4)),
        ("pi + π + e", 0.0, 0.0, 2pi + exp(1)),
        ("-x + +b + x^-2", 2.0, 3.0, 1.25),
        ("2x + 3(x+b)", 2.0, 3.0, 19.0),
        ("4", 2.0, 3.0, 4.0),
        ("b", 2.0, 3.0, 3.0),
        ("1000000^8", 0.0, 0.0, 1e48),
    ]
    for (source, x, b, expected) in cases
        result = parse_formula(source)
        @test result.message === nothing
        @test math_value(result.ast, x, b) ≈ expected
        @test plot_value(result.ast, x, b) ≈ expected
    end
    @test isnan(plot_value(parse_formula("sqrt(x-1)").ast, 0, 0))
    @test isnan(plot_value(parse_formula("1/x").ast, 0, 0))
    @test isnan(plot_value(parse_formula("exp(1000000)").ast, 0, 0))
end

@testset "Programming and oversized input rejected before calculation" begin
    sources = [
        "run(`whoami`)", "read(\"file\")", "open(\"file\",\"w\")", "include(\"file\")",
        "eval(x)", "Core.eval(Main,x)", "Base.sin(x)", "getfield(Base,x)(x)",
        "exit()", "sleep(1)", "download(x)", "ccall(x)", "getindex(x,1)",
        "@time sin(x)", "x[1]", "x.b", "x = 1", "begin x; b end",
        "x; b", "x\nb", "x -> x", "sin(x; a=1)", "sin.(x)",
        "[x,b]", "(x,b)", ":x", "\$(x)", "true", "NaN", "Inf", "1e999",
        "", " ", "sin()", "sin(x,b)", "x/", "1//2", "x^b", "x^0.5", "x^9",
        "x^-9", "x^(2+2)", "((x^2)^2)^2", "1000001", "1"^257,
        "sin("^14 * "x" * ")"^14,
        join(fill("sin(x)", 40), "+"), "0x10", "0x1p0", "1_000",
    ]
    for source in sources
        result = parse_formula(source)
        @test result.ast === nothing
        @test result.message isa String
    end
    @test parse_formula(nothing).ast === nothing
    @test parse_formula([1, 2]).ast === nothing
    sentinel = joinpath(@__DIR__, "..", ".local", "formula-must-not-write")
    @test !ispath(sentinel)
    payload = "write(" * repr(sentinel) * ", \"executed\")"
    @test parse_formula(payload).ast === nothing
    @test !ispath(sentinel)
end

# Exercise the same interpreter with symbolic values used by the notebook.
if "--symbolic" in ARGS
    @variables x b
    @testset "Symbolic formula and derivative" begin
        for source in ["x^2+b*x", "sin(x)", "cos(x)", "tan(x)", "exp(x)", "log(x)", "sqrt(x)", "4", "b"]
            ast = parse_formula(source).ast
            formula = math_value(ast, x, b)
            derivative = Symbolics.derivative(formula, x)
            value = Float64(Symbolics.value(substitute(formula, Dict(x => 2.0, b => 3.0))))
            @test value ≈ plot_value(ast, 2, 3)
            actual = Float64(Symbolics.value(substitute(derivative, Dict(x => 2.0, b => 3.0))))
            h = 1e-5
            expected = (plot_value(ast, 2+h, 3) - plot_value(ast, 2-h, 3)) / (2h)
            @test actual ≈ expected atol=1e-6
        end
    end
end
