% Input: 
%       Stringa --> input string
%       version --> int, the right version of QR to use
%       mode --> array of 4 bits
%       ecl --> char, 'H','Q','M','L'
%
% Output:
%       ArrayByte1 --> array of byte of the group 1
%       ArrayByte1 --> array of byte of the group 2, 0 if there's not group
%       2, it depends from the version

function [ArrayByte1,ArrayByte2] = Codifica(Stringa,Version,mode,ecl)


[numDataBits, n_data_block1, n_block1, n_data_block2, n_block2] = info_version(Version,ecl);


if mode == [0,0,1,0] %
    ArrayBit = alfa_numeric(Stringa,Version);
elseif mode == [0,0,0,1]
    ArrayBit = numerica(Stringa,Version);
elseif mode == [0,1,0,0]
    ArrayBit = ByteConv(Stringa,Version); 
end

% Add Padding e Terminator
for i = 1:4
    if (length(ArrayBit) == numDataBits)
        break;
    end
    ArrayBit = cat(2,ArrayBit,0);
    
end

while not(mod(length(ArrayBit),8) == 0)
    ArrayBit = cat(2,ArrayBit,0);
end

while length(ArrayBit) < numDataBits
    ArrayBit = cat(2,ArrayBit,[1,1,1,0,1,1,0,0]);
    if (length(ArrayBit) == numDataBits)
        break
    end
    ArrayBit = cat(2,ArrayBit,[0,0,0,1,0,0,0,1]);  
end

tmpt = transpose(reshape(ArrayBit,8,numDataBits/8));



ArrayByte1 = [];
ArrayByte2 = [];
if  n_block2 == 0
    for i = 1:n_block1
        ArrayByte1(1:n_data_block1,:,i) = tmpt(1:n_data_block1,:);
        tmpt(1:n_data_block1,:) = [];
    end
    ArrayByte2 = 0;

else
    for i = 1:n_block1
        ArrayByte1(1:n_data_block1,:,i) = tmpt(1:n_data_block1,:);
        tmpt(1:n_data_block1,:) = [];
    end
    for i = 1:n_block2
        ArrayByte2(1:n_data_block2,:,i) = tmpt(1:n_data_block2,:);
        tmpt(1:n_data_block2,:) = [];
    end
end


end





% Input: 
%       Stringa --> input string
%       version --> int, the right version of QR to use

% Output:
%       ArrayBit --> array of bit derivating from the input string,
%       codified with the alfanumeric method



function ArrayBit = alfa_numeric(Stringa,version)

keySet = ['0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z',' ','$','%','*','+','-','.','/',':'];

mode = [0,0,1,0];

if version < 10
ArrayBit = cat(2,mode,de2bi(length(Stringa),9,'left-msb'));
elseif  and(version >= 10, version < 27)
    ArrayBit = cat(2,mode,de2bi(length(Stringa),11,'left-msb'));
else
    ArrayBit = cat(2,mode,de2bi(length(Stringa),13,'left-msb'));
end


parity = mod(length(Stringa),2);    % Verifico se la lunghezza della stringa sia pari o dispari(parity = 1 \/ 0)
lenStringa = (length(Stringa)-parity);   % Lunghezza della stringa a meno dell'ultimo carattere

Coppie = zeros(2,lenStringa/2);  % inizializzo un array a due dimensioni in cui registrer?? le coppie di char

for i = 1:lenStringa/2  % registro ogni coppia di caratteri
    Coppie(1,i) = find(keySet == Stringa(2*i-1))-1;
    Coppie(2,i) = find(keySet == Stringa(2*i))-1;
        
end


for i = 1:lenStringa/2 % converto ogni coppia di caratteri in bit e casto tutto in un unico array 
    ArrayBit = cat(2,ArrayBit,de2bi(Coppie(1,i)*45 + Coppie(2,i),11,'left-msb'));
    
end

if (parity == 1) % casto il carattere rimanente nel caso la lunghezza della stringa sia dispari
   ArrayBit = cat(2,ArrayBit,de2bi(find(keySet == Stringa(length(Stringa)))-1,6,'left-msb'));
    
end

end



% Input: 
%       Stringa --> input string
%       version --> int, the right version of QR to use

% Output:
%       ArrayBit --> array of bit derivating from the input string,
%       codified with the numeric method


function ArrayByte = numerica(Stringa,version)
parity = mod(length(Stringa),3); %resto mod 3
lenStringa = (length(Stringa)-parity); % lunghezza stringa divisibile per tre
keyset = ['0', '1' ,'2','3','4','5','6','7','8','9'];
if version < 10
ArrayByte = cat(2,[0,0,0,1],de2bi(length(Stringa),10,'left-msb'));
elseif  and(version >= 10, version < 27)
    ArrayByte = cat(2,[0,0,0,1],de2bi(length(Stringa),12,'left-msb'));
