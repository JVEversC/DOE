function resposta = modelo(x1, x2, b)
    resposta = 0;
    for i = 1:3
        for j = 1:2
            resposta = resposta + b(i + j) * x1^j * x2^(2 - j);
        end
    end
end
