### A Pluto.jl notebook ###
# v0.19.32

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 9e471282-eebf-4d5b-a6cb-97ae932c1f1c
md"""
$(Resource("https://github.com/dorn-gerhard/workAdventure/raw/master/Characters/logo_weiss.png"))
"""

# ╔═╡ ae5f29fc-fff3-4bbb-81da-9fd616be93ad
md"""
# Finance plan
"""

# ╔═╡ 1f02a61a-4593-4bcf-bb79-9156eafd1474
begin
	#1 good
	#2 expected
	#3 bad
	
	def_CAC = [5, 40, 80]
	def_customer_lifetime =  [24, 12, 6]
	def_prod_range =  [2:0.1:4, 1:0.1:2, 0.5:0.1:1]
	def_market_share_max_austria = [0.10, 0.05, 0.01]
		
	md"""
	Different scenarios: $(@bind scenario Select([2 => "Expected case", 1 => "Optimal case", 3 => "Bad case"]))
	"""
end

# ╔═╡ 968a8caf-ad21-416c-9acd-740a53eb8ffc
begin
	#p_ein = plot(time_axis, revenue_per_month.(1:length(time_axis)), size = (600, 200), label= :none,  formatter = :plain)
	p_erg = plot(time_axis, result_per_month ./ 1000, size = (600, 300), label= :none, title = "monthly income", linewidth =5, formatter = :plain, ylabel =" revenue | k€", xlabel = "time")
	plot!(p_erg, time_axis, zeros(size(time_axis)), linecolor = :green, linewidth = 2, label = :none, alpha = 0.3)
#	plot(p_ein, p_erg, layout = (2,1), size = (600, 400))
end

# ╔═╡ b9c96a14-b60b-4ddc-9e7f-5f160501677f
md"""
max liquidity needed: **$(max_liqu_needed) k€**
"""

# ╔═╡ 0bd0fb65-cbeb-471c-a1e0-07d55d8c9650
md"""
- 👩‍💼👨‍💼 hiring rate:  $(@bind months_to_new_employee Slider(1:24, default = 4, show_value = true)) (hire new employee every `x` months)
"""

# ╔═╡ d3423ba9-0240-45d9-af6a-e6609e84dc28
@htl("""
Customer Aquisition Cost: $(cac_scrub) €
lifetime: $(lifetime_scrub)
customer acquisition rate: $(cust_acqu_rate_scrub)
""")

# ╔═╡ f1382903-a1f5-4c3e-8d44-deca5f3ba41e
md"""
- Start date 📆 finance plan: $(@bind datum PlutoUI.DateField(default = Date(2022, 11, 1)))
- End date finance plan: $(@bind datum_end PlutoUI.DateField(default = Date(2027, 11, 1)))
- Opening up German market $(@bind market_germany CheckBox()) after $(@bind entry_germany Scrubbable(1:100, default = 26, suffix = " months"))
"""

# ╔═╡ bd0547a9-1632-4b0b-bc4b-64069581ed82
md"""
---
- **productivity**: quests per employee/m: $(slider_prod_range)
- start of more efficient productivity: $(slider_prod_twist)
---
- reachable market share (medium-term): $(slider_marktanteil)
"""

# ╔═╡ aae1714d-358d-4cf9-ad13-189bea325cb7
md"""
## finance model
- expenses 🧾 ≈ employees 👩‍💼👨‍💼
- revenue 💰 = price 💶 ⋅ player 👥
- price 💶: dependent on content 🎲
- player 👥: dependent on possible market share, quality of the game ✔, market dynamics
- game quality ✔: dependent on content 🎲, tutor intelligence, lessons learned
- content 🎲: dependent on employess 👩‍💼👨‍💼
"""

# ╔═╡ c428aa68-b457-4665-aefe-fcbd8c92136e
plot(time_axis, players, size = (600, 200), label= :none, title = market_germany ? "players (with German market)" : "players (without German market)", linewidth = 3, formatter = :plain)

# ╔═╡ 97f7178d-2182-4ae8-b869-785c5a99730b
md"""
# 💰 Revenue
"""

# ╔═╡ f0ef9810-a0a3-47f6-8a25-667734288b53
plot(time_axis, revenue, size = (600, 200), label= :none, title = "revenue cummulated")

