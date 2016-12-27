
function dlpRead(fName::AbstractString)::tsParm
    o=tsParm()

    # A. Read dlp file - all into memory (unless really big file this 
    #     should not be a problem when optimisation is done
    
    # A1. Get data to preallocate memory
    #     Also count the number of data lines
    fID::IOStream=open(fName)
    nLines::Int64=0
    ndLines::Int64=0
    iDataSt::Int64=0
    iDataEd::Int64=0
    foundData::Bool=false
    rLines::Array{AbstractString,1}=[]
    while !eof(fID)
      in::AbstractString=readline(fID)
      nLines+=1
      push!(rLines,in)
      if foundData
        m=match(r"^\%",in)    # Check this is not a comment line
        if m === nothing
          m=match(r"[0-9]+",in) # Check there is something on the line - not just blanks
          if m !== nothing
	    (ndLines==0) ? iDataSt=nLines : 0
            ndLines+=1
	  else
	    if iDataEd==0 
	      (ndLines>0) ? iDataEd=nLines-1 : 0
	    end
	  end
        end
      end
      m=match(r"\[data\]"i,in)  # Check if this is the start of the data section
      if m !== nothing
        foundData=true
      end
    end
    (iDataEd==0) ? iDataEd=nLines : 0
    close(fID)
    println("Checked file $(fName):")
    println("  Found $(nLines) lines")
    println("  Found data lines from $(iDataSt) to $(iDataEd)")
    
    # B. Now make some interpretations of the Parameter sections
    function getParNm(inStr) m=match(r".*:(.*)]",inStr); a=m.captures[1]; end
    iP=find(x->contains(x,"[parameter"),rLines)
    parNms=Array(AbstractString,length(iP))
    for k=1:length(iP)
      parNms[k]=getParNm(rLines[iP[k]])
    end
    
    # C. Loop over each parameter section and gather metadata in a Dict
    function readParSect(iP::Int64, rLines::Array{AbstractString})
      c::Dict=Dict()
      lk=0
      while(!(chomp(rLines[iP+lk+1])=="")) 
        lk=lk+1
        m=match(r"(.* ) +(.*)",rLines[iP+lk])
        if m!==nothing 
           a=replace(m.captures[1]," ","");
           b=replace(m.captures[2],r"\r","");
	   c[a]=b
        end
      end
      return c
    end

    local k::Int64=0
    o.Meta=Dict()
    for k=1:length(iP)
      o.Meta[parNms[k]]=readParSect(iP[k],rLines)
    end

    # C1. Set list of variables
    o.Name=Array(AbstractString,length(iP))
    i=0
    for k=1:length(iP)
      if haskey(o.Meta[parNms[k]],"column")
        i+=1
        o.Name[i]=getParNm(rLines[iP[k]])
      end
    end

    # D. Interpret in the dataset
    i=0
    df = Dates.DateFormat("dd-uuu-yyyy HH:MM");
    for k=iDataSt:iDataEd
       a=replace(rLines[k],"\r\n","")
       a=replace(a,","," ")
       kk=search(a,r" |,")
       kk=search(a,r" |,",kk[end]+1)
       tDate=a[1:kk[1]]
       a=replace(a[kk[1]:end],r" +"," ")
       a=replace(a,r"^ ","")
       a=replace(a,"\n","")
       jdd=readdlm(IOBuffer(a))
       if i==0
         o.sDate=[]
         o.Data=zeros(iDataEd-iDataSt+1,size(jdd,2))
       end
       i+=1
       o.Data[i,:]=jdd[1,:]
       push!(o.sDate,Dates.DateTime(tDate,df))
    end
    println("  Read $i data lines")
    return o
    
end
    
    
    
