# #__precompile__()
"""
# tsZeroCross Module

 Zero crossing analysis routines including many outputs: heights, periods, peaks, troughs, etc

---

## Functions

    o=tsCalcStats(z)
    o=tsCalcZeroCrossDiscrete(z)
    o=tsCalcZeroCrossFull(t,z)

## Types

    tsStats -  Type containing basic statistics of the input z-signal
    zCross - Type containing zero crossing minima, maxima and height data
    zCrossDiscrete - Type containing zero crossing low level data
    zCrossUpDown - Type containing height and period data and statistics
    ZeroCrossFull - Type containing full zero crossing data 

## Description

 An OM_JPL Function.

 Zero crossing analysis routine including many outputs: heights, periods, peaks, troughs, etc

 Determines zero crossing parameters from the input time series. Both up crossing
  and downcrossing is peformed and reported.

 If the start and end of the time series is not at zero then these are not included in the
  statistics.  Only full zero-crossing wave cycles are used and reported.

 Values of z which are Inf or NaN are treated as missing values. If a zero-crossing occurs between
  these times linear interpolation is used to find the crossing point.

## Examples

```jldoctest
julia> f=1./[2;4; 8; 10; 15; 20]
julia> a= 0.5 * [1; 2; 3; 6; 2; 1]
julia> p=rand(6)*2*pi
julia> t=[xi for xi=0:0.1:110 ]
julia> z=0*t
julia> for i=1:size(a,1)
julia> z.=z.+a[i].*sin.(2.*pi.*f[i].*t+p[i])
julia> end
julia> z=z-mean(z)
julia> oStats=tsCalcStats(z)
julia> oDis=tsCalcZeroCrossDiscrete(z)
julia> oFull=tsCalcZeroCrossFull(t,z)
```

## History

 Created by Jason McConochie
   Revision 1, 20Dec2016 , Jason McConochie
      based upon Revision 3, of matlab version
"""
module tsZeroCross

using PyPlot
########################################################################################
# Functions and types for basic time series data statistics
export tsCalcStats, tsStats
"""
# tsStats
Type containing basic statistics of the input z-signal
  mean median max imax min imin std rms var
"""
type tsStats
   mean::Float64
   median::Float64
   max::Float64
   imax::Float64
   min::Float64
   imin::Float64
   std::Float64
   rms::Float64
   var::Float64
   function tsStats()
     return new()
   end
end

########################################################################################
# Functions and types for discrete zero crossing analysis using z only, no t
export tsCalcZeroCrossDiscrete, zCrossDiscrete, zCross
# Type to contain more detail but usually less relevant information
#  this is made by the zerocross_discrete function
"""
# zCross
Type containing zero crossing minima, maxima and height data
"""
type zCross
   zmax::Array{Float64,1}
   zmin::Array{Float64,1}
   izmax::Array{Int64,1}
   izmin::Array{Int64,1}
   height::Array{Float64,1}
   function zCross()
     return new()
   end
end
"""
# zCrossDiscrete

Type containing zero crossing low level data
     .izc       indicies of the points surrounding all zero crossings selected
     .zctype      value indicating the type of crossing
     .zctypemeta  ' 1 is an upcrossing, -1 is a downcrossing'
     .ilcrest   indicies of all local crests identified
     .iltrough  indicies of all local troughs identified
     .ipslope   boolean indicating postively sloping z
     .i0slope   boolean indicating sloping z
     .inslope   boolean indicating sloping z
     .uc 	contains zCross structure foe up-crossings
     .dz   	contains zCross structure foe down-crossings
"""
type zCrossDiscrete
   # low-level zero crossing data
   izc::Array{Int64,2}
   zctype::Array{Int64,1}
   zctypemeta::AbstractString
   ilcrest::Array{Int64,1}
   iltrough::Array{Int64,1}
   # slopes
   ipslope::Array{Bool,1}
   i0slope::Array{Bool,1}
   inslope::Array{Bool,1}
   # crossing data
   uc::zCross
   dc::zCross
   function zCrossDiscrete()
     t=new()
     t.uc=zCross()
     t.dc=zCross()
     return t
   end
end

