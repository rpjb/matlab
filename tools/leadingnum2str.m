% LEADINGNUM2STR converts an integer number to a string left-padded with
% zeros
% 
% leadingnum2str is useful in creating filenames for incrementally
% increasing id numbers.
%
% type: function
%
% inputs: 
%   num:  string or integer representing the number to be left-padded
%   totaldigits:  integer representing total number of digits desired for output.  
%
% outputs:
%   output:  string containing the number left padded with zeros
% 
% dependencies on custom functions:
%   none
%
% Robert Barretto, robertb@gmail.com
% 04/19/2011 11:53am


function [output] = leadingnum2str(num, totaldigits)   
    a  = 10^totaldigits;
    b = ['%1.' num2str(totaldigits) 'f'];

    if isnumeric(num)
        c = sprintf(b,num/a);
    elseif isstr(num)
        c = sprintf(b,str2num(num)/a);
    end
        
    if num/a < 1
        output = c(3:length(c));
    else
        output = NaN;
    end
end