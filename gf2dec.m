% Copyright 2017
% 
% Authors: Alessandro Budroni, Ermes Franch, Giuseppe Giffone
% 
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
% 
%     http://www.apache.org/licenses/LICENSE-2.0
% 
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.

%gf2dec.m
%Convert a Galois Field Array into a Decimal Array.
%The calling syntax is:
%		[DecOutput] = gf2dec(GFInput,m,prim_poly)
%Inputs:
%   GFInput: gf Array input
%   m: integer between 1 and 16 used in GF(2^m) array
%   prim_poly: integer representation of the primitive polynomial used by GF
%Outputs:
%   DecOutput: Decimal Array 
%Dr. Murad Qahwash
%DeVry University-Orlando, FL
%e-mail: mqahwash@orl.devry.edu
%October 05, 2006
%=================================================================
function [DecOutput] = gf2dec(GFInput,m)
GFInput = GFInput(:)';% force a row vector
GFRefArray = gf([0:(2^m)-1],m);
for i=1:length(GFInput)
    for k=0:(2^m)-1
        temp = isequal(GFInput(i),GFRefArray(k+1));
        if (temp==1)
            DecOutput(i) = k;
        end
    end
end