# ╔═╡ fa8f41b4-15d8-4bcd-b6f1-e63771c18576
plot(time_axis, revenue_per_month, size = (600, 200), label= :none, title = "Revenue per month")

# ╔═╡ e67da6bb-b2e5-49d5-95c3-03949033822d
times = 1:length(time_axis)

# ╔═╡ dce871dc-5b78-4067-ab00-9e9b4597461d
revenue_per_month = players .* price

# ╔═╡ af5f7d1c-e6b0-49bd-a8f9-921491df41de
revenue = cumsum(revenue_per_month)

# ╔═╡ d94f3f1d-8b80-4ef1-a21d-68ddbefe248b
md"""
# 🧾 Expenses
"""

# ╔═╡ aad8ad1e-b3c7-44dd-9e80-0d25e28f3df1
plot(time_axis, expenses, size = (600, 200), label= :none, title = "Expenses cummulated")

# ╔═╡ 879fd8fe-5654-4a0d-823e-f7d95c96436c
expenses = cumsum(expenses_per_month)

# ╔═╡ d3fdf901-3952-46fa-a78b-243c9cb27e62
expenses_per_month = employees * cost_per_employee + customer_acquisition_cost

# ╔═╡ f3ebd7d3-536e-4da1-a334-4cad88855b5b
result_per_month = revenue_per_month - expenses_per_month

# ╔═╡ 1dc641f8-e45f-4ecc-8811-a83b77a560eb
revenue_per_month

# ╔═╡ 7d101e27-db8c-4be5-a6ff-e7836660b0e1
DataFrame(
	"Employees" => employees, 
	"Expenses" => Int64.(round.(expenses_per_month)),
	"Revenue" => Int64.(round.(revenue_per_month, digits = 0)), 
	"cumsum" => Int64.(round.(cumsum(result_per_month))),
	"Income" => Int64.(round.(result_per_month)), 
	"customers" => round.(players), 
	"price" => price)

# ╔═╡ 01c4d517-b351-4011-a3ba-11c56f16167f
fin_result = revenue - expenses

# ╔═╡ f035fb9b-3729-40aa-bab1-8948cce9a868
max_liqu_needed =  Int(round(-minimum(fin_result) /1000))

# ╔═╡ adef630e-6ca6-48c9-afbc-977d31d5c788
md"""
# 👥 Players
dependent on market potential, game quality, and the effort to acquire new customers (*customer aquisition rate*) and average *customer lifetime*
"""

# ╔═╡ d63b4ef6-e0fa-42f1-a0b3-6bb61fd5fd6b
plot(time_axis, players, size = (600, 200), label= :none, title = "Players")

# ╔═╡ 59ec4e15-6f2e-439c-be6a-34d8a76b04f1
new_customers =(potential_austria * market_share_max_austria .* game_quality .* market_dynamics + 
market_germany * 
potential_germany * market_share_max_austria * game_quality .* market_dyn_germ) ./ 12 * customer_acquisition_rate

# ╔═╡ 19706a2f-c4af-4cba-9068-6350a2b5d649
players = [sum(new_customers[max(1, (i-customer_lifetime)) : i]) for i = 1:length(times)]

# ╔═╡ 3c2d5a88-edcc-4e05-871b-03234a3db051
customer_acquisition_cost = new_customers * CAC

# ╔═╡ 0e15f762-5987-46ec-8c8a-1f7b33baa753
market_dyn_germ = f_log.(times.- entry_germany, 30, 0, 1, 0.15)

# ╔═╡ a088a5da-3113-4146-839f-6b586b5dac53
market_dynamics = f_log.(times, 30, 0, 1, 0.15)

# ╔═╡ 5cfb59a8-86a0-4683-ad00-b3263ce91416
plot(times, market_dynamics)

# ╔═╡ cccaacc6-8b8d-4f8e-84d0-e60c14b37a75
md"""
### Market Austria
- Students: 1 140 000
- Tutoring: 28%
- payed tutoring: 17%
- payed math tutoring: 11%
"""

# ╔═╡ 9fb4ab30-389d-47ec-ab1e-be05472fc3d6
md"""
Mid-term reachable market share: $(slider_marktanteil)
"""

# ╔═╡ b2b7fb34-ff99-4172-8933-a68a029a5aba
students_austria= 1140000 # students

