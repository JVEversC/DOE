function resposta = modelo(x1, x2, b)
    resposta = b(1) + b(2) * x1 + b(3) * x2 + b(4) * x1 * x1 + b(5) * x2 * x2 + b(6) * x1 * x2;
end
