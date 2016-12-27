"""
# Gives the number of occurrences (counts) of the vector for each
#  unique value in the vector
"""
function countUniqueValues{T<:Number}(inValues::Array{T,1})
  uValues=unique(inValues)
  uCounts=zeros(Int64,(length(uValues),))
  for j=1:length(inValues)
    for i=1:length(uValues)
      (inValues[j]==uValues[i]) ? uCounts[i]+=1 : 0
    end
  end
  return uCounts,uValues
end
