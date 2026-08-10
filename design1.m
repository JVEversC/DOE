clear variaveis
variaveis(1) = Variavel();
variaveis(2) = Variavel();

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
fieldsize = [1 45; 1 45; 1 45; 1 45];
ans = inputdlg(prompt, dlgtitle, fieldsize);

if ~isempty(ans)
    variaveis(2).Nome = ans{1};
    variaveis(2).Unidade = ans{2};
    variaveis(2).Min = str2double(ans{3});
    variaveis(2).Max = str2double(ans{4});
end

delta = zeros(2);
delta(1) = (variaveis(1).Max - variaveis(1).Min)/2;
delta(2) = (variaveis(2).Max - variaveis(2).Min)/2;

B1 = zeros(9, 1);
for i = 1:9
    prompt = sprintf('Resultado do ensaio %d', i);
    ans = inputdlg(prompt, 'Resultados', [1 45]);
    if ~isempty(ans)
        B1(i) = str2double(ans{1});
    end
end

B2 = zeros(9, 1);
for i = 1:9
    B2(i) = input();
end

aux1 = B1 .* B1;
aux2 = B2 .* B2;
aux3 = B1 .* B2;

A = ones(9, 1);
X = [A ; B1 ; B2; aux1; aux2; aux3];

Y = zeros(9, 1);
for i = 1:9
    prompt = sprintf('Digite o resultado do ensaio de número %d: ', i);
    Y(i, 1)= input(prompt);
end

b = (X' * X) \ (X' * Y);
fprintf('%f + %f x(1) + %f x(2) + %f (x1)² + %f (x2)² + %f (x1)(x2)', b(1), b(2), b(3), b(4), b(5), b(6));


