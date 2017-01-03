"""
# Choose

  Displays a number menu in the matlab console.

## Syntax

   ichoose=gnChoose(header,itemlist)

## Description

 An OM_JPL Function.

 Displays a numbered menu on the metlab command window that allows the user
  to make a selection of one or more items.   The item number/s is returned.

 A user may cancel the selection, upon which [] is returned.
 
## INPUTS

   header          a title displayed at the top of the menu list
   itemlist        a cell array of strings to be displayed a numbered list
  
## OUTPUTS

   ichoose        the index of the selected menu item

## EXAMPLES

   o={ ...
       'Start MTB', ...
       'Start XWaves', ...
       '2013 Jobs', ...
       '2014 Jobs', ...
      };
    so=gnChoose('',o);

## Example
 To demonstrate the functionality, an example is shown below: 

   t = 'Job type';
   o={ ...
       'Start MTB', ...
       'Start XWaves', ...
       '2013 Jobs', ...
       '2014 Jobs', ...
      };
    so=gnChoose(t,o);

## Revisions

 Written by: Jason McConochie 
 Rev 1, 21-Dec-2016  Jason McConochie
"""
function gnChoose(header::AbstractString,itemlist::Tuple)

   write(STDOUT,"\n\n$(header)\n\nChoose:\n")
   n=length(itemlist)
   for i=1:n
       write(STDOUT,"$(i). $(itemlist[i])\n")
   end
   write(STDOUT,"$(n+1). Cancel\n")
   write(STDOUT,'\n')
   function input(prompt::AbstractString="")
        print(prompt)
        return chomp(readline())
   end

   ichoose=n+2
   while (ichoose > n+1) | (ichoose < 1)
       ichoose=parse(Int,input("Select Option: "))
   end
   return ichoose

end











"""
  maskReplace!

  Replaces values in array original with values in array replacements if replaceMask is true
  
  Usage: maskReplace!(original,replacements,replaceMask)

  Example: 

```  	
  julia> original=[1,2,3,4,5]
  julia> replacements=[0,0,4,0,1]
  julia> replaceMask=[false,true,true,false,true]
  julia> maskReplace!(original,replacements,replaceMask)
  julia> original
  5-element Array{Int64,1}:
    1
    0
    4
    4
    1
  ```
"""
function maskReplace!{T<:Number}(original::Array{T,1},replacements::Array{T,1},replaceMask::Array{Bool,1})
  for i in eachindex(replaceMask)
  original[i]=!replaceMask[i]*original[i] + replaceMask[i]*replacements[i] 
  end
end




"""
Array based Dates.value function definition
"""
function Dates.value(in::Array{DateTime,1})::Array{Int64,1}
   out=zeros(Int64,size(in,1))
   for i=1:length(in)
   out[i]=Dates.value(in[i])
   end
   return out
end




function gmAngDiff(this_angle,relative_to)
  ang1=this_angle
  ang2=relative_to
  #Make all angles to be between 0 and 360 degrees
  ang1=mod(ang1,360)
  ang2=mod(ang2,360)
  #Calculate angular difference as angle1-angle2
  angdiff=ang1-ang2
  #Identify angles > 180. These need to be sutracted from 360 
  if angdiff>180
    angdiff=angdiff-360
  end
  #Identify angles <-180. These need to be sutracted from 360 
  ismall=find(angdiff<=-180)
  if angdiff<=-180
    angdiff=angdiff+360
  end
  return angdiff
end




"""
function [minl,maxl,ticks]=ascale(minv,maxv,sType);
 Function will calculate nice axis limits based on the minimum and maximum values
  in the vectors minv and maxv 

 Several options for how the limits are set is available based on the value of type
 's' - allows some extra space at either end of the minv and maxv

 Revision 1, 27Dec2010 Jason McConochie (original code by Luciano Mason)
"""
function ascale(minv::Float64,maxv::Float64,sType::AbstractString)
   #minv=real(minv)
   #maxv=real(maxv)
   #minv[isnan.(minv)]=[]
   #maxv[isnan.(maxv)]=[]
   #if isempty(minv) | isempty(maxv)
   #  minl=-1
   #  maxl=1
   #  ticks=[-1,0,1]
   #  return
   #end
   #if isnan(minv) | isnan(maxv)
   #  minl=-1
   #  maxl=1
   #  ticks=[-1,0,1]
   #  return
   #end
   
   # Vector of Number of tick marks wanted
   di=[5,6,7,8,9]
   m=length(di)
   # Vector of step sizes ie. 1,10,100 2,4,6,8 5,0.5,50 etc
   i=[1,2,5]
   n=length(i)
   if(abs(minv - maxv)<1e-8)
     minv=minv-0.1*abs(minv)
     maxv=maxv+0.1*abs(maxv)
   end
   if( (minv==0) & (maxv==0) )
     minv=-1
     maxv=1
   end
   
   
   # Make vector of intervals based on di
   range=abs(maxv-minv)
   # ai=range./di;
   # Work in log space 
   li=log10(i)
   try
     lai=log10(range)-log10(di)
   catch
     minl=minv
     maxl=maxv
     ticks=[minl,maxl]
   end
   li=repmat(li',m,1)
   lai=repmat(lai,1,n)
   # Find best combination of Number of ticks/Interval
   r=abs(rem(lai-li,1))
   #r=abs(lai-li)
   minr=minimum(r[:])
   #r=rem(r,1);minr=rem(minr,1);
   
   imin,jmin=findn(r.==minr)
   #println(['No. of tick gaps=' num2str(di(imin)) ' Step size=' num2str(i(jmin))]);
   i=imin[end]
   j=jmin[end]
   
   di=lai[i,j]-li[i,j]
   fdi=floor(abs(di))*sign(di)
   interval=10.^(fdi+li[i,j])
   
   if sType=="e"
     llim=floor(minv/interval)*interval
     ulim=ceil(maxv/interval)*interval
     ticks=[x for x=llim:interval:ulim]
     minl=ticks[1]
     maxl=ticks[end]
   end 
   if sType=="i"
     llim=ceil(minv/interval)*interval
     ulim=floor(maxv/interval)*interval
     ticks=[x for x=llim:interval:ulim]
     minl=minv
     maxl=maxv
   end 
   if sType=="s"
     llim=ceil((minv-0.05*range)/interval)*interval
     ulim=floor((maxv+0.05*range)/interval)*interval
     ticks=[x for x=llim:interval:ulim]
     minl=minv-0.05*range
     maxl=maxv+0.05*range
   end 
   
   return minl,maxl,ticks
end
