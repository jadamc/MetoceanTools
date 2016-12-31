
"""
showSampling
 List detailed information on sampling in time series (e.g monthly occurrences, gaps etc)

Syntax

 showSampling(in::tsParm,days4gap::Float64)

Description

 List detailed information on sampling in time series (e.g monthly occurrences, gaps etc)
 The detailed information is useful for including in a report and find gaps.  It also checks for
  duplicate dates in the series.

 If value vector is provided then any NaNs will be treated as gaps.  

 INPUTS

  in::tsParm       	tsParm structure containing at least sDate and Data
                          sDate will be used to define dates
			  A column (iColumn) will be checked for NaNs which are considered missing data
  iColumn[1]            Integer defining column in Data which will be used to assess
                          missing data
  days4gap              Define minimum gaps size 
                          (This is not used for calculating % data return)

 OUTPUTS

   parcels,goodDurationDays,iParcels

   parcels              Structure contain information on Parcels of data separated by the gap size
                             as determined by MetoceanTools.findGaps
   durationGoodDays     Total effective duration [days] the data represent
                          determined by the total duration contained within contiguous blocks of
                          data with no gaps greater than days4gap
   iParcels             Array of length in.sDate containing sequential parcel number or 0 if a gap

Revisions

 Revision 1 26 Dec 2016 Jason McConochie

"""
function showSampling(in::tsParm,iColumn::Int64,days4gap::Float64)
  
  o=STDOUT
  @printf(o,"==========================================================================================\n")
  @printf(o,"Sampling Analysis Output - showSampling\n")
  @printf(o,"  Generated: %s\n",Dates.format(now(),"dd/uuu/yyyy HH:MM:SS"))
  @printf(o,"==========================================================================================\n")
  
  t=in.sDate
  z=in.Data[:,iColumn]
   
  #..check for duplicate dates
      #### Testing tsParm for duplicates, repeated data, should be a function
  usDate=unique(in.sDate)
  dd=length(in.sDate)!=length(usDate)
  if dd>0
     @printf(o,".. there are %d duplicate dates\n",dd)
     #  ADD CODE TO LIST THE UNIQUE DATES
  end
   
  #..get good data
  isGood=!isnan(z)
  tGood=t[isGood]
  zGood=z[isGood]
  if isempty(tGood)
       @printf(o,"..No dates with good data\n")
       @printf(o,"==========================================================================================\n")
       return
  end
  
  ms2days=1/(1000*60*60*24)
  ms2hours=1/(1000*60*60)
  ms2minutes=1/(1000*60)
  ms2seconds=1/(1000)
  
  @printf(o,"Time period covered by good data (i.e. not NaN)\n")
  @printf(o,"  start at %20s\n",Dates.format(tGood[1],"dd/uuu/yyyy HH:MM:SS"))
  @printf(o,"  ends  at %20s\n",Dates.format(tGood[end],"dd/uuu/yyyy HH:MM:SS"))
  tdur=(Dates.value(tGood[end])-Dates.value(tGood[1]))*ms2days
  @printf(o,"Total duration is %g days\n",tdur)
  
  ##### call s=tsSimpleStats(tsParm) and print more information
  @printf(o,"Simple statistics\n")
  @printf(o,"    Min value=%g\n",minimum(zGood))
  @printf(o,"    Mean value=%g\n",mean(zGood))
  @printf(o,"    Max value=%g\n",maximum(zGood))
   
  #..calculate the number of values in each year and month
  yy=Dates.year(tGood)
  mm=Dates.month(tGood)
  HH=Dates.hour(tGood)
  uyy=unique(yy)
  
  @printf(o,"Number of samples in each year\n")
  out=""
  for i=1:length(uyy)
     out=*(out,@sprintf("%4d: %-8d ",uyy[i],sum(uyy[i].==yy)))
     if i/5==round(i/5)
         @printf(o,"   %s\n",out)
         out=""
     end
  end
  if length(uyy)/5!=round(length(uyy)/5)
     @printf(o,"   %s\n",out)
  end
   
  @printf(o,"Number of samples in each month\n")
  out=""
  for i=1:12
     out=*(out,@sprintf("%3d: %-8d ",i,sum(i.==mm)))
     if i/6==round(i/6)
         @printf(o,"   %s\n",out)
         out=""
     end
  end
  @printf(o,"   %s\n",out)
   
  @printf(o,"Number of samples in each hour of the day\n")
  out=""
  for i=0:23
    out=*(out,@sprintf("%3d: %-8d ",i,sum(i.==HH))) 
    if (i+1)/6==round((i+1)/6)
      @printf(o,"   %s\n",out)
      out=""
    end
  end
  @printf(o,"   %s\n",out)
  
  if length(zGood)==1
    @printf(o,"==========================================================================================\n")
    return
  end
  
   
  @printf(o,"Most common sampling intervals of good data\n")
  @printf(o,"%10s %10s %10s %10s %10s\n","days","hours","minutes","seconds","occurrence")
  #.. calculate in seconds to nearest millisecond
  (uCounts,uValues)=MetoceanTools.countUniqueValues(diff(Dates.value(tGood)))
  isCounts=sortperm(uCounts,rev=true)
  sCounts=uCounts[isCounts]
  sValues=uValues[isCounts]
  for i=1:minimum([length(sValues),5])
    @printf(o,"%10g %10g %10g %10g %10d\n",sValues[i]*ms2days,sValues[i]*ms2hours,sValues[i]*ms2minutes,sValues[i]*ms2seconds,sCounts[i])
  end
  
  #.. percentage of values at the principal sampling interval for each month of each year
  @printf(o,"Percentage occurrence of most common sampling interval: %g hour(s)\n",uValues[1]*ms2hours)
  @printf(o,"         JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DEC\n")
  for iyy=1:length(uyy)
    oStr=@sprintf("    %4d ",uyy[iyy])
    for imth=1:12
      mask=(yy.==uyy[iyy]) & (mm.==imth)  #this month and year
      nvalues=sum(mask)
      if nvalues>1
          dd=diff(round(Dates.value(tGood[mask])))
          cnt=sum(dd .== uValues[1])
          pct=round(cnt/nvalues*100)
          oStr=*(oStr,@sprintf("%3d ",pct))
      else
          oStr=*(oStr,@sprintf("%3d ",0))
      end
    end
    @printf(o,"%s \n",oStr)
  end
  
  #.. percentage of values at the second most common sampling interval for each month of each year
  if length(uValues)>1
    @printf(o,"Percentage occurrence of second most common sampling interval: %g hour(s)\n",uValues[2]*ms2hours)
    @printf(o,"         JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DEC\n")
    for iyy=1:length(uyy)
      oStr=@sprintf("    %4d ",uyy[iyy])
      for im=1:12
        mask=(yy.==uyy[iyy]) & (mm.==im)  #this month and year
        nvalues=sum(mask)
        if nvalues>1
            dd=diff(round(Dates.value(tGood[mask])))
            cnt=sum(dd .== uValues[2])
            pct=round(cnt/nvalues*100)
            oStr=*(oStr,@sprintf("%3d ",pct))
        else
            oStr=*(oStr,@sprintf("%3d ",0))
        end
      end
      @printf(o,"%s \n",oStr)
    end
  end
  
  #.. now if requested check for gaps in the data
  parcels,goodDurationDays,iParcels=MetoceanTools.findGaps(in,iColumn,days4gap)
  #..loop over all parcels
  if any(parcels.ID.==0) # Found gaps
     dur=0.
     ig=0
     #@printf(o,"Found %d gaps greater than %g day(s)\n",length(p.sDate)-1,in.days4gap)
     for ip=1:length(parcels.ID)
        if parcels.ID[ip]==0
            ig+=1
            @printf(o,"   Gap %d between %s and %s, duration %8g days\n",ig, 
            Dates.format(parcels.sDate[ip,1],"dd/uuu/yyyy HH:MM:SS"), 
            Dates.format(parcels.sDate[ip,2],"dd/uuu/yyyy HH:MM:SS"),parcels.Duration[ip])
  	  dur+=parcels.Duration[ip]
         end
     end
     pct=100*sum(dur)./tdur
     @printf(o,"There is %g %% gaps greater than %g day(s) in the data\n",pct,days4gap)
  end
   
  # Now find out how many samples are missing assuming that we should
  # have all values with the most common sampling value
  @printf(o,"==========================================================================================\n")
  selt=Dates.value(tGood[1]):uValues[1]:Dates.value(tGood[end])
  @printf(o,"If the record had all samples taken at the most common sampling interval\n")
  @printf(o,"   then there should be %d samples.\n",length(selt))
  i=intersect(Dates.value(tGood),selt)
  @printf(o,"   There are %d of these samples found.\n",length(i))
  @printf(o,"   Thus the data represents %g %%.\n",100*length(i)/length(selt))
  
  @printf(o,"==========================================================================================\n")
   
  return parcels,goodDurationDays,iParcels
  
end