########################################################################################
# Functions and types for full zero crossing analysis using t,z
export tsCalcZeroCrossFull, ZeroCrossFull
"""
# zCrossUpDown

Type containing height and period data and statistics

       .H         vector of individual wave heights
       .T         vector of individual wave periods

       .Hmax      maximum individual wave height
       .Hm        mean wave height
       .H1on10        mean of the highest wave exceeding a 1/10 probability of exceedence
       .H1on3     mean of the highest wave exceeding a 1/3 probability of exceedence
       .H1on2     mean of the highest wave exceeding a 1/2 probability of exceedence

       .THmax     period of Hmax
       .Tm        mean wave period
       .T1on10    mean wave period of all waves with heights exceeding a 1/10 probability of exceedence
       .T1on3     mean wave period of all waves with heights exceeding a 1/3 probability of exceedence
       .T1on2     mean wave period of all waves with heights exceeding a 1/2 probability of exceedence

       .zcTimes   vector of times of zero crossings (either up or down)

"""
type zCrossUpDown
   H::Array{Float64,1}  
   T::Array{Float64,1}
   # height statistics
   Hmax::Float64
   Hm::Float64
   H1on10::Float64
   H1on3::Float64
   H1on2::Float64
   # period statistics
   THmax::Float64
   Tm::Float64
   T1on10::Float64
   T1on3::Float64
   T1on2::Float64
   # time of zero crossings
   zcTimes::Array{Float64,1}  
   function zCrossUpDown()
     return new()
   end
end
"""
# ZeroCrossFull
 Type containing full zero crossing data 
"""
type ZeroCrossFull
   # time of zero crossings
   zcTimes::Array{Float64,1}  
   upCross::zCrossUpDown
   downCross::zCrossUpDown
   zCrossDiscrete::zCrossDiscrete
   Hsigma::Float64
   function ZeroCrossFull()
     t=new()
     t.upCross=zCrossUpDown()
     t.downCross=zCrossUpDown()
     t.zCrossDiscrete=zCrossDiscrete()
     return t
   end
end


########################################################################################
# Run internal test
########################################################################################
function test()
    # Make some random waves and run tsZeroCross
    f=1./[2;4; 8; 10; 15; 20]
    a= 0.5 * [1; 2; 3; 6; 2; 1]
    p=rand(6)*2*pi
    t=[xi for xi=0:0.1:110 ]
    z=0*t
    for i=1:size(a,1)
        z.=z.+a[i].*sin.(2.*pi.*f[i].*t+p[i])
    end
    z=z-mean(z)
    oStats=tsCalcStats(z)
    oDis=tsCalcZeroCrossDiscrete(z) 
    oFull=tsCalcZeroCrossFull(t,z) 
    o=oFull
    return o,z,t
end

########################################################################################
# Basic Statistics - tsCalcStats
########################################################################################
""" 
# tsCalcStats

Calculate basic statistics min, max, std, var, mean, median 

"""
function tsCalcStats(z::Array{Float64,1})::tsStats
  # 0. Make new output structure
  o=tsStats()
  # A. Find typical statistics
  o.mean=mean(z)
  o.median=median(z)
  o.max=maximum(z)
  o.imax=indmax(z)
  o.min=minimum(z)
  o.imin=indmin(z)
  o.std=std(z)
  a=0
  for i=1:length(z)
    a=a+z[i].^2
  end
  o.rms=(a/length(z))^0.5
  o.var=var(z)
  return o
end

