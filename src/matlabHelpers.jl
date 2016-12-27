
function matlab_sdate2datetime(sDate)::DateTime
  return Dates.epochms2datetime(round((sDate-1)*24*3600*1000))
end
