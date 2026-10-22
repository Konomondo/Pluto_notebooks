### A Pluto.jl notebook ###
# v0.20.28

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    #! format: off
    return quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
    #! format: on
end

# ╔═╡ 2d5de768-13e9-4cca-bf55-70a6b8ff10f3
begin
    import Pkg
    Pkg.activate(joinpath(@__DIR__, "..", "slider-server-environment"))
    using PlutoUI
    using HypertextLiteral
    using Random
end

# ╔═╡ aec26320-ad06-11f1-9088-ff519a790689
md"""
# Number guessing game
by [Luis Schwarzl](https://www.linkedin.com/in/luis-schwarzl/)


powered by [edventureStudios](https://konomondo.com)

Welcome! Find the secret number between **1 and 100** in **six turns**.
Choose a number below, then press **Check**. Changing your selection is free.
After each guess, you will learn whether it was too low or too high.
"""

# ╔═╡ d2d5447e-5e7d-4609-98aa-cc0f102dc3db
@bind new_game PlutoUI.CounterButton("New game")

# ╔═╡ 39614601-d29e-4aff-a148-f2f3c7aecfe8
# A pure function: rerunning a cell cannot accidentally consume another turn.
function score_game(secret, guesses)
    history = NamedTuple{(:guess, :hint), Tuple{Int, String}}[]
    won = false
    for guess in guesses
        length(history) == 6 && break
        guess isa Integer && 1 <= guess <= 100 || continue
        hint = guess == secret ? "Correct!" : guess < secret ? "Too low" : "Too high"
        push!(history, (guess = Int(guess), hint = hint))
        if guess == secret
            won = true
            break
        end
    end
    turns = length(history)
    finished = won || turns == 6
    message = if won
        turns == 1 ? "Wow, you got lucky! You guessed the number instantly!" :
            "Congratulations! You won in $(turns) turns!"
    elseif finished
        "No guesses left. You lost! The secret number was $(secret)."
    elseif turns == 0
        "You have six attempts to guess the secret number."
    else
        "$(last(history).hint)! Try again."
    end
    (; history, turns, attempts_left = 6 - turns, won, finished, message)
end

# ╔═╡ 87fb556f-640d-443b-a476-e6a96f52922c
# Slider-server requests are stateless: derive the same secret from the browser's round ID.
round_secret(round_id::AbstractString) = rand(Xoshiro(parse(UInt64, round_id; base=16)), 1:100)

# ╔═╡ 7c5f6954-0910-4acc-a33a-907bbf5dd89d
@htl("""
<img src="https://cloud.konomondo.at/s/FjWKQHCWdeewyWw/download"
     alt="Number guessing game illustration"
     width="500" style="max-width: 50%; height: auto;">
""")

# ╔═╡ 55ea27fd-8fa4-4195-8cdd-4121dff17d83
md"""
## From Python to interactive Julia

Python's `random.randint(1, 100)` becomes Julia's `rand(1:100)`.
Instead of blocking with `input()` inside a `while` loop, Pluto's `@bind` sends
submitted guesses to Julia. The `score_game` function evaluates them and Pluto updates the feedback.
The browser handles selection and submission; Julia decides whether each guess is correct.

**Both endpoints count:** Python's `range(1, 100)` excludes 100. This version uses
Julia's inclusive `1:100`, so every button is valid. A correct sixth guess still wins.
Use **New game** to clear all guesses and draw another random secret (which may repeat).

The grid follows Pluto's [custom JavaScript widget API](https://plutojl.org/en/docs/javascript-api/).
Open this notebook in a running Pluto session for interactive Julia feedback.
"""