# ╔═╡ 467803c3-dead-4d43-ac50-8a7b74141cb6
potential_austria = students_austria * 0.11

# ╔═╡ a1b20863-cd85-481f-9939-7b8de0019670
md"""
### Market Germany
- Students: 11 000 000
- Tutoring: ~ 28%
- payed tutoring: ~17%
- payed math tutoring: ~10%
"""

# ╔═╡ c9d2b981-938c-4f1d-b5d1-b3f4a1cf2f2c
students_germany = 11000000 # students

# ╔═╡ dfc5646a-0fe6-4811-b52a-f67afd74a3f6
potential_germany = students_germany * 0.1

# ╔═╡ b11385a1-0c93-45b4-bcac-d9f20dd07f95
md"""
# 👩‍💼👨‍💼 Employees
"""

# ╔═╡ 07f0fb97-48aa-442e-98b9-df7e1093d011
plot(time_axis, employees, size = (600, 200), label= :none, title = "Employees")

# ╔═╡ 464213f4-89e5-49fa-9c66-9f17b7514367
employees = times .÷ months_to_new_employee .+ 2

# ╔═╡ 763b7bc0-cae5-48a8-a21a-514d382b70e2
cost_per_employee = 5000

# ╔═╡ 4fb58452-3864-4c92-ba40-39ab9dfbe2fa
md"""
**Productivity**: campaigns/quests production rate per employee: $(slider_prod_range)

more efficient production starting at month: $(slider_prod_twist)
"""

# ╔═╡ 42462032-736d-449b-bcd7-7bf3810629c2
producability = f_log.(times, prod_twist,  prod_range[1],  prod_range[end]) 

# ╔═╡ 8e21a4e8-c843-4e45-a00a-9cefb4319c30
md"""
# 🎲 Quests / Campaigns
"""

# ╔═╡ 5e57b8ce-45ff-4df3-b69e-3917d1e9e072
content_per_month = employees .* producability

# ╔═╡ 0f743f62-dc24-4a37-a4a3-5077747bb1eb
content = cumsum(content_per_month)

# ╔═╡ f78da556-2a09-4d7f-986e-00517fed59ef
begin
	p1 = plot(time_axis, content, label= :none, linewidth =5, formatter = :plain,  xlabel = "time", title = "created quests / campaigns")
	p2 = plot(time_axis, price, label= :none, linewidth =5, formatter = :plain, ylabel =" €", xlabel = "time", title = "price of game / month")
	plot(p1,p2, layout = (2,1))
end

# ╔═╡ adf59a08-ab44-4bc4-a31f-132fa7924de6
md"""
# 💶 Price per game
Discrete function starting at 1€ up to 20€ per month
"""

# ╔═╡ 455bd0fe-1ca6-4347-b604-e79d8be99ade
 plot(time_axis, price, size = (600, 300), label= :none, title = "game price", linewidth =5, formatter = :plain, ylabel =" €", xlabel = "time")

# ╔═╡ 78fdbb88-0237-4208-bab4-f584587b43a0
price = min.(ceil.(content/max_content * 40 ), 40)

# ╔═╡ e073c48a-f763-463c-8b3c-67497147e22c
max_content = 720

# ╔═╡ 7bfcd6ac-0d85-4b56-994c-73179a547b6a
md"""
# ✔ Quality
"""

# ╔═╡ 095dd17b-fbe6-4ab4-9815-d78fe14e0491
md"""
#### Success factors for productivity:
The promise that the game works (creates value) and helps the students, depends on:
- Tutoring intelligence: $(@bind p_system_intelligence Scrubbable(0:0.01:1, default = 0.40, format = "0.0%"))
- Contents: $(@bind p_content Scrubbable(0:0.01:1, default = 0.30, format = "0.0%"))
- Lessons learned: *rest*
"""
#$(@bind p_lessons_learned Scrubbable(0:0.01:1, default = 0.40, format = "0.0%")

# ╔═╡ 2c7d0165-5f0b-4cf1-8d77-825ac1ce5519
begin
	p_lessons_learned = 1- p_system_intelligence - p_content
	p_pie = pie(["tutoring intelligence: " * string(Int(round(p_system_intelligence * 100))) *"%", "contents: "* string(Int(round(p_content * 100))) *"%", "Lessons learned: "* string(Int(round(p_lessons_learned * 100))) *"%"], [p_system_intelligence, p_content, p_lessons_learned], 
	
	#series_annotation = [p_system_intelligence, p_content, p_lessons_learned],
	size = (600, 200),
	legend = :outertopright)
