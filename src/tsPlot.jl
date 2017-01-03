

function tsQuickScatter(o::tsParm,pngImageFile::AbstractString)

  plt=PyPlot
  plt.ioff()
  plt.clf()
  nPlots=size(o.Data,2)
  #nPlots=4
  f=plt.figure("tsQuickScatter",figsize=(4*nPlots,4*nPlots))
  subplots_adjust(wspace=0.3)
  k=0
  xBinCentres=zeros(19)
  p5=zeros(19)
  p50=zeros(19)
  p95=zeros(19)
  for i=1:nPlots
    for j=1:nPlots
       k+=1
       ax=plt.subplot(nPlots,nPlots,k)
       ax[:set_ylabel](o.Name[j],fontsize=10)
       ax[:tick_params]("both",labelsize=10)
       ax[:set_xlabel](o.Name[i],fontsize=10)
       ax[:tick_params]("both",labelsize=10)
   
       x=o.Data[:,i]
       y=o.Data[:,j]

       xMin,xMax,xTicks=ascale(minimum(x),maximum(x),"s")
       # Calculate binned percentiles
       xBinEdges=linspace(xTicks[1],xTicks[end],20)
       mask=falses(length(x))
       for ik=2:length(xBinEdges)
          mask = (x.>xBinEdges[ik-1]) & (x.<xBinEdges[ik]) & (!isnan(y))
	  if all(!mask)
	    p5[ik-1]=NaN
	    p50[ik-1]=NaN
	    p95[ik-1]=NaN
	  else
            p5[ik-1]=StatsBase.percentile(y[mask],5)
            p50[ik-1]=StatsBase.percentile(y[mask],50)
            p95[ik-1]=StatsBase.percentile(y[mask],95)
	  end
          xBinCentres[ik-1]=0.5*(xBinEdges[ik-1]+xBinEdges[ik])
       end
   
       ax[:set_xlim]((xMin,xMax))
       ax[:set_xticks]((xTicks))
       plot(x,y,"b.",color="#a0a060")
       plot(xBinCentres,p5,"k-o",color="#3030f0")
       plot(xBinCentres,p50,"r-o")
       plot(xBinCentres,p95,"k-o",color="#3030f0")
       grid("on")
    end
  end
  savefig(pngImageFile)
  println(*("File saved to:",pngImageFile))
  return true
  end


function tsQuickPlot(o::tsParm,pngImageFile::AbstractString)   

   plt=PyPlot
   #plt.ioff()
   plt.clf()
   nPlots=size(o.Data,2)
   f=plt.figure("tsQuickPlot",figsize=(10,4*nPlots))
   subplots_adjust(hspace=0.25)
   #majorformatter = matplotlib[:dates][:DateFormatter]("%d.%m.%Y")
   #majorformatter = matplotlib[:dates][:DateFormatter]("%Y")
   #minorformatter = matplotlib[:dates][:DateFormatter]("%H:%M")
   #majorlocator = matplotlib[:dates][:MonthLocator](interval=12*5)
   #minorlocator = matplotlib[:dates][:HourLocator](byhour=(8, 16))
   jDates=Dates.datetime2julian(o.sDate)
   ind=[x for x=1:length(o.sDate)] 
   # If running in julia not IJulia
   #pygui(true)
   dateTicks(o.sDate)

   for i=1:nPlots
      ax=plt.subplot(nPlots,1,i)
      ax[:set_ylabel](o.Name[i],fontsize=10) 
      ax[:tick_params]("both",labelsize=10) 
      #ax[:xaxis][:set_major_formatter](majorformatter)
      #ax[:xaxis][:set_minor_formatter](minorformatter)
      #ax[:xaxis][:set_major_locator](majorlocator)
      #ax[:xaxis][:set_minor_locator](minorlocator)
      #plt.plot_date(o.sDate,o.Data[:,i],markersize=1,fmt=".",color="red", linewidth=0.25)
      #plt.plot_date(jDates,o.Data[:,i],markersize=1,fmt=".",color="red", linewidth=0.25)
      #plt.plot_date(ind,o.Data[:,i],markersize=1,fmt=".",color="red", linewidth=0.25)
      #plt.plot(ind,o.Data[:,i],"r.")#,markersize=1,fmt=".",color="red", linewidth=0.25)
      plt.plot(jDates-jDates[1],o.Data[:,i],"r.",markersize=1)#,fmt=".",color="red", linewidth=0.25)
      grid("on")
   end

   plt.show()
   savefig(pngImageFile)
   println(*("File saved to:",pngImageFile))

   return true
end

