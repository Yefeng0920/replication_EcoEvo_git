### A Pluto.jl notebook ###
# v0.19.37

using Markdown
using InteractiveUtils

# ╔═╡ 9ff43490-bff1-11ee-1c31-bbd79e192d8f
begin
	using Empirikos
	using CSV
	using SCIP
	using DataFrames
	using Plots
	using PGFPlotsX
	using StatsBase
	using LaTeXStrings
end

# ╔═╡ 39c4502b-5968-4d61-a3bf-69a0da8ae95b
pgfplotsx()

# ╔═╡ a1f65daa-ebad-4caa-a725-ec7a75cec406
df = CSV.read("dat_processed_lnRR.csv", DataFrame; ntasks=1)

# ╔═╡ a99ff6d7-a0fd-4c75-a74f-9c159803d2f3
discr = interval_discretizer(2.3:0.1:10.0)

# ╔═╡ 754bf2f5-628a-480d-aa77-ebb40d5ad4fa
df.EBSample = Empirikos.FoldedNormalSample.(discr.(abs.(df.z)));

# ╔═╡ 1ca82aa8-1585-4a1e-98d8-df2ca54c1f93
gdf = groupby(df, :study);

# ╔═╡ 8f5f4b3c-525d-4b6c-bbe3-7b4865d085e0
Zs_collected = [Empirikos.DependentReplicatedSample(collect(idf.EBSample)) for idf in gdf] 

# ╔═╡ 7904df98-76b5-47a0-8695-fc5ac40bda10
flatten_summarized_Zs = summarize(Zs_collected; flatten=true)

# ╔═╡ d91e9792-19dc-4cbe-821b-6b6097601f40
md"""### Preliminaries for confidence interval construction"""

# ╔═╡ 585e2bf0-e929-4a84-bb2c-97aa9d21c269
floc = DvoretzkyKieferWolfowitz(;α=0.05)

# ╔═╡ abdca97f-66c8-424e-8da7-b4fe05ea9209
fitted_floc = fit(floc, flatten_summarized_Zs)

# ╔═╡ 73f7107c-5900-482a-942f-99fd8616b83e
𝒢 = Empirikos.autoconvexclass(
	GaussianScaleMixtureClass(), 
	σ_min=1e-5,
	σ_max=500.0, 
	grid_scaling=1.05
)

# ╔═╡ db877ae8-03d4-418a-b1d1-de52944f7770
length(components(𝒢))

# ╔═╡ c2a9ee82-0a42-4f1c-ac61-509eb5e0d415
floc_interval = FLocalizationInterval(;
	flocalization= fitted_floc, 
	convexclass = 𝒢,
    solver = SCIP.Optimizer
)

# ╔═╡ b9a6be55-e4e0-4514-9dbb-3a842fb976dd
md"""### 4-component $\widehat{G}$ estimated in R Code"""

# ╔═╡ 83861c6d-a842-4df9-8a24-215ff6b680b6
Ĝ = MixtureModel( 
	Normal.(0.0,  [2.804612042;  1.000000055;  4.644345713; 12.40563397]),
    Empirikos.fix_πs([0.342861781; 0.336363648; 0.171018398; 0.149756172])
)


# ╔═╡ 84913324-568b-4b8c-9674-86bca1da742e
md"""### Replication Probability"""

# ╔═╡ edd95444-12f8-4006-bbd4-dc02a001a9f6
begin
	
struct ReplicationProbability <: Empirikos.LinearEBayesTarget end
	
function (::ReplicationProbability)(μ::Number)
   2*cdf(Normal(), μ)*cdf(Normal(), -1.96 + μ)
end

end

# ╔═╡ 1a055588-ddc6-4017-951f-6cb31e6e627d
repl = ReplicationProbability()

# ╔═╡ ee3a5078-345e-4593-9fc5-6b94c6b3d7ee
md"""#### Point estimate
(should be same as in R)"""

# ╔═╡ 74d53dfa-db60-4fc2-959b-951d63e48303
round(repl(Ĝ); digits=3)

# ╔═╡ 11670e04-04c0-4fd0-bc08-a107a684e296
md"""#### Confidence interval"""

# ╔═╡ aaa39a37-e6c2-470a-bf1b-6213a634ca1e
# ╠═╡ show_logs = false
repl_ci = confint(floc_interval, repl)

# ╔═╡ 35885026-2722-4525-8d0b-41db461d1aa8
md"""### Replication Probability among $z \geq 1.96$"""

