module MetoceanTools

export ts
"""
 Time series type for types of metocean data 
"""
type ts
 tsDate::DateTime
 tsData::Array{T<:Number,2}
 isDirn::Array{Bool,1}
 isVector::Array{Bool,1}
end




end # module
