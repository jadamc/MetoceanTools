
function checkWaveSpec!(inSpec::waveSpec)
if isdefined(inSpec,:f)
  nf=length(inSpec.f)
  if any(isnan(inSpec.f))
    #println("checkWaveSpec: NaNs found in f")
  end
  if !isdefined(inSpec,:df)
    inSpec.df=makeWaveSpecFreq(inSpec.f)
  end
else
  #println("checkWaveSpec: f not defined")
end

if isdefined(inSpec,:th)
  nth=length(inSpec.th)
  if any(isnan(inSpec.th))
    #println("checkWaveSpec: NaNs found in th")
  end
  if !isdefined(inSpec,:dth)
    inSpec.dth=makeWaveSpecDirn(inSpec.th)
  end
else
  #println("checkWaveSpec: th not defined")
end

if isdefined(inSpec,:Sf)
  inSpec.Sf=vec(inSpec.Sf)
  if isdefined(inSpec,:f)
    if length(inSpec.Sf)!=nf
       #println("checkWaveSpec: Sf is different lengths to f")
       return
    end
  end
end

if isdefined(inSpec,:Sth)
  inSpec.th=vec(inSpec.th)
  if isdefined(inSpec,:th) 
    if length(inSpec.th)!=nth
       #println("checkWaveSpec: Sth is different lengths to th")
       return
    end
  end
end