end

# ╔═╡ f16922cf-58cb-445f-9fe9-1886e14d2b12
plot(time_axis, game_quality, label= :none, size = (400,200), title = "game quality", linewidth =5, formatter = :plain, xlabel = "time")

# ╔═╡ 7310d3e0-7aa3-4af8-b6d3-989398d7e560
game_quality = p_content * min.(1, content / max_content) + p_system_intelligence * sys_intelligence + p_lessons_learned * lessons_learned

# ╔═╡ cb06c3d8-fdaf-4076-b88f-0886a989576f
md"""
### Tutoring intelligence
- Recommender system
- Clever Buddy / Bot System
Halftime of implementation: $(@bind half_time_sys_intelligence Scrubbable(1:100, default = 24, suffix = " Monate")); Development speed: $(@bind dev_speed_sys_intelligence Scrubbable(0.01:0.01:2, default = 0.05, format = ".2f", suffix = " "))
"""

# ╔═╡ 7fbb99cd-5ec5-4852-a017-e7748b7b5ceb
sys_intelligence = f_log.(times, half_time_sys_intelligence, 0, 1, dev_speed_sys_intelligence)

# ╔═╡ f1abc127-4e1c-48aa-ad54-d8115327c451
plot(time_axis, sys_intelligence, size = (600, 200), label= :none, title = "Tutoring intelligence")

# ╔═╡ 5a4a8976-e2e9-4815-a840-0df78cd7201e
md"""
### Lessons learned
- Insights from first year 1 to 1 tutoring
- Feedback driven
halftime of lessons learned: $(@bind half_time_lessons_learned Scrubbable(1:100, default = 6, suffix = " Monate")); development speed: $(@bind dev_speed_lessons_learned Scrubbable(0.01:0.01:2, default = 0.85, format = ".2f", suffix = " "))
"""

# ╔═╡ 37ffea46-d636-4d0a-a579-5349a920d925
lessons_learned = f_log.(times, half_time_lessons_learned, 0, 1, dev_speed_lessons_learned)

# ╔═╡ 71d513b4-3bf1-4b2f-943a-8868bf99cde2
plot(time_axis, lessons_learned, size = (600, 200), label= :none, title = "Lessons learned")

# ╔═╡ 34826510-9602-4a49-8dfd-c34368cc8e7d
f_log(t, tip = 10, start_val = 1, end_val = 2, slope = 1) = (end_val - start_val) * (atan(slope * (t-tip)) + pi/2)/pi + start_val

# ╔═╡ 4d7bb9c4-b32f-4697-80b3-bc252c530f74
f_l(t, tip = 10, start_val = 1, end_val = 2, slope = 1) = start_val + (end_val - start_val) ./(1 + exp(- slope * (t - tip)))

# ╔═╡ 33b50157-2f64-498e-a972-fc3d63156a89
time_axis = Date(datum) : Month(1):Date(datum_end)

# ╔═╡ 40966def-ae1f-4ee8-b331-70c544901cbc
begin
	plot(f_l.(1:100))
	plot!(f_log.(1:100) )
end

# ╔═╡ 97a29d85-33d1-4368-822a-5737a4566b07
TableOfContents()

# ╔═╡ 8133a630-c47b-11ec-2b78-571c076a8c9a
begin
    import Pkg
    Pkg.activate(joinpath(@__DIR__, "..", "slider-server-environment"))
	using PlutoUI, Plots, Dates, DataFrames
	using HypertextLiteral
end

# ╔═╡ 568d711f-40c1-465e-b927-3c6f2ac3dd24
begin
slider_marktanteil = @bind market_share_max_austria Scrubbable(0.00:0.001:0.1, default = def_market_share_max_austria[scenario], format = "0.1%")

slider_prod_twist = @bind prod_twist Scrubbable(1:30, default = 10)
end

# ╔═╡ 64811833-e409-4d78-ab22-852610fd14a8
slider_prod_range = @bind prod_range PlutoUI.RangeSlider(0.0:0.1:4, default = def_prod_range[scenario])

