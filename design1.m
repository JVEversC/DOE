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

delta = zeros(2);
delta(1) = (variaveis(1).Max - variaveis(1).Min)/2;
delta(2) = (variaveis(2).Max - variaveis(2).Min)/2;

B1 = variaveis(1).Min .* ones(9, 1);
for i = 1:3
    for j = 1:3
        B1(3 * i + j - 3) = B1(3 * i + j - 3) + (i - 1) * delta(1);
    end
end

B2 = variaveis(2).Min .* ones(9, 1);
for i = 1:3
    for j = 1:3
        B2(3 * i + j - 3) = B2(3 * i + j - 3) + (j - 1) * delta(2);
    end
end

prompt = sprintf('Realize os seguintes ensaios em ordem aleatória:');
for i = 1:9
    prompt = [prompt, sprintf('\n%d. %s = %f %s, %s = %f %s', i, variaveis(1).Nome, B1(i), variaveis(1).Unidade, variaveis(2).Nome, B2(i), variaveis(2).Unidade)];
end
questdlg(prompt, 'Ensaios', 'Ok', 'Ok');

aux1 = B1 .* B1;
aux2 = B2 .* B2;
aux3 = B1 .* B2;

A = ones(9, 1);
X = [A , B1 , B2 , aux1 , aux2 , aux3];

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
aux4 = b .* b;
pivot = sqrt(min(aux4));
for i = 1:2
    caminho(i) = delta(i) / pivot;
end
max = resposta;
passos = 1;
x1_in_range = variaveis(1).Min <= B1(5) + passos * caminho(1) && B1(5) + passos * caminho(1) <= variaveis(1).Max;
x2_in_range = variaveis(2).Min <= B2(5) + passos * caminho(2) && B2(5) + passos * caminho(2) <= variaveis(2).Max;
while (resposta >= max && x1_in_range && x2_in_range)
    resposta = modelo(B1(5) + passos * caminho(1), B2(5) + passos * caminho(2), b);
    x1_in_range = variaveis(1).Min <= B1(5) + passos * caminho(1) && B1(5) + passos * caminho(1) <= variaveis(1).Max;
    x2_in_range = variaveis(2).Min <= B2(5) + passos * caminho(2) && B2(5) + passos * caminho(2) <= variaveis(2).Max;
    passos = passos + 1;
end
resposta = modelo(B1(5) + (passos - 1) * caminho(1), B2(5) + (passos - 1) * caminho(2), b);


prompt = sprintf('%f + %f x(1) + %f x(2) + %f (x1)² + %f (x2)² + %f (x1)(x2)', b(1), b(2), b(3), b(4), b(5), b(6));
questdlg(prompt, 'Ok', 'Ok');
prompt = sprintf('O valor maximo de y eh %f', resposta);
questdlg(prompt);
