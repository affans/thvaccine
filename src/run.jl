## main run file for HSV project. 
using Distributed
using Random
using DelimitedFiles
using Distributions
using Base.Filesystem
using JSON 


## multi core. 
addprocs(4; exeflags="--project")
@everywhere using thvaccine

using DataFrames
using CSV


res = map(x -> main(x), 1:5)

for i = 1:5
    dts = res[i]
    insertcols!(dts.prevalence, 1, :sim => i)
    insertcols!(dts.partners, 1, :sim => i)
    insertcols!(dts.episodes, 1, :sim => i)
end

# prevalence
p = vcat([res[i].prevalence for i = 1:5]...)
e = vcat([res[i].episodes for i = 1:5]...)
s = vcat([res[i].partners for i = 1:5]...)

function process_prev(res)
    avg_prev = DataFrame([Int64 for i = 1:5], [Symbol("sim$i") for i = 1:5], 20)
    #insertcols!(avg_prev, 6, :avg => 0)
    for i = 1:5
        avg_prev[!, Symbol("sim$i")] .= res[i].prevalence[:, :Total]
    end
    c = convert(Matrix, avg_prev[:, 1:5])
    m = dropdims(mean(c; dims=2), dims=2) 
    m = round.(m; digits=2)
    avg_prev[!, :avg] = m
    
    
    ## ways of taking the average row-wise
    # df |> @mutate(d=mean(_)) |> DataFrame
    # mean(eachcol(df))
    # mean.(eachrow(df))
    # map(mean, eachrow(df));
end