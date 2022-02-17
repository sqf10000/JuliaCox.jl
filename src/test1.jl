#import JuliaCox
#JuliaCox.dopipeline_file("/GCI/nacoo/julia_test3.csv","chr6_p_gain(0.5)","with_chr6_p_gain","without_chr6_p_gain","n",["survivalMonth","age","survivalEvent","gene_level"])

function main()
    # do something based on ARGS?
    #@show ARGS
    myfile = ARGS[1]
    factorcol = ARGS[2]
    positivevaule = ARGS[3]
    negativevalue = ARGS[4]
    inexclude = ARGS[5]
    genelist = ARGS[6:end]
    #re = (dopipeline_file(myfile, factorcol, positivevaule, negativevalue,inexclude,genelist))
    println(ARGS[1])
    return ARGS  # if things finished successfully
  end
  main()