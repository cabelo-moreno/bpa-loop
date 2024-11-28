# BPA Rules in Looping

Esse script roda o bpa rules para todos os modelos em uma lista de servidores.
a lista pode conter tanto servidores analysis services quanto workspaces do powerbi
a identidade gerenciada precisa ter acesso a todos os servidores na lista.
para gravação dos nomes removemos os acentos colchetes e espaços, então se tiver dois modelos muito parecidos teremos duplicidade:
Model Name1 --> modelname1
Model [Name] 1 --> modelname1
