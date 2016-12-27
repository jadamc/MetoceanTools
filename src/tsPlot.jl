

function tsQuickPlot(o::tsParm,pngImageFile::String)   

   plt=PyPlot
   plt.ioff()
   nPlots=size(o.Data,2)
   f=plt.figure("tsQuickPlot",figsize=(10,4*nPlots))
   subplots_adjust(hspace=0.25)
   #majorformatter = matplotlib[:dates][:DateFormatter]("%d.%m.%Y")
   #majorformatter = matplotlib[:dates][:DateFormatter]("%Y")
   #minorformatter = matplotlib[:dates][:DateFormatter]("%H:%M")
   #majorlocator = matplotlib[:dates][:MonthLocator](interval=12*5)
   #minorlocator = matplotlib[:dates][:HourLocator](byhour=(8, 16))
   jDates=Dates.datetime2julian(o.sDate)
   
   # If running in julia not IJulia
   #pygui(true)

   for i=1:nPlots
      ax=plt.subplot(nPlots,1,i)
      ax[:set_ylabel](o.Name[i],fontsize=10) 
      ax[:tick_params]("both",labelsize=10) 
      #ax[:xaxis][:set_major_formatter](majorformatter)
      #ax[:xaxis][:set_minor_formatter](minorformatter)
      #ax[:xaxis][:set_major_locator](majorlocator)
      #ax[:xaxis][:set_minor_locator](minorlocator)
      #plt.plot_date(o.sDate,o.Data[:,i],markersize=1,fmt=".",color="red", linewidth=0.25)
      plt.plot_date(jDates,o.Data[:,i],markersize=1,fmt=".",color="red", linewidth=0.25)
      grid("on")
   end

   println(*("File saved to:",pngImageFile))
   savefig(pngImageFile)

   return true
end

