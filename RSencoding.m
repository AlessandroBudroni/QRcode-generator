%This function computes Reed-Solomon encoding.
%Systematic encoding: redundance+message
%Input: msg-->  Vector of elements in gf(2^8) (vector of bits), message to be encoded  
%       k-->    int, Lenght of input message 
%       n-->    int, Lenght of output message
%Output 
%       msg-->  Vector of elements in gf(2^8) (0..255 notation) , encoded message
function msg = RSencoding( msg, n, k )

%Constructing coefficients vector of x^(n-k)
xnk=[1 0];

for i=1:n-k-1
    xnk=conv(xnk,[1 0]);
end
%casting in gf(2^8)
msg=gf(msg,8);
xnk=gf(xnk,8);

%Systematic encoding
p=get_polynomial(n-k);%Getting generator polynomial
[quotient,remainders]=deconv(conv(msg,xnk),p); %Computing redundance
redundance=remainders(k+1:n);
msg=gf2dec([msg,redundance],8);%converting in integer notation

end

%This function computes generator polynomial of Reed-Solomon encode
%Input:
%       grado--> int, polynomial degree
%
%Output:
%       p--> vector of elements in gf(2^8), vector of polynomial coefficients
%
function p = get_polynomial(grado)

a=gf(2,8);%primitive element
p=[1 1];
%computing coefficients of generator polynomial  
for i=1:grado-1
 p=conv(p,[1 a^i]); 
end


end