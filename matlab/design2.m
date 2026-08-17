% =========================================================================
% 1. CONFIGURAÇÃO DO CAMINHO DO ARQUIVO (MULTI-PLATAFORMA)
% =========================================================================
if ispc
    pasta_usuario = getenv('USERPROFILE'); % Windows
else
    pasta_usuario = getenv('HOME');        % Mac / Linux
end

pasta_dados = fullfile(pasta_usuario, 'DOE_invadiu', 'Meus_Experimentos_DoE');

if ~exist(pasta_dados, 'dir')
    mkdir(pasta_dados);
end

arquivo_completo = fullfile(pasta_dados, 'experimento_atual.mat');

% =========================================================================
% 2. MÁQUINA DE ESTADOS: VERIFICA SE JÁ EXISTEM DADOS SALVOS
% =========================================================================
if isfile(arquivo_completo)
    load(arquivo_completo);
else
    etapa = 1;
    clear variaveis
    variaveis(1) = Variavel();
    variaveis(2) = Variavel();
    resultado = Variavel();
end

% =========================================================================
% ETAPA 1: CONFIGURAÇÃO DAS VARIÁVEIS E MATRIZES
% =========================================================================
if etapa == 1
    prompt = {'Nome da primeira variável', 'Unidade da primeira variável', ...
              'Limite inferior da primeira variável', 'Limite superior da primeira variável'};
    dlgtitle = 'Dados da primeira variável';
    fieldsize = [1 45; 1 45; 1 45; 1 45];
    in = inputdlg(prompt, dlgtitle, fieldsize);

    if isempty(in), return; end % Cancela se fechar a janela
    variaveis(1).Nome = in{1};
    variaveis(1).Unidade = in{2};
    variaveis(1).Min = str2double(in{3});
    variaveis(1).Max = str2double(in{4});

    prompt = {'Nome da segunda variável', 'Unidade da segunda variável', ...
              'Limite inferior da segunda variável', 'Limite superior da segunda variável'};
    dlgtitle = 'Dados da segunda variável';
    in = inputdlg(prompt, dlgtitle, fieldsize);

    if isempty(in), return; end
    variaveis(2).Nome = in{1};
    variaveis(2).Unidade = in{2};
    variaveis(2).Min = str2double(in{3});
    variaveis(2).Max = str2double(in{4});

    prompt = {'Nome do valor a ser otimizado', 'Unidade do valor a ser otimizado'};
    dlgtitle = 'Dados do valor a ser otimizado';
    fieldsize = [1 45; 1 45];
    in = inputdlg(prompt, dlgtitle, fieldsize);

    if isempty(in), return; end
    resultado.Nome = in{1};
    resultado.Unidade = in{2};

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

    aux3 = B1 .* B1;
    aux4 = B2 .* B2;
    aux5 = B1 .* B2;
    A = ones(9, 1);
    X = [A, B1, B2, aux3, aux4, aux5];
    Y = zeros(9, 1);

    etapa = 2;
    save(arquivo_completo, 'variaveis', 'resultado', 'delta', 'B1', 'B2', 'X', 'Y', 'etapa');

% =========================================================================
% ETAPA 2: EXIBIÇÃO DOS ENSAIOS A SEREM REALIZADOS
% =========================================================================
elseif etapa == 2
    prompt = sprintf('Realize os seguintes ensaios em ordem aleatória:');
    for i = 1:9
        aux1 = B1(i) * delta(1) + variaveis(1).Min + delta(1);
        aux2 = B2(i) * delta(2) + variaveis(2).Min + delta(2);
        prompt = [prompt, sprintf('\n%d. %s = %f %s, %s = %f %s', i, variaveis(1).Nome, aux1, variaveis(1).Unidade, variaveis(2).Nome, aux2, variaveis(2).Unidade)];
    end
    
    resp = questdlg(prompt, 'Ensaios', 'Já fiz os ensaios e quero inserir os dados', 'Ver depois', 'Ver depois');
    
    if strcmp(resp, 'Já fiz os ensaios e quero inserir os dados')
        etapa = 3;
        save(arquivo_completo, 'etapa', '-append');
        % Força a execução da Etapa 3 imediatamente se o usuário já tiver os dados
        run_etapa3 = true; 
    else
        return; % Encerra aqui para o usuário poder consultar a lista quando quiser
    end

% =========================================================================
% ETAPA 3: COLETA DOS RESULTADOS DOS 9 EXPERIMENTOS
% =========================================================================
end

if etapa == 3 || (exist('run_etapa3', 'var') && run_etapa3)
    preenchido_com_sucesso = true;
    for i = 1:9
        prompt_str = sprintf('Resultado do ensaio %d', i);
        in = inputdlg(prompt_str, 'Resultados', [1 45]);
        
        if ~isempty(in) && ~isnan(str2double(in{1}))
            Y(i) = str2double(in{1});
        else
            preenchido_com_sucesso = false;
            msgbox('Entrada cancelada ou inválida. O progresso foi salvo até onde você preencheu.', 'Aviso');
            break;
        end
        save(arquivo_completo, 'Y', '-append'); 
    end

    if preenchido_com_sucesso
        etapa = 4;
        save(arquivo_completo, 'etapa', '-append');
    else
        return; % Não avança para a Etapa 4 se faltar algum dado
    end
end

% =========================================================================
% ETAPA 4: OTIMIZAÇÃO E RESULTADO FINAL
% =========================================================================
if etapa == 4
    b = (X' * X) \ (X' * Y);
    resposta = modelo(0, 0, b);

    if b(2) == 0
        b(2) = 1;
    end

    caminho(1) = 0.01;
    caminho(2) = 0.01 * b(3) / b(2); 

    valor_max = resposta;
    passos = 0;
    x1 = 0;
    x2 = 0;
    x1_in_range = (-1 <= x1) && (x1 <= 1);
    x2_in_range = (-1 <= x2) && (x2 <= 1);

    while (resposta >= valor_max && x1_in_range && x2_in_range)
        valor_max = resposta;
        passos = passos + 1;
        x1 = x1 + caminho(1);
        x2 = x2 + caminho(2);
        resposta = modelo(x1, x2, b);
        x1_in_range = (-1 <= x1) && (x1 <= 1);
        x2_in_range = (-1 <= x2) && (x2 <= 1);
    end

    resposta = modelo(x1 - caminho(1), x2 - caminho(2), b);
    x1 = (x1 - caminho(1)) * delta(1) + variaveis(1).Min + delta(1);
    x2 = (x2 - caminho(2)) * delta(2) + variaveis(2).Min + delta(2);

    x = - ([2*b(4), b(6); b(6), 2*b(5)] \ [b(2); b(3)]);
    if (x(1) <= 1 && x(1) >= -1 && x(2) <= 1 && x(2) >= -1)
        x1 = x(1) * delta(1) + variaveis(1).Min + delta(1);
        x2 = x(2) * delta(2) + variaveis(2).Min + delta(2);
        resposta = modelo(x1, x2, b);
    end

    prompt = sprintf('O %s maximo eh %f %s quando %s = %f %s, %s = %f %s', ...
        resultado.Nome, resposta, resultado.Unidade, ...
        variaveis(1).Nome, x1, variaveis(1).Unidade, ...
        variaveis(2).Nome, x2, variaveis(2).Unidade);
        
    questdlg(prompt, 'Valor Maximo', 'Ok', 'Ok');
end
