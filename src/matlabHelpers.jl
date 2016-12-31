
function matlab_sdate2datetime(sDate)::DateTime
  return Dates.epochms2datetime(round((sDate-1)*24*3600*1000))
end



function interp1(x1::Float64,y1::Float64,x2::Float64,y2::Float64,x_new::Float64)::Float64
  Slope = (y2 - y1) ./ (x2 - x1)
  Intercept = y2 - Slope .* x2  
  y_new=x_new*Slope+Intercept
  return y_new
end     
function interp1(x::Array{Float64,1},y::Array{Float64,1},x_new::Float64)
  for i = 2:length(x)
    if x_new<x[1]
      # Back-strapolate
      y_new=interp1(x[1],y[1],x[2],y[2],x_new)
      return y_new
    end
    if x_new>x[end]
      # Ex-strapolate
      y_new=interp1(x[end-1],y[end-1],x[end],y[end],x_new)
      return y_new
    end
    if x_new<=x[i]
      y_new=interp1(x[i-1],y[i-1],x[i],y[i],x_new)
      return y_new
    end
  end
end
function interp1(x::Array{Float64,1},y::Array{Float64,1},x_new::Array{Float64,1})
  y_new=similar(x_new)
  for i in eachindex(x_new)
    y_new[i]=interp1(x,y,x_new[i])
  end
  return y_new
end