# ╔═╡ 83bd5e96-a222-42cf-b516-7776f7c9226e
slider_marktanteil, slider_prod_range, slider_prod_twist

# ╔═╡ 14f6ee3d-5ec7-470e-9c8c-6b38bcb0fbca
cust_acqu_rate_scrub = @bind customer_acquisition_rate Scrubbable(0.1:0.1:2, default = 1.)

# ╔═╡ db8346b4-da24-4988-a723-fa0585096ea0
lifetime_scrub = @bind customer_lifetime Scrubbable(1:48, default = def_customer_lifetime[scenario])

# ╔═╡ 15d39de8-b739-4ff9-aa2a-6ad4522505bb

cac_scrub = @bind CAC Scrubbable(0.00: 0.1: 300, default = def_CAC[scenario])

# ╔═╡ 9b31d8d3-9a7e-4bdf-8c11-efe059fc00fe
md"""
# Abrechnung


## GuV (Gewinn- und Verlustrechnung)
- Betriebsleistung
  - Umsatzerlöse
  - Bestandsveränderung
  - Aktivierte Eigenleistung
  - sonstige betrieblichen Erträge (Förderungen)

- 


## Bilanz
nach außen

- Aktiva


- Passiva

# Planung
## Struktur für Finanzplan
Monatsbasis, Jahresbasis
- Einzahlungen
  - Umsatzerlöse
    - B2C Digital
    - B2C Nachhilfe vor Ort
  - Förderungen
- Auszahlungen
  - Gehälter / Löhne
  - Software Lizenzen
  - Rechts- und Beratungsaufwand
  - Drittdienstleister
  - Infrastruktur
  - PR und Marketing
  - Sonstige Ausgaben
  - Bürokosten
  - Computerinfrastruktur

## Liquiditätsplanung (Finanzplanung)
- Ausgaben
  - Fixkosten
  - Variable Kosten
  - Investitionen
  - Lohnnebenkosten
- Einnahemen
  - Umsatz (Stück * Preis)
  
## Umsatzplanung


"""

