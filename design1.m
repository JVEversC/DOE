clear variaveis
variaveis(1) = Variavel();
variaveis(2) = Variavel();
resultado = Variavel();

prompt = {'Nome da primeira variável', 'Unidade da primeira variável', 'Limite inferior da primeira variável', 'Limite superior da primeira variável'};
dlgtitle = 'Dados da primeira variável';
fieldsize = [1 45; 1 45; 1 45; 1 45];
in = inputdlg(prompt, dlgtitle, fieldsize);

if ~isempty(in)
    variaveis(1).Nome = in{1};
    variaveis(1).Unidade = in{2};
    variaveis(1).Min = str2double(in{3});
    variaveis(1).Max = str2double(in{4});
end

prompt = {'Nome da segunda variável', 'Unidade da segunda variável', 'Limite inferior da segunda variável', 'Limite superior da segunda variável'};
dlgtitle = 'Dados da segunda variável';
in = inputdlg(prompt, dlgtitle, fieldsize);

if ~isempty(in)
    variaveis(2).Nome = in{1};
    variaveis(2).Unidade = in{2};
    variaveis(2).Min = str2double(in{3});
    variaveis(2).Max = str2double(in{4});
end

prompt = {'Nome do valor a ser otimizado', 'Unidade do valor a ser otimizado'};
dlgtitle = 'Dados do valor a ser otimizado';
fieldsize = [1 45; 1 45];
in = inputdlg(prompt, dlgtitle, fieldsize);

if ~isempty(in)
    resultado.Nome = in{1};
    resultado.Unidade = in{2};
end

delta = zeros(1, 2);
delta(1) = (variaveis(1).Max - variaveis(1).Min)/2;
delta(2) = (variaveis(2).Max - variaveis(2).Min)/2;

B1 = zeros(9, 1);
for i = 1:3
    for j = 1:3
        B1(3 * i + j - 3) =  i - 2;
    end
end

B2 = zeros(9, 1);
for i = 1:3
    for j = 1:3
        B2(3 * i + j - 3) = j - 2;
    end
end

prompt = sprintf('Realize os seguintes ensaios em ordem aleatória:');
for i = 1:9
    aux1 = B1(i) * delta(1) + variaveis(1).Min + delta(1);
    aux2 = B2(i) * delta(2) + variaveis(2).Min + delta(2);
    prompt = [prompt, sprintf('\n%d. %s = %f %s, %s = %f %s', i,variaveis(1).Nome, aux1, variaveis(1).Unidade, variaveis(2).Nome, aux2, variaveis(2).Unidade)];
end
questdlg(prompt, 'Ensaios', 'Ok', 'Ok');

aux3 = B1 .* B1;
aux4 = B2 .* B2;
aux5 = B1 .* B2;

A = ones(9, 1);
X = [A , B1 , B2 , aux3 , aux4 , aux5];

Y = zeros(9, 1);
for i = 1:9
    prompt = sprintf('Resultado do ensaio %d', i);
    in = inputdlg(prompt, 'Resultados', [1 45]);
    if ~isempty(in)
        Y(i) = str2double(in{1});
    end
end

b = (X' * X) \ (X' * Y);
resposta = modelo(B1(5), B2(5), b);

% Andando no superfície de resposta
[passo_base, k] = min(delta .* delta);
passo_base = sqrt(passo_base) / 10;
for i = 1:2
    caminho(i) = passo_base * b(i + 1) / b(k + 1);
end

valor_max = resposta;
passos = 0;
x1 = B1(5);
x2 = B2(5);
x1_in_range = (-1 <= x1) && (x1 <= 1);
x2_in_range = (-1 <= x2) && (x2 <= 1);
while (resposta >= valor_max && x1_in_range && x2_in_range)
    valor_max = resposta;
    passos= passos + 1;
    x1 = B1(5) + passos * caminho(1);
    x2 = B2(5) + passos * caminho(2);
    resposta = modelo(x1, x2, b);
    x1_in_range = (-1 <= x1) && (x1 <= 1);
    x2_in_range = (-1 <= x2) && (x2 <= 1);
end
resposta = modelo(B1(5) + (passos - 1) * caminho(1), B2(5) + (passos - 1) * caminho(2), b);
x1 = x1 * delta(1) + caminho(1);
x2 = x2 * delta(2) + caminho(2);

prompt = sprintf('O %s maximo eh %f %s quando\nx1 = %f, x2 = %f', resultado.Nome, resposta, resultado.Unidade, x1, x2);
questdlg(prompt, 'Valor maximo', 'Ok', 'Ok');
