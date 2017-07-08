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

% Input: 
%       QR_matrix --> matrix
%       version --> int, the right version of QR to use
%
% Output:
%       QR_matrix --> matrix
%
% This function put the allignment pattern on the matrix and put
% some zeros instead of the version and format information

function QR_matrix = Blocchi_cover_info(QR_matrix, version)

QR_matrix = Blocchi(QR_matrix,version); % metto i blocchi

QR_matrix = cover_format_information(QR_matrix);

QR_matrix = cover_version_information(QR_matrix,version);

end




function QRplaced = Blocchi(QRplaced,Version)

%m = 29; % propria della versione 3
m = length(QRplaced(1,:));

QRplaced(7,8:2:m-7)=0;
QRplaced(7,9:2:m-8)=1;

QRplaced(8:2:m-7,7)=0;
QRplaced(9:2:m-8,7)=1;


QRplaced(1:7,1:7) = 0;  % Disegno quadrato in alto a sinistra

QRplaced(1:6,m-6:m) = 0;  % Disegno quadrato in alto a destra

QRplaced(m-6:m,1:7) = 0;  % Disegno quadrato in basso a sinistra



QRplaced(1:7,1:7) = 1;  % Disegno quadrato in alto a sinistra
QRplaced(2:6,2:6) = 0;
QRplaced(3:5,3:5) = 1;
QRplaced(1:8,8) = 0;
QRplaced(8,1:8) = 0;

QRplaced(1:7,m-6:m) = 1;  % Disegno quadrato in alto a destra
QRplaced(2:6,m-5:m-1) = 0;
QRplaced(3:5,m-4:m-2) = 1;
QRplaced(8,m-7:m) = 0;
QRplaced(1:7,m-7) = 0;

QRplaced(m-6:m,1:7) = 1;  % Disegno quadrato in basso a sinistra
QRplaced(m-5:m-1,2:6) = 0;
QRplaced(m-4:m-2,3:5) = 1;
QRplaced(m-7,1:8) = 0;
QRplaced(m-7:m,8) = 0;
QRplaced(m-7,9) = 1; % metto il dark module

if version>1
    %Disegno i quadratini
    Center = get_allignment_patterns_center(Version);

    for i=1:length(Center)
    
        QRplaced(Center(i).r-2:Center(i).r+2,Center(i).c-2:Center(i).c+2) = 1;
        QRplaced(Center(i).r-1:Center(i).r+1,Center(i).c-1:Center(i).c+1) = 0;
        QRplaced(Center(i).r,Center(i).c) = 1;
    
    end
end
    
    
end











% Questa funzione mette le information bit.
% INPUT:
% - QRmatrix: la matrice
% - mask_reference: deve essere un vettore di 3 bit che ci dice che
% maschera si sta usando
% - ECC_level deve essere il livello di correzione, un char tra 'L', 'M',
% 'Q' e 'H'.


function QRmatrix = cover_format_information(QRmatrix)


m = length(QRmatrix(:,1));

 QRmatrix(1:6,9) = 0;
 QRmatrix(8:9,9) = 0;
 QRmatrix(9,8) = 0;
 QRmatrix(9,6:-1:1) = 0;
  
 QRmatrix(9,m:-1:m-7) = 0;
 QRmatrix(m:-1:m-6,9) = 0;

end








function QR_matrix = cover_version_information(QR_matrix,version)
m = length(QR_matrix);
if version >=7
k = 0;
for j=6:-1:1
    for i=1:3        
      QR_matrix(m-7-i,j) = k;  
      k = k+1;
    end
end

for j=6:-1:1
    for i=1:3        
      QR_matrix(j,m-7-i) = k;  
    end
end


end

end
