module MetoceanTools
using PyPlot

export tsParm, tsBurst, waveSpec

type dirnSpec
 isGoingTo::Bool      # tells whether direction is going to (true) or coming from (false)
 isClockwise::Bool    # tells whether direction rotate c/w with increase value (true) or roates cc/w with increasing value (false)
 refDirn::Float64   # Gives some reference direction to which a directional parameter refers
 function dirnSpec()
   return new()
 end
end

"""
 Time series type for basic parameterised metocean data 
"""
type tsParm
 sDate::Array{DateTime,1}       # Each row is another time corresponding to rows in tsData
 Data::Array{Float64,2}         # Columns are different parameters, rows are times
 iName::Dict                    # Lookup column index by Name iName["Hs"] returns column index with Hs 
 Name::Array{AbstractString,1}  # Names of parameters in each column
 Meta::Dict                     # Arbitrary storage of meta-data
 Units::Array{AbstractString,1} # Units of parameters
 isDirn::Array{Bool,1}          # for Each column gives whether this parameter is directional (e.g. [0-360])
 isVector::Array{Bool,1}    	# for Each column gives whether this parameter is a complex vector 
 dirnSpec::Array{dirnSpec,1}    # for Each column, If isDirn==true or isVector==true then gives direction specification
 function tsParm()
   return new()
 end
end
### Add function to set the iName automatically if empty when setting Name array

"""
 Time series type for burst record data  -  like surface elevations from a wave buoy (or daily market data)
 Unlike parameter data which can store multiple parameters in one record, tsBurst can store only one parameter
"""
type tsBurst
 sDate::Array{DateTime,1}
 sTime::Array{Float64,2}
 Data::Array{Float64,2}
 function tsBurst()
   return new()
 end
end

"""
 Basic wave spectrum records data which can contain 1D or 2D spectra 
"""
type waveSpec
 sDate::DateTime
 f::Array{Float64}
 df::Array{Float64}
 th::Array{Float64}
 dth::Array{Float64}
 S::Array{Float64,2}
 function waveSpec()
   return new()
 end
end



# dlp includes:
#  dlpRead for reading in *.dlp files
include("dlp.jl")

#  tsPlot includes plotting routines for plotting tsParm data series
#    tsQuickPlot - plots time series of all data in tsParm data series as stacked plot
include("tsPlot.jl")

# Given an array will make a count of unique values
include("countUniqueValues.jl")

#   findGaps for finding gaps in data and duration of good data
include("findGaps.jl")

#   showSampling for displaying and getting sampling within time series data
include("showSampling.jl")

# Provides basic zero-crossing analysis data types and methods
include("tsZeroCross.jl")


end # module
