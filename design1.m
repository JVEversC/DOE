clear variaveis
variaveis(1) = Variavel();
variaveis(2) = Variavel();
resultado = Variavel();

prompt = {'Nome da primeira variável', 'Unidade da primeira variável', 'Limite inferior da primeira variável', 'Limite superior da primeira variável'};
dlgtitle = 'Dados da primeira variável';
fieldsize = [1 45; 1 45; 1 45; 1 45];
ans = inputdlg(prompt, dlgtitle, fieldsize);

if ~isempty(ans)
    variaveis(1).Nome = ans{1};
    variaveis(1).Unidade = ans{2};
    variaveis(1).Min = str2double(ans{3});
    variaveis(1).Max = str2double(ans{4});
end

prompt = {'Nome da segunda variável', 'Unidade da segunda variável', 'Limite inferior da segunda variável', 'Limite superior da segunda variável'};
dlgtitle = 'Dados da segunda variável';
ans = inputdlg(prompt, dlgtitle, fieldsize);

if ~isempty(ans)
    variaveis(2).Nome = ans{1};
    variaveis(2).Unidade = ans{2};
    variaveis(2).Min = str2double(ans{3});
    variaveis(2).Max = str2double(ans{4});
end

prompt = {'Nome do valor a ser otimizado', 'Unidade do valor a ser otimizado'};
dlgtitle = 'Dados do valor a ser otimizado';
fieldsize = [1 45; 1 45];
ans = inputdlg(prompt, dlgtitle, fieldsize);

delta = zeros(2);
delta(1) = (variaveis(1).Max - variaveis(1).Min)/2;
delta(2) = (variaveis(2).Max - variaveis(2).Min)/2;

mydialog

B1 = variaveis(1).Min .* ones(9, 1);
for i = 1:3
    for j = 1:3
        B1(i, j) = B(i, j) + (j - 1) * delta(1)/2;
    end
end

B2 = variaveis(2).Min .* ones(9, 1);
for i = 1:9
    for j = 1:3;
        B2(i, j) = B(i, j) + (i - 1) * delta(2)/2;
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
X = [A ; B1 ; B2; aux1; aux2; aux3];

Y = zeros(9, 1);
for i = 1:9
    prompt = sprintf('Resultado do ensaio %d', i);
    ans = inputdlg(prompt, 'Resultados', [1 45]);
    if ~isempty(ans)
        Y(i) = str2double(ans{1});
    end
end

b = (X' * X) \ (X' * Y);

% Andando no superfície de resposta
aux4 = b .* b;
pivot = sqrt(min(c));
for i = 1:6
    caminho(i) = b(i) * pivot;
end

prompt = sprintf('%f + %f x(1) + %f x(2) + %f (x1)² + %f (x2)² + %f (x1)(x2)', b(1), b(2), b(3), b(4), b(5), b(6));
questdlg(prompt, 'Ok', 'Ok');

