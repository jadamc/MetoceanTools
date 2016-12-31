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


