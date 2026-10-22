using Test, Random

const notebook_path = normpath(joinpath(@__DIR__, "..", "notebooks", "number_guessing_game.jl"))
const notebook_source = read(notebook_path, String)
function cell_source(id)
    marker = "# " * Char(0x2554) * Char(0x2550) * Char(0x2561) * " "
    split(split(notebook_source, marker * id; limit=2)[2], marker; limit=2)[1]
end
include_string(@__MODULE__, cell_source("39614601-d29e-4aff-a148-f2f3c7aecfe8"))
include_string(@__MODULE__, cell_source("87fb556f-640d-443b-a476-e6a96f52922c"))
function evaluate_submission(payload)
    global submitted = payload
    include_string(@__MODULE__, cell_source("3f25c2e3-1328-4db1-9533-5acaee5cdca4") * "\nresult")
end

@testset "Stateless guessing game" begin
    ids = ["0000000000000000", "0123456789abcdef", "ffffffffffffffff"]
    for id in ids
        secret = round_secret(id)
        @test 1 <= secret <= 100
        @test secret == round_secret(id)
        wrong = secret == 1 ? 2 : 1
        payload = Dict("round_id" => id, "guesses" => [wrong], "request_id" => 1)
        first = evaluate_submission(payload)
        @test first.turns == 1 && first.attempts_left == 5
        @test first.round_id == id
        # Another visitor/request must not alter this round.
        evaluate_submission(Dict("round_id" => ids[2], "guesses" => [50]))
        @test evaluate_submission(payload) == first
        payload["request_id"] = 2
        @test evaluate_submission(payload) == first
        @test score_game(secret, [secret]).won
        @test score_game(secret, [fill(wrong, 5); secret]).won
        @test score_game(secret, fill(wrong, 7)).turns == 6
        @test score_game(secret, fill(wrong, 6)).finished
        @test !score_game(secret, fill(wrong, 6)).won
        @test score_game(secret, [secret, wrong]).turns == 1
    end
    @test score_game(1, [1]).won
    @test score_game(100, [100]).won
    @test score_game(50, [0, 101, "no"]).turns == 0
    @test evaluate_submission(missing).turns == 0
    @test evaluate_submission(Dict("round_id" => "invalid", "guesses" => [1])).turns == 0
end

# Optional line-oriented bridge for real-browser tests: round_id;guess,guess,...
if "--bridge" in ARGS
    println("READY")
    flush(stdout)
    for line in eachline(stdin)
        id, values = split(line, ';'; limit=2)
        guesses = isempty(values) ? Int[] : parse.(Int, split(values, ','))
        state = evaluate_submission(Dict("round_id" => id, "guesses" => guesses))
        println(state.turns, ";", state.finished, ";", state.message, ";", round_secret(id))
        flush(stdout)
    end
end
