%This function chooses the useful mask to be applied to the qr_matrix.
%
%Input: 
%        qr_matrix -->matrix of bits
%        version --> int, the right version of QR to use
%        ecl --> char, indicates the error corretcion level
%Output: 
%       n_mask--> int, mask to be applied.

function n_mask=choose_mask(qr_matrix,version,ecl)

%initialing the evaluation vector, it will contain the score and the associed 
%index mask 
evaluation=[evaluation_mask(qr_matrix,0,version,ecl),0];
for i=2:8

    %calculating the score for each mask
    part_evaluation=evaluation_mask(qr_matrix,i-1,version,ecl);
    %if we find a better score, we substitute the old score and index mask.
    if part_evaluation < evaluation(1)
       evaluation=[part_evaluation,i-1];
    end                                                           
end
n_mask=evaluation(2); %storing the best mask in the output variable

end 



%This function applies a fixed mask(that is rapresented by a matrix) to a matrix by summing them.
%There is 8 different available masks. 
%
% Input: 
%       qr_matrix -->matrix of bits 
%       mask_n --> int, mask index
%       version --> int, the right version of QR to use
%
% Output:
%      qr_matrix -->matrix of bits

function [ qr_matrix ] = app_masking(qr_matrix, mask_n,version)
s=size(qr_matrix,1);%size of qr_matrix
mask=zeros(s,s);%initializing a zeros matrix of same size of qr_code
mask=app_masking_all(mask,mask_n);%applying the mask shape to all matrix
mask=remove_allignments_bits(mask,version);%removing the maskshape in allignments positions.

%summing qr_matrix and chosen mask
for i=1:s
    for j=1:s
        qr_matrix(i,j)=bitxor(mask(i,j),qr_matrix(i,j));
    end
end

end

%This function applies the mask shape to entire matrix 
%
%Input:
%       qr_matrix -->matrix of bits 
%       mask_n --> int, mask index
%
% Output:
%      qr_matrix -->matrix of bits

function [ qr_matrix ] = app_masking_all(qr_matrix, mask_n)

switch mask_n%switch to select the chosen mask
    
    case 0 % constructing mask 0
        for i=1:size(qr_matrix,1)
            for j=1:size(qr_matrix,2)
                if mod(i+j,2) == 0
                    qr_matrix(i,j)= bitxor(qr_matrix(i,j),1);
                end
            end
        end
        
    case 1 % constructing mask 1
        for i=1:size(qr_matrix,1)
            for j=1:size(qr_matrix,2)
                if mod(i-1,2) == 0
                    qr_matrix(i,j)= bitxor(qr_matrix(i,j),1);
                end
            end
        end
        
    case 2 % constructing mask 2
        for i=1:size(qr_matrix,1)
            for j=1:size(qr_matrix,2)
                if mod(j-1,3) == 0
                    qr_matrix(i,j)= bitxor(qr_matrix(i,j),1);
                end
            end
        end
        
    case 3 % constructing mask 3
        for i=1:size(qr_matrix,1)
            for j=1:size(qr_matrix,2)
                if mod(i+j-2,3) == 0
                    qr_matrix(i,j)= bitxor(qr_matrix(i,j),1);
                end
            end
        end
        
    case 4 % constructing mask 4
        for i=1:size(qr_matrix,1)
            for j=1:size(qr_matrix,2)
                if mod(idivide(uint8(i-1),uint8(2))+idivide(uint8(j-1),uint8(3)),2) == 0
                    qr_matrix(i,j)= bitxor(qr_matrix(i,j),1);
                end
            end
        end
        
    case 5 % constructing mask 5
        for i=1:size(qr_matrix,1)
            for j=1:size(qr_matrix,2)
                if mod((i-1)*(j-1),2)+ mod((i-1)*(j-1),3) == 0
                    qr_matrix(i,j)= bitxor(qr_matrix(i,j),1);
                end
            end
        end
        
    case 6 % constructing mask 6
        for i=1:size(qr_matrix,1)
            for j=1:size(qr_matrix,2)
                if mod(mod((i-1)*(j-1),2)+ mod((i-1)*(j-1),3),2) == 0
                    qr_matrix(i,j)= bitxor(qr_matrix(i,j),1);
                end
            end
        end
        
    case 7 % constructing mask 7
        for i=1:size(qr_matrix,1)
            for j=1:size(qr_matrix,2)
                if mod(mod((i-1)+(j-1),2)+ mod((i-1)*(j-1),3),2) == 0
                    qr_matrix(i,j)= bitxor(qr_matrix(i,j),1);
                end
            end
        end
