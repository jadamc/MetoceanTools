"""
Function test_showSampling() to test showSampling function
"""
function showSampling_test()
  in=tsParm()
  in.sDate=[
    DateTime(1900,1,1),
    DateTime(1900,1,2),
    DateTime(1900,1,3),
    DateTime(1900,1,4),
    DateTime(1900,1,5),
    DateTime(1900,1,6),
    DateTime(1900,1,7),
    DateTime(1900,1,8),
    DateTime(1900,1,9),
    DateTime(1900,1,11),
  ]
  in.Data=zeros(10,1)
  in.Data[1:10,1]=[1,2,NaN,NaN,5,6,7,8,9,10]
  days4gap=1.5
  MetoceanTools.showSampling(in,1,days4gap)
end

"""
Function showSampling_test1() to test showSampling function
  Uses dlp file as input for a more complex test
"""
function showSampling_test1()
  in=MetoceanTools.dlpRead("AnonymousDLP.dlp")
  days4gap=1.
  MetoceanTools.showSampling(in,1,days4gap)
end