# ╔═╡ Cell order:
# ╟─9e471282-eebf-4d5b-a6cb-97ae932c1f1c
# ╟─ae5f29fc-fff3-4bbb-81da-9fd616be93ad
# ╟─1f02a61a-4593-4bcf-bb79-9156eafd1474
# ╟─968a8caf-ad21-416c-9acd-740a53eb8ffc
# ╟─b9c96a14-b60b-4ddc-9e7f-5f160501677f
# ╟─0bd0fb65-cbeb-471c-a1e0-07d55d8c9650
# ╟─d3423ba9-0240-45d9-af6a-e6609e84dc28
# ╟─f1382903-a1f5-4c3e-8d44-deca5f3ba41e
# ╟─bd0547a9-1632-4b0b-bc4b-64069581ed82
# ╟─aae1714d-358d-4cf9-ad13-189bea325cb7
# ╟─c428aa68-b457-4665-aefe-fcbd8c92136e
# ╟─97f7178d-2182-4ae8-b869-785c5a99730b
# ╟─f0ef9810-a0a3-47f6-8a25-667734288b53
# ╟─fa8f41b4-15d8-4bcd-b6f1-e63771c18576
# ╠═e67da6bb-b2e5-49d5-95c3-03949033822d
# ╠═dce871dc-5b78-4067-ab00-9e9b4597461d
# ╟─af5f7d1c-e6b0-49bd-a8f9-921491df41de
# ╟─d94f3f1d-8b80-4ef1-a21d-68ddbefe248b
# ╟─aad8ad1e-b3c7-44dd-9e80-0d25e28f3df1
# ╠═879fd8fe-5654-4a0d-823e-f7d95c96436c
# ╠═d3fdf901-3952-46fa-a78b-243c9cb27e62
# ╠═f3ebd7d3-536e-4da1-a334-4cad88855b5b
# ╠═1dc641f8-e45f-4ecc-8811-a83b77a560eb
# ╠═7d101e27-db8c-4be5-a6ff-e7836660b0e1
# ╠═01c4d517-b351-4011-a3ba-11c56f16167f
# ╠═f035fb9b-3729-40aa-bab1-8948cce9a868
# ╟─adef630e-6ca6-48c9-afbc-977d31d5c788
# ╟─d63b4ef6-e0fa-42f1-a0b3-6bb61fd5fd6b
# ╠═59ec4e15-6f2e-439c-be6a-34d8a76b04f1
# ╠═19706a2f-c4af-4cba-9068-6350a2b5d649
# ╠═3c2d5a88-edcc-4e05-871b-03234a3db051
# ╠═0e15f762-5987-46ec-8c8a-1f7b33baa753
# ╠═a088a5da-3113-4146-839f-6b586b5dac53
# ╠═5cfb59a8-86a0-4683-ad00-b3263ce91416
# ╟─cccaacc6-8b8d-4f8e-84d0-e60c14b37a75
# ╠═9fb4ab30-389d-47ec-ab1e-be05472fc3d6
# ╠═b2b7fb34-ff99-4172-8933-a68a029a5aba
# ╠═467803c3-dead-4d43-ac50-8a7b74141cb6
# ╟─a1b20863-cd85-481f-9939-7b8de0019670
# ╠═c9d2b981-938c-4f1d-b5d1-b3f4a1cf2f2c
# ╠═dfc5646a-0fe6-4811-b52a-f67afd74a3f6
# ╟─b11385a1-0c93-45b4-bcac-d9f20dd07f95
# ╟─07f0fb97-48aa-442e-98b9-df7e1093d011
# ╠═464213f4-89e5-49fa-9c66-9f17b7514367
# ╠═763b7bc0-cae5-48a8-a21a-514d382b70e2
# ╟─4fb58452-3864-4c92-ba40-39ab9dfbe2fa
# ╠═42462032-736d-449b-bcd7-7bf3810629c2
# ╟─8e21a4e8-c843-4e45-a00a-9cefb4319c30
# ╠═5e57b8ce-45ff-4df3-b69e-3917d1e9e072
# ╠═0f743f62-dc24-4a37-a4a3-5077747bb1eb
# ╟─f78da556-2a09-4d7f-986e-00517fed59ef
# ╟─adf59a08-ab44-4bc4-a31f-132fa7924de6
# ╟─455bd0fe-1ca6-4347-b604-e79d8be99ade
# ╠═78fdbb88-0237-4208-bab4-f584587b43a0
# ╠═e073c48a-f763-463c-8b3c-67497147e22c
# ╟─7bfcd6ac-0d85-4b56-994c-73179a547b6a
# ╟─095dd17b-fbe6-4ab4-9815-d78fe14e0491
# ╟─2c7d0165-5f0b-4cf1-8d77-825ac1ce5519
# ╟─f16922cf-58cb-445f-9fe9-1886e14d2b12
# ╠═7310d3e0-7aa3-4af8-b6d3-989398d7e560
# ╟─cb06c3d8-fdaf-4076-b88f-0886a989576f
# ╠═7fbb99cd-5ec5-4852-a017-e7748b7b5ceb
# ╟─f1abc127-4e1c-48aa-ad54-d8115327c451
# ╟─5a4a8976-e2e9-4815-a840-0df78cd7201e
# ╠═37ffea46-d636-4d0a-a579-5349a920d925
# ╟─71d513b4-3bf1-4b2f-943a-8868bf99cde2
# ╠═34826510-9602-4a49-8dfd-c34368cc8e7d
# ╠═4d7bb9c4-b32f-4697-80b3-bc252c530f74
# ╠═33b50157-2f64-498e-a972-fc3d63156a89
# ╠═40966def-ae1f-4ee8-b331-70c544901cbc
# ╠═97a29d85-33d1-4368-822a-5737a4566b07
# ╠═8133a630-c47b-11ec-2b78-571c076a8c9a
# ╠═568d711f-40c1-465e-b927-3c6f2ac3dd24
# ╠═64811833-e409-4d78-ab22-852610fd14a8
# ╠═83bd5e96-a222-42cf-b516-7776f7c9226e
# ╠═14f6ee3d-5ec7-470e-9c8c-6b38bcb0fbca
# ╠═db8346b4-da24-4988-a723-fa0585096ea0
# ╠═15d39de8-b739-4ff9-aa2a-6ad4522505bb
# ╟─9b31d8d3-9a7e-4bdf-8c11-efe059fc00fe
