type Parcel
  ID
  Index
  sDate
  Duration
  function Parcel()
    return new()
  end
end

"""
   Find gaps in time series (tsParm) structure and return duration of good data
     as well as an index into parcels of data which have contigously good data.

   Good data have values other than NaN.  Where there is a gap in the data 
     larger than in.days4gap, a new parcel of data will be indicated.
     
   Any data which is NaN will be considered to form part of a gap in the time
     series such that where there are contiguous NaN's for a duration larger
     than days4gap will be marked as two separate parcels

 INPUT
  tsParm structure    -  from MetoceanTools package 
  		      -  requires tsParm.sDate[1:nsDate] to be filled
		      -  requires tsParm.Data[1:nsDate,:] to be filled
  iDataColumn         -  column of tsParm.Data to use for data to be checked for gaps
  days4gap[1]         -  duration in days which is to be regarded as a gap in
                           the data

 OUTPUT:
   Parcel definitions as Parcel type
     ID 		- either 0 for a gap parcel or integer sequence number of parcel
     sDate		- start and end date of each parcel
     Index		- start and end index of each parcel where index is into tsParm.sDate
     Duration           - duration [dyas] of each parcel
   iParcel[1:nsDate]   -  either 0 for a gap larger than days4gap or a sequence number
                           giving the parcel number
   goodDurationDays    - the effective duration in days of the complete time series 
                           (sum of the durations of each parcels)

 Created by Jason McConochie
 Revision 1 26Dec2016 by Jason McConochie
"""
function findGaps(in::tsParm,iDataColumn::Int64,days4gap::Float64)

   # A. Find the gaps greater than days4gap
   iParcel=zeros(Int64,size(in.sDate,1))
   ms2days=1/(1000 * 3600 * 24)
   inGap=false
   tParcel=1
   iSt=1
   iEd=1
   for i=1:length(in.sDate)
     isBad=isnan(in.Data[i,iDataColumn])
     if isBad & !inGap
       iSt=i
       inGap=true
     end
     if !isBad
       iEd=i-1
       dt=(Dates.value(in.sDate[iEd+1])-Dates.value(in.sDate[iSt]))*ms2days
       if inGap 
         if 1.*dt>days4gap
           iParcel[iSt:iEd]=0
	   if iSt!=1
             tParcel+=1
	   end
	 else
           iParcel[iSt:iEd]=tParcel
	 end
       end
       iParcel[i]=tParcel
       inGap=false
     end
   end 

   # B. Set duration of all parcels
   # B1. count number of parcels
   k=0
   lastParcel=-1
   for i=1:length(iParcel)-1
     if iParcel[i]!=lastParcel
        k=k+1
	lastParcel=iParcel[i]
     end
   end
   nParcels=k
   # B2. set start and end dates of parcels and parcel number associated
   p=Parcel()
   p.ID=Array{Int64,1}(nParcels)
   p.sDate=Array{DateTime,2}(nParcels,2)
   p.Index=Array{Int64,2}(nParcels,2)
   p.Duration=Array{Float64,1}(nParcels)
   lastParcel=-1
   k=0
   for i=1:length(iParcel)-1
     if iParcel[i]!=lastParcel
       k=k+1
       p.sDate[k,1]=in.sDate[i]
       p.Index[k,1]=i
       p.ID[k]=iParcel[i]
       lastParcel=iParcel[i]
     end
   end
   for i=1:nParcels-1
     p.sDate[i,2]=p.sDate[i+1,1]
     p.Index[i,2]=p.Index[i+1,1]
   end
   p.sDate[nParcels,2]=in.sDate[end]
   p.Index[nParcels,2]=length(in.sDate)
   
   goodDurationDays=0.
   for i=1:nParcels
     p.Duration[i]=ms2days*(Dates.value(p.sDate[i,2])-Dates.value(p.sDate[i,1])) 
     if p.ID!=0
       goodDurationDays+=p.Duration[i]
     end
     #println("$(i) : $(p.ID[i]) : $(p.Index[i,1]),$(p.Index[i,2]) : $(p.sDate[i,1]),$(p.sDate[i,2]) : $(p.Duration[i])")
   end

   return p,goodDurationDays,iParcel

end



"""
   Function test_findGaps() to test findGaps function
"""
function test_findGaps()
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
      DateTime(1900,1,10),
      ]
   in.Data=zeros(10,1)
   in.Data[1:10,1]=[1,1,NaN,NaN,1,1,1,1,NaN,NaN]
   days4gap=1.5
   p,goodDurationDays,iParcel=findGaps(in,1,days4gap)

end