else
    ArrayByte = cat(2,[0,0,0,1],de2bi(length(Stringa),14,'left-msb'));
end
%devo trasformare 3 a 3 la stringa in interi
s= floor(lenStringa/3);
for i= 1 : s
    num = (find(keyset == Stringa(3*(i-1)+1))-1)*100 +(find(keyset == Stringa(3*(i-1)+2))-1)*10 +(find(keyset == Stringa(3*(i-1)+3))-1);
    ArrayByte=cat(2,ArrayByte,de2bi(num,10,'left-msb'));
end
 if parity == 2
     num = (find(keyset == Stringa(length(Stringa)-1 ))-1 )*10 + find(keyset == Stringa(length(Stringa)))-1;
    ArrayByte=cat(2,ArrayByte,de2bi(num,7,'left-msb'));
 end
 if parity == 1
     num = find(keyset == Stringa(length(Stringa)))-1;
     ArrayByte=cat(2,ArrayByte,de2bi(num,4,'left-msb'));
end

end

function ArrayByte = ByteConv(String,version)

%solita storia con mode e lunghezza stringa dipendente dalla versione
if version < 10
ArrayByte = cat(2,[0,1,0,0],de2bi(length(String),8,'left-msb'));
elseif and(version >= 10, version < 27)
 ArrayByte = cat(2,[0,1,0,0],de2bi(length(String),16,'left-msb'));
else
 ArrayByte = cat(2,[0,1,0,0],de2bi(length(String),16,'left-msb'));
end


%appendo i byte corrispondenti a ciascun carattere della stringa

for j=1:length(String)
 ArrayByte=cat(2,ArrayByte,GetNum(String(j)));
end

end

%ByteConv function
%Ritorna il byte corrispondente al "carattere/stringa" s
function num = GetNum(s)
caratters = {'NUL', 'SOH', 'STX', 'ETX', 'EOT', 'ENQ', 'ACK', 'BEL', ...
 'BS', 'HT', '\n', 'VT', 'FF', 'CR', 'SO', 'SI', 'DLE', ...
 'DC1', 'DC2', 'DC3', 'DC4', 'NAK', 'SYN', 'ETB', 'CAN', ...
 'EM', 'SUB', 'ESC', 'FS', 'GS', 'RS', 'US', ' ', '!', ...
 '"', '#', '$', '%', '&', 'apice', '(', ')', '*', '+', ...
 ',', '-', '.', '/', '0', '1', '2', '3', '4', '5', '6', ...
 '7', '8', '9', ':', ';', '<', '=', '>', '?', '@', 'A', ...
 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', ...
 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', ...
 'X', 'Y', 'Z', '[', '', ']', '^', '_', '`', 'a', 'b', ...
 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', ...
 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', ...
 'y', 'z', '{', '|', '}', '', '?', 'DEL', ''};
K=cellstr(caratters);

h=0;
for i =1:130
 if (strcmp(K{i}, s))
h = i;
 end
end
num = de2bi(h-1,8,'left-msb');
end



% Input: 
%       version --> int, the right version of QR to use
%       ecl --> char, 'H','Q','M','L'

% Output:
%       numDataBits --> int, number of Databits supported by the version
%       n_data_block1 --> number of byte in every block in the first group
%       n_block1 --> number of block in the first block
%       n_data_block2 --> number of byte in every block in the second group
%       n_block2 --> number of block in the second block

function [numDataBits, n_data_block1, n_block1, n_data_block2, n_block2] = info_version(version,eclevel)  