########################################################################################
# Discrete Zero Crossing - tsZeroCrossDiscrete
########################################################################################
"""

# tsCalcZeroCrossDiscrete

 Function for discrete time series analysis

## INPUT

  z - Vector of time series values

"""
function tsCalcZeroCrossDiscrete(z::Array{Float64,1})::zCrossDiscrete

  # 0. Input handling 
  o=zCrossDiscrete()
  
  # A. Return empty data if there is only none or point or all zeros
  nz=size(z,1)
  allZero=true
  for i=1:size(z,1)
    if z[i]!=0
      allZero=false
      break
    end
  end
  if allZero
    return o
  end
  
  # C. Find zero-crossing indicies
  #sz=convert(Array{Int64,1},sign(z)) # -1 -1 0 0 1 1
  sz=sign(z) # -1 -1 0 0 1 1
  sz[1]==0 ? sz[1]=sz[2] : 0
  # ..Find patterns of -1 n0 -1 or 1 n0 1 in sz - remove these from
  foundzero=false
  izero=0
  ncross=0
  for i=2:nz
    if sz[i]==0 && !foundzero
      foundzero=true
      izero=i
    elseif (sz[i]!=0) && foundzero 
      sz[izero:(i-1)]=sz[i]
      foundzero=false
    end
    abs(sz[i]-sz[i-1])>0 ? ncross+=1 : 0
  end

  icross::Array{Int64,1}=zeros(Int64,ncross)
  kcross=0
  for i=2:nz
    if abs(sz[i]-sz[i-1])>0 
      kcross+=1
      icross[kcross]=i-1 
    end
  end

  # D. Plotting check
  #println("Ncrossings=$(ncross)")
  #PyPlot.plot(1:1:length(z),z,color="black")
  #hold(true)
  #PyPlot.plot(icross,icross.*0,"rx")
  #PyPlot.plot([1;length(z)],[0;0])
  	 
  # E. Put into icross array of indicies which bound the zero-crossing
  #	 start1,end1
  #	 start2,end2 etc
  o.izc=zeros(Int64,(ncross,2))
  for i=1:ncross
     o.izc[i,1]=icross[i]
     o.izc[i,2]=icross[i]+1
  end

  # F1. Check if the first point is zero-touching - and include
  if z[1]==0
    o.izc=[1 1;o.izc];tcross1=convert(Int64,sign(z[2])) 
  end
  # F2. Check if last point is zero touching
  if z[end]==0 
    o.izc[end,:]=[length(z) length(z)];tcrossN=-1*convert(Int64,sign(z[end-1]))
  end
    
  # G. Got all zero-crossing indicies now mark which is upcrossing and which is
  #  down crossing
  # 0  - touching zero
  # 1 - up-crossing
  # -1	- down-crossing

  o.zctype=Array(Int64,size(o.izc,1))
  for i=1:size(o.izc,1)
    o.zctype[i]=-1*sign(z[o.izc[i,1]])
  end
    
  # H1. Assign zero-touches to up or down crossing
  z[1]==0 ? o.zctype[1]=tcross1 : 0
  z[end]==0 ? o.zctype[end]=tcrossN : 0
  # H2. Check if we are still okay 
  if !all(abs(o.zctype[2:end]-o.zctype[1:end-1]).==2)
   println("**** Serious problem with zero crosssing routine")
   return
  end
    
  o.zctypemeta=" 1 is an upcrossing, -1 is a downcrossing"

  # I1. Find crests and troughs
  ra1::Array{Bool,1}=falses(nz)
  ra2::Array{Bool,1}=falses(nz)

  # I2.1 Find all 121 style crests
  for i=1:nz-2
    ra1[i]=(z[i]<z[i+1]) & (z[i+1]>z[i+2])
  end
  # I2.2 Find all 1221 style crests
  for i=1:nz-3
    ra2[i]=(z[i]<z[i+1]) & (z[i+1]==z[i+2]) & (z[i+2]>z[i+3])
  end
  o.ilcrest=find(ra1 | ra2)+1

  # I3.1 Find all 212 style troughs
  for i=1:nz-2
    ra1[i]=(z[i]>z[i+1]) & (z[i+1]<z[i+2])
  end
  # I3.2 Find all 2112 style crests
  for i=1:nz-3
    ra2[i]=(z[i]>z[i+1]) & (z[i+1]==z[i+2]) & (z[i+2]<z[i+3])
  end
  o.iltrough=find(ra1 | ra2)+1

  # J. Categorise slope
  o.ipslope=falses(nz)
  o.i0slope=falses(nz)
  o.inslope=falses(nz)
  for i=1:nz-2
    # .. find all points with neutral gradient
    o.ipslope[i]=z[i] < z[i+1]
    # .. find all points with neutral gradient
    o.i0slope[i]=z[i] == z[i+1]
    # .. find all points with negative gradient
    o.inslope[i]=z[i] > z[i+1]
  end

  # K. Find all zero-crossing heights
  #    construct array of waves
  o.uc=zCross()
  o.dc=zCross()

  # K1. upcrossing heights
  #    ..from first up cross to last upcross
  # .. first upcross
  iuc=find(o.zctype.==1)  #upcrossings
  nst=size(iuc,1)-1
  o.uc.zmax=zeros(Float64,nst)
  o.uc.zmin=zeros(Float64,nst)
  o.uc.izmax=zeros(Int64,nst)
  o.uc.izmin=zeros(Int64,nst)
  for i=1:nst
    st=o.izc[iuc[i],2]   #first point after upcross
    ed=o.izc[iuc[i+1],1] #last point in upcross wave
    mz=z[st:ed]
    o.uc.zmax[i]=maximum(mz)
    imax=indmax(mz)
    o.uc.zmin[i]=minimum(mz)
    imin=indmin(mz)
    o.uc.izmax[i]=st+imax-1
    o.uc.izmin[i]=st+imin-1
  end
  o.uc.height=o.uc.zmax-o.uc.zmin
    
  # K2. downcrossing heights
  #   ..from first up cross to last upcross
  # .. first upcross
  iuc=find(o.zctype.==-1)  #down-crossings
  nst=size(iuc,1)-1
  o.dc.zmax=zeros(Float64,nst)
  o.dc.zmin=zeros(Float64,nst)
  o.dc.izmax=zeros(Int64,nst)
  o.dc.izmin=zeros(Int64,nst)
  for i=1:nst
    st=o.izc[iuc[i],2]        #first point after upcross
    ed=o.izc[iuc[i+1],1]      #last point in upcross wave
    mz=z[st:ed]
    o.dc.zmax[i]=maximum(mz)
    imax=indmax(mz)
    o.dc.zmin[i]=minimum(mz)
    imin=indmin(mz)
    o.dc.izmax[i]=st+imax-1
    o.dc.izmin[i]=st+imin-1
  end
  o.dc.height=o.dc.zmax-o.dc.zmin
    
  #plot(z)
  #hold("true")
  #plot(o.izc[:,1],o.izc[:,1]*0,"rx")

  #println("Done $(o)") 
    
  return o  
  