# ╔═╡ e59a28c7-3e1d-44e0-a012-adb445b20ef5
let
    python_code = Markdown.parse(raw"""

The complete original Python script is shown below, including all final branches.
Only the indentation has been normalized. In this original version, `range(1, 100)`
excludes 100; the interactive Julia game above accepts both 1 and 100.

```python
import random
print("\nWelcome to the number guessing game!")
print("You have six attempts to guess the secret number.")

attempts_left = 6
secret_number = random.randint(1,100)
while attempts_left > 0:
    user_input = (input("Guess a number between 0 and 100: "))

    try:
        guess = int(user_input)
    except ValueError:
        print("Type in a number between 1 and 100 to guess again!")
        print("You still have ", attempts_left, "attempts left.\n")
        continue

    attempts_left -= 1

    if guess == secret_number:
        if attempts_left == 5:
            print("\033[33mWow, you got lucky! You guessed the number instantly!\033[0m")
        else:
            print("\033[32mCongratulations! You won in",6 - attempts_left, "turns!\033[0m")
        break

    elif guess < secret_number and guess in range(1,100):
        print("Your guess was \033[31m too low!\033[0m")
        if attempts_left > 0:
            print("Try again!", attempts_left, "attempt(s) left.\n")
        else:
            print("No guesses left. You lost!")
            print("The secret number was\033[33m", secret_number,"!\033[0m")

    elif guess > secret_number and guess in range(1,100):
        print("Your guess was\033[34m too high!\033[0m")
        if attempts_left > 0:
            print("Try again!", attempts_left, "attempt(s) left.\n")
        elif attempts_left <= 0:
            print("No guesses left. You lost!")
            print("The secret number was\033[33m", secret_number,"\033[0m!")

    elif guess not in range(1,100):
        attempts_left += 1
        print("You didn't type in an eligible number. Try again!")
        print("You still have ", attempts_left, "attempt(s) left.\n")

    else:
        attempts_left += 1
        print("Type in a number between 1 and 100 to guess again!")
        print("You still have ", attempts_left, "attempts left.\n")
```

**End of Python script.**
""")
    @htl("""
    <details class="python-example" open>
        <summary>Complete original Python script</summary>
        <style>
            .python-example .python-scroll {
                max-height: 32rem;
                max-width: 100%;
                overflow: auto;
                scrollbar-gutter: stable;
            }
            .python-example .python-scroll pre {
                width: max-content;
                min-width: 100%;
                max-width: none;
                max-height: none;
                box-sizing: border-box;
                overflow: visible;
            }
            .python-example .python-scroll pre,
            .python-example .python-scroll pre code {
                white-space: pre;
                overflow-wrap: normal;
                word-break: normal;
            }
            .python-example .python-scroll:focus-visible {
                outline: 2px solid currentColor;
                outline-offset: 2px;
            }
        </style>
        <div class="python-scroll" tabindex="0" role="region" aria-label="Complete Python code; scroll vertically and horizontally">
            $(python_code)
        </div>
    </details>
    """)
end

# ╔═╡ c2306335-cca2-481f-9ef1-d5e6bac5ddab
function number_grid(reset_count)
    @htl("""
    <div class="number-game">
        <style>
            .number-game { max-width: 620px; padding: 18px; border: 1px solid #8092a6;
                border-radius: 16px; background: #f5f8fc; color: #172b46; }
            .number-game .number-grid { display: grid; grid-template-columns: repeat(10, minmax(0, 1fr)); gap: 5px; }
            .number-game button { font: inherit; cursor: pointer; }
            .number-game .number-grid button { min-width: 0; min-height: 40px; padding: 4px 0;
                border: 1px solid #8297b0; border-radius: 7px; background: white; color: #172b46; }
            .number-game .number-grid button[aria-pressed="true"] { background: #244fb1; color: white; border-color: #244fb1; }
            .number-game button:focus-visible { outline: 3px solid #b65700; outline-offset: 2px; }
            .number-game button:disabled { opacity: 0.5; cursor: default; }
            .number-game .controls { display: flex; flex-wrap: wrap; align-items: center; gap: 16px; margin-top: 16px; }
            .number-game .check { background: #244fb1; color: white; border: 0; border-radius: 8px; padding: 10px 24px; }
            @media (max-width: 450px) { .number-game { padding: 8px; } .number-game .number-grid { gap: 3px; } }
        </style>
        <div class="number-grid" role="group" aria-label="Choose a number from 1 to 100">
            $([@htl("<button type='button' data-number=$(n) aria-pressed='false'>$(n)</button>") for n in 1:100])
        </div>
        <div class="controls">
            <button type="button" class="check" disabled>Check</button>
            <span class="selection" role="status">Choose a number.</span>
        </div>
        <script>
            const root = currentScript.parentElement;
            const buttons = Array.from(root.querySelectorAll('[data-number]'));
            const check = root.querySelector('.check');
            const selection = root.querySelector('.selection');
            const randomWords = crypto.getRandomValues(new Uint32Array(2));
            const roundId = Array.from(randomWords, n => n.toString(16).padStart(8, '0')).join('');
            const eventName = 'number-game-result-' + roundId;
            let selected = null;
            let pending = false;
            let finished = false;
            let guesses = [];
            let requestId = 0;
            let retry = false;
            let responseTimer;
            root.value = {round_id: roundId, guesses: [], request_id: requestId};

            function refresh() {
                buttons.forEach(button => {
                    button.disabled = pending || finished || retry;
                    button.setAttribute('aria-pressed', String(Number(button.dataset.number) === selected));
                });
                check.disabled = selected === null || pending || finished;
            }
            buttons.forEach(button => button.addEventListener('click', () => {
                if (pending || finished || retry) return;
                selected = Number(button.dataset.number);
                selection.textContent = 'Selected: ' + selected;
                refresh();
            }));
            check.addEventListener('click', () => {
                if (selected === null || pending || finished || (guesses.length >= 6 && !retry)) return;
                if (!retry) guesses = [...guesses, selected];
                retry = false;
                pending = true;
                check.textContent = 'Check';
                selection.textContent = 'Checking ' + selected + '...';
                refresh();
                root.value = {round_id: roundId, guesses: [...guesses], request_id: ++requestId};
                clearTimeout(responseTimer);
                responseTimer = setTimeout(() => {
                    pending = false;
                    retry = true;
                    selection.textContent = 'No response from the server. Retry this guess or start a new game.';
                    check.textContent = 'Retry';
                    refresh();
                }, 30000);
                root.dispatchEvent(new CustomEvent('input'));
            });
            const receiveResult = event => {
                if (event.detail.turns !== guesses.length) return;
                clearTimeout(responseTimer);
                pending = false;
                retry = false;
                check.textContent = 'Check';
                finished = event.detail.finished;
                selected = null;
                selection.textContent = finished ? 'Game over. Press New game to play again.' : 'Choose a number.';
                refresh();
            };
            window.addEventListener(eventName, receiveResult);
            invalidation.then(() => {
                clearTimeout(responseTimer);
                window.removeEventListener(eventName, receiveResult);
            });
        </script>
    </div>
    """)