Block_info = [19	7	1	19	0	0	;
16	10	1	16	0	0	;
13	13	1	13	0	0	;
9	17	1	9	0	0	;
34	10	1	34	0	0	;
28	16	1	28	0	0	;
22	22	1	22	0	0	;
16	28	1	16	0	0	;
55	15	1	55	0	0	;
44	26	1	44	0	0	;
34	18	2	17	0	0	;
26	22	2	13	0	0	;
80	20	1	80	0	0	;
64	18	2	32	0	0	;
48	26	2	24	0	0	;
36	16	4	9	0	0	;
108	26	1	108	0	0	;
86	24	2	43	0	0	;
62	18	2	15	2	16	;
46	22	2	11	2	12	;
136	18	2	68	0	0	;
108	16	4	27	0	0	;
76	24	4	19	0	0	;
60	28	4	15	0	0	;
156	20	2	78	0	0	;
124	18	4	31	0	0	;
88	18	2	14	4	15	;
66	26	4	13	1	14	;
194	24	2	97	0	0	;
154	22	2	38	2	39	;
110	22	4	18	2	19	;
86	26	4	14	2	15	;
232	30	2	116	0	0	;
182	22	3	36	2	37	;
132	20	4	16	4	17	;
100	24	4	12	4	13	;
274	18	2	68	2	69	;
216	26	4	43	1	44	;
154	24	6	19	2	20	;
122	28	6	15	2	16	;
324	20	4	81	0	0	;
254	30	1	50	4	51	;
180	28	4	22	4	23	;
140	24	3	12	8	13	;
370	24	2	92	2	93	;
290	22	6	36	2	37	;
206	26	4	20	6	21	;
158	28	7	14	4	15	;
428	26	4	107	0	0	;
334	22	8	37	1	38	;
244	24	8	20	4	21	;
180	22	12	11	4	12	;
461	30	3	115	1	116	;
365	24	4	40	5	41	;
261	20	11	16	5	17	;
197	24	11	12	5	13	;
523	22	5	87	1	88	;
415	24	5	41	5	42	;
295	30	5	24	7	25	;
223	24	11	12	7	13	;
589	24	5	98	1	99	;
453	28	7	45	3	46	;
325	24	15	19	2	20	;
253	30	3	15	13	16	;
647	28	1	107	5	108	;
507	28	10	46	1	47	;
367	28	1	22	15	23	;
283	28	2	14	17	15	;
721	30	5	120	1	121	;
563	26	9	43	4	44	;
397	28	17	22	1	23	;
313	28	2	14	19	15	;
795	28	3	113	4	114	;
627	26	3	44	11	45	;
445	26	17	21	4	22	;
341	26	9	13	16	14	;
861	28	3	107	5	108	;
669	26	3	41	13	42	;
485	30	15	24	5	25	;
385	28	15	15	10	16	;
932	28	4	116	4	117	;
714	26	17	42	0	0	;
512	28	17	22	6	23	;
406	30	19	16	6	17	;
1006	28	2	111	7	112	;
782	28	17	46	0	0	;
568	30	7	24	16	25	;
442	24	34	13	0	0	;
1094	30	4	121	5	122	;
860	28	4	47	14	48	;
614	30	11	24	14	25	;
464	30	16	15	14	16	;
1174	30	6	117	4	118	;
914	28	6	45	14	46	;
664	30	11	24	16	25	;
514	30	30	16	2	17	;
1276	26	8	106	4	107	;
1000	28	8	47	13	48	;
718	30	7	24	22	25	;
538	30	22	15	13	16	;
1370	28	10	114	2	115	;
1062	28	19	46	4	47	;
754	28	28	22	6	23	;
596	30	33	16	4	17	;
1468	30	8	122	4	123	;
1128	28	22	45	3	46	;
808	30	8	23	26	24	;
628	30	12	15	28	16	;
1531	30	3	117	10	118	;
1193	28	3	45	23	46	;
871	30	4	24	31	25	;
661	30	11	15	31	16	;
1631	30	7	116	7	117	;
1267	28	21	45	7	46	;
911	30	1	23	37	24	;
701	30	19	15	26	16	;
1735	30	5	115	10	116	;
1373	28	19	47	10	48	;
985	30	15	24	25	25	;
745	30	23	15	25	16	;
1843	30	13	115	3	116	;
1455	28	2	46	29	47	;
1033	30	42	24	1	25	;
793	30	23	15	28	16	;
1955	30	17	115	0	0	;
1541	28	10	46	23	47	;
1115	30	10	24	35	25	;
845	30	19	15	35	16	;
2071	30	17	115	1	116	;
1631	28	14	46	21	47	;
1171	30	29	24	19	25	;
901	30	11	15	46	16	;
2191	30	13	115	6	116	;
1725	28	14	46	23	47	;
1231	30	44	24	7	25	;
961	30	59	16	1	17	;
2306	30	12	121	7	122	;
1812	28	12	47	26	48	;
1286	30	39	24	14	25	;
986	30	22	15	41	16	;
2434	30	6	121	14	122	;
1914	28	6	47	34	48	;
1354	30	46	24	10	25	;
1054	30	2	15	64	16	;
2566	30	17	122	4	123	;
1992	28	29	46	14	47	;
1426	30	49	24	10	25	;
1096	30	24	15	46	16	;
2702	30	4	122	18	123	;
2102	28	13	46	32	47	;
1502	30	48	24	14	25	;
1142	30	42	15	32	16	;
2812	30	20	117	4	118	;
2216	28	40	47	7	48	;
1582	30	43	24	22	25	;
1222	30	10	15	67	16	;
2956	30	19	118	6	119	;
2334	28	18	47	31	48	;
1666	30	34	24	34	25	;
1276	30	20	15	61	16	];



switch eclevel
    case 'L'
        c = 1;
    case 'M'
        c = 2;
    case 'Q'
        c = 3;
    case 'H'
        c = 4;
end

numDataBits = Block_info(4*(version-1) + c,1)*8;
n_data_block1 = Block_info(4*(version-1) + c,4);
n_block1 = Block_info(4*(version-1) + c,3);
n_data_block2 = Block_info(4*(version-1) + c,6);
n_block2 = Block_info(4*(version-1) + c,5); 

end