end
end

%%This function removes the various finder puttin the null value
%
%Input:
%       qr_matrix -->matrix of bits 
%       version --> int, the right version of QR to use
%       
% Output:
%      qr_matrix -->matrix of bits

function [ qr_matrix ] = remove_allignments_bits( qr_matrix, version)
%value for pointless bit
global null;
null=0;
side = size(qr_matrix,1);
%qr_matrix = qr_matrix*255;
%%Remove position detection pattern (i 3 quadratoni)
%remove up left
qr_matrix(1:9,1:9) = null;
%remove up right
qr_matrix(1:9,side-7:side)=null;
%remove down left
qr_matrix(side-7:side, 1:9)=null;

%%remove timing patterns (le linee)
qr_matrix(7,:) = null;
qr_matrix(:,7) = null;

%%removing allignement patterns
%TODO:modify for center x,y
if version >1
    centers = get_allignment_patterns_center(version);
    %if the centers are more then one

    for c=centers
        qr_matrix(c.r-2:c.r+2,c.c-2:c.c+2) = null;
    end
end
%removing version information if version is bigger then 6
if version > 6
    %down left
    qr_matrix([(size(qr_matrix)-10):(size(qr_matrix)-8)], [1:6]) = null;
    %up right
    qr_matrix([1:6], [(size(qr_matrix)-10):(size(qr_matrix)-8)]) = null;
end
end

%%return the center of the allignemts patterns
function [ result ] = get_allignment_patterns_center( v )
%TODO: edit center in case bigger then 7
if v>1
    switch v
        case 2
            rc =18;
        case 3
            rc = 22;
        case 4
            rc = 26;
        case 5
            rc = 30;
        case 6
            rc = 34;
        case 7
            rc=[22 38];
        case 8
            rc=[24 42];
        case 9
            rc=[26 46];
        case 10
            rc=[28 50];
        case 11
            rc=[30 54];
        case 12
            rc=[32 58];
        case 13
            rc=[34 62];
        case 14
            rc =[26 46 66];
        case 15
            rc =[26 48 70];
        case 16
            rc =[26 50 74];
        case 17
            rc =[30 54 78];
        case 18
            rc =[30 56 82];
        case 19
            rc =[30 58 86];
        case 20
            rc =[34 62 90];
        case  21
            rc=[28 50 72 94];
        case  22
            rc=[26 50 74 98];
        case  23
            rc=[30 54 78 102];
        case  24
            rc=[ 28 54 80 106];
        case  25
            rc=[32 58 86 114];
        case  26
            rc=[ 30 58 86 114];
        case  27
            rc=[ 34 62 90 118];
        case  28
            rc=[26 50 74 98 122 ];
        case  29
            rc=[30 54 78 102 126 ];
        case  30
            rc=[26 52 78 104 130 ];
        case  31
            rc=[ 30 56 82 108 134];
        case  32
            rc=[ 34 60 86 112 138];
        case  33
            rc=[30 58 86 114 142 ];
        case  34
            rc=[34 62 90 118 146 ];
        case  35
            rc=[30 54 78 102 126 150];
        case  36
            rc=[24 50 76 102 128 154];
        case  37
            rc=[28 54 80 106 132 158 ];
        case  38
            rc=[32 58 84 110 136 162];
        case  39
            rc=[26 54 82 110 138 166];
        case 40
            rc = [30 58 86 114 142 170];
    end
    %size qr
    s = 21+(v-1)*4;
    %initialize result
    result=[];
    %add 6 since it is present a the beginning of all rc vector
    rc =[6 rc];
    %calculate max and min for avoid the 3 corner in the if
    M = max(rc);
    m = min(rc);
    for r =rc
        for c=rc
            %avoiding Position Detection Patterns
            if (c~=M|| r~=M)&&(c~=m || r~=m) && ...
                    (r~=M || c~=m)
                result = [result struct('r',s-r,'c',c+1)]; 
            end
        end
    end
