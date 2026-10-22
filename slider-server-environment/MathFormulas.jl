module MathFormulas

export parse_formula, math_value, plot_value

const FUNCTIONS = (:sin, :cos, :tan, :exp, :log, :sqrt)
const VARIABLES = (:x, :b, :pi, :π, :e)

invalid(message) = throw(ArgumentError(message))

function literal_power(node)
    value = if node isa Int
        node
    elseif node isa Expr && node.head === :call && length(node.args) == 2 &&
           node.args[1] === :- && node.args[2] isa Int
        -node.args[2]
    else
        invalid("Powers must use literal integers from -8 to 8.")
    end
    -8 <= value <= 8 || invalid("Powers must use literal integers from -8 to 8.")
    value
end

function validate(node, count=Ref(0), depth=0, powers=0)
    count[] += 1
    count[] <= 64 && depth <= 12 || invalid("This formula is too complex; simplify it.")
    if node isa Real && !(node isa Bool)
        isfinite(node) && abs(node) <= 1e6 || invalid("Use finite numbers no larger than 1000000.")
    elseif node isa Symbol
        node in VARIABLES || invalid("Only x, b, pi, π and e are allowed as names.")
    elseif node isa Expr && node.head === :call && !isempty(node.args)
        op, args = first(node.args), node.args[2:end]
        op isa Symbol || invalid("Only named mathematical operations are allowed.")
        arity = length(args)
        allowed = op in (:+, :*) ? 1 <= arity <= 8 :
                  op === :- ? arity in (1, 2) :
                  op in (:/, :^) ? arity == 2 :
                  op in FUNCTIONS ? arity == 1 : false
        allowed || invalid("Use +, -, *, /, ^, sin, cos, tan, exp, log or sqrt with the correct number of arguments.")
        if op === :^
            literal_power(args[2])
            powers += 1
            powers <= 2 || invalid("Use at most two nested powers.")
        end
        foreach(arg -> validate(arg, count, depth + 1, powers), args)
    else
        invalid("Enter a single mathematical formula; programming syntax is not allowed.")
    end
    nothing
end

function parse_formula(source)
    try
        source isa AbstractString || invalid("Enter a mathematical formula.")
        ncodeunits(source) <= 256 || invalid("Use at most 256 bytes of formula text.")
        occursin(r"^[A-Za-z0-9π+\-*/^().,\s]+$", source) || invalid("Use numbers, mathematical names, operators and parentheses only.")
        occursin(r"(?i)\b0[xob]", source) && invalid("Use decimal numbers in formulas.")
        ast = Meta.parse(source)
        validate(ast) # Complete validation happens before any calculation.
        (; ast, message=nothing)
    catch err
        err isa InterruptException && rethrow()
        message = err isa ArgumentError ? err.msg : "The formula could not be parsed; check its syntax."
        (; ast=nothing, message)
    end
end

# Interpret the allowlisted tree directly. Never evaluate Julia code or look up
# functions/variables from input. Dispatch targets below are fixed in this module.
function math_value(node, x, b)
    node isa Real && !(node isa Bool) && return Float64(node)
    node === :x && return x
    node === :b && return b
    node in (:pi, :π) && return Float64(pi)
    node === :e && return Float64(exp(1))
    node isa Expr && node.head === :call || invalid("Invalid formula node.")
    op, args = first(node.args), node.args[2:end]
    op === :^ && return math_value(args[1], x, b) ^ literal_power(args[2])
    values = map(arg -> math_value(arg, x, b), args)
    op === :+ && return +(values...)
    op === :- && return -(values...)
    op === :* && return *(values...)
    op === :/ && return /(values...)
    op === :sin && return sin(only(values))
    op === :cos && return cos(only(values))
    op === :tan && return tan(only(values))
    op === :exp && return exp(only(values))
    op === :log && return log(only(values))
    op === :sqrt && return sqrt(only(values))
    invalid("Unsupported mathematical operation.")
end

function plot_value(ast, x::Real, b::Real)
    ast === nothing && return NaN
    try
        value = Float64(math_value(ast, Float64(x), Float64(b)))
        isfinite(value) ? value : NaN
    catch err
        err isa DomainError || err isa OverflowError || err isa DivideError || rethrow()
        NaN
    end
end

end
