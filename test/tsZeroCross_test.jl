########################################################################################
# Run internal test
########################################################################################
function tsZeroCross_test()
  # Make some random waves and run tsZeroCross
  f=1./[2;4; 8; 10; 15; 20]
  a= 0.5 * [1; 2; 3; 6; 2; 1]
  p=[0.3 2.3 4.4 5.6 2.3 3.3] 
  t=[xi for xi=0:0.1:110 ]
  z=0*t
  for i=1:size(a,1)
  z.=z.+a[i].*sin.(2.*pi.*f[i].*t+p[i])
  end
  z=z-mean(z)
  oStats=MetoceanTools.tsCalcStats(z)
  oDis=MetoceanTools.tsCalcZeroCrossDiscrete(z)
  oFull=MetoceanTools.tsCalcZeroCrossFull(t,z)
  println(length(oFull.zcTimes))
  if length(oFull.zcTimes)==24
    return 1==1
  else
    return 1==0
  end
end