end

end


%This function calculates the score for a fixed mask, evalueating four 
%different features.
%
%Input:
%       qr_matrix -->matrix of bits 
%       mask_n --> int, mask index
%       version --> int, the right version of QR to use
%       ecl --> char, indicates the error corretcion level
%
%Output:
%       n --> int, score computed
%

function n=evaluation_mask(qr_matrix,mask_n,version,ecl)
s=size(qr_matrix,1); %size of qr_matrix
qr_matrix = bit_information(qr_matrix,mask_n, ecl,version); %finding information bits
%Applying n-th mask
qr_matrix=app_masking(qr_matrix, mask_n,version);

%Feature 1 Adjacent modules
%
%Searching in the rows
n=0;%initializing score
for i=1:s %columns index
    n_uguali=1;%initializing number of equal adjacent modules
    for j=1:s-1 %rows index 
        if qr_matrix(i,j) == qr_matrix(i,j+1); %check if this modules are equal
            n_uguali=n_uguali+1;%increasing number of equal adjacent modules
        elseif n_uguali>=5
                 n= n+(n_uguali-5)+3; %adding penalty points
                n_uguali=1;
        end;
    end;
                if (qr_matrix(i,s-1) == qr_matrix(i,s)) && n_uguali>=5; %checking if the last two modules are equal
                    n= n+(n_uguali-5)+3; %adding penalty points
                end;
end;

%Searching in the columns
for j=1:s %rows index
    n_uguali=1;
    for i=1:s-1 %columns index
        if qr_matrix(i,j) == qr_matrix(i+1,j);
            n_uguali=n_uguali+1;
            
        elseif n_uguali>=5
           n= n+(n_uguali-5)+3;
           n_uguali=1;
        end;
    end;
                if (qr_matrix(s-1,j) == qr_matrix(s,j)) && n_uguali>=5;
                    n= n+(n_uguali-5)+3;
                end;
end;

%Feature 2
%Searching 2x2 blocks
square_n=[1,1;1,1]; %2x2 black square
square_b=[0,0;0,0]; %2x2 white square

for i=1:s-1
    for j=1:s-1%
        %checking if there are this kind of this blocks
        if isequal(qr_matrix(i:i+1,j:j+1),square_n) || isequal(qr_matrix(i:i+1,j:j+1),square_b) 
            n=n+3; %adding penalty points
        end
    end
end

%Feature 3

for q=1:floor(s/7)
    % generating particular kind of vectors
    v=[];
    for j=1:q
        v=cat(2,v,1);
    end
    for j=1:q
        v=cat(2,v,0);
    end
    for j=1:q
        v=cat(2,v,[1 1 1]);
    end
    for j=1:q
        v=cat(2,v,0);
    end
    for j=1:q
        v=cat(2,v,1);
    end
    
    %Searching v in the matrix (rows)
    %
    for i=1:s
        for j=1:s-7*q+1;
            if isequal(qr_matrix(i,j:j+7*q-1),v)
                n=n+40;
            end
        end
    end
    
    %Searching v in the matrix (columns)
    for j=1:s
        for i=1:s-7*q+1;
            if isequal(qr_matrix(i:i+7*q-1,j),transpose(v))
                n=n+40;
            end
        end
    end
end



%Feature 4
%
number_of_blacks=0;%Initializing number of blacks
for i= 1: s
    for j = 1:s
        if qr_matrix(i,j) == 1;
            %Computing number of blacks in the matrix
            number_of_blacks= number_of_blacks+1; 
        end
    end
end
%Computing percentage of blacks
perc_number_of_blacks=floor((number_of_blacks*100)/(s^2));
if perc_number_of_blacks == 50 
    k=0;
else
    k=ceil(norm(perc_number_of_blacks-50)/5)-1; 
end
n=n+k*10; %adding penalty points
end


 
