function countUniqueValues_test()::Bool
  a=[1,1,1,2,2,1]*1.
  (uCounts,uValues)=MetoceanTools.countUniqueValues(a)
  if uCounts[1]==4
    return true
  else
    return false
  end
end
