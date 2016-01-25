% questa funzione sistema i bit nella matrice




function qr_matrix = Positioner(ArrayCodeword, version)
global null ;
null = -1;
%ArrayCodeword = fliplr(ArrayCodeword);
get_dim = [21 25 29 33 37 41 45 49 53 57 61 65 69 73 77 81 85 89 93 97 101 105 109 113 117 121 125 129 133 137 141 145 149 153 157 161 165 169 173 177];

dim = get_dim(version);

qr_matrix = zeros(dim,dim);


qr_matrix = remove_allignments_bits(qr_matrix,version); 

%starting from right down corner
%n is used for count the number of bit, 
%it start from 7 and end in 0, then begin 
%again from 7 until the matrix end
n=7; 









%retrieve data in the first part of qr (prima della riga verticale di 1 0)
for c=size(qr_matrix,2):-2:9
	%read from bottom to top
    	[qr_matrix, p, n, ArrayCodeword] = upwards(qr_matrix, [size(qr_matrix,1),c], n, ArrayCodeword);
	%reverse the matrix for read every time from bottom to top    	
	qr_matrix=rotate_matrix(qr_matrix);
end
%%retrieve data in the second part (dopo la famosa riga)
for c=6:-2:2
	%same as before
    [qr_matrix, p, n, ArrayCodeword] = upwards(qr_matrix, [size(qr_matrix,1),c], n, ArrayCodeword);
    qr_matrix=rotate_matrix(qr_matrix);
end
%since it appends every bit to the data sequence we need to reverse the sequence
ArrayCodeword = fliplr(ArrayCodeword);




end

%%Add (if is possible) 1 or 2 bit to the bit sequence data
%input:
%	qr_matrix: the qr matrix (as name says)
%	p : is a point (r,c) where the function begin
%	n : counter of bit (0<=n<=7)
%	data : the result
function [qr_matrix, p ,n, ArrayCodeword] = upwards(qr_matrix, p, n, ArrayCodeword)
%this variable is global and it is the value that we give to the null position
%usually we set it to -1
global null;
	%retrieve row form point
    	r=p(1);
	%retrieve column from point    	
	c=p(2);

%check if the gven position is inside the matrix
%if not it finish the column then it exit	
    if r>0 && r<=size(qr_matrix,1)
	%check if the byte isn't finished
        if n>=0
            %check if the position is not null
	    %(for avoid the pattern finder)
            if qr_matrix(r,c) ~= null;
                
                   if length(ArrayCodeword) >=1
                   qr_matrix(r,c) =  ArrayCodeword(1);
                   ArrayCodeword(1) = [];
                   end
		%budro tu devi mettere al posto di n il bit da scrivere                
		%qr_matrix(r,c) = n;
		%read the bit
                    
                if qr_matrix(r,c-1) ~= null
                    if n==0
                        n=8;
                        %qr_matrix(r,c-1) = n-1;
                        if length(ArrayCodeword) >=1
                        qr_matrix(r,c-1) =  ArrayCodeword(1);
                        ArrayCodeword(1) = [];
                        end
                    else
                        if length(ArrayCodeword) >=1
                    qr_matrix(r,c-1) =  ArrayCodeword(1);
                   ArrayCodeword(1) = [];
                        end
                    end
                    [qr_matrix, p, n, ArrayCodeword] = upwards(qr_matrix, [r-1,c], n-2, ArrayCodeword);
                else
                    [qr_matrix, p, n, ArrayCodeword] = upwards(qr_matrix, [r-1,c], n-1, ArrayCodeword);
                end
            else
                if qr_matrix(r,c-1) ~= null
                    %qr_matrix(r,c-1) = n;
                    if length(ArrayCodeword) >=1
                    qr_matrix(r,c-1) =  ArrayCodeword(1);
                        ArrayCodeword(1) = [];
                    end
                    [qr_matrix, p, n, ArrayCodeword] = upwards(qr_matrix, [r-1,c], n-1, ArrayCodeword);
                else
                    [qr_matrix, p, n, ArrayCodeword] = upwards(qr_matrix, [r-1,c], n, ArrayCodeword);
                end
            end
         else
             %recall the upward for the new byte
             [qr_matrix, p ,n, ArrayCodeword] = upwards(qr_matrix, p, 7, ArrayCodeword);
        end
    end
end

function [result] =rotate_matrix(matrix)
result= zeros(size(matrix));
for r=0:size(matrix,1)-1
   result(r+1,:) = matrix(size(matrix,1)-r,:); 
end
end



