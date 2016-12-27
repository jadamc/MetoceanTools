using MetoceanTools
using Base.Test

om=falses(5)

println("dlpRead test\n .. loading")
include("dlpRead_test.jl")
println(" .. running")
dlpRead_test()
om[1]=true
println(" .. done")

println("showSampling test\n .. loading")
include("showSampling_test.jl")
println(" .. running")
showSampling_test()
om[2]=true
println(" .. done")
println(" .. running test 1")
showSampling_test1()
om[3]=true
println(" .. done")

println("dlpRead test\n .. loading")
include("countUniqueValues_test.jl")
println(" .. running")
om[4]=countUniqueValues_test()
if !om[4]
  error("Failed on countUniqueValues")
end
println(" .. done")

println("tsZeroCross test\n .. loading")
include("tsZeroCross_test.jl")
println(" .. running")
om[5]=tsZeroCross_test()
if !om[5]
  error("Failed on tsZeroCross")
end
println(" .. done")

@test 1==1