end

# ╔═╡ d0375bcd-3fba-4dd7-b6b6-da114e7c8a1e
@bind submitted number_grid(new_game)

# ╔═╡ 3f25c2e3-1328-4db1-9533-5acaee5cdca4
result = let
    # Every request contains the whole round; no shared mutable server state is needed.
    round_id = submitted isa AbstractDict ? get(submitted, "round_id", "") : ""
    valid_round = round_id isa AbstractString && occursin(r"^[0-9a-f]{16}$", round_id)
    guesses = valid_round ? get(submitted, "guesses", []) : []
    guesses = guesses isa AbstractVector ? guesses : []
    secret = valid_round ? round_secret(round_id) : 1
    merge(score_game(secret, guesses), (; round_id = valid_round ? round_id : ""))
end;

# ╔═╡ c3c43c07-f611-4556-b5c6-2a2fac459a2c
let
    color = result.won ? "#17653a" : result.finished ? "#a12c24" : "#244fb1"
    @htl("""
    <section aria-label="Game feedback" aria-live="polite" aria-atomic="true">
        <p style=$("font-weight: bold; color: " * color)>$(result.message)</p>
        <p><strong>$(result.attempts_left)</strong> attempts left · $(result.turns) / 6 turns used</p>
        $(isempty(result.history) ? "" : @htl("""
            <table>
                <caption>Guess history</caption>
                <thead><tr><th scope="col">Turn</th><th scope="col">Guess</th><th scope="col">Answer</th></tr></thead>
                <tbody>$([@htl("<tr><td>$(i)</td><td>$(entry.guess)</td><td>$(entry.hint)</td></tr>") for (i, entry) in enumerate(result.history)])</tbody>
            </table>
        """))
        <script>
            window.dispatchEvent(new CustomEvent('number-game-result-' + $(result.round_id), {
                detail: {turns: $(result.turns), finished: $(result.finished)}
            }));
        </script>
    </section>
    """)
end

# ╔═╡ Cell order:
# ╟─aec26320-ad06-11f1-9088-ff519a790689
# ╟─d2d5447e-5e7d-4609-98aa-cc0f102dc3db
# ╠═d0375bcd-3fba-4dd7-b6b6-da114e7c8a1e
# ╟─c3c43c07-f611-4556-b5c6-2a2fac459a2c
# ╟─39614601-d29e-4aff-a148-f2f3c7aecfe8
# ╟─3f25c2e3-1328-4db1-9533-5acaee5cdca4
# ╟─87fb556f-640d-443b-a476-e6a96f52922c
# ╟─2d5de768-13e9-4cca-bf55-70a6b8ff10f3
# ╟─7c5f6954-0910-4acc-a33a-907bbf5dd89d
# ╟─55ea27fd-8fa4-4195-8cdd-4121dff17d83
# ╟─e59a28c7-3e1d-44e0-a012-adb445b20ef5
# ╟─c2306335-cca2-481f-9ef1-d5e6bac5ddab
