T = [40,45,50,55,60]';
r = [60,70,77,86,91]';

tabela_dados = table(T, r);

tabela_dados.Properties.VariableNames = {'T (ºC)', 'r (%)'};

rmodel = -1.2 + 1.56 * T;

anovatab(r,rmodel, true, 1, 1);
latextab(tabela_dados);