if isdefined(inSpec,:f) & isdefined(inSpec,:th)
   fm=repmat(inSpec.f[:],1,nth)
   dfm=repmat(inSpec.df[:],1,nth)
   thm=repmat(pi/180*inSpec.th[:]',nf,1)
   dthm=repmat(pi/180*inSpec.dth[:]',nf,1)
end

if isdefined(inSpec,:S)
  nS=collect(size(inSpec.S))
  if isdefined(inSpec,:f) & isdefined(inSpec,:th)
    if any(nS.==nf) & any(nS.==nth)
      if nS[1]==nth
        inSpec.S=inSpec.S'
      end
    else
       #println("checkWaveSpec: S is different size to f and/or th")
       return
    end
  end
  if !isdefined(inSpec,:Sf)
    if isdefined(inSpec,:th)
      # Loop over freq
      inSpec.Sf=zeros(size(inSpec.S,1))
      for i=1:size(inSpec.S,1)
        sumS=0.
	# Sum all directions
        for j=1:size(inSpec.S,2)
          sumS+=dthm[j]*inSpec.S[i,j]
        end
	inSpec.Sf[i]=sumS
      end
      #inSpec.Sf=vec(sum(dthm.*inSpec.S,2))
    end
  end
  if !isdefined(inSpec,:Sth)
    if isdefined(inSpec,:f)
      inSpec.Sth=zeros(size(inSpec.S,2))
      # Loop over dirns
      for i=1:size(inSpec.S,2)
        sumS=0.
	# Sum all frequencies
        for j=1:size(inSpec.S,1)
          sumS+=dfm[j]*inSpec.S[j,i]
        end
	inSpec.Sth[i]=sumS
      end
      #inSpec.Sth=vec(sum(dfm.*inSpec.S,1)) 
    end
  end
end

return inSpec

end






""" 
  Extends Base copy to copy MetoceanTools.waveSpec
"""
function Base.copy(inSpec::waveSpec)::waveSpec
  oSpec=waveSpec()
  isdefined(inSpec,:f) ? oSpec.f=copy(inSpec.f) : 0
  isdefined(inSpec,:df) ? oSpec.df=copy(inSpec.df) : 0 
  isdefined(inSpec,:th) ? oSpec.th=copy(inSpec.th) : 0 
  isdefined(inSpec,:dth) ? oSpec.dth=copy(inSpec.dth) : 0
  isdefined(inSpec,:Sf) ? oSpec.Sf=copy(inSpec.Sf) : 0
  isdefined(inSpec,:S) ? oSpec.S=copy(inSpec.S) : 0
  return oSpec
end







"""
  Function to split a full direction spectrum into two direction spectra
    by cutting along direction space specified by direction boundaries

  INPUT:
    inSpec - type waveSpec containing fields at least th and S both 
               defining vector of directions (th) and direction spectra
         either full directon/frequency or direction spectrum
         Will copy over f,df and will split dth if is defined
    dSplit - defines the directions at which to split the spectrm [stDir,edDir]
  OUTPUT:
    o1,o2  - two partitions of type waveSpec

"""
function wvSpec_dirSplit(inSpec::waveSpec,dSplit)
    th=rem(inSpec.th+720,360)
    dSplitr=rem(dSplit+720,360)
    c1=indmin(abs(th-dSplitr[1]))
    c2=indmin(abs(th-dSplitr[2]))
    if c1==c2
       error("No split required as split directions found are identical at indices $(c1) and $(c2)")
    end
    o1=waveSpec()
    o2=waveSpec()
    o1.f=copy(inSpec.f)
    o2.f=copy(inSpec.f)
    o1.df=copy(inSpec.df)
    o2.df=copy(inSpec.df)
    nth=length(th)
    if c1>c2
      t=c2
      c2=c1
      c1=t
    end
    o1.th=inSpec.th[c1:(c2-1)]
    o2.th=[inSpec.th[c2:end];inSpec.th[1:(c1-1)]]
    o1.th=vec(o1.th)
    o2.th=vec(o2.th)
    if isdefined(inSpec,:df)
      o1.dth=inSpec.dth[c1:(c2-1)]
      o2.dth=[inSpec.dth[c2:end];inSpec.dth[1:(c1-1)]]
      o1.dth=vec(o1.dth)
      o2.dth=vec(o2.dth)
    end
    o1.S=inSpec.S[:,c1:(c2-1)]
    o2.S=[inSpec.S[:,c2:end] inSpec.S[:,1:(c1-1)]]
    checkWaveSpec!(o1)
    checkWaveSpec!(o2)
    return o1,o2
end
function wvSpec_dirSplit(inSpec::Array{waveSpec,1},dSplit)
  nSpec=length(inSpec)
  o1=Array{waveSpec,1}(nSpec)
  o2=Array{waveSpec,1}(nSpec)
  for i=1:nSpec
    o1[i],o2[i]=wvSpec_dirSplit(inSpec[i],dSplit)
  end
  return o1,o2
end






function makeWaveSpecDirn(th::Array{Float64,1})
  dth=similar(th)
  nth=length(th)
  for i=2:nth-1
    th1=rem(th[i-1]+720,360)
    th2=rem(th[i]+720,360)
    th3=rem(th[i+1]+720,360)
    dth1=abs(gmAngDiff(th2,th1))
    dth2=abs(gmAngDiff(th3,th2))
    dth[i]=0.5*(dth1+dth2)
  end                                
  dth[1]=dth[2]
  dth[nth]=dth[nth-1]
  return dth
end



function makeWaveSpecFreq(f::Array{Float64,1})
#t.f=1./(30:-0.05:2)
df=copy(f)
nf=length(f)
df[1]=f[2]-f[1]
df[2:(nf-1)]=( f[3:nf]-f[2:(nf-1)]     )/2 +
( f[2:(nf-1)]-f[1:(nf-2)] )/2
df[nf]=f[nf]-f[nf-1]
return df
end


#######################################################################
# Make a new wave spectrum
#######################################################################
#function makeSpecJONSWAP(Hs,Tp,Gamma,SigmaA,SigmaB)::waveSpec
function makeSpecJONSWAP(inParm)::waveSpec
  # 0. Map input parameters
  (Hs,Tp,Gamma,SigmaA,SigmaB)=inParm
  # A. Make a new spectrum object
  s=waveSpec()
  # B. Create JONSWAP
  g::Float64=9.81
  fp::Float64=1./Tp
  nf=length(s.f)
  S=zeros(nf)
  for i=1:nf
    sigma=SigmaA*(s.f[i]<fp) + SigmaB*(s.f[i]>=fp)
    G=Gamma ^ exp( -1 * (((s.f[i]-fp)^2) / (2*sigma^2*fp^2)) )
    S[i]=g^2.*(2.*pi)^-4.*s.f[i]^-5.*exp(-5/4.*(s.f[i]/fp).^-4.) * G
  end
  sumS=0.
  for i=1:nf
    sumS+=S[i]*s.df[i]
  end
  alpha=Hs.^2./(16.*sumS)
  s.Sf=zeros(nf)
  for i=1:nf
    s.Sf[i]=alpha.*S[i]
  end
  return s
end

#######################################################################
# Calculate wave spectrum integrated parameters
#######################################################################
function calcSpecPar(mySpec::waveSpec)

  # 0. Remove the zero frequency if present
  fZero=find(mySpec.f.==0)
  if !isempty(fZero)
    shift!(mySpec.f)
    shift!(mySpec.df)
    mySpec.S=mySpec.S[2:end,:]
    mySpec.S=mySpec.S[:,:]
  end

  # A. Detemine frequency cut-off 
  fcut::Float64=mySpec.f[end]+mySpec.df[end]/2
  ecut::Float64=mySpec.S[end]

  # B. Calculate moment contributions from the tail
  m0t::Float64=1/4*fcut.*ecut
  m1t::Float64=1/3*fcut^2.*ecut
  m2t::Float64=1/2*fcut^3.*ecut

  # C. Calculate moments of the spectrum
  preCalc0::Array{Float64,1}=mySpec.df
  preCalc1::Array{Float64,1}=preCalc0.*mySpec.S[:,1]
  m0::Float64  = sum(sum(         preCalc1) + m0t)
  m1::Float64  = sum(sum(mySpec.f    .* preCalc1) + m1t)
  m2::Float64  = sum(sum(mySpec.f.^2 .* preCalc1) + m2t)
  mm1::Float64 = sum(sum(1./mySpec.f .* preCalc1))
  fe4::Float64 = sum(sum(mySpec.f .* preCalc0.*mySpec.S.^4))
  e4::Float64  = sum(sum(      preCalc0.*mySpec.S.^4))

  # D. Calculate integrated parameters
  Data=zeros(6)
  Name=["Hs","Tp","T01","T02","Tm01","T4"]
  Data[1]=4.*sqrt(m0); 
  iTp::Int64=indmax(mySpec.S)
  Data[2]=1./(mySpec.f[iTp])
  Data[3]=m0./m1        #[s] Mean Period
  Data[4]=sqrt(m0./m2)  #[s] Zero-crossing Period
  Data[5]=mm1./m0      #[s] Energy Period
  # Calculate T4
  #  Weighted Peak by recommend by Young, Ocean Eng. Vol22 No.7 pp 669 to 686.
  #  The Determination of confidence limits associated with estimates of the
  #    spectral peak frequency
  Data[6]=1./(fe4./e4)

  return Data,Name
end





"""
  Part of:  fitSpecJONSWAPsingle
  
  Returns the RMS error of fit between single JONSWAP and input discrete spectrum

  Written by: Jason McConochie
  Revision 1, 30Dec2016, Jason McConochie
"""
function errorfitSpecJONSWAPsingle(wParm::Array{Float64,1},Sf::Array{Float64,1},fParm,fMask)
  maskReplace!(wParm,fParm,fMask)
  if any(wParm.<0.0)
    return 1000.
  end
  if wParm[3]<0.8
    return 100./(wParm[3])
  end
  solverSpec=makeSpecJONSWAP(wParm)
  sumS=0.
  for i=1:length(Sf)
    sumS+=(Sf[i]-solverSpec.Sf[i])^2
  end
  errRMS=sqrt(sumS)
  #errRMS=sqrt( sum((Sf.-solverSpec.Sf).^2) )
  return errRMS
end
"""
  fitSpecJONSWAPsingle

  Makes a single fit of the JONSWAP single spectrum to an input discrete spectrum
    interpolating the input spectrum to frequencies defined by waveSpec() initialisation

  Input:
     f,S - input spectrum 
     fParm - array of [Hs,Tp,Gamma,SigmaA,SigmaB]
     fMask - Boolean array of mask indicating which of the fParm should be fixed in the fitting process
  Output:
     An array of parameters like fParm containing the best fit parameters

  Written by: Jason McConochie
  Revision 1, 30Dec2016, Jason McConochie
"""
function fitSpecJONSWAPsingle(f::Array{Float64,1},Sf::Array{Float64,1},fParm::Array{Float64,1},fMask::Array{Bool,1})
  # A. Interpolate to the standard waveSpec frequencies
  nS=waveSpec()
  fi=nS.f
  Si=interp1(f,Sf,fi)
  Si[Si.<0.]=0.
  r = optimize(b -> errorfitSpecJONSWAPsingle(b,Si,fParm,fMask), fParm)
  r1 = r.minimizer
  return r1
end
"""
  fitSpecJONSWAPsingle

  Makes a fit of the JONSWAP single spectrum to an input discrete spectrum
    interpolating the input spectrum to frequencies defined by waveSpec() initialisation

  This function takes an array of spectra defintions and returns a tsParm structure

  Input:
     f,S - input spectrum 
     fParm - array of [Hs,Tp,Gamma,SigmaA,SigmaB]
     fMask - Boolean array of mask indicating which of the fParm should be fixed in the fitting process
  Output:
     A tsParm type of parameters
        sDate - dates starting from 1/1/2000 and then every hour
        Data - array containing Hs,Tp,Gamma,SigmaA,SigmaB on each row
        Name - Names of parameters

     This is suitable to be sent to tsQuickPlot

  Written by: Jason McConochie
  Revision 1, 30Dec2016, Jason McConochie
"""
function fitSpecJONSWAPsingle(inSpec::Array{waveSpec,1},fParm::Array{Float64,1},fMask::Array{Bool,1})
  o=tsParm()
  o.Data=zeros(Float64,(length(inSpec),5))
  o.Name=["Hs","Tp","Gamma","SigmaA","SigmaB"]
  o.sDate=Array{DateTime}(length(inSpec))
  for i=1:length(inSpec)
    o.Data[i,:]=fitSpecJONSWAPsingle(inSpec[i].f,inSpec[i].Sf,fParm,fMask)
    o.sDate[i]=DateTime(2000,1,1,0,0,0)+Dates.Day(i)
    #solvedSpec=makeSpecJONSWAP(o.Data[i,:])
    #PyPlot.clf()
    #plot(inSpec[i].f,vec(inSpec[i].S),marker="o")
    #plot(solvedSpec.f,solvedSpec.S)
    #savefig(*("Jason",@sprintf("%015d",i)))
  end
  return o
end









