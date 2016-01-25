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
 'X', 'Y', 'Z', '[', '?', ']', '^', '_', '`', 'a', 'b', ...
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