# ╔═╡ c5fb73dc-8416-43fc-a663-4dd625262a11
struct ReplicationProbabilityAmongSignificant <: Empirikos.AbstractPosteriorTarget end

# ╔═╡ f6bcdba8-340e-45ac-9ee6-0a259d519b99
function Empirikos.location(::ReplicationProbabilityAmongSignificant)
	StandardNormalSample(Interval(1.96, nothing))
end

# ╔═╡ d2564355-2061-4443-a801-4aa6f0fa587b
function (::Empirikos.PosteriorTargetNumerator{ReplicationProbabilityAmongSignificant})(μ::Number) 
    abs2(cdf(Normal(), -1.96 + μ))
end 

# ╔═╡ 9d5f2df2-4fcf-4c59-ba5d-9a44660a6ed0
replsignificant = ReplicationProbabilityAmongSignificant()

# ╔═╡ d6e5d08d-38f8-496a-b1b8-1bee4d7300d3
md"""#### Point estimate
(should be same as in R)"""

# ╔═╡ 41c22eef-5e09-414f-9fa0-31e6da3e80e8
round(replsignificant(Ĝ); digits=3)

# ╔═╡ f92edfd3-019e-4e6a-b6c1-a4bca4a29753
md"""#### Confidence interval"""

# ╔═╡ 1b85ac5c-2a2a-401e-b61e-afae1b61b782
# ╠═╡ show_logs = false
replsignificant_ci = confint(floc_interval, replsignificant)

# ╔═╡ c5d5fe9b-c390-42cd-8095-8a5cfa7d2ad0
md"""### Replication probability conditional on $z$"""

# ╔═╡ fcc5f8bc-896a-42ad-a0e8-dbd59a0cfaa4
begin
struct ConditionalReplicationProbability{EB<:StandardNormalSample, S} <: Empirikos.BasicPosteriorTarget
    Z::EB
	repl_multiplier::S
end

ConditionalReplicationProbability(Z) = ConditionalReplicationProbability(Z,1)

end

# ╔═╡ 577136fb-51be-439d-909c-59489c39fd62
function Empirikos.compute_target(::Empirikos.Conjugate, target::ConditionalReplicationProbability, Z::EBayesSample, prior)
	post = Empirikos.posterior(Z, prior)
	η = sqrt(target.repl_multiplier)
	Zrepl = NormalSample(nothing, 1/η)
    marg = marginalize(Zrepl, post)
    if response(Z) >= 0 
        ccdf(marg, 1.96 / η)
    else
        cdf(marg, -1.96 / η)
    end
end

# ╔═╡ 6c1dd17e-92b3-46bb-bbd4-2332040c6d09
md"""
We will compute the confidence interval for all values $z=0,0.1,0.2,\dotsc,8$."""

# ╔═╡ e96ab4de-481b-4455-812d-63afdb1af8c1
zs_locs = sort(vcat(0.0:0.1:9, [1.644854; 1.959964; 2.575829; 3.290527; 3.890592]))

# ╔═╡ bfe3634e-4cdc-4c7b-a83e-9536092b5c57
crepls = ConditionalReplicationProbability.(StandardNormalSample.(zs_locs))

# ╔═╡ 22e14ae6-2b95-45f2-9017-ec3e6d4940a9
md"""#### Point estimate
(should be same as in R)"""

# ╔═╡ 29a3ed6b-9ed6-4ac9-9025-4fe1cecc4125
crepls_Ĝ = crepls.(Ĝ)

# ╔═╡ 08f76833-4856-429d-b7a5-633eec225884
# ╠═╡ show_logs = false
replication_plot = plot(zs_locs, crepls_Ĝ, xlabel=L"Z", 
	ylabel="Replication Probability", 
	label = nothing,
	color=:black,  
	thickness_scaling = 1.4,
	grid = nothing,
	linewidth = 1.5,
    frame = :box
)

# ╔═╡ d7d56219-f0a7-433e-8de7-897236c383c4
md"""#### Confidence interval"""

# ╔═╡ ccb87cd9-4885-41bb-afaa-405837c97bbd
# ╠═╡ show_logs = false
crepls_cis = confint.(floc_interval, crepls)

# ╔═╡ e899651f-143e-4af3-a59b-6bc1c64555b1
plot!(replication_plot, zs_locs, crepls_cis, fillcolor=:darkorange)

