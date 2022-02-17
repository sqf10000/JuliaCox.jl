module JuliaCox

using Survival
using CSV
using DataFrames
using DataFramesMeta
using StatsBase

function docox(genename,mymatrix, mydf_event,qcut,n,mylabel)
    n1 = sum(mymatrix)
    n2 = length(mymatrix)-n1
    try
        all = DataFrame(coeftable(coxph(mymatrix, mydf_event)))
        replace!(all[!, :Name], "x1" => join([genename, mylabel, string(n),string(qcut),string(n1),string(n2)], "_"))
        return all
    catch
        return DataFrame("Name" => join([genename, mylabel, string(n),string(qcut),string(n1),string(n2)], "_"),"Estimate" => 0,"Std.Error"=>0,"z value" =>0,"Pr(>|z|)"=>0)
    end
    
end

function genecox(mydf_df,pos_df,neg_df, genename; quant_range = 0.2:0.02:0.81)
    d = DataFrame()
    for n in quant_range
        qcut = quantile(mydf_df[:, genename], n)
        ###all#######
        mydf_mymatrix = hcat(ifelse.(mydf_df[:, genename] .> qcut, 1, 0))
        mydf_re = docox(genename,mydf_mymatrix, mydf_df.event,qcut,n,"all")
        append!(d, mydf_re)
        ###positive#######
        pos_mymatrix = hcat(ifelse.(pos_df[:, genename] .> qcut, 1, 0))
        pos_re = docox(genename,pos_mymatrix, pos_df.event,qcut,n,"pos")
        append!(d, pos_re)
        ###negative######
        neg_mymatrix = hcat(ifelse.(neg_df[:, genename] .> qcut, 1, 0))
        neg_re = docox(genename,neg_mymatrix, neg_df.event,qcut,n,"neg")
        append!(d, neg_re)
    end
    return d
end

function dopipeline(mydf, factorcol, positivevaule, negativevalue,inexclude,genelist)
    myresult = DataFrame()
    ####group data ######    
    mydf.event = EventTime.(mydf.survivalMonth, mydf.survivalEvent .== 1.0)
    pos_df = @subset(mydf, $factorcol .== positivevaule)
    neg_df = @subset(mydf, $factorcol .== negativevalue)
    ####run ######
    if inexclude =="y"
        for genename in genelist
            append!(myresult, genecox(mydf,pos_df,neg_df, genename))
        end
    elseif inexclude =="n"
        for genename in names(mydf)
            if !(genename in genelist) && (genename !="Column1") && (genename !="event") && (genename !=factorcol)
                #println(genename)  
                append!(myresult, genecox(mydf,pos_df,neg_df, genename ))
            end
        end
    else
        println("inexclude value must be y or n!")
    end
    return myresult
end


function dopipeline_file(myfile, factorcol, positivevaule, negativevalue,inexclude, genelist)
    mydf = CSV.read(myfile, DataFrame,header=1,delim=",",)
    df = dopipeline(mydf, factorcol, positivevaule, negativevalue,inexclude, genelist)
    CSV.write(join([factorcol, "coxph.csv"], "_"), df, delim = '\t')
    return join([factorcol, "done"], " ")
end


function julia_main()::Cint
    # do something based on ARGS?
    #@show ARGS
    myfile = ARGS[1]
    factorcol = ARGS[2]
    positivevaule = ARGS[3]
    negativevalue = ARGS[4]
    inexclude = ARGS[5]
    genelist = ARGS[6:end]
    re = (dopipeline_file(myfile, factorcol, positivevaule, negativevalue,inexclude,genelist))
    println(re)
    return 1  # if things finished successfully
  end

end