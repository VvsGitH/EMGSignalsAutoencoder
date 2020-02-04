%% Denormalizazzione per riga di un dataset matriciale
% Xnorm: dataset
% [a, b]: estremi di normalizzazione
% MAX: vettore dei massimi di ogni riga del dataset, prima della
%      normalizzazione
% MIN: (opzionale) vettore dei minimi di ogni riga del dataset, prima della
%      normalizzazione. Se omesso viene considerato 0.

function XRecos = dataDenormalize(Xnorm,a,b,MAX,MIN)

% Numero di Righe
R = size(Xnorm,1);

% Imposto MIN = 0 se omesso
if nargin == 4
    MIN = zeros(R,1);
end

% Denormalizzazione con la seguente formula inversa:
%       Xrecos = (Xnorm-a)*(max-min)/(b-a) + min
XRecos = zeros(R, size(Xnorm,2));
for i = 1:R
    XRecos(i,:) = ((Xnorm(i,:)-a).*(MAX(i,1)-MIN(i,1)))./(b-a) + MIN(i,1);
end

end