# ╔═╡ 9483012a-3701-4e4d-bae6-0210fbabcd70
ci_dataframe = DataFrame(
	z = zs_locs,
	point_estimate = crepls_Ĝ,
	lower_ci = getproperty.(crepls_cis, :lower),
	upper_ci = getproperty.(crepls_cis, :upper)
)

# ╔═╡ c5e6e4f4-9711-4c4b-a47f-caa0db92cb99
CSV.write("confidence_intervals_lnRR.csv", ci_dataframe)

# ╔═╡ 2f5992df-9274-40c2-8a9a-ce63cc340404
md"""### Replication with increasing sample size"""

# ╔═╡ e35b8bb0-9aed-4a58-9375-66fc46ec2044
multipliers = 0.9:0.1:10 # sample size multipliers

# ╔═╡ 5569ac56-6a47-41cf-b7f3-b1e6bd78a92b
repls_3_3 = ConditionalReplicationProbability.(StandardNormalSample(3.3), 
													multipliers)

# ╔═╡ 99fd54b4-4433-49ac-b6e3-fc753a5e0f33
repls_3_3_Ĝ = repls_3_3.(Ĝ)

# ╔═╡ 7f823958-d922-4e61-8524-08b8cb3ba9dc
# ╠═╡ show_logs = false
repls_3_3_cis = confint.(floc_interval, repls_3_3)

# ╔═╡ 47bd9224-f94e-4c21-ad6f-23961357cf15
repls_2_6 = ConditionalReplicationProbability.(StandardNormalSample(2.6), 
													multipliers)

# ╔═╡ ed0909e2-c211-45d8-8272-5b88eaeedb99
repls_2_6_Ĝ = repls_2_6.(Ĝ)

# ╔═╡ 67002ce1-4eed-4773-9b70-55aba897916c
# ╠═╡ show_logs = false
repls_2_6_cis = confint.(floc_interval, repls_2_6)

# ╔═╡ addca770-be18-42bc-a637-b883fbf7c8be
repls_2_0 = ConditionalReplicationProbability.(StandardNormalSample(2.0), 
												multipliers)

# ╔═╡ c1f1f7a3-c293-4398-83a3-6fee8cdc13e0
repls_2_0_Ĝ = repls_2_0.(Ĝ)

# ╔═╡ 7f3e2e92-504c-4cab-9b5b-051ebae41920
# ╠═╡ show_logs = false
repls_2_0_cis = confint.(floc_interval, repls_2_0)

# ╔═╡ 11625fdc-8ee2-499f-94f8-de98eef40880
begin
plot(multipliers, repls_3_3_cis,
	thickness_scaling = 1.4,
	legend=:outertop,
	linewidth = 1.2,
	ylim = (0, 1.19),
    frame = :box,
	label = "z=3.3",
	xlabel = "sample size multiplier",
	ylabel = "Replication probability"
)
plot!(multipliers, repls_3_3_Ĝ, color=:black, label="")
plot!(multipliers, repls_2_6_cis, 
	color=:darkorange,
	label = "z=2.6"
)
plot!(multipliers, repls_2_6_Ĝ, color=:black, label="")
plot!(multipliers, repls_2_0_cis, 
	color=:purple,
	label = "z=2.0"
)
plot!(multipliers, repls_2_0_Ĝ, color=:black, label="")	
end

# ╔═╡ 1073a98a-6e8e-47d2-a352-6d8a59eb1a80
ci_multiplier_dataframe = DataFrame(
	multiplier = multipliers,
	point_estimate_2_0 = repls_2_0_Ĝ,
	lower_ci_2_0 = getproperty.(repls_2_0_cis, :lower),
	upper_2_0 = getproperty.(repls_2_0_cis, :upper),
 	point_estimate_2_6 = repls_2_6_Ĝ,
	lower_ci_2_6 = getproperty.(repls_2_6_cis, :lower),
	upper_2_6 = getproperty.(repls_2_6_cis, :upper),
	point_estimate_3_3 = repls_3_3_Ĝ,
	lower_ci_3_3 = getproperty.(repls_3_3_cis, :lower),
	upper_3_3 = getproperty.(repls_3_3_cis, :upper)
)

# ╔═╡ 27c9e1c7-e53a-46bc-9655-a4637e6bbd69
CSV.write("confidence_intervals_sample_size_multiplier_lnRR.csv", ci_multiplier_dataframe)