end # end function dzca



########################################################################################
# Full Zero Crossing - tsZeroCross
########################################################################################
"""

# tsCalcZeroCrossFull

 Function for full zero crossing analysis of time series 

## INPUT

  t - Vector of times as Float64 
  z - Vector of time series values

"""
function tsCalcZeroCrossFull(t::Array{Float64,1},z::Array{Float64,1})::ZeroCrossFull
 
     # 0. Do some checking
     t=t[:]
     z=z[:]
     if size(t,1)!=size(z,1)
         return NaN
         #error('tsZeroCross: length of t (%d) does not match z (%d)\n',length(t),length(z));
     end
     # .. check for unique and monotonically increasing values of t
     bad=any(diff(t).<=0.)
     if bad
         return NaN
         # error('tsZeroCross: t is not monotonically increasing\n');
     end
     # .. check for NaN's/Inf's
     bad1=any(isnan(z))
     bad2=any(isinf(z))
     if bad1 | bad2 
         println("tsZeroCross: NaNs or Infs detected in z, removing them and treating as missing values")
         m=isnan(z) | isinf(z)
         ind=1:1:size(m,1)
         deleteat!(z,ind(m))
         deleteat!(t,ind(m))
     end
     
     # A. Perform discrete part of time series analysis
     # A1. Make new output strcuture
     om=ZeroCrossFull()
     # A2. Run the discrete zero crossing
     # .. this only requires the z component
     om.zCrossDiscrete=tsCalcZeroCrossDiscrete(z)
     # B. Find zero crossing times and up and down crossing periods
     if size(om.zCrossDiscrete.izc,1)>1
         # B1. Find zero crossing times
         x1=z[om.zCrossDiscrete.izc[:,1]]
         x2=z[om.zCrossDiscrete.izc[:,2]]
         y1=t[om.zCrossDiscrete.izc[:,1]]
         y2=t[om.zCrossDiscrete.izc[:,2]]
         # ..find slope of known data points
         Slope = (y2 - y1) ./ (x2 - x1)
         # ..find intercept
         Intercept = y2 - Slope .* x2
         inan=isnan(Intercept)
         Intercept[inan]=0
         Intercept=inan.*y1+Intercept
         om.zcTimes=Intercept
         
         # B2. Upcrossing Periods
         ic=find(om.zCrossDiscrete.zctype.==1)  # upcrossings
         if !isempty(ic) # must have at least one upcrossing
             om.upCross.zcTimes=om.zcTimes[ic]
             om.upCross.H=om.zCrossDiscrete.uc.height
         end
         if isdefined(om.upCross,:zcTimes)
             om.upCross.T=diff(om.upCross.zcTimes)
         end
         
         # B3. Downcrossing Periods
         ic=find(om.zCrossDiscrete.zctype.==-1)  # downcrossings
         if !isempty(ic) # must have at least one downcrossing
             om.downCross.zcTimes=om.zcTimes[ic]
             om.downCross.H=om.zCrossDiscrete.dc.height
         end
         if isdefined(om.downCross,:zcTimes)
             om.downCross.T=diff(om.downCross.zcTimes)
         end
     end
     
     # C. Find periods statistics
     # C1. Upcrossing period statistics
     if !isdefined(om,:upCross)
         om.upCross.Tm=mean(om.upCross.T)
         isp=sortperm(om.upCross.H)
         N=size(isp,1)
         ist=ceil(N-N/10+0.5)
         om.upCross.T1on10=mean(om.upCross.T[ist:N])
         ist=ceil(N-N/3+0.5)
         om.upCross.T1on3=mean(om.upCross.T[ist:N])
         ist=ceil(N-N/2+0.5)
         om.upCross.T1on2=mean(om.upCross.T[ist:N])
     end
     # C2. Downcrossing period statistics
     if !isdefined(om,:downCross)
         om.downCross.Tm=mean(om.downCross.T)
         isp=sortperm(om.downCross.H)
         N=size(isp,1)
         ist=ceil(N-N/10+0.5)
         om.downCross.T1on10=mean(om.downCross.T[ist:N])
         ist=ceil(N-N/3+0.5)
         om.downCross.T1on3=mean(om.downCross.T[ist:N])
         ist=ceil(N-N/2+0.5)
         om.downCross.T1on2=mean(om.downCross.T[ist:N])
     end
     
     # D. Find height statistics
     # D1. UpCrossing Height statistics
     if !isdefined(om,:upCross)
         om.upCross.Hm=mean(om.upCross.H)
         sh=sort(om.upCross.H)
         N=size(sh,1)
         ist=ceil(N-N/10+0.5)
         om.upCross.H1on10=mean(sh[ist:N])
         ist=ceil(N-N/3+0.5)
         om.upCross.H1on3=mean(sh[ist:N])
         ist=ceil(N-N/2+0.5)
         om.upCross.H1on2=mean(sh[ist:N])
     end
     # D2. DownCrossing Height statistics
     if !isdefined(om,:downCross)
         om.downCross.Hm=mean(om.downCross.H)
         sh=sort(om.downCross.H)
         N=size(sh,1)
         ist=ceil(N-N/10+0.5)
         om.downCross.H1on10=mean(sh[ist:N])
         ist=ceil(N-N/3+0.5)
         om.downCross.H1on3=mean(sh[ist:N])
         ist=ceil(N-N/2+0.5)
         om.downCross.H1on2=mean(sh[ist:N])
     end
     
     # E. Find data for the maximum wave
     # E1. Upcrossing
     if !isdefined(om,:upCross)
         om.upCross.Hmax=max(om.upCross.H)
         om.upCross.iHmax=indmax(om.upCross.H)
         om.upCross.THmax=om.upCross.T[om.upCross.iHmax]
     end
     # E2. Downcrossing
     if !isdefined(om,:downCross)
         om.downCross.Hmax=max(om.downCross.H)
         om.downCross.iHmax=indmax(om.downCross.H)
         om.downCross.THmax=om.downCross.T[om.downCross.iHmax]
     end
     
     # F. Calculate significant wave height
     om.Hsigma=4*sqrt(var(z))
     
     # G. If requested make a plot of all of the information
     #if exist('doplot','var')==1
     #    figure
         #ind=1:1:length(z);
     #    plot(t,z,'k-x');hold on
         #plot(t(dtsa.ZeroUpCrossingIndicies_1st),z(dtsa.ZeroUpCrossingIndicies_1st),'ro');
         #plot(t(dtsa.ZeroDownCrossingIndicies_1st),z(dtsa.ZeroDownCrossingIndicies_1st),'b+');
     #    plot(t(o.dzc.ilcrest),z(o.dzc.ilcrest),'g^');
     #    plot(t(o.dzc.iltrough),z(o.dzc.iltrough),'cv');
         
     #    plot(o.uc.tzc,zeros(size(o.uc.tzc)),'+');
         #h=text(tsa.ZeroUpCrossingTimes,zeros(size(tsa.ZeroUpCrossingTimes)),char(tsa.Periods));
         #set(h,'verticalalignment','bottom','horizontalalignment','left');
     #    h=line(t,zeros(size(t)));
     #    set(h,'color',[0 0 0]);
         
     #end
     return om
     
 end



end # module
