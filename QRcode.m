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

% Main della che genere il QR code

function QRmatrix = QRcode(Stringa)

ecl = input('Inserisci il livello di codifica (L,M,Q,H) :','s');

[mode,version] = find_mode_version(Stringa,ecl);

if length(mode)== 1
    fprintf('It has been inserted a not codificable symbol');
    QRmatrix=[];
    return
end


[ArrayByte1,ArrayByte2] = Codifica(Stringa,version,mode,ecl); % sistemo l'input in blocchi di byte

[ECCodewordByte1, ECCodewordByte2] = Encoding(ArrayByte1,ArrayByte2,version,ecl); % calcolo gli ECC e li sistemo in blocchi

Finsequence = Assembler(ArrayByte1,ArrayByte2, ECCodewordByte1, ECCodewordByte2, version, ecl); % sistemo tutto in un array

QRmatrix = Positioner(Finsequence,version);  % Qui si posizionano i bit nella matrice, la dimensione va poi aggiornata quando si far?? lo script generalizzato

QRmatrix = Blocchi_cover_info(QRmatrix, version);

n_mask=choose_mask(QRmatrix,version,ecl);

QRmatrix = app_masking(QRmatrix, n_mask,version);

QRmatrix = bit_information(QRmatrix,n_mask, ecl,version);

QRmatrix = ones(length(QRmatrix))-QRmatrix;

QRmatrix = imresize(uint8(QRmatrix),[length(QRmatrix)*10,length(QRmatrix)*10]);
imshow(QRmatrix*255);
imwrite(QRmatrix*255,'QR.png');


end
