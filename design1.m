
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
variaveis(2) = inputdlg(prompt, dlgtitle, fieldsize);
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

%{
variaveis(1, 1) = input('Digite o nome da primeira variável: ', 's');
variaveis(2, 1) = input('Digite a unidade da primeira variável: ', 's');
variaveis(1, 2) = input('Digite o nome da segunda variável: ', 's');
variaveis(2, 2) = input('Digite a unidade da segunda variável', 's');
%}

B = zeros(9, 1);
for i = 1:9
    B(i) = input();
end

A = ones(9, 1);
X = [A ; B];
Y = zeros(9, 1);
for i = 1:9
    prompt = sprintf('Digite o resultado do ensaio de número %d: ', i);
    Y(i, 1)= input(prompt);
end


classdef Variavel
    properties
        Nome string
        Unidade string
        Min double
        Max double
    end
end 
